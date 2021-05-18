# Debian based borg server - multistage docker image

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# STAGE 1: compile borg software to /usr/local/borg
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FROM debian:10-slim AS builder

ARG BORG_VERSION=1.1.16
    
RUN set -ex \
 && apt-get update \
 # build packages
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install --yes \
        build-essential \
        libacl1 \
        libacl1-dev \
        libfuse-dev \
        libssl-dev \
        libzstd-dev \
        openssl \
        pkg-config \
        python3 \
        python3-dev \
        python3-pip \
        virtualenv 


RUN set -ex \
 && virtualenv --python=python3 /opt/borg \
 && . /opt/borg/bin/activate \
 && python3 -m pip install \
    borgbackup[fuse]==$BORG_VERSION \
    borgmatic


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# STAGE 2: 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FROM debian:10-slim 

# application packages installation
RUN set -ex \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install --yes --no-install-recommends --no-install-suggests \
        openssh-client \
        python3-minimal \
        python3-distutils \
        fuse \
 && apt-get --yes autoremove && apt-get clean \
 && rm -rf /tmp/* /usr/share/doc/ /var/lib/apt/lists/* /var/tmp/* 


COPY --from=builder /opt/borg /opt/borg

ENV PATH="/opt/borg/bin:$PATH"

# docker integration
EXPOSE 22
CMD ["/opt/borg/bin/borg", "--version"]

# vim: set ft=sh:ts=4:sw=4:
