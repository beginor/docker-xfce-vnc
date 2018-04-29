FROM beginor/ubuntu-china:16.04

LABEL MAINTAINER="beginor <beginor@gmail.com>"

ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 \
    HOME=/headless \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/headless/install \
    NO_VNC_HOME=/headless/noVNC \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1280x800 \
    VNC_PW=vncpassword \
    VNC_VIEW_ONLY=false \
    LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8'

EXPOSE $VNC_PORT $NO_VNC_PORT

WORKDIR $HOME

COPY ["src/lxde-vnc.sh", "/tmp/"]
COPY src/xfce/ $HOME/
COPY src/startup $STARTUPDIR

RUN /tmp/lxde-vnc.sh

USER 1000

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]
