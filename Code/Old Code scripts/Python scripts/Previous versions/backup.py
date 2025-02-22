import os
import shutil
from datetime import datetime

# Define source and backup directories
SOURCE_DIR = r'C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Project_Root'  # Replace with your Project Root path
BACKUP_BASE_DIR = r'C:\Users\jessa\MATLAB Drive\Back up'   # Replace with your backup folder path

# Create a timestamp for each backup
timestamp = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
BACKUP_DIR = os.path.join(BACKUP_BASE_DIR, f'backup_{timestamp}')

# Function to create a backup
def backup_project():
    if not os.path.exists(SOURCE_DIR):
        print(f"Source directory does not exist: {SOURCE_DIR}")
        return

    if not os.path.exists(BACKUP_BASE_DIR):
        os.makedirs(BACKUP_BASE_DIR)

    try:
        shutil.copytree(SOURCE_DIR, BACKUP_DIR)
        print(f"Backup completed successfully! Files saved to: {BACKUP_DIR}")
    except Exception as e:
        print(f"Backup failed: {e}")

if __name__ == "__main__":
    backup_project()