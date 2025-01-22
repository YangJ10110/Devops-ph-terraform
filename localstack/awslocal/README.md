# Setting Up `awslocal` in Windows and Git Bash

This guide walks you through the steps to set up `awslocal` to work seamlessly on both Windows (via Command Prompt or PowerShell) and Git Bash.

---

## Prerequisites
1. **Python**: Ensure Python is installed and added to your system PATH.
2. **Pip**: Confirm that `pip` is available by running `pip --version`.
3. **Git Bash**: Installed and configured on your system.

---

## Installation Steps

### 1. Install `awscli-local`
Run the following command to install `awscli-local`:
```bash
pip install awscli-local
```
This installs the `awslocal` command-line tool, which is used to interact with LocalStack.

### 2. Add the Installation Path to System Variables
Ensure the directory containing the `awslocal` executable (`Scripts` folder) is included in your system's PATH.

#### Steps:
1. Open the Start Menu and search for **Environment Variables**.
2. Click **Edit the system environment variables**.
3. In the **System Properties** window, click **Environment Variables**.
4. Under **System Variables**, find `Path` and click **Edit**.
5. Use the following command in PowerShell or Command Prompt to find the exact path to `awslocal`:
   ```bash
   where awslocal
   ```
   Note the directory path (e.g., `C:\Users\Jerome Yang\anaconda3\Scripts`) from the output.
6. Add the path to the PATH variable.
7. Click **OK** to save changes and restart your terminal to apply the updated PATH.

### 3. Verify `awslocal` in PowerShell or Command Prompt
Open PowerShell or Command Prompt and run:
```bash
awslocal --version
```
If installed correctly, you should see the version number for `awslocal`.

---

## Making `awslocal` Work in Git Bash

Git Bash doesn't natively execute `.bat` files, so we need to add an alias to reference the `.bat` file directly.

### Steps:

#### 1. Edit `.bashrc`
Open Git Bash and edit your `.bashrc` file using the `nano` editor:
```bash
nano ~/.bashrc
```

#### 2. Add an Alias
Add the following line to create an alias for `awslocal`:
```bash
alias awslocal="cmd //c 'C:/Users/Jerome Yang/anaconda3/Scripts/awslocal.bat'"
```

#### 3. Save and Reload `.bashrc`
1. Save the file: Press `Ctrl + O`, then `Enter`.
2. Exit the editor: Press `Ctrl + X`.
3. Reload the `.bashrc` file:
   ```bash
   source ~/.bashrc
   ```

#### 4. Test `awslocal`
Run the following command in Git Bash:
```bash
awslocal --version
```
You should see the version number, confirming it works.

---

## Summary of Steps
1. Installed `awscli-local` using `pip`.
2. Added the `Scripts` directory to the system PATH for Windows compatibility.
3. Edited the `.bashrc` file in Git Bash to alias the `.bat` file for `awslocal`.
4. Reloaded `.bashrc` and verified the setup.



