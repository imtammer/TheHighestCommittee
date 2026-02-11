# Paperless-ngx Configuration

**Core Config:** Environment Variables

## Environment Variables
| Variable | Description | Recommended |
|----------|-------------|-------------|
| `PAPERLESS_URL` | Full public URL (e.g. `https://paperless.domain.com`) | Required for CSRF |
| `PAPERLESS_SECRET_KEY` | Random string for sessions | **CHANGE ME** |
| `PAPERLESS_TIME_ZONE` | Timezone | `America/Los_Angeles` |
| `PAPERLESS_OCR_LANGUAGE` | Default OCR language | `eng` |
| `PAPERLESS_REDIS` | Redis connection string | `redis://broker:6379` |
| `PAPERLESS_ADMIN_USER` | Initial admin user (create only) | - |
| `PAPERLESS_ADMIN_PASSWORD` | Initial admin password | - |

## User/Permissions
| Variable | Description | Default |
|----------|-------------|---------|
| `USERMAP_UID` | User ID for file permissions | `1000` |
| `USERMAP_GID` | Group ID for file permissions | `1000` |

## Resources
- [Configuration Documentation](https://docs.paperless-ngx.com/configuration/)
- [Docker Hub](https://hub.docker.com/r/paperless-ngx/paperless-ngx)
