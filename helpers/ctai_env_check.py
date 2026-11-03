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
