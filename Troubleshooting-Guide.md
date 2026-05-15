# SIEM Troubleshooting Guide
## Complete Resolution of Splunk Data Pipeline Failure

**Author:** Sumesh Kumar  
**Date:** May 14-15, 2026  
**Duration:** 4 hours  
**Environment:** Splunk Enterprise 9.x + Universal Forwarder  

---

## Executive Summary

This document provides a comprehensive troubleshooting methodology for resolving Splunk SIEM data pipeline failures. The process documented here successfully resolved a complete absence of detection query results despite confirmed attack execution on the victim system.

**Problem:** Detection queries returned ZERO results after executing 6 attack techniques  
**Root Causes:** Three distinct configuration issues (inputs, indexes, hostname)  
**Resolution Time:** 4 hours of systematic debugging  
**Final Result:** 119,050+ events successfully indexed and searchable  

---

## Problem #1: Missing Windows Security Event Logs

### Symptom
- Sysmon logs visible in Splunk ✅
- Windows Security logs completely absent ❌
- Detection queries for EventCode 4720, 4732, 4698 return 0 results

### Diagnostic Process

**Step 1: Verify Splunk Forwarder Service**
```powershell
Get-Service SplunkForwarder

# Expected Output:
# Status   Name               DisplayName
# ------   ----               -----------
# Running  SplunkForwarder    SplunkForwarder
```
✅ **Result:** Service running normally

**Step 2: Check Forwarder Connection to SIEM**
```powershell
cd "C:\Program Files\SplunkUniversalForwarder\bin"
.\splunk list forward-server -auth admin:password

# Expected Output:
# Active forwards:
#         192.168.56.1:9997
```
✅ **Result:** Forwarder connected to SIEM on port 9997

**Step 3: Query Splunk for Available Log Sources**
```spl
index=* host="DESKTOP-PT2GLLD" 
| stats count by sourcetype
```

**Actual Output:**
```
sourcetype                                     count
XmlWinEventLog:Microsoft-Windows-Sysmon/...  5,696
```

❌ **Problem Identified:** Only Sysmon appearing; Security log missing

**Step 4: Inspect inputs.conf Configuration**
```powershell
cd "C:\Program Files\SplunkUniversalForwarder\etc\system\local"
cat inputs.conf
```

**Actual Configuration:**
```ini
[WinEventLog://Microsoft-Windows-Sysmon/Operational]
disabled = 0
index = sysmon
```

❌ **Root Cause Found:** inputs.conf missing Security log configuration

### Root Cause Analysis

Splunk Universal Forwarder does NOT include Windows Security log monitoring by default. The configuration file `inputs.conf` must explicitly define each Windows Event Log channel to monitor.

**Why This Happens:**
- Default Splunk UF installation omits Security channel
- Sysmon must be manually installed, so its input is explicitly added
- Security log assumed to be "standard" but not auto-configured
- Many SOC engineers make this same mistake during initial deployment

### Resolution Steps

**Step 1: Add Security Log Input to inputs.conf**
```powershell
cd "C:\Program Files\SplunkUniversalForwarder\etc\system\local"

# Add Security log configuration
Add-Content inputs.conf "`n[WinEventLog://Security]"
Add-Content inputs.conf "disabled = 0"
Add-Content inputs.conf "index = wineeventlog"
Add-Content inputs.conf "renderXml = true"
```

**Updated inputs.conf:**
```ini
[WinEventLog://Microsoft-Windows-Sysmon/Operational]
disabled = 0
index = sysmon

[WinEventLog://Security]
disabled = 0
index = wineeventlog
renderXml = true
```

**Step 2: Restart Splunk Forwarder Service**
```powershell
Restart-Service SplunkForwarder

# Verify service restarted successfully
Get-Service SplunkForwarder | Select Status, StartType
```

**Step 3: Verify Security Logs Now Flowing**
```powershell
# Wait 30 seconds for logs to forward
Start-Sleep -Seconds 30

# Check on SIEM side
```

```spl
index=wineeventlog sourcetype="WinEventLog:Security" host="DESKTOP-PT2GLLD"
| stats count
```

✅ **Success:** 765 Security events now visible

### Verification Queries

```spl
# Check EventCode 4720 (Account Creation)
index=wineeventlog EventCode=4720 host="DESKTOP-PT2GLLD"
| table _time, TargetUserName, SubjectUserName

# Expected: 4 events (Backdoor, AttackTest, TestUser, FreshTest)
```

✅ **All 4 backdoor accounts now detected**

---

## Problem #2: Non-Existent Destination Indexes

### Symptom
- Forwarder sending data (tcpdump confirms network traffic on port 9997) ✅
- Splunk _internal index shows forwarder connection ✅
- Searches for index=wineeventlog return 0 results ❌
- Searches for index=sysmon return 0 results ❌

### Diagnostic Process

**Step 1: Verify Forwarder Sending Data**
```bash
# On SIEM (DELL)
sudo tcpdump -i any port 9997

# Output shows network traffic:
# 192.168.56.104.52394 > 192.168.56.1.9997: data
```
✅ **Result:** Data being transmitted

**Step 2: Check Splunk Internal Logs**
```spl
index=_internal source=*metrics.log host="DESKTOP-PT2GLLD"
| stats count by host

# Result: Shows forwarder connecting
```
✅ **Result:** Forwarder successfully connecting

**Step 3: List All Available Indexes**
```spl
| eventcount summarize=false index=* 
| dedup index 
| table index

# Result:
# index
# -----
# main
# _internal
# _audit
```

❌ **Problem Identified:** Indexes 'wineeventlog' and 'sysmon' do not exist

**Step 4: Check Splunk Behavior with Missing Index**
```spl
index=wineeventlog
| stats count

# Result: 0 events (no error message!)
```

❌ **Critical Finding:** Splunk silently drops data when target index doesn't exist

### Root Cause Analysis

Splunk Universal Forwarder inputs.conf specifies `index = wineeventlog` and `index = sysmon`, but these indexes were never created on the receiving Splunk Enterprise instance.

**Why This Happens:**
- Splunk does NOT auto-create indexes mentioned in forwarder configs
- Data sent to non-existent index is silently discarded
- No error messages in UI (must check _internal logs for warnings)
- Common mistake when deploying distributed Splunk environments

**Evidence of Silent Data Loss:**
```spl
index=_internal source=*splunkd.log "index not found"
| table _time, message

# Shows warnings about missing indexes (easy to miss)
```

### Resolution Steps

**Step 1: Create wineeventlog Index**
1. Splunk Web → Settings → Indexes
2. Click "New Index"
3. Index Name: `wineeventlog`
4. Max Size: 500 MB
5. Frozen Path: (leave default)
6. Data Retention: 90 days
7. Save

**Step 2: Create sysmon Index**
1. Splunk Web → Settings → Indexes
2. Click "New Index"
3. Index Name: `sysmon`
4. Max Size: 1000 MB (Sysmon generates high volume)
5. Data Retention: 90 days
6. Save

**Step 3: Restart Splunk Enterprise**
```bash
sudo /opt/splunk/bin/splunk restart
```

**Step 4: Wait for Data to Flow**
```bash
# Data pipeline has delay
# Forwarder buffers data and retries
# Wait 2-3 minutes for indexes to populate
sleep 180
```

**Step 5: Verify Indexes Now Populated**
```spl
index=sysmon | stats count
# Result: 5,696 events

index=wineeventlog | stats count
# Result: 960 events
```

✅ **Success:** Data pipeline fully operational

### Index Configuration Best Practices

**Recommended Index Sizes:**
- `sysmon`: 1-5 GB (high volume, detailed process tracking)
- `wineeventlog`: 500 MB - 2 GB (security, system, application)
- `main`: 50 GB+ (catch-all for uncategorized data)

**Retention Policies:**
- Security/Audit logs: 365 days minimum (compliance)
- Sysmon: 90 days (forensic investigations)
- Application logs: 30 days (troubleshooting)

---

## Problem #3: Hostname Resolution Mismatch

### Symptom
- Indexes exist and contain data ✅
- Query `host="Windows10-Victi"` returns 0 results ❌
- Data confirmed in indexes via `index=*` ✅

### Diagnostic Process

**Step 1: Search All Data Without Host Filter**
```spl
index=sysmon 
| stats count

# Result: 5,696 events
```
✅ **Data exists in index**

**Step 2: Search with Expected Hostname**
```spl
index=sysmon host="Windows10-Victi"
| stats count

# Result: 0 events
```
❌ **Hostname filter failing**

**Step 3: List All Hostnames in Index**
```spl
index=* 
| stats count by host

# Result:
# host              count
# --------------    -----
# DESKTOP-PT2GLLD   6,656
# MY-WINDOWS-PC     53,653
```

❌ **Problem Identified:** Actual hostname is "DESKTOP-PT2GLLD", not "Windows10-Victi"

### Root Cause Analysis

**VirtualBox Display Name vs. OS Hostname:**
- VirtualBox VM labeled: "Windows10-Victi" (display name in GUI)
- Windows OS hostname: "DESKTOP-PT2GLLD" ($env:COMPUTERNAME)
- Splunk reports OS hostname, NOT VirtualBox label

**How Splunk Determines Hostname:**
```powershell
# Splunk Universal Forwarder uses this value:
$env:COMPUTERNAME

# Output on victim VM:
DESKTOP-PT2GLLD
```

**Why This Matters:**
- Detection queries hardcoded with wrong hostname fail silently
- No error message, just 0 results (appears as "no attack detected")
- Common issue when moving from VM testing to production

### Resolution Steps

**Step 1: Identify Actual Hostname**
```spl
index=* 
| stats count by host
| sort - count
```

**Step 2: Update All Detection Queries**

Before (Incorrect):
```spl
index=wineeventlog EventCode=4720 host="Windows10-Victi"
```

After (Correct):
```spl
index=wineeventlog EventCode=4720 host="DESKTOP-PT2GLLD"
```

**Step 3: Re-run All Detection Queries**
```spl
# Account Creation Detection
index=wineeventlog EventCode=4720 host="DESKTOP-PT2GLLD"
| table _time, TargetUserName, SubjectUserName
```

✅ **Success:** 4 events detected (all backdoor accounts found)

**Step 4: Verify Complete Event Visibility**
```spl
index=* host="DESKTOP-PT2GLLD"
| stats count by sourcetype

# Result:
# sourcetype                                          count
# XmlWinEventLog:Microsoft-Windows-Sysmon/...       45,867
# WinEventLog:Security                              15,226
# WinEventLog:System                                 1,705
# WinEventLog:Application                              282
# WinEventLog:Microsoft-Windows-PowerShell/...         285
```

✅ **Total: 65,397 events from victim machine**

---

## Complete Resolution Summary

### Problems Resolved
1. ✅ Added Security log to inputs.conf
2. ✅ Created missing indexes (wineeventlog, sysmon)
3. ✅ Corrected hostname in all queries (DESKTOP-PT2GLLD)

### Final Data Pipeline Status
- **Total Events Indexed:** 119,050+
- **Victim Machine (DESKTOP-PT2GLLD):** 65,397 events
- **Baseline Endpoint (MY-WINDOWS-PC):** 53,653 events
- **Detection Rate:** 100% (6/6 MITRE ATT&CK techniques detected)

### Troubleshooting Time Breakdown
- **Hour 1:** Problem discovery, initial diagnostics
- **Hour 2:** inputs.conf resolution, service restarts
- **Hour 3:** Index creation, Splunk restart, waiting for data flow
- **Hour 4:** Hostname discovery, query updates, verification
- **Total:** 4 hours

---

## Lessons Learned

### Key Takeaways
1. **Always verify data pipeline end-to-end** before trusting detection queries
2. **Use discovery queries first** (`index=* | stats count by host, sourcetype`)
3. **Document configuration changes** (inputs.conf, indexes.conf)
4. **Test with known-good data** before assuming zero results = no attacks
5. **Hostname matters** - verify actual reporting hostname, not assumptions

### Prevention for Future Deployments

**Pre-Deployment Checklist:**
- [ ] Create all necessary indexes on SIEM before configuring forwarders
- [ ] Verify inputs.conf includes ALL required log channels
- [ ] Test forwarder with `./splunk list forward-server`
- [ ] Run discovery query `index=* | stats count by host` immediately
- [ ] Document actual hostnames in deployment guide
- [ ] Set up automated monitoring for index storage capacity

**Monitoring Queries:**
```spl
# Daily data ingestion health check
index=_internal source=*license_usage.log type=Usage
| timechart span=1d sum(b) as bytes by idx
| eval GB=round(bytes/1024/1024/1024, 2)
```

---

## Troubleshooting Commands Reference

### Forwarder Troubleshooting (Windows)
```powershell
# Check service status
Get-Service SplunkForwarder

# View inputs configuration
cat "C:\Program Files\SplunkUniversalForwarder\etc\system\local\inputs.conf"

# Check forwarding targets
cd "C:\Program Files\SplunkUniversalForwarder\bin"
.\splunk list forward-server -auth admin:password

# View forwarder logs
cd "C:\Program Files\SplunkUniversalForwarder\var\log\splunk"
cat splunkd.log | Select-String "ERROR"

# Restart forwarder
Restart-Service SplunkForwarder
```

### SIEM Troubleshooting (Linux)
```bash
# Check Splunk status
sudo /opt/splunk/bin/splunk status

# List indexes
sudo /opt/splunk/bin/splunk list index

# Check license usage
sudo /opt/splunk/bin/splunk list licenser-messages

# View Splunk logs
sudo tail -f /opt/splunk/var/log/splunk/splunkd.log

# Restart Splunk
sudo /opt/splunk/bin/splunk restart
```

### Discovery Queries
```spl
# List all hosts
index=* | stats count by host

# List all sourcetypes
index=* | stats count by sourcetype

# List all indexes
| eventcount summarize=false index=*

# Check data ingestion rate
index=_internal source=*metrics.log group=per_host_thruput
| timechart span=5m avg(kbps) by host

# Find missing data gaps
index=sysmon | timechart span=1h count
```

---

**Document Version:** 1.0  
**Last Updated:** May 15, 2026  
**Author:** Sumesh Kumar
**Status:** Production-Ready
