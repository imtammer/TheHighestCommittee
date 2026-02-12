#!/bin/bash
# Migrate appdata to ./appdata/servicename/ locations per updated compose files
# Moves data from arrstack/appdata and scattered dirs to correct stack-specific locations

set -e

STACKS="/opt/stacks"
ARRDATA="$STACKS/arrstack/appdata"
MEDIA_ROOT="/media/storage"

move_data() {
    local src="$1"
    local dst="$2"
    local label="$3"
    
    if [ ! -e "$src" ]; then
        echo "  SKIP: $label — source not found: $src"
        return
    fi
    
    if [ -e "$dst" ] && [ "$(ls -A "$dst" 2>/dev/null)" ]; then
        echo "  EXIST: $label — destination already has data: $dst"
        return
    fi
    
    mkdir -p "$(dirname "$dst")"
    echo "  MOVE: $label"
    echo "    from: $src"
    echo "    to:   $dst"
    mv "$src" "$dst"
}

echo "=============================="
echo "=== gameservers ==="
echo "=============================="
mkdir -p "$STACKS/gameservers/appdata"
move_data "$ARRDATA/enshrouded" "$STACKS/gameservers/appdata/enshrouded" "enshrouded"
move_data "$ARRDATA/satisfactory-server" "$STACKS/gameservers/appdata/satisfactory-server" "satisfactory-server"

echo ""
echo "=============================="
echo "=== arr_support ==="
echo "=============================="
mkdir -p "$STACKS/arr_support/appdata"
move_data "$ARRDATA/tunarr" "$STACKS/arr_support/appdata/tunarr" "tunarr"

echo ""
echo "=============================="
echo "=== discord_bots ==="
echo "=============================="
mkdir -p "$STACKS/discord_bots/appdata"
# muse: currently at ./muse/data → move to ./appdata/muse/data
if [ -d "$STACKS/discord_bots/muse" ] && [ ! -d "$STACKS/discord_bots/appdata/muse" ]; then
    move_data "$STACKS/discord_bots/muse" "$STACKS/discord_bots/appdata/muse" "muse (local ./muse)"
elif [ -d "$ARRDATA/muse" ]; then
    move_data "$ARRDATA/muse" "$STACKS/discord_bots/appdata/muse" "muse (arrstack)"
fi
# discodrome: currently at ./discodrome/data → move to ./appdata/discodrome/data
if [ -d "$STACKS/discord_bots/discodrome" ] && [ ! -d "$STACKS/discord_bots/appdata/discodrome" ]; then
    move_data "$STACKS/discord_bots/discodrome" "$STACKS/discord_bots/appdata/discodrome" "discodrome (local ./discodrome)"
elif [ -d "$ARRDATA/discodrome" ]; then
    move_data "$ARRDATA/discodrome" "$STACKS/discord_bots/appdata/discodrome" "discodrome (arrstack)"
fi
# manuel-rw: has data in arrstack but no compose volume (stateless?)
move_data "$ARRDATA/manuel-rw" "$STACKS/discord_bots/appdata/manuel-rw" "manuel-rw"

echo ""
echo "=============================="
echo "=== music ==="
echo "=============================="
mkdir -p "$STACKS/music/appdata"
# sonobarr: currently ./sonobarr → ./appdata/sonobarr
if [ -d "$STACKS/music/sonobarr" ] && [ ! -d "$STACKS/music/appdata/sonobarr" ]; then
    move_data "$STACKS/music/sonobarr" "$STACKS/music/appdata/sonobarr" "sonobarr (local ./sonobarr)"
elif [ -d "$ARRDATA/sonobarr" ]; then
    move_data "$ARRDATA/sonobarr" "$STACKS/music/appdata/sonobarr" "sonobarr (arrstack)"
fi
# slskd: currently at MEDIA_ROOT/ugreen/arrstack/slskd → ./appdata/slskd
move_data "$MEDIA_ROOT/ugreen/arrstack/slskd" "$STACKS/music/appdata/slskd" "slskd (MEDIA_ROOT)"
# Also check arrstack/appdata
move_data "$ARRDATA/slskd" "$STACKS/music/appdata/slskd" "slskd (arrstack)"
# lidify: rename lidify_data → lidify if needed
if [ -d "$STACKS/music/appdata/lidify_data" ] && [ ! -d "$STACKS/music/appdata/lidify" ]; then
    move_data "$STACKS/music/appdata/lidify_data" "$STACKS/music/appdata/lidify" "lidify (rename lidify_data)"
fi

echo ""
echo "=============================="
echo "=== comics_and_manga ==="
echo "=============================="
mkdir -p "$STACKS/comics_and_manga/appdata/kapowarr"
# kapowarr: at MEDIA_ROOT/ugreen/arrstack/appdata/kapowarr-db → ./appdata/kapowarr/db
move_data "$MEDIA_ROOT/ugreen/arrstack/appdata/kapowarr-db" "$STACKS/comics_and_manga/appdata/kapowarr/db" "kapowarr-db (MEDIA_ROOT)"

echo ""
echo "=============================="
echo "=== cooking ==="
echo "=============================="
# mealie: already at ./appdata/mealie, but also in arrstack
move_data "$ARRDATA/mealie" "$STACKS/cooking/appdata/mealie" "mealie (arrstack)"

echo ""
echo "=============================="
echo "=== emulators ==="
echo "=============================="
mkdir -p "$STACKS/emulators/appdata/romm" "$STACKS/emulators/appdata/romm-db"
# romm resources, redis, config
move_data "$MEDIA_ROOT/ugreen/arrstack/romm/romm_resources" "$STACKS/emulators/appdata/romm/resources" "romm resources"
move_data "$MEDIA_ROOT/ugreen/arrstack/romm/romm_redis_data" "$STACKS/emulators/appdata/romm/redis_data" "romm redis_data"
move_data "$MEDIA_ROOT/ugreen/arrstack/romm/config" "$STACKS/emulators/appdata/romm/config" "romm config"
# romm-db mysql_data
move_data "$MEDIA_ROOT/ugreen/arrstack/romm/mysql_data" "$STACKS/emulators/appdata/romm-db/mysql_data" "romm-db mysql_data"
# Also check arrstack/appdata for mysql/redis
move_data "$ARRDATA/mysql" "$STACKS/emulators/appdata/romm-db/mysql_data" "mysql (arrstack, for romm-db)"
move_data "$ARRDATA/redis" "$STACKS/emulators/appdata/romm/redis_data" "redis (arrstack, for romm)"

echo ""
echo "=============================="
echo "=== books ==="
echo "=============================="
mkdir -p "$STACKS/books/appdata"
# readarr: rename bookshelf_config → readarr
if [ -d "$STACKS/books/appdata/bookshelf_config" ] && [ ! -d "$STACKS/books/appdata/readarr" ]; then
    move_data "$STACKS/books/appdata/bookshelf_config" "$STACKS/books/appdata/readarr" "readarr (rename bookshelf_config)"
fi
# listenarr: rename bookshelf_audio → listenarr
if [ -d "$STACKS/books/appdata/bookshelf_audio" ] && [ ! -d "$STACKS/books/appdata/listenarr" ]; then
    move_data "$STACKS/books/appdata/bookshelf_audio" "$STACKS/books/appdata/listenarr" "listenarr (rename bookshelf_audio)"
fi
# booklore: from ./booklore to ./appdata/booklore
if [ -d "$STACKS/books/booklore" ] && [ ! -d "$STACKS/books/appdata/booklore" ]; then
    move_data "$STACKS/books/booklore" "$STACKS/books/appdata/booklore" "booklore (local ./booklore)"
fi
# mariadb: from ./mariadb to ./appdata/mariadb
if [ -d "$STACKS/books/mariadb" ] && [ ! -d "$STACKS/books/appdata/mariadb" ]; then
    move_data "$STACKS/books/mariadb" "$STACKS/books/appdata/mariadb" "mariadb (local ./mariadb)"
fi

echo ""
echo "=============================="
echo "=== utilities ==="
echo "=============================="
mkdir -p "$STACKS/utilities/appdata"
# flaresolverr: from ./flaresolverr to ./appdata/flaresolverr
if [ -d "$STACKS/utilities/flaresolverr" ] && [ ! -d "$STACKS/utilities/appdata/flaresolverr" ]; then
    move_data "$STACKS/utilities/flaresolverr" "$STACKS/utilities/appdata/flaresolverr" "flaresolverr (local ./flaresolverr)"
fi

echo ""
echo "=============================="
echo "=== SUMMARY ==="
echo "=============================="
echo ""
echo "Remaining in arrstack/appdata:"
ls -1 "$ARRDATA/" 2>/dev/null || echo "(empty)"
