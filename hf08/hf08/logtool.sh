#!/usr/bin/env bash
set -euo pipefail

readonly EX_OK=0
readonly EX_USAGE=2
readonly EX_NOFILE=3

FILE=""
TOP=10
STATUS=""
OUTPUT=""
QUIET=0

usage() {
    cat <<'EOF'
Hasznalat: ./logtool.sh -f FAJL [KAPCSOLOK]

Kapcsolok:
  -h, --help        Hasznalat kiirasa
  -f, --file FAJL   Feldolgozando Apache access log (kotelezo)
  -t, --top N       Toplista merete (alapertelmezes: 10)
  -s, --status KOD  Csak a megadott HTTP statuszkodu sorok
  -o, --output FAJL Riport mentese fajlba
  -q, --quiet       Csak a vegso osszefoglalo sor kiirasa
EOF
}

parse_args() {
    local arg
    while [[ $# -gt 0 ]]; do
        arg="$1"
        case "$arg" in
            -h|--help)
                usage
                exit "$EX_OK"
                ;;
            -f|--file)
                if [[ $# -lt 2 ]]; then
                    echo "Hiba: a $arg kapcsolohoz fajlnevet kell megadni." >&2
                    usage >&2
                    return "$EX_USAGE"
                fi
                FILE="$2"
                shift 2
                ;;
            -t|--top)
                if [[ $# -lt 2 ]]; then
                    echo "Hiba: a $arg kapcsolohoz darabszamot kell megadni." >&2
                    usage >&2
                    return "$EX_USAGE"
                fi
                TOP="$2"
                shift 2
                ;;
            -s|--status)
                if [[ $# -lt 2 ]]; then
                    echo "Hiba: a $arg kapcsolohoz statuszkodot kell megadni." >&2
                    usage >&2
                    return "$EX_USAGE"
                fi
                STATUS="$2"
                shift 2
                ;;
            -o|--output)
                if [[ $# -lt 2 ]]; then
                    echo "Hiba: a $arg kapcsolohoz kimeneti fajlt kell megadni." >&2
                    usage >&2
                    return "$EX_USAGE"
                fi
                OUTPUT="$2"
                shift 2
                ;;
            -q|--quiet)
                QUIET=1
                shift
                ;;
            -*)
                echo "Hiba: ismeretlen kapcsolo: $arg" >&2
                usage >&2
                return "$EX_USAGE"
                ;;
            *)
                echo "Hiba: nem vart parameter: $arg" >&2
                usage >&2
                return "$EX_USAGE"
                ;;
        esac
    done
}

ellenoriz_bemenet() {
    if [[ -z "$FILE" ]]; then
        echo "Hiba: a -f vagy --file kapcsolo kotelezo." >&2
        usage >&2
        return "$EX_USAGE"
    fi
    if [[ ! -f "$FILE" || ! -r "$FILE" ]]; then
        echo "Hiba: a fajl nem talalhato vagy nem olvashato: $FILE" >&2
        return "$EX_NOFILE"
    fi
    if [[ ! "$TOP" =~ ^[1-9][0-9]*$ ]]; then
        echo "Hiba: a toplista merete pozitiv egesz szam legyen." >&2
        return "$EX_USAGE"
    fi
    if [[ -n "$STATUS" && ! "$STATUS" =~ ^[1-5][0-9][0-9]$ ]]; then
        echo "Hiba: a statuszkod haromjegyu HTTP-kod legyen." >&2
        return "$EX_USAGE"
    fi
}

top_ip() {
    local status_filter="$STATUS"
    echo "Leggyakoribb IP-cimek:"
    awk -v wanted="$status_filter" '
        $1 != "" && (wanted == "" || $9 == wanted) { count[$1]++ }
        END { for (ip in count) print count[ip], ip }
    ' "$FILE" | sort -nr -k1,1 -k2,2 |
        awk -v top="$TOP" 'NR <= top { printf "  %-7s %s\n", $1, $2 }'
}

statusz_megoszlas() {
    local status_filter="$STATUS"
    echo "HTTP statuszkodok megoszlasa:"
    awk -v wanted="$status_filter" '
        $9 ~ /^[1-5][0-9][0-9]$/ && (wanted == "" || $9 == wanted) {
            count[$9]++
        }
        END { for (code in count) print code, count[code] }
    ' "$FILE" | sort -n |
        awk '{ printf "  %-7s %s db\n", $1, $2 }'
}

osszefoglalo() {
    local status_filter="$STATUS"
    awk -v wanted="$status_filter" '
        $1 != "" && (wanted == "" || $9 == wanted) {
            total++
            ips[$1] = 1
            if ($9 ~ /^[45][0-9][0-9]$/) errors++
        }
        END {
            for (ip in ips) unique++
            printf "Osszesen: %d keres, %d kulonbozo IP-cim, %d hiba (4xx/5xx).\n", total, unique, errors
        }
    ' "$FILE"
}

riport() {
    if [[ "$QUIET" -eq 1 ]]; then
        osszefoglalo
        return
    fi
    echo "Logriport: $FILE"
    if [[ -n "$STATUS" ]]; then
        echo "Szurt HTTP statuszkod: $STATUS"
    fi
    echo
    top_ip
    echo
    statusz_megoszlas
    echo
    osszefoglalo
}

main() {
    parse_args "$@" || exit $?
    ellenoriz_bemenet || exit $?
    if [[ -n "$OUTPUT" ]]; then
        riport > "$OUTPUT"
        if [[ "$QUIET" -eq 1 ]]; then
            osszefoglalo
        else
            echo "Riport elmentve: $OUTPUT"
        fi
    else
        riport
    fi
}

main "$@"
