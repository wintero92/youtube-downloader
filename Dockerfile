# syntax=docker/dockerfile:1

################################################################################
# layer: safe_user_land
#   layer creating `downloader` user and `downloader` group

FROM ubuntu:22.04 AS safe_user_land

ARG BUILD_DATE

LABEL maintainer="Ondrej Winter <ondrej.winter@gmail.com>"
LABEL org.opencontainers.image.created=$BUILD_DATE
LABEL org.opencontainers.image.url=""
LABEL org.opencontainers.image.source=""
LABEL org.opencontainers.image.vendor=""
LABEL org.opencontainers.image.title="linux-youtube-downloader"
LABEL org.opencontainers.image.description="YouTube channels downloader."
LABEL org.opencontainers.image.ref.name="youtube-downloader"
LABEL org.opencontainers.image.version="1"

RUN <<EOF
    groupadd --gid 10001 downloader
    useradd --system \
            --create-home \
            --home-dir /home/downloader \
            --shell /bin/bash \
            --gid 10001 \
            --uid 10001 \
            downloader
EOF

################################################################################
# layer: yt-dlp

FROM safe_user_land AS ytdlp

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

ENV PATH=/home/downloader/.local/bin:${PATH}

RUN <<EOF
    apt-get update
    apt-get install --no-install-recommends -y \
        apt-utils='2.*'\
        ca-certificates='2023*' \
        curl='7.*' \
        ffmpeg='7:4.*' \
        gnupg='2.*' \
        gpg='2.*' \
        software-properties-common='0.99.*' \
        sudo='1.*'
    update-ca-certificates
    add-apt-repository ppa:deadsnakes/ppa
    apt-get update
    apt-get install --no-install-recommends -y python3.11
    curl -sSL https://bootstrap.pypa.io/get-pip.py | python3.11
    apt-get -y clean
    rm -rf /var/lib/apt/lists/*
    mkdir -p /etc/sudoers.d/
    echo "downloader ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/downloader
EOF

USER downloader

# hadolint ignore=DL3004
RUN <<EOF
    python3.11 -m pip install --no-cache-dir yt-dlp
    sudo apt-get -y clean
    sudo rm -rf /var/lib/apt/lists/*
    sudo rm /etc/sudoers.d/downloader
EOF

WORKDIR /app

COPY --chown=10001:10001 scripts/* /app/

CMD [ "bash", "run.sh" ]

################################################################################