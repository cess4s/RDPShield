$failedPath = "C:\rdpShield\failed_rdp_ips.txt"
$blacklistPath = "C:\rdpShield\blacklist.txt"
$whitelistPath = "C:\rdpShield\whitelist.txt"
$logFile = "C:\rdpShield\rdpShield.log"

function Write-Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "[$timestamp] $msg"
}

Write-Log "rdpBlocker başlatıldı."

# Eğer dosyalar yoksa oluştur
if (-not (Test-Path $blacklistPath)) {
    New-Item $blacklistPath -ItemType File -Force | Out-Null
    Write-Log "Blacklist dosyası oluşturuldu."
}

if (-not (Test-Path $whitelistPath)) {
    New-Item $whitelistPath -ItemType File -Force | Out-Null
    Write-Log "Whitelist dosyası oluşturuldu."
}

# Whitelist ve Blacklist yükle
$whitelist = Get-Content $whitelistPath -ErrorAction SilentlyContinue
$blacklist = Get-Content $blacklistPath -ErrorAction SilentlyContinue

# Başarısız IP'leri oku
if (-not (Test-Path $failedPath)) {
    Write-Log "$failedPath dosyası bulunamadı. Çıkılıyor."
    exit
}

$lines = Get-Content $failedPath
foreach ($line in $lines) {
    if ($line -match "^(\d{1,3}(\.\d{1,3}){3})\s+(\d+)$") {
        $ip = $matches[1]
        $count = [int]$matches[3]

        if ($count -le 3) { continue }
        if ($ip -in $whitelist) {
            Write-Log "$ip whitelist'te, atlanıyor."
            continue
        }
        if ($ip -in $blacklist) {
            Write-Log "$ip zaten blacklist'te."
            continue
        }

        # Firewall kural adı
        $ruleName = "rdpShield_$ip"

        # Kuralı ekle
        try {
            New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -RemoteAddress $ip -Action Block -Protocol TCP -Profile Any -ErrorAction Stop
            Write-Log "$ip firewall'a engellendi. Kural: $ruleName"
            Add-Content -Path $blacklistPath -Value $ip
        } catch {
            Write-Log "HATA: $ip için firewall kuralı eklenemedi: $_"
        }
    }
}

Write-Log "rdpBlocker tamamlandı."
