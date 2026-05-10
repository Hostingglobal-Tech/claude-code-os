# AICODE-OS — USB 하나로 끝나는 AI 컴퓨터

![AICODE-OS](branding/cco-cover.png)

**USB 하나만 꽂으면 어느 컴퓨터든 30초 만에 AI (Claude + ChatGPT 의 Codex) 두 명이 같이 뜨는 운영체제.**

설치 필요 없습니다. 부팅하는 순간:
- 와이파이 자동으로 잡힘
- 한글 입력 됩니다 (`Shift+Space` 또는 `한/영` 키)
- 화면 가득 검은 창 하나에 **탭 두 개** — 왼쪽 Claude, 오른쪽 ChatGPT Codex
- 와이파이 비번, 로그인 정보, 작업한 파일 모두 **USB 안에 자동 저장** → 다음에 켜면 그대로

다른 사람 컴퓨터, 카페 노트북, 회의실 PC 어디든 같은 USB 꽂으면 **내 환경 그대로**. 빼고 나오면 그 컴퓨터에 흔적 0.

> 🙏 **v2.0.5 개선** — 스레드 사용자 **@imusiro** 님의 "저장 파일은 어디서 받나요?" 의견을 받아 더 좋게 개선했습니다. 이제 **다운로드만 받으면 끝** (직접 만들 필요 X).

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

USB 꽂고 → 30초 → 로그인 한 번 → AI.

### USB 안에 뭐가 들어있나

- **AI 두 명** — Claude (Anthropic) + Codex (OpenAI)
- **인터넷 브라우저** — Firefox (로그인용)
- **한글 입력** — `Shift+Space` 또는 `한/영` 키로 한/영 토글
- **와이파이** — 우측 하단 메뉴 클릭, AP 선택, 비번 입력 (한 번이면 영구)
- **자동 저장** — 와이파이 비번 / 로그인 / 작업 파일 모두 USB 에 영구 저장
- **언어/시간** — 한국어 (ko_KR), 한국 시간 (Asia/Seoul)
- **데스크탑 환경** — Linux Mint (검증된 안정 OS, Ubuntu 기반)

> 다른 PC 에서도 같은 USB 꽂으면 모든 설정 그대로. 호스트 PC 디스크는 안 건드립니다.

### 시작하기 (5분)

#### 1단계 · USB 8 GB 이상 준비

[Ventoy](https://www.ventoy.net/) 라는 작은 무료 프로그램으로 USB 한 번 굽기. (Ventoy 는 USB 를 부팅 가능하게 만들어주는 도구. 한 번만 굽으면 끝.)

#### 2단계 · 두 파일 다운로드

[**Releases v2.0.5**](https://github.com/Hostingglobal-Tech/claude-code-os/releases/tag/v2.0.5) 에서:

| 파일 | 크기 | 용도 |
|---|---|---|
| `aicode-os-v2.0.5.iso.part1` | 1.99 GB | OS 본체 (조각 1) |
| `aicode-os-v2.0.5.iso.part2` | 1.65 GB | OS 본체 (조각 2) |
| `cco-persistence.dat.xz` | 543 KB | 설정 저장소 (압축본) |

> ISO 본체가 너무 커서 두 조각으로 나눠 올렸습니다. 합쳐서 사용.

#### 3단계 · ISO 합치기

다운로드 받은 폴더에서 한 줄:

**Windows** — `cmd` 창에서:
```cmd
copy /b aicode-os-v2.0.5.iso.part1+aicode-os-v2.0.5.iso.part2 aicode-os-v2.0.5.iso
```

**Mac / Linux** — 터미널에서:
```bash
cat aicode-os-v2.0.5.iso.part1 aicode-os-v2.0.5.iso.part2 > aicode-os-v2.0.5.iso
```

→ 3.4 GB `aicode-os-v2.0.5.iso` 파일 하나가 만들어집니다.

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
| `F:\aicode-os-v2.0.5.iso` | (3.4 GB, 합친 ISO) |
| `F:\cco-persistence.dat` | (3.5 GB, 풀어놓은 설정 저장소) |
| `F:\ventoy\ventoy.json` | (아래 내용으로 새로 만들기) |

`ventoy.json` 내용 (텍스트 편집기로 만들기):
```json
{
  "control": [
    { "VTOY_DEFAULT_MENU_MODE": "0" },
    { "VTOY_MENU_TIMEOUT": "3" },
    { "VTOY_DEFAULT_IMAGE": "/aicode-os-v2.0.5.iso" }
  ],
  "persistence": [
    {
      "image": "/aicode-os-v2.0.5.iso",
      "backend": "/cco-persistence.dat",
      "autosel": 1
    }
  ]
}
```

#### 6단계 · 부팅

USB 꽂고 → 컴퓨터 켤 때 **F12 / ESC / F2** 누름 → 부팅 메뉴에서 USB 선택 → 30초 후 AI 두 탭 자동 시작.

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
- 검증된 모델: ASUS X515, Samsung NT900X3A (13년 묵은 노트북도 OK)
- 게임용 그래픽 카드, 와이파이, 블루투스 거의 자동 인식

### 보안 안내

#### 호스트 PC 디스크 = 안전
LiveUSB 는 **USB 안에서만 작업**합니다. 호스트 PC 의 디스크 (Windows / 기존 Linux 등) 는 건드리지 않습니다. USB 빼고 나오면 흔적 0.

#### AI 가 root 권한 = 신중
샌드박스가 아닙니다. `claude --dangerously-skip-permissions` + `codex` 가 **root 권한 + 풀 네트워크** 로 실행됩니다. AI 가 시키는 명령은 그대로 실행되니, 모르는 명령이나 외부 코드를 무분별하게 실행하지 마세요. (위험은 호스트 디스크가 아니라 USB 안의 작업물 / 네트워크로 나가는 데이터에 있음.)

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

가장 쉬운 방법 = [Release](https://github.com/Hostingglobal-Tech/claude-code-os/releases/tag/v2.0.5) 에서 `cco-persistence.dat.xz` (543 KB) 다운로드 → 7-Zip 으로 풀기 → 3.5 GB 파일 하나.

| 방법 | 어떻게 | 어디서 |
|---|---|---|
| **다운로드 (권장)** | 543 KB 압축본 받아 풀기 | Release |
| Mac / Linux 직접 만들기 | `sudo bash make-persistence.sh` | repo |
| Windows 직접 만들기 | `powershell -File Make-Persistence.ps1` (WSL 필요) | repo |

**Q · ISO 두 조각 어떻게 합치나요?**

다운로드 받은 폴더에서 한 줄:
```bash
# Windows (cmd 창)
copy /b aicode-os-v2.0.5.iso.part1+aicode-os-v2.0.5.iso.part2 aicode-os-v2.0.5.iso

# Mac / Linux (터미널)
cat aicode-os-v2.0.5.iso.part1 aicode-os-v2.0.5.iso.part2 > aicode-os-v2.0.5.iso
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

> Ventoy 최신 버전 (1.0.96+) 은 기본이 exFAT 이라 8 GB 이상 OK.

**Q · 다른 컴퓨터에 같은 USB 꽂아도 설정 그대로 있나요?**

**네!** 와이파이 비번, 로그인 정보, 작업한 파일, 설치한 프로그램 모두 USB 안에 저장. 회의실 PC, 카페 노트북, 호텔 데스크탑 어디든 같은 USB 꽂으면 **내 환경 그대로**.

---

### 3. 로그인

**Q · Claude 어떻게 로그인?**

왼쪽 탭이 자동으로 로그인 URL 을 보여줍니다 → 그걸 Firefox 새 탭에 붙여넣기 → `claude.ai` 로 로그인. **한 번이면 끝** (USB 에 저장되어 다음부터 자동).

**Q · Codex (ChatGPT) 어떻게 로그인?**

오른쪽 탭에서 화면 안내를 따라 ChatGPT 로 로그인. 또는 OpenAI API 키가 있으면:
```bash
export OPENAI_API_KEY="sk-..."
```

> 두 방법 다 한 번이면 끝. USB 에 저장.

---

### 4. 한글 · 와이파이

**Q · 한글 입력이 안 돼요.**

키보드의 `Shift+Space` 또는 `한/영` 키 누르기.

입력기 아이콘이 안 보이면 검은 창에서:
```bash
ibus restart
```

**Q · 맥북 사용자인데 `Caps Lock` 으로 한/영 전환은 안 되나요?**

지금 v2.0.5 는 `Shift+Space` 만 됩니다. **다음 버전 v2.0.6** 에서 `Caps Lock` 도 추가 예정.

당장 쓰고 싶으면 검은 창에 한 줄 (한 번만 실행하면 USB 에 저장되어 영구):
```bash
dconf write /desktop/ibus/general/hotkey/triggers "['<Shift>space', 'Hangul', 'Caps_Lock']"
ibus restart
```

**Q · 와이파이 비번은 어떻게?**

화면 **우측 하단** 의 와이파이 아이콘 (바 모양) 클릭 → AP 선택 → 비번 입력. 한 번이면 영구 저장.

---

### 5. 호환 · 부팅

**Q · 컴퓨터에 영향 없나요?**

**없습니다.** USB 안에서만 작동하고, 컴퓨터 본체의 디스크는 안 건드립니다. USB 빼고 나오면 그 컴퓨터엔 흔적 0.

**Q · 어떤 컴퓨터에서 되나요?**

| 사양 | 비고 |
|---|---|
| Intel / AMD CPU 컴퓨터 | 거의 모두 |
| ASUS X515 | 신형 동작 OK |
| Samsung NT900X3A | 13년 묵은 노트북도 OK |
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

**네!** 그게 두 명 박은 이유. Claude 가 막히면 옆 탭 Codex 에 시키기. 잘하는 분야가 다름.

**Q · 어떻게 종료?**

작업한 데이터는 자동으로 USB 에 저장됩니다. 안전 종료:

```bash
sync
```

또는 화면 메뉴에서 **종료** 클릭. 그냥 USB 뽑아도 대부분 OK.

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

> **`cco-persistence.dat` 은 그대로 두기** — 와이파이 비번 / 로그인 다 유지.

---

## English

### Why

Talking to AI takes too many steps — install OS, drivers, browser, Node, npm, login. AI is the interface; why bolt an OS install ritual in front of it? So we made the OS itself AI.

Boot → 30 sec → auth → AI.

### What's inside (v2.0.5)

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
# → aicode-os-v2.0.5.iso (~3.4 GB)
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
