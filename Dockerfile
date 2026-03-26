# syntax=docker/dockerfile:1.7

ARG BASE_IMAGE_REGISTRY=ghcr.io
ARG BASE_IMAGE_NAME=linuxserver/baseimage-alpine
ARG BASE_IMAGE_VARIANT=3.22
ARG BASE_IMAGE=${BASE_IMAGE_REGISTRY}/${BASE_IMAGE_NAME}:${BASE_IMAGE_VARIANT}
ARG BUILD_OUTPUT_DIR=/out
ARG GRAPHS1090_REPO_URL=https://github.com/wiedehopf/graphs1090
ARG GRAPHS1090_REPO_BRANCH=master
ARG VCS_URL=https://github.com/blackoutsecure/docker-graphs1090

# ---------------------------------------------------------------------------
# Stage 1: Builder — clone graphs1090 and prepare application files
# ---------------------------------------------------------------------------
FROM ${BASE_IMAGE} AS builder

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG BUILD_OUTPUT_DIR
ARG GRAPHS1090_REPO_URL
ARG GRAPHS1090_REPO_BRANCH
ARG VCS_URL

RUN apk add --no-cache \
        bash \
        ca-certificates \
        git

WORKDIR /src

RUN git clone --branch ${GRAPHS1090_REPO_BRANCH} --single-branch --depth 1 ${GRAPHS1090_REPO_URL} . && \
    BUILD_DATE="$(git log -1 --format=%cI)" && \
    VERSION="$(cat version 2>/dev/null || git rev-parse --short HEAD)" && \
    VCS_REF="$(git rev-parse HEAD)" && \
    printf 'BUILD_DATE=%s\nVERSION=%s\nVCS_REF=%s\nVCS_URL=%s\n' \
        "${BUILD_DATE}" "${VERSION}" "${VCS_REF}" "${VCS_URL}" \
        > /tmp/graphs1090-build-metadata.env && \
    rm -rf .git && \
    # Stamp version into index.html (matches upstream install.sh behavior)
    sed -i 's|<span id="graphs1090-version">.*</span>|<span id="graphs1090-version"> '"${VERSION}"'</span>|' html/index.html && \
    # Create application layout
    mkdir -p \
        "${BUILD_OUTPUT_DIR}/usr/share/graphs1090/html" && \
    # Copy HTML assets
    cp -a html/. "${BUILD_OUTPUT_DIR}/usr/share/graphs1090/html/" && \
    # Copy application scripts, configs, and data files
    cp -a *.sh *.py *.db *.conf default adjust-scripts-s6-sh LICENSE version \
        "${BUILD_OUTPUT_DIR}/usr/share/graphs1090/" && \
    # Install build metadata
    install -D -m 0644 /tmp/graphs1090-build-metadata.env \
        "${BUILD_OUTPUT_DIR}/usr/share/graphs1090/build-metadata.env"

# ---------------------------------------------------------------------------
# Stage 2: Runtime image
# ---------------------------------------------------------------------------
FROM ${BASE_IMAGE}

ARG BUILD_OUTPUT_DIR
ARG GRAPHS1090_USER=abc
ARG GRAPHS1090_PORT=8080
ARG VCS_URL

LABEL build_version="Linuxserver.io version:- unknown Build-date:- unknown"
LABEL maintainer="Blackout Secure - https://blackoutsecure.app/"
LABEL org.opencontainers.image.title="docker-graphs1090" \
    org.opencontainers.image.description="LinuxServer.io style containerized build of graphs1090, generating performance graphs for readsb / dump1090-fa ADS-B receivers with signal, range, aircraft count, CPU, and network statistics." \
    org.opencontainers.image.url="${VCS_URL}" \
    org.opencontainers.image.source="${VCS_URL}" \
    org.opencontainers.image.revision="unknown" \
    org.opencontainers.image.created="unknown" \
    org.opencontainers.image.version="unknown" \
    org.opencontainers.image.licenses="MIT"

ENV HOME="/config" \
    GRAPHS1090_USER="${GRAPHS1090_USER}" \
    GRAPHS1090_PORT="${GRAPHS1090_PORT}"

# Install runtime dependencies:
#   collectd + python plugin — data collection from decoder JSON
#   rrdtool — round-robin database for time-series storage and graph rendering
#   nginx — serves the web UI
#   bash — required by graphs1090 shell scripts
#   fontconfig — rrdtool graph text rendering
RUN apk add --no-cache \
        bash \
        collectd \
        collectd-disk \
        collectd-python \
        collectd-rrdtool \
        fontconfig \
        nginx \
        py3-six \
        python3 \
        rrdtool \
        tzdata

# Copy built application from builder stage
COPY --link --from=builder ${BUILD_OUTPUT_DIR}/usr/share/graphs1090/ /usr/share/graphs1090/

# Copy s6-overlay service definitions and nginx config template
COPY --link root/ /

# Set up application directories, install scripts, and configure collectd
RUN set -eux && \
    # Load build metadata into labels if available
    if [ -f /usr/share/graphs1090/build-metadata.env ]; then \
        . /usr/share/graphs1090/build-metadata.env; \
    fi && \
    echo "Linuxserver.io version:- ${VERSION:-unknown} Build-date:- ${BUILD_DATE:-unknown} Revision:- ${VCS_REF:-unknown}" > /build_version && \
    # Make s6 service scripts executable
    find /etc/s6-overlay/s6-rc.d -type f \( -name run -o -name finish -o -name check \) -exec chmod 0755 {} + && \
    # Create required directories
    mkdir -p \
        /config \
        /run/graphs1090 \
        /var/lib/collectd/rrd \
        /var/lib/graphs1090/scatter \
        /run/collectd \
        /usr/share/graphs1090/data-symlink \
        /usr/share/graphs1090/978-symlink && \
    # Make scripts executable and save default config
    chmod u+x /usr/share/graphs1090/*.sh && \
    cp -a /usr/share/graphs1090/default /usr/share/graphs1090/default-config && \
    # Install collectd configuration (save pristine copy for reference, per upstream install.sh)
    mkdir -p /etc/collectd && \
    cp /usr/share/graphs1090/collectd.conf /usr/share/graphs1090/default-collectd.conf && \
    cp /usr/share/graphs1090/collectd.conf /etc/collectd/collectd.conf && \
    # Configure collectd to use /run/collectd (memory-backed for reduced writes)
    sed -i 's|DataDir.*|DataDir "/run/collectd"|' /etc/collectd/collectd.conf && \
    # Install default graphs1090 config
    mkdir -p /etc/default && \
    cp /usr/share/graphs1090/default-config /etc/default/graphs1090 && \
    # Adjust scripts for s6 (replace systemctl calls with s6-svc)
    bash /usr/share/graphs1090/adjust-scripts-s6-sh && \
    # Set ownership
    chown -R 911:911 /config /usr/share/graphs1090 /run/graphs1090 /var/lib/collectd /var/lib/graphs1090 && \
    # Cleanup
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD sh -c 'wget -q --spider http://127.0.0.1:${GRAPHS1090_PORT:-8080}/graphs1090/ || exit 1'

EXPOSE ${GRAPHS1090_PORT}
VOLUME ["/config", "/var/lib/collectd/rrd"]

