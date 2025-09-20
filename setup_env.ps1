<#
setup_env.ps1
Installs Python dependencies for analytics-learner and orchestration-bridge on Windows.
Handles FAISS via conda if available; otherwise provides guidance.
#>

param(
    [switch]$CreateVenv
)

function Write-Log($msg){ Write-Host "[setup] $msg" }

# Check python
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    Write-Error "Python not found in PATH. Install Python 3.10+ and ensure 'python' is on PATH or use conda."
    exit 1
}

# Optionally create venv
if ($CreateVenv) {
    Write-Log "Creating virtual environment '.venv'"
    python -m venv .venv
    .\.venv\Scripts\Activate.ps1
}

Write-Log "Upgrading pip"
python -m pip install --upgrade pip

# Install analytics-learner requirements
$analyticsReq = "analytics-learner\requirements.txt"
if (Test-Path $analyticsReq) {
    Write-Log "Installing analytics-learner requirements"
    python -m pip install -r $analyticsReq
} else { Write-Log "analytics-learner requirements.txt not found: $analyticsReq" }

# Install orchestration-bridge requirements with FAISS handling
$orchReq = "orchestration-bridge\requirements.txt"
if (Test-Path $orchReq) {
    Write-Log "Installing orchestration-bridge requirements (attempt pip first)"
    try {
        python -m pip install -r $orchReq
    } catch {
        Write-Log "pip install failed for some packages. Checking for faiss-cpu issues..."
        # Try installing without faiss-cpu
        $lines = Get-Content $orchReq | Where-Object { $_ -notmatch 'faiss-cpu' }
        $tmp = "orchestration-bridge\requirements-lite.txt"
        $lines | Set-Content $tmp
        Write-Log "Installing lightweight requirements (without faiss-cpu)"
        python -m pip install -r $tmp
        Write-Log "If you need FAISS, install via conda: 'conda install -c conda-forge faiss-cpu' or follow Windows wheel instructions."
    }
} else { Write-Log "orchestration-bridge requirements.txt not found: $orchReq" }

Write-Log "Installing sentence-transformers (may take time)"
python -m pip install sentence-transformers

Write-Log "Setup complete. If you need faiss-cpu on Windows, prefer conda: conda install -c conda-forge faiss-cpu"
