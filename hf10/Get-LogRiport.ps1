<#
.SYNOPSIS
Apache access log feldolgozasa.

.DESCRIPTION
A program feldolgozza az Apache access log fajlt,
es objektumokat ad vissza az eredmenyekrol.

.EXAMPLE
.\Get-LogRiport.ps1 -Path .\access.log

.EXAMPLE
.\Get-LogRiport.ps1 -Path .\access.log -Top 5

.EXAMPLE
.\Get-LogRiport.ps1 -Path .\access.log -Status 404

.EXAMPLE
.\Get-LogRiport.ps1 -Path .\access.log -Csendes
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Path,

    [int]$Top = 10,

    [int]$Status = 0,

    [switch]$Csendes
)

if ($Top -lt 1) {
    throw "A Top erteke pozitiv egesz szam legyen."
}

if ($Status -ne 0 -and ($Status -lt 100 -or $Status -gt 599)) {
    throw "A Status ervenyes HTTP statuszkod legyen."
}

try {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "A fajl nem talalhato: $Path"
    }

    $sorok = Get-Content -LiteralPath $Path -ErrorAction Stop

    $ipDarabok = @{}
    $statuszDarabok = @{}

    $osszesen = 0
    $hibak = 0

    foreach ($sor in $sorok) {
        if ($sor -match '^(\S+)\s+\S+\s+\S+\s+\[[^\]]+\]\s+"[^"]*"\s+(\d{3})\s+\S+') {
            $ip = $matches[1]
            $kod = [int]$matches[2]

            if ($Status -eq 0 -or $kod -eq $Status) {
                $osszesen++

                if ($ipDarabok.ContainsKey($ip)) {
                    $ipDarabok[$ip]++
                }
                else {
                    $ipDarabok[$ip] = 1
                }

                if ($statuszDarabok.ContainsKey($kod)) {
                    $statuszDarabok[$kod]++
                }
                else {
                    $statuszDarabok[$kod] = 1
                }

                if ($kod -ge 400) {
                    $hibak++
                }
            }
        }
    }

    if (-not $Csendes) {
        $ipEredmenyek = foreach ($ip in $ipDarabok.Keys) {
            [PSCustomObject]@{
                Tipus = "IP"
                IP = $ip
                Keresek = $ipDarabok[$ip]
            }
        }

        $ipEredmenyek |
            Sort-Object -Property @{Expression="Keresek"; Descending=$true}, IP
            Select-Object -First $Top

        $statuszEredmenyek = foreach ($kod in $statuszDarabok.Keys) {
            [PSCustomObject]@{
                Tipus = "Statusz"
                Statusz = $kod
                Keresek = $statuszDarabok[$kod]
            }
        }

        $statuszEredmenyek |
            Sort-Object Statusz
    }

    [PSCustomObject]@{
        Tipus = "Osszesites"
        OsszesKeres = $osszesen
        KulonbozoIP = $ipDarabok.Count
        Hibak = $hibak
        Keresek = $osszesen
    }
}
catch {
    Write-Error "Hiba a log feldolgozasa kozben: $_"
}
