#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "Update and upgrade"
apt-get update && apt-get upgrade -y

echo "Install some common tools for further installation"
apt-get install -y --no-install-recommends wget net-tools locales bzip2 \
    python-numpy #used for websockify/novnc

echo "Generate locales für en_US.UTF-8"
locale-gen en_US.UTF-8

echo "Install TigerVNC server"
wget -qO- https://dl.bintray.com/tigervnc/stable/tigervnc-1.8.0.x86_64.tar.gz | tar xz --strip 1 -C /

echo "Install noVNC - HTML5 based VNC viewer"
mkdir -p $NO_VNC_HOME/utils/websockify
wget -qO- https://github.com/novnc/noVNC/archive/v1.0.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME
# use older version of websockify to prevent hanging connections on offline containers, see https://github.com/ConSol/docker-headless-vnc-container/issues/50
wget -qO- https://github.com/novnc/websockify/archive/v0.6.1.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify
chmod +x -v $NO_VNC_HOME/utils/*.sh
## create index.html to forward automatically to `vnc_lite.html`
ln -s $NO_VNC_HOME/vnc_lite.html $NO_VNC_HOME/index.html

echo "Install Chromium Browser"
apt-get install -y --no-install-recommends chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg
ln -s /usr/bin/chromium-browser /usr/bin/google-chrome
### fix to start chromium in a Docker container, see https://github.com/ConSol/docker-headless-vnc-container/issues/2
echo "CHROMIUM_FLAGS='--no-sandbox --start-maximized --user-data-dir'" > $HOME/.chromium-browser.init

echo "Install Xfce4 UI components"
apt-get install -y supervisor xfce4 xfce4-terminal
apt-get purge -y pm-utils xscreensaver*

echo "Install nss-wrapper to be able to execute image as non-root user"
apt-get install -y libnss-wrapper gettext

echo "add 'souce generate_container_user' to .bashrc"
# have to be added to hold all env vars correctly
echo 'source $STARTUPDIR/generate_container_user' >> $HOME/.bashrc

if [[ -z $DEBUG ]]; then
    verbose="-v"
fi

for var in "$@"
do
    echo "fix permissions for: $var"
    find "$var"/ -name '*.sh' -exec chmod $verbose a+x {} +
    find "$var"/ -name '*.desktop' -exec chmod $verbose a+x {} +
    chgrp -R 0 "$var" && chmod -R $verbose a+rw "$var" && find "$var" -type d -exec chmod $verbose a+x {} +
done

echo "Cleanup"
apt-get clean -y
apt-get autoremove
rm -rf /var/lib/apt/lists/*
