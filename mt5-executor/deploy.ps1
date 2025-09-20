# deploy.ps1 - Setup for mt5-executor
# Run as Administrator

$ErrorActionPreference = 'Stop'

$dirs = @(
    'C:\titanovax\signals',
    'C:\titanovax\logs',
    'C:\titanovax\state',
    'C:\titanovax\screenshots',
    'C:\titanovax\secrets'
)
foreach ($d in $dirs) {
    if (!(Test-Path $d)) { New-Item -ItemType Directory -Path $d | Out-Null }
}

# Create demo HMAC key
$key = [System.Guid]::NewGuid().ToString('N').Substring(0,32)
$keyPath = 'C:\titanovax\secrets\hmac.key'
$key | Set-Content -Path $keyPath -Encoding ASCII

# Set permissions (restrict to current user)
foreach ($d in $dirs) {
    icacls $d /inheritance:r /grant "$env:USERNAME:(OI)(CI)F" | Out-Null
}
icacls $keyPath /inheritance:r /grant "$env:USERNAME:F" | Out-Null

Write-Host "Directories and demo HMAC key created."
Write-Host "Copy SignalExecutorEA.mq5 to your MT5/Experts folder manually."
