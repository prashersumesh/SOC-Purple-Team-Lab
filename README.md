# 🛡️ Enterprise SOC Purple Team Detection Lab
## Multi-Endpoint SIEM Architecture with Attack Simulation & Detection Engineering

[![Lab Type](https://img.shields.io/badge/Lab-Purple%20Team-blueviolet)](https://github.com/prashersumesh/SOC-Purple-Team-Lab)
[![SIEM](https://img.shields.io/badge/SIEM-Splunk%20Enterprise-green)](https://www.splunk.com)
[![Attack Framework](https://img.shields.io/badge/Framework-MITRE%20ATT%26CK-red)](https://attack.mitre.org)
[![Endpoints](https://img.shields.io/badge/Endpoints-3%20Hosts-blue)](https://github.com/prashersumesh/SOC-Purple-Team-Lab)
[![Detection Coverage](https://img.shields.io/badge/Detection-6%20Techniques-success)](https://github.com/prashersumesh/SOC-Purple-Team-Lab)
[![Events Collected](https://img.shields.io/badge/Events-119%2C050%2B-orange)](https://github.com/prashersumesh/SOC-Purple-Team-Lab)

**Security Operations Analyst:** Sumesh Kumar  
**Completion Date:** May 14-15, 2026  
**Lab Duration:** 48+ hours  
**Academic Program:** Master of Cybersecurity & Threat Intelligence, University of Guelph  
**Expected Graduation:** January 2027  
**GitHub:** [@prashersumesh](https://github.com/prashersumesh)

---

## 🎯 Executive Summary

This project demonstrates a **complete enterprise-grade Purple Team engagement** where I designed, deployed, and operated a production-ready Security Operations Center (SOC) environment. Acting as both Red Team (attacker) and Blue Team (defender), I executed 6 MITRE ATT&CK techniques, troubleshot a broken SIEM pipeline, and built detection rules capable of identifying sophisticated attacks across multiple endpoints.

### What Makes This Lab Industry-Ready:

✅ **Real troubleshooting documented** - Complete resolution of enterprise SIEM data pipeline issues  
✅ **119,050+ security events** collected from 3 diverse endpoints  
✅ **Multi-endpoint correlation** - DELL workstation + Surface Laptop + Windows VM  
✅ **Complete attack chain** - From reconnaissance to defense evasion  
✅ **Production-ready SPL queries** - Detection rules deployable to enterprise SOC  
✅ **Full documentation** - Every command, screenshot, and troubleshooting step preserved  
✅ **Baseline comparison** - Normal vs. attack traffic analysis

**Industry Assessment:** This lab demonstrates **mid-level SOC Analyst** and **Detection Engineer** capabilities, exceeding entry-level requirements.

---

## 🏗️ Lab Architecture

### Network Topology

```
┌──────────────────────────────────────────────────────────────────────┐
│          Enterprise Security Operations Center (SOC)                 │
│             VirtualBox Host-Only Network: 192.168.56.0/24            │
└──────────────────────────────────────────────────────────────────────┘
         │                       │                         │
         │                       │                         │
  ┌──────▼────────┐      ┌───────▼──────────┐     ┌───────▼──────────┐
  │  Kali Linux   │      │   Windows 10 VM  │     │  Surface Laptop  │
  │  (Attacker)   │──────│    (Victim)      │     │   (Endpoint)     │
  │               │Attack│                  │     │                  │
  │ 192.168.56    │      │  192.168.56.104  │     │  WiFi:           │
  │    .102       │      │                  │     │  172.20.10.11    │
  │               │      │  Hostname:       │     │                  │
  │ Tools:        │      │  DESKTOP-PT2GLLD │     │  Hostname:       │
  │ • Nmap        │      │                  │     │  MY-WINDOWS-PC   │
  │ • Hydra       │      │  • Sysmon        │     │                  │
  │ • NetExec     │      │  • Splunk UF     │     │  • Splunk UF     │
  │ (NXC)         │      │  • Event Logs    │     │  • Event Logs    │
  └───────────────┘      └──────────┬───────┘     └──────────┬───────┘
                                    │                        │
                                    │ Logs                   │ Logs
                                    │ Forward                │ Forward
                                    │                        │
                         ┌──────────▼────────────────────────▼─────────┐
                         │         DELL Precision 7760                 │
                         │         (SIEM / SOC Analyst Workstation)    │
                         │                                             │
                         │  IP: 192.168.56.1 (Host-Only)               │
                         │  WiFi: 172.20.10.X                          │
                         │                                             │
                         │  ┌────────────────────────────────────┐    │
                         │  │   Splunk Enterprise 9.x            │    │
                         │  │   Receiving Port: 9997             │    │
                         │  │                                    │    │
                         │  │   Total Events: 119,050+           │    │
                         │  │   ├─ DESKTOP-PT2GLLD: 65,397       │    │
                         │  │   └─ MY-WINDOWS-PC:   53,653       │    │
                         │  │                                    │    │
                         │  │   Indexes:                         │    │
                         │  │   ├─ sysmon                        │    │
                         │  │   ├─ wineeventlog                  │    │
                         │  │   └─ main                          │    │
                         │  └────────────────────────────────────┘    │
                         │                                             │
                         │  Detection Queries: 10+ SPL rules          │
                         │  Attack Timeline: Fully documented         │
                         └─────────────────────────────────────────────┘
```

### Infrastructure Components

| Component | Role | IP Address | Hostname | Log Sources | Event Count |
|-----------|------|------------|----------|-------------|-------------|
| **DELL Precision 7760** | SIEM / SOC Workstation | 192.168.56.1 (Host-Only)<br>172.20.10.X (WiFi) | N/A | Splunk Enterprise | **119,050+** total |
| **Windows 10 VM** | Target / Victim | 192.168.56.104 | DESKTOP-PT2GLLD | Sysmon, Security, System, Application | **65,397** |
| **Surface Laptop** | Baseline Endpoint | WiFi: 172.20.10.11 | MY-WINDOWS-PC | Security, System, Application, PowerShell | **53,653** |
| **Kali Linux VM** | Attacker | 192.168.56.102 | kali | N/A (attack source) | 0 |

---

## 🎭 Attack Execution Summary

### MITRE ATT&CK Coverage

| # | Technique | MITRE ID | Tool | Timestamp | Status |
|---|-----------|----------|------|-----------|--------|
| 1 | Network Service Discovery | T1046 | Nmap | 2026-05-14 15:40 | ✅ Detected |
| 2 | Brute Force: Password Spraying | T1110.003 | NetExec | 2026-05-14 16:47 | ✅ Detected |
| 3 | Scheduled Task/Job | T1053.005 | schtasks | 2026-05-15 00:19 | ✅ Detected |
| 4 | Create Account | T1136.001 | net.exe | 2026-05-15 00:19 | ✅ Detected |
| 5 | Account Manipulation | T1098 | net.exe | 2026-05-15 00:19 | ✅ Detected |
| 6 | Clear Logs | T1070.001 | wevtutil | 2026-05-14 | ✅ Detected |

**Total Events Collected:** 119,050+  
**Detection Rate:** 100% (6/6 techniques detected)  
**Mean Time to Detect:** <3 minutes

---

## 📊 Key Findings

### Data Pipeline Statistics

```
Total Endpoints Monitored: 3
Total Events Indexed: 119,050+
Event Coverage: 12+ days
Log Sources: Sysmon, Security, System, Application, PowerShell
SIEM Platform: Splunk Enterprise 9.x
Detection Queries Deployed: 10+
```

### Attack vs. Baseline Comparison

| Metric | DESKTOP-PT2GLLD (Victim) | MY-WINDOWS-PC (Baseline) |
|--------|--------------------------|--------------------------|
| Unique Ports Contacted | 52 (ATTACK) | 7 (NORMAL) |
| Failed Login Attempts | 4 (brute force) | 0 |
| New Accounts Created | 4 (backdoors) | 0 |
| Scheduled Tasks Created | 2 (persistence) | 0 |
| Admin Group Changes | 1 (privilege escalation) | 0 |

---

## 🔍 Detection Highlights

### Query #1: Account Creation Detection
```spl
index=wineeventlog EventCode=4720 host="DESKTOP-PT2GLLD"
| table _time, TargetUserName, SubjectUserName
```
**Result:** ✅ Detected 4 backdoor accounts (Backdoor, AttackTest, TestUser, FreshTest)

### Query #5: Port Scan Detection
```spl
index=sysmon EventCode=3 host="DESKTOP-PT2GLLD" SourceIp="192.168.56.102"
| stats dc(DestinationPort) as UniquePortsScanned
```
**Result:** ✅ Detected 52 unique ports scanned (threshold: >10 = attack)

---

## 📚 Skills Demonstrated

**SIEM Administration:** Splunk Enterprise deployment, index management, forwarder configuration  
**Log Analysis:** Windows Event Logs, Sysmon, multi-source correlation  
**Detection Engineering:** SPL query development, MITRE ATT&CK mapping, baseline analysis  
**Offensive Security:** Nmap reconnaissance, password attacks, post-exploitation  
**Troubleshooting:** 4-hour SIEM pipeline debugging, hostname resolution, service configuration  
**Documentation:** Complete technical writing, screenshot organization, GitHub portfolio

---

## 📁 Repository Contents

```
SOC-Purple-Team-Lab/
├── README.md (you are here)
├── screenshots/ (organized by phase)
├── scripts/spl-queries/ (10 detection rules)
├── scripts/powershell-commands/
├── scripts/kali-commands/
├── docs/ (technical deep-dives)
└── reports/ (PDF exports)
```

---

## 🚀 Getting Started

See individual documentation files in `/docs` for:
- **Attack Methodology** - Complete Red Team playbook
- **Detection Strategy** - Blue Team detection engineering
- **Troubleshooting Guide** - SIEM pipeline debugging steps
- **MITRE ATT&CK Mapping** - Technique coverage matrix

---

## 🤝 Connect

**GitHub:** [@prashersumesh](https://github.com/prashersumesh)  
**Location:** Toronto, Ontario, Canada  
**Looking for:** SOC Analyst, Digital Forensics, Network Security roles

**⭐ Star this repo if you found it helpful!**

---

*Last Updated: May 26, 2026 | Status: Complete & Production-Ready*
