#Vulcan - Advanced Educational Security Framework
Forensics, Investigation, Research & Education Tool

<div align="center">
![Version](https://img.shields.io/badge/version-7.9--Enhanced-orange )
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20WSL-brightgreen )
![Python](https://img.shields.io/badge/python-3.7%2B-blue )
![Bash](https://img.shields.io/badge/bash-script-yellow )
![License](https://img.shields.io/badge/license-Educational-green )
![Educational](https://img.shields.io/badge/Educational%20Use-ONLY-red )
![Security](https://img.shields.io/badge/Security-Research-purple )
**Educational Framework for Security Research & Training**
</div>
---
## ⚠️ CRITICAL WARNING - READ THIS FIRST!
### 🔥 VULCAN IS FOR EDUCATIONAL PURPOSES ONLY 🔥
**DO NOT USE FOR MALICIOUS PURPOSES**
**UNAUTHORIZED ACCESS TO COMPUTER SYSTEMS IS ILLEGAL**
> **⚖️ LEGAL DISCLAIMER:**
> By using VULCAN, you agree to:
>
> - ✅ Use it only in legally authorized environments
> - ✅ Test only on systems you own or have explicit written permission to test
> - ✅ Comply with all applicable laws and regulations
> - ✅ Accept FULL responsibility for your actions
> - ✅ Understand that violating computer crime laws can result in severe penalties including imprisonment and fines
>
> **THE DEVELOPER IS NOT RESPONSIBLE FOR ANY MISUSE OF THIS TOOL**
---
## 📋 TABLE OF CONTENTS
1. [⚠️ Critical Warning](#️-critical-warning---read-this-first)
2. [🎯 What is Vulcan?](#-what-is-vulcan)
3. [✨ Key Features](#-key-features)
4. [🚀 Quick Start](#-quick-start)
5. [📋 Prerequisites](#-prerequisites)
6. [🛠️ Installation](#️-installation)
7. [📖 Usage Guide](#-usage-guide)
8. [🎓 Educational Use Cases](#-educational-use-cases)
9. [🔒 Safety Protocols](#-safety-protocols)
10. [⚖️ Legal Guidelines](#️-legal-guidelines)
11. [🏛️ Academic Integration](#️-academic-integration)
12. [🚨 Emergency Procedures](#-emergency-procedures)
13. [📚 Learning Resources](#-learning-resources)
14. [🤝 Contributing](#-contributing)
15. [📄 License](#-license)
---
## 🎯 WHAT IS VULCAN?
VULCAN (Forensics, Investigation, Research & Education) is an advanced educational security framework designed to help cybersecurity students, researchers, and professionals understand:
- **Malware Construction Techniques** - How malicious software is built
- **Persistence Mechanisms** - Methods malware uses to survive reboots
- **Obfuscation & Evasion** - Techniques to avoid detection
- **Cross-Platform Threats** - How malware operates across different operating systems
- **Detection & Prevention** - How to identify and stop malicious software
### 🎓 Educational Mission
VULCAN provides a **safe, controlled environment** for learning about:
- Threat construction and analysis
- Security testing methodologies
- Incident response procedures
- Digital forensics techniques
- Defensive security measures
---
## ✨ KEY FEATURES
### Core Capabilities
```
╔════════════════════════════════════════════════════════════╗
║ VULCAN v7.9 FEATURES ║
╠════════════════════════════════════════════════════════════╣
║ ✅ Multi-Platform Payload Generation (Win/Linux/macOS) ║
║ ✅ Cross-Platform Build Support ║
║ ✅ Advanced Code Obfuscation (5 Levels) ║
║ ✅ Multiple Encryption Algorithms (AES, ChaCha20, etc.) ║
║ ✅ 9+ Persistence Methods (Registry, Cron, LaunchAgent) ║
║ ✅ Anti-Analysis Techniques (VM/Debugger Detection) ║
║ ✅ Cloudflare HTTPS Tunnel Integration ║
║ ✅ Auto-Execution System (NEW!) ║
║ ✅ Fake GUI Social Engineering (NEW!) ║
║ ✅ Comprehensive Logging System ║
║ ✅ Interactive Configuration Wizard ║
╚════════════════════════════════════════════════════════════╝
```
### Educational Payload Types
| Type | Code | Educational Focus | Risk Level |
|------|------|------------------|------------|
| Bricker | 1 | System destruction concepts | 🔴 HIGH |
| Backdoor | 2 | Remote access mechanisms | 🔴 HIGH |
| Ransomware | 3 | Encryption/decryption methods | 🔴 HIGH |
| Worm | 4 | Network propagation | 🟠 MEDIUM |
| Info Stealer | 5 | Data exfiltration | 🟠 MEDIUM |
| Network Destroyer | 6 | DDoS/Network stress testing | 🔴 HIGH |
| Keylogger | 7 | Input capture methods | 🟡 LOW |
| Rootkit | 8 | System stealth techniques | 🔴 HIGH |
| Custom Template | 9 | Framework for learning | 🟢 SAFE |
### 🆕 NEW FEATURES (v7.9)
#### 1. Auto-Execution System
Intelligent persistence setup that automatically configures system startup mechanisms:
**Windows:**
- Registry Run Keys (HKCU\Software\Microsoft\Windows\CurrentVersion\Run)
- Windows Startup Folder
- WMI Event Subscriptions
- Scheduled Tasks
**Linux:**
- Cron Jobs (@reboot)
- Systemd Services
- Init.d Scripts
- Profile Modifications
**macOS:**
- LaunchAgents
- LaunchDaemons
- Login Items
- Cron Jobs
#### 2. Fake GUI Feature
Social engineering enhancement that displays a fake "System Update" window while payload executes in background:
- Professional-looking GUI using tkinter
- Customizable appearance and messages
- Automatic window closure after execution
- Increases user interaction compliance in educational demonstrations
#### 3. Cross-Platform Support
Build for Windows, Linux, and macOS simultaneously:
- Automatic platform detection
- Universal launcher scripts
- Platform-specific optimizations
- Centralized build management
#### 4. Cloudflare Tunnel Integration
Secure payload delivery via HTTPS:
- Automatic cloudflared setup
- Encrypted traffic
- QR code generation
- Professional download portal
---
## 🚀 QUICK START
```bash
# Clone the repository
git clone https://github.com/yourusername/vulcan.git
cd vulcan
# Make the script executable
chmod +x vulcan.sh
# Run the framework
./vulcan.sh
```
**Note:** If you encounter permission issues on macOS:
```bash
bash vulcan.sh
# or
sh vulcan.sh
```
---
## 📋 PREREQUISITES
### System Requirements
| Platform | Status | Minimum Requirements |
|----------|--------|---------------------|
| Linux | ✅ Fully Supported | Ubuntu/Debian/Kali, 2GB RAM, 5GB storage |
| macOS | ✅ Supported | macOS 10.15+, 2GB RAM, 5GB storage |
| WSL2 | ✅ Supported | Windows 10/11 with WSL2 enabled |
### Software Requirements
```bash
# Core Dependencies
- Python 3.7 or higher
- pip (Python package manager)
- git
- upx (optional, for compression)
# Python Packages (auto-installed)
- pyinstaller
- cryptography
- requests
- flask
- psutil
- pefile
- yara-python
```
---
## 🛠️ INSTALLATION
### Method 1: Basic Installation (Recommended)
```bash
# 1. Clone the repository
git clone https://github.com/yourusername/vulcan.git
# 2. Navigate to directory
cd vulcan
# 3. Make executable
chmod +x vulcan.sh
# 4. Run (no sudo required for basic usage)
./vulcan.sh
```
### Method 2: Complete Installation with Dependencies
```bash
#!/bin/bash
# Complete VULCAN installation script
echo "Installing VULCAN Educational Framework..."
echo "========================================"
# Update system packages
sudo apt-get update && sudo apt-get upgrade -y
# Install system dependencies
sudo apt-get install -y \
python3 \
python3-pip \
python3-venv \
git \
upx \
wget \
curl
# Clone VULCAN repository
git clone https://github.com/yourusername/vulcan.git
cd vulcan
# Make script executable
chmod +x vulcan.sh
# Display success message
echo ""
echo "✅ VULCAN installation complete!"
echo "📁 Location: $(pwd)"
echo "🚀 Run: ./vulcan.sh"
echo ""
echo "⚠️ REMEMBER: Educational use only!"
```
### Platform-Specific Installation
#### Ubuntu/Debian/Kali Linux
```bash
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git upx
git clone https://github.com/yourusername/vulcan.git
cd vulcan
chmod +x vulcan.sh
./vulcan.sh
```
#### macOS
```bash
# Install Homebrew first (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh )"
# Install dependencies
brew install python3 git upx
# Clone and run
git clone https://github.com/yourusername/vulcan.git
cd vulcan
chmod +x vulcan.sh
./vulcan.sh
```
#### Windows (WSL2)
```bash
# Enable WSL2 first, then:
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git
git clone https://github.com/yourusername/vulcan.git
cd vulcan
chmod +x vulcan.sh
./vulcan.sh
```
---
## 📖 USAGE GUIDE
### First-Time Setup
When you run `./vulcan.sh` for the first time, you'll see:
```
╔════════════════════════════════════════════════════════════╗
║ __ __ _ _ _ _____ _ _ ║
║ \ \ / / | | | || | / ____| /\ | \ | | ║
║ \ \ / / | | | || | | | / \ | \| | ║
║ \ \/ / | | | || | | | / /\ \ | . ` | ║
║ \ / | |__| || |____ | |____ / ____ \ | |\ | ║
║ \/ \____/ |______| \_____|/_/ \_\|_| \_| ║
║ ║
║ [ VULCAN // Advanced Educational Framework v7.9 ] ║
╚════════════════════════════════════════════════════════════╝
WARNING: This tool is for educational purposes only.
Unauthorized use is illegal and unethical.
```
### Configuration Workflow
#### 1. Basic Configuration
```bash
Enter attacker IP [default: 127.0.0.1]:
Enter attacker port [default: 4444]:
```
#### 2. Target Operating System
```bash
SELECT TARGET OPERATING SYSTEM:
1) Windows
2) Linux
3) macOS
4) Cross-platform # NEW! Build for all platforms
```
#### 3. Payload Type Selection
```bash
SELECT PAYLOAD TYPE:
1) Bricker (System Destroyer)
2) Backdoor (Remote Access)
3) Ransomware (File Encryptor)
4) Worm (Network Spreader)
5) Info Stealer (Data Exfiltration)
6) Network Destroyer (DDoS Tool)
7) Keylogger (Input Capture)
8) Rootkit (System Stealth)
9) Custom Payload Template
```
#### 4. Auto-Execution Configuration (NEW!)
```bash
AUTO-EXECUTION CONFIGURATION:
Enable auto-execution on installation? [Y/n]:
```
**If enabled, select persistence method:**
**Windows Options:**
- Registry Run Keys
- Windows Startup Folder
- WMI Event Subscription
- Scheduled Task
**Linux Options:**
- Cron Job
- Systemd Service
- Init.d Script
- Profile Modification
**macOS Options:**
- LaunchAgent
- LaunchDaemon
- Login Item
- Cron Job
#### 5. Appearance Configuration (NEW!)
```bash
APPEARANCE CONFIGURATION:
Enable Fake GUI (Social Engineering)? [Y/n]:
```
**What it does:**
- Displays a fake "System Update" window
- Masks malicious activity
- Demonstrates social engineering techniques
- Automatically closes after execution
#### 6. Delivery Method
```bash
SELECT DELIVERY METHOD:
1) Email Delivery
2) USB Drive Preparation
3) Web Server Hosting
4) Network Distribution
5) Social Engineering Kit
6) Application Bundling
7) Cloudflare Tunnel (Secure Remote Access) # NEW!
8) Skip Delivery (Generate Only)
```
### Example Educational Scenarios
#### Scenario 1: Safe Local Testing
```bash
# SAFE CONFIGURATION FOR LEARNING
Attacker IP: 127.0.0.1 # LOCALHOST ONLY!
Attacker Port: 4444
Target OS: Linux
Payload: Custom Template (9)
Auto-Execution: Disabled
Fake GUI: Disabled
Delivery: Skip (8)
```
#### Scenario 2: Cross-Platform Study
```bash
# STUDY MULTIPLE PLATFORMS
Attacker IP: 127.0.0.1
Attacker Port: 4444
Target OS: Cross-platform (4)
Payload: Backdoor (2)
Auto-Execution: Enabled
Persistence: Windows Startup + Linux Cron + macOS LaunchAgent
Fake GUI: Enabled
Delivery: Skip (8)
```
#### Scenario 3: Cloudflare Tunnel Demo
```bash
# SECURE DELIVERY DEMONSTRATION
Attacker IP: 127.0.0.1
Attacker Port: 4444
Target OS: Windows
Payload: Info Stealer (5)
Auto-Execution: Enabled
Fake GUI: Enabled
Delivery: Cloudflare Tunnel (7)
Tunnel Port: 8080
```
### Output Files
After successful build:
**Single Platform:**
```
vulcan/
├── pc.exe (Windows) or pc (Linux/macOS)
├── pc.exe.meta (Build metadata)
└── vulcan_generator.log (Detailed logs)
```
**Cross-Platform:**
```
vulcan/
├── cross_platform_builds/
│ ├── pc.exe (Windows)
│ ├── pc_linux (Linux)
│ ├── pc_macos (macOS)
│ ├── launcher.sh (Unix launcher)
│ ├── launcher.bat (Windows launcher)
│ ├── README.txt (Build summary)
│ └── *.meta (Individual metadata files)
└── vulcan_generator.log
```
**Cloudflare Tunnel:**
```
vulcan/
├── vulcan_delivery/
│ └── cloudflare_tunnel_info.txt
└── cloudflared/
└── cloudflared (binary)
```
---
## 🎓 EDUCATIONAL USE CASES
### 1. Cybersecurity Courses
**Course**: Introduction to Malware Analysis
**Week 1-2: Fundamentals**
- Use Custom Template (Type 9) to understand basic structure
- Study how payloads are compiled with PyInstaller
- Analyze the generated executable with hex editors
**Week 3-4: Persistence**
- Enable Auto-Execution feature
- Compare different persistence methods across OSes
- Practice detecting persistence with Autoruns, cron, launchctl
**Week 5-6: Social Engineering**
- Enable Fake GUI feature
- Analyze user interaction patterns
- Study psychological manipulation techniques
**Week 7-8: Defense**
- Create detection rules for YARA
- Build behavioral analysis signatures
- Develop removal scripts
### 2. Security Researcher Training
```bash
# Lab Exercise: Behavioral Analysis
1. Generate payload with all features enabled
2. Execute in sandboxed VM (Cuckoo, Any.run)
3. Monitor:
- File system changes
- Registry modifications
- Network connections
- Process creation
4. Document findings
5. Create detection signatures
```
### 3. Incident Response Practice
```bash
# Scenario: Compromised System
1. Deploy VULCAN payload in controlled environment
2. Practice identification techniques:
- Process analysis (ps, tasklist)
- Network analysis (netstat, ss)
- File system forensics (find, dir)
- Registry analysis (regedit, reg query)
3. Develop removal procedures
4. Create incident report
```
### 4. Red Team Training
**Authorized Testing Only!**
```bash
# Demonstrate evasion techniques:
- Obfuscation levels 1-5
- Anti-debugging mechanisms
- Anti-VM detection
- Process hollowing
- Shellcode injection
# Study detection bypass:
- Analyze AV/EDR responses
- Document detection gaps
- Recommend improvements
```
---
## 🔒 SAFETY PROTOCOLS
### MANDATORY SAFETY MEASURES
#### 1. Isolated Testing Environment
```bash
# ALWAYS TEST IN:
✅ Virtual Machines (VirtualBox, VMware, QEMU)
✅ Docker Containers (--network=none)
✅ Dedicated Test Hardware (air-gapped)
✅ Cloud VPS (completely isolated)
❌ NEVER ON:
- Personal computers
- Work machines
- Production servers
- Shared networks
```
#### 2. Network Isolation
```bash
# SAFE NETWORK CONFIGURATION:
✅ Use 127.0.0.1 (localhost) ONLY
✅ Disconnect from internet during testing
✅ Use virtual network interfaces
✅ Configure firewall to block external access
# Example: iptables rules
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
```
#### 3. Virtual Machine Setup
```bash
# Recommended VM Configuration:
# VirtualBox
VBoxManage modifyvm "TestVM" --nic1 intnet
VBoxManage modifyvm "TestVM" --intnet1 "isolated_net"
# VMware
# Edit .vmx file:
ethernet0.connectionType = "custom"
ethernet0.vnet = "vmnet0"
# Disable shared folders and clipboard
```
#### 4. Pre-Execution Checklist
```
[ ] VM snapshot taken
[ ] Network isolated
[ ] Backups created
[ ] Monitoring tools ready
[ ] Documentation prepared
[ ] Emergency procedures reviewed
[ ] Supervisor notified (if applicable)
[ ] Legal authorization obtained
```
### Built-in Safety Features
| Safety Feature | Status | Description |
|---------------|--------|-------------|
| IP Validation | ✅ Enabled | Warns about dangerous IPs |
| Port Validation | ✅ Enabled | Warns about reserved ports |
| Educational Warnings | ✅ Enabled | Multiple safety prompts |
| Environment Detection | ✅ Enabled | Can detect VM/sandbox |
| Comprehensive Logging | ✅ Enabled | Audit trail of all actions |
| Auto-Exec Warning | ✅ Enabled | Warns when persistence is enabled |
| Localhost Default | ✅ Enabled | Defaults to 127.0.0.1 |
---
## ⚖️ LEGAL GUIDELINES
### ACCEPTABLE USE CASES
```
✅ University cybersecurity courses (supervised)
✅ Corporate security training (authorized)
✅ Personal education (OWN systems ONLY)
✅ Security research (isolated lab)
✅ CTF competitions (sandboxed)
✅ Authorized penetration testing (written contract)
✅ Academic research (ethics board approval)
```
### PROHIBITED USE CASES
```
❌ Unauthorized system access
❌ Data theft or destruction
❌ Extortion or ransom demands
❌ Attacking others' systems
❌ Testing without permission
❌ Corporate espionage
❌ Government system testing (without authorization)
❌ Critical infrastructure testing
❌ Distributing to unauthorized parties
```
### LEGAL CONSEQUENCES
```
⚖️ Computer Fraud and Abuse Act (CFAA)
→ Up to 20 years imprisonment
→ Fines up to $250,000
⚖️ State Computer Crime Laws
→ Varies by jurisdiction
→ Additional penalties possible
⚖️ Civil Liability
→ Financial damages
→ Legal fees
→ Restitution
⚖️ Professional Consequences
→ Job termination
→ License revocation
→ Industry blacklisting
⚖️ International Laws
→ Computer Misuse Act (UK)
→ Cybercrime Convention (EU)
→ Country-specific regulations
```
### Required Authorization
**Before using VULCAN, you MUST have:**
1. **Written Permission**
- Signed by system owner
- Specific scope defined
- Time period specified
2. **Legal Review**
- Compliance verification
- Liability assessment
- Insurance consideration
3. **Ethics Approval** (Academic)
- IRB approval
- Student consent
- Faculty oversight
---
## 🏛️ ACADEMIC INTEGRATION
### Course Integration Guide
#### Cybersecurity 101: Introduction to Threats
**Week-by-Week Breakdown:**
| Week | Topic | VULCAN Module | Lab Activity |
|------|-------|--------------|--------------|
| 1 | Malware Basics | Payload Types 1-3 | Analyze structure |
| 2 | Persistence | Auto-Execution | Study Windows Registry |
| 3 | Cross-Platform | Cross-platform build | Compare OSes |
| 4 | Social Engineering | Fake GUI | User interaction study |
| 5 | Obfuscation | Obfuscation levels | Reverse engineering |
| 6 | Detection | All features | Create YARA rules |
| 7 | Response | Full simulation | Incident handling |
| 8 | Prevention | Defense project | Build security tools |
#### Student Safety Contract Template
```
VULCAN EDUCATIONAL FRAMEWORK
STUDENT ACCEPTABLE USE AGREEMENT
I, _________________, agree to the following terms:
1. I will use VULCAN only for educational purposes in supervised lab environments.
2. I will not deploy VULCAN-generated payloads on any system I do not own or have
explicit written permission to test.
3. I will maintain all generated files in isolated, secure environments.
4. I will immediately report any accidental deployment or security incident to
my instructor.
5. I understand that misuse of VULCAN may result in:
- Course failure
- Academic disciplinary action
- Legal prosecution
- Civil liability
6. I have read and understood the VULCAN documentation and legal warnings.
Student Signature: ___________________ Date: ___________
Instructor Signature: ________________ Date: ___________
```
### Lab Environment Setup
```bash
# Recommended Lab Configuration
# 1. Create isolated network
sudo ip link add vulcan-lab0 type bridge
sudo ip addr add 192.168.100.1/24 dev vulcan-lab0
sudo ip link set vulcan-lab0 up
# 2. Configure firewall
sudo iptables -A FORWARD -i vulcan-lab0 -o eth0 -j DROP
sudo iptables -A FORWARD -i eth0 -o vulcan-lab0 -j DROP
# 3. Create VM template
# - OS: Ubuntu 20.04 LTS (or Windows 10)
# - RAM: 2GB minimum
# - Disk: 20GB
# - Network: vulcan-lab0 bridge only
# - Snapshot: "Clean State"
# 4. Deploy to students
# Each student gets isolated VM with VULCAN pre-installed
```
---
## 🚨 EMERGENCY PROCEDURES
### IF SOMETHING GOES WRONG
#### Immediate Actions
```bash
# 1. DISCONNECT FROM NETWORK IMMEDIATELY
sudo ifconfig eth0 down # Method 1
sudo ip link set eth0 down # Method 2
# OR physically unplug cable
# 2. ISOLATE THE SYSTEM
sudo systemctl stop networking # Stop all networking
sudo iptables -F # Flush firewall rules
sudo iptables -P INPUT DROP # Block all incoming
sudo iptables -P OUTPUT DROP # Block all outgoing
sudo iptables -A INPUT -i lo -j ACCEPT # Allow localhost
sudo iptables -A OUTPUT -o lo -j ACCEPT
# 3. STOP ALL SUSPICIOUS PROCESSES
ps aux | grep -E 'pc|vulcan|suspicious' | awk '{print $2}' | xargs kill -9
# 4. CHECK FOR PERSISTENCE
# Windows
reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Run
schtasks /query /fo LIST
# Linux
crontab -l
systemctl list-units --type=service
ls /etc/init.d/
# macOS
launchctl list
ls /Library/LaunchAgents/
ls /Library/LaunchDaemons/
```
#### Documentation Checklist
```
[ ] Screenshot all error messages
[ ] Save system logs (syslog, Event Viewer)
[ ] Note exact time of incident
[ ] Document actions taken
[ ] Preserve evidence (don't delete files)
[ ] Record network activity
[ ] List affected systems
[ ] Identify scope of compromise
```
#### Reporting Procedures
**Immediate Contacts:**
1. **Course Instructor**
- Report within 1 hour
- Provide full incident details
2. **Lab Administrator**
- Technical assistance
- System isolation
3. **IT Security**
- Campus/Corporate security team
- Incident response coordination
4. **Legal Department** (if serious)
- Compliance assessment
- Liability management
### Incident Response Script
```bash
#!/bin/bash
# VULCAN Emergency Response Script
echo "VULCAN EMERGENCY RESPONSE"
echo "======================="
echo "Timestamp: $(date)"
echo ""
# 1. Network isolation
echo "[1/6] Isolating network..."
sudo ifconfig eth0 down 2>/dev/null || sudo ip link set eth0 down
echo "✓ Network isolated"
# 2. Process termination
echo "[2/6] Stopping suspicious processes..."
killall -9 pc 2>/dev/null
killall -9 vulcan 2>/dev/null
echo "✓ Processes terminated"
# 3. Persistence removal
echo "[3/6] Removing persistence mechanisms..."
# Windows
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v SystemUpdate /f 2>/dev/null
schtasks /delete /tn "SystemUpdate" /f 2>/dev/null
# Linux
crontab -r 2>/dev/null
systemctl disable system-update.service 2>/dev/null
# macOS
launchctl unload /Library/LaunchAgents/com.system.update.plist 2>/dev/null
rm /Library/LaunchAgents/com.system.update.plist 2>/dev/null
echo "✓ Persistence removed"
# 4. Evidence preservation
echo "[4/6] Preserving evidence..."
mkdir -p ~/vulcan_incident_$(date +%Y%m%d_%H%M%S)
cp /var/log/* ~/vulcan_incident_$(date +%Y%m%d_%H%M%S)/ 2>/dev/null
echo "✓ Evidence preserved"
# 5. System snapshot
echo "[5/6] Taking system snapshot..."
ps aux > ~/vulcan_incident_$(date +%Y%m%d_%H%M%S)/processes.txt
netstat -tulpn > ~/vulcan_incident_$(date +%Y%m%d_%H%M%S)/network.txt
echo "✓ Snapshot complete"
# 6. Report generation
echo "[6/6] Generating incident report..."
cat > ~/vulcan_incident_$(date +%Y%m%d_%H%M%S)/REPORT.txt << EOF
VULCAN INCIDENT REPORT
====================
Date: $(date)
System: $(uname -a)
User: $(whoami)
IP: $(hostname -I)
Actions Taken:
1. Network isolated
2. Processes terminated
3. Persistence removed
4. Evidence preserved
5. System snapshot taken
Next Steps:
1. Contact your instructor immediately
2. Do not restart system
3. Await further instructions
4. Review security policies
EOF
echo "✓ Report generated"
echo ""
echo "Emergency procedures complete!"
echo "Evidence location: ~/vulcan_incident_$(date +%Y%m%d_%H%M%S)/"
echo ""
echo "IMPORTANT: Contact your instructor immediately!"
```
---
## 📚 LEARNING RESOURCES
### Recommended Study Path
```
Beginner → Intermediate → Advanced → Expert
↓ ↓ ↓ ↓
Basics Analysis Reverse Defense
Engineering Creation
```
**Beginner (Weeks 1-4)**
- Payload structure analysis
- Basic obfuscation
- Simple persistence
- File system operations
**Intermediate (Weeks 5-8)**
- Encryption analysis
- Cross-platform development
- Network communication
- Process injection basics
**Advanced (Weeks 9-12)**
- Anti-analysis techniques
- Advanced obfuscation
- Rootkit concepts
- Kernel-level understanding
**Expert (Weeks 13-16)**
- Detection engineering
- Custom prevention systems
- Malware hunting
- Threat intelligence
### Complementary Tools
| Tool | Purpose | Learning Level | Installation |
|------|---------|---------------|--------------|
| **Wireshark** | Network analysis | Beginner | `apt install wireshark` |
| **Process Hacker** | Process monitoring | Beginner | Download from GitHub |
| **Autoruns** | Persistence detection | Beginner | Windows Sysinternals |
| **YARA** | Pattern matching | Intermediate | `pip install yara-python` |
| **Volatility** | Memory forensics | Advanced | `pip install volatility3` |
| **Ghidra** | Reverse engineering | Advanced | Download from NSA |
| **Cuckoo Sandbox** | Malware analysis | Advanced | Docker deployment |
| **IDA Pro** | Disassembly | Expert | Commercial license |
| **launchd-analyzer** | macOS persistence | Intermediate | Custom script |
| **RegRipper** | Registry forensics | Intermediate | Perl script |
### Recommended Reading
**Books:**
1. "Practical Malware Analysis" - Michael Sikorski & Andrew Honig
2. "The Art of Memory Forensics" - Michael Hale Ligh et al.
3. "Malware Analyst's Cookbook" - Michael Ligh et al.
4. "Rootkits and Bootkits" - Alex Matrosov
5. "Windows Internals" - Mark Russinovich
**Online Resources:**
- MITRE ATT&CK Framework: https://attack.mitre.org
- SANS SEC760: Advanced Exploit Development
- Malware Unicorn Workshops: https://malwareunicorn.org
- Reverse Engineering 101: https://github.com/onethawt/reverseengineering-reading-list
**Certifications:**
- GREM (GIAC Reverse Engineering Malware)
- GCFA (GIAC Certified Forensic Analyst)
- OSCP (Offensive Security Certified Professional)
- OSCE (Offensive Security Certified Expert)
---
## 🤝 CONTRIBUTING
### Important Notice
VULCAN is an **educational project**. All contributions must:
- ✅ Be for educational purposes only
- ✅ Include no actual malicious code
- ✅ Have clear educational documentation
- ✅ Include appropriate warnings
- ✅ Follow ethical guidelines
### Development Guidelines
```bash
# 1. Fork the repository
git clone https://github.com/yourusername/vulcan.git
# 2. Create feature branch
git checkout -b feature/educational-enhancement
# 3. Make changes following:
# - Educational focus
# - Safety considerations
# - Comprehensive documentation
# - Ethical compliance
# 4. Test thoroughly in isolated environment
# 5. Submit pull request with:
# - Clear description
# - Educational value explanation
# - Safety considerations
# - Testing results
```
### Code of Conduct
```
1. EDUCATIONAL PURPOSE ONLY
2. NO ACTUAL MALICIOUS CODE
3. COMPREHENSIVE DOCUMENTATION
4. RESPECT PRIVACY AND LAWS
5. HELP OTHERS LEARN SAFELY
6. REPORT SECURITY CONCERNS
7. MAINTAIN ETHICAL STANDARDS
```
### Feature Request Template
```markdown
## Feature Request
### Educational Value
[Explain how this feature helps learning]
### Safety Considerations
[Describe safety implications and mitigations]
### Implementation Details
[Technical approach]
### Documentation Plan
[How will this be documented for students?]
### Testing Strategy
[How to safely test this feature?]
```
---
## 📄 LICENSE
### MIT License
```
Copyright (c) 2024 VULCAN Educational Framework
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
**IMPORTANT DISCLAIMER:**
This license does NOT grant permission for illegal activities. You are SOLELY responsible for using this software legally and ethically. The developers assume NO liability for misuse.
---
## 📞 SUPPORT & CONTACT
### Official Channels
- **GitHub Issues**: For technical problems (educational context only)
- **Documentation**: https://github.com/yourusername/vulcan/wiki
- **Discussions**: Educational topics only
### What We Support
```
✅ SUPPORT FOR:
- Educational questions
- Setup and installation issues
- Feature requests (educational)
- Bug reports (in educational context)
- Documentation improvements
- Lab environment configuration
```
### What We Don't Support
```
❌ NO SUPPORT FOR:
- Malicious use
- Illegal activities
- Bypassing security controls
- Attack techniques
- Evading detection
- Unauthorized testing
```
### For Academic Institutions
If you're an educational institution interested in using VULCAN for your cybersecurity program:
1. Review the full documentation
2. Complete the [Academic Use Request Form]
3. Provide proof of educational status
4. Agree to safety protocols
5. Submit course integration plan
---
<div align="center">
## 🔥 VULCAN - LEARN RESPONSIBLY 🔥
*"Knowledge is power, responsibility is essential"*
[![LEGAL USE ONLY](https://img.shields.io/badge/LEGAL%20USE-ONLY-success?style=for-the-badge )](#)
[![ETHICAL PRACTICE](https://img.shields.io/badge/ETHICAL-PRACTICE-blue?style=for-the-badge )](#)
[![SUPERVISED LEARNING](https://img.shields.io/badge/SUPERVISED-LEARNING-yellow?style=for-the-badge )](#)
</div>
---
<div align="center">
## ⚠️ FINAL NOTICE ⚠️
**THIS TOOL IS FOR EDUCATIONAL PURPOSES IN CONTROLLED ENVIRONMENTS ONLY**
**UNAUTHORIZED USE IS ILLEGAL, UNETHICAL, AND HARMFUL**
**YOU ARE SOLELY RESPONSIBLE FOR YOUR ACTIONS**
**USE WISELY. LEARN SAFELY. SECURE THE FUTURE.**
---
Version: 7.9-Enhanced | Last Updated: 2026-01-16
© 2026 VULCAN Educational Framework | For Educational Use Only
*This documentation is for the VULCAN Educational Security Framework.*
*Always obtain proper authorization before security testing.*
</div>
