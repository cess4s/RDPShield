Installation Guide

To ensure the script functions correctly, please follow these steps:

1. Directory Setup: Move the rdpShield folder directly into the C: drive.
   Target path: C:\rdpShield\
        
2. Administrator Access: Open PowerShell with Administrator privileges.
    
3. Navigate to Directory: Change your location to the project folder:
   cd C:\rdpShield

4. Execute Setup: Run the Task Creator script to configure the automated monitoring:
    .\rdpShieldTaskCreater.ps1

How It Works
    Automation: Upon successful execution, a new task is registered in the Windows Task Scheduler.
    Interval: The script is configured to trigger automatically every 15 minutes.

Tested in Windows 10, Windows Server 2016
