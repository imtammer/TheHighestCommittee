# AI Agent Context Guide

**Last Updated:** 2026-02-11

## 🧠 Repository Overview

This is a **Production Homelab** spanning 5 physical/virtual hosts, managed via **Docker Compose**.
All non-persistence configuration is centralized in `/opt/stacks/` on **Osiris** (Primary Controller).

### 🌍 Infrastructure Map (Verified)

| Hostname | Role | IP | OS | CPU | RAM |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **UDM-SE** | **Gateway** | `.1` | UniFi OS 5 | ARM Cortex-A57 | 4 GB |
| **Dell R730** | **Bare Metal** | `.50` | iDRAC 8 | Xeon E5-2640 v4 | 128 GB |
| **Proxmox** | **Hypervisor** | `.40` | Debian 13 | (Host) | 128 GB |
| **Osiris** | **Docker Controller** | `.11` | Ubuntu 24.04 | 20 vCPU | 47 GB |
| **TrueNAS** | **Storage** | `.44` | Debian 13 | 8 vCPU | 64 GB |
| **Thoth** | **AI Inference** | `.7` | Ubuntu 25.10 | i7-7700 | 64 GB |
| **TamMediaBox** | **Media** | `.13` | Ubuntu 25.10 | Ryzen 5 PRO | 64 GB |
| **UGREEN** | **NAS/Cache** | `.8` | Debian 12 | Pentium 8505 | 64 GB |

---

## 🚦 Network & Security

1.  **Edge Proxy**: **Traefik** (`192.168.0.2`) handles ALL external traffic (Port 80/443).
    *   **NO Nginx Proxy Manager (NPM)**. Do not mention it.
2.  **Internal Network**: All stacks attach to `external: true` network named `shared`.
3.  **Secrets**:
    *   Stored in `.env` files (git-ignored).
    *   Templates in `.env.example`.
    *   **NEVER** commit secrets.
4.  **Firewall**:
    *   UDM-SE blocks Inter-VLAN traffic.
    *   Traefik is the only ingress point for web services.

---

## 📂 File System Standards

-   **Base Path**: `/opt/stacks/<stack_name>/`
-   **Compose File**: `compose.yaml` (NOT `docker-compose.yml`)
-   **Data Persistence**:
    *   **Local Config**: `./appdata/<service_name>` (Relative path)
    *   **Media**: `/media/storage/truenas/` or `/media/storage/ugreen/`
    *   **NEVER** use centralized `/opt/stacks/arrstack/appdata` (Deprecated).

---

## 🛠️ Management Tools

| Command | Action |
| :--- | :--- |
| `./scripts/orchestrate.sh` | **Master CLI** for all hosts (`status`, `up`, `restart`) |
| `./scripts/sync-all-hosts.sh` | Pushes Configs & Docs to remote nodes |
| `./scripts/secrets-manager.sh` | Encrypt/Decrypt secrets via SOPS |

---

## 🤖 Agent Directives

1.  **Context First**: Always check `INFRASTRUCTURE.md` before assuming hardware capabilities.
2.  **Verification**: If a user asks about "NPM", correct them: "We use Traefik now."
3.  **Safety**: Do not edit `.env` files directly unless explicitly asked. Use `.env.example` for reference.
4.  **Style**: Use `docker compose` (v2), not `docker-compose` (v1).
