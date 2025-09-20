# simulate_signals.ps1 - Write demo signals and check logs

$signal = @{
    timestamp = [int][double]::Parse((Get-Date -UFormat %s))
    symbol = 'EURUSD'
    side = 'BUY'
    volume = 0.01
    price = 1.12345
    modelId = 'ensemble-v1'
    model_version = '2025-09-19'
    features_hash = 'sha256:abcd1234'
    meta = @{ reason = 'momentum+news-spike'; confidence = 0.72 }
}

$signalPath = 'C:\titanovax\signals\latest.json'
$hmacPath = 'C:\titanovax\signals\latest.json.hmac'

# Write JSON
$signal | ConvertTo-Json -Depth 3 | Set-Content -Path $signalPath -Encoding UTF8

# Compute HMAC (demo: just hash the JSON, replace with real HMAC in prod)
$body = Get-Content $signalPath -Raw
$key = Get-Content 'C:\titanovax\secrets\hmac.key' -Raw
$hmac = (echo $body | openssl dgst -sha256 -hmac $key | Out-String).Trim().Split(' ')[-1]
$hmac | Set-Content -Path $hmacPath -Encoding ASCII

Write-Host "Signal and HMAC written."
Write-Host "Check C:\titanovax\logs\exec_log.csv and C:\titanovax\state\hb.json after EA runs."
