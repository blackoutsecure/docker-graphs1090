<p align="center">
  <img src="https://raw.githubusercontent.com/blackoutsecure/docker-graphs1090/main/logo.png" alt="graphs1090 logo" width="200">
</p>

# blackoutsecure/graphs1090

[![GitHub Stars](https://img.shields.io/github/stars/blackoutsecure/docker-graphs1090?style=flat-square&color=E7931D&logo=github)](https://github.com/blackoutsecure/docker-graphs1090/stargazers)
[![Docker Pulls](https://img.shields.io/docker/pulls/blackoutsecure/graphs1090?style=flat-square&color=E7931D&logo=docker&logoColor=FFFFFF)](https://hub.docker.com/r/blackoutsecure/graphs1090)
[![GitHub Release](https://img.shields.io/github/release/blackoutsecure/docker-graphs1090.svg?style=flat-square&color=E7931D&logo=github&logoColor=FFFFFF)](https://github.com/blackoutsecure/docker-graphs1090/releases)
[![Release CI](https://img.shields.io/github/actions/workflow/status/blackoutsecure/docker-graphs1090/release.yml?style=flat-square&label=release%20ci&color=E7931D)](https://github.com/blackoutsecure/docker-graphs1090/actions/workflows/release.yml)
[![Publish CI](https://img.shields.io/github/actions/workflow/status/blackoutsecure/docker-graphs1090/publish.yml?style=flat-square&label=publish%20ci&color=E7931D)](https://github.com/blackoutsecure/docker-graphs1090/actions/workflows/publish.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](https://opensource.org/licenses/MIT)

Unofficial community image for [graphs1090](https://github.com/wiedehopf/graphs1090), built with [LinuxServer.io](https://linuxserver.io/) style container patterns (s6, hardened defaults, practical runtime options) for ADS-B performance graphing workloads.

Sponsored and maintained by [Blackout Secure](https://blackoutsecure.app).

> [!IMPORTANT]
> This repository is not an official LinuxServer.io image release.
> Want to help make it an officially supported LinuxServer.io Community image?
> Add your support in [linuxserver/discussions/112](https://github.com/orgs/linuxserver/discussions/112).

## Overview

This project packages upstream [wiedehopf/graphs1090](https://github.com/wiedehopf/graphs1090) into an easy-to-run, LinuxServer.io-style container image with practical defaults for generating performance graphs from readsb / dump1090-fa ADS-B receivers.

Quick links:

- Docker Hub listing: [blackoutsecure/graphs1090](https://hub.docker.com/r/blackoutsecure/graphs1090)
- Balena block listing: [graphs1090 block on Balena Hub](https://hub.balena.io/blocks/2351129/graphs1090)
- GitHub repository: [blackoutsecure/docker-graphs1090](https://github.com/blackoutsecure/docker-graphs1090)
- Upstream application: [wiedehopf/graphs1090](https://github.com/wiedehopf/graphs1090)

[![balena deploy button](https://www.balena.io/deploy.svg)](https://dashboard.balena-cloud.com/deploy?repoUrl=https://github.com/blackoutsecure/docker-graphs1090&configUrl=https://raw.githubusercontent.com/blackoutsecure/docker-graphs1090/main/balena.yml)

---

## Table of Contents

- [blackoutsecure/graphs1090](#blackoutsecuregraphs1090)
  - [Overview](#overview)
  - [Table of Contents](#table-of-contents)
  - [Quick Start](#quick-start)
  - [Image Availability](#image-availability)
  - [About The graphs1090 Application](#about-the-graphs1090-application)
  - [Supported Architectures](#supported-architectures)
  - [Usage](#usage)
    - [docker-compose (recommended, click here for more info)](#docker-compose-recommended-click-here-for-more-info)
    - [docker-compose paired with readsb](#docker-compose-paired-with-readsb)
    - [docker-cli (click here for more info)](#docker-cli-click-here-for-more-info)
    - [Balena Deployment](#balena-deployment)
  - [Parameters](#parameters)
    - [Ports](#ports)
    - [Environment Variables](#environment-variables)
    - [Storage Mounts](#storage-mounts)
  - [Volume Details](#volume-details)
    - [`/config` — Configuration \& Persistence](#config--configuration--persistence)
    - [`/var/lib/collectd/rrd` — RRD Database Storage](#varlibcollectdrrd--rrd-database-storage)
    - [`/run/readsb` — Decoder JSON Input](#runreadsb--decoder-json-input)
  - [Configuration](#configuration)
    - [Common Options](#common-options)
    - [Custom Configuration via Volume Mount](#custom-configuration-via-volume-mount)
  - [Application Setup](#application-setup)
    - [Data Persistence](#data-persistence)
  - [Troubleshooting](#troubleshooting)
    - [No data / empty graphs](#no-data--empty-graphs)
    - [Graphs take time to appear](#graphs-take-time-to-appear)
    - [Port conflict](#port-conflict)
    - [View logs](#view-logs)
    - [Check service status](#check-service-status)
    - [Getting help](#getting-help)
  - [Release \& Versioning](#release--versioning)
  - [Support \& Getting Help](#support--getting-help)
  - [Sponsor \& Credits](#sponsor--credits)
  - [References](#references)
    - [Project Resources](#project-resources)
    - [Upstream \& Related](#upstream--related)
    - [Technical Resources](#technical-resources)
  - [License](#license)

---

## Quick Start

```bash
docker run -d \
  --name=graphs1090 \
  --restart unless-stopped \
  -e TZ=Etc/UTC \
  -e GRAPHS1090_DECODER_DIR=/run/readsb \
  -p 8080:8080 \
  -v graphs1090-config:/config \
  -v collectd-rrd:/var/lib/collectd/rrd \
  -v /path/to/readsb/json:/run/readsb:ro \
  blackoutsecure/graphs1090:latest
```

Access the web UI at `http://<host-ip>:8080/graphs1090/`.

For compose files, balena, and more examples, see [Usage](#usage) below.

---

## Image Availability

**Docker Hub (Recommended):**

- All images published to [Docker Hub](https://hub.docker.com/r/blackoutsecure/graphs1090)
- Simple pull command: `docker pull blackoutsecure/graphs1090:latest`
- Multi-arch support: amd64, arm64
- No registry prefix needed (defaults to Docker Hub)

```bash
# Pull latest
docker pull blackoutsecure/graphs1090

# Pull specific version
docker pull blackoutsecure/graphs1090:1.0.1

# Pull architecture-specific (rarely needed)
docker pull blackoutsecure/graphs1090:latest@amd64
```

---

## About The graphs1090 Application

[graphs1090](https://github.com/wiedehopf/graphs1090) generates performance graphs for readsb / dump1090-fa ADS-B receivers, providing visual insight into signal strength, message rate, aircraft count, range, CPU, and other metrics over time.

Author and maintenance credits (upstream):

- Primary upstream maintainer: [wiedehopf](https://github.com/wiedehopf) (Matthias Wirth)
- Upstream repository and documentation: [wiedehopf/graphs1090](https://github.com/wiedehopf/graphs1090)

---

## Supported Architectures

This image is published as a multi-arch manifest. Pulling `blackoutsecure/graphs1090:latest` retrieves the correct image for your host architecture.

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64-latest |
| arm64 | arm64v8-latest |

---

## Usage

### docker-compose (recommended, [click here for more info](https://docs.linuxserver.io/general/docker-compose))

```yaml
---
services:
  graphs1090:
    image: blackoutsecure/graphs1090:latest
    container_name: graphs1090
    environment:
      - TZ=Etc/UTC
      - GRAPHS1090_DECODER_DIR=/run/readsb
    volumes:
      - config:/config
      - collectd-rrd:/var/lib/collectd/rrd
      - /path/to/readsb/json:/run/readsb:ro
    ports:
      - 8080:8080  # Web UI (HTTP)
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - DAC_OVERRIDE
      - FOWNER
      - SETUID
      - SETGID
    security_opt:
      - no-new-privileges:true
    tmpfs:
      - /tmp
      - /run:exec
    restart: unless-stopped

volumes:
  config:
  collectd-rrd:
```

### docker-compose paired with readsb

```yaml
---
services:
  readsb:
    image: blackoutsecure/readsb:latest
    container_name: readsb
    environment:
      - TZ=Etc/UTC
    volumes:
      - readsb-config:/config
      - readsb-run:/run/readsb
    devices:
      - /dev/bus/usb:/dev/bus/usb
    tmpfs:
      - /tmp
      - /run:exec
    restart: unless-stopped

  graphs1090:
    image: blackoutsecure/graphs1090:latest
    container_name: graphs1090
    environment:
      - TZ=Etc/UTC
      - GRAPHS1090_DECODER_DIR=/run/readsb
    volumes:
      - graphs1090-config:/config
      - collectd-rrd:/var/lib/collectd/rrd
      - readsb-run:/run/readsb:ro
    ports:
      - 8080:8080
    depends_on:
      - readsb
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - DAC_OVERRIDE
      - FOWNER
      - SETUID
      - SETGID
    security_opt:
      - no-new-privileges:true
    tmpfs:
      - /tmp
      - /run:exec
    restart: unless-stopped

volumes:
  readsb-config:
  readsb-run:
  graphs1090-config:
  collectd-rrd:
```

### docker-cli ([click here for more info](https://docs.docker.com/engine/reference/commandline/cli/))

```bash
docker run -d \
  --name=graphs1090 \
  -e TZ=Etc/UTC \
  -e GRAPHS1090_DECODER_DIR=/run/readsb \
  -p 8080:8080 \
  -v /path/to/graphs1090/config:/config \
  -v /path/to/collectd/rrd:/var/lib/collectd/rrd \
  -v /path/to/readsb/json:/run/readsb:ro \
  --restart unless-stopped \
  blackoutsecure/graphs1090:latest
```

### Balena Deployment

This image can be deployed to Balena-powered IoT devices using the included `docker-compose.yml` file (which contains the required Balena labels):

- Balena block listing: [https://hub.balena.io/blocks/2351129/graphs1090](https://hub.balena.io/blocks/2351129/graphs1090)

```bash
balena push <your-app-slug>
```

For deployment via the web interface, use the deploy button in this repository. See [Balena documentation](https://docs.balena.io/) for details.

## Parameters

### Ports

| Parameter | Function |
| :----: | --- |
| `-p 8080:8080` | Web UI (HTTP) |

### Environment Variables

| Parameter | Function | Required |
| :----: | --- | :---: |
| `-e TZ=Etc/UTC` | Timezone ([TZ database](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List)) | Optional |
| `-e GRAPHS1090_DECODER_DIR=/run/readsb` | Path to decoder JSON directory (`stats.json`, `aircraft.json`) | Optional |
| `-e GRAPHS1090_UAT_DIR=` | Path to 978 MHz UAT decoder directory (enables UAT graphs) | Optional |
| `-e GRAPHS1090_PORT=8080` | HTTP port for the web UI | Optional |
| `-e GRAPHS1090_USER=abc` | Runtime user | Optional |
| `-e PUID=911` | User ID for file ownership | Optional |
| `-e PGID=911` | Group ID for file ownership | Optional |

### Storage Mounts

| Parameter | Function | Required |
| :----: | --- | :---: |
| `-v /config` | Persistent configuration | Recommended |
| `-v /var/lib/collectd/rrd` | RRD database storage — preserves graph history across restarts | Recommended |
| `-v /run/readsb` | Decoder JSON input directory (mount read-only) | Required |

---

## Volume Details

The container uses three volumes:

### `/config` — Configuration & Persistence

- **Purpose**: Stores persistent configuration and application state
- **Example**: `-v /path/to/graphs1090/config:/config` or `-v graphs1090-config:/config`

### `/var/lib/collectd/rrd` — RRD Database Storage

- **Purpose**: Preserves graph history (RRD databases) across container restarts
- **Example**: `-v /path/to/collectd/rrd:/var/lib/collectd/rrd` or `-v collectd-rrd:/var/lib/collectd/rrd`

### `/run/readsb` — Decoder JSON Input

- **Purpose**: Read-only mount of the decoder JSON output directory from readsb or dump1090-fa
- **Required files**: `stats.json`, `aircraft.json`
- **Example**: `-v /path/to/readsb/json:/run/readsb:ro`

---

## Configuration

Environment variables are set using `-e` flags in `docker run` or the `environment:` section in docker-compose.

The graphs1090 config file is `/etc/default/graphs1090` inside the container. To customize, either mount a file into the container or edit it via `docker exec`.

### Common Options

| Variable | Default | Description |
| --- | --- | --- |
| `colorscheme` | `default` | Color scheme: `default` or `dark` |
| `range` | `nautical` | Range unit: `nautical`, `statute`, or `metric` |
| `fahrenheit` | `0` | Set to `1` for Fahrenheit |
| `graph_size` | `default` | Graph size: `small`, `default`, `large`, `huge`, `custom` |
| `WWW_TITLE` | `graphs1090` | Browser tab title |
| `WWW_HEADER` | `Performance Graphs` | Page heading |
| `DRAW_INTERVAL` | `60` | Graph redraw interval in seconds |
| `HIDE_SYSTEM` | `no` | Set `yes` to hide system resource graphs |
| `disk` | *(blank)* | Block device for disk I/O graphs (e.g. `mmcblk0`) |
| `ether` | *(blank)* | Network interface for wired stats (e.g. `eth0`) |
| `enable_scatter` | `no` | Enable scatter plot data collection |

All options: [upstream default config](https://github.com/wiedehopf/graphs1090/blob/master/default)

### Custom Configuration via Volume Mount

```yaml
volumes:
  - ./my-graphs1090-config:/etc/default/graphs1090:ro
```

---

## Application Setup

The container runs three services under s6-overlay:

1. **collectd** — polls the decoder's JSON output every 60 seconds via Python plugins and writes metrics to RRD databases
2. **graphs1090** — periodically generates PNG graph images from the RRD data with escalating intervals (1 min, 5 min, 15 min, 60 min depending on graph timespan)
3. **nginx** — serves the HTML interface and graph images

### Data Persistence

During normal operation, collectd writes to `/run/collectd` (memory-backed tmpfs) to minimize disk I/O.

On **container start**, RRD data is restored from `/var/lib/collectd/rrd/localhost.tar.gz` to memory, with a fallback cascade: primary tarball, raw folder, this week's auto-backup, last week's auto-backup, or fresh start.

On **container stop**, RRD data is compressed and written back to disk. A weekly rotating backup is kept automatically with 60-day retention.

---

## Troubleshooting

### No data / empty graphs

1. Verify the decoder JSON directory is mounted and populated:

   ```bash
   docker exec graphs1090 ls -la /run/readsb/
   docker exec graphs1090 head -c 200 /run/readsb/stats.json
   ```

2. If `stats.json` is missing, the decoder container is not providing data. Check that:
   - The readsb/dump1090-fa container is running
   - The shared volume is mounted correctly (not an empty volume)
   - The decoder is writing JSON output

### Graphs take time to appear

Initial data collection takes up to 10 minutes. Graphs with longer timespans (7-day, 30-day) will fill in gradually.

### Port conflict

Map to a different host port:

```bash
docker run ... -p 8081:8080 ...
```

### View logs

```bash
docker logs graphs1090
docker logs graphs1090 --tail 100 -f
```

### Check service status

```bash
docker exec graphs1090 s6-svstat /run/service/svc-collectd
docker exec graphs1090 s6-svstat /run/service/svc-graphs1090
docker exec graphs1090 s6-svstat /run/service/svc-nginx
```

### Getting help

- Check [upstream graphs1090 documentation](https://github.com/wiedehopf/graphs1090)
- Review container logs: `docker logs -f graphs1090`
- Open an issue on [GitHub](https://github.com/blackoutsecure/docker-graphs1090/issues)

---

## Release & Versioning

This project uses [semantic versioning](https://semver.org/):

- Releases published on [GitHub Releases](https://github.com/blackoutsecure/docker-graphs1090/releases)
- Multi-arch images (amd64, arm64v8) built automatically
- Docker Hub tags: version-specific, `latest`, and architecture-specific

**Update to latest:**

```bash
docker pull blackoutsecure/graphs1090:latest
docker-compose up -d  # if using compose
```

**Check image version:**

```bash
docker inspect -f '{{ index .Config.Labels "build_version" }}' blackoutsecure/graphs1090:latest
```

---

## Support & Getting Help

- **Questions:** [GitHub Issues](https://github.com/blackoutsecure/docker-graphs1090/issues)
- **Bug Reports:** Include Docker version, container logs, and reproduction steps
- **Upstream Documentation:** [graphs1090 on GitHub](https://github.com/wiedehopf/graphs1090)

**Get help:**

```bash
docker logs graphs1090                          # View container logs
docker exec -it graphs1090 /bin/bash           # Access container shell
docker inspect blackoutsecure/graphs1090       # Check image details
```

---

## Sponsor & Credits

Sponsored and maintained by [Blackout Secure](https://blackoutsecure.app)

Upstream project: [wiedehopf/graphs1090](https://github.com/wiedehopf/graphs1090)
Container patterns: [LinuxServer.io](https://linuxserver.io/)

---

## References

### Project Resources

| Resource | Link |
| --- | --- |
| **Docker Hub** | [blackoutsecure/graphs1090](https://hub.docker.com/r/blackoutsecure/graphs1090) |
| **GitHub Issues** | [Report bugs or request features](https://github.com/blackoutsecure/docker-graphs1090/issues) |
| **GitHub Releases** | [Download releases](https://github.com/blackoutsecure/docker-graphs1090/releases) |

### Upstream & Related

| Project | Link |
| --- | --- |
| **graphs1090** | [wiedehopf/graphs1090](https://github.com/wiedehopf/graphs1090) |
| **readsb** | [wiedehopf/readsb](https://github.com/wiedehopf/readsb) |
| **LinuxServer.io** | [linuxserver.io](https://linuxserver.io/) |

### Technical Resources

- [ADS-B Overview](https://en.wikipedia.org/wiki/Automatic_Dependent_Surveillance%E2%80%93Broadcast)
- [Docker Documentation](https://docs.docker.com/)
- [RRDtool Documentation](https://oss.oetiker.ch/rrdtool/)

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

The upstream graphs1090 application is also MIT licensed. For more information, see the [graphs1090 repository](https://github.com/wiedehopf/graphs1090).

---

*Made with confidence by [Blackout Secure](https://blackoutsecure.app)*
