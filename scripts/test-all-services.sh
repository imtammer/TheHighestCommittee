#!/bin/bash
# Test all major services on 192.168.0.11 for HTTP 200 or open port
# Usage: bash test-all-services.sh

HOST=192.168.0.11
SERVICES=(
  "homepage 3333"
  "sonarr 8989"
  "radarr 7878"
  "prowlarr 9696"
  "overseerr 5055"
  "jellyseerr 5056"
  "bazarr 6767"
  "lidarr 8686"
  "tautulli 8181"
  "notifiarr 5454"
  "kavita 5002"
  "audiobookshelf 13378"
  "navidrome 4533"
  "mealie 9925"
  "romm 8808"
  "suwayomi 4567"
  "mylar3 8090"
  "blissful 7373"
  "sonobarr 5003"
  "flaresolverr 3000"
  "dozzle 8081"
  "homarr 7575"
  "termix 8880"
  "maintainerr 6246"
  "SuggestArr 5000"
  "watcharr 3080"
  "cleanuparr 11011"
)

for svc in "${SERVICES[@]}"; do
  name=$(echo $svc | awk '{print $1}')
  port=$(echo $svc | awk '{print $2}')
  code=$(curl -sk -m5 -w "%{http_code}" -o /dev/null "http://$HOST:$port/")
  if [[ "$code" == "200" ]]; then
    echo "$name on $HOST:$port - HTTP 200 OK"
  else
    echo "$name on $HOST:$port - HTTP $code or not responding"
  fi
done
