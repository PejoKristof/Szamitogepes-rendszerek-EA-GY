#!/usr/bin/env bash

set -euo pipefail
PATH="/usr/bin:/bin"
export PATH
umask 077

if [ "$#" -lt 2 ]; then
    echo "Hasznalat: $0 mentes_konyvtar celkonyvtar [mentesnev|--legutobbi] [--proba]"
    exit 1
fi

BACKUP_DIR="$1"
DEST="$2"
shift 2

if [ ! -d "$BACKUP_DIR" ]; then
    echo "Hiba: a menteseket tartalmazo konyvtar nem letezik."
    exit 1
fi

BACKUP_DIR=$(cd "$BACKUP_DIR" && pwd -P)

PROBA=0
BACKUP_NAME=""

for ARG in "$@"; do
    if [ "$ARG" = "--proba" ]; then
        PROBA=1
    elif [ -z "$BACKUP_NAME" ]; then
        BACKUP_NAME="$ARG"
    else
        echo "Hiba: tul sok argumentum."
        exit 1
    fi
done

mapfile -t BACKUPS < <(
    find "$BACKUP_DIR" -maxdepth 1 -type f -name 'mentes-*.tar.gz' -printf '%f\n' |
    grep -E '^mentes-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{4}\.tar\.gz$' |
    sort
)

echo "Elerheto mentesek:"
if [ "${#BACKUPS[@]}" -eq 0 ]; then
    echo "Nincs elerheto mentes."
else
    for NAME in "${BACKUPS[@]}"; do
        SIZE=$(du -h "$BACKUP_DIR/$NAME" | awk '{print $1}')
        echo "${NAME#mentes-}  $SIZE"
    done
fi

if [ -z "$BACKUP_NAME" ]; then
    echo "Valassz egy mentest nevvel, vagy hasznald a --legutobbi kapcsolot."
    exit 0
fi

if [ "$BACKUP_NAME" = "--legutobbi" ]; then
    if [ "${#BACKUPS[@]}" -eq 0 ]; then
        echo "Hiba: nincs visszaallithato mentes."
        exit 1
    fi
    BACKUP_NAME="${BACKUPS[${#BACKUPS[@]}-1]}"
fi

if ! [[ "$BACKUP_NAME" =~ ^mentes-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{4}\.tar\.gz$ ]]; then
    echo "Hiba: ervenytelen mentesnev."
    exit 1
fi

ARCHIVE="$BACKUP_DIR/$BACKUP_NAME"
CHECKSUM="$ARCHIVE.sha256"

if [ ! -f "$ARCHIVE" ] || [ ! -f "$CHECKSUM" ]; then
    echo "Hiba: a mentes vagy az ellenorzoosszeg fajl nem talalhato."
    exit 1
fi

echo "Ellenorzes: $BACKUP_NAME"
(
    cd "$BACKUP_DIR"
    sha256sum -c "$BACKUP_NAME.sha256"
)

if [ "$PROBA" -eq 1 ]; then
    echo "Proba mod: a celkonyvtar nem valtozott."
    echo "A kovetkezo fajlok kerulnenek vissza:"
    tar -tzf "$ARCHIVE"
    exit 0
fi

mkdir -p "$DEST"
DEST=$(cd "$DEST" && pwd -P)

TEMP=$(mktemp -d "$DEST/.visszaallitas.XXXXXX")
trap 'rm -rf "$TEMP"' EXIT

tar -xzf "$ARCHIVE" -C "$TEMP"

HIBA=0
while IFS= read -r -d '' ITEM; do
    RELATIVE="${ITEM#"$TEMP"/}"
    if [ -e "$DEST/$RELATIVE" ] || [ -L "$DEST/$RELATIVE" ]; then
        echo "Utk ozes, mar letezik: $RELATIVE"
        HIBA=1
    fi
done < <(find "$TEMP" -mindepth 1 -print0)

if [ "$HIBA" -eq 1 ]; then
    echo "A visszaallitas megszakadt, semmi nem lett felulirva."
    exit 1
fi

cp -a "$TEMP/." "$DEST/"
echo "A visszaallitas sikeresen befejezodott."
