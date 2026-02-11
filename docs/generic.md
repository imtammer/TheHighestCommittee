# General Container Configuration

Most containers in this homelab follow standard configuration patterns.

## Common Variables
| Variable | Description | Common Default |
|----------|-------------|----------------|
| `PUID` | User ID (tammer) | `1000` |
| `PGID` | Group ID | `1000` |
| `TZ` | Timezone | `America/Los_Angeles` |
| `LOG_LEVEL` | Logging verbosity | `info` |

## Resources
- **LSIO Containers:** [Fleet](https://fleet.linuxserver.io/)
- **Docker Hub:** Search for specific image tags
- **GitHub:** Check repository `README.md` for specific env vars
