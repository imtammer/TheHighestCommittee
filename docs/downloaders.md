# Downloaders & Trackers Configuration

## Slskd (`slskd/slskd`)
| Variable | Description | Default |
|----------|-------------|---------|
| `SLSKD_REMOTE_CONFIGURATION` | Enable web UI config editing | `false` |
| `SLSKD_SHARED_DIR` | Directories to share (semicolon separated) | - |
| `SLSKD_UPLOAD_SLOTS` | Upload slot count | - |
| `SLSKD_NO_AUTH` | Disable authentication | `false` |

## Ryot (`ignisda/ryot`)
| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | Postgres connection string |
| `SERVER_ADMIN_ACCESS_TOKEN` | Admin token |
| `SERVER_IMPORTER_TRAKT_CLIENT_ID` | Trakt ID |

## Watcharr (`ghcr.io/sbondco/watcharr`)
**Config:** SQLite database by default.
**Env Vars:** `TZ`, `PUID`, `PGID`.

## Agregarr (`agregarr/agregarr`)
- Standard LSIO-style variables (`PUID`, `PGID`, `TZ`).

## Maintainerr (`ghcr.io/maintainerr/maintainerr`)
- **Web UI:** most config done in UI.
- **Env Vars:** `TZ`.

## Cleanuparr (`ghcr.io/cleanuparr/cleanuparr`)
| Variable | Description |
|----------|-------------|
| `PORT` | Listening port (default 11011) |
| `PUID` / `PGID` / `UMASK` / `TZ` | Standard permissions |
