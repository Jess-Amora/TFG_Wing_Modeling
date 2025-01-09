import os
import shutil
from datetime import datetime
import subprocess

# -------------------------
# Backup Configuration
# -------------------------
SOURCE_DIR = r'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root'  # Replace with your Project Root path
BACKUP_BASE_DIR = r'C:\Users\jessa\MATLAB Drive\Back up'  # Replace with your backup folder path

# Create a timestamp for each backup
timestamp = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
BACKUP_DIR = os.path.join(BACKUP_BASE_DIR, f'backup_{timestamp}')

# -------------------------
# Git Configuration
# -------------------------
GIT_COMMANDS = [
    "git add .",
    'git commit -m "Automated commit: Updates from script"',
    "git push origin main"
]

# -------------------------
# Backup Function
# -------------------------
def backup_project():
    """Create a backup of the source directory."""
    if not os.path.exists(SOURCE_DIR):
        print(f"Source directory does not exist: {SOURCE_DIR}")
        return False

    if not os.path.exists(BACKUP_BASE_DIR):
        os.makedirs(BACKUP_BASE_DIR)

    try:
        shutil.copytree(SOURCE_DIR, BACKUP_DIR)
        print(f"Backup completed successfully! Files saved to: {BACKUP_DIR}")
        return True
    except Exception as e:
        print(f"Backup failed: {e}")
        return False

# -------------------------
# Git Function
# -------------------------
def git_operations():
    """Run Git commands to commit and push changes."""
    for command in GIT_COMMANDS:
        try:
            print(f"Running: {command}")
            subprocess.run(command, shell=True, check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error: {e}")
            break

# -------------------------
# Main Execution
# -------------------------
if __name__ == "__main__":
    backup_successful = backup_project()
    if backup_successful:
        git_operations()
    else:
        print("Skipping Git operations due to backup failure.")
