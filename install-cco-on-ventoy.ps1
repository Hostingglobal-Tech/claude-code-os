<#
.SYNOPSIS
  AICODE-OS USB 자동 준비 도구 (Windows)

.DESCRIPTION
  초보자용 흐름:
  1. USB 디스크를 선택한다.
  2. Ventoy를 USB에 설치하거나, 이미 설치된 Ventoy USB를 찾는다.
  3. GitHub Release에서 AICODE-OS ISO 조각과 persistence 파일을 받는다.
  4. ISO를 합치고, persistence 압축을 푼 뒤 USB에 복사한다.
  5. ventoy\ventoy.json을 자동 생성한다.

  주의: Ventoy 설치 단계는 선택한 USB의 기존 데이터를 삭제한다.
  안전장치: OS 디스크, C: 포함 디스크, Fixed/NVMe/SATA 계열 디스크는 차단한다.

.EXAMPLE
  관리자 PowerShell:
  PS> .\install-cco-on-ventoy.ps1

.EXAMPLE
  2번 물리 디스크에 Ventoy를 설치하고 v2.0.5 Release 파일을 USB에 배치:
  PS> .\install-cco-on-ventoy.ps1 -DiskNumber 2 -Version v2.0.5

.EXAMPLE
  이미 Ventoy가 설치된 F: 드라이브에만 파일 복사:
  PS> .\install-cco-on-ventoy.ps1 -Drive F: -SkipVentoyInstall
#>

[CmdletBinding()]
param(
    [int]$DiskNumber = -1,
    [string]$Drive = "",
    [string]$Version = "latest",
    [string]$IsoPath = "",
    [string]$WorkDir = "$env:TEMP\AICODE-OS-USB",
    [switch]$SkipVentoyInstall,
    [switch]$UpdateVentoy
)

$ErrorActionPreference = "Stop"
$Repo = "Hostingglobal-Tech/claude-code-os"

function Write-Step([string]$Text) {
    Write-Host ""
    Write-Host "== $Text ==" -ForegroundColor Cyan
}

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($id)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Normalize-Drive([string]$Value) {
    if (-not $Value) { return "" }
    $d = $Value.TrimEnd("\")
    if ($d.Length -eq 1) { $d = "${d}:" }
    return $d
}

function Get-Release([string]$Tag) {
    if ($Tag -eq "latest") {
        return Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/latest"
    }
    return Invoke-RestMethod "https://api.github.com/repos/$Repo/releases/tags/$Tag"
}

function Save-Url([string]$Url, [string]$OutFile) {
    if (Test-Path $OutFile) {
        Write-Host "이미 있음: $OutFile" -ForegroundColor DarkYellow
        return
    }
    Write-Host "다운로드: $Url"
    Invoke-WebRequest $Url -OutFile $OutFile -UseBasicParsing
}

function Find-Asset($Release, [string]$Name) {
    $asset = $Release.assets | Where-Object { $_.name -eq $Name } | Select-Object -First 1
    if (-not $asset) {
        throw "Release asset을 찾지 못했습니다: $Name"
    }
    return $asset.browser_download_url
}

function Get-VentoyRelease {
    return Invoke-RestMethod "https://api.github.com/repos/ventoy/Ventoy/releases/latest"
}

function Get-DiskDriveLetters([int]$DiskNumber) {
    $letters = @()
    try {
        $parts = Get-Partition -DiskNumber $DiskNumber -ErrorAction Stop
        foreach ($part in $parts) {
            if ($part.DriveLetter) {
                $letters += "$($part.DriveLetter):"
            }
        }
    } catch {
        return @()
    }
    return $letters
}

function Assert-SafeVentoyTarget {
    param($Disk)

    $letters = Get-DiskDriveLetters -DiskNumber $Disk.Number
    $bootDrive = [Environment]::GetEnvironmentVariable("SystemDrive")
    if (-not $bootDrive) { $bootDrive = "C:" }
    $bootDrive = $bootDrive.ToUpperInvariant()
    $letterText = if ($letters.Count) { $letters -join ", " } else { "(드라이브 문자 없음)" }

    $blockedReasons = @()
    if ($Disk.IsBoot) { $blockedReasons += "Windows 부팅 디스크" }
    if ($Disk.IsSystem) { $blockedReasons += "Windows 시스템 디스크" }
    if ($letters | Where-Object { $_.ToUpperInvariant() -eq $bootDrive }) { $blockedReasons += "$bootDrive 포함 디스크" }
    if ($Disk.BusType -ne "USB") { $blockedReasons += "USB 디스크가 아님(BusType=$($Disk.BusType))" }

    # Windows는 일부 외장 장치를 Fixed로 표시할 수 있지만, 이 도구는 초보자 보호가 목적이다.
    # 그러므로 USB로 보이지 않는 장치는 차단한다.
    if ($blockedReasons.Count -gt 0) {
        $msg = @(
            "Ventoy 설치 대상이 안전하지 않아 중단합니다.",
            "Disk Number: $($Disk.Number)",
            "Name: $($Disk.FriendlyName)",
            "BusType: $($Disk.BusType)",
            "DriveLetters: $letterText",
            "차단 사유: $($blockedReasons -join ', ')",
            "",
            "실제 사용 중인 물리 드라이브 포맷을 막기 위한 강제 안전장치입니다.",
            "반드시 USB 메모리만 선택하세요."
        ) -join [Environment]::NewLine
        throw $msg
    }

    return $letterText
}

function Install-VentoyIfNeeded {
    param([int]$TargetDiskNumber, [switch]$DoUpdate)

    if (-not (Test-Admin)) {
        throw "Ventoy 설치/업데이트는 관리자 PowerShell에서 실행해야 합니다."
    }

    Write-Step "USB 디스크 확인"
    $usbDisks = Get-Disk | Where-Object { $_.BusType -eq "USB" } | Sort-Object Number
    if (-not $usbDisks) {
        throw "USB 디스크를 찾지 못했습니다. USB를 꽂은 뒤 다시 실행하세요."
    }

    $usbDisks | Select-Object Number,FriendlyName,SerialNumber,PartitionStyle,OperationalStatus,@{n="DriveLetters";e={(Get-DiskDriveLetters $_.Number) -join ", "}},@{n="GB";e={[math]::Round($_.Size/1GB,1)}} | Format-Table -AutoSize

    if ($TargetDiskNumber -lt 0) {
        $TargetDiskNumber = Read-Host "Ventoy를 설치할 USB Disk Number를 입력하세요"
        $TargetDiskNumber = [int]$TargetDiskNumber
    }

    $disk = Get-Disk -Number $TargetDiskNumber -ErrorAction Stop
    $letterText = Assert-SafeVentoyTarget -Disk $disk

    Write-Host ""
    Write-Host "선택한 디스크:" -ForegroundColor Yellow
    $disk | Select-Object Number,FriendlyName,SerialNumber,BusType,PartitionStyle,IsBoot,IsSystem,@{n="DriveLetters";e={$letterText}},@{n="GB";e={[math]::Round($_.Size/1GB,1)}} | Format-List

    $confirm = Read-Host "이 USB의 기존 데이터가 삭제됩니다. 계속하려면 ERASE USB $($disk.Number) 를 정확히 입력하세요"
    if ($confirm -ne "ERASE USB $($disk.Number)") {
        throw "사용자가 취소했습니다."
    }

    Write-Step "Ventoy 다운로드"
    New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null
    $ventoyRel = Get-VentoyRelease
    $zipAsset = $ventoyRel.assets | Where-Object { $_.name -like "ventoy-*-windows.zip" } | Select-Object -First 1
    if (-not $zipAsset) {
        throw "Ventoy Windows ZIP asset을 찾지 못했습니다."
    }
    $zipPath = Join-Path $WorkDir $zipAsset.name
    Save-Url $zipAsset.browser_download_url $zipPath

    $extractDir = Join-Path $WorkDir "ventoy"
    if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
    Expand-Archive $zipPath -DestinationPath $extractDir -Force

    $exe = Get-ChildItem $extractDir -Recurse -File -Filter "Ventoy2Disk.exe" | Select-Object -First 1
    if (-not $exe) {
        throw "Ventoy2Disk.exe를 찾지 못했습니다."
    }

    Write-Step "Ventoy 설치"
    $mode = if ($DoUpdate) { "/U" } else { "/I" }
    $args = @("VTOYCLI", $mode, "/PhyDrive:$TargetDiskNumber", "/GPT", "/FS:EXFAT")
    Write-Host "$($exe.FullName) $($args -join ' ')"
    $p = Start-Process -FilePath $exe.FullName -ArgumentList $args -Wait -PassThru -WorkingDirectory $exe.DirectoryName
    if ($p.ExitCode -ne 0) {
        throw "Ventoy 설치 명령이 실패했습니다. ExitCode=$($p.ExitCode)"
    }

    $done = Join-Path $exe.DirectoryName "cli_done.txt"
    if (Test-Path $done) {
        $doneValue = (Get-Content $done -Raw).Trim()
        if ($doneValue -ne "0") {
            throw "Ventoy CLI 결과가 실패입니다. cli_done.txt=$doneValue"
        }
    }
}

function Get-VentoyDrive {
    param([string]$PreferredDrive)

    $PreferredDrive = Normalize-Drive $PreferredDrive
    if ($PreferredDrive) {
        if (-not (Test-Path "$PreferredDrive\")) {
            throw "드라이브를 찾지 못했습니다: $PreferredDrive"
        }
        return $PreferredDrive
    }

    Write-Step "Ventoy USB 드라이브 찾기"
    for ($i = 0; $i -lt 30; $i++) {
        $vol = Get-Volume -ErrorAction SilentlyContinue |
            Where-Object { $_.DriveLetter -and ($_.FileSystemLabel -eq "VENTOY" -or $_.FileSystemLabel -eq "Ventoy") } |
            Select-Object -First 1
        if ($vol) {
            return "$($vol.DriveLetter):"
        }
        Start-Sleep -Seconds 2
    }
    throw "VENTOY 라벨의 USB 드라이브를 찾지 못했습니다. -Drive F: 처럼 직접 지정하세요."
}

function Expand-Xz {
    param([string]$XzPath, [string]$OutPath)

    if (Test-Path $OutPath) {
        Write-Host "이미 있음: $OutPath" -ForegroundColor DarkYellow
        return
    }

    Write-Step "persistence 압축 풀기"

    $sevenZip = @(
        "$env:ProgramFiles\7-Zip\7z.exe",
        "${env:ProgramFiles(x86)}\7-Zip\7z.exe"
    ) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1

    if ($sevenZip) {
        & $sevenZip x "-o$(Split-Path $OutPath -Parent)" $XzPath -y | Out-Host
        $expanded = Join-Path (Split-Path $OutPath -Parent) ([IO.Path]::GetFileNameWithoutExtension($XzPath))
        if ($expanded -ne $OutPath -and (Test-Path $expanded)) {
            Move-Item $expanded $OutPath -Force
        }
        return
    }

    if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
        $winDir = (Split-Path $XzPath -Parent)
        $drive = $winDir.Substring(0, 1).ToLower()
        $rest = $winDir.Substring(2).Replace("\", "/")
        $wslDir = "/mnt/$drive$rest"
        $xzName = Split-Path $XzPath -Leaf
        $outName = Split-Path $OutPath -Leaf
        wsl.exe -- bash -lc "cd '$wslDir' && xz -dc '$xzName' > '$outName'"
        return
    }

    throw "압축 해제 도구가 없습니다. 7-Zip을 설치하거나 WSL을 설치한 뒤 다시 실행하세요."
}

function Write-VentoyJson {
    param([string]$UsbDrive, [string]$IsoName)

    $ventoyDir = Join-Path $UsbDrive "ventoy"
    New-Item -ItemType Directory -Path $ventoyDir -Force | Out-Null

    $json = @"
{
  "control": [
    { "VTOY_DEFAULT_MENU_MODE": "0" },
    { "VTOY_MENU_TIMEOUT": "3" },
    { "VTOY_DEFAULT_IMAGE": "/$IsoName" }
  ],
  "persistence": [
    {
      "image": "/$IsoName",
      "backend": "/cco-persistence.dat",
      "autosel": 1
    }
  ]
}
"@
    Set-Content -Path (Join-Path $ventoyDir "ventoy.json") -Value $json -Encoding ASCII
}

Write-Step "AICODE-OS USB 준비 시작"
New-Item -ItemType Directory -Path $WorkDir -Force | Out-Null

if (-not $SkipVentoyInstall) {
    Install-VentoyIfNeeded -TargetDiskNumber $DiskNumber -DoUpdate:$UpdateVentoy
}

$Drive = Get-VentoyDrive -PreferredDrive $Drive
Write-Host "사용할 USB 드라이브: $Drive" -ForegroundColor Green

$release = Get-Release $Version
$Version = $release.tag_name
$isoName = "aicode-os-$Version.iso"
$part1 = "$isoName.part1"
$part2 = "$isoName.part2"
$sha = "$isoName.sha256"
$persistXz = "cco-persistence.dat.xz"

Write-Step "Release 파일 준비 ($Version)"
if ($IsoPath) {
    if (-not (Test-Path $IsoPath)) { throw "ISO 파일을 찾지 못했습니다: $IsoPath" }
    Copy-Item $IsoPath (Join-Path $WorkDir $isoName) -Force
} else {
    Save-Url (Find-Asset $release $part1) (Join-Path $WorkDir $part1)
    Save-Url (Find-Asset $release $part2) (Join-Path $WorkDir $part2)
    Save-Url (Find-Asset $release $sha) (Join-Path $WorkDir $sha)

    $isoWork = Join-Path $WorkDir $isoName
    if (-not (Test-Path $isoWork)) {
        Write-Step "ISO 조각 합치기"
        cmd.exe /c "copy /b `"$WorkDir\$part1`"+`"$WorkDir\$part2`" `"$isoWork`""
    }
}

Save-Url (Find-Asset $release $persistXz) (Join-Path $WorkDir $persistXz)
Expand-Xz (Join-Path $WorkDir $persistXz) (Join-Path $WorkDir "cco-persistence.dat")

Write-Step "USB에 파일 복사"
Copy-Item (Join-Path $WorkDir $isoName) (Join-Path $Drive $isoName) -Force
Copy-Item (Join-Path $WorkDir "cco-persistence.dat") (Join-Path $Drive "cco-persistence.dat") -Force
Write-VentoyJson -UsbDrive $Drive -IsoName $isoName

Write-Step "완료"
Write-Host "USB 준비가 끝났습니다." -ForegroundColor Green
Write-Host "USB: $Drive"
Write-Host "ISO: $isoName"
Write-Host "Persistence: cco-persistence.dat"
Write-Host ""
Write-Host "이제 대상 PC에서 USB 부팅 메뉴(F12/ESC/F2 등)를 열고 이 USB를 선택하세요."
