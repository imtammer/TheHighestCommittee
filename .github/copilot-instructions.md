Purpose
-------
This file gives concise, actionable guidance for AI coding agents working in this mono-repo of Docker-compose stacks. It focuses on the repository's structure, service boundaries, common commands, and repository-specific conventions you should follow when making changes.

**Big picture**
- **Architecture:** The repo organizes multiple service stacks as separate folders (each with a single `compose.yaml`). Examples: [books/compose.yaml](books/compose.yaml) and [arrstack/compose.yaml](arrstack/compose.yaml).
- **Persistent data:** Service configuration and persistent state live under `appdata/<service>/` (for example, [appdata/jellyfin/config](appdata/jellyfin/config)). Compose files mount these directories as volumes — treat `appdata` as the authoritative state for services.

**Key locations to inspect**
- Root stacks: `arr_support/`, `arrstack/`, `books/`, `gameservers/`, `music/`, etc. Each contains a `compose.yaml` that defines that stack.
- Shared data: `appdata/` holds per-service config and data subfolders. Use these paths when adding volumes or migrating data.

**Common developer workflows (commands)**
- Start a stack: `docker compose -f <stack-folder>/compose.yaml up -d` — e.g. `docker compose -f books/compose.yaml up -d`.
- Rebuild a service: `docker compose -f <stack>/compose.yaml up --build -d <service>`.
- View logs: `docker compose -f <stack>/compose.yaml logs -f <service>`.
- Exec into a container: `docker compose -f <stack>/compose.yaml exec <service> /bin/sh` (or `/bin/bash`).
- Check status: `docker compose -f <stack>/compose.yaml ps`.

**Project-specific conventions**
- Single compose file per stack named `compose.yaml` (not docker-compose.yaml). Follow existing compose files for service naming and labels.
- Persist service state under `appdata/<service>/` — do not store runtime state elsewhere.
- When adding services, mirror the folder grouping convention (create a folder in the root with a `compose.yaml`). Reference appdata volumes relative to the repository root.

**Integration points & patterns**
- Services integrate via Docker networking defined in each compose file; check existing compose files for network names before creating new ones.
- If the project uses a reverse-proxy or common labels (look in `arr_support/` or top-level compose files), copy label patterns for host, entrypoints, and TLS. Use consistent label keys.
- External dependencies (databases, redis, mariadb) are often defined as separate services in their stack compose files — prefer connecting via service name and Docker network rather than hardcoded IPs.

**Stack-specific patterns**

**arrstack/** — Media management stack (Sonarr, Radarr, Lidarr, Prowlarr, Jellyseerr, Overseerr, Bazarr, etc.)
- Core "arr" services share a consistent volume mount pattern: config under `appdata/<service>/config`, media libraries mounted from `/media/storage/` (e.g., `/media/storage/truenas/tv/`, `/media/storage/ugreen/movies/`).
- Example service: `sonarr` (lines 1–16 in compose.yaml)—note standard PUID/PGID/TZ environment variables, port mapping, and multi-source volume mounts.
- Inter-service communication: Sonarr connects to Prowlarr for indexers; Overseerr to Sonarr/Radarr; Bazarr for subtitle management. All services are on the default bridge network.

**arr_support/** — Helper services for arrstack (SuggestArr, Tunarr, Huntarr, Cleanuparr, Maintainerr, DAPS, etc.)
- Lighter-weight services with environment variable overrides (e.g., `${SUGGESTARR_PORT:-5000}`).
- `cleanuparr` includes health checks (lines ~50–57 in compose.yaml)—use this pattern for services requiring startup verification.
- Example: `maintainerr` uses named volumes with `type: bind` syntax for explicit source→target mapping.

**books/** — Reading stack (Audiobookshelf, Kavita, Readarr, OpenBooks, ABR, ShelfMark, BookLore)
- Similar to arrstack but for books/audio; mixes `/media/storage/truenas/` (NAS-mounted) and `/media/storage/ugreen/` (local storage).
- Example: `kavita` reads from three libraries: `/manga`, `/comics`, `/books` and stores config in `/opt/stacks/arrstack/appdata/kavita/config`.
- Note: Some services (e.g., `openbooks`) use `hostname` and `restart: on-failure:5` for resilience.

**music/** — Music management stack (Navidrome, Lidify, Sonobarr, Blissful, SLSKD)
- Simpler stacks often use direct API keys in environment variables.
- Example: `blissful` (lines ~44–60 in compose.yaml) demonstrates hardcoded external URLs and API keys for Lidarr, Jellyfin, and Plex integration—review and secure before deploying.
- JSON logging: use `logging` driver with max-size/max-file for rotation.

**TamMediaBox/** — Remote media serving (Plex, Jellyfin, mstream, dozzle-agent)
- **Location:** 192.168.0.13 | `/opt/stacks/TamMediaBox/compose.yaml`
- **Plex** (plexinc/pms-docker:plexpass) — Primary media server with GPU transcoding
  - Network: host mode (for LAN discovery) | Port: 32400/tcp
  - GPU: NVIDIA (`NVIDIA_VISIBLE_DEVICES=all`) mapped to `/dev/dri:/dev/dri`
  - Volumes: Config, TV, movies, anime, sports, music (all from NAS/uGreen storage)
  - Requires `PLEX_CLAIM` token for init (stored in `.env`)
- **Jellyfin** (jellyfin/jellyfin) — Alternative open-source media server
  - Ports: 8096/tcp, 7359/udp | User: 1000:1000 | Group: 991 (GPU access)
  - GPU: Intel/AMD (`/dev/dri/renderD128`)
  - Volumes: Config (local), cache (cross-mounted from primary), multi-library mounts
  - URL: jellyfin.thehighestcommittee.com
- **mstream** (lscr.io/linuxserver/mstream:latest) — Web music streaming
  - Port: 3000 | Config cross-mounted from primary appdata
- **dozzle-agent** (amir20/dozzle:latest) — Remote Docker monitoring
  - Mode: `agent` | Port: 7007 | Integrates with primary host's Dozzle dashboard
- **Storage:** All services mount `/media/storage/truenas/` (NAS) and `/media/storage/ugreen/` (local SSD)
- **Cross-host mounts:** Jellyfin cache, mstream config sourced from primary via `/opt/stacks/arrstack/appdata/`
- **Environment:** `.env` includes PLEX_CLAIM, GPU settings, media library paths, PUID/PGID/TZ

**bots/** — Discord bot integration stacks (manuel-rw, muse, discodrome)
- Services communicate with external APIs (Discord, YouTube, Spotify, Subsonic) via embedded credentials in environment.
- All store state data in `/opt/stacks/arrstack/appdata/<service>/data`.
- Example: `discodrome` (lines ~17–34 in compose.yaml) connects to Navidrome music server with embedded credentials—never commit these to version control.

**comics_and_manga/** — Comic and manga management (Kapowarr, Suwayomi, Mylar3)
- Downloads stored in `/media/storage/truenas/downloads/complete/comics/` or `/manga/`; libraries in `/media/storage/truenas/`.
- `suwayomi` uses FlareSolverr integration (`FLARESOLVERR_URL`) to bypass anti-bot protections.
- Service databases stored on faster storage: `/media/storage/ugreen/arrstack/appdata/<service>-db/`.

**emulators/** — ROM manager (RoMM) with metadata providers
- RoMM requires a MariaDB backend; always use `depends_on` with `service_healthy` condition.
- Multiple storage paths: resources in `ugreen`, ROM library in `truenas`, metadata providers (ScreenScraper, RetroAchievements, SteamGridDB) via API keys.
- Example: `romm-db` includes health checks (CMD healthcheck.sh) for startup verification.

**gameservers/** — Multiplayer game servers (Enshrouded, Satisfactory, PalWorld, ARK Survival Ascended)
- Game servers require high memory allocation (set `deploy.resources.limits.memory` for Satisfactory).
- Long graceful shutdown periods: `stop_grace_period: 90s` for Enshrouded, `30s` for PalWorld.
- State stored in `appdata/<service>`, with ports exposed as UDP/TCP depending on game (e.g., PalWorld uses UDP 8211).

**reporting/** — Monitoring/analytics stacks (Tautulli, Notifiarr)
- Lightweight services requiring only config mount and minimal resources.
- Example: `tautulli` tracks Plex/Jellyfin usage; `notifiarr` handles notifications via config.
- System integration: `notifiarr` mounts `/var/run/utmp` and `/etc/machine-id` for host awareness.

**security/** — Authentication services (Pocket-ID) - managed via Dockhand
- **Location:** `/opt/stacks/arrstack/appdata/dockhand/data/stacks/security/`
- **Pocket-ID** (ghcr.io/pocket-id/pocket-id:v2) — OIDC provider with passkey authentication
  - Port: 1411 | External URL: auth.thehighestcommittee.com
  - Data: `/opt/stacks/arrstack/appdata/pocket-id/data/` (SQLite DB, uploads)
  - **Requires HTTPS** for secure cookie authentication - must access via external domain
  - Key env vars: `APP_URL`, `ENCRYPTION_KEY` (generate with `openssl rand -base64 32`), `TRUST_PROXY=true`
  - CLI: `docker exec security-pocket-id-1 /app/pocket-id one-time-access-token <username>` for login tokens
  - Note: Passkey-only authentication, no password support

**AI_Docker_Host/** — Machine learning and AI services (Ollama, Open-WebUI, Whisper-ASR, Subgen, Paperless-NGX, Paperless-AI)
- **Location:** 192.168.0.7 | Three stacks: `ollama/`, `utilities/`, `paperless/`
- **ollama/** — LLM inference and speech-to-text stack
  - `ollama` runs local language models with NVIDIA GPU acceleration (LLaMA2, Mistral, etc.)
  - `open-webui` provides web chat interface connecting to ollama via `http://ollama:11434`
  - `whisper-asr` transcribes audio to text (GPU-enabled, supports concurrent transcriptions)
  - `subgen` generates AI subtitles for Plex media; connects back to TamMediaBox Plex via PLEXTOKEN and PLEXSERVER environment variables
  - All services use `ai` bridge network for internal communication; GPU reservations ensure NVIDIA access
- **utilities/** — Monitoring agent for remote host
  - `dozzle-agent` (port 7007) connects to primary host's Dozzle dashboard for centralized Docker monitoring
- **paperless/** — Document management and AI document processing
  - `broker` (Redis) manages task queue and caching for document processing
  - `webserver` (Paperless-NGX) ingests documents from `/media/storage/ugreen/documents_consume/`, applies OCR, stores in `/media/storage/ugreen/documents/`
  - `paperless-ai` enhances documents with AI-powered classification, entity extraction, and summarization
  - Document workflow: consume folder (intake) → OCR/indexing → storage → AI enhancement for search/retrieval
- **GPU Requirements:** All AI services expect NVIDIA GPU (8GB+ recommended); subgen and whisper-asr run on same GPU instance for load management
- **Storage Pattern:** Model weights in `appdata/ollama/`, document data in `/media/storage/ugreen/documents/`
- **Cross-host Integration:** subgen reaches back to Plex on 192.168.0.13 for media access; dozzle-agent reports to primary host (192.168.0.11)

**utilities/** — Helper/UI services (Termix, Dozzle, FlareSolverr, Homarr, Homepage, Newt)
- Dashboard/logging tools often mount `docker.sock` for container introspection (read-only: `:ro`).
- FlareSolverr and other services use `.env` for port/logging configuration: `${PORT:-8191}` syntax.
- External network references: `dockge_default` is an external Docker network; use `external: true` and reference by name.
- Example: `homepage` mounts both socket and config; `newt` uses external Pangolin endpoint for integrations.

**Common volume patterns**
```yaml
# Pattern 1: Config + external library (most common)
volumes:
  - /opt/stacks/arrstack/appdata/<service>/config:/config
  - /media/storage/truenas/<library>:/<library>
  - /media/storage/ugreen/<library>:/<library>

# Pattern 2: Multiple config subdirectories
volumes:
  - /opt/stacks/arrstack/appdata/<service>/config:/config
  - /opt/stacks/arrstack/appdata/<service>/metadata:/metadata

# Pattern 3: Explicit bind mounts (maintainerr style)
volumes:
  - type: bind
    source: /opt/stacks/arrstack/appdata/<service>/data
    target: /opt/data

# Pattern 4: Environment-sourced volumes (tunarr style)
volumes:
  - /media/storage/ugreen/arrstack/appdata/<service>/data:/config/data
```

**Common environment patterns**
```yaml
# Standard PUID/PGID/TZ (used across 90% of services)
environment:
  - PUID=1000
  - PGID=1000
  - TZ=America/Los_Angeles
  - UMASK=022

# External API keys (arr_support stacks)
environment:
  - SUGGESTARR_TMDB_API_KEY=<key>
  - SUGGESTARR_OVERSEERR_URL=http://192.168.0.11:5055
  - SUGGESTARR_OVERSEERR_API_KEY=<key>

# Environment file override (sonobarr style)
env_file:
  - .env

# Environment variable substitution with defaults (utilities stack)
environment:
  - LOG_LEVEL=${LOG_LEVEL:-info}
  - PORT=${PORT:-8191}
  - CAPTCHA_SOLVER=${CAPTCHA_SOLVER:-none}
```
**Secret & Sensitive Data Policy**
- All secrets, tokens, API keys, passwords, usernames, hostnames, and private/internal IPs must be replaced with variables (e.g., `${VAR_NAME}`) or clear placeholders (e.g., `changeme`, `<key>`, `<password>`) in all files committed to the repository.
- Never commit real secrets, tokens, or private/internal IPs in any form (including .env, compose.yaml, scripts, or documentation).
- `.env` files store real sensitive data and must be excluded from version control via `.gitignore`. Use `.env.example` with only placeholder values for documentation and onboarding.
- Services reference `.env` variables with `${VAR_NAME}` in compose.yaml or via `env_file:` directive.
- Example: `${LOG_LEVEL:-info}` falls back to `info` if `LOG_LEVEL` is not set in `.env`.
- Common `.env` variables across stacks:
  ```env
  PUID=1000
  PGID=1000
  TZ=America/Los_Angeles
  LOG_LEVEL=info
  PORT=8191
  SUGGESTARR_PORT=5000
  TUNARR_SERVER_PORT=8888
  ```
- All sensitive keys (Discord tokens, API keys, database passwords, etc.) must be referenced via variables and never hardcoded in any committed file.

**System-wide .env commonalities** — Move these to root `.env` to centralize and DRY up configuration:
```env
# User/permissions (universal across all services)
PUID=1000
PGID=1000
TZ=America/Los_Angeles
UMASK=022
LOG_LEVEL=info

# Infrastructure Hosts
PRIMARY_DOCKER_HOST=192.168.0.11         # Primary Docker host (arr stacks, media managers)
LOCAL_IP=192.168.0.11                     # Alias for primary host
MEDIABOX_IP=192.168.0.13                  # TamMediaBox - Jellyfin, Dozzle, media containers
AI_DOCKER_HOST=192.168.0.7                # AI services and model hosting
DOMAIN_NAME=thehighestcommittee.com

# Shared passwords & credentials (database, admin, service auth)
DB_ROOT_PASSWORD=<secure-password>
DB_USER_PASSWORD=<secure-password>
SHARED_SERVICE_PASSWORD=<secure-password>
ADMIN_PASSWORD=<secure-password>

# External service URLs (referenced by multiple stacks)
OVERSEERR_URL=http://${LOCAL_IP}:5055
OVERSEERR_API_KEY=<key>
JELLYFIN_SERVER=http://${MEDIABOX_IP}:8096    # Jellyfin on TamMediaBox
JELLYFIN_URL=https://${DOMAIN_NAME}
JELLYFIN_API_KEY=<key>
NAVIDROME_URL=http://${LOCAL_IP}:4533
LIDARR_URL=http://${LOCAL_IP}:8686
LIDARR_API_KEY=<key>
FLARESOLVERR_URL=http://${LOCAL_IP}:8191

# API keys & external integrations (sensitive - DO NOT commit)
TMDB_API_KEY=<key>
YOUTUBE_API_KEY=<key>
SPOTIFY_CLIENT_ID=<id>
SPOTIFY_CLIENT_SECRET=<secret>
DISCORD_TOKEN=<token>
SCREENSCRAPER_USER=<user>
SCREENSCRAPER_PASSWORD=<password>
RETROACHIEVEMENTS_API_KEY=<key>
STEAMGRIDDB_API_KEY=<key>

# Port overrides (for services with flexible port binding)
PORT=8191
SUGGESTARR_PORT=5000
TUNARR_SERVER_PORT=8888
```

**Applying system-wide .env:**
1. Create `/opt/stacks/.env` with values above.
2. Add `.env` to `.gitignore`.
3. Reference variables in compose files: `${PUID}`, `${TZ}`, `${JELLYFIN_API_KEY}`, etc.
4. Services already using `env_file: - .env` will inherit all variables automatically.
5. For services not yet using `env_file`, add it (example: `arr_support/compose.yaml` already does this for `sonobarr`).

**Migration roadmap (prioritized):**
1. **High Impact**: Consolidate PUID, PGID, TZ, UMASK, LOCAL_IP, REMOTE_IP, DOMAIN_NAME (eliminates 50+ hardcoded lines)
2. **Medium Impact**: Replace hardcoded IPs (`192.168.0.11`, `192.168.0.13`) and domain with variables across all compose files
3. **Medium Impact**: Add `env_file: - .env` directive to 7 stacks not using it (arrstack, books, bots, comics_and_manga, emulators, gameservers, reporting)
4. **Security**: Move all Discord tokens, YouTube/Spotify/TMDB keys, ScreenScraper/RetroAchievements/SteamGridDB credentials to `.env` placeholders

**Examples to follow**
- Add a new service to `arrstack/compose.yaml`: copy the `sonarr` service block, update image, container_name, config path under `appdata/<new-service>/config/`, mount relevant media libraries.
- Add a new stack: create a folder (e.g., `streaming/`) with `compose.yaml`, mirror the pattern from `books/compose.yaml`, reference appdata volumes as `/opt/stacks/arrstack/appdata/<service>/`.
- Debugging a service: `docker compose -f <stack>/compose.yaml logs -f <service>` → inspect `/opt/stacks/arrstack/appdata/<service>/config/` for errors or missing `.db` files.
- Health checks: if a service needs startup verification, add `healthcheck` block (see `cleanuparr` or `jellyseerr`).

**Homepage Dashboard Icons**
- **Icon source**: [selfhst/icons](https://github.com/selfhst/icons) via jsDelivr CDN
- **Configuration**: `/opt/stacks/arrstack/appdata/homepage/config/services.yaml`
- **SVG format**: `https://cdn.jsdelivr.net/gh/selfhst/icons/svg/{reference}.svg`
- **PNG format**: `https://cdn.jsdelivr.net/gh/selfhst/icons/png/{reference}.png`
- **Fallback**: Use `mdi-{icon-name}` for Material Design Icons when selfhst doesn't have the service
- **Check availability**: Not all icons have SVG versions; check index.json for SVG=Yes/No before using
- **Icon index**: `https://raw.githubusercontent.com/selfhst/icons/main/index.json`

Example icon references (services.yaml):
```yaml
# SVG available
icon: https://cdn.jsdelivr.net/gh/selfhst/icons/svg/sonarr.svg
icon: https://cdn.jsdelivr.net/gh/selfhst/icons/svg/plex.svg
icon: https://cdn.jsdelivr.net/gh/selfhst/icons/svg/jellyfin.svg

# PNG only (no SVG)
icon: https://cdn.jsdelivr.net/gh/selfhst/icons/png/mylar3.png
icon: https://cdn.jsdelivr.net/gh/selfhst/icons/png/huntarr.png
icon: https://cdn.jsdelivr.net/gh/selfhst/icons/png/tunarr.png

# MDI fallback (service not in selfhst/icons)
icon: mdi-server
```
