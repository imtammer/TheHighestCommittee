# Operations Log: Appdata Migration & Standardization

This document records the steps taken during the migration and troubleshooting session starting on 2026-02-12.

## 2026-02-12 05:30 UTC - Initialization
- **Objective**: Migrate appdata from `/opt/stacks/arrstack/appdata/` to stack-specific `./appdata/` directories and standardize `compose.yaml` files.

## Phase 1: Compose Path Standardization
- **Action**: Updated all `compose.yaml` volume paths in 12 stacks from absolute or non-standard paths to the relative `./appdata/servicename/` pattern.
- **Affected Stacks**: `arrstack`, `gameservers`, `arr_support`, `music`, `discord_bots`, `comics_and_manga`, `emulators`, `books`, `utilities`.
- **Method**: Direct edit of `compose.yaml` files.

## Phase 2: Data Relocation
- **Action**: Moved data folders from `/opt/stacks/arrstack/appdata/` to their respective stack directories.
- **Specific Moves**:
    - `tunarr` → `/opt/stacks/arr_support/appdata/`
    - `muse`, `discodrome`, `manuel-rw` → `/opt/stacks/discord_bots/appdata/`
    - `sonobarr` → `/opt/stacks/music/appdata/`
    - `slskd` → `/opt/stacks/music/appdata/` (Symlink maintained to NAS)
    - `kapowarr` → `/opt/stacks/comics_and_manga/appdata/` (Symlink to NAS)
    - `romm` → `/opt/stacks/emulators/appdata/` (Symlink to NAS)
    - `mealie` → `/opt/stacks/cooking/appdata/`
    - `flaresolverr` → `/opt/stacks/utilities/appdata/`
- **Cleanup**: Removed old copies from `/opt/stacks/arrstack/appdata/` AFTER verification.

## Phase 3: Troubleshooting & Standardization
- **Image Updates**: Standardized `radarr`, `prowlarr` to `lscr.io/linuxserver` stable branches.
- **ID Standardization**: Verified and ensured all services in `arrstack` use `PUID=1000` and `PGID=1000` to match the `ubuntu` host user.
- **Lock Clearing**: Deleted stale `.pid` files in `appdata/radarr/config` and `appdata/prowlarr/config`.
- **Global PUID/PGID Verification**: Audited `.env` and `compose.yaml` files across all stacks to ensure consistent use of UID/GID 1000.
- **System Blockers**:
    - Identified a **Pending Host Reboot** (confirmed by `dmesg` and `reboot-required`).
    - Identified **ZFS ACL** visibility issues on the Truenas mount (`/media/storage/truenas/downloads`).

## Pending Actions
- [ ] Reboot host to clear IO hangs.
- [ ] Refresh ZFS ACLs for Sonarr import permissions.
- [ ] Decide on 12 orphaned folders in `/opt/stacks/arrstack/appdata/` (e.g., `authentik`, `ollama`).
