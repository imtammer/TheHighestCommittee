# Media Servers Configuration

## Plex (`plexinc/pms-docker`)
| Variable | Description |
|----------|-------------|
| `PLEX_CLAIM` | Claim token (https://plex.tv/claim) |
| `ADVERTISE_IP` | Custom server access URLs |
| `ALLOWED_NETWORKS` | CIDR networks allowed without auth |
| `PLEX_UID` / `PLEX_GID` | User/Group ID |

## Jellyfin (`jellyfin/jellyfin`)
| Variable | Description |
|----------|-------------|
| `JELLYFIN_PublishedServerUrl` | Autodiscovery URL |
| `JELLYFIN_CACHE_DIR` | Cache location override |

## Navidrome (`deluan/navidrome`)
| Variable | Description | Default |
|----------|-------------|---------|
| `ND_SCANSCHEDULE` | Scan interval | `1h` |
| `ND_LOGLEVEL` | Log verbosity | `info` |
| `ND_MUSICFOLDER` | Music path | `/music` |
| `ND_BASEURL` | Base URL path | - |

## Lidify (`chevron7locked/lidify`)
- **Config:** Connects Navidrome play counts to Lidarr.
- **Env Vars:** `LIDARR_URL`, `LIDARR_API_KEY`, `NAVIDROME_URL`, `NAVIDROME_USER`, `NAVIDROME_SALT`, `NAVIDROME_TOKEN`.

## Mstream (`lscr.io/linuxserver/mstream`)
- **Config:** Standard LSIO variables (`PUID`, `PGID`, `TZ`).
