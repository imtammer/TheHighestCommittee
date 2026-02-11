# Changelog

## [Unreleased]

### Added
- **Data Migration**: Decoupled `appdata` from `arrstack`. All stacks now use self-contained `./appdata` directories.
  - Migrated `utilities`, `books`, `music`, `gameservers`, `reporting`, `trackers`, `comics`, `cooking`.
  - Updated `compose.yaml` files to use relative paths.
- **Security**:
  - Removed deprecated Authelia configuration.
  - Hardened Docker socket mounts (RO where possible).
  - Audited port exposures.
- **Documentation**:
  - Overhauled `README.md` with new structure, hardware specs, and service directory.
  - Created `SECURITY_AUDIT.md`.
  - Updated `INFRASTRUCTURE.md` and `OPERATIONS.md`.

## [2026-02-04]
- Initial documentation overhaul start.
