# =============================================================================
# CT-AI course: lab VM setup (Windows, VS Code terminal)
# Run with ONE line in the VS Code terminal (see README):
#   irm https://raw.githubusercontent.com/qalhata/ctai-setup/main/setup.ps1 | iex
# Safe to run more than once. No admin rights needed. Takes about 3 to 6 minutes.
# =============================================================================
& {
  $ErrorActionPreference = "Continue"
  $ProgressPreference = "SilentlyContinue"          # makes downloads much faster
  try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}
  $lab = "C:\1288 Student Files"
  $log = Join-Path $env:TEMP "ctai_setup_log.txt"
  try { Start-Transcript -Path $log -Force | Out-Null } catch {}
  function Say($t, $c = "Cyan") { Write-Host $t -ForegroundColor $c }
  function Stop-Setup($t) {
    Write-Host ""; Write-Host "  SETUP STOPPED: $t" -ForegroundColor Red
    Write-Host "  Type the words STOPPED and the step number in Zoom chat. Your trainer will help." -ForegroundColor Red
    try { Stop-Transcript | Out-Null } catch {}
  }

  Say "CT-AI lab setup starting. Leave this window open until you see READY." "Green"

  # ---- 1/6 Lab folder ------------------------------------------------------
  Say "1/6 Checking the lab folder..."
  if (-not (Test-Path (Join-Path $lab "datasets"))) {
    Stop-Setup "step 1: '$lab\datasets' was not found on this machine."; return
  }
  Say "    OK: $lab"

  # ---- 2/6 Internet --------------------------------------------------------
  Say "2/6 Checking internet access..."
  try { Invoke-WebRequest "https://pypi.org/simple/pip/" -UseBasicParsing -TimeoutSec 30 | Out-Null; Say "    OK" "Gray" }
  catch { Stop-Setup "step 2: this VM cannot reach the internet (pypi.org)."; return }

  # ---- 3/6 Python ----------------------------------------------------------
  Say "3/6 Finding or installing Python..."
  $py = $null
  $candidates = @(Get-ChildItem "$env:LOCALAPPDATA\Programs\Python\Python3*\python.exe", "C:\Program Files\Python3*\python.exe", "C:\Python3*\python.exe" -ErrorAction SilentlyContinue | Sort-Object FullName -Descending)
  foreach ($c in $candidates) {
    $v = & $c.FullName -c "import sys; print(sys.version_info[0]*100+sys.version_info[1])" 2>$null
    if ($v -and [int]$v -ge 309) { $py = $c.FullName; break }
  }
  if ($py) { Say "    Python already installed: $py" "Gray" }
  else {
    Say "    Downloading Python 3.12.10 (about 27 MB)..." "Gray"
    $exe = Join-Path $env:TEMP "python-3.12.10-amd64.exe"
    try { Invoke-WebRequest "https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe" -OutFile $exe -UseBasicParsing }
    catch { Stop-Setup "step 3: the Python download failed."; return }
    Say "    Installing for this user only (no admin needed). Please wait..." "Gray"
    $p = Start-Process $exe -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1 Include_launcher=1 InstallLauncherAllUsers=0 Include_tcltk=1 Include_pip=1 Include_test=0" -Wait -PassThru
    $py = "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe"
    if (-not (Test-Path $py)) { Stop-Setup "step 3: Python did not install (installer exit code $($p.ExitCode)). Installers may be blocked on this VM."; return }
    Say "    Installed: $py" "Gray"
  }
  $pydir = Split-Path $py
  $env:Path = "$pydir;$pydir\Scripts;$env:Path"      # 'python' works in THIS window straight away
  # Remove the Microsoft Store 'python' shortcuts for this user so 'python' always means real Python
  Remove-Item "$env:LOCALAPPDATA\Microsoft\WindowsApps\python.exe", "$env:LOCALAPPDATA\Microsoft\WindowsApps\python3.exe" -Force -ErrorAction SilentlyContinue

  # ---- 4/6 Libraries -------------------------------------------------------
  Say "4/6 Installing the lab libraries (numpy, pandas, scikit-learn, matplotlib, seaborn)..."
  $pkgs = @("numpy", "pandas", "scikit-learn", "matplotlib", "seaborn")
  & $py -m pip install --quiet --disable-pip-version-check @pkgs
  if ($LASTEXITCODE -ne 0) {
    Say "    First attempt failed, retrying once..." "Yellow"
    & $py -m pip install --disable-pip-version-check @pkgs
    if ($LASTEXITCODE -ne 0) { Stop-Setup "step 4: the libraries did not install."; return }
  }
  Say "    OK" "Gray"

  # ---- 5/6 Lab helpers and VS Code settings --------------------------------
  Say "5/6 Adding the lab helper files and VS Code settings..."
  [Environment]::SetEnvironmentVariable("PYTHONPATH", $lab, "User")
  $env:PYTHONPATH = $lab
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  $envcheck = @'
"""
CT-AI lab VM check. Run once per VM before the labs:  python ctai_env_check.py
(If 'python' gives a Microsoft Store message, use:  py ctai_env_check.py)
It confirms Python, the five libraries, the datasets module, and that a chart can be shown.
Put this file in the lab pack's top folder (C:\\1288 Student Files on the course VMs).
"""
import importlib
import os
import sys

ok = True
print(f"Python {sys.version.split()[0]} at {sys.executable}")
if sys.version_info < (3, 9):
    ok = False
    print("  FAIL  Python 3.9 or newer is needed")

for name in ["numpy", "pandas", "sklearn", "matplotlib", "seaborn"]:
    try:
        mod = importlib.import_module(name)
        print(f"  OK    {name} {getattr(mod, '__version__', '')}")
    except ImportError:
        ok = False
        print(f"  FAIL  {name} is missing. Install with: python -m pip install "
              f"{'scikit-learn' if name == 'sklearn' else name}")

# The datasets module may be a file (datasets.py) or a folder (datasets\__init__.py)
here = os.path.dirname(os.path.abspath(__file__))
found = [p for p in (os.path.join(here, "datasets.py"), os.path.join(here, "datasets")) if os.path.exists(p)]
pp = os.environ.get("PYTHONPATH", "")
if found:
    print(f"  OK    datasets module found: {found[0]}")
    if os.path.normcase(here) not in [os.path.normcase(p.rstrip("\\/")) for p in pp.split(os.pathsep) if p]:
        print(f"  WARN  PYTHONPATH does not include {here}. Labs inside subfolders may not find datasets.")
        print(f"        Fix (PowerShell): [Environment]::SetEnvironmentVariable('PYTHONPATH','{here}','User')  then restart VS Code")
    try:
        sys.path.insert(0, here)
        from datasets import get_prepared_iris_data
        d = get_prepared_iris_data()
        print(f"  OK    datasets module works ({d['X_train'].shape[0]} training rows)")
    except Exception as exc:  # report, do not stop
        ok = False
        print(f"  FAIL  datasets module error: {exc}")
else:
    ok = False
    print("  FAIL  no datasets.py or datasets folder next to this file. Put this file in the lab pack's top folder")

try:
    import matplotlib
    import matplotlib.pyplot as plt
    backend = matplotlib.get_backend()
    interactive = backend.lower() not in ("agg", "pdf", "svg", "ps", "cairo", "template")
    print(f"  {'OK  ' if interactive else 'WARN'}  matplotlib backend: {backend}")
    plt.plot([0, 1, 2], [0, 1, 4], marker="o")
    plt.title("CT-AI plot check: close this window to finish")
    if interactive:
        print("        A chart window should open now. Close it to finish the check.")
        plt.show()
    else:
        plt.savefig(os.path.join(here, "plot_check.png"))
        print("        No window can open on this VM. Use run_lab.py, which saves charts as PNG files.")
except Exception as exc:
    ok = False
    print(f"  FAIL  plotting error: {exc}")

print("\nRESULT:", "READY for the labs" if ok else "NOT READY: fix the FAIL lines above")
'@
  $runlab = @'
"""
Run a CT-AI lab file and save every chart as a PNG instead of opening windows.

Use it when chart windows do not appear on a VM, or when you want to keep the charts:
    python run_lab.py path/to/ho_3_2_2_todo.py

Charts go to a 'figures' folder next to the lab file, named after it
(ho_3_2_2_todo_1.png, ho_3_2_2_todo_2.png ...). Click one in the VS Code
Explorer to view it. The lab file itself is not changed.
"""
import os
import runpy
import sys

import matplotlib
matplotlib.use("Agg")  # draw to files, never to windows
import matplotlib.pyplot as plt

if len(sys.argv) != 2 or not sys.argv[1].endswith(".py"):
    sys.exit("Usage: python run_lab.py path/to/lab_file.py")

lab = os.path.abspath(sys.argv[1])
out_dir = os.path.join(os.path.dirname(lab), "figures")
os.makedirs(out_dir, exist_ok=True)
stem = os.path.splitext(os.path.basename(lab))[0]
count = [0]

def save_instead_of_show(*args, **kwargs):
    for num in plt.get_fignums():
        count[0] += 1
        path = os.path.join(out_dir, f"{stem}_{count[0]}.png")
        plt.figure(num).savefig(path, dpi=110, bbox_inches="tight")
        print(f"[chart saved] {path}")
    plt.close("all")

plt.show = save_instead_of_show
sys.argv = [lab]
runpy.run_path(lab, run_name="__main__")  # sets __file__, so the labs find datasets.py
save_instead_of_show()  # catch any chart drawn but never shown
print(f"\n{count[0]} chart(s) saved in {out_dir}")
'@
  [IO.File]::WriteAllText((Join-Path $lab "ctai_env_check.py"), $envcheck, $utf8)
  [IO.File]::WriteAllText((Join-Path $lab "run_lab.py"), $runlab, $utf8)
  $vs = Join-Path $lab ".vscode"
  New-Item -ItemType Directory -Force -Path $vs | Out-Null
  $settings = Join-Path $vs "settings.json"
  if (Test-Path $settings) { Copy-Item $settings "$settings.bak" -Force }
  $json = "{`n  `"python.defaultInterpreterPath`": `"" + ($py -replace '\\', '\\') + "`",`n  `"python.terminal.activateEnvironment`": false`n}`n"
  [IO.File]::WriteAllText($settings, $json, $utf8)
  Say "    OK: ctai_env_check.py, run_lab.py, .vscode\settings.json, PYTHONPATH" "Gray"

  # ---- 6/6 Check -----------------------------------------------------------
  Say "6/6 Running the lab check. A small test chart opens: CLOSE IT to finish."
  $out = & $py (Join-Path $lab "ctai_env_check.py") 2>&1
  $out | ForEach-Object { Write-Host "    $_" }
  try { Stop-Transcript | Out-Null } catch {}
  if (($out -join "`n") -match "READY for the labs") {
    Write-Host ""
    Write-Host "  ==============================================================" -ForegroundColor Green
    Write-Host "   READY.  Now: File > Exit to close VS Code, then reopen it."    -ForegroundColor Green
    Write-Host "   Then type READY in Zoom chat."                                 -ForegroundColor Green
    Write-Host "  ==============================================================" -ForegroundColor Green
  } else {
    Stop-Setup "step 6: the lab check reported a problem (see the FAIL lines above)."
  }
}
