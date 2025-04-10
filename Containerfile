ARG ALPINE_VERSION=latest
FROM gautada/alpine:$ALPINE_VERSION as CONTAINER

# ╭――――――――――――――――――――╮
# │ VARIABLES          │
# ╰――――――――――――――――――――╯
ARG IMAGE_VERSION="1.86.1"

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="n8n"
LABEL org.opencontainers.image.description="An n8n self-hosted server."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/gautada/n8n"
LABEL org.opencontainers.image.source="https://github.com/gautada/n8n"
LABEL org.opencontainers.image.version="${IMAGE_VERSION}"
LABEL org.opencontainers.image.license="Upstream"

# ╭―
# │ USER
# ╰――――――――――――――――――――
ARG USER=n8n
RUN /usr/sbin/usermod -l $USER alpine \
  && /usr/sbin/usermod -d /home/$USER -m $USER \
  && /usr/sbin/groupmod -n $USER alpine \
  && /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭―
# │ BACKUP
# ╰――――――――――――――――――――
# COPY backup /etc/container/backup

# ╭―
# │ ENTRYPOINT
# ╰――――――――――――――――――――
# Overwrite upstream entrypoint
COPY entrypoint.sh /usr/bin/container-entrypoint

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
RUN /bin/sed -i 's|dl-cdn.alpinelinux.org/alpine/|mirror.math.princeton.edu/pub/alpinelinux/|g' /etc/apk/repositories \
  && /sbin/apk add --no-cache nodejs npm \
 && echo "n8n@${IMAGE_VERSION}" \
 && npm install "n8n@${IMAGE_VERSION}" -g

# ╭――――――――――――――――――――╮
# │ CONTAINER          │
# ╰――――――――――――――――――――╯
USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
EXPOSE 8080/tcp
WORKDIR /home/$USER
