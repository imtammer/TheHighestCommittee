# Gaming & Books Configuration

## Audiobookshelf (`ghcr.io/advplyr/audiobookshelf`)
| Variable | Description | Default |
|----------|-------------|---------|
| `CONFIG_PATH` | Config directory | `/config` |
| `METADATA_PATH` | Metadata directory | `/metadata` |
| `TZ` | Timezone | - |
| `PUID` / `PGID` | User/Group ID | - |

## Kavita (`ghcr.io/kareadita/kavita`)
- Standard LSIO variables (`PUID`, `PGID`, `TZ`).
- **Port:** 5000.

## Readarr / Listenarr (`ghcr.io/pennydreadful/bookshelf`)
This image is a Readarr fork/variant.
| Variable | Description |
|----------|-------------|
| `METADATA_URL` | Self-hosted metadata server URL (optional) |
| `hardcover-auth` | Auth for Hardcover metadata provider |
- Takes standard LSIO variables (`PUID`, `PGID`, `TZ`) as it is based on Readarr.

## Romm (`rommapp/romm`)
| Variable | Description |
|----------|-------------|
| `DB_HOST` / `DB_NAME` / `DB_USER` / `DB_PASSWD` | Database connection |
| `ROMM_AUTH_SECRET_KEY` | Secret key (openssl rand -hex 32) |
| `SCREENSCRAPER_USER` / `PASSWORD` | Metadata provider creds |
| `STEAMGRIDDB_API_KEY` | SteamGridDB API key |

## Mealie (`ghcr.io/mealie-recipes/mealie`)
| Variable | Description |
|----------|-------------|
| `BASE_URL` | Public URL |
| `ALLOW_SIGNUP` | Enable/Disable signup (`true`/`false`) |
| `SMTP_HOST` / `PORT` / `USER` / `PASSWORD` | Email settings |
| `DB_ENGINE` | `postgres` or `sqlite` |

## Game Servers
### Enshrouded (`mornedhels/enshrouded-server`)
- `SERVER_NAME`, `SERVER_PASSWORD`, `UPDATE_CRON`.
### Palworld (`thijsvanloef/palworld-server-docker`)
- `PLAYERS`, `PORT`, `SERVER_PASSWORD`, `ADMIN_PASSWORD`.
### ARK: SA (`acekorneya/asa_server`)
- `SESSION_NAME`, `MaxPlayers`, `SERVER_ADMIN_PASSWORD`.
### Satisfactory (`wolveix/satisfactory-server`)
- `MAXPLAYERS`, `STEAMBETA` (`true`/`false`).
