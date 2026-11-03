# CT-AI course: get your lab machine ready

About 10 minutes, most of it waiting. Do every step **inside your lab VM window**, not on your own computer.

When you finish, type **READY** in Zoom chat. If anything turns red, type **STOPPED** and the step number in Zoom chat, then wait: I will help you.

---

## Step 1. Log in to your lab VM

Use the lab link from Learning Tree. Everything below happens inside the VM.

## Step 2. Open this page inside the VM

In the VM, open the web browser (**Microsoft Edge**). Click the address bar at the top, type the address below and press **Enter**:

**github.com/qalhata/ctai-setup**

You are on the right page when you see the heading *CT-AI course: get your lab machine ready*.

If Edge shows a welcome or sign-in screen, choose the option to continue **without** signing in.

## Step 3. Open the lab folder in VS Code

1. Open **Visual Studio Code** from the VM desktop or Start menu.
2. Click **File**, then **Open Folder...**
3. Go to **C:\1288 Student Files** and click **Select Folder**.
4. If VS Code asks *"Do you trust the authors of the files in this folder?"*, click **Yes, I trust the authors**.
5. If a blue **Update** button appears at the top, ignore it.

## Step 4. Open a terminal

Click **Terminal** in the top menu, then **New Terminal**. A panel opens at the bottom of VS Code. Its last line should end with:

```
C:\1288 Student Files>
```

## Step 5. Copy, paste and run the setup command

On this page, point at the grey box below and click the **copy icon** at its right-hand end. Click in the VS Code terminal, press **Ctrl+V** (or right-click), then press **Enter**.

```powershell
irm https://raw.githubusercontent.com/qalhata/ctai-setup/main/setup.ps1 | iex
```

Copy not working? Type it exactly as shown. It is one line, and `irm` and `iex` are short PowerShell commands.

## Step 6. Wait for READY

The terminal shows steps **1/6** to **6/6**. It takes 3 to 6 minutes; downloading Python is the slow part.

At step 6 a small chart window opens. **Close it** (the X at its top right) to let the setup finish. If you cannot see it, it may be behind VS Code: look for a new icon on the taskbar and click it.

Do not close VS Code or the terminal while the setup is running.

You are done when you see a green box that says **READY**.

## Step 7. Restart VS Code and check

1. Click **File**, then **Exit**. VS Code closes completely.
2. Open **Visual Studio Code** again. It reopens your lab folder (if it does not, repeat Step 3).
3. Click **Terminal**, then **New Terminal**.
4. Type `python --version` and press **Enter**. You should see **Python 3.12** (or newer).

## Step 8. Tell me you are ready

Type **READY** in Zoom chat.

---

## If something goes wrong

| What you see | What it means | What to do |
|---|---|---|
| `STOPPED: step 1` | The lab folder is not where it should be | Type STOPPED 1 in chat. Do not move any folders. |
| `STOPPED: step 2` | The VM cannot reach the internet | Type STOPPED 2 in chat. I will raise it with Learning Tree. |
| `STOPPED: step 3` | Python could not be downloaded or installed | Type STOPPED 3 in chat. |
| `STOPPED: step 4` | The libraries did not install | Run the Step 5 command once more. If it stops again, type STOPPED 4. |
| `STOPPED: step 6` | The final check found a problem | Type STOPPED 6 in chat and keep the window open so I can see it. |
| `irm` or `iex` is "not recognised" | The terminal is not PowerShell | Click the small arrow next to the + in the terminal panel, choose **PowerShell**, and repeat Step 5. |
| Red text: "Could not create SSL/TLS secure channel" | An older security setting on the VM | Paste this instead and press Enter: `[Net.ServicePointManager]::SecurityProtocol = "Tls12"; irm https://raw.githubusercontent.com/qalhata/ctai-setup/main/setup.ps1 \| iex` |
| Red text about "running scripts is disabled" | A security setting on the VM | Use the backup route below. |
| After Step 7, `python` opens the Microsoft Store | VS Code was not fully closed | Click **File**, then **Exit**, and reopen it. Still there? Type `py --version` instead and tell me. |

Please do not run the setup more than twice. If it stops twice, tell me in chat: there is time to fix it before the first lab.

### Backup route (only if I ask you to use it)

1. On this page, click the green **Code** button, then **Download ZIP**.
2. In the VS Code terminal, paste this line and press **Enter**:

```powershell
powershell -ExecutionPolicy Bypass -Command "Expand-Archive -Force $HOME\Downloads\ctai-setup-main.zip $HOME\Downloads; & $HOME\Downloads\ctai-setup-main\setup.ps1"
```

---

## Running the labs (for the rest of the course)

- **Open a lab:** in the VS Code Explorer, open a lab folder (for example `HO-3.2.2`, then `todo`) and click the `.py` file.
- **Edit:** fill in each `>>> YOUR CODE HERE <<<`, then press **Ctrl+S** to save.
- **Run:** in the terminal, go to the lab's folder and run the file. For example:

```powershell
cd "C:\1288 Student Files\HO-3.2.2\todo"
python ho_3_2_2_todo.py
```

- **See your results:** these are scripts, not notebooks. `df.head(10)` on its own line shows nothing; write `print(df.head(10))`.
- **Charts:** each chart opens in its own window and the script waits. Read it, close it, and the script carries on.
- **No chart window?** Run the lab like this instead. Charts are saved as pictures in a `figures` folder next to the lab:

```powershell
python "C:\1288 Student Files\run_lab.py" ho_3_2_2_todo.py
```

- **Run again:** press the **up arrow** in the terminal, then **Enter**.

---

*What the setup does:* it installs Python 3.12 for your user only (no admin rights needed), installs numpy, pandas, scikit-learn, matplotlib and seaborn, adds two helper files (`ctai_env_check.py` and `run_lab.py`) to `C:\1288 Student Files`, tells VS Code which Python to use, and checks everything works. It does not change anything outside your user account and the lab folder. A log is saved as `ctai_setup_log.txt` in your Temp folder.
