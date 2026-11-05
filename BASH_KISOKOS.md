# Bash kisokos – Számítógépes rendszerek ZH

## 1. Script indítása

```bash
#!/bin/bash
```

Futtatás:

```bash
chmod +x script.sh
./script.sh
```

Vagy:

```bash
bash script.sh
```

## 2. Változók

```bash
nev="Gergő"
szam=10

echo "$nev"
echo "$szam"
```

- Értékadásnál nincs szóköz az `=` körül.
- Változó értéke: `$nev` vagy `${nev}`.
- Szövegnél általában használj idézőjelet: `"$nev"`.

Parancs kimenetének eltárolása:

```bash
aktualis_datum=$(date)
fajlok=$(ls)
```

## 3. Parancssori argumentumok

Ha így indítjuk:

```bash
./script.sh alma korte 42
```

| Jelölés | Jelentés |
|---|---|
| `$0` | A script neve |
| `$1` | Első argumentum (`alma`) |
| `$2` | Második argumentum (`korte`) |
| `$3` | Harmadik argumentum (`42`) |
| `$#` | Argumentumok száma (itt 3) |
| `$@` | Az összes argumentum külön-külön |
| `$*` | Az összes argumentum egyetlen szövegként |

Argumentumok feldolgozása:

```bash
while [ "$#" -gt 0 ]; do
    echo "$1"
    shift
done
```

A `shift` eldobja az első argumentumot, a többi eggyel előrébb kerül.

## 4. Feltételek – if

Alakja:

```bash
if [ FELTETEL ]; then
    # ha igaz
elif [ MASIK_FELTETEL ]; then
    # ha a második igaz
else
    # különben
fi
```

Példa az argumentumok számára:

```bash
if [ "$#" -ne 2 ]; then
    echo "Pontosan 2 argumentum kell!"
    exit 1
fi
```

### Számok összehasonlítása

| Operátor | Jelentés |
|---|---|
| `-eq` | egyenlő |
| `-ne` | nem egyenlő |
| `-lt` | kisebb |
| `-le` | kisebb vagy egyenlő |
| `-gt` | nagyobb |
| `-ge` | nagyobb vagy egyenlő |

Példa:

```bash
if [ "$szam" -gt 10 ]; then
    echo "Nagyobb 10-nél"
fi
```

### Szövegek összehasonlítása

```bash
if [ "$nev" = "Gergő" ]; then
    echo "Egyezik"
fi
```

- `=` : egyenlő
- `!=` : nem egyenlő
- `-z "$szoveg"` : üres a szöveg
- `-n "$szoveg"` : nem üres a szöveg

### Logikai kapcsolatok

```bash
if [ "$szam" -gt 0 ] && [ "$szam" -lt 10 ]; then
    echo "0 és 10 között van"
fi
```

- `&&` : ÉS
- `||` : VAGY
- `!` : tagadás

## 5. Fájlok és könyvtárak ellenőrzése

```bash
if [ -f "$1" ]; then
    echo "Létező fájl"
fi
```

| Feltétel | Jelentés |
|---|---|
| `-e útvonal` | Létezik |
| `-f útvonal` | Létező normál fájl |
| `-d útvonal` | Létező könyvtár |
| `-r útvonal` | Olvasható |
| `-w útvonal` | Írható |
| `-x útvonal` | Futtatható |
| `-s útvonal` | Létezik és nem üres |

Példa:

```bash
if [ ! -f "$1" ]; then
    echo "Nincs ilyen fájl!"
    exit 1
fi
```

## 6. Ciklusok

### for – adott lista elemein végigmegy

```bash
for nev in alma korte banan; do
    echo "$nev"
done
```

Számolós for:

```bash
for ((i=1; i<=5; i++)); do
    echo "$i"
done
```

Argumentumokon:

```bash
for arg in "$@"; do
    echo "$arg"
done
```

### while – amíg a feltétel igaz

```bash
i=1
while [ "$i" -le 5 ]; do
    echo "$i"
    i=$((i + 1))
done
```

Argumentumok feldolgozása:

```bash
while [ "$#" -gt 0 ]; do
    echo "Következő: $1"
    shift
done
```

### until – amíg a feltétel hamis

```bash
i=1
until [ "$i" -gt 5 ]; do
    echo "$i"
    i=$((i + 1))
done
```

### Ciklusvezérlés

- `break` : kilépés a ciklusból.
- `continue` : ugrás a következő körre.

## 7. Számolás Bash-ben

```bash
a=10
b=3

osszeg=$((a + b))
kulonbseg=$((a - b))
szorzat=$((a * b))
hanyados=$((a / b))
maradek=$((a % b))
```

Fontos: a `$(())` egész számokkal számol.

Régebbi megoldás:

```bash
osszeg=$(expr "$a" + "$b")
```

Az `expr` esetén a műveleti jelek között szóköz kell.

## 8. Beolvasás

```bash
read -p "Add meg a neved: " nev
echo "Szia, $nev!"
```

Fájl soronkénti beolvasása:

```bash
while read -r sor; do
    echo "$sor"
done < fajl.txt
```

## 9. Fontos parancsok

| Parancs | Mire való? | Példa |
|---|---|---|
| `echo` | Kiírás | `echo "Hello"` |
| `cat` | Fájl tartalmának kiírása | `cat chat.log` |
| `grep` | Sorok keresése mintára | `grep "Gergő" chat.log` |
| `cut` | Mezők kivágása | `cut -d " " -f 2 chat.log` |
| `sort` | Rendezés | `sort nevek.txt` |
| `uniq` | Szomszédos ismétlődések kiszűrése | `sort nevek.txt \| uniq` |
| `tr` | Karakterek cseréje/törlése | `tr "a-z" "A-Z"` |
| `wc` | Sorok/szavak/karakterek száma | `wc -l chat.log` |
| `head` | Első sorok | `head -n 5 chat.log` |
| `tail` | Utolsó sorok | `tail -n 5 chat.log` |
| `find` | Fájlok keresése | `find . -name "*.sh"` |
| `basename` | Útvonal utolsó eleme | `basename /home/user/a.txt` |
| `dirname` | Könyvtárrész | `dirname /home/user/a.txt` |
| `pwd` | Aktuális könyvtár | `pwd` |
| `ls` | Könyvtár tartalma | `ls -l` |

### grep – keresés

```bash
grep "Gergő" chat.log
grep -i "gergő" chat.log     # kis/nagybetűt nem különböztet meg
grep -v "Gergő" chat.log     # azokat a sorokat adja, amelyekben nincs benne
grep -n "Gergő" chat.log     # sorszámot is mutat
grep -c "Gergő" chat.log     # találatok száma
grep -E "alma|korte" fajl    # alma VAGY korte
```

### cut – mezők kivágása

```bash
cut -d " " -f 2 chat.log
cut -d ":" -f 1 /etc/passwd
cut -d " " -f 2,3 chat.log
```

- `-d` : elválasztó karakter.
- `-f` : kiválasztott mező vagy mezők.

### sort és uniq

```bash
sort nevek.txt
sort -n szamok.txt
sort nevek.txt | uniq
sort nevek.txt | uniq -c
sort nevek.txt | uniq -d
```

Az `uniq` csak az egymás mellett álló ismétlődéseket szűri ki, ezért gyakran `sort` után használjuk.

### tr – karakterek átalakítása

```bash
tr "a-z" "A-Z" < fajl.txt
tr -d "()" < fajl.txt
tr -s " " < fajl.txt
```

- `tr "a-z" "A-Z"` : kisbetűből nagybetű.
- `tr -d "()"` : zárójelek törlése.
- `tr -s " "` : egymás melletti szóközök összevonása.

### wc – számlálás

```bash
wc -l fajl.txt   # sorok
wc -w fajl.txt   # szavak
wc -c fajl.txt   # bájtok
```

## 10. Csövezés és átirányítás

```bash
parancs1 | parancs2
```

A `|` az első parancs kimenetét a második bemenetére adja.

```bash
grep "Gergő" chat.log | cut -d " " -f 2,3
```

Gyakori átirányítások:

| Jel | Jelentés |
|---|---|
| `>` | Kimenet fájlba, felülírja |
| `>>` | Kimenet fájl végére |
| `<` | Bemenet fájlból |
| `2>` | Hibakimenet fájlba |
| `2>&1` | Hibakimenet a normál kimenetre |

Példák:

```bash
echo "alma" > gyumolcs.txt
echo "korte" >> gyumolcs.txt
sort < gyumolcs.txt
```

## 11. Kilépési kód

```bash
exit 0
```

- `0` : sikeres végrehajtás.
- Nem nulla (például `1`) : hiba vagy sikertelen végrehajtás.
- `$?` : az előző parancs kilépési kódja.

```bash
grep "Gergő" chat.log
if [ "$?" -eq 0 ]; then
    echo "Volt találat"
fi
```

Rövidebben:

```bash
if grep -q "Gergő" chat.log; then
    echo "Volt találat"
fi
```

A `grep -q` nem írja ki a találatokat, csak a kilépési kódjával jelzi, hogy volt-e találat.

## 12. Gyakori minták ZH-ra

### Ellenőrizd az argumentumok számát

```bash
if [ "$#" -ne 1 ]; then
    echo "Használat: $0 <fájlnév>"
    exit 1
fi
```

### Ellenőrizd, hogy létezik-e a fájl

```bash
if [ ! -f "$1" ]; then
    echo "A fájl nem létezik!"
    exit 1
fi
```

### Feldolgozd az összes argumentumot

```bash
for arg in "$@"; do
    echo "$arg"
done
```

### Feldolgozd az argumentumokat shift segítségével

```bash
while [ "$#" -gt 0 ]; do
    echo "$1"
    shift
done
```

### Szűrés, mezők kivágása, rendezés, egyedi elemek

```bash
grep "minta" fajl.txt | cut -d " " -f 2 | sort | uniq
```

### Számold meg a találatokat

```bash
grep -c "minta" fajl.txt
```

### Első N sor

```bash
head -n "$N" fajl.txt
```
---