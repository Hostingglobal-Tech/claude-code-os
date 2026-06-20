# CHANGELOG

**한국어** · [English](CHANGELOG.en.md)

---

## v2.0.6 (2026-06-21) — 최신 CLI 빌드 + 고해상도 wallpaper + macOS 사용자 친화

### 추가 및 개선
- **빌드 시점 최신 CLI 설치** — `@anthropic-ai/claude-code@latest`, `@openai/codex@latest`를 설치하도록 명시
- **기존 ISO 버전 오해 방지** — 이미 배포된 ISO의 CLI는 ISO 생성 당시 버전이며, 최신 CLI가 필요하면 ISO를 다시 빌드해야 함을 README에 명시
- **Caps Lock = 한/영 토글** 기본 설정 추가 — **@akra.dev 님 의견 반영** (*"맥북은 Caps Lock 이 기본 한/영 변환"*)
- ibus hotkey trigger 에 `Caps_Lock` 추가 (`Shift+Space` + `Hangul` + `Caps_Lock` + `Super+Space`)
- **고해상도/외부 모니터 wallpaper 복구** — 실제 연결된 모니터 이름을 감지해 XFCE wallpaper를 로그인 후 다시 적용
- **자동시작 동작 정정** — README 설명과 맞게 Claude Code와 OpenAI Codex를 한 xfce4-terminal 창의 두 탭으로 실행
- **CLI 종료 후 복구성 개선** — Claude/Codex가 종료되어도 탭이 바로 닫히지 않고 shell로 돌아오도록 처리
- **Ventoy 설치 스크립트 정정** — 옛 Alpine ISO 파일명을 사용하던 문제를 수정하고, 현재 Release의 `aicode-os-*.iso.part1/part2`와 `cco-persistence.dat.xz` 구조를 처리하도록 변경
- **셸 스크립트 검수** — Linux/macOS 실행을 방해하던 CRLF 줄끝 문제를 정리하고 `bash -n`, `shellcheck` 통과 확인

### 검증 결과
- 빌드 산출물: `aicode-os-v2.0.6.iso` (약 3.6 GB)
- Claude Code: `2.1.185`
- OpenAI Codex CLI: `0.141.0`
- SHA256: `792287b3eaf313bc9dbee0e6a99f3e6955b4ce2ba2dc733b20fe7fab5e7d1466`

→ 임시 우회 (v2.0.5 사용 중): 터미널에서
```bash
dconf write /desktop/ibus/general/hotkey/triggers "['<Shift>space', 'Hangul', 'Caps_Lock']"
ibus restart
```
persistence 덕분에 한 번만.

---

## v2.0.5 (2026-05-09) — 한 창 두 탭 + persistence 자동 (커뮤니티 의견 반영)

### 추가 (커뮤니티 피드백 반영)
- **`cco-persistence.dat.xz`** Release upload (543 KB 압축본, 풀면 3.5 GB ext4) — **@imusiro 님의 "dat 어디서 받나" 의견** 반영
- **`make-persistence.sh`** 자동 생성 스크립트 — Linux/WSL/macOS 에서 한 줄 실행으로 dat 만들기 (사이즈 선택 가능)
- README 에 **QnA 16개** 섹션 추가 (dat / 인증 / Wi-Fi / 부팅 / 호환 / 종료 등)

### 수정 (v2.0.4 의 회귀 fix)
- **두 별도 xfce4-terminal 창 → 한 창 두 탭**
  - v2.0.4 의 `--geometry=+1000+450` 좌표가 1366×768 (Samsung NT900X3A 등) 화면 밖이라 Codex 창이 안 보였음
  - v2.0.5 = `xfce4-terminal --maximize --tab` (한 창에 좌탭 Claude / 우탭 Codex) — 다양한 화면 크기에서 정상 표시
- **graceful 종료** — claude / codex 종료 시 `exec bash` (창 살아있고 재시작 가능)
- **Codex 첫 실행 안내** — `OPENAI_API_KEY` / `~/.codex/auth.json` 부재 시 setup 가이드 자동 출력
- **첫 부팅 시 stale 정리** — `aicode-startup-dual` 이 옛 v2.0.0~v2.0.4 의 stale `~/.config/autostart/*.desktop` 자동 rm

### 빌드 인프라 fix
- **chroot bind mount 잔존 = mksquashfs deadlock 원인** 발견 — 매 빌드 끝에 `umount -f -l` + verify 추가
- **direct-patch 빌드 방식** — Mint apt mirror 404 회피 위해 v2.0.4 sqfs base + file 패치만 + 새 mksquashfs (chroot apt 단계 0)

### 추가 데스크톱 아이콘
- `AICODE-OS.desktop` (통합 — 두 탭 wrapper)
- `AICODE-Claude.desktop` (Claude 단독)
- `AICODE-Codex.desktop` (Codex 단독)

### Asset
- `aicode-os-v2.0.5.iso.part1` (1.99 GB)
- `aicode-os-v2.0.5.iso.part2` (1.65 GB)
- `aicode-os-v2.0.5.iso.sha256` (`0dfba30e377dc42db3e9dfb830462e0134ebc12de7eec2efb3164f6fc4d92a0a`)

---

## v2.0.4 (2026-05-08) — OpenAI Codex CLI 통합 + AICODE-OS 브랜드 전환

### 추가
- **OpenAI Codex CLI** (`npm @openai/codex`) chroot 안 install — Anthropic Claude Code 와 함께 두 AI 코더 탑재
- **부팅 시 두 창 자동 시작**:
  - 좌측: `xfce4-terminal` geometry 120×36+50+80 → `aicode-startup-claude` → claude
  - 우측: `xfce4-terminal` geometry 100×30+1000+450 → `aicode-startup-codex` → codex (2초 지연 시작)
- **데스크톱 아이콘 두 개**: `AICODE-Claude.desktop` + `AICODE-Codex.desktop`
- ASCII banner 갱신 — 거대 "AICODE OS" 노란/하늘색 (Claude/Codex 각 창 색 구분)

### 브랜드 변경
- 통합 이름 = **AICODE-OS** (사장님 결정)
- ISO 파일명 `cco-mint-v2.0.x.iso` → `aicode-os-v2.0.4.iso`
- wallpaper / cover / logo 모두 "AICODE-OS" + Claude + Codex 배지 (yellow + sky blue)
- cluster-skills 정본 폴더 `cco-mint/` → `aicode-os/` git mv
- repo 이름 `claude-code-os` 유지 (URL 호환성)

### 수정
- cover title 한 줄 표시 (font-size 96px + letter-spacing 8px + white-space:nowrap)

---

## v2.0.3 (2026-05-08) — 한글 입력기 EN+KO 자동 등록 + 가독성 폰트

### 추가
- **ibus 입력 source 자동 등록** — `xkb:us::eng` (EN) + `hangul` (KO) preload, 부팅 후 즉시 토글 가능
- **토글 키** — `Shift+Space` / `Hangul` 키 / `Super+Space`
- **GTK 시스템 폰트** — `Noto Sans CJK KR 11pt` (메뉴/대화상자 한글 가독성)
- **xfwm4 윈도우 제목** — `Noto Sans CJK KR Bold 11`
- **xsettings.xml** — Mint-Y-Dark-Aqua 테마 + Mint-Y 아이콘 + DMZ-White 커서 + Xft hinting

### 변경
- 자동 등록 스크립트 `/usr/local/bin/cco-ibus-setup` (autostart, ibus-daemon 시작 후 4초 지연)

---

## v2.0.2 (2026-05-08) — 한글 locale + KST timezone

### 추가
- **language-pack-ko / language-pack-ko-base / locales / tzdata** apt install
- **ko_KR.UTF-8 locale** — `update-locale LANG=ko_KR.UTF-8 LANGUAGE=ko_KR:ko LC_ALL=ko_KR.UTF-8`
- **Asia/Seoul timezone** — `/etc/localtime` 심볼릭 + `/etc/timezone`
- `/home/cco/.profile` 의 LANG 도 ko_KR.UTF-8 로 갱신

---

## v2.0.1 (2026-05-07) — wallpaper / lightdm / 데스크톱 아이콘

### 추가
- **데스크톱 wallpaper** = `/usr/share/backgrounds/cco/wallpaper.png` (1920×1080, Wong colorblind-safe palette + IBM yellow)
  - 다크 네이비 그라디언트 배경 + 거대 노란 픽셀 CCO + 좌상 Available Tools / 우상 System / 좌하 Target hardware / 우하 anthropic
  - xfconf desktop image (multi-monitor: monitor0 / monitorVGA-1 / monitoreDP-1 / monitorLVDS-1)
- **lightdm 로그인 배경** — slick-greeter (Mint 기본) + lightdm-gtk-greeter fallback
- **`~/Desktop/CCO.desktop`** — 데스크톱 좌측 상단 단축키
- **xfce4-terminal terminalrc** — 검정 배경 + D2Coding 13pt + JetBrains Mono + yellow cursor + 120×36 geometry
- **xfwm4 테마** — Mint-Y-Dark-Aqua (헤더 우측 컨트롤 [— ▢ ✕])

### 보안
- Wong palette 적용 (deuteranopia / protanopia / tritanopia 모두 구분 가능, contrast ratio AAA)

---

## v2.0.0 (2026-05-06) — Alpine 폐기, Linux Mint 21.3 XFCE 베이스 전환

### 폐기 이유
사장님 결정 — Alpine v1.0.x 시리즈 (~v1.0.36) 누적 회귀:
- ASUS X515 — 저해상도 vesa fallback + 키보드/마우스 먹통 (mesa-dri-gallium / linux-firmware 부재)
- Samsung NT900X3A — X 윈도우 화면 미표시
- v1.0.36 — `localhost login:` 프롬프트에서 진행 X (Alpine init line 986 default switch_root 가 patch 보다 먼저 실행)
- "용량도 크고 부팅시간도 엄청 느리고 드라이버도 없고"

### Mint 베이스 장점
- Ubuntu 22.04 LTS jammy 호환 (모든 .deb / PPA / apt 동작)
- linux-firmware 풀세트 (모든 Wi-Fi / GPU / 오디오 드라이버 자동)
- Firefox / nm-applet / xfce4-terminal 모두 내장
- Samsung 900X 같은 옛 노트북도 native 부팅

### 포함 항목
- Linux Mint 21.3 XFCE LiveCD (`linuxmint-21.3-xfce-64bit.iso`) 기반으로 chroot 안에 필요한 패키지 추가
- `claude-code` (Node v20 LTS) + `ibus-hangul` + Naver D2Coding (GitHub release zip)
- `cco` user (NOPASSWD sudo, autologin / nopasswdlogin / sudo / audio / video / plugdev / netdev 그룹)
- `cco-startup` 스크립트 = ASCII banner + claude 자동 시작
- `~/.config/autostart/cco-startup.desktop` + `ibus-daemon.desktop`
- slim — apt cache + man / doc / info + non-en/ko locale 제거

### 빌드 결과물
- `cco-mint-v2.0.0.iso` (~3.3 GB)
- xorriso ISO repack (`-boot_image any replay`) 으로 Mint 의 boot record (El Torito + isohybrid GPT) 보존

---

## v1.0.35 (2026-05-05) — Xauthority + iwd 첫 부팅 fix (Alpine, 마지막 v1.x)

### 수정
- **`.Xauthority does not exist`** — `/home/cco/.Xauthority` 빈 파일 미리 생성 (chmod 600). `.profile` 에 `startx` 직전 fallback 추가.
- **iwd 시작 실패** — `/etc/iwd/main.conf` 추가 (`EnableNetworkConfiguration=false` + `NameResolvingService=none` — NetworkManager 가 IP/DNS 담당). `/var/lib/iwd` 미리 생성. cco-infra.start 의 daemon spawn 을 OpenRC service 와 충돌 안 하게 `pgrep` 가드.

---

## v1.0.34 (2026-05-05) — 모든 예상 issue + Ventoy 자동 부팅

### 추가
- **chrony** 추가 — 시간 sync (1970 → 정확 시간 → SSL/OAuth 정상)
- **OpenRC service 활성** — devfs / dmesg / hwclock / bootmisc / hostname / syslog / urandom / modules / iwd / networkmanager / dbus / chronyd
- **`/etc/fstab`** — proc, sys, devpts (gid=5,mode=620), shm, run, tmp 표준 mount
- **`/etc/hosts`** + **`/etc/hostname` = claude-code-os**
- **`nomodloop` 폐기** — alpine modloop 사용 → kernel module 정상 load (Wi-Fi/USB driver 설치됨)
- **Ventoy 자동 부팅 ventoy.json**:
  - `VTOY_MENU_TIMEOUT: 3` — 3초 후 자동
  - `VTOY_DEFAULT_IMAGE: cco-alpine-v1.0.34.iso` — 자동 선택
  - `persistence.autosel: 1` — persistence 자동 enabled
- **자동 installer 스크립트**: `install-cco-on-ventoy.ps1` (Windows) + `.sh` (Linux/macOS) — 한 줄 명령으로 USB 설치
- **INSTALL.md** — 한국어 사용자 가이드

### 수정
- v1.0.33 의 PTY ("Failed to open PTY") — `/dev/pts` 설치
- v1.0.32 의 `/dev/tty1` — `mksquashfs -e dev` 폐기 + devtmpfs mount
- v1.0.31 의 squashfs 검색 — find / + diagnostic
- v1.0.30 의 init bypass fail — alpine init 본체 활용 + sed insert

---

## v1.0.30~33 (2026-05-04 → 05) — squashfs+overlay 검증

- v1.0.30 — alpine init 본체 + sed insert (v1.0.29 bypass fail 회복)
- v1.0.31 — squashfs 검색 path 11곳 + block device + find / + diagnostic
- v1.0.32 — `/dev/tty1` fix (devtmpfs mount on /sysroot)
- v1.0.33 — PTY fix (`/dev/pts` devpts mount)

---

## v1.0.27~29 (2026-05-04) — Ventoy persistence + alpine init bypass

- v1.0.27 — Ventoy persistence 자동 검색 (label `casper-rw` 또는 fat32 안 cco-persistence.dat)
- v1.0.28 — alpine init 우회 시도 (fail)
- v1.0.29 — squashfs+overlay alpine init bypass (fail — KOPT/helper 미도달)

---

## v1.0.21~26 (2026-05-04) — persistence + Wi-Fi GUI

- v1.0.20 — **iwgtk** (gtk Wi-Fi manager, click only) + iwd backend, RTL8821CE 호환
- v1.0.21 — USB persistence (cco-persistence init)
- v1.0.22 — boot 시간 단축 (TIMEOUT, loglevel, fastboot)
- v1.0.23~24 — squashfs+overlay 시도 (overlay workdir issue)
- v1.0.25 — plain tar 회귀 (검증)
- v1.0.26 — persistence USB FAT32 (cdrom remount fix)

---

## v1.0.13~19 (2026-05-02 → 04) — UI 정리 + Wi-Fi 진화

- v1.0.13 — fluxbox 메뉴 한글 폰트 (이후 영문 권장)
- v1.0.14 — xfce4-terminal 인자 fix (`--hold -x`)
- v1.0.15 — 메뉴 영문 only (한글 fallback 회피)
- v1.0.16 — Wi-Fi rfkill + cfg80211 + dbus + wpa_supplicant
- v1.0.17 — RTL8821CE firmware 정확 패키지명 fix
- v1.0.18 — Wi-Fi GUI (nm-connection-editor)
- v1.0.19 — Wi-Fi nmcli CLI prompt

---

## v1.0.7~12 (2026-05-02 → 04) — Wi-Fi/Ethernet driver

- v1.0.7 — linux-firmware-* 드라이버 설치 (RTL/Intel/Atheros/Broadcom/MediaTek)
- v1.0.8 — UEFI grub.cfg "Linux lts" → "Claude Code OS"
- v1.0.9~11 — squashfs 시도 (mount fail)
- v1.0.12 — plain tar 회귀

---

## v1.0.6 (2026-05-02) — 데스크톱 워크스테이션

- X11 + fluxbox + xfce4-terminal + Firefox + ibus-hangul + D2Coding
- cco user (sudo NOPASSWD), claude --dangerously-skip-permissions 자동
- VMware open-vm-tools 클립보드 sync
- 키보드 단축키 (F2/F3/F4/F11/Alt+드래그)

---

## v1.0.0 (2026-05-01) — 첫 공개

- Alpine Linux 3.20 standard ISO + initramfs `/init` 패치
- nodejs + npm + claude-code 사전 설치
- 검은 콘솔 only (X11 X)
- root autologin

---

## 비교 (v1.0.0 → v1.0.35)

| 항목 | v1.0.0 | v1.0.35 |
|---|---|---|
| 인터페이스 | 검은 콘솔 | X11 데스크톱 (fluxbox + xfce4-terminal) |
| 사용자 | root | cco (sudo NOPASSWD) |
| 한글 입력 | 불가 | ibus-hangul + D2Coding |
| Wi-Fi | 없음 | iwgtk + iwd (RTL8821CE 등) |
| OAuth | 다른 PC | Firefox 자동 |
| **Persistence** | 없음 | **Ventoy 자동 (cco-persistence.dat)** |
| 부팅 시간 | ~30s | ~30s + 3s Ventoy timeout |
| 압축 해제 | tar.gz | **squashfs 직접 mount + overlayfs (해제 0)** |
| 자동 설치 | 없음 | **`install-cco-on-ventoy.ps1/.sh` 한 줄** |
| ISO 크기 | ~400MB | ~930MB (squashfs zstd) |
