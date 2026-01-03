ARG ALPINE_VERSION=3.23
FROM docker.io/gautada/alpine:$ALPINE_VERSION as CONTAINER

ARG IMAGE_NAME=n8n
ARG IMAGE_VERSION=2.1.5

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="${IMAGE_NAME}"
LABEL org.opencontainers.image.description="An n8n self-hosted server."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/gautada/n8n"
LABEL org.opencontainers.image.source="https://github.com/gautada/n8n"
LABEL org.opencontainers.image.version="${IMAGE_VERSION}"
LABEL org.opencontainers.image.license="Upstream"

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG USER=n8n
RUN /usr/sbin/usermod -l $USER alpine \
  && /usr/sbin/usermod -d /home/$USER -m $USER \
  && /usr/sbin/groupmod -n $USER alpine \
  && /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭――――――――――――――――――――╮
# │ BACKUP             │
# ╰――――――――――――――――――――╯
# COPY backup /etc/container/backup

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
# Overwrite upstream entrypoint
# COPY entrypoint.sh /usr/bin/container-entrypoint

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
COPY n8n.s6 /etc/services.d/n8n/run
RUN /bin/sed -i 's|dl-cdn.alpinelinux.org/alpine/|mirror.math.princeton.edu/pub/alpinelinux/|g' /etc/apk/repositories \
 && /sbin/apk add --no-cache nodejs npm python3 \
 && echo "n8n@${IMAGE_VERSION}" \
 && npm install "n8n@${IMAGE_VERSION}" -g \
 && ln -fsv /mnt/volumes/container/n8n /home/$USER/.n8n
EXPOSE 8080/tcp
WORKDIR /home/$USER
