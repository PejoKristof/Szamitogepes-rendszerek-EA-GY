#!/usr/bin/env bash

# rendszerinfok kiírása: | hosztnév | kernelverzió | uptime | bejelent felh | home méret | szabad lemezhely /-on | hány folyamat fut
# ./rendszerinfo.sh [kimeneti_fajl]
# sikeres: 0 |  sikertelen: 1

output_file="${1:-}"

gen_info() {
	printf '%-25s %s\n' "Hosztnév:" "$(hostname)"
	printf '%-25s %s\n' "Kernel verzió:" "$(uname -r)"
	printf '%-25s %s\n' "Uptime:" "$(uptime -p 2>/dev/null || uptime)"
	printf '%-25s %s\n' "Bejelentkezett felhasználó:" "$(whoami)"
	printf '%-25s %s\n' "Home könyvtár mérete:" "$(du -sh "$HOME" 2>/dev/null | cut -f1)"
	printf '%-25s %s\n' "Szabad hely a / -on:" "$(df -h / | awk 'NR==2 {print $4}')"
	printf '%-25s %s\n' "Futó folyamatok száma:" "$(ps -e | wc -l)"
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
