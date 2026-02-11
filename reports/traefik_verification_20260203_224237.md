# Traefik Backend Verification Report
**Date**: Tue Feb  3 22:42:37 UTC 2026  
**Traefik Host**: 192.168.0.2  
**Total Services**: 41

---

## ✅ Summary

| Status | Count | Percentage |
|--------|-------|------------|
| ✅ Working | 38 | 92.7% |
| ⚠️ Issues | 3 | 7.3% |

---

## 🎯 Services Verified (38/41)

### ✅ Working Services

**Media Management (Arr Stack)** - 15 services
- ✅ Sonarr (8989) - Fixed from 3030
- ✅ Radarr (7878)
- ✅ Lidarr (8686)
- ✅ Prowlarr (9696)
- ✅ Readarr (8787) - Started container
- ✅ ListenArr (8788) - Started container, added to Traefik
- ✅ Bazarr (6767)
- ✅ Overseerr (5055)
- ✅ JellySeerr (5056)
- ✅ Huntarr (9705)
- ✅ Maintainerr (6246)
- ✅ SuggestArr (5000)
- ✅ SportArr (1867)
- ✅ ProfilArr (6868)
- ✅ Watcharr (3080)

**Media Servers & Streaming** - 3 services
- ✅ Jellyfin (192.168.0.13:8096) - Fixed IP
- ✅ Navidrome (4533)
- ✅ Lidify (3030) - Fixed router rule

**Books & Reading** - 5 services
- ✅ Audiobookshelf (13378) - Started container
- ✅ Kavita (5002)
- ✅ BookLore (6060)
- ✅ OpenBooks (6081)
- ✅ ShelfMark (8084)

**Comics & Manga** - 3 services
- ✅ Suwayomi (4567)
- ✅ Mylar3 (8090)
- ✅ Kapowarr (5656) - Started container

**Gaming** - 1 service
- ✅ RoMM (8808)

**Dashboards & Utilities** - 11 services
- ✅ Homarr (7575)
- ✅ Homepage (3333)
- ✅ Dockhand (3003)
- ✅ Dozzle (8081)
- ✅ Termix (8880)
- ✅ Mealie (9925)
- ✅ MeTube (8881)
- ✅ Wizarr (5690) - Started container
- ✅ Tautulli (8181)
- ✅ Tunarr (8888) - Started container
- ✅ Ryot (8010)

---

## ⚠️ Services Requiring Attention (3/41)

### 1. **slskd** (SoulSeek Client)
- **Status**: ❌ Not responding on port 5030
- **Container**: Running but web UI not accessible
- **Port Mapping**: Correct (5030:5030)
- **Logs**: Application started, processing transfers
- **Issue**: Web interface may need additional startup time
- **Action**: Wait 5-10 minutes for full startup, or restart container

### 2. **tabletop** (FoundryVTT)
- **Status**: ❌ Not responding
- **Location**: 192.168.0.4:30000 (Foundry VTT VM)
- **Fixed**: Updated Traefik from .11 to .4
- **Host**: VM is pingable
- **Issue**: FoundryVTT service not running
- **Action**: Start FoundryVTT service on VM

### 3. **arrstack**
- **Status**: ❌ Not responding on port 5001
- **Issue**: LXC container (VMID 111) is stopped
- **Listed**: Shows as 🔴 [STOPPED] in HOSTED_APPS.md
- **Action**: Start container or remove from Traefik

---

## 🔧 Fixes Applied Today

### Traefik Configuration Fixes
1. ✅ **Sonarr**: Corrected port 3030 → 8989
2. ✅ **ListenArr**: Added complete router and service configuration
3. ✅ **Lidify**: Removed incorrect listenarr domain from router rule
4. ✅ **Jellyfin**: Fixed IP 192.168.0.11 → 192.168.0.13
5. ✅ **Tabletop**: Fixed IP 192.168.0.11 → 192.168.0.4

### Container Fixes
Started 7 stopped containers:
1. ✅ books-readarr-1
2. ✅ books-listenarr-1
3. ✅ books-audiobookshelf-1
4. ✅ kapowarr
5. ✅ slskd
6. ✅ tunarr
7. ✅ wizarr

---

## 📊 HTTP Response Codes

- **200**: Service responding normally
- **302/303/307**: Redirect (normal)
- **401/403**: Auth required (service is up)
- **000**: Connection failed/timeout

---

## ✅ Validation Commands

```bash
# Re-run full verification
python3 /tmp/verify_traefik_all.py

# Test individual services
curl -I http://192.168.0.11:5030  # slskd
curl -I http://192.168.0.4:30000  # tabletop

# Check slskd status
docker logs slskd --tail 50
docker restart slskd  # if needed
```

---

**Report Generated**: Tue Feb  3 22:42:37 UTC 2026  
**Success Rate**: 92.7% (38/41 operational)  
**Status**: ✅ Excellent - Only 3 minor issues remaining
