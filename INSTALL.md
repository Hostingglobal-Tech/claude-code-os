# 설치 가이드 — AICODE-OS + Ventoy persistence

USB 한 개로 Claude Code와 OpenAI Codex가 들어 있는 Linux Mint XFCE 기반 AI 작업 환경을 부팅하는 방법입니다. Wi-Fi, 로그인, 작업 파일은 `cco-persistence.dat`에 저장되어 재부팅 후에도 유지됩니다.

---

## 0. 가장 중요한 안전 원칙

Ventoy 설치는 USB를 부팅 가능하게 만들기 위해 선택한 디스크를 다시 구성합니다. 잘못 선택하면 실제 사용 중인 물리 디스크가 포맷될 수 있습니다.

이 저장소의 Windows 자동 도구는 다음 안전장치를 둡니다.

- USB로 표시되는 디스크만 Ventoy 설치 대상으로 허용
- Windows 부팅 디스크, 시스템 디스크, C: 포함 디스크는 무조건 차단
- 포맷 직전 `ERASE USB 디스크번호`를 직접 입력해야 진행
- 이미 Ventoy가 설치된 USB에는 `-SkipVentoyInstall`로 포맷 없이 파일만 복사 가능

그래도 중요한 USB 데이터는 먼저 백업하세요.

---

## 1. Windows에서 가장 쉽게 준비하기

명령어를 모르면 이 방법을 쓰면 됩니다.

1. [Releases v2.0.7](https://github.com/Hostingglobal-Tech/claude-code-os/releases/tag/v2.0.7)에서 `AICODE-OS-USB-Maker-v2.0.7.zip`을 다운로드합니다.
2. 압축을 풉니다.
3. `AICODE-OS-USB-만들기.cmd`를 더블클릭합니다.
4. 관리자 권한 요청이 나오면 허용합니다.
5. USB 디스크 목록에서 USB 메모리만 선택합니다.

이 `.cmd` 파일은 사용자가 PowerShell 명령을 몰라도 되도록 만든 실행 파일입니다. 실제 작업은 `install-cco-on-ventoy.ps1`이 처리합니다.

관리자 PowerShell에서 직접 실행하려면:

```powershell
cd C:\DEVEL\claude-code-os
powershell -ExecutionPolicy Bypass -File .\install-cco-on-ventoy.ps1
```

도구가 하는 일:

1. USB 디스크 목록 표시
2. 사용자가 USB Disk Number 선택
3. Ventoy 최신 Windows 패키지 다운로드
4. Ventoy CLI로 USB 설치
5. GitHub Release에서 `aicode-os-vX.Y.Z.iso.part1`, `part2`, `sha256`, `cco-persistence.dat.xz` 다운로드
6. ISO 조각 병합
7. `cco-persistence.dat.xz` 압축 해제
8. USB root에 ISO와 persistence 복사
9. `USB:\ventoy\ventoy.json` 자동 생성

이미 Ventoy가 설치된 USB에 파일만 넣으려면:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-cco-on-ventoy.ps1 -Drive F: -SkipVentoyInstall
```

특정 Release를 지정하려면:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-cco-on-ventoy.ps1 -Version v2.0.7
```

로컬 ISO를 이미 가지고 있다면:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-cco-on-ventoy.ps1 -Drive F: -SkipVentoyInstall -IsoPath D:\AICODE_OS_RELEASE\v2.0.7\aicode-os-v2.0.7.iso
```

---

## 2. 수동 설치

### 2.1 Ventoy 설치

[Ventoy 공식 사이트](https://www.ventoy.net/)에서 Windows ZIP을 받고 `Ventoy2Disk.exe`를 실행합니다. USB를 선택하고 Install을 누릅니다.

Ventoy 공식 Windows CLI도 사용할 수 있습니다.

```cmd
Ventoy2Disk.exe VTOYCLI /I /PhyDrive:2 /GPT /FS:EXFAT
```

`/PhyDrive:2`의 숫자는 실제 USB Disk Number입니다. 숫자를 잘못 고르면 위험하므로 Windows 디스크 관리에서 반드시 확인하세요.

### 2.2 Release 파일 다운로드

[GitHub Releases](https://github.com/Hostingglobal-Tech/claude-code-os/releases/latest)에서 다음 파일을 받습니다.

| 파일 | 용도 |
|---|---|
| `aicode-os-vX.Y.Z.iso.part1` | ISO 조각 1 |
| `aicode-os-vX.Y.Z.iso.part2` | ISO 조각 2 |
| `aicode-os-vX.Y.Z.iso.sha256` | 병합한 ISO 검증값 |
| `cco-persistence.dat.xz` | 설정 저장소 압축본 |

### 2.3 ISO 조각 합치기

Windows `cmd`:

```cmd
copy /b aicode-os-vX.Y.Z.iso.part1+aicode-os-vX.Y.Z.iso.part2 aicode-os-vX.Y.Z.iso
```

Linux/macOS:

```bash
cat aicode-os-vX.Y.Z.iso.part1 aicode-os-vX.Y.Z.iso.part2 > aicode-os-vX.Y.Z.iso
```

검증:

```bash
sha256sum -c aicode-os-vX.Y.Z.iso.sha256
```

### 2.4 persistence 압축 풀기

Windows:

- 7-Zip 설치
- `cco-persistence.dat.xz` 우클릭
- "여기에 압축 풀기"
- `cco-persistence.dat` 생성 확인

Linux/macOS:

```bash
xz -d cco-persistence.dat.xz
```

### 2.5 USB에 복사

USB root:

```text
F:\
├── aicode-os-vX.Y.Z.iso
├── cco-persistence.dat
└── ventoy\
    └── ventoy.json
```

`ventoy.json` 예시:

```json
{
  "control": [
    { "VTOY_DEFAULT_MENU_MODE": "0" },
    { "VTOY_MENU_TIMEOUT": "3" },
    { "VTOY_DEFAULT_IMAGE": "/aicode-os-vX.Y.Z.iso" }
  ],
  "persistence": [
    {
      "image": "/aicode-os-vX.Y.Z.iso",
      "backend": "/cco-persistence.dat",
      "autosel": 1
    }
  ]
}
```

`vX.Y.Z` 부분은 실제 파일명과 정확히 일치해야 합니다.

---

## 3. 부팅

1. USB를 대상 PC에 꽂습니다.
2. 전원을 켭니다.
3. 제조사 부팅 메뉴 키를 누릅니다. 보통 `F12`, `ESC`, `F2`, `F8`, `F11` 중 하나입니다.
4. USB 장치를 선택합니다.
5. Ventoy가 자동으로 AICODE-OS ISO를 선택하고 persistence를 적용합니다.
6. Linux Mint XFCE 데스크톱이 뜨면 Claude Code와 OpenAI Codex 탭이 자동으로 열립니다.

---

## 4. 한글 입력

v2.0.6부터 기본 한/영 토글:

- `Shift+Space`
- `한/영` 키
- `Caps Lock`
- `Super+Space`

맥북 사용자가 익숙한 `Caps Lock = 한/영` 흐름을 반영했습니다.

v2.0.5에서 직접 켜려면 터미널에서 한 번 실행합니다.

```bash
dconf write /desktop/ibus/general/hotkey/triggers "['<Shift>space', 'Hangul', 'Caps_Lock', '<Super>space']"
ibus restart
```

USB persistence가 켜져 있으면 한 번 설정한 뒤 유지됩니다.

---

## 5. 문제 해결

### USB에 큰 파일 복사가 안 됩니다

USB 파일시스템이 FAT32이면 파일 하나가 4GB를 넘을 수 없습니다. Ventoy 설치 시 EXFAT을 사용하거나, Ventoy 설치 후 첫 번째 파티션을 EXFAT으로 포맷하세요.

### 부팅했는데 설정이 저장되지 않습니다

확인할 것:

- `cco-persistence.dat`가 USB root에 있는지
- `ventoy\ventoy.json`의 `image` 파일명이 실제 ISO 파일명과 같은지
- `backend`가 `/cco-persistence.dat`인지
- Ventoy 부팅 메뉴에서 persistence가 선택되었는지

### 고해상도 화면에서 배경화면이 기본 이미지로 보입니다

v2.0.6 ISO에는 로그인 후 실제 모니터 이름을 읽어 AICODE-OS 배경화면을 다시 적용하는 스크립트가 포함됩니다. v2.0.5 이하라면 최신 ISO를 사용하거나 `build-mint.sh`로 다시 빌드하세요.

### Claude Code 또는 Codex 버전이 오래됐습니다

이미 배포된 ISO 안의 CLI는 ISO를 빌드한 날짜의 버전입니다. 새 ISO를 만들면 `@anthropic-ai/claude-code@latest`, `@openai/codex@latest`가 빌드 시점 기준으로 설치됩니다.

---

## 6. 직접 빌드

원본 Linux Mint ISO가 필요합니다.

```bash
sudo bash build-mint.sh
```

출력:

```text
aicode-os-v2.0.7.iso
aicode-os-v2.0.7.iso.sha256
```

빌드가 끝나면 ISO를 Release용으로 나누어 업로드할 수 있습니다.

```bash
split -b 1900M aicode-os-v2.0.7.iso aicode-os-v2.0.7.iso.part
sha256sum aicode-os-v2.0.7.iso > aicode-os-v2.0.7.iso.sha256
```

---

[전체 변경 이력](CHANGELOG.md)
