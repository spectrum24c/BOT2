Quick setup

1) Optional: create and activate a virtualenv

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

2) Run the setup script (from repo root):

```powershell
powershell -ExecutionPolicy Bypass -File .\setup_env.ps1
```

Notes:
- On Windows, `faiss-cpu` is best installed via conda: `conda install -c conda-forge faiss-cpu`.
- If pip install fails for heavy packages, re-run with conda or use WSL/Ubuntu.
- You can create a lightweight setup by editing `orchestration-bridge/requirements.txt` and removing `faiss-cpu` during early testing.
