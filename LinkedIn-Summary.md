# LinkedIn Post - Purple Team SOC Lab

## Option 1: Professional Narrative Style

🛡️ **Just completed a 48-hour Purple Team SOC lab that taught me more about detection engineering than 6 months of theory.**

Here's what happened:

I built an enterprise-grade SIEM environment from scratch—Splunk Enterprise monitoring 3 endpoints, collecting 119,050+ security events.

Then I attacked it.

**The Red Team Phase:**
- Executed 6 MITRE ATT&CK techniques (T1046, T1110.003, T1053.005, T1136.001, T1098, T1070.001)
- Used Nmap for reconnaissance, NetExec for brute force attacks
- Created backdoor accounts, established persistence, attempted log clearing

**The Problem:**
After executing all attacks, my detection queries returned ZERO results. 😳

This began a 4-hour troubleshooting journey that turned out to be the most valuable part of the entire lab.

**What I found:**
1. Splunk Forwarder wasn't collecting Security logs (inputs.conf misconfiguration)
2. Destination indexes didn't exist on the SIEM (wineeventlog and sysmon missing)
3. Hostname mismatch (Splunk used OS hostname "DESKTOP-PT2GLLD," not the VM name)

**The Blue Team Phase:**
Once the pipeline was fixed, the attacks lit up like a Christmas tree:
- ✅ 52 unique ports scanned (normal = 7 ports)
- ✅ 4 backdoor accounts detected via EventCode 4720
- ✅ Scheduled task persistence caught via EventCode 4698
- ✅ Privilege escalation to Administrators group logged
- ✅ Log clearing attempt (EventCode 1102) flagged as CRITICAL

**The Real Learning:**
Perfect execution teaches you procedures.  
Troubleshooting broken systems teaches you how things actually work.

Every SOC analyst will face missing logs, misconfigured forwarders, and "why isn't this showing up?" moments. This lab taught me how to systematically debug them.

**Lab Stats:**
🔹 3 endpoints monitored
🔹 119,050+ events indexed
🔹 10 SPL detection queries deployed
🔹 100% detection rate (6/6 techniques caught)
🔹 Mean time to detect: <3 minutes

Full technical documentation, screenshots, and SPL queries available on GitHub.

Who else has had that "my SIEM isn't working" panic moment? What did you learn from it?

#Cybersecurity #SOC #ThreatDetection #SIEM #Splunk #DetectionEngineering #InfoSec #CySA #PurpleTeam

---

## Option 2: Metrics-Focused Style

🎯 **119,050 security events. 6 attack techniques. 1 broken SIEM pipeline. Here's what I learned.**

I just wrapped up a 48-hour Purple Team lab that simulated a complete enterprise SOC environment.

**By the numbers:**
📊 3 endpoints monitored (Windows VM, Surface Laptop, DELL workstation)
📊 119,050+ events collected
📊 6 MITRE ATT&CK techniques executed
📊 10 SPL detection queries deployed
📊 100% detection rate
📊 <3 minute mean time to detect

**The setup:**
- Splunk Enterprise SIEM
- Kali Linux (attacker)
- Windows 10 VM with Sysmon (victim)
- Surface Laptop (baseline comparison)

**The attacks:**
✅ T1046 - Network Service Discovery (Nmap)
✅ T1110.003 - Password Brute Force (NetExec)
✅ T1053.005 - Scheduled Task Persistence
✅ T1136.001 - Backdoor Account Creation
✅ T1098 - Privilege Escalation
✅ T1070.001 - Log Clearing (Defense Evasion)

**The twist:**
My first detection query returned 0 results despite successful attacks.

This led to discovering:
1. Misconfigured Splunk Forwarder (missing Security log input)
2. Non-existent indexes on receiving SIEM
3. Hostname mismatch between VM name and OS hostname

**The value:**
This troubleshooting taught me more than the attacks themselves. Real SOC work isn't about perfect setups—it's about debugging broken pipelines at 2 AM.

Key learning: Always verify your data pipeline end-to-end with `index=* | stats count by host` before trusting it.

**Detection highlight:**
Baseline traffic: 7 unique ports
Under attack: 52 unique ports

The difference between normal and malicious becomes obvious when you have both to compare.

Full lab documentation on GitHub (link in comments).

#SOC #Cybersecurity #Splunk #SIEM #ThreatHunting #DetectionEngineering #InfoSec #BlueTeam #RedTeam

---

## Option 3: Story-Driven Style

💡 **"Your detection queries look perfect. Why aren't they finding anything?"**

That was me at hour 6 of my Purple Team SOC lab, staring at a Splunk dashboard showing exactly zero detections.

I'd just executed 6 sophisticated attacks:
- Port scanned 1,000 ports
- Brute-forced credentials
- Created backdoor admin accounts
- Established scheduled task persistence
- Attempted to wipe security logs

Every attack succeeded. But according to my SIEM? Nothing happened.

**The investigation:**

Step 1: Check if Splunk Forwarder is running
✅ Status: Running

Step 2: Verify it's connected to the SIEM
✅ Connected to 192.168.56.1:9997

Step 3: Check if ANY logs are coming through
✅ Sysmon logs flowing (5,696 events)
❌ Security logs missing

**First breakthrough:** inputs.conf was missing `[WinEventLog://Security]`

Added it. Restarted forwarder. Still nothing.

**Second breakthrough:** The destination indexes (wineeventlog, sysmon) didn't exist on the SIEM. Splunk was dropping the data silently.

Created the indexes. Restarted Splunk. Still nothing.

**Final breakthrough:** `index=* | stats count by host` showed the logs were there, just under hostname "DESKTOP-PT2GLLD" instead of the VM name "Windows10-Victi"

Updated the query. Suddenly: **6,656 events.**

Every attack lit up:
🔴 Port scan: 52 unique ports contacted
🔴 Brute force: 4 failed login attempts, then success
🔴 Backdoor account: EventCode 4720 at 00:19:12
🔴 Privilege escalation: User added to Administrators
🔴 Log clearing: EventCode 1102 (CRITICAL alert)

**The lesson:**
Perfect theory won't prepare you for "the forwarder is running but no data is showing up."

Real SOC skills come from the 4 hours spent troubleshooting, not the 30 seconds running a working query.

Now I have a production-ready lab with 119,050+ events, multi-endpoint correlation, and detection queries that actually work.

More importantly, I know how to fix them when they don't.

Full technical breakdown on GitHub.

#Cybersecurity #SOC #RealWorldLearning #Splunk #DetectionEngineering #ThreatHunting #InfoSec

---

## Option 4: Achievement-Focused Style

🚀 **From zero to enterprise SOC in 48 hours.**

Just completed a hands-on Purple Team lab that I'm genuinely proud of.

**What I built:**
🔹 Production Splunk Enterprise SIEM
🔹 3-endpoint architecture (attack + victim + baseline)
🔹 Complete MITRE ATT&CK attack chain
🔹 10 detection queries with 100% catch rate
🔹 119,050+ events collected and analyzed

**Attack surface covered:**
→ Reconnaissance (Nmap port scanning)
→ Initial access (credential brute force)
→ Persistence (scheduled tasks + backdoor accounts)
→ Privilege escalation (admin group modification)
→ Defense evasion (log clearing attempts)

**Detection capabilities:**
✅ Baseline vs. attack traffic comparison
✅ Multi-host correlation queries
✅ Sysmon + Windows Event Log integration
✅ Process execution timeline reconstruction
✅ Failed login anomaly detection

**The breakthrough moment:**
Spent 4 hours debugging why my SIEM wasn't showing attack data. Turned out to be a perfect storm of:
- Missing inputs.conf configuration
- Non-existent destination indexes
- Hostname resolution mismatch

Solving these taught me more about SIEM architecture than any tutorial could.

**Metrics that matter:**
- Mean time to detect: <3 minutes
- False positive rate: 0% (baseline comparison validated)
- Detection coverage: 6/6 MITRE techniques
- Time to full pipeline restoration: 4 hours

This lab is now part of my portfolio as I pursue SOC Analyst roles in the Toronto area.

Available for opportunities starting January 2027 (post-graduation from University of Guelph's MCTI program).

GitHub link in comments. Open to connecting with SOC professionals, hiring managers, and fellow cybersecurity students.

#SOCAnalyst #JobSearch #Cybersecurity #Splunk #SIEM #DetectionEngineering #Toronto #Hiring

---

## Hashtag Strategy

**Primary hashtags (always include):**
#Cybersecurity #SOC #SIEM #Splunk #DetectionEngineering

**Technical hashtags:**
#ThreatHunting #ThreatDetection #InfoSec #BlueTeam #RedTeam #PurpleTeam

**Certification/Career hashtags:**
#CySA #CompTIA #SOCAnalyst #CyberSecurity #InfoSecJobs

**Location-based:**
#Toronto #TorontoCyber #CanadaCybersecurity

**Engagement hashtags:**
#LessonsLearned #TechLearning #CyberEducation #HandsOnLearning

---

## Tips for Maximum Engagement

1. **Post timing:** Tuesday-Thursday, 8-10 AM EST (when SOC managers check LinkedIn)
2. **Include visuals:** Attach 2-3 screenshots (network diagram, Splunk dashboard, attack timeline)
3. **Tag relevant people:** Don't tag randomly, but if you've connected with SOC professionals, consider it
4. **Respond to comments:** Engage within first 2 hours for algorithm boost
5. **Use document feature:** LinkedIn allows PDF uploads—attach your technical report
6. **Pin post:** Pin to your profile for 1-2 weeks as your "featured project"
7. **Cross-post:** Share in relevant LinkedIn groups (Cybersecurity Professionals, SOC Analysts, etc.)

---

## GitHub Repository Link for Comments

```
Full technical documentation, attack methodology, SPL queries, and screenshots:
https://github.com/prashersumesh/SOC-Purple-Team-Lab

Includes:
📂 10 production-ready detection queries
📂 Complete attack timeline with timestamps
📂 SIEM troubleshooting playbook
📂 119,050+ events dataset summary
📂 Multi-endpoint correlation examples
```

---

## Follow-up Post Ideas (1 week later)

**Post 2: "5 SIEM troubleshooting mistakes I made (so you don't have to)"**
**Post 3: "Here's what 119,050 security events taught me about baseline behavior"**
**Post 4: "The difference between entry-level and mid-level SOC analyst (my lab comparison)"**
