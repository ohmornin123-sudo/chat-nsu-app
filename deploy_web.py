import os
import subprocess
import shutil

app_dir = r"C:\src\capstone_app"
web_dir = r"C:\src\chat-nsu-web"
build_web_dir = os.path.join(app_dir, "build", "web")

print("1. Committing and Pushing App Source Code (chat-nsu-app)...")
try:
    subprocess.run(["git", "add", "."], cwd=app_dir, check=True)
    subprocess.run(["git", "commit", "-m", "Auto-sync updated Flutter app source code"], cwd=app_dir)
    subprocess.run(["git", "push", "origin", "main"], cwd=app_dir, check=True)
except Exception as e:
    print(f"Source push notice: {e}")

print("2. Building Flutter Web Release...")
subprocess.run(["flutter.bat", "build", "web", "--release"], cwd=app_dir, check=True, shell=True)

print("3. Syncing files to chat-nsu-web-...")
for item in os.listdir(build_web_dir):
    src_item = os.path.join(build_web_dir, item)
    dst_item = os.path.join(web_dir, item)
    if item == ".git":
        continue
    if os.path.isdir(src_item):
        if os.path.exists(dst_item):
            shutil.rmtree(dst_item)
        shutil.copytree(src_item, dst_item)
    else:
        shutil.copy2(src_item, dst_item)

print("4. Committing and Pushing to GitHub (ohmornin123-sudo/chat-nsu-web-)...")
subprocess.run(["git", "add", "."], cwd=web_dir, check=True)
subprocess.run(["git", "commit", "-m", "Auto-deploy updated Flutter web build"], cwd=web_dir)
subprocess.run(["git", "push", "origin", "main"], cwd=web_dir, check=True)

print("All done! Both App Source Code and Web Hosting are synced! Netlify will update in 5 seconds!")
