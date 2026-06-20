# AICODE-OS — USB로 부팅하는 AI 작업 환경

![AICODE-OS](branding/cco-cover.png)

**USB 하나로 부팅하면 Claude Code와 OpenAI Codex를 바로 사용할 수 있는 Linux Mint XFCE 기반 작업 환경입니다.**

설치 과정 없이 USB로 부팅해 사용할 수 있습니다. 부팅 후에는:
- 와이파이 연결
- 한글 입력 됩니다 (`Shift+Space`, `한/영`, v2.0.6부터 `Caps Lock`)
- 화면 가득 검은 창 하나에 **탭 두 개** — 왼쪽 Claude, 오른쪽 ChatGPT Codex
- 와이파이 비번, 로그인 정보, 작업한 파일 모두 **USB 안에 자동 저장** → 다음에 켜면 그대로

다른 컴퓨터에서도 같은 USB로 부팅하면 익숙한 작업 환경을 그대로 사용할 수 있습니다. LiveUSB 방식이므로 호스트 PC의 디스크에는 기본적으로 기록하지 않습니다.

> 🙏 **커뮤니티 의견 반영**
> - **v2.0.5** — 스레드 사용자 **@imusiro** 님의 *"저장 파일은 어디서 받나요?"* 의견 반영. 이제 직접 만들지 않고 Release 파일을 다운로드해 사용할 수 있습니다.
> - **v2.0.6 (최신)** — **@akra.dev** 님의 *"맥북은 Caps Lock 이 기본 한/영 변환인데 맥 환경은 안 좋아하시나봄"* 의견을 반영해 **Caps Lock 키 = 한/영 토글**을 기본 설정에 포함합니다. (v2.0.5에서도 한 줄 명령으로 활성화 가능 → [QnA Q · 맥북 Caps Lock](#4-한글--와이파이) 참조)
> - **v2.0.6 추가 수정** — 고해상도/외부 모니터 장비에서 XFCE 모니터명이 달라져도 AICODE-OS wallpaper가 자동 적용되도록 로그인 후 wallpaper 복구 스크립트를 추가했습니다.
> - **CLI 버전 안내** — 이미 배포된 ISO 안의 Claude Code/Codex는 ISO를 만들 당시의 버전입니다. `build-mint.sh`로 새 ISO를 빌드하면 빌드 시점의 최신 npm 패키지를 설치합니다.

> 📋 [전체 변경 내역](CHANGELOG.md) · [English](#english)

"Languages": [한국어](#한국어) · [English](#english)

---

## 한국어

### 왜 만들었나

AI 와 한 번 대화하려고:
- Windows 깔고 → 드라이버 잡고 → 브라우저 깔고 → 검색
- 또는 Linux 깔고 → Node 깔고 → 명령어 입력 → 로그인

너무 복잡합니다. 컴퓨터 좀 한다는 사람도 헤매는데, 모르는 사람한테는 거의 불가능.

AI 가 결국 우리가 쓰는 도구인데, 왜 그 앞에 복잡한 단계를 끼워둘까. 그래서 **OS 자체를 AI 로** 만들었습니다.

USB로 부팅 → 약 1분 → 로그인 한 번 → AI 작업 환경.

### USB 안에 뭐가 들어있나

- **AI 두 명** — Claude (Anthropic) + Codex (OpenAI)
- **인터넷 브라우저** — Firefox (로그인용)
- **한글 입력** — `Shift+Space`, `한/영`, v2.0.6부터 `Caps Lock` 키로 한/영 토글
- **와이파이** — 우측 하단 메뉴 클릭, AP 선택, 비번 입력 (한 번이면 영구)
- **자동 저장** — 와이파이 비번 / 로그인 / 작업 파일 모두 USB 에 영구 저장
- **언어/시간** — 한국어 (ko_KR), 한국 시간 (Asia/Seoul)
- **데스크탑 환경** — Linux Mint (검증된 안정 OS, Ubuntu 기반)
- **배경화면 자동 보정** — 고해상도/외부 모니터에서도 실제 연결된 화면 이름을 읽어 AICODE-OS wallpaper를 다시 적용

### 왜 Linux Mint XFCE인가

이 프로젝트는 화려한 데스크톱보다 **부팅 안정성, 드라이버 호환성, 낮은 리소스 사용량, 쉬운 복구**가 더 중요합니다. Linux Mint XFCE는 Ubuntu LTS 기반이라 패키지 호환성이 좋고, XFCE는 가벼우면서도 Wi-Fi, 브라우저, 터미널, 한글 입력을 갖춘 실사용 환경을 만들기 좋습니다. LiveUSB와 persistence 조합도 안정적으로 운영할 수 있어 이 목적에 잘 맞습니다.

> 다른 PC 에서도 같은 USB 꽂으면 모든 설정 그대로. 호스트 PC 디스크는 안 건드립니다.

### 가장 쉬운 시작: Windows에서 더블클릭

Windows 사용자는 명령어를 몰라도 됩니다.

1. 이 저장소를 ZIP으로 다운로드합니다.
2. 압축을 풉니다.
3. `AICODE-OS-USB-만들기.cmd`를 더블클릭합니다.
4. 화면에 나오는 USB 목록에서 USB 메모리만 선택합니다.

내부적으로는 `install-cco-on-ventoy.ps1`이 실행되어 Ventoy 설치, ISO 다운로드, ISO 병합, persistence 적용, `ventoy.json` 생성까지 한 번에 처리합니다.

가장 중요한 안전장치:
- **USB로 표시되는 디스크만** Ventoy 설치 대상으로 허용합니다.
- **Windows 부팅 디스크, 시스템 디스크, C:가 포함된 디스크는 무조건 차단**합니다.
- 포맷 직전에는 `ERASE USB 디스크번호`를 직접 입력해야 합니다.
- 이미 Ventoy가 설치된 USB에 파일만 넣을 때는 `-SkipVentoyInstall -Drive F:`처럼 실행할 수 있습니다.

명령어를 직접 입력하고 싶은 경우에는 관리자 PowerShell에서:
```powershell
cd C:\DEVEL\claude-code-os
powershell -ExecutionPolicy Bypass -File .\install-cco-on-ventoy.ps1
```

이미 Ventoy가 설치된 USB가 `F:`라면 포맷 없이 파일만 배치:
```powershell
powershell -ExecutionPolicy Bypass -File .\install-cco-on-ventoy.ps1 -Drive F: -SkipVentoyInstall
```

### 수동 시작하기 (5분)

#### 1단계 · USB 8 GB 이상 준비

[Ventoy](https://www.ventoy.net/) 라는 무료 프로그램으로 USB를 부팅 가능하게 만듭니다. Ventoy는 한 번 설치해 두면 ISO 파일을 USB에 복사해 부팅할 수 있게 해주는 도구입니다.

#### 2단계 · 두 파일 다운로드

[**Releases v2.0.6**](https://github.com/Hostingglobal-Tech/claude-code-os/releases/tag/v2.0.6) 에서:

| 파일 | 크기 | 용도 |
|---|---|---|
| `aicode-os-v2.0.6.iso.part1` | 약 1.9 GB | OS 본체 (조각 1) |
| `aicode-os-v2.0.6.iso.part2` | 약 1.8 GB | OS 본체 (조각 2) |
| `cco-persistence.dat.xz` | 543 KB | 설정 저장소 (압축본) |

> ISO 본체가 너무 커서 두 조각으로 나눠 올렸습니다. 합쳐서 사용.

#### 3단계 · ISO 합치기

다운로드 받은 폴더에서 한 줄:

**Windows** — `cmd` 창에서:
```cmd
copy /b aicode-os-v2.0.6.iso.part1+aicode-os-v2.0.6.iso.part2 aicode-os-v2.0.6.iso
```

**Mac / Linux** — 터미널에서:
```bash
cat aicode-os-v2.0.6.iso.part1 aicode-os-v2.0.6.iso.part2 > aicode-os-v2.0.6.iso
```

→ 약 3.6 GB `aicode-os-v2.0.6.iso` 파일 하나가 만들어집니다.

#### 4단계 · 설정 저장소 (`cco-persistence.dat.xz`) 압축 풀기

이 파일이 있어야 **와이파이 비번 / 로그인 / 작업 파일이 USB 에 자동 저장** 됩니다.

**Windows** — 7-Zip 우클릭 → "여기에 압축 풀기" → 3.5 GB `cco-persistence.dat` 생성

**Mac / Linux** — 터미널:
```bash
xz -d cco-persistence.dat.xz
```

#### 5단계 · USB 에 두 파일 + 설정 한 줄 복사

USB 의 root 폴더 (예: `F:` 드라이브 안 최상위) 에 그대로 복사:

| 위치 | 파일 |
|---|---|
| `F:\aicode-os-v2.0.6.iso` | (약 3.6 GB, 합친 ISO) |
| `F:\cco-persistence.dat` | (3.5 GB, 풀어놓은 설정 저장소) |
| `F:\ventoy\ventoy.json` | (아래 내용으로 새로 만들기) |

`ventoy.json` 내용 (텍스트 편집기로 만들기):
```json
{
  "control": [
    { "VTOY_DEFAULT_MENU_MODE": "0" },
    { "VTOY_MENU_TIMEOUT": "3" },
    { "VTOY_DEFAULT_IMAGE": "/aicode-os-v2.0.6.iso" }
  ],
  "persistence": [
    {
      "image": "/aicode-os-v2.0.6.iso",
      "backend": "/cco-persistence.dat",
      "autosel": 1
    }
  ]
}
```

#### 6단계 · 부팅

USB 꽂고 → 컴퓨터 켤 때 **F12 / ESC / F2** 누름 → 부팅 메뉴에서 USB 선택 → 약 1분 후 AI 두 탭 자동 시작.

> 사용 후 와이파이 비번 / 로그인 정보 / 작업 파일은 자동으로 USB 에 저장됩니다. 다음에 켜면 그대로.

### 첫 사용 시 로그인

부팅 후 두 탭이 자동으로 뜹니다. 각각 한 번만 로그인:

| 탭 | 인증 방법 |
|---|---|
| **Claude (왼쪽)** | 화면에 뜨는 URL → Firefox 새 탭에 붙여넣기 → claude.ai 로그인 |
| **Codex (오른쪽)** | 화면 안내 따라 ChatGPT 로 로그인 또는 OpenAI API 키 입력 |

> 한 번 로그인하면 USB 에 저장되어 다음 부팅부터 자동.

### 어떤 컴퓨터에서 되나

- **모든 일반 PC / 노트북** (Intel / AMD CPU)
- 검증된 모델: ASUS X515, Samsung NT900X3A 같은 오래된 노트북
- 게임용 그래픽 카드, 와이파이, 블루투스 거의 자동 인식

### 보안 안내

#### 호스트 PC 디스크 = 안전
LiveUSB 는 **USB 안에서만 작업**합니다. 호스트 PC 의 디스크 (Windows / 기존 Linux 등) 는 건드리지 않습니다. USB를 제거하면 호스트 PC에는 작업 환경이 남지 않습니다.

#### AI 도구 권한 = 신중하게 사용
이 환경은 완전한 샌드박스가 아닙니다. `claude --dangerously-skip-permissions`와 `codex`는 USB 안의 Linux 환경에서 높은 권한과 네트워크 접근을 사용할 수 있습니다. 출처를 모르는 명령이나 외부 코드는 내용을 확인한 뒤 실행하세요. 기본 위험 범위는 호스트 PC 디스크가 아니라 USB 안의 작업물과 외부로 전송되는 네트워크 데이터입니다.

#### USB 분실 = 토큰 노출 주의
비밀번호 / Wi-Fi / Claude OAuth / OpenAI API 키는 USB 의 `cco-persistence.dat` 안에만 저장됩니다.
- USB 분실 시 원격 삭제 기능 없음 → 잘 관리하세요.
- 분실 후 토큰 무효화: claude.ai / OpenAI 콘솔에서 직접 revoke.
- 오픈소스 (Apache-2.0) 라 직접 빌드 + 커스텀 개조 가능.

---

## 자주 묻는 질문

[다운로드 · 설치](#1-다운로드--설치) | [설정 저장소](#2-설정-저장소) | [로그인](#3-로그인) | [한글 · 와이파이](#4-한글--와이파이) | [호환 · 부팅](#5-호환--부팅) | [사용](#6-사용) | [고급](#7-고급)

---

### 1. 다운로드 · 설치

**Q · 설정 저장소 (`cco-persistence.dat`) 어디서 받나요?**

가장 쉬운 방법 = [Release](https://github.com/Hostingglobal-Tech/claude-code-os/releases/latest) 에서 `cco-persistence.dat.xz` (543 KB) 다운로드 → 7-Zip 으로 풀기 → 3.5 GB 파일 하나.

| 방법 | 어떻게 | 어디서 |
|---|---|---|
| **다운로드 (권장)** | 543 KB 압축본 받아 풀기 | Release |
| Mac / Linux 직접 만들기 | `sudo bash make-persistence.sh` | repo |
| Windows 직접 만들기 | `powershell -File Make-Persistence.ps1` (WSL 필요) | repo |

**Q · ISO 두 조각 어떻게 합치나요?**

다운로드 받은 폴더에서 한 줄:
```bash
# Windows (cmd 창)
copy /b aicode-os-v2.0.6.iso.part1+aicode-os-v2.0.6.iso.part2 aicode-os-v2.0.6.iso

# Mac / Linux (터미널)
cat aicode-os-v2.0.6.iso.part1 aicode-os-v2.0.6.iso.part2 > aicode-os-v2.0.6.iso
```

> 합치고 나면 part1, part2 는 삭제해도 됩니다.

---

### 2. 설정 저장소

**Q · 저장소 용량이 자동으로 늘어나나요?**

**아닙니다.** 설정 저장소는 처음 만들 때 정한 크기 (기본 3.5 GB) 그대로 고정. 안에 데이터가 채워질수록 사용량만 늘어나고, 한도에 도달하면 더 큰 저장소를 새로 만들어 교체.

**Q · 8 GB 저장소 만들었는데 USB 에 복사가 안 돼요.**

USB 가 옛날 방식 (`FAT32`) 으로 포맷되어 있어서. FAT32 는 **파일 하나 최대 4 GB** 한도.

| 해결 | 어떻게 |
|---|---|
| 저장소 크기 줄이기 | 3.5 GB 그대로 사용 (가장 간단) |
| USB 다시 포맷 (`exFAT`) | Ventoy 의 Configuration 에서 Partition Style = exFAT 후 재설치 (USB 데이터 다 지워짐, 백업 필수) |

> Ventoy 최신 버전 (1.0.96+) 은 기본이 exFAT 이라 8 GB 이상 파일도 사용할 수 있습니다.

**Q · 다른 컴퓨터에 같은 USB 꽂아도 설정 그대로 있나요?**

**네!** 와이파이 비번, 로그인 정보, 작업한 파일, 설치한 프로그램 모두 USB 안에 저장. 회의실 PC, 카페 노트북, 호텔 데스크탑 어디든 같은 USB 꽂으면 **내 환경 그대로**.

---

### 3. 로그인

**Q · Claude 어떻게 로그인?**

왼쪽 탭이 자동으로 로그인 URL 을 보여줍니다 → 그걸 Firefox 새 탭에 붙여넣기 → `claude.ai` 로 로그인합니다. 로그인 정보는 USB 에 저장되어 다음 부팅 때 다시 사용할 수 있습니다.

**Q · Codex (ChatGPT) 어떻게 로그인?**

오른쪽 탭에서 화면 안내를 따라 ChatGPT 로 로그인. 또는 OpenAI API 키가 있으면:
```bash
export OPENAI_API_KEY="sk-..."
```

> 두 방법 모두 USB 에 저장되어 다음 부팅 때 다시 사용할 수 있습니다.

---

### 4. 한글 · 와이파이

**Q · 한글 입력이 안 돼요.**

키보드의 `Shift+Space`, `한/영`, v2.0.6부터는 `Caps Lock` 키 누르기.

입력기 아이콘이 안 보이면 검은 창에서:
```bash
ibus restart
```

**Q · 맥북 사용자인데 `Caps Lock` 으로 한/영 전환은 안 되나요?**

> 🙏 **@akra.dev** 님 의견 반영 — **v2.0.6** 에서 **Caps Lock = 한/영** 기본 설정을 포함합니다.

지금 v2.0.5 도 검은 창에 한 줄 실행하면 즉시 활성화 (USB 에 저장되어 영구):
```bash
dconf write /desktop/ibus/general/hotkey/triggers "['<Shift>space', 'Hangul', 'Caps_Lock', '<Super>space']"
ibus restart
```

이후 `Shift+Space`, `한/영`, `Caps Lock`, `Super+Space` 모두 토글 가능.

**Q · 와이파이 비번은 어떻게?**

화면 **우측 하단** 의 와이파이 아이콘 (바 모양) 클릭 → AP 선택 → 비번 입력. 한 번이면 영구 저장.

---

### 5. 호환 · 부팅

**Q · 컴퓨터에 영향 없나요?**

기본적으로 없습니다. USB 안에서만 작동하고, 컴퓨터 본체의 디스크는 건드리지 않습니다. USB를 제거하면 그 컴퓨터에는 작업 환경이 남지 않습니다.

**Q · 어떤 컴퓨터에서 되나요?**

| 사양 | 비고 |
|---|---|
| Intel / AMD CPU 컴퓨터 | 거의 모두 |
| ASUS X515 | 정상 동작 확인 |
| Samsung NT900X3A | 오래된 노트북에서도 동작 확인 |
| 와이파이 / 블루투스 | 자동 인식 |

**Q · 부팅이 안 돼요.**

| 확인 | 어떻게 |
|---|---|
| USB 부팅 메뉴 안 떠요 | 컴퓨터 켤 때 `F12` 또는 `ESC` / `F2` 누름 (제조사마다 다름) |
| Linux 가 안 떠요 | BIOS 에서 **Secure Boot** 끄기 |
| 화면이 깨지거나 검정 | UEFI 와 Legacy 둘 다 시도 |

---

### 6. 사용

**Q · 두 탭 (Claude / Codex) 전환은?**

위쪽 탭 클릭 또는 키보드:
- `Ctrl + Page Up` / `Ctrl + Page Down`
- `Ctrl + Tab`

**Q · 한 AI 가 막히면 다른 AI 에 같은 거 시켜도 되나요?**

네. Claude가 잘 처리하지 못하는 작업은 옆 탭의 Codex에 다시 요청할 수 있습니다. 두 도구의 강점이 다르기 때문에 같은 문제를 다른 관점에서 확인하는 용도로도 사용할 수 있습니다.

**Q · 어떻게 종료?**

작업한 데이터는 자동으로 USB 에 저장됩니다. 안전 종료:

```bash
sync
```

또는 화면 메뉴에서 **종료**를 클릭하세요. 가능하면 종료 후 USB를 제거하는 것을 권장합니다.

---

### 7. 고급

**Q · ISO 직접 빌드는?**

```bash
sudo bash build-mint.sh   # ~35분
```

자세한 안내는 [직접 빌드](#1-1-선택-직접-빌드) 섹션.

**Q · 새 버전 (v2.0.6 등) 나오면 업데이트는?**

1. Release 에서 새 ISO 두 조각 받아 합치기
2. USB 의 옛 ISO 지우고 새 ISO 복사
3. `ventoy.json` 의 ISO 파일명만 새 이름으로 변경

**Q · 기존 v2.0.5 ISO 안의 Codex가 최신 버전인가요?**

아닙니다. ISO 안의 Claude Code와 Codex는 **그 ISO를 빌드한 날짜의 npm 패키지 버전**입니다. 예를 들어 한 달 전에 만든 ISO라면 현재 최신 Codex가 자동으로 들어있을 수 없습니다. 최신 버전을 포함하려면 `build-mint.sh`로 ISO를 다시 빌드해야 합니다. v2.0.6부터는 빌드 시점의 최신 `@anthropic-ai/claude-code`와 `@openai/codex`를 설치하도록 명시했습니다.

> **`cco-persistence.dat` 은 그대로 두기** — 와이파이 비번 / 로그인 다 유지.

---

## English

### Why

Talking to AI takes too many steps — install OS, drivers, browser, Node, npm, login. AI is the interface; why bolt an OS install ritual in front of it? So we made the OS itself AI.

Boot → ~1 min → auth → AI.

### What's inside (v2.0.6)

- base: Linux Mint 21.3 XFCE (Ubuntu 22.04 LTS jammy)
- **Anthropic Claude Code** (npm `@anthropic-ai/claude-code`) — left tab
- **OpenAI Codex CLI** (npm `@openai/codex`) — right tab (single xfce4-terminal, two tabs)
- node v20 LTS + Firefox + nm-applet (Wi-Fi GUI)
- ibus + ibus-hangul, EN+KO preloaded (`Shift+Space` toggle)
- Korean locale (ko_KR.UTF-8) + Asia/Seoul tz
- lightdm autologin (`cco` user, NOPASSWD sudo)
- Mint-Y-Dark-Aqua theme + custom AICODE-OS wallpaper
- Ventoy `casper-rw` persistence

### Build

```bash
mkdir -p ~/aicode-build/branding && cd ~/aicode-build
# place linuxmint-21.3-xfce-64bit.iso and branding/cco-wallpaper.png here
git clone https://github.com/Hostingglobal-Tech/claude-code-os repo
cp repo/build-mint.sh .
cp repo/branding/cco-wallpaper.png branding/

sudo bash build-mint.sh   # ~35 minutes
# → aicode-os-v2.0.6.iso (~3.6 GB)
```

### Use

Flash USB with [Ventoy](https://www.ventoy.net/), drop the ISO + a 3.5 GB ext4 file labeled `casper-rw` named `cco-persistence.dat`, edit `ventoy/ventoy.json` for default boot + persistence (see Korean section above), boot from USB. One xfce4-terminal with two tabs (Claude + Codex) auto-launches.

### Tested hardware
ASUS X515 · Samsung NT900X3A · generic x86_64 PCs (Intel HD/UHD/AMD GPU, Intel iwlwifi)

### Security

**Host disk: safe.** LiveUSB only writes inside the USB. Host PC's disk (Windows / existing Linux) is never touched. Pull the USB and there's zero trace.

**AI runs as root: be cautious.** Not a sandbox. `claude --dangerously-skip-permissions` + `codex` execute with **root + full network**. Whatever the AI runs, runs. Don't blindly execute unknown commands or external code. (The risk is to your USB workspace and outbound network — not the host disk.)

**Lose the USB = lose secrets.** Wi-Fi passwords, Claude OAuth, OpenAI API key all live in `cco-persistence.dat` on the USB. No remote wipe. Manage it carefully. If lost, revoke tokens via claude.ai / OpenAI console. Apache-2.0 — fork and customize.

---

## License
[Apache-2.0](LICENSE)

## Changelog
See [CHANGELOG.md](CHANGELOG.md) (한국어) · [CHANGELOG.en.md](CHANGELOG.en.md) (English)
