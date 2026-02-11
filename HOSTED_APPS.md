<p align="center">
  <img src="https://img.shields.io/badge/Applications-70%2B-success?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Media%20Automation-Arr%20Stack-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/AI%20Services-Ollama%20%7C%20Whisper-purple?style=for-the-badge" />
</p>

<h1 align="center">📱 Hosted Applications Directory</h1>

<p align="center">
  <strong>Complete directory of all hosted services in TheHighestCommittee homelab</strong>
</p>

---

## 🔗 Quick Access Dashboards

<table align="center">
<tr>
<th>🏷️</th>
<th>Dashboard</th>
<th>URL</th>
<th>Purpose</th>
</tr>
<tr>
<tr>
<td>🏠</td>
<td><strong>Homepage</strong></td>
<td><a href="https://homepage.thehighestcommittee.com">homepage.thehighestcommittee.com</a></td>
<td>Unified app dashboard</td>
</tr>
<tr>
<td>📊</td>
<td><strong>Dozzle</strong></td>
<td><a href="https://dozzle.thehighestcommittee.com">dozzle.thehighestcommittee.com</a></td>
<td>Container logs (all hosts)</td>
</tr>
<tr>
<td>🎨</td>
<td><strong>Homarr</strong></td>
<td><a href="https://start.thehighestcommittee.com">start.thehighestcommittee.com</a></td>
<td>Alternative dashboard</td>
</tr>
<tr>
<td>💻</td>
<td><strong>Termix</strong></td>
<td><a href="https://termix.thehighestcommittee.com">termix.thehighestcommittee.com</a></td>
<td>Web terminal</td>
</tr>
</table>

---

## 🗂️ Host Distribution

<table>
<tr>
<th>🏷️</th>
<th>Host</th>
<th>IP</th>
<th>Services</th>
</tr>
<tr><td>🖥️</td><td><strong>Primary</strong></td><td><code>192.168.0.11</code></td><td>60+ services</td></tr>
<tr><td>🎬</td><td><strong>TamMediaBox</strong></td><td><code>192.168.0.13</code></td><td>Plex, Jellyfin, mstream</td></tr>
<tr><td>🤖</td><td><strong>AI Docker</strong></td><td><code>192.168.0.7</code></td><td>Ollama, Paperless, Whisper</td></tr>
<tr><td>💾</td><td><strong>TrueNAS</strong></td><td><code>192.168.0.44</code></td><td>qBittorrent, SABnzbd, Dockge</td></tr>
<tr><td>📦</td><td><strong>UGREEN</strong></td><td><code>192.168.0.8</code></td><td>Storage only (Docker-capable)</td></tr>
<tr><td>🗄️</td><td><strong>PostgreSQL</strong></td><td><code>192.168.0.12</code></td><td>21 databases</td></tr>
<tr><td>🌐</td><td><strong>phpIPAM</strong></td><td><code>192.168.0.116</code></td><td>IP management</td></tr>
<tr><td>🖥️</td><td><strong>Proxmox</strong></td><td><code>192.168.0.40</code></td><td>Hypervisor (3 VMs, 6 LXCs)</td></tr>
<tr><td>🍳</td><td><strong>Tandoor</strong></td><td><code>192.168.0.6</code></td><td>Recipe server</td></tr>
<tr><td>🛡️</td><td><strong>UDM-SE</strong></td><td><code>192.168.0.1</code></td><td>Gateway & Firewall</td></tr>
<tr><td>🔧</td><td><strong>Dell iDRAC</strong></td><td><code>192.168.0.50</code></td><td>Server management</td></tr>
</table>


---

## 🖥️ Proxmox Infrastructure

<table>
<tr><td colspan="5">

### 📍 192.168.0.40 — Node: **khemt**

</td></tr>
</table>

### 🖥️ Virtual Machines

| VMID | 🏷️ Name | 📍 IP | 💻 Resources | 🎯 Purpose |
|:----:|:--------|:-----:|:-------------|:-----------|
| 103 | **TrueNAS** | .44 | 8c / 64GB / 80GB | NAS + Docker |
| 104 | **foundry** | .4 | 2c / 4GB / 80GB | Foundry VTT |
| 105 | **osiris** | .11 | 20c / 48GB / 1TB | Primary Docker Host |

### 📦 LXC Containers

| VMID | 🏷️ Name | 📍 IP | 💻 Resources | 🎯 Purpose |
|:----:|:--------|:-----:|:-------------|:-----------|
| 101 | **traefik** | .2 | 1c / 2GB / 20GB | Traefik Proxy |
| 111 | **arrstack** | .11 | 16c / 16GB / 2TB | 🔴 [STOPPED] |
| 112 | **postgresql** | .12 | 2c / 8GB / 125GB | Central Database |
| 119 | **phpipam** | .116 | 1c / 512MB / 4GB | IP Management |

---

## 🎬 Media Servers

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 🎬 | **Plex** | TamMediaBox | 32400 | [plex.thehighestcommittee.com](https://plex.thehighestcommittee.com) | ✅ | Primary media server (GPU) |
| 🎬 | **Jellyfin** | TamMediaBox | 8096 | [jellyfin.thehighestcommittee.com](https://jellyfin.thehighestcommittee.com) | ✅ | Open-source media server (GPU) |
| 🎵 | **mstream** | TamMediaBox | 3000 | [mstream.thehighestcommittee.com](https://mstream.thehighestcommittee.com) | — | FLAC/Music Streaming |

---

## 📺 Media Automation

### 📡 TV, Movies & Anime

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 📺 | **Sonarr** | Primary | 8989 | [sonarr.thehighestcommittee.com](https://sonarr.thehighestcommittee.com) | ✅ | TV show automation |
| 🎬 | **Radarr** | Primary | 7878 | [radarr.thehighestcommittee.com](https://radarr.thehighestcommittee.com) | ✅ | Movie automation |
| 🔍 | **Prowlarr** | Primary | 9696 | [prowlarr.thehighestcommittee.com](https://prowlarr.thehighestcommittee.com) | ✅ | Indexer management |
| 💬 | **Bazarr** | Primary | 6767 | [bazarr.thehighestcommittee.com](https://bazarr.thehighestcommittee.com) | ✅ | Subtitle management |
| ⚽ | **SportArr** | Primary | 1867 | [sportarr.thehighestcommittee.com](https://sportarr.thehighestcommittee.com) | — | Sports automation |
| 🎨 | **ProfilArr** | Primary | 6868 | [profilarr.thehighestcommittee.com](https://profilarr.thehighestcommittee.com) | — | Profile management |

### 🎫 Media Requests

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 🎫 | **Overseerr** | Primary | 5055 | [overseerr.thehighestcommittee.com](https://overseerr.thehighestcommittee.com) | ✅ | Plex media requests |
| 🎫 | **JellySeerr** | Primary | 5056 | [jellyseerr.thehighestcommittee.com](https://jellyseerr.thehighestcommittee.com) | ✅ | Jellyfin media requests |
| 💡 | **SuggestArr** | Primary | 5000 | [suggestarr.thehighestcommittee.com](https://suggestarr.thehighestcommittee.com) | — | AI recommendations |

---

## 🎵 Music Services

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 🎵 | **Lidarr** | Primary | 8686 | [lidarr.thehighestcommittee.com](https://lidarr.thehighestcommittee.com) | ✅ | Music automation |
| 🎧 | **Navidrome** | Primary | 4533 | [music.thehighestcommittee.com](https://music.thehighestcommittee.com) | ✅ | Music streaming |
| 🎼 | **Lidify** | Primary | 3030 | [lidify.thehighestcommittee.com](https://lidify.thehighestcommittee.com) | — | Lidarr UI enhancement |
| 🔊 | **Sonobarr** | Primary | 5003 | — | — | Sonos integration |
| 🎶 | **Blissful** | Primary | 7373 | — | — | Music discovery |
| 🌐 | **SLSKD** | Primary | 5030 | [slskd.thehighestcommittee.com](https://slskd.thehighestcommittee.com) | — | SoulSeek client |
| 🎵 | **SoularR** | Primary | — | — | — | Music sync (background) |

---

## 📚 Books & Audiobooks

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 🎧 | **Audiobookshelf** | Primary | 13378 | [audiobookshelf.thehighestcommittee.com](https://audiobookshelf.thehighestcommittee.com) | ✅ | Audiobook streaming |
| 📖 | **Kavita** | Primary | 5002 | [kavita.thehighestcommittee.com](https://kavita.thehighestcommittee.com) | ✅ | eBook/manga reader |
| 📕 | **Readarr** | Primary | 8787 | [readarr.thehighestcommittee.com](https://readarr.thehighestcommittee.com) | ✅ | eBook automation |
| 🎧 | **ListenArr** | Primary | 8788 | [listenarr.thehighestcommittee.com](https://listenarr.thehighestcommittee.com) | — | Audiobook automation |
| 📚 | **OpenBooks** | Primary | 6081 | [openbooks.thehighestcommittee.com](https://openbooks.thehighestcommittee.com) | — | Book downloader |
| ➕ | **ABR** | Primary | 8088 | — | — | Audiobook requests |
| 🔖 | **ShelfMark** | Primary | 8084 | [shelfmark.thehighestcommittee.com](https://shelfmark.thehighestcommittee.com) | — | Book catalog |
| 📗 | **BookLore** | Primary | 6060 | [booklore.thehighestcommittee.com](https://booklore.thehighestcommittee.com) | — | Book library tool |

---

## 📖 Comics & Manga

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 🦸 | **Kapowarr** | Primary | 5656 | — | — | Comic automation |
| 📱 | **Suwayomi** | Primary | 4567 | [manga.thehighestcommittee.com](https://manga.thehighestcommittee.com) | — | Manga reader (Tachidesk) |
| 🦹 | **Mylar3** | Primary | 8090 | — | — | Comic management |

---

## 🛠️ Media Maintenance

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 🔧 | **Maintainerr** | Primary | 6246 | [maintainerr.thehighestcommittee.com](https://maintainerr.thehighestcommittee.com) | — | Library maintenance |
| 🧹 | **CleanupArr** | Primary | 11011 | — | — | Cleanup automation |
| 🎯 | **Huntarr** | Primary | 9705 | [huntarr.thehighestcommittee.com](https://huntarr.thehighestcommittee.com) | — | Unwanted removal |
| 📂 | **SortArr** | Primary | 9595 | — | — | Media organization |
| 📺 | **Tunarr** | Primary | 8888 | — | — | IPTV channel manager |
| 🖼️ | **DAPS** | Primary | 8008 | — | — | Poster artwork |
| ▶️ | **Quickstart** | Primary | 7172 | — | — | Kometa quickstart |
| 🧙 | **Wizarr** | Primary | 5690 | [wizarr.thehighestcommittee.com](https://wizarr.thehighestcommittee.com) | — | User onboarding |
| ➕ | **Agregarr** | Primary | 7171 | — | — | Media aggregation |

---

## 📥 Downloads

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 🌊 | **qBittorrent** | TrueNAS | 8880 | [qbittorrent.thehighestcommittee.com](https://qbittorrent.thehighestcommittee.com) | ✅ | Torrent client |
| 📰 | **SABnzbd** | TrueNAS | 8080 | [sabnzbd.thehighestcommittee.com](https://sabnzbd.thehighestcommittee.com) | ✅ | Usenet downloader |
| 📺 | **MeTube** | Primary | 8881 | [metube.thehighestcommittee.com](https://metube.thehighestcommittee.com) | — | YouTube downloader |
| 🛡️ | **FlareSolverr** | Primary | 8191 | — | — | Anti-bot bypass |

---

## 🤖 AI & Intelligence

## 🤖 AI & Intelligence

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 🧠 | **Ollama** | AI Docker | 11434 | — | — | LLM inference engine |
| 💬 | **Open-WebUI** | AI Docker | 8080 | [chat.thehighestcommittee.com](https://chat.thehighestcommittee.com) | — | LLM chat interface |
| 🎤 | **Whisper ASR** | AI Docker | 9000 | [whisper.thehighestcommittee.com](https://whisper.thehighestcommittee.com) | — | Speech-to-text |
| 📄 | **Paperless-NGX** | AI Docker | 8000 | [paperless.thehighestcommittee.com](https://paperless.thehighestcommittee.com) | — | Document OCR |
| 🤖 | **Paperless-AI** | AI Docker | 3001 | — | — | AI classification |
| 🎬 | **Subgen** | AI Docker | — | — | — | AI subtitles (background) |

---

## 🎮 Gaming & Emulation

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 🎮 | **RoMM** | Primary | 8808 | [romm.thehighestcommittee.com](https://romm.thehighestcommittee.com) | ✅ | ROM management |
| 🎲 | **FoundryVTT** | Proxmox | 30000 | [tabletop.thehighestcommittee.com](https://tabletop.thehighestcommittee.com) | — | Virtual tabletop |
| 👾 | **Palworld** | Primary | 8211 | — | — | Dedicated Server |
| ⛏️ | **Enshrouded** | Primary | 15637 | — | — | Dedicated Server |
| 🦖 | **Ark: SA** | Primary | 7779 | — | — | Dedicated Server |
| 🏭 | **Satisfactory** | Primary | 7777 | — | — | Dedicated Server |

---

## 🍳 Food & Recipes

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 🍳 | **Mealie** | Primary | 9925 | [mealie.thehighestcommittee.com](https://mealie.thehighestcommittee.com) | ✅ | Recipe management |
| 📖 | **Tandoor** | Tandoor (LXC) | 8002 | [recipes.thehighestcommittee.com](https://recipes.thehighestcommittee.com) | ✅ | Recipe management v2 |

---

## 📊 Monitoring & Reporting

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 📊 | **Tautulli** | Primary | 8181 | [tautulli.thehighestcommittee.com](https://tautulli.thehighestcommittee.com) | ✅ | Plex analytics |
| 🔔 | **Notifiarr** | Primary | 5454 | — | — | Notifications hub |
| 👁️ | **Watcharr** | Primary | 3080 | [watcharr.thehighestcommittee.com](https://watcharr.thehighestcommittee.com) | — | Watch tracking |
| 📋 | **Ryot** | Primary | 8010 | [ryot.thehighestcommittee.com](https://ryot.thehighestcommittee.com) | — | Media tracking |

---

## 🎛️ Dashboards & Control

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 🏠 | **Homepage** | Primary | 3333 | [homepage.thehighestcommittee.com](https://homepage.thehighestcommittee.com) | — | Unified dashboard |
| 📊 | **Dozzle** | Primary | 8081 | [dozzle.thehighestcommittee.com](https://dozzle.thehighestcommittee.com) | — | Container logs |
| 🎨 | **Homarr** | Primary | 7575 | [start.thehighestcommittee.com](https://start.thehighestcommittee.com) | — | Alt dashboard |
| 💻 | **Termix** | Primary | 8880 | [termix.thehighestcommittee.com](https://termix.thehighestcommittee.com) | — | Web terminal |
| 🐳 | **Dockhand** | Primary | 3003 | [dockhand.thehighestcommittee.com](https://dockhand.thehighestcommittee.com) | — | Docker management |
| 🔄 | **WUD** | Primary | 3001 | — | — | Image update checker |
| 📦 | **Dockge** | TrueNAS | 31014 | [dockge.thehighestcommittee.com](https://dockge.thehighestcommittee.com) | — | Stack manager (TrueNAS) |

---

## 🤖 Discord Bots

> 🔇 Background Services — No Web UI

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 🎵 | **Manuel-RW** | Primary | 3300 | — | — | Jellyfin music bot |
| 🎶 | **Muse** | Primary | — | — | — | Music playback bot |
| 🎧 | **Discodrome** | Primary | — | — | — | Navidrome integration |

---

## 🔐 Authentication

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 🔑 | **Pocket-ID** | Primary | 1411 | [auth.thehighestcommittee.com](https://auth.thehighestcommittee.com) | — | OIDC provider with passkey |
| 🛡️ | **TinyAuth** | Primary | 3000 | [tinyauth.thehighestcommittee.com](https://tinyauth.thehighestcommittee.com) | — | Simple auth proxy |

### Pocket-ID Configuration

**Location**: `/opt/stacks/arrstack/appdata/dockhand/data/stacks/security/`

| File | Purpose |
|:-----|:--------|
| `docker-compose.yml` | Container definition |
| `.env` | Environment configuration |
| `/opt/stacks/arrstack/appdata/pocket-id/data/` | Persistent data (SQLite DB, uploads) |

**Key Environment Variables**:
```env
APP_URL=https://auth.thehighestcommittee.com
ENCRYPTION_KEY=<base64-encoded-key>  # Generate with: openssl rand -base64 32
TRUST_PROXY=true
MAXMIND_LICENSE_KEY=<your-maxmind-key>  # Optional, for GeoIP
```

**CLI Commands**:
```bash
# Generate one-time login token
docker exec security-pocket-id-1 /app/pocket-id one-time-access-token <username>

# Health check
docker exec security-pocket-id-1 /app/pocket-id healthcheck
```

**Notes**:
- Requires HTTPS for secure cookie authentication
- Supports passkey (WebAuthn) authentication only - no passwords
- Must access via external URL (auth.thehighestcommittee.com) for login to work

---

## 🏗️ Infrastructure Services

### 🔀 Reverse Proxies

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 🔀 | **Traefik** | Proxmox | 8080 | — | — | Docker auto-discovery |

### 🌐 Network & Database

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 🌐 | **phpIPAM** | phpIPAM (LXC) | 80 | [192.168.0.116](http://192.168.0.116/) | — | IP address management |
| 🗄️ | **PostgreSQL** | Postgres (LXC) | 5432 | — | — | Central database (21 DBs) |
| 🔧 | **Adminer** | Postgres (LXC) | 80 | [192.168.0.12/adminer/](http://192.168.0.12/adminer/) | — | Database web UI |

### 🖥️ Virtualization & Storage

| 🏷️ | Name | Server | Port | External URL | Widget | Purpose |
|:--:|:-----|:-------|:-----|:-------------|:------:|:--------|
| 🖥️ | **Proxmox** | Proxmox | 8006 | [khemt.thehighestcommittee.com](https://khemt.thehighestcommittee.com) | ✅ | Hypervisor |
| 💾 | **TrueNAS** | TrueNAS (VM) | 80 | [192.168.0.44](http://192.168.0.44) | ✅ | Primary NAS |
| 📦 | **UGREEN** | UGREEN | 9999 | — | — | SSD NAS |
| 🔧 | **Dell iDRAC** | Dell Server | 443 | [192.168.0.50](https://192.168.0.50) | — | Server management |
| 🛡️ | **UDM-SE** | Gateway | 443 | [192.168.0.1](https://192.168.0.1) | — | Network Core |

---

## 🌐 NPM Plus Proxy Hosts

<details>
<summary>📋 <strong>Click to expand full proxy host list (49 total)</strong></summary>

| 🌍 Domain | 🎯 Target | 🖥️ Host |
|:----------|:----------|:--------|
| arrstack.thehighestcommittee.com | 192.168.0.11:5001 | Primary |
| audiobookshelf.thehighestcommittee.com | 192.168.0.11:13378 | Primary |
| auth.thehighestcommittee.com | 192.168.0.11:1411 | Primary |
| bazarr.thehighestcommittee.com | 192.168.0.11:6767 | Primary |
| booklore.thehighestcommittee.com | 192.168.0.11:6060 | Primary |
| books.thehighestcommittee.com | 192.168.0.11:8083 | Primary |
| dockhand.thehighestcommittee.com | 192.168.0.11:3003 | Primary |
| dozzle.thehighestcommittee.com | 192.168.0.11:8081 | Primary |
| huntarr.thehighestcommittee.com | 192.168.0.11:9705 | Primary |
| jellyfin.thehighestcommittee.com | 192.168.0.13:8096 | TamMediaBox |
| jellyseerr.thehighestcommittee.com | 192.168.0.11:5056 | Primary |
| kavita.thehighestcommittee.com | 192.168.0.11:5002 | Primary |
| khemt.thehighestcommittee.com | 192.168.0.40:8006 | Proxmox |
| lidarr.thehighestcommittee.com | 192.168.0.11:8686 | Primary |
| lidify.thehighestcommittee.com | 192.168.0.11:3030 | Primary |
| listenarr.thehighestcommittee.com | 192.168.0.11:8788 | Primary |
| maintainerr.thehighestcommittee.com | 192.168.0.11:6246 | Primary |
| manga.thehighestcommittee.com | 192.168.0.11:4567 | Primary |
| mealie.thehighestcommittee.com | 192.168.0.11:9925 | Primary |
| metube.thehighestcommittee.com | 192.168.0.11:8881 | Primary |
| mstream.thehighestcommittee.com | 192.168.0.13:3000 | TamMediaBox |
| music.thehighestcommittee.com | 192.168.0.11:4533 | Primary |
| openbooks.thehighestcommittee.com | 192.168.0.11:6081 | Primary |
| overseerr.thehighestcommittee.com | 192.168.0.11:5055 | Primary |
| paperless.thehighestcommittee.com | 192.168.0.7:8000 | AI Docker |
| plex.thehighestcommittee.com | 192.168.0.13:32400 | TamMediaBox |
| pocketid.thehighestcommittee.com | 192.168.0.5:1411 | External |
| profilarr.thehighestcommittee.com | 192.168.0.11:6868 | Primary |
| prowlarr.thehighestcommittee.com | 192.168.0.11:9696 | Primary |
| qbittorrent.thehighestcommittee.com | 192.168.0.44:8880 | TrueNAS |
| radarr.thehighestcommittee.com | 192.168.0.11:7878 | Primary |
| readarr.thehighestcommittee.com | 192.168.0.11:8787 | Primary |
| recipes.thehighestcommittee.com | 192.168.0.6:8002 | Tandoor |
| romm.thehighestcommittee.com | 192.168.0.11:8808 | Primary |
| ryot.thehighestcommittee.com | 192.168.0.11:8010 | Primary |
| sabnzbd.thehighestcommittee.com | 192.168.0.44:8080 | TrueNAS |
| shelfmark.thehighestcommittee.com | 192.168.0.11:8084 | Primary |
| slskd.thehighestcommittee.com | 192.168.0.11:5030 | Primary |
| sonarr.thehighestcommittee.com | 192.168.0.11:8989 | Primary |
| sportarr.thehighestcommittee.com | 192.168.0.11:1867 | Primary |
| start.thehighestcommittee.com | 192.168.0.11:7575 | Primary |
| suggestarr.thehighestcommittee.com | 192.168.0.11:5000 | Primary |
| tabletop.thehighestcommittee.com | 192.168.0.4:30000 | FoundryVTT |
| tautulli.thehighestcommittee.com | 192.168.0.11:8181 | Primary |
| termix.thehighestcommittee.com | 192.168.0.11:8880 | Primary |
| tinyauth.thehighestcommittee.com | 192.168.0.19:3000 | External |
| watcharr.thehighestcommittee.com | 192.168.0.11:3080 | Primary |
| wizarr.thehighestcommittee.com | 192.168.0.11:5690 | Primary |

</details>

---

## 🗄️ PostgreSQL Databases

<details>
<summary>📋 <strong>Click to expand database list (21 total)</strong></summary>

| 🗄️ Database | 🐳 Service | 📁 Category |
|:------------|:-----------|:------------|
| sonarr-main, sonarr-log | Sonarr | TV |
| radarr-main, radarr-log | Radarr | Movies |
| lidarr-main, lidarr-log | Lidarr | Music |
| prowlarr-main, prowlarr-log | Prowlarr | Indexers |
| readarr-main, readarr-log, readarr-cache | Readarr | Books |
| listenarr-main, listenarr-log, listenarr-cache | ListenArr | Audiobooks |
| mealie | Mealie | Recipes |
| ryot | Ryot | Tracking |
| suggestarr | SuggestArr | AI |
| seerr-db | Overseerr | Requests |
| anythingllm | AnythingLLM | AI |
| ollama | Open-WebUI | AI |

</details>

---

## 🔑 API Keys & Credentials

> 🔒 All sensitive credentials stored in `/opt/stacks/.env`

| 🐳 Service | 🔐 Auth Method | 📍 Location in .env |
|:-----------|:---------------|:--------------------|
| Plex | API Key | `PLEX_TOKEN` |
| Jellyfin | API Key | `JELLYFIN_API_KEY` |
| Overseerr | API Key | `OVERSEERR_API_KEY` |
| Sonarr/Radarr/etc | API Key | Per-service configs |
| Navidrome | Salt+Token | `NAVIDROME_*` |
| Kavita | API Key | `KAVITA_API_KEY` |
| Audiobookshelf | JWT Token | `AUDIOBOOKSHELF_API_KEY` |
| SABnzbd | API Key | `SABNZBD_API_KEY` |
| NPM Plus | Email/Password | `NPMPLUS_*` |
| PostgreSQL | postgres/postgres | `POSTGRES_*` |

---

## 🛠️ Management Scripts

> 📍 Located in `/opt/stacks/scripts/`

| 📜 Script | 🎯 Purpose |
|:----------|:-----------|
| `orchestrate.sh` | Master multi-host orchestration |
| `tammediabox.sh` | TamMediaBox remote management |
| `ai_docker_host.sh` | AI Docker remote management |
| `truenas.sh` | TrueNAS remote management |
| `setup-ssh-automation.sh` | Configure SSH keys to all hosts |
| `secrets-manager.sh` | SOPS/age encryption for .env |
| `sync-all-hosts.sh` | Distribute configs to remote hosts |
| `setup-cron.sh` | Install monitoring cron jobs |
| `quick-ref.sh` | Display command cheatsheet |
| `verify-setup.sh` | Infrastructure health check |

### ⚡ Quick Commands

```bash
./scripts/orchestrate.sh status       # All hosts status
./scripts/setup-ssh-automation.sh     # One-time SSH setup
./scripts/secrets-manager.sh encrypt  # Protect .env
./scripts/sync-all-hosts.sh           # Push to all hosts
```

---

## 📝 Legend

| Symbol | Meaning |
|:------:|:--------|
| ✅ | Has Homepage widget |
| — | Not applicable / None |
| 🟢 | Running |
| 🔴 | Stopped |
| 🔗 | Internal URL |
| 🌍 | External URL |
| 🔒 | Requires authentication |
| 🔄 | Background service |

---

<p align="center">
  <sub>📱 Hosted Applications Directory — TheHighestCommittee Homelab</sub>
</p>
