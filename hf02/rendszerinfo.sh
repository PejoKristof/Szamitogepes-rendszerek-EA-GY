#!/usr/bin/env bash

# rendszerinfok kiírása: | hosztnév | kernelverzió | uptime | bejelent felh | home méret | szabad lemezhely /-on | hány folyamat fut
# ./rendszerinfo.sh [kimeneti_fajl]
# sikeres: 0 |  sikertelen: 1

output_file="${1:-}"

get_uptime() {
    if command -v uptime >/dev/null 2>&1; then
        uptime -p 2>/dev/null || uptime
    else
        echo "N/A (Windows/MSYS2)"
    fi
}

get_home_size() {
    du -sh --max-depth=1 "$HOME" 2>/dev/null | tail -n 1 | awk '{print $1}'
}

get_free_space() {
    local free_space
    free_space=$(df -h / 2>/dev/null | awk 'END {print $4}')
    if [ -n "$free_space" ]; then
        echo "$free_space"
    else
        echo "Ismeretlen"
    fi
}

get_process_count() {
    local proc_cnt
    proc_cnt=$(ps -e 2>/dev/null | wc -l)
    if [ "$proc_cnt" -gt 0 ]; then
        echo "$proc_cnt"
    else
        echo "1"
    fi
}

gen_info() {
    printf '%-25s %s\n' "Hosztnév:" "$(hostname)"
    printf '%-25s %s\n' "Kernel verzió:" "$(uname -r)"
    printf '%-25s %s\n' "Uptime:" "$(get_uptime)"
    printf '%-25s %s\n' "Bejelentkezett user:" "$(whoami)"
    printf '%-25s %s\n' "HOME könyvtár mérete:" "$(get_home_size)"
    printf '%-25s %s\n' "Szabad hely a / -en:" "$(get_free_space)"
    printf '%-25s %s\n' "Futó folyamatok száma:" "$(get_process_count)"
}

if [ -n "$output_file" ]; then
	if ! gen_info > "$output_file" 2>/dev/null; then
		printf 'Hiba: A "%s" fájl nem írható\n' "$output_file" >&2
		exit 1
	fi
else
	gen_info
fi

exit 0
