<p align="center">
  <img src="https://img.shields.io/badge/Hosts-5%20Docker%20%7C%201%20Proxmox-2496ED?style=for-the-badge&logo=docker" />
  <img src="https://img.shields.io/badge/Services-70%2B-success?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Storage-TrueNAS%20%2B%20UGREEN-orange?style=for-the-badge" />
</p>

<h1 align="center">🏗️ Infrastructure Guide</h1>

<p align="center">
  <strong>TheHighestCommittee homelab infrastructure — Multi-host Docker environment</strong>
</p>

---

## 🗺️ Network Topology

```mermaid
graph TD
    subgraph "External Access"
        Internet((Internet))
        CF[Cloudflare DNS]
        Internet --> CF
    end

    subgraph "Edge Network"
        Router[Router / Gateway]
        CF --> Router
    end

    subgraph "Dell PowerEdge Server"
        direction TB
        iDRAC["🔧 iDRAC .50"]
        Proxmox["🏗️ Proxmox .40"]
        
        subgraph "Virtual Machines & LXCs"
            Traefik["Traefik (LXC) .2"]
            TrueNAS["💾 TrueNAS (VM) .44"]
            Osiris["🖥️ Osiris (VM) .11"]
            b_Postgres["🐘 Postgres (VM) .12"]
        end
        
        iDRAC -.- Proxmox
        Proxmox --- Traefik
        Proxmox --- TrueNAS
        Proxmox --- Osiris
        Proxmox --- b_Postgres
        
        Router --> Traefik
    end

    subgraph "Physical Nodes"
        Thoth["🤖 Thoth AI .7"]
        Tam["🎬 TamMediaBox .13"]
    end

    Traefik --> Osiris
    Traefik --> Thoth
    Traefik --> Tam
    Traefik --> TrueNAS
    
    Osiris -.-> TrueNAS
    Osiris -.-> b_Postgres
    Thoth -.-> b_Postgres
```

---

## 💻 Host Overview

| Hostname | Type | IP | Role | Specs | OS |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Dell Server** | **Bare Metal** | `192.168.0.50` | Proxmox Host | Xeon E5-2640 v4 / 128GB | - |
| **Proxmox** | **Hypervisor** | `192.168.0.40` | VM Manager | - | Debian 13 (Trixie) |
| **Osiris** | **VM** | `192.168.0.11` | Docker Core | 47GB RAM | Ubuntu 24.04 |
| **Thoth** | **Physical** | `192.168.0.7` | AI Inference | i7-7700 / 64GB | Ubuntu 25.10 |
| **TamMediaBox** | **Physical** | `192.168.0.13` | Media Player | Ryzen 5 5650GE / 64GB | Ubuntu 25.10 |
| **TrueNAS** | **VM** | `192.168.0.44` | Storage | Xeon E5-2640 v4 / 64GB | Debian 13 |
| **UGREEN** | **NAS** | `192.168.0.8` | SSD/HDD Storage | Pentium Gold 8505 / 64GB | Debian 12 (UGOS) |

<td><code>192.168.0.8</code></td>
<td>SSD Storage</td>
<td>Docker-capable</td>
<td>UGOS Pro</td>
</tr>
<tr>
<td>🗄️ <strong>PostgreSQL</strong></td>
<td><code>192.168.0.12</code></td>
<td>Central DB</td>
<td>22 databases</td>
<td>—</td>
</tr>
<tr>
<td>🔀 <strong>NPM Plus</strong></td>
<td><code>192.168.0.14</code></td>
<td>Reverse Proxy</td>
<td>49 proxy hosts</td>
<td>—</td>
</tr>
<tr>
<td>🔀 <strong>Traefik</strong></td>
<td><code>192.168.0.2</code></td>
<td>Reverse Proxy</td>
<td>Docker auto-discovery</td>
<td>—</td>
</tr>
<tr>
<td>🌐 <strong>phpIPAM</strong></td>
<td><code>192.168.0.116</code></td>
<td>IP Management</td>
<td>Subnet tracking</td>
<td>—</td>
</tr>
<tr>
<td>🖥️ <strong>Proxmox</strong></td>
<td><code>192.168.0.40</code></td>
<td>Hypervisor</td>
<td>VMs & LXC</td>
<td>—</td>
</tr>
<tr>
<td>🔧 <strong>Dell iDRAC</strong></td>
<td><code>192.168.0.50</code></td>
<td>Server Management</td>
<td>PowerEdge R730</td>
<td>—</td>
</tr>
</table>

---

## 🖥️ Primary Docker Host

<table>
<tr><td colspan="2">

### 📍 192.168.0.11 — Main server running all media automation

</td></tr>
</table>

<table>
<tr>
<th>🔌 Access Method</th>
<th>📋 Details</th>
</tr>
<tr><td>🔑 SSH</td><td><code>ssh user@192.168.0.11</code></td></tr>
<tr><td>🏠 Dashboard</td><td><a href="http://192.168.0.11:3333">Homepage :3333</a></td></tr>
<tr><td>📊 Logs</td><td><a href="http://192.168.0.11:8081">Dozzle :8081</a></td></tr>
<tr><td>📂 Config</td><td><code>/opt/stacks/</code></td></tr>
</table>

### 📦 Service Stacks

| 📁 Stack | 🐳 Services | 🎯 Purpose |
|:---------|:------------|:-----------|
| **arrstack/** | Sonarr, Radarr, Lidarr, Prowlarr, Bazarr | Media automation |
| **arr_support/** | SuggestArr, Maintainerr, Huntarr, CleanupArr | Maintenance tools |
| **books/** | Audiobookshelf, Kavita, Readarr, ListenArr | Book management |
| **music/** | Navidrome, Lidify, Sonobarr, Blissful, SLSKD | Music streaming |
| **comics_and_manga/** | Kapowarr, Suwayomi, Mylar3 | Comics & manga |
| **discord_bots/** | Manuel-RW, Muse, Discodrome | Discord bots |
| **utilities/** | Homepage, Dozzle, Homarr, Termix, FlareSolverr | Dashboards & tools |
| **emulators/** | RoMM | ROM management |
| **cooking/** | Mealie | Recipe management |
| **reporting/** | Tautulli, Notifiarr | Analytics |

---

## 🎬 TamMediaBox

<table>
<tr><td colspan="2">

### 📍 192.168.0.13 — Dedicated media server with GPU transcoding

</td></tr>
</table>

<table>
<tr>
<th>🔌 Access Method</th>
<th>📋 Details</th>
</tr>
<tr><td>🔑 SSH</td><td><code>ssh tammer@192.168.0.13</code> or <code>ssh mediabox</code></td></tr>
<tr><td>🎬 Plex</td><td><a href="http://192.168.0.13:32400">:32400</a></td></tr>
<tr><td>🎬 Jellyfin</td><td><a href="http://192.168.0.13:8096">:8096</a></td></tr>
<tr><td>📂 Config</td><td><code>/opt/stacks/TamMediaBox/</code></td></tr>
</table>

### 🐳 Services

| 🎯 Service | 🔌 Port | 🎮 GPU | 📋 Purpose |
|:-----------|:-------:|:------:|:-----------|
| **Plex** | 32400 | ✅ NVIDIA | Primary media server |
| **Jellyfin** | 8096 | ✅ Intel/AMD | Open-source alternative |
| **mstream** | 3000 | — | Web music streaming |
| **Dozzle Agent** | 7007 | — | Remote log monitoring |

### 🎮 GPU Configuration

```yaml
# 🟢 Plex - NVIDIA GPU
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: all
          capabilities: [gpu]

# 🔵 Jellyfin - Intel QuickSync
devices:
  - /dev/dri/renderD128:/dev/dri/renderD128
```

### 📂 Media Libraries

| 📚 Library | 📍 Mount Path | 🐳 Used By |
|:-----------|:--------------|:-----------|
| 📺 TV | `/media/storage/truenas/tv/` | Sonarr, Plex, Jellyfin |
| 🎬 Movies | `/media/storage/ugreen/movies/` | Radarr, Plex, Jellyfin |
| 🎌 Anime | `/media/storage/truenas/anime/` | Sonarr, Plex, Jellyfin |
| 🎵 Music | `/media/storage/truenas/Music/` | Lidarr, Navidrome |
| ⚽ Sports | `/media/storage/truenas/sports/` | SportArr |

---

## 🤖 AI Docker Host

<table>
<tr><td colspan="2">

### 📍 192.168.0.7 — Machine learning and AI services with GPU acceleration

</td></tr>
</table>

<table>
<tr>
<th>🔌 Access Method</th>
<th>📋 Details</th>
</tr>
<tr><td>🔑 SSH</td><td><code>ssh user@192.168.0.7</code> or <code>ssh ai</code></td></tr>
<tr><td>💬 Open-WebUI</td><td><a href="http://192.168.0.7:8080">:8080</a></td></tr>
<tr><td>📄 Paperless</td><td><a href="http://192.168.0.7:8000">:8000</a></td></tr>
<tr><td>📂 Config</td><td><code>/opt/stacks/AI_Docker_Host/</code></td></tr>
</table>

### 🐳 Services

| 🎯 Service | 🔌 Port | 🎮 GPU | 📋 Purpose |
|:-----------|:-------:|:------:|:-----------|
| **Ollama** | 11434 | ✅ | LLM inference (llama2, mistral) |
| **Open-WebUI** | 8080 | — | Chat interface |
| **Whisper ASR** | 9000 | ✅ | Speech-to-text |
| **Subgen** | — | ✅ | AI subtitle generation |
| **Paperless-NGX** | 8000 | — | Document OCR & management |
| **Paperless-AI** | 3001 | — | AI document classification |

### 📄 Document Workflow

```
📥 Intake              →    🔍 OCR/Index     →    📁 Storage     →    🤖 AI Enhancement
─────────────────────────────────────────────────────────────────────────────────────
/documents_consume/    →    Paperless-NGX    →    /documents/    →    Paperless-AI
```

---

## 🔀 NPM Plus

<table>
<tr><td colspan="2">

### 📍 192.168.0.14 — Nginx Proxy Manager Plus (49 active hosts)

</td></tr>
</table>

<table>
<tr>
<th>🔌 Access Method</th>
<th>📋 Details</th>
</tr>
<tr><td>🌐 Admin UI</td><td><a href="https://192.168.0.14:81">:81</a></td></tr>
<tr><td>🌍 External</td><td><a href="https://npmplus.thehighestcommittee.com">npmplus.thehighestcommittee.com</a></td></tr>
<tr><td>👤 Username</td><td><code>imtammer@gmail.com</code></td></tr>
<tr><td>🔑 Password</td><td>Stored in <code>.env</code> as <code>NPMPLUS_PASSWORD</code></td></tr>
</table>

### 📊 Proxy Distribution

| 🖥️ Host | 📊 Count | 🎯 Examples |
|:--------|:--------:|:------------|
| **Primary (0.11)** | 38 | sonarr, radarr, overseerr, kavita |
| **TamMediaBox (0.13)** | 3 | plex, jellyfin, mstream |
| **TrueNAS (0.44)** | 2 | qbittorrent, sabnzbd |
| **AI Docker (0.7)** | 1 | paperless |
| **External** | 5 | pocketid, tinyauth, tabletop |

---

## 🔀 Traefik

<table>
<tr><td colspan="2">

### 📍 192.168.0.2 — Cloud-native reverse proxy with Docker auto-discovery

</td></tr>
</table>

<table>
<tr>
<th>🔌 Access Method</th>
<th>📋 Details</th>
</tr>
<tr><td>📊 Dashboard</td><td><a href="http://192.168.0.2:8080/dashboard/">:8080/dashboard/</a></td></tr>
<tr><td>🔒 HTTPS</td><td><a href="https://192.168.0.2">:443</a></td></tr>
<tr><td>👤 Username</td><td><code>tammer</code></td></tr>
<tr><td>🔑 Password</td><td>Stored in <code>.env</code> as <code>TRAEFIK_PASSWORD</code></td></tr>
</table>

### 🔌 Ports

| Port | Purpose |
|:----:|:--------|
| 80 | HTTP (redirects to HTTPS) |
| 443 | HTTPS termination |
| 8080 | Dashboard & API |

---

## 💾 TrueNAS Scale

<table>
<tr><td colspan="2">

### 📍 192.168.0.44 — Primary NAS with Docker app support

</td></tr>
</table>

<table>
<tr>
<th>🔌 Access Method</th>
<th>📋 Details</th>
</tr>
<tr><td>🌐 Web UI</td><td><a href="http://192.168.0.44">:80</a></td></tr>
<tr><td>🔑 SSH</td><td><code>ssh truenas_admin@192.168.0.44</code> or <code>ssh truenas</code></td></tr>
<tr><td>📦 Dockge</td><td><a href="http://192.168.0.44:31014">:31014</a></td></tr>
<tr><td>👤 Username</td><td><code>truenas_admin</code></td></tr>
<tr><td>🔑 Password</td><td>Stored in <code>.env</code> as <code>TRUENAS_PASSWORD</code></td></tr>
</table>

### 🎯 Hardware Specs (Verified)
- **CPU**: Intel Xeon E5-2640 v4 (Allocated)
- **RAM**: 64 GB (ECC)
- **OS**: Debian 13 (TrueNAS Scale)
- **Storage**:
    -   3x 18TB Seagate Exos X18 (`ST18000NM0292`)
    -   ZFS Pool Management

### 🐳 Docker Services

| 🎯 Service | 🔌 Port | 🌍 External Domain |
|:-----------|:-------:|:-------------------|
| **Dockge** | 31014 | — |
| **qBittorrent** | 8880 | qbittorrent.thehighestcommittee.com |
| **SABnzbd** | 8080 | sabnzbd.thehighestcommittee.com |

### 📂 Storage Shares

> Mounted on all Docker hosts as `/media/storage/truenas/`

| 📚 Share | 📍 Path | 🐳 Used By |
|:---------|:--------|:-----------|
| 📺 TV | `/tv/` | Sonarr, Plex, Jellyfin |
| 🎬 Movies | `/movies/` | Radarr, Plex, Jellyfin |
| 🎌 Anime | `/anime/` | Sonarr, Plex, Jellyfin |
| 🎵 Music | `/Music/` | Lidarr, Navidrome |
| 📚 Books | `/Books/` | Readarr, Kavita |
| 🎧 Audiobooks | `/AudioBooks/` | Audiobookshelf |
| 📖 Comics | `/Comics/` | Kapowarr |
| 📱 Manga | `/manga/` | Suwayomi |
| ⚽ Sports | `/sports/` | SportArr |
| 📥 Downloads | `/downloads/` | qBit, SABnzbd |

---

## 📦 UGREEN NAS

<table>
<tr><td colspan="2">

### 📍 192.168.0.8 — DXP 4800 Plus — SSD-based fast storage

</td></tr>
</table>

<table>
<tr>
<th>🔌 Access Method</th>
<th>📋 Details</th>
</tr>
<tr><td>🌐 Web UI</td><td><a href="http://192.168.0.8:9999">:9999</a></td></tr>
<tr><td>🔑 SSH</td><td><code>ssh tammer@192.168.0.8</code> or <code>ssh ugreen</code></td></tr>
<tr><td>🔒 HTTPS</td><td><a href="https://192.168.0.8:9443">:9443</a></td></tr>
<tr><td>🐳 Docker</td><td>Capable (no containers currently)</td></tr>
</table>

### 🎯 Hardware Specs (Verified)
- **CPU**: Intel Pentium Gold 8505
- **RAM**: 64 GB DDR5
- **OS**: Debian 12 (UGOS Pro)
- **Storage**:
    -   4x 16TB Seagate Exos X16 (`ST16000NM000G`)
    -   High-speed SSD Volume for Appdata

### 📂 Storage Shares

> Mounted as `/media/storage/ugreen/`

| 📚 Share | 📍 Path | 🎯 Purpose |
|:---------|:--------|:-----------|
| 🎬 Movies | `/movies/` | Fast SSD cache |
| 📥 Downloads | `/downloads/` | Active downloads |
| ⚙️ Appdata | `/arrstack/appdata/` | Service databases |
| 📄 Documents | `/documents/` | Paperless storage |

### 🎯 Role
- ⚡ **Fast cache** for active downloads
- 💾 **SSD storage** for database-heavy services
- 🔄 **Complements TrueNAS** (fast SSD + large HDD tiering)

---

## 🗄️ PostgreSQL Server

<table>
<tr><td colspan="2">

### 📍 192.168.0.12 — Centralized database server (21 databases)

</td></tr>
</table>

<table>
<tr>
<th>🔌 Access Method</th>
<th>📋 Details</th>
</tr>
<tr><td>🔌 Host</td><td><code>192.168.0.12</code></td></tr>
<tr><td>🔌 Port</td><td><code>5432</code></td></tr>
<tr><td>👤 Username</td><td><code>postgres</code></td></tr>
<tr><td>🔑 Password</td><td><code>postgres</code></td></tr>
<tr><td>🌐 Adminer</td><td><a href="http://192.168.0.12/adminer/">:80/adminer/</a></td></tr>
</table>

### 📋 Connection String
```
postgresql://postgres:postgres@192.168.0.12:5432/DATABASE_NAME
```

### 📊 Databases (22 total)

| 📁 Category | 🗄️ Databases |
|:------------|:-------------|
| **Arr Stack** | sonarr-main, sonarr-log, radarr-main, radarr-log, lidarr-main, lidarr-log |
| | prowlarr-main, prowlarr-log, readarr-main, readarr-log, readarr-cache |
| | listenarr-main, listenarr-log, listenarr-cache, booklore |
| **Apps** | mealie, ryot, suggestarr, seerr-db |
| **AI** | anythingllm, ollama |
| **System** | postgres |

---

## 🖥️ Proxmox VE

<table>
<tr><td colspan="2">

### 📍 192.168.0.40 — Hypervisor running all infrastructure (Node: khemt)

</td></tr>
</table>

<table>
<tr>
<th>🔌 Access Method</th>
<th>📋 Details</th>
</tr>
<tr><td>🌐 Web UI</td><td><a href="https://192.168.0.40:8006">:8006</a></td></tr>
<tr><td>🔑 SSH</td><td><code>ssh root@192.168.0.40</code> or <code>ssh proxmox</code></td></tr>
<tr><td>👤 Username</td><td><code>root</code></td></tr>
<tr><td>🔑 Password</td><td>Stored in <code>.env</code> as <code>PROXMOX_PASSWORD</code></td></tr>
<tr><td>🔑 API Token</td><td><code>root@pam!homepage</code></td></tr>
</table>

### 🖥️ Virtual Machines (QEMU)

| VMID | 🏷️ Name | 📊 Status | 💻 CPU | 🧠 RAM | 💾 Disk | 📍 IP | 🎯 Purpose |
|:----:|:--------|:--------:|:------:|:------:|:-------:|:-----:|:-----------|
| 103 | **TrueNAS** | 🟢 | 8 cores | 64GB | 80GB | .44 | NAS + Docker |
| 104 | **foundry** | 🟢 | 2 cores | 4GB | 80GB | .4 | Foundry VTT |
| 105 | **osiris** | 🟢 | 20 cores | 48GB | 1TB | .11 | Primary Docker Host |

### 📦 LXC Containers

| VMID | 🏷️ Name | 📊 Status | 💻 CPU | 🧠 RAM | 💾 Disk | 📍 IP | 🎯 Purpose |
|:----:|:--------|:--------:|:------:|:------:|:-------:|:-----:|:-----------|
| 100 | **npmplus** | 🟢 | 1 core | 512MB | 3GB | .14 | Nginx Proxy Manager |
| 101 | **traefik** | 🟢 | 1 core | 2GB | 20GB | .2 | Traefik Proxy |
| 102 | **recipes** | 🟢 | 4 cores | 16GB | 80GB | .6 | Tandoor Recipes |
| 111 | **arrstack** | 🔴 | 16 cores | 16GB | 2TB | .11 | [STOPPED] Legacy |
| 112 | **postgresql** | 🟢 | 2 cores | 8GB | 125GB | .12 | Central Database |
| 119 | **phpipam** | 🟢 | 1 core | 512MB | 4GB | .116 | IP Management |

### 📊 Resource Summary

| Metric | Value |
|:-------|:------|
| **Total VMs** | 3 running |
| **Total LXCs** | 5 running, 1 stopped |
| **Allocated CPU** | 38 cores |
| **Allocated RAM** | ~145GB |

---

## 🛡️ UniFi Dream Machine SE (Gateway)

<table>
<tr><td colspan="2">

### 📍 192.168.0.1 — Network Core, Firewall, and IPS/IDS

</td></tr>
</table>

<table>
<tr>
<th>🔌 Access Method</th>
<th>📋 Details</th>
</tr>
<tr><td>🌐 Console</td><td><a href="https://192.168.0.1">unifi.ui.com</a> (Local)</td></tr>
<tr><td>🔑 SSH</td><td><code>ssh root@192.168.0.1</code></td></tr>
<tr><td>💻 CPU</td><td>Quad-Core ARM Cortex-A57</td></tr>
<tr><td>🧠 RAM</td><td>4 GB DDR4</td></tr>
<tr><td>💾 Storage</td><td>128 GB SSD (Internal) + 8 TB HDD (Protect)</td></tr>
<tr><td>📡 WAN</td><td>Interface <code>eth8</code> (2.5GbE)</td></tr>
<tr><td>🕸️ LAN</td><td>Bridge <code>br0</code> (192.168.0.0/24)</td></tr>
<tr><td>⚙️ Firmware</td><td>v5.0.12</td></tr>
</table>

### 🚦 Traffic Flow & Firewall Strategy

1.  **WAN Ingress (eth8)**:
    *   Public IP establishes connection.
    *   **IPS/IDS** scans for threats (Level 5).
2.  **NAT & Port Forwarding**:
    *   **HTTP (80)** ➔ **Traefik** (192.168.0.2:80)
    *   **HTTPS (443)** ➔ **Traefik** (192.168.0.2:443)
    *   *Note: All external access is routed through Traefik.*
3.  **LAN Switching (br0)**:
    *   Traffic routed to Hosts (Osiris, Thoth, etc.) on `192.168.0.x`.
    *   WireGuard VPN terminates directly on UDM.

---

## 🔧 Dell PowerEdge R730

<table>
<tr><td colspan="2">

### 📍 192.168.0.50 — iDRAC Server Management (Physical Host)

</td></tr>
</table>

<table>
<tr>
<th>🔌 Access Method</th>
<th>📋 Details</th>
</tr>
<tr><td>🌐 iDRAC</td><td><a href="https://192.168.0.50">:443</a></td></tr>
<tr><td>💻 CPU</td><td>Intel Xeon E5-2640 v4</td></tr>
<tr><td>🧠 RAM</td><td>128GB DDR4</td></tr>
<tr><td>💾 Storage</td><td>4TB HDD</td></tr>
<tr><td>🎯 Purpose</td><td>Hosts Proxmox VE</td></tr>
</table>

---

## 🔗 Cross-Host Communication

```
┌─────────────────┐     API calls      ┌─────────────────┐
│    🖥️ Primary   │ ◄────────────────► │  🎬 TamMediaBox │
│   192.168.0.11  │   Jellyfin API     │   192.168.0.13  │
│                 │   Plex webhooks    │                 │
│  Overseerr      │                    │  Plex/Jellyfin  │
│  Jellyseerr     │                    │                 │
└────────┬────────┘                    └─────────────────┘
         │
         │ LLM API, Whisper
         ▼
┌─────────────────┐
│   🤖 AI Docker  │
│   192.168.0.7   │
│                 │
│  Ollama         │
│  Whisper-ASR    │
│  Subgen ───────────► Plex (0.13) for subtitle injection
└────────┬────────┘
         │
         │ PostgreSQL connections
         ▼
┌─────────────────┐
│  🗄️ PostgreSQL  │ ◄──── All Arr apps store databases here
│   192.168.0.12  │
└─────────────────┘
```

---

## 🛠️ Management Scripts

All scripts located in `/opt/stacks/scripts/`:

| 📜 Script | 🎯 Purpose | 💻 Usage |
|:----------|:-----------|:---------|
| `orchestrate.sh` | Master multi-host control | `./orchestrate.sh status\|up\|down\|restart\|logs` |
| `tammediabox.sh` | TamMediaBox management | `./tammediabox.sh status\|up\|down\|logs` |
| `ai_docker_host.sh` | AI Docker management | `./ai_docker_host.sh status\|up\|down\|logs` |
| `truenas.sh` | TrueNAS management | `./truenas.sh status\|logs` |
| `setup-ssh-automation.sh` | SSH key setup to all hosts | Run once for passwordless SSH |
| `secrets-manager.sh` | SOPS/age encryption | `./secrets-manager.sh init\|encrypt\|decrypt\|sync` |
| `sync-all-hosts.sh` | Push configs to all hosts | Syncs .env, docs to remote hosts |
| `setup-cron.sh` | Install monitoring crons | Background health checks |
| `quick-ref.sh` | Quick reference display | Common commands cheatsheet |
| `verify-setup.sh` | Infrastructure verification | Pre-flight checks |

### 🔑 SSH Shortcuts

> After running `setup-ssh-automation.sh`:

```bash
ssh mediabox    # → tammer@192.168.0.13 (TamMediaBox)
ssh ai          # → tammer@192.168.0.7 (AI Docker)
ssh truenas     # → truenas_admin@192.168.0.44 (TrueNAS)
ssh ugreen      # → tammer@192.168.0.8 (UGREEN NAS)
ssh proxmox     # → root@192.168.0.40 (Proxmox)
```

---

## 📚 Quick Reference

### 🔌 Common Ports

| Port | Service |
|:----:|:--------|
| 80/443 | HTTP/HTTPS (reverse proxy) |
| 5432 | PostgreSQL |
| 3306 | MariaDB |
| 6379 | Redis |
| 8081 | Dozzle |
| 32400 | Plex |
| 8096 | Jellyfin |
| 11434 | Ollama API |

### 📂 Storage Paths

```bash
# Primary config
/opt/stacks/arrstack/appdata/

# NAS media (HDD)
/media/storage/truenas/

# SSD cache
/media/storage/ugreen/
```

---

## 📝 Notes

| 🏷️ | 📋 Note |
|:--:|:--------|
| 🔒 | **Internal access** requires LAN (192.168.0.0/24) |
| 🌐 | **External access** via reverse proxy with DNS |
| 🎮 | **GPU services**: Plex, Jellyfin, Ollama, Whisper, Subgen |
| 🤖 | **Background services** may not have Web UIs (bots, workers) |
| 📋 | Check `.env` for all credentials and API keys |
| 📊 | Use **Dozzle** (port 8081) for real-time container monitoring |
| 🔐 | **Secrets** encrypted with SOPS + age (key in `.secrets/age-key.txt`) |

---

<p align="center">
  <sub>🏗️ Infrastructure Guide — TheHighestCommittee Homelab</sub>
</p>
