# Zurg Configuration

**Core Config:** `config.yml` (Required)
**Environment Variables:** Docker-level overrides

## Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `RD_API_KEY` | Real-Debrid API Token (Alternative to `config.yml`) | - |
| `ZURG_ENABLED` | Enable Zurg service | `true` |
| `ZURG_LOG_LEVEL` | Log verbosity (`DEBUG`, `INFO`, `WARN`) | `INFO` |
| `ZURG_UPDATE` | Auto-update Zurg binary on restart | `false` |
| `ZURG_USER` | Basic Auth Username | - |
| `ZURG_PASS` | Basic Auth Password | - |
| `ZURG_PORT` | Listening Port | `9999` |
| `PUID` / `PGID` | User/Group ID for permissions | `1000` |
| `TZ` | Timezone | `UTC` |

## Config File (`config.yml`)
Key parameters:
```yaml
zurg: v1
token: "YOUR_RD_TOKEN"
host: "0.0.0.0"
port: 9999
concurrent_workers: 8
check_for_changes_every_secs: 10
ignore_renames: true
retain_rd_torrent_name: true
```

## Resources
- [GitHub Repository](https://github.com/debridmediamanager/zurg-testing)
