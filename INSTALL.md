# 설치 가이드 — Claude Code OS + Ventoy persistence

USB 한 개로 **Wi-Fi/OAuth/설정 자동 저장 (재부팅 후에도 보존)** 환경을 만드는 방법.

---

## 다운로드 (Releases 페이지)

[Releases](https://github.com/Hostingglobal-Tech/claude-code-os/releases/latest) 에서 4개 파일 다운로드:

| 파일 | 크기 | 설명 |
|---|---|---|
| `cco-alpine-vX.Y.Z.iso` | ~930 MB | LiveCD ISO |
| `cco-persistence.dat` | 1 GB | persistence container (ext4, label casper-rw) |
| `ventoy.json` | 1 KB | Ventoy plugin 설정 |
| `INSTALL.md` | 1 KB | 이 가이드 |

---

## 설치 (3 단계)

### 1. Ventoy 설치

[Ventoy 다운로드](https://www.ventoy.net) → Ventoy2Disk.exe 으로 USB 에 설치.
USB 의 모든 데이터 사라지므로 미리 백업.

### 2. 4 파일 USB 에 복사

USB 부팅 후 **VTOYEFI / Ventoy** 라벨 partition 안에 설치:

```
F:\
├── cco-alpine-vX.Y.Z.iso       ← USB root
├── cco-persistence.dat          ← USB root
└── ventoy\
    └── ventoy.json              ← ventoy 폴더 안
```

PowerShell:
```powershell
Copy-Item Downloads\cco-alpine-vX.Y.Z.iso F:\
Copy-Item Downloads\cco-persistence.dat F:\
New-Item -ItemType Directory -Path F:\ventoy -Force
Copy-Item Downloads\ventoy.json F:\ventoy\
```

### 3. USB 부팅

PC BIOS 부팅 메뉴 → USB 선택 → **3초 후 자동**:
- Ventoy → cco ISO 자동 선택
- persistence 자동 활성
- cco 데스크톱 진입

---

## 첫 사용

1. **iwgtk** 으로 Wi-Fi 연결 (트레이 또는 우클릭 메뉴)
2. **claude** 자동 시작 → OAuth URL 자동 Firefox open → 인증
3. **설정**, **자주 쓰는 파일** 추가 — 모두 `/home/cco` 에 자동 저장
4. **재부팅** → Wi-Fi 자동 연결, claude 자동 인증 (이미 설정된 상태) — 사용자 입력 0

---

## CLI 검증

```sh
# Persistence 상태
mountpoint /persistence       # /persistence is a mountpoint
df /persistence               # 1.0G 의 사용량

# 시간 sync 확인
chronyc tracking              # NTP 동기화 상태

# Wi-Fi 상태
iwctl station list
nmcli device status
```

---

## persistence 크기 늘리기

기본 1GB. 부족하면 더 큰 file 만들기:

```bash
# Linux/macOS
dd if=/dev/zero of=cco-persistence.dat bs=1M count=4096   # 4GB
mkfs.ext4 -F -L casper-rw cco-persistence.dat
```

기존 데이터 사라짐 — 부팅 후 백업 먼저.

---

## 단축키

| 키 | 동작 |
|---|---|
| F2 | Firefox |
| F3 | Terminal |
| F4 | Claude |
| F11 | Fullscreen |
| Alt+드래그 | 창 이동 |
| Ctrl+Shift+V | 터미널 붙여넣기 |
| 한영 | 한글/영문 토글 |

---

## 문제 해결

- **부팅 시 "Welcome to Alpine" 떨어짐** — ISO 파일 손상. 다시 다운로드.
- **PTY 에러 / can't open tty1** — v1.0.33 이상 사용. 옛 버전 폐기.
- **Wi-Fi가 연결되지 않음** — RTL8821CE chip 의 firmware 포함됨 (v1.0.17+). 그래도 안 되면 `dmesg | grep -i firmware` 확인.
- **persistence 안 활성** — `mountpoint /persistence` 결과 확인. ventoy.json 의 image 이름이 ISO 와 정확히 일치 해야.

---

[전체 변경 이력](CHANGELOG.md)
