#!/bin/bash
# AICODE-OS — Mint LiveUSB ISO builder (Claude Code + OpenAI Codex)
# Usage: sudo bash build-mint.sh   (run from a working dir that has linuxmint-*.iso + branding/cco-wallpaper.png)
set -e

WORK_DIR="${WORK_DIR:-$(pwd)}"
cd "$WORK_DIR"

VERSION="${VERSION:-2.0.6}"
ISO_OUT="${ISO_OUT:-aicode-os-v${VERSION}.iso}"
ISO_IN="${ISO_IN:-linuxmint-21.3-xfce-64bit.iso}"
WALLPAPER_PNG="${WALLPAPER_PNG:-${WORK_DIR}/branding/cco-wallpaper.png}"
ROOTFS="${ROOTFS:-/tmp/mint-rootfs}"
EXTRACT="${EXTRACT:-/tmp/mint-extract}"

[ -f "$ISO_IN" ]        || { echo "ERROR: $ISO_IN not found in $WORK_DIR"; exit 1; }
[ -f "$WALLPAPER_PNG" ] || { echo "ERROR: $WALLPAPER_PNG not found"; exit 1; }
[ "$(id -u)" = "0" ]    || { echo "ERROR: must run as root (sudo)"; exit 1; }

date +"START %T"

# 1. ISO 전체 추출 (이미 추출돼 있으면 skip)
if [ ! -f "$EXTRACT/casper/filesystem.squashfs" ]; then
  rm -rf "$EXTRACT"
  mkdir -p "$EXTRACT"
  xorriso -osirrox on -indev "$ISO_IN" -extract / "$EXTRACT" 2>&1 | tail -3
fi
date +"extract %T"

# 2. filesystem.squashfs 풀기 (이미 풀려있고 firefox 박혀있으면 skip)
if [ ! -f "$ROOTFS/usr/bin/firefox" ]; then
  rm -rf "$ROOTFS"
  mkdir -p "$ROOTFS"
  unsquashfs -f -d "$ROOTFS" "$EXTRACT/casper/filesystem.squashfs" >/dev/null
fi
date +"unsquashfs %T"

rm -f "$ISO_OUT"

# 3. chroot 준비
cp /etc/resolv.conf "$ROOTFS/etc/resolv.conf"
mount --bind /proc "$ROOTFS/proc"
mount --bind /sys "$ROOTFS/sys"
mount --bind /dev "$ROOTFS/dev"
mount --bind /dev/pts "$ROOTFS/dev/pts"
trap 'umount "$ROOTFS/dev/pts" "$ROOTFS/dev" "$ROOTFS/sys" "$ROOTFS/proc" 2>/dev/null || true' EXIT

# 3.5. wallpaper PNG 를 chroot 내 임시 위치로 (chroot 안에서 최종 위치로 이동)
mkdir -p "$ROOTFS/tmp/cco-assets"
cp "$WALLPAPER_PNG" "$ROOTFS/tmp/cco-assets/wallpaper.png"

# 4. chroot 안 customization
chroot "$ROOTFS" /bin/bash <<'CHROOT'
set -e
export DEBIAN_FRONTEND=noninteractive

apt update
apt install -y --no-install-recommends \
  curl ca-certificates wget unzip \
  ibus ibus-hangul fonts-noto-cjk fonts-noto-cjk-extra \
  language-pack-ko language-pack-ko-base locales tzdata \
  xfce4-terminal

# Korean locale + Asia/Seoul timezone
locale-gen ko_KR.UTF-8 en_US.UTF-8
update-locale LANG=ko_KR.UTF-8 LANGUAGE=ko_KR:ko LC_ALL=ko_KR.UTF-8
echo 'LANG=ko_KR.UTF-8' > /etc/default/locale
echo 'LANGUAGE=ko_KR:ko' >> /etc/default/locale
echo 'LC_ALL=ko_KR.UTF-8' >> /etc/default/locale
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
echo 'Asia/Seoul' > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata 2>/dev/null || true

# Node.js 20 LTS (claude-code 권장)
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# claude-code + OpenAI Codex CLI (둘 다 npm, 기본은 빌드 시점 최신)
CLAUDE_CODE_NPM_VERSION="${CLAUDE_CODE_NPM_VERSION:-latest}"
CODEX_NPM_VERSION="${CODEX_NPM_VERSION:-latest}"
npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_NPM_VERSION}" "@openai/codex@${CODEX_NPM_VERSION}"
claude --version 2>/dev/null || true
codex --version 2>/dev/null || true

# D2Coding 폰트 (Naver GitHub release — Ubuntu repo 미포함)
mkdir -p /usr/share/fonts/truetype/d2coding
cd /tmp
wget -q 'https://github.com/naver/d2codingfont/releases/download/VER1.3.2/D2Coding-Ver1.3.2-20180524.zip' -O d2.zip
unzip -q d2.zip -d d2-extract
find d2-extract -name '*.ttf' -exec cp {} /usr/share/fonts/truetype/d2coding/ \;
rm -rf d2-extract d2.zip
fc-cache -fv >/dev/null 2>&1

# cco user
id cco 2>/dev/null || useradd -m -s /bin/bash -G sudo,audio,video,plugdev,netdev cco
echo 'cco:cco' | chpasswd
echo 'cco ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/cco
chmod 440 /etc/sudoers.d/cco

# lightdm autologin
sed -i 's/^#*autologin-user=.*/autologin-user=cco/' /etc/lightdm/lightdm.conf 2>/dev/null || \
  echo -e '[Seat:*]\nautologin-user=cco\nautologin-user-timeout=0' > /etc/lightdm/lightdm.conf
sed -i 's/^#*autologin-user-timeout=.*/autologin-user-timeout=0/' /etc/lightdm/lightdm.conf

# autologin group (필수 — Ubuntu 22.04)
groupadd -f nopasswdlogin
groupadd -f autologin
usermod -aG nopasswdlogin,autologin cco

# aicode-startup-claude — Anthropic Claude Code
cat > /usr/local/bin/aicode-startup-claude <<'EOSTART'
#!/bin/bash
export BROWSER=firefox
clear
printf '\033[1;38;5;220m'
cat <<'BANNER'

      █████╗ ██╗ ██████╗ ██████╗ ██████╗ ███████╗      ██████╗ ███████╗
     ██╔══██╗██║██╔════╝██╔═══██╗██╔══██╗██╔════╝     ██╔═══██╗██╔════╝
     ███████║██║██║     ██║   ██║██║  ██║█████╗       ██║   ██║███████╗
     ██╔══██║██║██║     ██║   ██║██║  ██║██╔══╝       ██║   ██║╚════██║
     ██║  ██║██║╚██████╗╚██████╔╝██████╔╝███████╗     ╚██████╔╝███████║
     ╚═╝  ╚═╝╚═╝ ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝

           AICODE-OS  v2.0.6  ·  Anthropic Claude Code

BANNER
printf '\033[0m'
printf '\033[38;5;245m  Mint 21.3 XFCE · cco user (sudo NOPASSWD) · 한글: Shift+Space\033[0m\n\n'
if command -v claude >/dev/null 2>&1; then
  claude --dangerously-skip-permissions
  rc=$?
else
  echo "ERROR: claude command not found"
  rc=127
fi
echo
echo "Claude Code exited with status ${rc}. This shell stays open for recovery."
exec bash
EOSTART
chmod 755 /usr/local/bin/aicode-startup-claude

# aicode-startup-codex — OpenAI Codex CLI
cat > /usr/local/bin/aicode-startup-codex <<'EOCODEX'
#!/bin/bash
clear
printf '\033[1;38;5;81m'
cat <<'BANNER'

      █████╗ ██╗ ██████╗ ██████╗ ██████╗ ███████╗      ██████╗ ███████╗
     ██╔══██╗██║██╔════╝██╔═══██╗██╔══██╗██╔════╝     ██╔═══██╗██╔════╝
     ███████║██║██║     ██║   ██║██║  ██║█████╗       ██║   ██║███████╗
     ██╔══██║██║██║     ██║   ██║██║  ██║██╔══╝       ██║   ██║╚════██║
     ██║  ██║██║╚██████╗╚██████╔╝██████╔╝███████╗     ╚██████╔╝███████║
     ╚═╝  ╚═╝╚═╝ ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝

           AICODE-OS  v2.0.6  ·  OpenAI Codex CLI

BANNER
printf '\033[0m'
printf '\033[38;5;245m  npm @openai/codex · OPENAI_API_KEY 또는 ChatGPT 로그인 필요\033[0m\n\n'
if command -v codex >/dev/null 2>&1; then
  codex
  rc=$?
else
  echo "ERROR: codex command not found"
  rc=127
fi
echo
echo "OpenAI Codex exited with status ${rc}. This shell stays open for recovery."
exec bash
EOCODEX
chmod 755 /usr/local/bin/aicode-startup-codex

# autostart — Claude + Codex 한 창 두 탭 동시 시작
mkdir -p /home/cco/.config/autostart
rm -f /home/cco/.config/autostart/aicode-claude.desktop \
      /home/cco/.config/autostart/aicode-codex.desktop \
      /home/cco/.config/autostart/cco-startup.desktop \
      /home/cco/.config/autostart/aicode-startup-dual.desktop

cat > /usr/local/bin/aicode-startup-dual <<'EODUAL'
#!/bin/bash
exec xfce4-terminal --maximize --disable-server \
  --tab --title="Claude Code" --command="/usr/local/bin/aicode-startup-claude" \
  --tab --title="OpenAI Codex" --command="/usr/local/bin/aicode-startup-codex"
EODUAL
chmod 755 /usr/local/bin/aicode-startup-dual

cat > /home/cco/.config/autostart/aicode-os.desktop <<'EODESK'
[Desktop Entry]
Type=Application
Name=AICODE-OS
Exec=/usr/local/bin/aicode-startup-dual
X-GNOME-Autostart-enabled=true
EODESK

# Korean input — ibus + 한글 locale
cat > /home/cco/.profile <<'EOPROF'
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export LANG=ko_KR.UTF-8
export LANGUAGE=ko_KR:ko
export LC_ALL=ko_KR.UTF-8
EOPROF

cat > /home/cco/.config/autostart/ibus-daemon.desktop <<'EOIBUS'
[Desktop Entry]
Type=Application
Name=ibus-daemon
Exec=ibus-daemon -drx
X-GNOME-Autostart-enabled=true
EOIBUS

# ibus input sources: EN(xkb:us::eng) + KO(hangul) 등록 + 한/영 토글 키
cat > /usr/local/bin/cco-ibus-setup <<'EOIBSCR'
#!/bin/bash
# Wait for ibus-daemon
sleep 3
# Register English + Korean (hangul)
dconf write /desktop/ibus/general/preload-engines "['xkb:us::eng', 'hangul']" 2>/dev/null
# Toggle keys: Shift+Space, Hangul (Right-Alt on most KR keyboards), Caps Lock, <Super>space
dconf write /desktop/ibus/general/hotkey/triggers "['<Shift>space', 'Hangul', 'Caps_Lock', '<Super>space']" 2>/dev/null
dconf write /desktop/ibus/general/use-system-keyboard-layout true 2>/dev/null
dconf write /desktop/ibus/general/embed-preedit-text true 2>/dev/null
# Restart ibus to apply
ibus restart 2>/dev/null || true
# Default to English on login
ibus engine xkb:us::eng 2>/dev/null || true
EOIBSCR
chmod 755 /usr/local/bin/cco-ibus-setup

cat > /home/cco/.config/autostart/cco-ibus-setup.desktop <<'EOIBAUTO'
[Desktop Entry]
Type=Application
Name=CCO ibus EN+KO setup
Exec=/usr/local/bin/cco-ibus-setup
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=4
EOIBAUTO

# === CCO branding: wallpaper + lightdm + desktop icon + xfce4-terminal ===

# wallpaper 정착 위치
mkdir -p /usr/share/backgrounds/cco
mv /tmp/cco-assets/wallpaper.png /usr/share/backgrounds/cco/wallpaper.png
chmod 644 /usr/share/backgrounds/cco/wallpaper.png
rm -rf /tmp/cco-assets

# XFCE 데스크톱 wallpaper — cco user 프로필
mkdir -p /home/cco/.config/xfce4/xfconf/xfce-perchannel-xml
cat > /home/cco/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml <<'EOXFCE'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/cco/wallpaper.png"/>
        </property>
      </property>
      <property name="monitorVGA-1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/cco/wallpaper.png"/>
        </property>
      </property>
      <property name="monitoreDP-1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/cco/wallpaper.png"/>
        </property>
      </property>
      <property name="monitorLVDS-1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/cco/wallpaper.png"/>
        </property>
      </property>
      <property name="monitorHDMI-1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/cco/wallpaper.png"/>
        </property>
      </property>
      <property name="monitorDP-1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/cco/wallpaper.png"/>
        </property>
      </property>
      <property name="monitordefault" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/cco/wallpaper.png"/>
        </property>
      </property>
      <property name="monitorVirtual1" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="/usr/share/backgrounds/cco/wallpaper.png"/>
        </property>
      </property>
    </property>
  </property>
</channel>
EOXFCE

# XFCE는 실제 모니터 이름(eDP-1/HDMI-1/DP-1/Virtual1 등)을 backdrop key에 넣는다.
# 고해상도/외부 모니터 장비에서 이름이 바뀌면 빌드 시 XML만으로는 wallpaper가 빠질 수 있어
# 로그인 후 실제 연결된 monitor key 전체에 wallpaper를 다시 적용한다.
cat > /usr/local/bin/cco-apply-wallpaper <<'EOWALL'
#!/bin/bash
set -u

WALLPAPER="/usr/share/backgrounds/cco/wallpaper.png"
[ -f "$WALLPAPER" ] || exit 0

for _ in $(seq 1 20); do
  if command -v xfconf-query >/dev/null 2>&1 && pgrep -x xfdesktop >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

set_prop() {
  local path="$1" type="$2" value="$3"
  xfconf-query -c xfce4-desktop -p "$path" -n -t "$type" -s "$value" >/dev/null 2>&1 || true
  xfconf-query -c xfce4-desktop -p "$path" -s "$value" >/dev/null 2>&1 || true
}

monitors="monitor0 monitordefault monitorDefault monitorVirtual1"
if command -v xrandr >/dev/null 2>&1; then
  connected="$(xrandr --query 2>/dev/null | awk '/ connected/{print "monitor"$1}' | tr '\n' ' ')"
  monitors="$monitors $connected"
fi
existing="$(xfconf-query -c xfce4-desktop -l 2>/dev/null | sed -n 's|^/backdrop/screen0/\([^/]*\)/workspace[0-9]/last-image$|\1|p' | sort -u | tr '\n' ' ')"
monitors="$(printf '%s\n' $monitors $existing | awk 'NF && !seen[$0]++')"

for monitor in $monitors; do
  for workspace in 0 1 2 3; do
    base="/backdrop/screen0/${monitor}/workspace${workspace}"
    set_prop "${base}/color-style" int 0
    set_prop "${base}/image-style" int 5
    set_prop "${base}/last-image" string "$WALLPAPER"
    set_prop "${base}/image-path" string "$WALLPAPER"
  done
done

xfdesktop --reload >/dev/null 2>&1 || true
EOWALL
chmod 755 /usr/local/bin/cco-apply-wallpaper

cat > /home/cco/.config/autostart/cco-apply-wallpaper.desktop <<'EOWALLAUTO'
[Desktop Entry]
Type=Application
Name=CCO high-resolution wallpaper apply
Exec=/usr/local/bin/cco-apply-wallpaper
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=8
EOWALLAUTO

# Mint 기본 배경 심볼릭 — Mint 가 wallpaper 못 찾으면 fallback
mkdir -p /usr/share/backgrounds/linuxmint
ln -sf /usr/share/backgrounds/cco/wallpaper.png /usr/share/backgrounds/linuxmint/cco-default.png || true

# lightdm 로그인 화면 배경 — slick-greeter (Mint 기본)
if [ -f /etc/lightdm/slick-greeter.conf ] || command -v slick-greeter >/dev/null 2>&1; then
  cat > /etc/lightdm/slick-greeter.conf <<'EOSLICK'
[Greeter]
background=/usr/share/backgrounds/cco/wallpaper.png
draw-user-backgrounds=false
draw-grid=false
show-hostname=true
theme-name=Mint-Y-Dark-Aqua
icon-theme-name=Mint-Y
EOSLICK
fi
# lightdm-gtk-greeter fallback
mkdir -p /etc/lightdm/lightdm-gtk-greeter.conf.d
cat > /etc/lightdm/lightdm-gtk-greeter.conf.d/90-cco.conf <<'EOGTK'
[greeter]
background=/usr/share/backgrounds/cco/wallpaper.png
theme-name=Mint-Y-Dark-Aqua
icon-theme-name=Mint-Y
EOGTK

# Desktop 아이콘 (통합 실행 + Claude / Codex 단독 실행)
mkdir -p /home/cco/Desktop
cat > /home/cco/Desktop/AICODE-OS.desktop <<'EOAIOS'
[Desktop Entry]
Version=1.0
Type=Application
Name=AICODE-OS
Comment=Launch Claude Code and OpenAI Codex in one terminal window
Exec=/usr/local/bin/aicode-startup-dual
Icon=utilities-terminal
Terminal=false
Categories=Development;
StartupNotify=true
EOAIOS
chmod +x /home/cco/Desktop/AICODE-OS.desktop

cat > /home/cco/Desktop/AICODE-Claude.desktop <<'EOAICLA'
[Desktop Entry]
Version=1.0
Type=Application
Name=AICODE-OS — Claude Code
Comment=Launch Anthropic Claude Code
Exec=xfce4-terminal --geometry=120x36 --title=AICODE-OS\ —\ Claude\ Code --hold -e /usr/local/bin/aicode-startup-claude
Icon=utilities-terminal
Terminal=false
Categories=Development;
StartupNotify=true
EOAICLA
chmod +x /home/cco/Desktop/AICODE-Claude.desktop

cat > /home/cco/Desktop/AICODE-Codex.desktop <<'EOAICOD'
[Desktop Entry]
Version=1.0
Type=Application
Name=AICODE-OS — OpenAI Codex
Comment=Launch OpenAI Codex CLI
Exec=xfce4-terminal --geometry=100x30 --title=AICODE-OS\ —\ OpenAI\ Codex --hold -e /usr/local/bin/aicode-startup-codex
Icon=utilities-terminal
Terminal=false
Categories=Development;
StartupNotify=true
EOAICOD
chmod +x /home/cco/Desktop/AICODE-Codex.desktop

# xfce4-terminal 기본 색상/폰트 (검정 배경 + JetBrains Mono / D2Coding 14pt)
mkdir -p /home/cco/.config/xfce4/terminal
cat > /home/cco/.config/xfce4/terminal/terminalrc <<'EOTERM'
[Configuration]
FontName=D2Coding 13
ColorPalette=#000000;#cc0000;#4e9a06;#c4a000;#3465a4;#75507b;#06989a;#d3d7cf;#555753;#ef2929;#8ae234;#fce94f;#739fcf;#ad7fa8;#34e2e2;#eeeeec
ColorBackground=#0a0a0a
ColorForeground=#FFFFFF
ColorCursor=#FFB000
ColorBold=#FFFFFF
MiscAlwaysShowTabs=FALSE
MiscBell=FALSE
MiscBordersDefault=TRUE
MiscCursorBlinks=TRUE
MiscCursorShape=TERMINAL_CURSOR_SHAPE_BLOCK
MiscDefaultGeometry=120x36
MiscInheritGeometry=FALSE
MiscMenubarDefault=TRUE
MiscMouseAutohide=FALSE
MiscToolbarDefault=FALSE
MiscConfirmClose=FALSE
MiscCycleTabs=TRUE
MiscTabCloseButtons=TRUE
MiscTabCloseMiddleClick=TRUE
MiscTabPosition=GTK_POS_TOP
MiscHighlightUrls=TRUE
ScrollingBar=TERMINAL_SCROLLBAR_RIGHT
ScrollingLines=10000
EOTERM

# xfwm4 (window manager) 테마 + 한글 가독성 title font
mkdir -p /home/cco/.config/xfce4/xfconf/xfce-perchannel-xml
cat > /home/cco/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml <<'EOXFWM'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="Mint-Y-Dark-Aqua"/>
    <property name="title_font" type="string" value="Noto Sans CJK KR Bold 11"/>
    <property name="button_layout" type="string" value="O|HMC"/>
    <property name="workspace_count" type="int" value="2"/>
  </property>
</channel>
EOXFWM

# GTK 시스템 폰트 (메뉴/대화상자/패널) — 한글 가독성
cat > /home/cco/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml <<'EOXSET'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Mint-Y-Dark-Aqua"/>
    <property name="IconThemeName" type="string" value="Mint-Y"/>
    <property name="DoubleClickTime" type="int" value="400"/>
    <property name="EnableEventSounds" type="bool" value="false"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName" type="string" value="Noto Sans CJK KR 11"/>
    <property name="MonospaceFontName" type="string" value="D2Coding 12"/>
    <property name="CursorThemeName" type="string" value="DMZ-White"/>
    <property name="ButtonImages" type="bool" value="true"/>
    <property name="MenuImages" type="bool" value="true"/>
  </property>
  <property name="Xft" type="empty">
    <property name="DPI" type="int" value="-1"/>
    <property name="Antialias" type="int" value="1"/>
    <property name="Hinting" type="int" value="1"/>
    <property name="HintStyle" type="string" value="hintslight"/>
    <property name="RGBA" type="string" value="rgb"/>
  </property>
</channel>
EOXSET

# xfce4 panel font 도 한글 가독성
mkdir -p /home/cco/.config/xfce4/panel
cat > /home/cco/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml <<'EOPANEL'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="dark-mode" type="bool" value="true"/>
    <property name="panel-1" type="empty">
      <property name="size" type="uint" value="32"/>
      <property name="length" type="uint" value="100"/>
      <property name="position" type="string" value="p=8;x=0;y=0"/>
      <property name="position-locked" type="bool" value="true"/>
    </property>
  </property>
</channel>
EOPANEL

chown -R cco:cco /home/cco

# slim — apt cache + man + doc + locale (en + ko 외)
apt clean
rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb
rm -rf /usr/share/man /usr/share/doc /usr/share/info
find /usr/share/locale -mindepth 1 -maxdepth 1 -type d \
  ! -name 'en' ! -name 'en_*' ! -name 'ko' ! -name 'ko_*' \
  -exec rm -rf {} + 2>/dev/null || true

CHROOT
date +"chroot %T"

# 5. unmount
umount "$ROOTFS/dev/pts" "$ROOTFS/dev" "$ROOTFS/sys" "$ROOTFS/proc" 2>/dev/null || true

# 6. squashfs 재패키징 (zstd)
rm -f "$EXTRACT/casper/filesystem.squashfs"
mksquashfs "$ROOTFS" "$EXTRACT/casper/filesystem.squashfs" -comp zstd -b 1M -noappend 2>&1 | tail -3
date +"mksquashfs %T"

# 7. filesystem.size 갱신
du -sx --block-size=1 "$ROOTFS" | cut -f1 > "$EXTRACT/casper/filesystem.size"

# 8. ISO 재빌드 (원본 boot info 그대로)
xorriso -indev "$ISO_IN" -outdev "$ISO_OUT" \
  -boot_image any replay -volid 'CCO-Mint-v2.0.0' \
  -map "$EXTRACT/casper/filesystem.squashfs" /casper/filesystem.squashfs \
  -map "$EXTRACT/casper/filesystem.size" /casper/filesystem.size \
  -commit 2>&1 | tail -3

chown nmsglobal:nmsglobal "$ISO_OUT"
date +"ISO DONE %T"
ls -la "$ISO_OUT"
