# Utilities Configuration

## Homepage (`ghcr.io/gethomepage/homepage`)
**Config:** `config/` directory (services.yaml, widgets.yaml).
**Environment Variables:**
| Variable | Description |
|----------|-------------|
| `HOMEPAGE_CONFIG_DIR` | Config path |
| `HOMEPAGE_VAR_NAME` | Inject vars into yaml (e.g. `HOMEPAGE_VAR_API_KEY=xyz`) |

## Dozzle (`amir20/dozzle`)
| Variable | Description |
|----------|-------------|
| `DOZZLE_LEVEL` | Log level |
| `DOZZLE_TAIL` | Initial lines to show |
| `DOZZLE_REMOTE_AGENT` | Connect to remote agent (ip:port) |

## Tautulli (`lscr.io/linuxserver/tautulli`)
- Standard LSIO variables (`PUID`, `PGID`, `TZ`).

## Notifiarr (`golift/notifiarr`)
| Variable | Description |
|----------|-------------|
| `DN_API_KEY` | Notifiarr API Key |
| `DN_PORT` | Listening port (default 5454) |

## FlareSolverr (`ghcr.io/flaresolverr/flaresolverr`)
| Variable | Description | Default |
|----------|-------------|---------|
| `LOG_LEVEL` | info, debug, none | `info` |
| `CAPTCHA_SOLVER` | none, hcaptcha-solver | `none` |
| `TZ` | Timezone | - |
