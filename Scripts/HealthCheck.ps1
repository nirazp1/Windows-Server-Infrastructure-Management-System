# MedSpace Server Health Check Script
# This script performs comprehensive health checks on Windows servers

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$ServerName,
    
    [Parameter(Mandatory=$false)]
    [switch]$DetailedReport,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath
)

# Function to check CPU usage
function Get-CPUUsage {
    param ($ComputerName)
    $cpu = Get-WmiObject Win32_Processor -ComputerName $ComputerName | Measure-Object -Property LoadPercentage -Average | Select-Object Average
    return $cpu.Average
}

# Function to check memory usage
function Get-MemoryUsage {
    param ($ComputerName)
    $memory = Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName
    $totalMemory = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
    $freeMemory = [math]::Round($memory.FreePhysicalMemory / 1MB, 2)
    $usedMemory = $totalMemory - $freeMemory
    $memoryUsage = [math]::Round(($usedMemory / $totalMemory) * 100, 2)
    return @{
        Total = $totalMemory
        Free = $freeMemory
        Used = $usedMemory
        UsagePercent = $memoryUsage
    }
}

# Function to check disk space
function Get-DiskSpace {
    param ($ComputerName)
    $disks = Get-WmiObject Win32_LogicalDisk -ComputerName $ComputerName | Where-Object { $_.DriveType -eq 3 }
    $diskInfo = @()
    foreach ($disk in $disks) {
        $freeSpace = [math]::Round($disk.FreeSpace / 1GB, 2)
        $totalSpace = [math]::Round($disk.Size / 1GB, 2)
        $usedSpace = $totalSpace - $freeSpace
        $diskInfo += [PSCustomObject]@{
            Drive = $disk.DeviceID
            Total = $totalSpace
            Free = $freeSpace
            Used = $usedSpace
            UsagePercent = [math]::Round(($usedSpace / $totalSpace) * 100, 2)
        }
    }
    return $diskInfo
}

# Function to check service status
function Get-ServiceStatus {
    param ($ComputerName)
    $services = Get-WmiObject Win32_Service -ComputerName $ComputerName | Where-Object { $_.StartMode -eq "Auto" }
    $serviceStatus = @()
    foreach ($service in $services) {
        if ($service.State -ne "Running") {
            $serviceStatus += [PSCustomObject]@{
                Name = $service.DisplayName
                State = $service.State
                StartMode = $service.StartMode
            }
        }
    }
    return $serviceStatus
}

# Function to check event logs
function Get-EventLogStatus {
    param ($ComputerName)
    $criticalEvents = Get-EventLog -LogName System -EntryType Error -ComputerName $ComputerName -Newest 10
    $warningEvents = Get-EventLog -LogName System -EntryType Warning -ComputerName $ComputerName -Newest 10
    return @{
        Critical = $criticalEvents
        Warning = $warningEvents
    }
}

# Main execution
try {
    Write-Host "Starting health check for server: $ServerName" -ForegroundColor Green
    
    # Check if server is reachable
    if (-not (Test-Connection -ComputerName $ServerName -Count 1 -Quiet)) {
        throw "Server $ServerName is not reachable"
    }
    
    # Gather health information
    $healthReport = [PSCustomObject]@{
        ServerName = $ServerName
        CheckTime = Get-Date
        CPUUsage = Get-CPUUsage -ComputerName $ServerName
        MemoryUsage = Get-MemoryUsage -ComputerName $ServerName
        DiskSpace = Get-DiskSpace -ComputerName $ServerName
        ServiceStatus = Get-ServiceStatus -ComputerName $ServerName
        EventLogStatus = Get-EventLogStatus -ComputerName $ServerName
    }
    
    # Generate report
    if ($OutputPath) {
        $healthReport | Export-Clixml -Path $OutputPath
        Write-Host "Report saved to: $OutputPath" -ForegroundColor Green
    }
    
    # Display summary
    Write-Host "`nHealth Check Summary:" -ForegroundColor Yellow
    Write-Host "CPU Usage: $($healthReport.CPUUsage)%"
    Write-Host "Memory Usage: $($healthReport.MemoryUsage.UsagePercent)%"
    
    # Check for critical issues
    $criticalIssues = @()
    
    if ($healthReport.CPUUsage -gt 90) {
        $criticalIssues += "High CPU usage detected"
    }
    
    if ($healthReport.MemoryUsage.UsagePercent -gt 90) {
        $criticalIssues += "High memory usage detected"
    }
    
    foreach ($disk in $healthReport.DiskSpace) {
        if ($disk.UsagePercent -gt 90) {
            $criticalIssues += "Low disk space on drive $($disk.Drive)"
        }
    }
    
    if ($healthReport.ServiceStatus.Count -gt 0) {
        $criticalIssues += "Found $($healthReport.ServiceStatus.Count) stopped auto-start services"
    }
    
    if ($healthReport.EventLogStatus.Critical.Count -gt 0) {
        $criticalIssues += "Found $($healthReport.EventLogStatus.Critical.Count) critical events"
    }
    
    if ($criticalIssues.Count -gt 0) {
        Write-Host "`nCritical Issues Found:" -ForegroundColor Red
        $criticalIssues | ForEach-Object { Write-Host "- $_" }
    } else {
        Write-Host "`nNo critical issues found" -ForegroundColor Green
    }
    
    # Display detailed report if requested
    if ($DetailedReport) {
        Write-Host "`nDetailed Report:" -ForegroundColor Yellow
        $healthReport | Format-List
    }
    
} catch {
    Write-Host "Error during health check: $_" -ForegroundColor Red
    exit 1
} 