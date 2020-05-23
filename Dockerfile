# Jackett and OpenVPN, JackettVPN

FROM debian:buster
MAINTAINER imsplitbit

ENV DEBIAN_FRONTEND noninteractive
ENV IPTV_VERSION 2.0.3

WORKDIR /opt

# Make directories
RUN mkdir -p /config/openvpn /config/iptv-vpn

# Update, upgrade and install required packages
RUN apt update \
    && apt -y upgrade \
    && apt -y install \
    apt-transport-https \
    wget \
    curl \
    gnupg \
    sed \
    openvpn \
    emacs-nox \
    curl \
    moreutils \
    net-tools \
    dos2unix \
    kmod \
    iptables \
    procps \
    ipcalc\
    grep \
    libcurl4 \
    liblttng-ust0 \
    libkrb5-3 \
    zlib1g \
    tzdata \
    && apt-get clean \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

# Install iptv-proxy
RUN curl -o iptv-proxy.deb -skSL "https://github.com/pierre-emmanuelJ/iptv-proxy/releases/download/v${IPTV_VERSION}/iptv-proxy_${IPTV_VERSION}_linux_amd64.deb" \
    && dpkg -i iptv-proxy.deb \
    && rm -f iptv-proxy.deb


VOLUME /config

ADD openvpn/ /etc/openvpn/
ADD iptv-proxy/ /etc/iptv-proxy/

RUN chmod +x /etc/iptv-proxy/*.sh /etc/openvpn/*.sh

CMD ["/bin/bash", "/etc/openvpn/start.sh"]