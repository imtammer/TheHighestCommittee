# LinuxServer.io Containers (The Arrs)

This documentation applies to: **Sonarr, Radarr, Lidarr, Readarr, Prowlarr, Bazarr, Jellyfin, etc.** (images by `linuxserver.io`)

## Common Environment Variables
These variables are standard across almost all LSIO images.

| Variable | Description | Default | Recommended |
|----------|-------------|---------|-------------|
| `PUID` | Process User ID | `911` | `1000` (tammer) |
| `PGID` | Process Group ID | `911` | `1000` (tammer) |
| `TZ` | Timezone | - | `America/Los_Angeles` |
| `UMASK` | File creation mask | `022` | `022` |

## Application Specifics

### Sonarr / Radarr / Lidarr / Readarr / Prowlarr
| Variable | Description |
|----------|-------------|
| `DOCKER_MODS` | Install additional mods (e.g. `linuxserver/mods:universal-package-install`) |
| `Item naming` | Handled via UI, not env vars |

### Jellyfin
| Variable | Description |
|----------|-------------|
| `JELLYFIN_PublishedServerUrl` | For auto-discovery (e.g., `http://jellyfin.domain.com`) |
| `DOCKER_MODS` | Hardware acceleration mods often needed here |

### Bazarr
| Variable | Description |
|----------|-------------|
| `DOCKER_MODS` | N/A usually |

## Resources
- [LinuxServer.io Fleet](https://fleet.linuxserver.io/)
- [Docker Hub Profile](https://hub.docker.com/u/linuxserver)
