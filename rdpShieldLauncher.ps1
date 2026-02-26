$logFile = "C:\rdpShield\rdpShield.log"
function Write-Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "[$timestamp] $msg"
}

$maxSizeMB = 5

if ((Test-Path $logFile) -and ((Get-Item $logFile).Length -gt $maxSizeMB * 1MB)) {
    Clear-Content $logFile
    Add-Content $logFile "[$(Get-Date)] Log file cleared because it exceeded $maxSizeMB MB."
}


Write-Log "rdpShieldLauncher started."

try {
    & "C:\rdpShield\src\rdpScanner.ps1"
    Write-Log "rdpScanner completed successfully."
} catch {
    Write-Log "rdpScanner failed: $_"
}

try {
    & "C:\rdpShield\src\rdpBlocker.ps1"
    Write-Log "rdpBlocker completed successfully."
} catch {
    Write-Log "rdpBlocker failed: $_"
}

Write-Log "rdpShieldLauncher finished."
