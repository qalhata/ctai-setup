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
