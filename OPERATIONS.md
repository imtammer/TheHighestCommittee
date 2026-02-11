# Operations Guide

**Last Updated:** 2026-02-11
Quick reference for commands, automation, and troubleshooting across all homelab hosts.

---

### 🔐 Managing Secrets & Variables
All sensitive data and configuration variables are stored in `.env` files within each stack directory.
**Do not hardcode passwords or API keys in `compose.yaml`.**

**To update a password or key:**
1. Navigate to the stack: `cd /opt/stacks/<stack_name>`
2. Edit the `.env` file: `nano .env`
3. Update the variable (e.g., `API_KEY=new_value`)
4. Recreate the container: `docker compose up -d`

**Standard Variables:**
- `MEDIA_ROOT=/media/storage`
- `PUID=1000`, `PGID=1000`

## Docker Commands (Primary Host)

```bash
# Stack management
cd /opt/stacks/<stack_name> && docker compose up -d --remove-orphans
cd /opt/stacks/<stack_name> && docker compose down
cd /opt/stacks/<stack_name> && docker compose pull && docker compose up -d

# Container operations
docker stats --no-stream                                    # Resource usage
docker logs <container> --tail 100 -f                       # Live logs
docker exec -it <container> bash                            # Shell access
docker inspect <container> --format '{{.State.Status}}'     # Status

# Network
docker network inspect shared -f '{{len .Containers}}'     # Count on shared network
docker network inspect shared -f '{{range .Containers}}{{.Name}} | {{end}}'  # List names

# Cleanup
docker system prune -af --volumes                          # ⚠️ Remove unused everything
docker image prune -af                                     # Remove unused images only
```

### Resource Monitoring

```bash
# All container stats
docker stats --no-stream

# Specific services
docker stats --no-stream sonarr radarr lidarr prowlarr

# Check resource limits
docker inspect <container> --format '{{.HostConfig.NanoCpus}} {{.HostConfig.Memory}}'
```

---

## Multi-Host SSH Access

| Shortcut | Target | IP | User |
|:---------|:-------|:---|:-----|
| `ssh mediabox` | TamMediaBox | 192.168.0.13 | tammer |
| `ssh ai` | AI Docker Host | 192.168.0.7 | tammer |
| `ssh truenas` | TrueNAS | 192.168.0.44 | truenas_admin |
| `ssh ugreen` | UGREEN NAS | 192.168.0.8 | tammer |
| `ssh gateway` | UDM-SE | 192.168.0.1 | root |
| `ssh proxmox` | Proxmox VE | 192.168.0.40 | root |

```bash
# Setup SSH keys (one-time)
./scripts/setup-ssh-automation.sh setup

# Test connectivity
./scripts/setup-ssh-automation.sh test
```

---

## Orchestration Scripts

All scripts in `/opt/stacks/scripts/`.

### orchestrate.sh — Master Control

```bash
# Global operations (all hosts)
./scripts/orchestrate.sh check-all      # Health check all hosts
./scripts/orchestrate.sh status-all     # Container status
./scripts/orchestrate.sh health-all     # HTTP + GPU checks
./scripts/orchestrate.sh sync-all       # Download configs (creates backups)
./scripts/orchestrate.sh push-all       # Upload .env changes
./scripts/orchestrate.sh start-all      # Start all services
./scripts/orchestrate.sh stop-all       # Stop all services

# Host-specific
./scripts/orchestrate.sh tmb <cmd>      # TamMediaBox
./scripts/orchestrate.sh ai <cmd>       # AI Docker Host
./scripts/orchestrate.sh truenas <cmd>  # TrueNAS
```

### Host-Specific Scripts

| Script | Host | Commands |
|:-------|:-----|:---------|
| `tammediabox.sh` | 192.168.0.13 | check, health, ps, sync, push, start, stop, restart, logs [service] |
| `ai_docker_host.sh` | 192.168.0.7 | check, health, ps [stack], sync, push, start [stack], stop [stack], logs [stack] [service] |
| `truenas.sh` | 192.168.0.44 | check, health, ps, sync, push, start, stop |

### sync-all-hosts.sh — Config Distribution

```bash
./scripts/sync-all-hosts.sh all         # Everything
./scripts/sync-all-hosts.sh env         # .env files only
./scripts/sync-all-hosts.sh docs        # Documentation
./scripts/sync-all-hosts.sh scripts     # Management scripts
./scripts/sync-all-hosts.sh verify      # Check sync status
```

### Cross-Reference Validation

Validates service configs match across NPM Plus, Traefik, and HOSTED_APPS.md:

```bash
./scripts/cross_reference_automation.sh           # Full report
./scripts/npm_traefik_sync.py                     # Quick check
./scripts/npm_traefik_sync.py --no-traefik        # Skip Traefik
```

Reports saved to `/opt/stacks/reports/`.

---

## Cron Jobs

```bash
./scripts/setup-cron.sh                 # Install all cron jobs
crontab -l | grep orchestrate           # View installed jobs
```

| Time | Task |
|:-----|:-----|
| 6:00 AM daily | Health check all hosts |
| 2:00 AM Sunday | Weekly config sync |
| Every 6h | Status check |

**Logs:** `/var/log/stacks/health-check.log`, `/var/log/stacks/sync.log`, `/var/log/stacks/check.log`

---

## Shell Aliases

```bash
# Load aliases (add to ~/.bashrc)
source /opt/stacks/.stacks-aliases

# Available aliases
stacks-check        # orchestrate.sh check-all
stacks-health       # orchestrate.sh health-all
stacks-status       # orchestrate.sh status-all
stacks-sync         # orchestrate.sh sync-all
stacks-push         # orchestrate.sh push-all
stacks-start        # orchestrate.sh start-all
stacks-stop         # orchestrate.sh stop-all
tmb-check           # orchestrate.sh tmb check
ai-check            # orchestrate.sh ai check
ai-gpu              # GPU status on AI host
```

---

## Troubleshooting

### Container Won't Start
```bash
docker compose logs <service> --tail 50                 # Check logs
docker compose config                                    # Validate YAML
docker inspect <container> --format '{{.State.Error}}'   # Error message
```

### Port Conflict
```bash
ss -tlnp | grep <port>
docker ps --format '{{.Ports}}' | grep <port>
```

### DNS/Network Issues
```bash
docker exec <container> nslookup <hostname>
docker network inspect shared | jq '.[0].Containers'
```

### SSH Connection Failed
```bash
ssh -v <alias>                                           # Verbose debug
chmod 600 ~/.ssh/id_ed25519                              # Fix permissions
./scripts/setup-ssh-automation.sh test                   # Test all hosts
```

### Plex Remote Access
- Ensure port 32400 is forwarded on router
- Set `ADVERTISE_IP=http://192.168.0.13:32400` in Plex config
- Traefik needs `Host` and `X-Forwarded-*` headers configured

### Database Connection
```bash
# Connect to central PostgreSQL
psql -h 192.168.0.12 -U postgres -d <database>

# List databases
psql -h 192.168.0.12 -U postgres -c "\\l"
```

---

## Compose File Template

```yaml
services:
  newservice:
    image: org/image:latest
    container_name: newservice
    restart: unless-stopped
    ports:
      - 8080:80
    environment:
      - TZ=America/Los_Angeles
      - PUID=1000
      - PGID=1000
    volumes:
      - /opt/stacks/<stack>/appdata/newservice:/config
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
networks:
  default:
    name: shared
    external: true
```

### Resource Limit Tiers

| Tier | CPUs | RAM | Examples |
|------|------|-----|----------|
| Heavy Media | 2.0 | 2G | Sonarr, Radarr, Lidarr, Kavita |
| Game Servers | 4.0 | 16G | Enshrouded, Palworld, ASA |
| Standard | 0.5–1.0 | 1G | Overseerr, Prowlarr, Readarr, Mealie |
| Light | 0.5 | 512M | Jellyseerr, Bots, Trackers, Notifiarr |
| Minimal | 0.25 | 256M | Profilarr |

---

## Directory Structure

```
/opt/stacks/                    # All compose stacks
├── <stack>/compose.yaml        # Stack definitions
├── <stack>/appdata/            # Persistent container data
├── scripts/                    # Automation scripts
├── reports/                    # Validation reports
├── TamMediaBox/                # Synced configs from .13
└── AI_Docker_Host/             # Synced configs from .7

/opt/dockge/                    # Dockge stack manager
/opt/dockhand/                  # Dockhand Docker UI
/media/storage/truenas/         # TrueNAS NFS mount
/media/storage/ugreen/          # UGREEN NFS mount
```
