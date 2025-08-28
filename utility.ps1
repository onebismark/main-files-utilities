Write-Host "=============================" -ForegroundColor Cyan
Write-Host "   Markmix Studios Utilities " -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "1. System Information"
Write-Host "2. System Security State"
Write-Host "============================="

$choice = Read-Host "Enter option (1 or 2)"

switch ($choice) {
    1 {
        Write-Host "`n===== System Information =====" -ForegroundColor Cyan
        Write-Host "OS:" (Get-CimInstance Win32_OperatingSystem).Caption
        Write-Host "Build:" (Get-CimInstance Win32_OperatingSystem).Version
        Write-Host "Computer Name:" $env:COMPUTERNAME
        Write-Host "User Name:" $env:USERNAME
        Write-Host "CPU:" (Get-CimInstance Win32_Processor).Name
        Write-Host "Cores:" (Get-CimInstance Win32_Processor).NumberOfCores
        Write-Host "Logical Processors:" (Get-CimInstance Win32_Processor).NumberOfLogicalProcessors
        Write-Host "RAM (GB):" "{0:N2}" -f ((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB)

        Write-Host "`n===== Storage ====="
        Get-PSDrive -PSProvider FileSystem | ForEach-Object {
            Write-Host "$($_.Name): $([math]::Round($_.Used/1GB,2)) GB used / $([math]::Round($_.Free/1GB,2)) GB free"
        }
    }
    2 {
        Write-Host "`n===== Security State =====" -ForegroundColor Green

        # Firewall
        $fw = (Get-NetFirewallProfile | Where-Object {$_.Enabled -eq "True"}).Name
        if ($fw) {
            Write-Host "Firewall: ENABLED (Profiles: $fw)"
        } else {
            Write-Host "Firewall: DISABLED" -ForegroundColor Red
        }

        # Antivirus
        try {
            $av = Get-CimInstance -Namespace "root/SecurityCenter2" -ClassName AntivirusProduct
            if ($av) {
                Write-Host "Antivirus:" $av.displayName
            } else {
                Write-Host "Antivirus: Not detected" -ForegroundColor Red
            }
        } catch {
            Write-Host "Antivirus check failed (need admin)."
        }

        # Updates
        Write-Host "Windows Update Last Install:" (Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 1).InstalledOn
    }
    Default {
        Write-Host "Invalid option. Please choose 1 or 2." -ForegroundColor Red
    }
}