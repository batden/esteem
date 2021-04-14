#!/bin/bash

# This Bash script allows you to easily and safely install Enlightenment along with
# other EFL-based applications, on Ubuntu.

# See README.md for instructions on how to use this script.

# Heads up!
# Enlightenment programs installed from .deb packages or tarballs will inevitably conflict
# with programs compiled from the Enlightenment git repositories——do not mix source code
# with pre-built binaries!

# Once installed, you can update your shiny new Enlightenment desktop whenever you want to.
# However, because software gains entropy over time (performance regression, unexpected
# behavior... and this is especially true when dealing directly with source code), we
# highly recommend doing a complete uninstall and reinstall of your Enlightenment
# desktop every three weeks or so for an optimal user experience.

# ESTEEM.SH is written and maintained by batden@sfr.fr and carlasensa@sfr.fr,
# feel free to use this script as you see fit.

# ---------------
# LOCAL VARIABLES
# ---------------

BLD="\e[1m"    # Bold text.
ITA="\e[3m"    # Italic text.
BDR="\e[1;31m" # Bold red text.
BDG="\e[1;32m" # Bold green text.
BDY="\e[1;33m" # Bold yellow text.
BDP="\e[1;35m" # Bold purple text.
OFF="\e[0m"    # Turn off ANSI colors and formatting.

PREFIX=/usr/local
DLDIR=$(xdg-user-dir DOWNLOAD)
DOCDIR=$(xdg-user-dir DOCUMENTS)
SCRFLR=$HOME/.esteem
REBASEF="git config pull.rebase false"
CONFG="./configure --prefix=$PREFIX"
GEN="./autogen.sh --prefix=$PREFIX"
SNIN="sudo ninja -C build install"
SMIL="sudo make install"
DISTRO=$(lsb_release -sc)
LWEB=libwebp-1.2.0
LAVF=0.8.4

# Build dependencies, recommended and script-related packages.
# The Papirus Icon Theme fits nicely with the default theme for Enlightenment:
# https://github.com/PapirusDevelopmentTeam/papirus-icon-theme

DEPS="aspell build-essential ccache check cmake cowsay ddcutil doxygen \
fonts-noto graphviz gstreamer1.0-libav gstreamer1.0-plugins-bad \
gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly imagemagick \
libasound2-dev libavahi-client-dev libblkid-dev libbluetooth-dev \
libegl1-mesa-dev libexif-dev libfontconfig1-dev libdrm-dev \
libfreetype6-dev libfribidi-dev libgbm-dev libgeoclue-2-dev \
libgif-dev libgraphviz-dev libgstreamer1.0-dev \
libgstreamer-plugins-base1.0-dev libharfbuzz-dev libheif-dev \
libi2c-dev libibus-1.0-dev libinput-dev libinput-tools libjpeg-dev \
libluajit-5.1-dev liblz4-dev libmenu-cache-dev libmount-dev \
libopenjp2-7-dev libosmesa6-dev libpam0g-dev libpoppler-cpp-dev \
libpoppler-dev libpoppler-private-dev libpulse-dev libraw-dev \
librsvg2-dev libscim-dev libsndfile1-dev libspectre-dev libssl-dev \
libsystemd-dev libtiff5-dev libtool libudev-dev libudisks2-dev \
libunibreak-dev libunwind-dev libxcb-keysyms1-dev libxcursor-dev \
libxinerama-dev libxkbcommon-x11-dev libxkbfile-dev lxmenu-data \
libxrandr-dev libxss-dev libxtst-dev lolcat manpages-dev \
manpages-posix-dev meson mlocate nasm ninja-build texlive-base \
unity-greeter-badges valgrind wayland-protocols wmctrl xdotool \
xserver-xephyr xwayland"

# Latest development code.
CLONEFL="git clone https://git.enlightenment.org/core/efl.git"
CLONETY="git clone https://git.enlightenment.org/apps/terminology.git"
CLONE25="git clone https://git.enlightenment.org/core/enlightenment.git"
CLONEPH="git clone https://git.enlightenment.org/apps/ephoto.git"
CLONERG="git clone https://git.enlightenment.org/apps/rage.git"
CLONEVI="git clone https://git.enlightenment.org/apps/evisum.git"
CLONEVE="git clone https://git.enlightenment.org/tools/enventor.git"
CLONEXP="git clone https://git.enlightenment.org/apps/express.git"

# 'MN' stands for Meson, 'AT' refers to Autotools.
PROG_MN="efl terminology enlightenment ephoto evisum rage express"
PROG_AT="enventor"

# ---------
# FUNCTIONS
# ---------

beep_attention() {
  paplay /usr/share/sounds/freedesktop/stereo/dialog-warning.oga
}

beep_question() {
  paplay /usr/share/sounds/freedesktop/stereo/dialog-information.oga
}

beep_exit() {
  paplay /usr/share/sounds/freedesktop/stereo/suspend-error.oga
}

beep_ok() {
  paplay /usr/share/sounds/freedesktop/stereo/complete.oga
}

# Hints.
# 1/2: Plain build with well tested default values.
# 3: A feature-rich, decently optimized build; however, occasionally technical glitches do happen...
# 4: Same as above, but running Enlightenment as a Wayland compositor is still considered experimental.

sel_menu() {
  if [ $INPUT -lt 1 ]; then
    echo
    printf "1. $BDG%s $OFF%s\n\n" "INSTALL Enlightenment now"
    printf "2. $BDG%s $OFF%s\n\n" "Update and REBUILD Enlightenment"
    printf "3. $BDP%s $OFF%s\n\n" "Update and rebuild Enlightenment in RELEASE mode"
    printf "4. $BDY%s $OFF%s\n\n" "Update and rebuild Enlightenment with WAYLAND support"

    sleep 1 && printf "$ITA%s $OFF%s\n\n" "Or press Ctrl+C to quit."
    read INPUT
  fi
}

bin_deps() {
  sudo apt update && sudo apt full-upgrade

  sudo apt install $DEPS
  if [ $? -ne 0 ]; then
    printf "\n$BDR%s %s\n" "CONFLICTING OR MISSING .DEB PACKAGES"
    printf "$BDR%s %s\n" "OR DPKG DATABASE IS LOCKED."
    printf "$BDR%s $OFF%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
  fi
}

ls_dir() {
  COUNT=$(ls -d -- */ | wc -l)
  if [ $COUNT == 8 ]; then
    printf "$BDG%s $OFF%s\n\n" "All programs have been downloaded successfully."
    sleep 2
  elif [ $COUNT == 0 ]; then
    printf "\n$BDR%s %s\n" "OOPS! SOMETHING WENT WRONG."
    printf "$BDR%s $OFF%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
  else
    printf "\n$BDY%s %s\n" "WARNING: ONLY $COUNT OF 8 PROGRAMS HAVE BEEN DOWNLOADED!"
    printf "\n$BDY%s $OFF%s\n\n" "WAIT 12 SECONDS OR HIT CTRL+C TO QUIT."
    beep_attention
    sleep 12
  fi
}

mng_err() {
  printf "\n$BDR%s $OFF%s\n\n" "BUILD ERROR——TRY AGAIN LATER."
  beep_exit
  exit 1
}

chk_path() {
  if ! echo $PATH | grep -q $HOME/.local/bin; then
    echo -e '    export PATH=$HOME/.local/bin:$PATH' >>$HOME/.bash_aliases
    source $HOME/.bash_aliases
  fi
}

elap_start() {
  START=$(date +%s)
}

elap_stop() {
  DELTA=$(($(date +%s) - START))
  printf "\n$ITA%s $OFF%s" "Compilation and linking time: "
  eval "echo $(date -ud "@$DELTA" +'%H hr %M min %S sec')"
}

# Timestamp: See the date man page to convert epoch to human-readable date
# or visit https://www.epochconverter.com/

e_bkp() {
  TSTAMP=$(date +%s)
  mkdir -p $DOCDIR/ebackups

  mkdir $DOCDIR/ebackups/E_$TSTAMP
  cp -aR $HOME/.elementary $DOCDIR/ebackups/E_$TSTAMP && cp -aR $HOME/.e $DOCDIR/ebackups/E_$TSTAMP

  if [ -d $HOME/.config/terminology ]; then
    cp -aR $HOME/.config/terminology $DOCDIR/ebackups/Eterm_$TSTAMP
  fi

  sleep 2
}

e_tokens() {
  echo $(date +%s) >>$HOME/.cache/ebuilds/etokens

  TOKEN=$(wc -l <$HOME/.cache/ebuilds/etokens)
  if [ "$TOKEN" -gt 3 ]; then
    echo
    # Questions: Enter either y or n, or press Enter to accept the default value (capital letter).
    beep_question
    read -t 12 -p "Do you want to back up your Enlightenment settings now? [y/N] " answer
    case $answer in
    [yY])
      e_bkp
      ;;
    [nN])
      printf "\n$ITA%s $OFF%s\n\n" "(no backup made... OK)"
      ;;
    *)
      printf "\n$ITA%s $OFF%s\n\n" "(no backup made... OK)"
      ;;
    esac
  fi
}

rstrt_e() {
  if [ "$XDG_CURRENT_DESKTOP" == "Enlightenment" ]; then
    enlightenment_remote -restart
  fi
}

build_plain() {
  chk_path

  sudo ln -sf /usr/lib/x86_64-linux-gnu/preloadable_libintl.so /usr/lib/libintl.so
  sudo ldconfig

  for I in $PROG_MN; do
    cd $ESRC/e25/$I
    printf "\n$BLD%s $OFF%s\n\n" "Building $I..."

    case $I in
    efl)
      meson build
      ninja -C build || mng_err
      ;;
    enlightenment)
      meson build
      ninja -C build || mng_err
      ;;
    *)
      meson build
      ninja -C build || true
      ;;
    esac

    beep_attention
    $SNIN || true
    sudo ldconfig
  done

  for I in $PROG_AT; do
    cd $ESRC/e25/$I
    printf "\n$BLD%s $OFF%s\n\n" "Building $I..."

    $GEN
    make || true
    beep_attention
    $SMIL || true
    sudo ldconfig
  done
}

rebuild_plain() {
  ESRC=$(cat $HOME/.cache/ebuilds/storepath)
  bin_deps
  e_tokens
  elap_start

  cd $ESRC/rlottie
  printf "\n$BLD%s $OFF%s\n\n" "Updating rlottie..."
  git reset --hard &>/dev/null
  $REBASEF && git pull
  meson --reconfigure build
  ninja -C build || true
  $SNIN || true
  sudo ldconfig

  elap_stop

  for I in $PROG_MN; do
    elap_start

    cd $ESRC/e25/$I
    printf "\n$BLD%s $OFF%s\n\n" "Updating $I..."
    git reset --hard &>/dev/null
    $REBASEF && git pull
    rm -rf build
    echo

    case $I in
    efl)
      meson build
      ninja -C build || mng_err
      ;;
    enlightenment)
      meson build
      ninja -C build || mng_err
      ;;
    *)
      meson build
      ninja -C build || true
      ;;
    esac

    beep_attention
    $SNIN || true
    sudo ldconfig

    elap_stop
  done

  for I in $PROG_AT; do
    elap_start
    cd $ESRC/e25/$I

    printf "\n$BLD%s $OFF%s\n\n" "Updating $I..."
    sudo make distclean &>/dev/null
    git reset --hard &>/dev/null
    $REBASEF && git pull

    $GEN
    make || true
    beep_attention
    $SMIL || true
    sudo ldconfig
    elap_stop
  done
}

rebuild_optim_mn() {
  ESRC=$(cat $HOME/.cache/ebuilds/storepath)
  bin_deps
  e_tokens
  elap_start

  cd $ESRC/rlottie
  printf "\n$BLD%s $OFF%s\n\n" "Updating rlottie..."
  git reset --hard &>/dev/null
  $REBASEF && git pull
  echo
  sudo chown $USER build/.ninja*
  meson configure -Dexample=false -Dbuildtype=release build
  ninja -C build || true
  $SNIN || true
  sudo ldconfig

  elap_stop

  for I in $PROG_MN; do
    elap_start

    cd $ESRC/e25/$I
    printf "\n$BLD%s $OFF%s\n\n" "Updating $I..."
    git reset --hard &>/dev/null
    $REBASEF && git pull

    case $I in
    efl)
      sudo chown $USER build/.ninja*
      meson configure -Dnative-arch-optimization=true -Dfb=true -Dharfbuzz=true \
        -Dbindings=cxx -Dbuild-tests=false -Dbuild-examples=false \
        -Devas-loaders-disabler=json -Dbuildtype=release build
      ninja -C build || mng_err
      ;;
    enlightenment)
      sudo chown $USER build/.ninja*
      meson configure -Dbuildtype=release build
      ninja -C build || mng_err
      ;;
    *)
      sudo chown $USER build/.ninja*
      meson configure -Dbuildtype=release build
      ninja -C build || true
      ;;
    esac

    $SNIN || true
    sudo ldconfig

    elap_stop
  done
}

rebuild_optim_at() {
  export CFLAGS="-O2 -ffast-math -march=native"

  for I in $PROG_AT; do
    elap_start
    cd $ESRC/e25/$I

    printf "\n$BLD%s $OFF%s\n\n" "Updating $I..."
    sudo make distclean &>/dev/null
    git reset --hard &>/dev/null
    $REBASEF && git pull

    $GEN
    make || true
    beep_attention
    $SMIL || true
    sudo ldconfig
    elap_stop
  done
}

rebuild_wld_mn() {
  if [ "$XDG_SESSION_TYPE" == "tty" ] && [ "$XDG_CURRENT_DESKTOP" == "Enlightenment" ]; then
    printf "\n$BDR%s $OFF%s\n\n" "PLEASE LOG IN TO THE DEFAULT DESKTOP ENVIRONMENT TO EXECUTE THIS SCRIPT."
    beep_exit
    exit 1
  fi

  ESRC=$(cat $HOME/.cache/ebuilds/storepath)
  bin_deps
  e_tokens
  elap_start

  cd $ESRC/rlottie
  printf "\n$BLD%s $OFF%s\n\n" "Updating rlottie..."
  git reset --hard &>/dev/null
  $REBASEF && git pull
  echo
  sudo chown $USER build/.ninja*
  meson configure -Dexample=false -Dbuildtype=release build
  ninja -C build || true
  $SNIN || true
  sudo ldconfig

  elap_stop

  for I in $PROG_MN; do
    elap_start

    cd $ESRC/e25/$I
    printf "\n$BLD%s $OFF%s\n\n" "Updating $I..."
    git reset --hard &>/dev/null
    $REBASEF && git pull

    case $I in
    efl)
      sudo chown $USER build/.ninja*
      meson configure -Dnative-arch-optimization=true -Dfb=true -Dharfbuzz=true \
        -Dbindings=cxx -Ddrm=true -Dwl=true -Dopengl=es-egl \
        -Dbuild-tests=false -Dbuild-examples=false \
        -Devas-loaders-disabler=json \
        -Dbuildtype=release build
      ninja -C build || mng_err
      ;;
    enlightenment)
      sudo chown $USER build/.ninja*
      meson configure -Dwl=true -Dbuildtype=release build
      ninja -C build || mng_err
      ;;
    *)
      sudo chown $USER build/.ninja*
      meson configure -Dbuildtype=release build
      ninja -C build || true
      ;;
    esac

    $SNIN || true
    sudo ldconfig

    elap_stop
  done
}

rebuild_wld_at() {
  export CFLAGS="-O2 -ffast-math -march=native"

  for I in $PROG_AT; do
    elap_start
    cd $ESRC/e25/$I

    printf "\n$BLD%s $OFF%s\n\n" "Updating $I..."
    sudo make distclean &>/dev/null
    git reset --hard &>/dev/null
    $REBASEF && git pull

    $GEN
    make || true
    beep_attention
    $SMIL || true
    sudo ldconfig
    elap_stop
  done
}

do_tests() {
  if [ -x /usr/bin/wmctrl ]; then
    if [ "$XDG_SESSION_TYPE" == "x11" ]; then
      wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
    fi
  fi

  printf "\n\n$BLD%s $OFF%s\n" "System check..."

  if systemd-detect-virt -q --container; then
    printf "\n$BDR%s %s\n" "ESTEEM.SH IS NOT INTENDED FOR USE INSIDE CONTAINERS."
    printf "$BDR%s $OFF%s\n\n" "SCRIPT ABORTED."
    beep_exit
    exit 1
  fi

  if [ $DISTRO == focal ] || [ $DISTRO == groovy ] || [ $DISTRO == hirsute ]; then
    printf "\n$BDG%s $OFF%s\n\n" "Ubuntu ${DISTRO^}... OK"
    sleep 2
  else
    printf "\n$BDR%s $OFF%s\n\n" "UNSUPPORTED OPERATING SYSTEM [ $(lsb_release -d | cut -f2) ]."
    beep_exit
    exit 1
  fi

  git ls-remote https://git.enlightenment.org/core/efl.git HEAD &>/dev/null
  if [ $? -ne 0 ]; then
    printf "\n$BDR%s %s\n" "REMOTE HOST IS UNREACHABLE——TRY AGAIN LATER"
    printf "$BDR%s $OFF%s\n\n" "OR CHECK YOUR INTERNET CONNECTION."
    beep_exit
    exit 1
  fi

  [[ ! -d $HOME/.local/bin ]] && mkdir -p $HOME/.local/bin

  [[ ! -d $HOME/.cache/ebuilds ]] && mkdir -p $HOME/.cache/ebuilds
}

do_bsh_alias() {
  if [ ! -f $HOME/.bash_aliases ]; then
    touch $HOME/.bash_aliases

    cat >$HOME/.bash_aliases <<EOF
    # ----------------
    # GLOBAL VARIABLES
    # ----------------

    # Compiler and linker flags added by esteem.
    export CC="ccache gcc"
    export CXX="ccache g++"
    export USE_CCACHE=1
    export CCACHE_COMPRESS=1
    export CPPFLAGS=-I/usr/local/include
    export LDFLAGS=-L/usr/local/lib
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

    # Parallel build? It's your call...
    #export MAKE="make -j$(($(nproc) * 2))"

    # This script adds the ~/.local/bin directory to your PATH environment variable if required.
EOF

    source $HOME/.bash_aliases
  fi
}

set_p_src() {
  echo
  beep_attention
  # Do not append a trailing slash (/) to the end of the path prefix.
  read -p "Please enter a path to the Enlightenment source folders \
  (e.g. /home/jamie/Documents or /home/jamie/testing): " mypath
  mkdir -p "$mypath"/sources
  ESRC="$mypath"/sources
  echo $ESRC >$HOME/.cache/ebuilds/storepath
  printf "\n%s\n\n" "You have chosen: $ESRC"
  sleep 1
}

get_preq() {
  ESRC=$(cat $HOME/.cache/ebuilds/storepath)
  cd $DLDIR
  printf "\n\n$BLD%s $OFF%s\n\n" "Installing prerequisites.."
  wget -c https://storage.googleapis.com/downloads.webmproject.org/releases/webp/$LWEB.tar.gz
  tar xzvf $LWEB.tar.gz -C $ESRC
  cd $ESRC/$LWEB
  $CONFG
  make
  sudo make install
  sudo ldconfig
  rm -rf $DLDIR/$LWEB.tar.gz
  echo

  cd $ESRC
  git clone https://aomedia.googlesource.com/aom
  cd $ESRC/aom
  mkdir -p aom-build && cd aom-build
  cmake .. -DENABLE_CCACHE=1 -DENABLE_NASM=ON
  make
  sudo make install
  echo

  cd $DLDIR
  wget -c https://github.com/AOmediaCodec/libavif/archive/v$LAVF.tar.gz
  tar xzvf v$LAVF.tar.gz -C $ESRC
  cd $ESRC/libavif-$LAVF
  mkdir -p build && cd build
  cmake .. -DAVIF_CODEC_AOM=ON -DBUILD_SHARED_LIBS=OFF
  make
  sudo make install
  rm -rf $DLDIR/v$LAVF.tar.gz
  echo

  cd $ESRC
  git clone https://github.com/Samsung/rlottie.git
  cd $ESRC/rlottie
  meson build
  ninja -C build || true
  $SNIN || true
  sudo ldconfig
  echo
}

do_lnk() {
  sudo ln -sf /usr/local/etc/enlightenment/system.conf /etc/enlightenment/system.conf
  sudo ln -sf /usr/local/etc/xdg/menus/e-applications.menu /etc/xdg/menus/e-applications.menu
}

install_now() {
  clear
  printf "\n$BDG%s $OFF%s\n\n" "* INSTALLING ENLIGHTENMENT DESKTOP: PLAIN BUILD *"
  beep_attention
  do_bsh_alias
  bin_deps
  set_p_src
  get_preq

  cd $HOME
  mkdir -p $ESRC/e25
  cd $ESRC/e25

  printf "\n\n$BLD%s $OFF%s\n\n" "Fetching source code from the Enlightenment git repositories..."
  $CLONEFL
  echo
  $CLONETY
  echo
  $CLONE25
  echo
  $CLONEPH
  echo
  $CLONERG
  echo
  $CLONEVI
  echo
  $CLONEVE
  echo
  $CLONEXP
  echo

  ls_dir

  build_plain

  printf "\n%s\n\n" "Almost done..."

  mkdir -p $HOME/.elementary/themes

  sudo mkdir -p /etc/enlightenment
  do_lnk

  sudo ln -sf /usr/local/share/xsessions/enlightenment.desktop \
    /usr/share/xsessions/enlightenment.desktop

  sudo updatedb
  beep_ok

  printf "\n\n$BDY%s %s" "Initial setup wizard tips:"
  printf "\n$BDY%s %s" "'Update checking' —— you can disable this feature because it serves no useful purpose."
  printf "\n$BDY%s $OFF%s\n\n\n" "'Network management support' —— Connman is not needed."
  # Enlightenment adds three shortcut icons (namely home.desktop, root.desktop and tmp.desktop)
  # to your Ubuntu Desktop, you can safely delete them.

  echo
  cowsay "Now reboot your computer then select Enlightenment on the login screen... \
  That's All Folks!" | lolcat -a
  echo

  cp -f $DLDIR/esteem.sh $HOME/.local/bin
}

update_go() {
  clear
  printf "\n$BDG%s $OFF%s\n\n" "* UPDATING ENLIGHTENMENT DESKTOP: PLAIN BUILD *"

  cp -f $SCRFLR/esteem.sh $HOME/.local/bin
  chmod +x $HOME/.local/bin/esteem.sh
  sleep 1

  rebuild_plain

  sudo ln -sf /usr/local/share/xsessions/enlightenment.desktop \
    /usr/share/xsessions/enlightenment.desktop

  if [ -f /usr/share/wayland-sessions/enlightenment.desktop ]; then
    sudo rm -rf /usr/share/wayland-sessions/enlightenment.desktop
  fi

  sudo updatedb
  beep_ok
  rstrt_e
  echo
  cowsay -f www "That's All Folks!"
  echo
}

release_go() {
  clear
  printf "\n$BDP%s $OFF%s\n\n" "* UPDATING ENLIGHTENMENT DESKTOP: RELEASE BUILD *"

  cp -f $SCRFLR/esteem.sh $HOME/.local/bin
  chmod +x $HOME/.local/bin/esteem.sh
  sleep 1

  rebuild_optim_mn
  rebuild_optim_at

  sudo ln -sf /usr/local/share/xsessions/enlightenment.desktop \
    /usr/share/xsessions/enlightenment.desktop

  if [ -f /usr/share/wayland-sessions/enlightenment.desktop ]; then
    sudo rm -rf /usr/share/wayland-sessions/enlightenment.desktop
  fi

  sudo updatedb
  beep_ok
  rstrt_e
  echo
  cowsay -f www "That's All Folks!"
  echo
}

wld_go() {
  clear
  printf "\n$BDY%s $OFF%s\n\n" "* UPDATING ENLIGHTENMENT DESKTOP: WAYLAND BUILD *"

  cp -f $SCRFLR/esteem.sh $HOME/.local/bin
  chmod +x $HOME/.local/bin/esteem.sh
  sleep 1

  rebuild_wld_mn
  rebuild_wld_at

  sudo mkdir -p /usr/share/wayland-sessions
  sudo ln -sf /usr/local/share/wayland-sessions/enlightenment.desktop \
    /usr/share/wayland-sessions/enlightenment.desktop

  sudo updatedb
  beep_ok

  if [ "$XDG_SESSION_TYPE" == "x11" ] || [ "$XDG_SESSION_TYPE" == "wayland" ]; then
    echo
    cowsay -f www "Now log out of your existing session and press Ctrl+Alt+F3 to switch to tty3, \
        then enter your credentials and type: enlightenment_start" | lolcat -a
    echo
    # Wait a few seconds for the Wayland session to start.
    # When you're done, type exit
    # Pressing Ctrl+Alt+F1 will bring you back to the login screen.
  else
    echo
    cowsay -f www "That's it. Now type: enlightenment_start"
    echo
  fi
}

main() {
  trap '{ printf "\n$BDR%s $OFF%s\n\n" "KEYBOARD INTERRUPT."; exit 130; }' INT

  INPUT=0
  printf "\n$BLD%s $OFF%s\n" "Please enter the number of your choice:"
  sel_menu

  if [ $INPUT == 1 ]; then
    do_tests
    install_now
  elif [ $INPUT == 2 ]; then
    do_tests
    update_go
  elif [ $INPUT == 3 ]; then
    do_tests
    release_go
  elif [ $INPUT == 4 ]; then
    do_tests
    wld_go
  else
    beep_exit
    exit 1
  fi
}

main
