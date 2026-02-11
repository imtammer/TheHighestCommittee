# Rclone Configuration

**Core Config:** `rclone.conf` (or via Env Vars)
**Environment Variables:** Docker-level overrides

## Environment Variables
Rclone allows setting config options via environment variables using the `RCLONE_CONFIG_` prefix.

### Format
`RCLONE_CONFIG_<REMOTE_NAME>_<PARAMETER>`

### Examples
If your remote is named `realdebrid`:
| Variable | Description |
|----------|-------------|
| `RCLONE_CONFIG_REALDEBRID_TYPE` | Type of remote (e.g., `webdav`) |
| `RCLONE_CONFIG_REALDEBRID_URL` | URL for the remote |
| `RCLONE_CONFIG_REALDEBRID_VENDOR` | Vendor name (e.g., `realdebrid`) |
| `RCLONE_CONFIG_REALDEBRID_USER` | Username |
| `RCLONE_CONFIG_REALDEBRID_PASS` | Password (obfuscated) |

### Global Flags
Any global flag can be set via env vars:
| Variable | Flag Equivalent | Description |
|----------|----------------|-------------|
| `RCLONE_VERBOSE` | `-v` | Verbosity (0-2) |
| `RCLONE_LOG_LEVEL` | `--log-level` | `DEBUG`, `INFO`, `NOTICE`, `ERROR` |
| `RCLONE_CONFIG` | `--config` | Path to config file |
| `RCLONE_CACHE_DIR` | `--cache-dir` | Path to cache directory |
| `TZ` | - | Timezone |
| `PUID` / `PGID` | - | User/Group ID |

## Resources
- [Official Docs: Environment Variables](https://rclone.org/docs/#environment-variables)
- [DockerHub](https://hub.docker.com/r/rclone/rclone)
