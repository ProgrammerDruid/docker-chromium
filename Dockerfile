FROM ubuntu:latest

#get apt ready to install some stuff
RUN \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && apt-get update -y

#the chromium build tools expect a `python` executable, but modern ubuntu uses python3, so install python-is-python3
RUN \
    apt-get install -y \
    build-essential \
    curl \
    git \
    lsb-base \
    lsb-release \
    sudo \
    python-is-python3

RUN \
    apt update 

RUN \
    apt install vim golang -y

# depot tools
RUN \
    cd / \
    && git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

# headless shell
RUN \
    cd / \
    && git clone https://github.com/chromedp/docker-headless-shell.git


#headless shell requires verhist to run, we need to build it and put it on the path
RUN \
    cd / \
    && git clone https://github.com/chromedp/verhist && cd verhist && git checkout v0.3.6 && cd cmd/verhist/ && go build -o /depot_tools/verhist main.go


RUN \
    echo Etc/UTC > /etc/timezone

RUN \
    echo tzdata tzdata/Areas select Etc | debconf-set-selections

RUN \
    echo tzdata tzdata/Zones/Etc UTC | debconf-set-selections

RUN \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

ENV PATH=/depot_tools:$PATH

# needed for install-build-deps.sh
RUN \
    apt-get install -y python3

RUN \
    curl -s https://chromium.googlesource.com/chromium/src/+/master/build/install-build-deps.sh?format=TEXT | base64 -d \
    | perl -pe 's/apt-get install ${do_quietly-}/DEBIAN_FRONTEND=noninteractive apt-get install -y/' \
    | bash -e -s - \
    --no-prompt \
    --no-chromeos-fonts \
    --no-arm \
    --no-syms \
    --no-nacl \
    --no-backwards-compatible

# needed to build mojo
RUN \
    apt-get install -y default-jdk

RUN \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#extra below here -- for local shared drive
# RUN \
#     mkdir -p /media/src/chromium && cd /media/src/chromium ; fetch --nohooks chromium && gclient runhooks

