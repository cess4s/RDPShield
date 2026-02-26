$logPath = "C:\rdpShield\failed_rdp_ips.txt"
$timeSpanMinutes = 15  # İstersen 15 veya başka yapabilirsin
$logFile = "C:\rdpShield\rdpShield.log"

function Write-Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "[$timestamp] $msg"
}

function Read-FailedIPs {
    $ipDict = @{}
    if (Test-Path $logPath) {
        Get-Content $logPath | ForEach-Object {
            if ($_ -match "^(\d{1,3}(\.\d{1,3}){3})\s+(\d+)$") {
                $ip = $matches[1]
                $count = [int]$matches[3]
                $ipDict[$ip] = $count
            }
        }
    }
    return $ipDict
}

function Write-FailedIPs($ipDict) {
    $lines = @()
    foreach ($key in $ipDict.Keys) {
        $lines += "$key $($ipDict[$key])"
    }
    $lines | Set-Content -Path $logPath -Encoding ASCII
}

Write-Log "rdpScanner başlatıldı."

$startTime = (Get-Date).AddMinutes(-$timeSpanMinutes)

# FilterHashtable kullanımı
$filter = @{
    LogName = 'Security'
    Id = 4625
    StartTime = $startTime
}

$events = Get-WinEvent -FilterHashtable $filter -ErrorAction SilentlyContinue

if (!$events -or $events.Count -eq 0) {
    Write-Log "Son $timeSpanMinutes dakika içinde başarısız RDP denemesi bulunamadı."
    exit
}

$failedIPs = Read-FailedIPs

foreach ($event in $events) {
    # XML ile IP çekiyoruz
    $xml = [xml]$event.ToXml()
    $ip = $xml.Event.EventData.Data | Where-Object { $_.Name -eq "IpAddress" } | Select-Object -ExpandProperty '#text'

    if ($ip -and $ip -ne "-" -and $ip -ne "127.0.0.1") {
        if ($failedIPs.ContainsKey($ip)) {
            $failedIPs[$ip] += 1
        } else {
            $failedIPs[$ip] = 1
        }
    }
}

Write-FailedIPs $failedIPs
Write-Log "Son $timeSpanMinutes dakikadaki başarısız IP denemeleri işlendi. Toplam IP sayısı: $($failedIPs.Keys.Count)"
