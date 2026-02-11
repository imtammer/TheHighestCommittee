# 🔐 Complete Credentials & API Keys Reference

**Environment:** TheHighestCommittee Homelab
**Last Updated:** 2026-02-04
**WARNING:** This file contains sensitive credentials. Keep secure.

---

## 📋 Table of Contents

1. [Common Passwords](#common-passwords)
2. [Infrastructure Access](#infrastructure-access)
3. [Database Credentials](#database-credentials)
4. [Media Services](#media-services)
5. [Arr Stack (Sonarr, Radarr, etc.)](#arr-stack)
6. [Download Clients](#download-clients)
7. [Book Services](#book-services)
8. [Recipe & Cooking](#recipe--cooking)
9. [Game Servers](#game-servers)
10. [ROM & Emulation](#rom--emulation)
11. [External API Keys](#external-api-keys)
12. [Email & SMTP](#email--smtp)
13. [Homepage Widget API Keys](#homepage-widget-api-keys)
14. [Encryption & Secrets](#encryption--secrets)
15. [User Accounts](#user-accounts)

---

## Common Passwords

### Standard Admin Password
```
Password: <REDACTED_ADMIN_PASSWORD>
```
Used for:
- Palworld admin
- ASA admin
- Database root passwords
- General admin access

### Standard User Password
```
Password: <REDACTED_USER_PASSWORD>
```
Used for:
- Palworld server password
- ASA server password
- MariaDB passwords
- General user passwords

### Tammer's Password
```
Password: <REDACTED_PERSONAL_PASSWORD>
```
Used for:
- Most service logins
- TrueNAS
- UGreen NAS
- NPM Plus
- Traefik
- qBittorrent
- Navidrome
- Kavita
- PHPIPAM
- Tandoor
- Mealie

---

## Infrastructure Access

### TrueNAS
```
URL:      https://truenas.thehighestcommittee.com
Username: truenas_admin
Password: <REDACTED_PASSWORD>
API Key:  <REDACTED_API_KEY>
```

### TrueNAS Dockge
```
Username: tammer
Password: <REDACTED_PASSWORD>
```

### UGreen NAS
```
URL:      https://ugreen.thehighestcommittee.com
Username: tammer
Password: <REDACTED_PASSWORD>
```

### NPM Plus (Nginx Proxy Manager)
```
URL:      https://npmplus.thehighestcommittee.com
Email:    <REDACTED_EMAIL>
Password: <REDACTED_PASSWORD>
```

### Traefik
```
URL:      https://traefik.thehighestcommittee.com
Username: tammer
Password: <REDACTED_PASSWORD>
```

### Cloudflare
```
NPM Plus API Token:      <REDACTED_TOKEN>
API Token (Zone):        <REDACTED_TOKEN>
Global API Key:          <REDACTED_KEY>
User Email:              <REDACTED_EMAIL>
Zone ID:                 <REDACTED_ID>
Domain:                  thehighestcommittee.com
Let's Encrypt Token:     <REDACTED_TOKEN>
```

### PHPIPAM
```
URL:      https://phpipam.thehighestcommittee.com
Username: tammer
Password: <REDACTED_PASSWORD>
```

---

## Database Credentials

### PostgreSQL (192.168.0.12:5432)
```
Host:     192.168.0.12
Port:     5432
Username: postgres
Password: <REDACTED_PASSWORD>
URL:      postgresql://postgres:<REDACTED_PASSWORD>@192.168.0.12:5432
```

### MariaDB / MySQL (Common)
```
Root Password: <REDACTED_PASSWORD>
User Password: <REDACTED_PASSWORD>
DB Name:       (varies by service)
```

### Specific Database Passwords
```
DB_ROOT_PASSWORD:   <REDACTED_PASSWORD>
DB_USER_PASSWORD:   <REDACTED_PASSWORD>
SHARED_PASSWORD:    <REDACTED_PASSWORD>
```

---

## Media Services

### Plex
```
URL:         https://plex.thehighestcommittee.com
Token:       <REDACTED_TOKEN>
Subgen Token: <REDACTED_TOKEN>
```

### Jellyfin
```
URL:      https://jellyfin.thehighestcommittee.com
Username: cannaculture
API Key:  <REDACTED_API_KEY>
```

### Overseerr
```
URL:      https://overseerr.thehighestcommittee.com
API Key:  <REDACTED_API_KEY>
```

### Navidrome
```
URL:      https://navidrome.thehighestcommittee.com
Username: tammer
Password: <REDACTED_PASSWORD>
Token:    <REDACTED_TOKEN>
```

### Subsonic
```
Username: thehighestcommittee
```

---

## Arr Stack

### Sonarr
```
URL:      https://sonarr.thehighestcommittee.com
Port:     8989
API Key:  <REDACTED_API_KEY>
```

### Radarr
```
URL:      https://radarr.thehighestcommittee.com
Port:     7878
API Key:  <REDACTED_API_KEY>
```

### Lidarr
```
URL:      https://lidarr.thehighestcommittee.com
API Key:  <REDACTED_API_KEY>
```

### Readarr
```
URL:      https://readarr.thehighestcommittee.com
Port:     8787
API Key:  <REDACTED_API_KEY>
```

### Prowlarr
```
URL:      https://prowlarr.thehighestcommittee.com
API Key:  <REDACTED_API_KEY>
```

### Sonobarr
```
Superadmin Username: tammer
Superadmin Password: <REDACTED_PASSWORD>
```

---

## Download Clients

### qBittorrent
```
URL:      https://qbittorrent.thehighestcommittee.com
Username: tammer
Password: <REDACTED_PASSWORD>
```

### SABnzbd
```
URL:      https://sabnzbd.thehighestcommittee.com
API Key:  <REDACTED_API_KEY>
```

---

## Book Services

### Kavita
```
URL:      https://kavita.thehighestcommittee.com
Port:     5002
Username: tammer
Password: <REDACTED_PASSWORD>
API Key:  <REDACTED_API_KEY>
```

### Audiobookshelf
```
URL:      https://audiobookshelf.thehighestcommittee.com
Port:     13378
API Key:  <REDACTED_API_KEY>
```

### BookLore
```
URL:            https://booklore.thehighestcommittee.com
Port:           6060
Database:       mariadb (container)
DB Name:        booklore
DB Username:    booklore
DB Password:    <REDACTED_PASSWORD>
DB Root Pass:   <REDACTED_PASSWORD>
```

---

## Recipe & Cooking

### Mealie
```
URL:      https://mealie.thehighestcommittee.com
Port:     9925
Username: tammer
Password: <REDACTED_PASSWORD>
API Key:  <REDACTED_API_KEY>

Database: PostgreSQL
  Host:     192.168.0.12
  Port:     5432
  Database: mealie
  Username: postgres
  Password: <REDACTED_PASSWORD>
```

### Tandoor
```
URL:      https://tandoor.thehighestcommittee.com
Username: tammer
Password: <REDACTED_PASSWORD>
API Key:  <REDACTED_API_KEY>
```

---

## Game Servers

### Palworld
```
Admin Password:  <REDACTED_PASSWORD>
Server Password: <REDACTED_PASSWORD>
```

### ARK: Survival Ascended (ASA)
```
Admin Password:  <REDACTED_PASSWORD>
Server Password: <REDACTED_PASSWORD>
```

### Enshrouded
```
Server Password: <REDACTED_PASSWORD>
```

---

## ROM & Emulation

### RoMM (ROM Manager)
```
URL:       https://romm.thehighestcommittee.com
Port:      8808
Auth Key:  <REDACTED_KEY>

Database: MariaDB (container: romm-db)
  Root Password: <REDACTED_PASSWORD>
  Database:      romm
  Username:      romm-user
  Password:      <REDACTED_PASSWORD>
```

### ScreenScraper (Metadata Provider)
```
Username: imtammer
Password: <REDACTED_PASSWORD>
```

### RetroAchievements
```
API Key: <REDACTED_API_KEY>
```

### SteamGridDB
```
API Key: <REDACTED_API_KEY>
```

---

## External API Keys

### TMDB (The Movie Database)
```
API Key: <REDACTED_API_KEY>
```


### YouTube Data API
```
API Key: <REDACTED_API_KEY>
```

### Last.fm
```
API Key: <REDACTED_API_KEY>
Shared Secret: <REDACTED_SECRET>
```

### Spotify
```
Client Secret: <REDACTED_SECRET>
```

### Discord
```
Bot Token:    <REDACTED_TOKEN>
Client Token: <REDACTED_TOKEN>
```

---

## Email & SMTP

### Gmail SMTP (Authelia Notifications)
```
Host:     smtp.gmail.com
Port:     587
Username: <REDACTED_EMAIL>
Password: <REDACTED_PASSWORD>
Sender:   Authelia <REDACTED_EMAIL>
```

### SMTP2GO (Mealie)
```
Host:       mail.smtp2go.com
Port:       587
Strategy:   TLS
From Name:  TheHighestCommittee
From Email: <REDACTED_EMAIL>
Username:   <REDACTED_EMAIL>
Password:   <REDACTED_PASSWORD>
```

---

## Homepage Widget API Keys

### slskd
```
API Key: <REDACTED_API_KEY>
```

### Mylar
```
API Key: <REDACTED_API_KEY>
```

### Paperless-NGX
```
API Key: <REDACTED_API_KEY>
```

---

## Encryption & Secrets

### General Encryption Keys
```
SECRET_ENCRYPTION_KEY: <REDACTED_KEY>
NEWT_SECRET:           <REDACTED_SECRET>
PAPERLESS_SECRET_KEY:  <REDACTED_KEY>
WEBUI_SECRET_KEY:      <REDACTED_KEY>
```

### SOPS + age
```
SOPS_AGE_KEY_FILE: /opt/stacks/.secrets/age-key.txt
```

---

## User Accounts

### Primary Admin
```
Username: admin
Email:    <REDACTED_EMAIL>
Password: <REDACTED_PASSWORD>
Groups:   admins, users
```

### Primary User (tammer)
```
Username: tammer
Email:    <REDACTED_EMAIL>
Password: <REDACTED_PASSWORD> (most services)
```

### Secondary User (redacted)
```
Username: redacted
Email:    <REDACTED_EMAIL>
Password: <REDACTED_PASSWORD>
Groups:   users
```

### Jellyfin User
```
Username: cannaculture
```

---

## Service-Specific Notes

### Mealie Database Issue
If Mealie can't connect to database:
- Hardcode POSTGRES_SERVER, POSTGRES_PORT, POSTGRES_USER, POSTGRES_PASSWORD in compose.yaml
- Don't rely on .env file for database variables

### RoMM Database Issue
If RoMM database is unhealthy:
- Check MARIADB_ROOT_PASSWORD is set in compose.yaml
- Verify healthcheck configuration

### Arr Services Authentication
Most arr services are configured with:
- AuthenticationMethod: Forms
- AuthenticationRequired: DisabledForLocalAddresses
- Access via Traefik requires API key

---

## Quick Access URLs

### Management
- Traefik: https://traefik.thehighestcommittee.com
- Dockhand: https://dockhand.thehighestcommittee.com
- Dozzle: https://dozzle.thehighestcommittee.com
- NPM Plus: https://npmplus.thehighestcommittee.com
- Homepage: https://homepage.thehighestcommittee.com
- UDM-SE: https://192.168.0.1

### Media Servers
- Plex: https://plex.thehighestcommittee.com
- Jellyfin: https://jellyfin.thehighestcommittee.com
- Overseerr: https://overseerr.thehighestcommittee.com

### Arr Stack
- Sonarr: https://sonarr.thehighestcommittee.com
- Radarr: https://radarr.thehighestcommittee.com
- Lidarr: https://lidarr.thehighestcommittee.com
- Readarr: https://readarr.thehighestcommittee.com
- Prowlarr: https://prowlarr.thehighestcommittee.com

### Downloads
- qBittorrent: https://qbittorrent.thehighestcommittee.com
- SABnzbd: https://sabnzbd.thehighestcommittee.com

### Books & Media
- Kavita: https://kavita.thehighestcommittee.com
- Audiobookshelf: https://audiobookshelf.thehighestcommittee.com
- BookLore: https://booklore.thehighestcommittee.com
- Navidrome: https://music.thehighestcommittee.com

### Cooking
- Mealie: https://mealie.thehighestcommittee.com
- Tandoor: https://recipes.thehighestcommittee.com

### Gaming
- RoMM: https://romm.thehighestcommittee.com

---

## Environment File Location

**Primary .env file:** `/opt/stacks/.env`

This file contains most of the credentials listed above and can be sourced by compose files.

**Note:** Many services have issues loading from .env files. If a service fails to start with "empty host" or similar errors, hardcode the credentials directly in the compose.yaml file.

---

## Security Notes

### ⚠️ Important
- This file contains production credentials
- Keep file permissions restricted: `chmod 600`
- Do not commit to public repositories
- Rotate credentials regularly
- Use strong passwords for external-facing services

### 🔒 Current Auth Status
- **Authelia:** REMOVED (as of 2026-02-04)
- **Pocket ID:** REMOVED (as of 2026-02-04)
- **OIDC:** REMOVED from all services
- Services now use individual authentication mechanisms
- No centralized SSO currently active

### 📝 Credential Change Locations
- Service passwords: Usually in web UI settings
- Database passwords: In compose.yaml files
- API keys: Generated in service web UI (Settings → API)
- Environment variables: `/opt/stacks/.env` and individual compose files

---

## Emergency Access

### If Locked Out
1. SSH to server: `ssh root@192.168.0.11`
2. Stop service: `cd /opt/stacks/service && docker compose down`
3. Edit config or reset credentials
4. Restart: `docker compose up -d`

### Reset Service Authentication
Most services store authentication in SQLite databases:
```bash
# Find database location
docker inspect service-name | grep -i volume

# Backup database
cp /path/to/service.db /path/to/service.db.bak

# Use sqlite3 to reset credentials
sqlite3 /path/to/service.db
```

### Traefik Access
If Traefik is down, services are accessible via direct IP:port:
```
http://192.168.0.11:PORT
```

---

**Last Updated:** 2026-02-04
**Maintained By:** AI Assistant
**Contact:** imtammer@gmail.com

---

## VPN Services

### Proton VPN
```
Account Login:      <REDACTED_EMAIL>
Account Password:   <REDACTED_PASSWORD>

WireGuard Key:      <REDACTED_KEY>

OpenVPN/IKEv2 User: <REDACTED_USER>
OpenVPN/IKEv2 Pass: <REDACTED_PASSWORD>
MaM ID:             <REDACTED_ID>
MAM Cookie:         <REDACTED_COOKIE>
```

### PrivadoVPN
```
Username: <REDACTED_USER>
Password: <REDACTED_PASSWORD>
```

---

## Usenet Providers

### NewsHosting
```
Server:   news.newshosting.com
Port:     563
Username: tammer
Password: <REDACTED_PASSWORD>
```

### FrugalUseNet
```
Server:   newswest.frugalusenet.com
Port:     563
Username: tammer
Password: <REDACTED_PASSWORD>
```

---

## Usenet Indexers

### NZBPlanet
```
API Key:  <REDACTED_API_KEY>
Queries:  20000
Grabs:    Unlimited
```

### Miatrix
```
API Key:  <REDACTED_API_KEY>
          <REDACTED_API_KEY> (alternate)
Queries:  2000
Grabs:    500
```

### NZBGeek
```
API Key: <REDACTED_API_KEY>
```

---

## Additional Media APIs

### Real Debrid
```
API Key: <REDACTED_API_KEY>
```

### Comic Vine
```
API Key: <REDACTED_API_KEY>
```

### Discogs
```
API Key: <REDACTED_API_KEY>
```

### Trakt
```
Client ID:     <REDACTED_ID>
Client Secret: <REDACTED_SECRET>
```

### MyAnimeList
```
Client ID:     <REDACTED_ID>
Client Secret: <REDACTED_SECRET>
```

### OMDB
```
API Key: <REDACTED_API_KEY>
```

### MDBLIST
```
API Key: <REDACTED_API_KEY>
```

### TMDB (Additional)
```
API Key:            <REDACTED_API_KEY>
Read Access Token:  <REDACTED_TOKEN>
```

### Cloudinary
```
Cloud Name: dwnrssezv
API Key:    <REDACTED_API_KEY>
API Secret: <REDACTED_SECRET>
```

---

## Additional Service APIs

### Tautulli
```
URL:      http://192.168.0.11:8181
API Key:  <REDACTED_API_KEY>
```

### Notifiarr
```
URL:      http://192.168.0.2:5454
API Key:  <REDACTED_API_KEY>
```

### Bazarr
```
URL:      http://192.168.0.11:6767
API Key:  <REDACTED_API_KEY>
```

### Jellyseerr
```
URL:      http://192.168.0.11:5056
API Key:  <REDACTED_API_KEY>
```

### Listenarr (Audiobook Readarr)
```
URL:      http://192.168.0.11:8788
API Key:  <REDACTED_API_KEY>
```

### SABnzbd (TrueNAS)
```
URL:      http://192.168.0.44:8080/
API Key:  <REDACTED_API_KEY>
```

### SABnzbd (Local)
```
URL:      http://192.168.0.11:8080/
API Key:  <REDACTED_API_KEY>
```

---

## Google Services

### Google OAuth
```
Client ID:     <REDACTED_ID>.apps.googleusercontent.com
               <REDACTED_ID>.apps.googleusercontent.com (alternate)
Client Secret: <REDACTED_SECRET>
               <REDACTED_SECRET> (alternate)
```

### Google Books API
```
API Key: <REDACTED_API_KEY>
```

### Gmail App Password (Kavita)
```
Password: otei ptqs okxn wehq
```

---

## Additional SMTP Configurations

### PurelyMail
```
Server:   smtp.purelymail.com
Port:     465/587
Username: <REDACTED_EMAIL>
Password: <REDACTED_PASSWORD>
```

### iCloud Mail
```
Server:     smtp.mail.me.com
Port:       587
Encryption: STARTTLS
Username:   <REDACTED_EMAIL>
Password:   <REDACTED_PASSWORD>
```

---

## Developer APIs & Keys

### Anthropic (Claude)
```
VSCode API Key:  <REDACTED_API_KEY>
```

### OpenAI (OpenWebUI)
```
API Key: <REDACTED_API_KEY>
```

### GitHub Tokens
```
General Token: <REDACTED_TOKEN>
Komodo Token:  <REDACTED_TOKEN>
```

### YouTube API (Additional)
```
API Key: <REDACTED_API_KEY>
```

---

## Plex Tokens (Additional)

### Primary Plex Tokens
```
MediaBox (192.168.0.13): <REDACTED_TOKEN>
UGreen (192.168.0.8):    <REDACTED_TOKEN>
Local (192.168.0.11):    <REDACTED_TOKEN>
Library Token:           <REDACTED_TOKEN>
Alternate Token:         <REDACTED_TOKEN>
```

---

## Kavita (Extended)

### Full Configuration
```
URL:                https://kavita.thehighestcommittee.com
Local URL:          http://192.168.0.11:5002
Username:           tammer
Password:           <REDACTED_PASSWORD>
API Key:            <REDACTED_API_KEY>
Full API Key:       <REDACTED_API_KEY>
Gmail App Pass:     <REDACTED_PASSWORD>
Registration Key:   (as needed)
OPDS URL:           https://kavita.thehighestcommittee.com/api/opds/<REDACTED_KEY>
```

---

## Book Services (Extended)

### Hardcover API
```
Bearer Token: <REDACTED_TOKEN>
```

### Anna's Archive
```
Secret Key:      <REDACTED_KEY>
Account ID:      <REDACTED_ID>
Public Profile:  #<REDACTED_ID>
```

---

## Monitoring & Infrastructure

### InfluxDB
```
Operator API: <REDACTED_API_KEY>
```

### Pangolin
```
Admin Password:  <REDACTED_PASSWORD>
Server Secret:   <REDACTED_SECRET>
Setup Token:     <REDACTED_TOKEN>
Endpoint:        https://pangolin.thehighestcommittee.com
```

### Newt (Pangolin Integration)
```
Endpoint:    https://pangolin.thehighestcommittee.com
ID:          <REDACTED_ID>
             <REDACTED_ID> (alternate)
Secret Key:  <REDACTED_KEY>
             <REDACTED_KEY> (from .env)
```

---

## Pocket ID (Extended)

### Additional Keys
```
Claude API Key: <REDACTED_API_KEY>
```

**Note:** Pocket ID has been removed from the environment as of 2026-02-04

---

## Recovery & Backup Keys

### Mega
```
Recovery Key: <REDACTED_KEY>
```

### Huntarr
```
Recovery 1: <REDACTED_KEY>
Recovery 2: <REDACTED_KEY>
```

### UGreen NAS Password
```
Password: <REDACTED_PASSWORD>
```

---

## NPM Plus Default Credentials

```
Username: <REDACTED_EMAIL>
Password: <REDACTED_HASH>
```

**Note:** Change after first login

---

## SOPS & Age Encryption (DISABLED)

**Status:** ⛔ Secrets encryption has been DISABLED as of 2026-02-04

### Why Disabled
User requested removal of all secrets encryption to simplify environment management.

### What Was Removed
- ❌ Encrypted `.env.enc` file (deleted)
- ❌ `secrets-manager.sh` (disabled)
- ❌ `sops-encrypt-all-env.sh` (disabled)
- ❌ SOPS/age environment variables (commented out)

### Current State
- ✅ All credentials in plaintext at `/opt/stacks/.env`
- ✅ File permissions: 600 (root only)
- ✅ `.env` in `.gitignore` (never commit)
- ✅ Age private key preserved at `/opt/stacks/.secrets/age-key.txt` (for reference only)

### Age Keys (Reference Only)
```
Private Key Location: /opt/stacks/.secrets/age-key.txt
Public Key:          age1pm3d8jcve9x5x2fzwut6zgvvu2kq0ak5qaacf8mxrgu5l00zq9ks52yzuj
```

### If You Need to Re-Enable Encryption
1. Uncomment SOPS variables in `/opt/stacks/.env`
2. Rename scripts: remove `.disabled` suffix
3. Run: `/opt/stacks/scripts/secrets-manager.sh encrypt`
4. Commit `.env.enc` instead of `.env`

---

## NFS Mount Configurations

### Permanent Mounts (/etc/fstab)
```bash
192.168.0.44:/mnt/datastore/media /media/storage/truenas/ nfs bg 0 0
192.168.0.8:/volume1/media /media/storage/ugreen/ nfs bg 0 0
192.168.0.3:/volume1/Media /media/synology/ nfs bg 0 0
```

### Manual Mount Commands
```bash
# Mount TrueNAS
sudo mount -t nfs 192.168.0.44:/mnt/datastore/media /media/storage/truenas/

# Mount UGreen
sudo mount -t nfs 192.168.0.8:/volume1/media /media/storage/ugreen/

# Mount Synology
sudo mount -t nfs 192.168.0.3:/volume1/Media /media/synology/

# Mount UGreen downloads
sudo mount -t nfs 192.168.0.8:/volume1/media/downloads /media/ugreen/downloads/
```

### Legacy Mount Points (Historical)
```bash
192.168.0.204:/media/legion /media/legion nfs bg 0 0
192.168.0.10:/mnt/truenas/media /media/storage/truenas/
```

---

## PostgreSQL Migration Commands

### Readarr Migration Example
```bash
sudo docker run --rm \
  -v /home/tammer/docker/appdata/readarr/readarr.db:/readarr.db:ro \
  --network=host \
  ghcr.io/roxedus/pgloader \
  --with "quote identifiers" \
  --with "data only" \
  /readarr.db \
  "postgresql://postgres:<REDACTED_PASSWORD>@192.168.0.2/readarr-main"
```

### Standard PostgreSQL Config (XML Format)
```xml
<PostgresUser>postgres</PostgresUser>
<PostgresPassword><REDACTED_PASSWORD></PostgresPassword>
<PostgresPort>5432</PostgresPort>
<PostgresHost>192.168.0.12</PostgresHost>
<UpdateAutomatically>True</UpdateAutomatically>
<PostgresMainDb>appname-main</PostgresMainDb>
<PostgresLogDb>appname-log</PostgresLogDb>
```

### Specific Database Configs

**Sonarr:**
```xml
<PostgresMainDb>sonarr-main</PostgresMainDb>
<PostgresLogDb>sonarr-log</PostgresLogDb>
```

**Lidarr:**
```xml
<PostgresMainDb>lidarr-main</PostgresMainDb>
<PostgresLogDb>lidarr-log</PostgresLogDb>
```

---

## Useful Passwords & Hashes

*This section has been moved to the secure local storage.*

---

## Related Documentation
- **Main Guide:** `/opt/stacks/AI_ASSISTANT_GUIDE.md`
- **Quick Reference:** `/opt/stacks/QUICK_REFERENCE.md`
- **Changelog:** `/opt/stacks/CHANGELOG.md`
- **User Credentials:** `/opt/stacks/security/USER_CREDENTIALS.md`
