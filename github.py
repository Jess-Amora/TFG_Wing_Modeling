import subprocess

# Define your Git commands
commands = [
    "git add .",
    'git commit -m "Automated commit: Updates from script"',
    "git push origin main"
]

# Execute the commands
for command in commands:
    try:
        print(f"Running: {command}")
        subprocess.run(command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")
        break
