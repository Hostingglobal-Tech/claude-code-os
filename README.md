# AICODE-OS — Claude + Codex LiveUSB

![AICODE-OS](branding/cco-cover.png)

**AI 코더 두 명 (Anthropic Claude Code + OpenAI Codex CLI) 이 동시에 탑재된** 부팅 가능한 LiveUSB ISO. Linux Mint 21.3 XFCE 기반.

DHCP 방식으로 IP가 자동으로 잡힙니다. 유선랜과 무선랜을 지원합니다. 무선은 AP(공유기) 를 선택하는 메뉴를 통해서 접속할수 있습니다.

USB 한 개 꽂고 부팅하면 — `cco` 사용자 자동 로그인 → XFCE 데스크톱 (Wi-Fi GUI, 한글 입력, Firefox 내장) → **xfce4-terminal 한 창에 두 탭 자동** (좌탭: Claude Code, 우탭: OpenAI Codex). OAuth 한 번이면 끝. Wi-Fi 비번 / 작업물 / 설치한 패키지 전부 Ventoy persistence 로 영구 저장.

> "v2.0" 부터 Linux Mint 21.3 XFCE 기반. 이전 Alpine v1.0.x 시리즈는 [`archive/alpine-v1/`](archive/alpine-v1/) 참조.

> 📋 [Full changelog](CHANGELOG.md) · [Install guide](INSTALL.md)

"Languages": [한국어](#한국어) · [English](#english)

---

## 한국어

### 왜 이렇게 만들었나

AI 와 대화 한 번 하려고 — Windows 깔고, 드라이버 잡고, 브라우저 깔고. 또는 Linux 깔고, Node 깔고, `npm install` 하고, 로그인하고. 단계가 너무 많습니다.

AI 가 인터페이스 그 자체인데, 왜 그 앞에 OS 와 설치 과정을 끼워두는가. 그래서 OS 자체를 AI 로 만들었습니다.

부팅 → 30초 → 인증 → AI.

### 박힌 항목 (v2.0.5)

- "base": Linux Mint 21.3 XFCE (Ubuntu 22.04 LTS jammy)
- "Anthropic Claude Code" (npm `@anthropic-ai/claude-code`) — 좌탭 자동 시작
- "OpenAI Codex CLI" (npm `@openai/codex`) — 우탭 자동 시작 (한 창 두 탭)
- "node v20 LTS" + "firefox" 내장 (OAuth 인증용)
- "NetworkManager + nm-applet" — Wi-Fi GUI 트레이
- "ibus + ibus-hangul" — EN+KO 자동 등록 (`Shift+Space` 토글)
- "fonts": Noto CJK KR (시스템 11pt), D2Coding 13pt (터미널)
- "locale": ko_KR.UTF-8 + Asia/Seoul timezone
- "lightdm autologin" = `cco` (sudo NOPASSWD)
- "Mint-Y-Dark-Aqua" 테마 + AICODE-OS wallpaper (Wong palette colorblind-safe)
- "persistence": Ventoy `casper-rw` 매핑 → 모든 변경 영구 저장

### 사용법

#### 1. ISO 다운로드 (권장)
[Releases](https://github.com/Hostingglobal-Tech/claude-code-os/releases) 에서 v2.0.5 의 세 파일 다운로드:
- `aicode-os-v2.0.5.iso.part1` (1.99 GB)
- `aicode-os-v2.0.5.iso.part2` (1.65 GB)
- `aicode-os-v2.0.5.iso.sha256`

ISO 가 GitHub Release 단일 한도 (2 GB) 초과로 두 part 로 분할되어 있습니다. 합치기:

Linux / WSL / macOS:
```bash
cat aicode-os-v2.0.5.iso.part1 aicode-os-v2.0.5.iso.part2 > aicode-os-v2.0.5.iso
sha256sum -c aicode-os-v2.0.5.iso.sha256
```

Windows (cmd):
```cmd
copy /b aicode-os-v2.0.5.iso.part1+aicode-os-v2.0.5.iso.part2 aicode-os-v2.0.5.iso
```

#### 1-1. (선택) 직접 빌드
```bash
mkdir -p ~/aicode-build/branding && cd ~/aicode-build
# Linux Mint 21.3 XFCE 64bit ISO 다운로드 (https://www.linuxmint.com/edition.php?id=302)
git clone https://github.com/Hostingglobal-Tech/claude-code-os repo
cp repo/build-mint.sh .
cp repo/branding/cco-wallpaper.png branding/

# 빌드 (mksquashfs ~30분, 전체 ~35분)
sudo bash build-mint.sh
# → aicode-os-v2.0.5.iso (~3.4 GB)
```

빌드 의존성: `xorriso`, `unsquashfs`, `mksquashfs` (`squashfs-tools`, `xorriso` 패키지)

#### 2. Ventoy USB 준비
[Ventoy](https://www.ventoy.net/) 으로 USB 포맷 (8 GB+ 권장).

#### 3. ISO + persistence dat 복사
```
F:\aicode-os-v2.0.5.iso       (3.4 GB)
F:\cco-persistence.dat        (3.5 GB, ext4 label=casper-rw)
F:\ventoy\ventoy.json
```

`cco-persistence.dat` 준비 — 두 가지 방법 중 선택:

**방법 A (권장): Release 에서 미리 만든 압축본 다운로드**
- [Releases v2.0.5](https://github.com/Hostingglobal-Tech/claude-code-os/releases/tag/v2.0.5) 에서 `cco-persistence.dat.xz` (543 KB) 다운로드
- 압축 풀기:
  - Linux/WSL/macOS: `xz -d cco-persistence.dat.xz` → 3.5 GB `cco-persistence.dat`
  - Windows: 7-Zip 으로 `cco-persistence.dat.xz` 우클릭 → "여기에 압축 풀기"

**방법 B: 직접 생성 (Linux/WSL/macOS — 더 큰 사이즈 원할 때)**
```bash
# 기본 3.5 GB
sudo bash make-persistence.sh

# 또는 8 GB / 16 GB
sudo bash make-persistence.sh 8000
sudo bash make-persistence.sh 16000
```
또는 한 줄:
```bash
sudo dd if=/dev/zero of=cco-persistence.dat bs=1M count=3500
sudo mkfs.ext4 -F -L casper-rw cco-persistence.dat
```

> dat 컨테이너는 **고정 사이즈** (자동 안 늘어남). 안에 작업 데이터 (Wi-Fi 비번, OAuth, 파일) 채워질수록 사용량 ↑, 한도 (3.5 GB) 초과 시 더 큰 dat 새로 만들어 교체.

`ventoy.json`:
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

#### 4. 부팅
대상 PC 에서 USB 꽂고 → BIOS 부팅 메뉴 (F12 / ESC / F2) → USB 선택 → Ventoy → 3초 후 자동 → 30초 후 xfce4-terminal 한 창에 두 탭 (Claude / Codex) 자동.

### Codex 인증
첫 부팅 시 Codex 창에서 `OPENAI_API_KEY` 환경변수 설정 또는 ChatGPT 계정으로 로그인. Persistence 덕분에 한 번만.

### 동작 확인된 하드웨어
- ASUS X515
- Samsung NT900X3A (Sens 900X 시리즈)
- 일반 x86_64 PC (Intel HD/UHD/AMD GPU + Intel iwlwifi)

### 보안 안내
"샌드박스가 아닙니다." `claude --dangerously-skip-permissions` 로 root 권한 + 풀 네트워크 권한입니다. 중요한 머신에는 띄우지 마세요. LiveUSB 는 USB 안에서만 데이터 보존되며 호스트 디스크는 건드리지 않습니다.

비밀번호 / Wi-Fi / OAuth 토큰 / OpenAI API 키는 "persistence dat 안에만" 저장됩니다. USB 분실 = 데이터 노출. 분실 시 원격에서 `cco-persistence.dat` 만 삭제하는 기능이 없습니다. 절대로 분실하지 않도록 관리를 잘해주시기 바랍니다. 오픈소스로 제작 방법을 공개하였으니 커스텀하게 개조가 가능합니다.

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
**Not a sandbox.** `claude --dangerously-skip-permissions` runs as root with full network. Don't run on machines with sensitive data on disk. LiveUSB doesn't touch host disks; all state (Wi-Fi, OAuth, OpenAI API key) lives in `cco-persistence.dat` on the USB. Lose USB = lose secrets. Delete `cco-persistence.dat` to reset.

---

## License
[Apache-2.0](LICENSE)

## Changelog
See [CHANGELOG.md](CHANGELOG.md) (한국어) · [CHANGELOG.en.md](CHANGELOG.en.md) (English)
