FROM alpine:3.1      4

SHELL ["/bin/ash", "-x", "-c", "-o", "pipefail"]

# Based on https://github.com/multani/docker-nomad
LABEL maintainer="Szymon Maszke <github@maszke.co>"

RUN addgroup nomad \
 && adduser -S -G nomad nomad \
 && mkdir -p /nomad/data \
 && mkdir -p /etc/nomad \
 && chown -R nomad:nomad /nomad /etc/nomad

# Allow to fetch artifacts from TLS endpoint during the builds and by Nomad after.
# Install timezone data so we can run Nomad periodic jobs containing timezone information
RUN apk --update --no-cache add \
        ca-certificates \
        libcap \
        tzdata \
        su-exec \
  && update-ca-certificates

# https://github.com/sgerrand/alpine-pkg-glibc/releases
ARG GLIBC_VERSION=2.33-r0

ADD https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub /etc/apk/keys/sgerrand.rsa.pub
ADD https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
    glibc.apk
RUN apk add --no-cache \
        glibc.apk \
 && rm glibc.apk
 
ARG HASHICORP_PGP_FINGERPRINT="C874 011F 0AB4 0511 0D02 1055 3436 5D94 72D7 468F"

# https://releases.hashicorp.com/nomad/
ARG NOMAD_VERSION=1.2.6

ADD https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip \
    nomad_${NOMAD_VERSION}_linux_amd64.zip
ADD https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS \
    nomad_${NOMAD_VERSION}_SHA256SUMS
ADD https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS.sig \
    nomad_${NOMAD_VERSION}_SHA256SUMS.sig
RUN apk add --no-cache --virtual .nomad-deps gnupg \
  && GNUPGHOME="$(mktemp -d)" \
  && export GNUPGHOME \
  && gpg --keyserver pgp.mit.edu --keyserver keys.openpgp.org --keyserver keyserver.ubuntu.com --recv-keys "${HASHICORP_PGP_FINGERPRINT}" \
  && gpg --batch --verify nomad_${NOMAD_VERSION}_SHA256SUMS.sig nomad_${NOMAD_VERSION}_SHA256SUMS \
  && grep nomad_${NOMAD_VERSION}_linux_amd64.zip nomad_${NOMAD_VERSION}_SHA256SUMS | sha256sum -c \
  && unzip -d /bin nomad_${NOMAD_VERSION}_linux_amd64.zip \
  && chmod +x /bin/nomad \
  && rm -rf "$GNUPGHOME" nomad_${NOMAD_VERSION}_linux_amd64.zip nomad_${NOMAD_VERSION}_SHA256SUMS nomad_${NOMAD_VERSION}_SHA256SUMS.sig \
  && apk del .nomad-deps
  
# https://releases.hashicorp.com/nomad-driver-podman/
ARG NOMAD_DRIVER_PODMAN_VERSION=0.3.0
ENV NOMAD_PLUGIN_DIR="/nomad/plugins"

ADD https://releases.hashicorp.com/nomad-driver-podman/${NOMAD_DRIVER_PODMAN_VERSION}/nomad-driver-podman_${NOMAD_DRIVER_PODMAN_VERSION}_linux_amd64.zip \
    nomad-driver-podman_${NOMAD_DRIVER_PODMAN_VERSION}_linux_amd64.zip
ADD https://releases.hashicorp.com/nomad-driver-podman/${NOMAD_DRIVER_PODMAN_VERSION}/nomad-driver-podman_${NOMAD_DRIVER_PODMAN_VERSION}_SHA256SUMS \
    nomad-driver-podman_${NOMAD_DRIVER_PODMAN_VERSION}_SHA256SUMS
ADD https://releases.hashicorp.com/nomad-driver-podman/${NOMAD_DRIVER_PODMAN_VERSION}/nomad-driver-podman_${NOMAD_DRIVER_PODMAN_VERSION}_SHA256SUMS.sig \
    nomad-driver-podman_${NOMAD_DRIVER_PODMAN_VERSION}_SHA256SUMS.sig
RUN apk add --no-cache --virtual .nomad-driver-podman-deps gnupg \
  && GNUPGHOME="$(mktemp -d)" \
  && export GNUPGHOME \
  && gpg --keyserver pgp.mit.edu --keyserver keys.openpgp.org --keyserver keyserver.ubuntu.com --recv-keys "${HASHICORP_PGP_FINGERPRINT}" \
  && gpg --batch --verify nomad-driver-podman_${NOMAD_DRIVER_PODMAN_VERSION}_SHA256SUMS.sig nomad-driver-podman_${NOMAD_DRIVER_PODMAN_VERSION}_SHA256SUMS \
  && grep nomad-driver-podman_${NOMAD_DRIVER_PODMAN_VERSION}_linux_amd64.zip nomad-driver-podman_${NOMAD_DRIVER_PODMAN_VERSION}_SHA256SUMS | sha256sum -c \
  && mkdir -p ${NOMAD_PLUGIN_DIR} \
  && unzip -d ${NOMAD_PLUGIN_DIR} nomad-driver-podman_${NOMAD_DRIVER_PODMAN_VERSION}_linux_amd64.zip \
  && chmod +x ${NOMAD_PLUGIN_DIR}/nomad-driver-podman \
  && rm -rf "$GNUPGHOME" nomad-driver-podman_${NOMAD_DRIVER_PODMAN_VERSION}_linux_amd64.zip \
  && rm -rf nomad-driver-podman_${NOMAD_DRIVER_PODMAN_VERSION}_SHA256SUMS nomad-driver-podman_${NOMAD_DRIVER_PODMAN_VERSION}_SHA256SUMS.sig \
  && apk del .nomad-driver-podman-deps

EXPOSE 4646 4647 4648 4648/udp

COPY start.sh /usr/local/bin/

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/start.sh"]
CMD ["--help"]
