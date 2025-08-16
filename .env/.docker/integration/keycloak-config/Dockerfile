FROM registry.access.redhat.com/ubi9 AS ubi-micro-build
RUN mkdir -p /mnt/rootfs
RUN dnf install --installroot /mnt/rootfs jq curl \
    --releasever 9 --setopt install_weak_deps=false --nodocs -y; \
    dnf --installroot /mnt/rootfs clean all

FROM quay.io/keycloak/keycloak:latest
COPY --from=ubi-micro-build /mnt/rootfs /

COPY scripts /scripts/
COPY config /config/

USER root
RUN chmod +x /scripts/*.sh

RUN sed -i 's/\r//' /scripts/configure-keycloak.sh

ENTRYPOINT /scripts/configure-keycloak.sh ; /bin/bash