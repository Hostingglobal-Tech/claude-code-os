# AICODE-OS — Windows persistence dat 자동 생성
# Usage:  powershell -ExecutionPolicy Bypass -File Make-Persistence.ps1 [-Size 3500] [-Out cco-persistence.dat]
# Requires: WSL (wsl --install) — Windows native 에 mkfs.ext4 없음

param(
    [int]$Size = 3500,
    [string]$Out = "cco-persistence.dat"
)

$ErrorActionPreference = "Stop"

# WSL 설치 확인
if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] WSL 미설치." -ForegroundColor Red
    Write-Host "        관리자 PowerShell 에서: wsl --install" -ForegroundColor Yellow
    Write-Host "        또는 Release 에서 cco-persistence.dat.xz 다운로드 후 7-Zip 으로 풀기." -ForegroundColor Yellow
    exit 1
}

$distros = wsl.exe --list --quiet 2>$null | Where-Object { $_ -and $_.Trim() -ne "" }
if (-not $distros) {
    Write-Host "[ERROR] WSL distro 없음." -ForegroundColor Red
    Write-Host "        wsl --install -d Ubuntu  로 설치 후 한 번 부팅 (사용자명/비번 설정)." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "AICODE-OS persistence dat 생성" -ForegroundColor Cyan
Write-Host "  Size:  ${Size} MB"
Write-Host "  Out:   ${Out}"
Write-Host "  Label: casper-rw (ext4)"
Write-Host ""

# Windows 경로 → WSL 경로 변환
$winDir = (Get-Location).Path
$drive = $winDir.Substring(0, 1).ToLower()
$rest = $winDir.Substring(2).Replace("\", "/")
$wslDir = "/mnt/$drive$rest"

Write-Host "WSL distro 경유로 dd + mkfs.ext4 실행 (sudo 비번 입력 필요)..." -ForegroundColor Cyan
Write-Host ""

$cmd = "cd '$wslDir' && sudo dd if=/dev/zero of='$Out' bs=1M count=$Size status=progress && sudo mkfs.ext4 -F -L casper-rw '$Out'"
wsl.exe -- bash -c $cmd

if (Test-Path $Out) {
    $size = (Get-Item $Out).Length
    Write-Host ""
    Write-Host "[OK] $Out 생성 완료 ($([math]::Round($size/1GB, 2)) GB)" -ForegroundColor Green
    Write-Host ""
    Write-Host "다음 단계 — Ventoy USB root 에 복사:" -ForegroundColor Yellow
    Write-Host "  copy $Out F:\"
    Write-Host "  (USB 드라이브 letter 확인 후 F: 부분 변경)"
} else {
    Write-Host "[FAIL] $Out 생성 실패" -ForegroundColor Red
    exit 1
}
