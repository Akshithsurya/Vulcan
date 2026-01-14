VULCAN - Advanced Educational Security Framework
Exploit & Test Malware Creator for Educational & Research Purposes Only

<div align="center">
https://img.shields.io/badge/GitHub-Akshithsurya%252FVulcan-blue?logo=github
https://img.shields.io/badge/version-7.8--Cloudflare--HTTPS--Fixed-orange
https://img.shields.io/badge/platform-Linux%2520%257C%2520macOS%2520%257C%2520WSL-brightgreen
https://img.shields.io/badge/python-3.7%252B-blue
https://img.shields.io/badge/bash-script-yellow
https://img.shields.io/badge/license-MIT-green
https://img.shields.io/badge/Educational%2520Use-ONLY-red
https://img.shields.io/badge/Security-Research-purple

OFFICIAL REPOSITORY: github.com/Akshithsurya/Vulcan

</div>
⚠️ CRITICAL WARNING - READ THIS FIRST!
<h3 align="center" style="color: #ff0000;">🔥 VULCAN IS FOR EDUCATIONAL PURPOSES ONLY 🔥</h3> <h4 align="center" style="color: #ff5500;">DO NOT USE FOR MALICIOUS PURPOSES</h4> <h4 align="center" style="color: #ff5500;">UNAUTHORIZED ACCESS TO COMPUTER SYSTEMS IS ILLEGAL</h4><div class="warning" style="background-color: #ffcccc; border-left: 4px solid #ff0000; padding: 10px; margin: 20px 0; border-radius: 5px;">
⚖️ LEGAL DISCLAIMER
I AM NOT RESPONSIBLE FOR ANY MISUSE OF THIS TOOL. By using VULCAN, you agree to:

Use it only in legally authorized environments

Test only on systems you own or have explicit permission to test

Comply with all applicable laws and regulations

Accept FULL responsibility for your actions

Understand that violating computer crime laws can result in severe penalties including imprisonment and fines

AS THE DEVELOPER CLEARLY STATES: "DON'T BLAME ME FOR ANY HARM YOU CAUSE!!"

</div>
🚀 QUICK START
bash
# Clone the official repository
git clone https://github.com/Akshithsurya/Vulcan.git
cd Vulcan

# Make the script executable
chmod +x vulcan.sh

# Run the framework
./vulcan.sh
Note: If you're on macOS or encounter permission issues:

bash
# If chmod +x doesn't work
bash vulcan.sh
# or
sh vulcan.sh
📋 TABLE OF CONTENTS
⚠️ Critical Warning

🚀 Quick Start

📋 Prerequisites

🛠️ Installation

🎯 Features

📖 Usage Guide

🔒 Safety Protocols

⚖️ Legal Guidelines

🏛️ Academic Use

🚨 Emergency Procedures

📚 Learning Resources

🤝 Contributing

📄 License

🌐 Support

📋 PREREQUISITES
System Requirements
Platform	Status	Minimum Requirements
Linux	✅ Fully Supported	Ubuntu/Debian/Kali, 2GB RAM, 5GB storage
macOS	✅ Supported	macOS 10.15+, 2GB RAM, 5GB storage
WSL2	✅ Supported	Windows 10/11 with WSL2 enabled
Software Requirements
bash
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
🛠️ INSTALLATION
Basic Installation (Recommended)
bash
# 1. Clone the repository
git clone https://github.com/Akshithsurya/Vulcan.git

# 2. Navigate to directory
cd Vulcan

# 3. Make executable
chmod +x vulcan.sh

# 4. Run with elevated privileges if needed
sudo ./vulcan.sh
# OR run without sudo
./vulcan.sh
Complete Installation Script
bash
#!/bin/bash
# Complete VULCAN installation script

echo "Installing VULCAN Educational Framework..."
echo "========================================="

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
git clone https://github.com/Akshithsurya/Vulcan.git
cd Vulcan

# Make script executable
chmod +x vulcan.sh

# Display success message
echo ""
echo "✅ VULCAN installation complete!"
echo "📁 Location: $(pwd)"
echo "🚀 Run: ./vulcan.sh"
echo ""
echo "⚠️  REMEMBER: Educational use only!"
Installation on Different Systems
Ubuntu/Debian/Kali Linux
bash
# Complete setup
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git upx
git clone https://github.com/Akshithsurya/Vulcan.git
cd Vulcan
chmod +x vulcan.sh
./vulcan.sh
macOS
bash
# Install Homebrew first (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install python3 git upx

# Clone and run
git clone https://github.com/Akshithsurya/Vulcan.git
cd Vulcan
chmod +x vulcan.sh
./vulcan.sh
Windows (WSL2)
bash
# Enable WSL2 first, then:
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git
git clone https://github.com/Akshithsurya/Vulcan.git
cd Vulcan
chmod +x vulcan.sh
./vulcan.sh
🎯 FEATURES
Core Capabilities
text
╔════════════════════════════════════════════════════════════╗
║                     VULCAN v7.8 FEATURES                    ║
╠════════════════════════════════════════════════════════════╣
║ ✅ Multi-Platform Payload Generation                       ║
║ ✅ Advanced Code Obfuscation (5 Levels)                    ║
║ ✅ Cloudflare HTTPS Tunnel Integration                     ║
║ ✅ Anti-Analysis Techniques (VM/Debugger Detection)        ║
║ ✅ Multiple Encryption Algorithms                          ║
║ ✅ Various Persistence Methods                             ║
║ ✅ Comprehensive Logging System                            ║
║ ✅ Interactive Configuration Wizard                        ║
╚════════════════════════════════════════════════════════════╝
Educational Payload Types
Type	Code	Educational Focus	Risk Level
Bricker	1	System destruction concepts	🔴 HIGH
Backdoor	2	Remote access mechanisms	🔴 HIGH
Ransomware	3	Encryption/decryption methods	🔴 HIGH
Worm	4	Network propagation	🟠 MEDIUM
Info Stealer	5	Data exfiltration	🟠 MEDIUM
Network Destroyer	6	DDoS/Network stress testing	🔴 HIGH
Keylogger	7	Input capture methods	🟡 LOW
Rootkit	8	System stealth techniques	🔴 HIGH
Custom Template	9	Framework for learning	🟢 NONE
Advanced Configuration Options
python
# Available in VULCAN Configuration
ENCRYPTION_ALGORITHMS = {
    "1": "AES-256-GCM",
    "2": "ChaCha20-Poly1305", 
    "3": "Blowfish-CBC",
    "4": "Serpent-256-CBC",
    "5": "Twofish-CBC"
}

OBFUSCATION_LEVELS = {
    "1": "basic",
    "2": "intermediate", 
    "3": "advanced",
    "4": "professional",
    "5": "military_grade"
}

PERSISTENCE_METHODS = {
    "1": "registry",
    "2": "cron",
    "3": "launchd", 
    "4": "systemd",
    "5": "startup_folder",
    "6": "wmi_subscription"
}
📖 USAGE GUIDE
First-Time Setup
bash
# After installation, run:
./vulcan.sh

# You'll see the main interface:
╔════════════════════════════════════════════════════════════╗
║  __      __  _    _  _        _____            _   _       ║
║  \ \    / / | |  | || |      / ____|    /\    | \ | |      ║
║   \ \  / /  | |  | || |     | |        /  \   |  \| |      ║
║    \ \/ /   | |  | || |     | |       / /\ \  | . \` |      ║
║     \  /    | |__| || |____ | |____  / ____ \ | |\  |      ║
║      \/      \____/ |______| \_____|/_/    \_\|_| \_|      ║
║                                                              ║
║    [ VULCAN // Advanced Educational Framework v7.8 ]         ║
╚════════════════════════════════════════════════════════════╝
Interactive Configuration Flow
Basic Configuration

bash
Enter attacker IP [default: 127.0.0.1]: 
Enter attacker port [default: 4444]:
Target Selection

bash
SELECT TARGET OPERATING SYSTEM:
1) Windows
2) Linux  
3) macOS
4) Cross-platform
Payload Selection

bash
SELECT PAYLOAD TYPE:
1) Bricker (System Destroyer)
2) Backdoor (Remote Access)
3) Ransomware (File Encryptor)
... etc
Advanced Options (Optional)

bash
Configure advanced options? [y/N]:
Delivery Method

bash
SELECT DELIVERY METHOD:
1) Email Delivery
2) USB Drive Preparation
... 
7) Cloudflare Tunnel (Secure Remote Access)
8) Skip Delivery (Generate Only)
Example Educational Scenario
bash
# SAFE EDUCATIONAL CONFIGURATION
Attacker IP: 127.0.0.1  # LOCALHOST ONLY!
Attacker Port: 4444
Target OS: Linux
Payload: Backdoor (Educational Template)
Delivery: Local file only
Obfuscation: Level 1 (Basic)
Persistence: Disabled
Using Cloudflare Tunnels (New Feature)
bash
# To create secure testing tunnels:
1. Select delivery method 7 (Cloudflare Tunnel)
2. Enter local port (default: 8080)
3. VULCAN will:
   - Download cloudflared binary
   - Start HTTP server
   - Create secure HTTPS tunnel
   - Provide you with a unique URL
4. Use the URL for secure testing
🔒 SAFETY PROTOCOLS
MANDATORY SAFETY MEASURES
<div class="safety" style="background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 5px;">
1. ISOLATED TESTING ENVIRONMENT
bash
# ALWAYS TEST IN:
✅ Virtual Machines (VirtualBox, VMware)
✅ Docker Containers (Isolated)
✅ Dedicated Test Hardware
✅ Cloud VPS (Completely isolated)
❌ NEVER ON: Personal computers, Work machines, Production servers
2. NETWORK ISOLATION
bash
# SAFE NETWORK CONFIGURATION:
✅ Use 127.0.0.1 (localhost) only
✅ Disconnect from internet during testing
✅ Use virtual network interfaces
✅ Configure firewall to block external access
❌ NEVER: Test on public networks, Work networks, Others' networks
3. LEGAL AUTHORIZATION
bash
# REQUIRED PERMISSIONS:
✅ Written permission from system owner
✅ Signed testing agreement
✅ Scope of work document
✅ Legal review (for organizations)
❌ NEVER: Assume permission, Test without written consent
</div>
Built-in Safety Features
Safety Feature	Status	Description
IP Validation	✅ Enabled	Checks for private/public IPs, warns about dangerous configurations
Port Validation	✅ Enabled	Warns about reserved/well-known ports
Educational Warnings	✅ Enabled	Multiple warning prompts before dangerous operations
Environment Detection	✅ Enabled	Can detect VM/sandbox environments
Comprehensive Logging	✅ Enabled	All actions logged to file for audit trail
No Harmful Code	✅ Enabled	Educational templates only, no actual malware
⚖️ LEGAL GUIDELINES
ACCEPTABLE USE CASES
text
✅ University cybersecurity courses (with supervision)
✅ Security researcher training (isolated labs)
✅ Corporate security awareness (authorized only)
✅ CTF competitions (isolated environments)
✅ Personal education (OWN systems only)
✅ Authorized penetration testing (written contract)
PROHIBITED USE CASES
text
❌ Unauthorized system access
❌ Data theft or destruction  
❌ Ransom demands
❌ Attacking others' systems
❌ Testing without permission
❌ Corporate espionage
❌ Government system testing (without authorization)
❌ Critical infrastructure testing
LEGAL CONSEQUENCES
text
⚖️ Computer Fraud and Abuse Act (CFAA) - Up to 20 years prison
⚖️ State Computer Crime Laws - Varies by state
⚖️ Civil Liability - Financial damages + legal fees
⚖️ Criminal Record - Permanent mark
⚖️ Employment Termination - Immediate job loss
⚖️ Professional License Revocation - For licensed professionals
🏛️ ACADEMIC USE
For Educational Institutions
bash
# Recommended Lab Setup:
1. Create isolated VM template for each student
2. Use network segmentation (separate VLAN)
3. Implement strict firewall rules
4. Enable comprehensive logging
5. Require signed acceptable use policy
6. Supervise all testing activities
Course Integration Example
Week	Topic	VULCAN Module	Lab Activity
1	Malware Fundamentals	Payload Types 1-3	Analyze basic payload structure
2	Obfuscation Techniques	Obfuscation Levels 1-5	Compare obfuscation methods
3	Persistence Mechanisms	Persistence Methods	Study registry/cron persistence
4	Detection & Analysis	Anti-analysis features	Practice detection techniques
5	Defense Strategies	All features	Create detection rules
Student Guidelines
bash
# Before using VULCAN, students must:
1. Complete ethics training
2. Sign acceptable use policy  
3. Setup isolated testing environment
4. Document all activities
5. Report any issues immediately
6. Never share payloads outside class
🚨 EMERGENCY PROCEDURES
<div class="emergency" style="background-color: #f8d7da; border: 2px solid #dc3545; padding: 15px; margin: 20px 0; border-radius: 5px;">
IF SOMETHING GOES WRONG:
bash
# IMMEDIATE ACTION REQUIRED:

# 1. DISCONNECT FROM NETWORK
sudo ifconfig eth0 down          # Linux
sudo ip link set eth0 down       # Alternative
# OR physically unplug network cable

# 2. ISOLATE THE SYSTEM
sudo systemctl stop networking   # Stop all networking
sudo iptables -F                 # Flush firewall rules
sudo iptables -P INPUT DROP      # Block all incoming
sudo iptables -P OUTPUT DROP     # Block all outgoing

# 3. DOCUMENT EVERYTHING
# Take screenshots
# Save log files
# Note timestamps
# Record actions taken

# 4. REPORT IMMEDIATELY
# Instructor: [CONTACT INFO]
# Lab Admin: [CONTACT INFO]  
# IT Security: [CONTACT INFO]
EMERGENCY CONTACTS:

Instructor: Your course instructor

Lab Administrator: Your lab supervisor

IT Security: Campus/Corporate security team

Legal Department: For legal concerns

</div>
Incident Response Checklist
bash
[ ] 1. Contain the incident (disconnect network)
[ ] 2. Document everything (screenshots, logs)
[ ] 3. Preserve evidence (don't delete anything)
[ ] 4. Report to authorities (instructor/security)
[ ] 5. Analyze what happened (root cause)
[ ] 6. Implement fixes (prevent recurrence)
[ ] 7. Update procedures (learn from incident)
📚 LEARNING RESOURCES
Recommended Study Path
graph LR
    A[Beginner: Basics] --> B[Intermediate: Analysis]
    B --> C[Advanced: Reverse Engineering]
    C --> D[Expert: Defense Creation]
    
    A --> A1[Payload Structure]
    A --> A2[Basic Obfuscation]
    
    B --> B1[Encryption Analysis]
    B --> B2[Persistence Study]
    
    C --> C1[Anti-Analysis Techniques]
    C --> C2[Process Injection]
    
    D --> D1[Detection Engineering]
    D --> D2[Prevention Systems]
Complementary Tools for Learning
Tool	Purpose	Learning Level
Wireshark	Network traffic analysis	Beginner
Ghidra	Reverse engineering	Intermediate
Volatility	Memory forensics	Advanced
YARA	Pattern matching	Intermediate
Cuckoo Sandbox	Malware analysis	Advanced
IDA Pro	Disassembly	Expert
Recommended Reading
"Practical Malware Analysis" - Michael Sikorski & Andrew Honig

"The Art of Memory Forensics" - Michael Hale Ligh et al.

"Mastering Reverse Engineering" - Reginald Wong

SANS Institute SEC760 - Advanced Exploit Development

MITRE ATT&CK Framework - Enterprise knowledge base

OWASP Testing Guide - Web application security

🤝 CONTRIBUTING
Important Notice
This is an educational project. Contributions must:

Be for educational purposes only

Include no actual malicious code

Have clear educational documentation

Include appropriate warnings

Follow ethical guidelines strictly

Development Guidelines
bash
# Fork the repository
git clone https://github.com/Akshithsurya/Vulcan.git

# Create feature branch  
git checkout -b feature/educational-feature

# Make changes following:
# 1. Educational focus
# 2. Safety considerations
# 3. Comprehensive documentation
# 4. Ethical compliance

# Submit pull request with detailed explanation
Code of Conduct
text
1. EDUCATIONAL PURPOSE ONLY
2. NO MALICIOUS CODE
3. RESPECT PRIVACY
4. FOLLOW LAWS
5. HELP OTHERS LEARN
6. REPORT CONCERNS
📄 LICENSE
<div class="license" style="background-color: #e7f3ff; border-left: 4px solid #0d6efd; padding: 15px; margin: 20px 0; border-radius: 5px;">
MIT License
text
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
IMPORTANT: This license does NOT grant permission for illegal activities.
You are SOLELY responsible for using this software legally and ethically.

AS THE DEVELOPER STATES: "DON'T BLAME ME FOR ANY HARM YOU CAUSE!!"

</div>
🌐 SUPPORT
Official Channels
GitHub Repository: github.com/Akshithsurya/Vulcan

Issues: For technical problems (educational context only)

Discussions: Educational topics only

Important Notes
text
⚠️  NO SUPPORT FOR:
- Malicious use
- Illegal activities  
- Bypassing security
- Attack techniques
- Evading detection

✅ SUPPORT FOR:
- Educational questions
- Setup issues
- Feature requests (educational)
- Bug reports (in educational context)
Contact Information
For educational inquiries only:

GitHub Issues: Use the repository issue tracker

Email: Educational institutions only

Forum: Cybersecurity education communities

<div align="center" style="margin: 40px 0; padding: 25px; background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%); color: white; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);"><h2 style="color: white; margin-bottom: 15px;">🔥 VULCAN - EDUCATIONAL USE ONLY 🔥</h2> <p style="font-size: 18px; color: #f0f0f0; margin-bottom: 20px;"><em>"Knowledge is power, but responsibility is key"</em></p><div style="display: flex; justify-content: center; gap: 15px; flex-wrap: wrap; margin-top: 20px;"> <span style="display: inline-block; background: #198754; color: white; padding: 10px 20px; border-radius: 25px; font-weight: bold;">LEGAL USE ONLY</span> <span style="display: inline-block; background: #0d6efd; color: white; padding: 10px 20px; border-radius: 25px; font-weight: bold;">ETHICAL PRACTICE</span> <span style="display: inline-block; background: #ffc107; color: black; padding: 10px 20px; border-radius: 25px; font-weight: bold;">LEARN RESPONSIBLY</span> </div></div>
<div align="center" style="margin: 30px 0; padding: 20px; background-color: #dc3545; color: white; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.2);"><h2 style="color: white; margin-bottom: 15px;">⚠️ FINAL WARNING ⚠️</h2> <p style="font-weight: bold; font-size: 18px; margin-bottom: 10px;">THIS TOOL IS FOR EDUCATIONAL PURPOSES IN CONTROLLED ENVIRONMENTS ONLY</p> <p style="font-weight: bold; margin-bottom: 10px;">UNAUTHORIZED USE IS ILLEGAL AND UNETHICAL</p> <p style="font-weight: bold; margin-bottom: 15px;">YOU ARE SOLELY RESPONSIBLE FOR YOUR ACTIONS</p> <p style="font-style: italic;">As the developer says: "DON'T BLAME ME FOR ANY HARM YOU CAUSE!!"</p></div>
<div align="center" style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 14px; color: #666;"> <p><strong>OFFICIAL REPOSITORY:</strong> <a href="https://github.com/Akshithsurya/Vulcan">github.com/Akshithsurya/Vulcan</a></p> <p>Last Updated: $(date +%Y-%m-%d) | Version: 7.8-Cloudflare-HTTPS-Fixed</p> <p>© 2024 VULCAN Educational Framework | Created by Akshithsurya</p> <p><em>This documentation is for the official VULCAN project. Use responsibly.</em></p> </div><style> /* Additional styling for better readability */ h1, h2, h3, h4 { margin-top: 24px; margin-bottom: 16px; font-weight: 600; } h1 { color: #ff6b35; border-bottom: 3px solid #ff6b35; padding-bottom: 10px; text-align: center; } h2 { color: #ff8e53; border-bottom: 2px solid #ff8e53; padding-bottom: 8px; } h3 { color: #ffa726; } code { background-color: #f5f5f5; border-radius: 4px; padding: 2px 6px; font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace; font-size: 0.9em; } pre { background-color: #2d2d2d; color: #f8f8f2; border-radius: 8px; padding: 16px; overflow-x: auto; margin: 20px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); } table { border-collapse: collapse; width: 100%; margin: 20px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); } th { background-color: #ff6b35; color: white; font-weight: bold; text-align: left; } th, td { border: 1px solid #ddd; padding: 12px 15px; text-align: left; } tr:nth-child(even) { background-color: #f9f9f9; } tr:hover { background-color: #f5f5f5; } a { color: #ff6b35; text-decoration: none; } a:hover { text-decoration: underline; color: #ff8e53; } .warning, .safety, .emergency, .license { transition: all 0.3s ease; } .warning:hover, .safety:hover, .emergency:hover, .license:hover { transform: translateY(-2px); box-shadow: 0 4px 8px rgba(0,0,0,0.15); } </style><script> // Simple script for better user experience document.addEventListener('DOMContentLoaded', function() { // Smooth scrolling for anchor links document.querySelectorAll('a[href^="#"]').forEach(anchor => { anchor.addEventListener('click', function (e) { e.preventDefault(); const targetId = this.getAttribute('href'); if(targetId === '#') return; const targetElement = document.querySelector(targetId); if(targetElement) { window.scrollTo({ top: targetElement.offsetTop - 80, behavior: 'smooth' }); } }); }); // Add copy buttons to code blocks document.querySelectorAll('pre').forEach(pre => { const button = document.createElement('button'); button.innerHTML = '📋 Copy'; button.style.cssText = ` position: absolute; right: 10px; top: 10px; background: #ff6b35; color: white; border: none; padding: 5px 10px; border-radius: 4px; cursor: pointer; font-size: 12px; opacity: 0.8; transition: opacity 0.3s; `; button.addEventListener('mouseenter', () => button.style.opacity = '1'); button.addEventListener('mouseleave', () => button.style.opacity = '0.8'); button.addEventListener('click', () => { const code = pre.querySelector('code') ? pre.querySelector('code').innerText : pre.innerText; navigator.clipboard.writeText(code).then(() => { button.innerHTML = '✅ Copied!'; setTimeout(() => button.innerHTML = '📋 Copy', 2000); }); }); pre.style.position = 'relative'; pre.appendChild(button); }); }); </script>
This response is AI-generated, for reference only.
