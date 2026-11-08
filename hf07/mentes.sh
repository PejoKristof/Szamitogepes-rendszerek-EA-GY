#!/usr/bin/env bash

set -euo pipefail
PATH="/usr/bin:/bin"
export PATH
umask 077

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Hasznalat: $0 forraskonyvtar celkonyvtar [megtartando_db]"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "Hiba: a forraskonyvtar nem letezik."
    exit 1
fi

SOURCE=$(cd "$1" && pwd -P)
DEST="$2"
RETENTION="${3:-7}"

if ! [[ "$RETENTION" =~ ^[1-9][0-9]*$ ]]; then
    echo "Hiba: a megtartando darabszam pozitiv egesz szam legyen."
    exit 1
fi

mkdir -p "$DEST"
DEST=$(cd "$DEST" && pwd -P)

if [ "$DEST" = "$SOURCE" ] || [ "$SOURCE" = "/" ] || [[ "$DEST" == "$SOURCE/"* ]]; then
    echo "Hiba: a celkonyvtar nem lehet a forraskonyvtaron belul."
    exit 1
fi

LOG="$DEST/mentes.log"
LOCK="$DEST/.mentes.lock"

exec 9>"$LOCK"
if ! flock -n 9; then
    echo "A mentes mar fut, ez a peldany nem indul el." >&2
    echo "$(date '+%Y-%m-%d %H:%M:%S') A mentes mar fut, uj peldany kihagyva." >> "$LOG"
    exit 0
fi

exec >> "$LOG" 2>&1

echo "----------------------------------------"
echo "$(date '+%Y-%m-%d %H:%M:%S') Mentes indult."
echo "Forras: $SOURCE"
echo "Cel: $DEST"

DATE=$(date '+%Y-%m-%d-%H%M')
NAME="mentes-$DATE.tar.gz"
ARCHIVE="$DEST/$NAME"

if [ -e "$ARCHIVE" ]; then
    echo "Hiba: ilyen nevu mentes mar letezik: $NAME"
    exit 1
fi

tar -czf "$ARCHIVE" -C "$SOURCE" .

(
    cd "$DEST"
    sha256sum "$NAME" > "$NAME.sha256"
)

SIZE=$(du -h "$ARCHIVE" | awk '{print $1}')
COUNT=$(find "$SOURCE" -type f | wc -l | tr -d ' ')

{
    echo "Keszult: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Meret: $SIZE"
    echo "Fajlok szama: $COUNT"
} > "$ARCHIVE.meta"

echo "Elkeszult: $NAME"
echo "Meret: $SIZE"
echo "Fajlok szama: $COUNT"

mapfile -t BACKUPS < <(
    find "$DEST" -maxdepth 1 -type f -name 'mentes-*.tar.gz' -printf '%f\n' |
    grep -E '^mentes-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{4}\.tar\.gz$' |
    sort
)

REMOVE_COUNT=$((${#BACKUPS[@]} - RETENTION))

if [ "$REMOVE_COUNT" -gt 0 ]; then
    for ((i = 0; i < REMOVE_COUNT; i++)); do
        OLD="${BACKUPS[$i]}"
        echo "Regi mentes torlese: $OLD"
        rm -f "$DEST/$OLD" "$DEST/$OLD.sha256" "$DEST/$OLD.meta"
    done
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') Mentes befejezodott."
