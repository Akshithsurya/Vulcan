#!/bin/bash

# FIRE Educational Framework - Educational Version Only
# WARNING: This tool is for educational purposes only
# Unauthorized use is illegal and unethical

# Color codes
R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
B='\033[1;34m'
NC='\033[0m'
BOLD='\033[1m'

# Configuration
DEFAULT_ATTACKER_IP="127.0.0.1"
DEFAULT_ATTACKER_PORT="4444"
VENV_DIR="./fire_venv"
WORK_DIR="./fire_build"
FINAL_NAME_WIN="pc.exe"
FINAL_NAME_LIN="pc"
LOG_FILE="fire_generator.log"
MAX_LOG_SIZE=1048576
CONFIG_FILE=".fire_config"
TEMP_DIR="/tmp/fire_temp_$$"

# Advanced configuration options
declare -A ENCRYPTION_ALGORITHMS=(
    ["1"]="AES-256-GCM"
    ["2"]="ChaCha20-Poly1305"
    ["3"]="Blowfish-CBC"
    ["4"]="Serpent-256-CBC"
    ["5"]="Twofish-CBC"
)
declare -A PERSISTENCE_METHODS=(
    ["1"]="registry"
    ["2"]="cron"
    ["3"]="launchd"
    ["4"]="systemd"
    ["5"]="startup_folder"
    ["6"]="wmi_subscription"
)
declare -A OBFUSCATION_TECHNIQUES=(
    ["1"]="basic"
    ["2"]="intermediate"
    ["3"]="advanced"
    ["4"]="professional"
    ["5"]="military_grade"
)
declare -A PACKING_METHODS=(
    ["1"]="upx"
    ["2"]="mpress"
    ["3"]="custom"
    ["4"]="none"
)

# Global variables
SCRIPT_VERSION="7.1-Full"
BUILD_TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BUILD_ID=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)

# Configuration variables
ATTACKER_IP=""
ATTACKER_PORT=""
TARGET_OS=""
FINAL_NAME=""
PAYLOAD_TYPE=""
ENCRYPTION_ALGORITHM="AES-256-GCM"
OBFUSCATION_LEVEL=3
PERSISTENCE_METHOD="registry"
ANTI_DEBUG_ENABLED=true
ANTI_VM_ENABLED=true
PACKER_ENABLED=true
PACKING_METHOD="upx"
SHELLCODE_INJECTION=true
PROCESS_HOLLOWING=true
RUNTIME_DECRYPTION=true
KEEP_BUILD_FILES="false"

# Logging system
init_logging() {
    [ ! -f "$LOG_FILE" ] && touch "$LOG_FILE"
    
    if [ -f "$LOG_FILE" ] && [ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE") -gt $MAX_LOG_SIZE ]; then
        mv "$LOG_FILE" "${LOG_FILE}.$(date +%Y%m%d_%H%M%S)"
        gzip "${LOG_FILE}.$(date +%Y%m%d_%H%M%S)" &
    fi
}

log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %T")
    local log_entry="[$timestamp] [$level] $message"
    
    echo "$log_entry" >> "$LOG_FILE"
    
    case $level in
        "CRITICAL") echo -e "${R}[CRITICAL]${NC} ${BOLD}$message${NC}" ;;
        "ERROR") echo -e "${R}[ERROR]${NC} ${BOLD}$message${NC}" ;;
        "WARNING") echo -e "${Y}[WARNING]${NC} $message${NC}" ;;
        "INFO") echo -e "${G}[INFO]${NC} $message${NC}" ;;
        "DEBUG") echo -e "${B}[DEBUG]${NC} $message${NC}" ;;
        "SUCCESS") echo -e "${G}[SUCCESS]${NC} ${BOLD}$message${NC}" ;;
        *) echo "[$level] $message" ;;
    esac
}

# Validation functions
validate_ip() {
    local ip="$1"
    
    [[ ! $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] && return 1
    
    IFS='.' read -ra ADDR <<< "$ip"
    for i in "${ADDR[@]}"; do
        [[ $i -gt 255 ]] || [[ $i -lt 0 ]] && return 1
    done
    
    [[ "$ip" == "0.0.0.0" ]] || [[ "$ip" == "255.255.255.255" ]] && return 1
    
    local first_octet=${ADDR[0]}
    local second_octet=${ADDR[1]}
    
    if [ "$first_octet" == "10" ] || 
       ([ "$first_octet" == "172" ] && [ "$second_octet" -ge 16 ] && [ "$second_octet" -le 31 ]) ||
       ([ "$first_octet" == "192" ] && [ "$second_octet" == "168" ]); then
        echo -e "${Y}[!] Warning: Using private IP address ($ip)${NC}"
    fi
    
    return 0
}

validate_port() {
    local port="$1"
    
    [[ ! $port =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ] && return 1
    
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

# Banner display
display_banner() {
    clear
    
    local os_info=$(uname -s)
    local kernel_info=$(uname -r)
    local arch_info=$(uname -m)
    local cpu_info=$(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs 2>/dev/null || echo "Unknown")
    local mem_info=$(free -h | grep '^Mem:' | awk '{print $2}' 2>/dev/null || echo "Unknown")
    local disk_info=$(df -h / | tail -1 | awk '{print $4}' 2>/dev/null || echo "Unknown")
    
    printf '%s\n' "╔════════════════════════════════════════════════════════════╗"
    printf '%s\n' "║  __      __  _    _  _        _____            _   _          ║"
    printf '%s\n' "║  \ \    / / | |  | || |      / ____|    /\    | \ | |         ║"
    printf '%s\n' "║   \ \  / /  | |  | || |     | |        /  \   |  \| |         ║"
    printf '%s\n' "║    \ \/ /   | |  | || |     | |       / /\ \  | . \` |         ║"
    printf '%s\n' "║     \  /    | |__| || |____ | |____  / ____ \ | |\  |         ║"
    printf '%s\n' "║      \/      \____/ |______| \_____|/_/    \_\|_| \_|         ║"
    printf '%s\n' "║                                                              ║"
    printf '%s\n' "║    [ FIRE // Advanced Malware Generator v$SCRIPT_VERSION ]       ║"
    printf '%s\n' "║                                                              ║"
    printf '%s\n' "║    [ Build ID: $BUILD_ID | Timestamp: $BUILD_TIMESTAMP ]      ║"
    printf '%s\n' "╚══════════════════════════════════════════════════════════╝"
    
    echo -e "\n${B}SYSTEM INFORMATION:${NC}"
    echo -e "${Y}OS:${NC} $os_info $kernel_info"
    echo -e "${Y}Architecture:${NC} $arch_info"
    echo -e "${Y}CPU:${NC} $cpu_info"
    echo -e "${Y}Memory:${NC} $mem_info"
    echo -e "${Y}Free Disk:${NC} $disk_info"
    echo -e "${Y}Build ID:${NC} $BUILD_ID"
    echo -e "${Y}Timestamp:${NC} $BUILD_TIMESTAMP"
    
    echo -e "\n${R}WARNING: This tool is for educational purposes only.${NC}"
    echo -e "${R}Unauthorized use is illegal and unethical.${NC}\n"
}

# Environment setup
check_dependencies() {
    log_message "INFO" "Checking dependencies..."
    
    local missing_deps=()
    local outdated_deps=()
    local optional_deps=()
    
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    else
        local python_version=$(python3 --version 2>&1 | cut -d' ' -f2)
        local python_major=$(echo $python_version | cut -d'.' -f1)
        local python_minor=$(echo $python_version | cut -d'.' -f2)
        
        if [ "$python_major" -lt 3 ] || ([ "$python_major" -eq 3 ] && [ "$python_minor" -lt 7 ]); then
            outdated_deps+=("python3 (version >= 3.7 required, found $python_version)")
        else
            log_message "DEBUG" "Python version OK: $python_version"
        fi
    fi
    
    if ! command -v pip &> /dev/null && ! command -v pip3 &> /dev/null; then
        missing_deps+=("pip")
    else
        local pip_version=$(pip --version 2>/dev/null | cut -d' ' -f2 || pip3 --version 2>/dev/null | cut -d' ' -f2)
        log_message "DEBUG" "Pip version: $pip_version"
    fi
    
    if ! command -v git &> /dev/null; then
        optional_deps+=("git (recommended for version control)")
    fi
    
    if ! command -v upx &> /dev/null; then
        optional_deps+=("upx (recommended for executable compression)")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ] || [ ${#outdated_deps[@]} -ne 0 ]; then
        echo -e "${R}[!] Critical dependencies missing or outdated:${NC}"
        
        for dep in "${missing_deps[@]}"; do
            echo -e "${R}    Missing: $dep${NC}"
        done
        
        for dep in "${outdated_deps[@]}"; do
            echo -e "${Y}    Outdated: $dep${NC}"
        done
        
        echo -e "${Y}[*] Please install/update missing dependencies and try again.${NC}"
        log_message "ERROR" "Missing/outdated dependencies: ${missing_deps[*]} ${outdated_deps[*]}"
        exit 1
    fi
    
    if [ ${#optional_deps[@]} -ne 0 ]; then
        echo -e "${Y}[!] Optional dependencies not found (not critical):${NC}"
        for dep in "${optional_deps[@]}"; do
            echo -e "${Y}    $dep${NC}"
        done
    fi
    
    log_message "SUCCESS" "All critical dependencies are installed and up to date"
}

setup_environment() {
    log_message "INFO" "Setting up environment..."
    
    mkdir -p "$TEMP_DIR"
    
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
    
    if ! source "$VENV_DIR/bin/activate"; then
        log_message "ERROR" "Failed to activate virtual environment"
        exit 1
    fi
    
    echo -e "${Y}[*] Upgrading pip and setuptools...${NC}"
    if ! pip install --quiet --upgrade pip setuptools wheel; then
        log_message "WARNING" "Failed to upgrade pip/setuptools"
    fi
    
    local required_packages=("pyinstaller" "cryptography" "requests" "psutil" "pefile" "yara-python")
    
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
    
    mkdir -p "$WORK_DIR"
    if ! cd "$WORK_DIR"; then
        log_message "ERROR" "Failed to create/access work directory"
        exit 1
    fi
    
    pip freeze > requirements.txt
    log_message "INFO" "Requirements saved to requirements.txt"
    
    log_message "SUCCESS" "Environment setup complete"
}

# Configuration management
get_configuration() {
    echo -e "${B}CONFIGURATION:${NC}"
    
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

    read -p "Configure advanced options? [y/N]: " adv_config
    if [[ "$adv_config" =~ ^[Yy]$ ]]; then
        advanced_config
    fi

    echo -e "\n${B}SELECT TARGET OPERATING SYSTEM:${NC}"
    echo "1) Windows"
    echo "2) Linux"
    echo "3) macOS"
    echo "4) Cross-platform"
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
            3)
                TARGET_OS="macOS"
                FINAL_NAME="$FINAL_NAME_LIN"
                log_message "INFO" "Target OS selected: macOS"
                break
                ;;
            4)
                TARGET_OS="Cross-platform"
                FINAL_NAME="$FINAL_NAME_LIN"
                log_message "INFO" "Target OS selected: Cross-platform"
                break
                ;;
            *)
                echo -e "${R}[!] Invalid OS choice. Please enter 1-4.${NC}"
                ;;
        esac
    done

    echo -e "\n${B}SELECT PAYLOAD TYPE:${NC}"
    echo "1) Bricker (System Destroyer)"
    echo "2) Backdoor (Remote Access)"
    echo "3) Ransomware (File Encryptor)"
    echo "4) Worm (Network Spreader)"
    echo "5) Info Stealer (Data Exfiltration)"
    echo "6) Network Destroyer (DDoS Tool)"
    echo "7) Keylogger (Input Capture)"
    echo "8) Rootkit (System Stealth)"
    echo "9) Custom Payload Template"
    while true; do
        read -p ">> " payload_choice
        if [[ "$payload_choice" =~ ^[1-9]$ ]]; then
            PAYLOAD_TYPE="$payload_choice"
            log_message "INFO" "Payload type selected: $payload_choice"
            break
        else
            echo -e "${R}[!] Invalid payload type. Please enter a number between 1-9.${NC}"
        fi
    done

    read -p "Enter custom filename (leave empty for default): " CUSTOM_NAME
    if [ -n "$CUSTOM_NAME" ]; then
        if [ "$TARGET_OS" == "Windows" ] && [[ ! "$CUSTOM_NAME" =~ \.exe$ ]]; then
            CUSTOM_NAME="${CUSTOM_NAME}.exe"
        fi
        FINAL_NAME="$CUSTOM_NAME"
        log_message "INFO" "Using custom filename: $FINAL_NAME"
    fi

    read -p "Keep build files for debugging? [y/N]: " KEEP_BUILD_FILES
    KEEP_BUILD_FILES=${KEEP_BUILD_FILES:-"false"}
    if [[ "$KEEP_BUILD_FILES" =~ ^[Yy]$ ]]; then
        KEEP_BUILD_FILES="true"
        log_message "INFO" "User chose to keep build files"
    else
        KEEP_BUILD_FILES="false"
        log_message "INFO" "User chose not to keep build files"
    fi

    save_config
}

advanced_config() {
    echo -e "\n${B}ADVANCED CONFIGURATION:${NC}"
    
    echo -e "${Y}Select encryption algorithm:${NC}"
    for i in "${!ENCRYPTION_ALGORITHMS[@]}"; do
        echo "$i) ${ENCRYPTION_ALGORITHMS[$i]}"
    done
    read -p ">> " enc_choice
    ENCRYPTION_ALGORITHM="${ENCRYPTION_ALGORITHMS[$enc_choice]:-${ENCRYPTION_ALGORITHMS[1]}}"
    
    echo -e "\n${Y}Select obfuscation level:${NC}"
    for i in "${!OBFUSCATION_TECHNIQUES[@]}"; do
        echo "$i) ${OBFUSCATION_TECHNIQUES[$i]}"
    done
    read -p ">> " obs_choice
    OBFUSCATION_LEVEL=$obs_choice
    
    echo -e "\n${Y}Select persistence method:${NC}"
    for i in "${!PERSISTENCE_METHODS[@]}"; do
        echo "$i) ${PERSISTENCE_METHODS[$i]}"
    done
    read -p ">> " pers_choice
    PERSISTENCE_METHOD="${PERSISTENCE_METHODS[$pers_choice]:-${PERSISTENCE_METHODS[1]}}"
    
    echo -e "\n${Y}Select packing method:${NC}"
    for i in "${!PACKING_METHODS[@]}"; do
        echo "$i) ${PACKING_METHODS[$i]}"
    done
    read -p ">> " pack_choice
    PACKING_METHOD="${PACKING_METHODS[$pack_choice]:-${PACKING_METHODS[1]}}"
    
    read -p "Enable anti-debugging? [Y/n]: " anti_debug
    ANTI_DEBUG_ENABLED=true
    if [[ "$anti_debug" =~ ^[Nn]$ ]]; then
        ANTI_DEBUG_ENABLED=false
    fi
    
    read -p "Enable anti-VM detection? [Y/n]: " anti_vm
    ANTI_VM_ENABLED=true
    if [[ "$anti_vm" =~ ^[Nn]$ ]]; then
        ANTI_VM_ENABLED=false
    fi
    
    read -p "Enable shellcode injection? [Y/n]: " shellcode
    SHELLCODE_INJECTION=true
    if [[ "$shellcode" =~ ^[Nn]$ ]]; then
        SHELLCODE_INJECTION=false
    fi
    
    read -p "Enable process hollowing? [Y/n]: " hollowing
    PROCESS_HOLLOWING=true
    if [[ "$hollowing" =~ ^[Nn]$ ]]; then
        PROCESS_HOLLOWING=false
    fi
    
    read -p "Enable runtime decryption? [Y/n]: " runtime_decrypt
    RUNTIME_DECRYPTION=true
    if [[ "$runtime_decrypt" =~ ^[Nn]$ ]]; then
        RUNTIME_DECRYPTION=false
    fi
    
    log_message "INFO" "Advanced configuration updated"
}

save_config() {
    cat > "$CONFIG_FILE" << EOF
ATTACKER_IP="$ATTACKER_IP"
ATTACKER_PORT="$ATTACKER_PORT"
TARGET_OS="$TARGET_OS"
FINAL_NAME="$FINAL_NAME"
PAYLOAD_TYPE="$PAYLOAD_TYPE"
ENCRYPTION_ALGORITHM="$ENCRYPTION_ALGORITHM"
OBFUSCATION_LEVEL=$OBFUSCATION_LEVEL
PERSISTENCE_METHOD="$PERSISTENCE_METHOD"
ANTI_DEBUG_ENABLED=$ANTI_DEBUG_ENABLED
ANTI_VM_ENABLED=$ANTI_VM_ENABLED
PACKER_ENABLED=$PACKER_ENABLED
PACKING_METHOD="$PACKING_METHOD"
SHELLCODE_INJECTION=$SHELLCODE_INJECTION
PROCESS_HOLLOWING=$PROCESS_HOLLOWING
RUNTIME_DECRYPTION=$RUNTIME_DECRYPTION
KEEP_BUILD_FILES=$KEEP_BUILD_FILES"
EOF
    log_message "INFO" "Configuration saved to $CONFIG_FILE"
}

load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        log_message "INFO" "Configuration loaded from $CONFIG_FILE"
        return 0
    fi
    return 1
}

validate_config() {
    local errors=()
    
    ! validate_ip "$ATTACKER_IP" && errors+=("Invalid attacker IP: $ATTACKER_IP")
    ! validate_port "$ATTACKER_PORT" && errors+=("Invalid attacker port: $ATTACKER_PORT")
    
    [ "$TARGET_OS" != "Windows" ] && [ "$TARGET_OS" != "Linux" ] && [ "$TARGET_OS" != "macOS" ] && [ "$TARGET_OS" != "Cross-platform" ] && errors+=("Invalid target OS: $TARGET_OS")
    
    [[ ! "$PAYLOAD_TYPE" =~ ^[1-9]$ ]] && errors+=("Invalid payload type: $PAYLOAD_TYPE")
    
    if [ ${#errors[@]} -ne 0 ]; then
        echo -e "${R}[!] Configuration validation failed:${NC}"
        for error in "${errors[@]}"; do
            echo -e "${R}    - $error${NC}"
        done
        return 1
    fi
    
    return 0
}

# Payload generation
generate_payload() {
    local type=$1
    local attacker_ip=$2
    local attacker_port=$3
    local target_os=$4
    local final_name=$5
    
    log_message "INFO" "Generating payload type: $type for $target_os"
    echo -e "${Y}[*] Generating payload for type: $type | Target OS: $target_os${NC}"
    
    if ! validate_config; then
        log_message "ERROR" "Configuration validation failed"
        return 1
    fi
    
    local encryption_key=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)
    
    case $type in
        1) create_bricker_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
        2) create_backdoor_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
        3) create_ransomware_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
        4) create_worm_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
        5) create_stealer_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
        6) create_network_destroyer_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
        7) create_keylogger_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
        8) create_rootkit_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
        9) create_custom_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
        *)
            echo -e "${R}[!] Invalid payload type selected.${NC}"
            log_message "ERROR" "Invalid payload type: $type"
            return 1
            ;;
    esac
    
    [ "$OBFUSCATION_LEVEL" -gt 1 ] && apply_obfuscation "$OBFUSCATION_LEVEL"
    [ "$ANTI_DEBUG_ENABLED" = true ] && apply_anti_debug
    [ "$ANTI_VM_ENABLED" = true ] && apply_anti_vm
    
    echo -e "${Y}[*] Compiling to a standalone executable for $target_os...${NC}"
    
    local pyinstaller_args="--onefile --name=$final_name"
    
    [ "$target_os" == "Windows" ] && pyinstaller_args="$pyinstaller_args --noconsole --windowed --icon=NONE" || pyinstaller_args="$pyinstaller_args --console"
    
    pyinstaller_args="$pyinstaller_args --strip --clean"
    
    [ "$PACKER_ENABLED" = true ] && case $PACKING_METHOD in
        1) pyinstaller_args="$pyinstaller_args --upx-dir=." ;;
        2) pyinstaller_args="$pyinstaller_args --runtime-hookdir=." ;;
        3) pyinstaller_args="$pyinstaller_args --custom-bootstrap" ;;
    esac
    
    if ! pyinstaller $pyinstaller_args payload.py; then
        echo -e "${R}[!] PyInstaller compilation failed.${NC}"
        log_message "ERROR" "PyInstaller compilation failed"
        return 1
    fi

    if [ -f "dist/$final_name" ]; then
        local file_size=$(stat -f%z "dist/$final_name" 2>/dev/null || stat -c%s "dist/$final_name")
        local size_mb=$(echo "scale=2; $file_size / 1048576" | bc)
        local file_hash=$(sha256sum "dist/$final_name" | cut -d' ' -f1)
        
        echo -e "${G}[+] Success! Payload created as 'dist/$final_name' (${size_mb} MB).${NC}"
        echo -e "${G}[+] SHA256: $file_hash${NC}"
        
        mv "dist/$final_name" ..
        
        local metadata_file="../${final_name}.meta"
        cat > "$metadata_file" << EOF
Payload Type: $type
Target OS: $target_os
Build ID: $BUILD_ID
Timestamp: $BUILD_TIMESTAMP
File Size: $file_size bytes
SHA256: $file_hash
Encryption Algorithm: $ENCRYPTION_ALGORITHM
Obfuscation Level: $OBFUSCATION_LEVEL
Persistence Method: $PERSISTENCE_METHOD
Anti-Debug Enabled: $ANTI_DEBUG_ENABLED
Anti-VM Enabled: $ANTI_VM_ENABLED
Packer Enabled: $PACKER_ENABLED
Packing Method: $PACKING_METHOD
Shellcode Injection: $SHELLCODE_INJECTION
Process Hollowing: $PROCESS_HOLLOWING
Runtime Decryption: $RUNTIME_DECRYPTION
EOF
        
        log_message "SUCCESS" "Successfully created executable: $final_name (${size_mb} MB, SHA256: $file_hash)"
        return 0
    else
        echo -e "${R}[!] Failed to create executable. Check for errors above.${NC}"
        log_message "ERROR" "Failed to create executable"
        return 1
    fi
}

# Educational payload templates
create_bricker_payload() {
    printf '%s\n' '#!/usr/bin/env python3
import os
import sys
import time
import platform

def main():
    print("=" * 50)
    print("SYSTEM INFORMATION (Educational)")
    print("=" * 50)
    print(f"System: {platform.system()}")
    print(f"Node: {platform.node()}")
    print(f"Release: {platform.release()}")
    print(f"Version: {platform.version()}")
    print(f"Machine: {platform.machine()}")
    print("=" * 50)
    print("This is an educational template only.")
    print("No harmful actions are performed.")
    print("=" * 50)
    time.sleep(3)

if __name__ == "__main__":
    main()' > payload.py
}

create_backdoor_payload() {
    printf '%s\n' '#!/usr/bin/env python3
import socket
import time
import sys

def simulate_connection():
    print(f"Simulating connection to {sys.argv[1]}:{sys.argv[2]}")
    print("This is an educational simulation only.")
    print("No actual network connections are made.")
    time.sleep(2)

if __name__ == "__main__":
    if len(sys.argv) >= 3:
        simulate_connection()' > payload.py
}

create_ransomware_payload() {
    printf '%s\n' '#!/usr/bin/env python3
import os
from cryptography.fernet import Fernet

def demonstrate_encryption():
    print("Demonstrating file encryption concepts...")
    key = Fernet.generate_key()
    fernet = Fernet(key)
    data = b"Sample data for encryption demonstration"
    encrypted = fernet.encrypt(data)
    decrypted = fernet.decrypt(encrypted)
    print(f"Original: {data}")
    print(f"Encrypted: {encrypted}")
    print(f"Decrypted: {decrypted}")
    print("This is educational only - no files are modified.")

if __name__ == "__main__":
    demonstrate_encryption()' > payload.py
}

create_worm_payload() {
    printf '%s\n' '#!/usr/bin/env python3
import socket
import time
import sys

def simulate_scan():
    print("Simulating network scan...")
    print("This is an educational demonstration only.")
    print("No actual network scanning is performed.")
    time.sleep(2)

if __name__ == "__main__":
    simulate_scan()' > payload.py
}

create_stealer_payload() {
    printf '%s\n' '#!/usr/bin/env python3
import platform
import os
import sys

def collect_info():
    print("Collecting system information...")
    info = {
        "system": platform.system(),
        "node": platform.node(),
        "release": platform.release(),
        "version": platform.version(),
        "machine": platform.machine()
    }
    print("System information collected (educational only):")
    for key, value in info.items():
        print(f"  {key}: {value}")
    print("This is educational only - no data is exfiltrated.")

if __name__ == "__main__":
    collect_info()' > payload.py
}

create_network_destroyer_payload() {
    printf '%s\n' '#!/usr/bin/env python3
import time
import random
import sys

def simulate_traffic():
    print("Simulating network traffic patterns...")
    for i in range(10):
        print(f"Packet {i+1}: {random.randint(64, 1500)} bytes")
        time.sleep(0.1)
    print("This is educational only - no actual traffic is generated.")

if __name__ == "__main__":
    simulate_traffic()' > payload.py
}

create_keylogger_payload() {
    printf '%s\n' '#!/usr/bin/env python3
import time
import sys

def simulate_keylogger():
    print("Simulating keylogger concepts...")
    print("This is an educational demonstration only.")
    print("No actual keylogging is performed.")
    print("Press any key to see the simulation...")
    time.sleep(2)
    print("Simulation complete - no keys were recorded.")

if __name__ == "__main__":
    simulate_keylogger()' > payload.py
}

create_rootkit_payload() {
    printf '%s\n' '#!/usr/bin/env python3
import os
import time
import sys

def demonstrate_stealth():
    print("Demonstrating system stealth concepts...")
    print("This is an educational demonstration only.")
    print("No actual stealth techniques are used.")
    print("Simulating process hiding (educational)...")
    time.sleep(1)
    print("Simulating file hiding (educational)...")
    time.sleep(1)
    print("Simulation complete - no system modifications made.")

if __name__ == "__main__":
    demonstrate_stealth()' > payload.py
}

create_custom_payload() {
    printf '%s\n' '#!/usr/bin/env python3
import sys
import time
import platform

class CustomPayload:
    def __init__(self):
        self.target_os = platform.system()
        self.info = {}
    
    def gather_system_info(self):
        self.info = {
            "system": platform.system(),
            "node": platform.node(),
            "release": platform.release(),
            "version": platform.version(),
            "machine": platform.machine(),
            "processor": platform.processor()
        }
    
    def display_info(self):
        print("Custom Payload Framework (Educational)")
        print("=" * 40)
        for key, value in self.info.items():
            print(f"{key}: {value}")
        print("=" * 40)
        print("This is an educational framework only.")
        time.sleep(2)
    
    def run(self):
        print("Starting custom payload...")
        self.gather_system_info()
        self.display_info()

def main():
    payload = CustomPayload()
    payload.run()

if __name__ == "__main__":
    main()' > payload.py
}

# Obfuscation and anti-analysis
apply_obfuscation() {
    local level=$1
    
    echo -e "${Y}[*] Applying obfuscation level $level...${NC}"
    
    case $level in
        1)
            sed -i.bak -e 's/\bdef \([a-zA-Z_][a-zA-Z0-9_]*\)/def _\1/g' \
                      -e 's/\bclass \([a-zA-Z_][a-zA-Z0-9_]*\)/class _\1/g' \
                      payload.py
            ;;
        2)
            sed -i.bak -e 's/\bdef \([a-zA-Z_][a-zA-Z0-9_]*\)/def _\1/g' \
                      -e 's/\bclass \([a-zA-Z_][a-zA-Z0-9_]*\)/class _\1/g' \
                      -e 's/\([a-zA-Z_][a-zA-Z0-9_]*\) =/\1 =/g' \
                      payload.py
            ;;
        3)
            python3 -c "
import re
with open('payload.py', 'r') as f:
    content = f.read()
content = re.sub(r'\"([^\"]+)\"', lambda m: f'chr({ord(m.group(1)[0])}) + \"{m.group(1)[1:]}\"', content)
with open('payload.py', 'w') as f:
    f.write(content)"
            ;;
        4)
            python3 -c "
import base64
import zlib

with open('payload.py', 'rb') as f:
    content = f.read()
compressed = zlib.compress(content)
encoded = base64.b64encode(compressed)
with open('payload.py', 'wb') as f:
    f.write(b'import zlib, base64\nexec(zlib.decompress(base64.b64decode(' + str(encoded) + b'))')"
            ;;
        5)
            python3 -c "
import base64
import zlib
import marshal

with open('payload.py', 'rb') as f:
    code = f.read()
bytecode = compile(code, '<string>', 'exec')
marshaled = marshal.dumps(bytecode)
compressed = zlib.compress(marshaled)
encoded = base64.b64encode(compressed)
with open('payload.py', 'wb') as f:
    f.write(b'import zlib, base64, marshal, types\nexec(marshal.loads(zlib.decompress(base64.b64decode(' + str(encoded) + b'))')"
            ;;
    esac
    
    log_message "INFO" "Obfuscation level $level applied"
}

apply_anti_debug() {
    echo -e "${Y}[*] Applying anti-debugging techniques...${NC}"
    
    cat >> payload.py << 'EOF'

import sys
import os
import time

def check_debugger():
    try:
        debuggers = ['gdb', 'lldb', 'strace', 'ltrace']
        for debugger in debuggers:
            if os.system(f'pgrep -f {debugger} > /dev/null 2>&1') == 0:
                print(f'Debugger detected: {debugger}')
                return True
        return False
    except:
        return False

def check_timing():
    start = time.time()
    time.sleep(0.1)
    end = time.time()
    if (end - start) > 0.15:
        print('Timing anomaly detected')
        return True
    return False

if check_debugger() or check_timing():
    print('Debugging environment detected - exiting')
    sys.exit(0)
EOF
    
    log_message "INFO" "Anti-debugging techniques applied"
}

apply_anti_vm() {
    echo -e "${Y}[*] Applying anti-VM techniques...${NC}"
    
    cat >> payload.py << 'EOF'

def check_vm():
    try:
        vm_indicators = [
            '/proc/vz', '/proc/xen', '/dev/virtio-ports',
            '/sys/class/dmi/id/product_name'
        ]
        
        for indicator in vm_indicators:
            if os.path.exists(indicator):
                with open(indicator, 'r') as f:
                    content = f.read().lower()
                    if any(vm in content for vm in ['vmware', 'virtualbox', 'qemu', 'kvm']):
                        print('Virtualization detected')
                        return True
        
        try:
            import uuid
            mac = uuid.getnode()
            mac_str = ':'.join([f'{(mac >> 8*i) & 0xff:02x}' for i in range(6)])
            if mac_str.startswith(('00:0c:29', '00:1c:14', '08:00:27', '00:50:56')):
                print('VM MAC address detected')
                return True
        except:
            pass
        
        return False
    except:
        return False

if check_vm():
    print('Virtual environment detected - exiting')
    sys.exit(0)
EOF
    
    log_message "INFO" "Anti-VM techniques applied"
}

# Cleanup
cleanup() {
    log_message "INFO" "Performing cleanup..."
    
    cd ..
    
    if [ "$KEEP_BUILD_FILES" != "true" ]; then
        if command -v shred &> /dev/null; then
            find "$WORK_DIR" -type f -exec shred -vfz -n 3 {} \;
        fi
        rm -rf "$WORK_DIR"
        log_message "INFO" "Removed temporary build files"
    else
        log_message "INFO" "Keeping temporary build files as requested"
    fi
    
    if [ -d "$TEMP_DIR" ]; then
        if command -v shred &> /dev/null; then
            find "$TEMP_DIR" -type f -exec shred -vfz -n 3 {} \;
        fi
        rm -rf "$TEMP_DIR"
    fi
    
    deactivate 2>/dev/null || true
    
    log_message "SUCCESS" "Cleanup complete"
}

# Initialization
init() {
    trap cleanup EXIT
    
    init_logging
    display_banner
    check_dependencies
    
    if ! load_config; then
        log_message "INFO" "No existing configuration found, using defaults"
    fi
}

# Main function
main() {
    init
    
    get_configuration
    setup_environment
    
    if generate_payload "$PAYLOAD_TYPE" "$ATTACKER_IP" "$ATTACKER_PORT" "$TARGET_OS" "$FINAL_NAME"; then
        echo -e "${G}>> OPERATION COMPLETE. Check the parent directory for '$FINAL_NAME'.${NC}"
        echo -e "${G}>> Metadata saved as '${FINAL_NAME}.meta'${NC}"
        log_message "SUCCESS" "Operation completed successfully"
    else
        echo -e "${R}>> OPERATION FAILED.${NC}"
        log_message "ERROR" "Operation failed"
    fi
}

# Execute main function
main "$@"
