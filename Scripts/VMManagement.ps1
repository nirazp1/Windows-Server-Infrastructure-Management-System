# MedSpace VMware Infrastructure Management Script
# This script provides comprehensive VMware infrastructure management capabilities

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [ValidateSet('GetVMStatus', 'StartVM', 'StopVM', 'RestartVM', 'GetVMResourceUsage', 'CreateSnapshot', 'RemoveSnapshot', 'CloneVM', 'GetHostStatus')]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [string]$VMName,
    
    [Parameter(Mandatory=$false)]
    [string]$SnapshotName,
    
    [Parameter(Mandatory=$false)]
    [string]$TemplateName,
    
    [Parameter(Mandatory=$false)]
    [string]$HostName,
    
    [Parameter(Mandatory=$false)]
    [string]$DatastoreName,
    
    [Parameter(Mandatory=$false)]
    [string]$ClusterName
)

# Import required modules
Import-Module VMware.VimAutomation.Core

# Function to connect to vCenter
function Connect-VCenter {
    try {
        # Note: In production, these credentials should be stored securely
        $vCenterServer = "vcenter.example.com"
        $credential = Get-Credential -Message "Enter vCenter credentials"
        Connect-VIServer -Server $vCenterServer -Credential $credential
        Write-Host "Connected to vCenter successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Error connecting to vCenter: $_" -ForegroundColor Red
        throw
    }
}

# Function to get VM status
function Get-VMStatus {
    param ([string]$VMName)
    
    try {
        $vm = Get-VM -Name $VMName
        $status = [PSCustomObject]@{
            Name = $vm.Name
            PowerState = $vm.PowerState
            NumCpu = $vm.NumCpu
            MemoryGB = $vm.MemoryGB
            ProvisionedSpaceGB = $vm.ProvisionedSpaceGB
            UsedSpaceGB = $vm.UsedSpaceGB
            Guest = $vm.Guest
            Notes = $vm.Notes
        }
        $status | Format-List
    }
    catch {
        Write-Host "Error getting VM status: $_" -ForegroundColor Red
        throw
    }
}

# Function to manage VM power state
function Set-VMPowerState {
    param (
        [string]$VMName,
        [string]$Action
    )
    
    try {
        $vm = Get-VM -Name $VMName
        switch ($Action) {
            'StartVM' {
                Start-VM -VM $vm
                Write-Host "VM $VMName started successfully" -ForegroundColor Green
            }
            'StopVM' {
                Stop-VM -VM $vm -Confirm:$false
                Write-Host "VM $VMName stopped successfully" -ForegroundColor Green
            }
            'RestartVM' {
                Restart-VM -VM $vm -Confirm:$false
                Write-Host "VM $VMName restarted successfully" -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Host "Error managing VM power state: $_" -ForegroundColor Red
        throw
    }
}

# Function to get VM resource usage
function Get-VMResourceUsage {
    param ([string]$VMName)
    
    try {
        $vm = Get-VM -Name $VMName
        $stats = Get-Stat -Entity $vm -Stat cpu.usage.average,mem.usage.average,disk.usage.average -MaxSamples 1
        
        $usage = [PSCustomObject]@{
            Name = $vm.Name
            CPUUsage = $stats | Where-Object { $_.MetricId -eq 'cpu.usage.average' } | Select-Object -ExpandProperty Value
            MemoryUsage = $stats | Where-Object { $_.MetricId -eq 'mem.usage.average' } | Select-Object -ExpandProperty Value
            DiskUsage = $stats | Where-Object { $_.MetricId -eq 'disk.usage.average' } | Select-Object -ExpandProperty Value
        }
        $usage | Format-List
    }
    catch {
        Write-Host "Error getting VM resource usage: $_" -ForegroundColor Red
        throw
    }
}

# Function to manage snapshots
function Manage-VMSnapshot {
    param (
        [string]$VMName,
        [string]$SnapshotName,
        [string]$Action
    )
    
    try {
        $vm = Get-VM -Name $VMName
        switch ($Action) {
            'CreateSnapshot' {
                New-Snapshot -VM $vm -Name $SnapshotName -Description "Created by MedSpace script"
                Write-Host "Snapshot $SnapshotName created successfully for VM $VMName" -ForegroundColor Green
            }
            'RemoveSnapshot' {
                $snapshot = Get-Snapshot -VM $vm -Name $SnapshotName
                Remove-Snapshot -Snapshot $snapshot -Confirm:$false
                Write-Host "Snapshot $SnapshotName removed successfully from VM $VMName" -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Host "Error managing snapshots: $_" -ForegroundColor Red
        throw
    }
}

# Function to clone VM
function New-VMClone {
    param (
        [string]$VMName,
        [string]$TemplateName,
        [string]$DatastoreName
    )
    
    try {
        $vm = Get-VM -Name $VMName
        $template = Get-Template -Name $TemplateName
        $datastore = Get-Datastore -Name $DatastoreName
        
        $cloneParams = @{
            VM = $vm
            Name = "$VMName-Clone"
            Template = $template
            Datastore = $datastore
            Location = $vm.Folder
        }
        
        New-VM @cloneParams
        Write-Host "VM $VMName cloned successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Error cloning VM: $_" -ForegroundColor Red
        throw
    }
}

# Function to get host status
function Get-HostStatus {
    param ([string]$HostName)
    
    try {
        $host = Get-VMHost -Name $HostName
        $status = [PSCustomObject]@{
            Name = $host.Name
            PowerState = $host.PowerState
            ConnectionState = $host.ConnectionState
            NumCpu = $host.NumCpu
            CpuUsageMhz = $host.CpuUsageMhz
            CpuTotalMhz = $host.CpuTotalMhz
            MemoryUsageGB = $host.MemoryUsageGB
            MemoryTotalGB = $host.MemoryTotalGB
            Version = $host.Version
            Build = $host.Build
        }
        $status | Format-List
    }
    catch {
        Write-Host "Error getting host status: $_" -ForegroundColor Red
        throw
    }
}

# Main execution
try {
    # Connect to vCenter
    Connect-VCenter
    
    switch ($Action) {
        'GetVMStatus' {
            if (-not $VMName) {
                throw "VM name is required for VM status check"
            }
            Get-VMStatus -VMName $VMName
        }
        
        'StartVM' {
            if (-not $VMName) {
                throw "VM name is required for VM operations"
            }
            Set-VMPowerState -VMName $VMName -Action 'StartVM'
        }
        
        'StopVM' {
            if (-not $VMName) {
                throw "VM name is required for VM operations"
            }
            Set-VMPowerState -VMName $VMName -Action 'StopVM'
        }
        
        'RestartVM' {
            if (-not $VMName) {
                throw "VM name is required for VM operations"
            }
            Set-VMPowerState -VMName $VMName -Action 'RestartVM'
        }
        
        'GetVMResourceUsage' {
            if (-not $VMName) {
                throw "VM name is required for resource usage check"
            }
            Get-VMResourceUsage -VMName $VMName
        }
        
        'CreateSnapshot' {
            if (-not $VMName -or -not $SnapshotName) {
                throw "VM name and snapshot name are required for snapshot operations"
            }
            Manage-VMSnapshot -VMName $VMName -SnapshotName $SnapshotName -Action 'CreateSnapshot'
        }
        
        'RemoveSnapshot' {
            if (-not $VMName -or -not $SnapshotName) {
                throw "VM name and snapshot name are required for snapshot operations"
            }
            Manage-VMSnapshot -VMName $VMName -SnapshotName $SnapshotName -Action 'RemoveSnapshot'
        }
        
        'CloneVM' {
            if (-not $VMName -or -not $TemplateName -or -not $DatastoreName) {
                throw "VM name, template name, and datastore name are required for cloning"
            }
            New-VMClone -VMName $VMName -TemplateName $TemplateName -DatastoreName $DatastoreName
        }
        
        'GetHostStatus' {
            if (-not $HostName) {
                throw "Host name is required for host status check"
            }
            Get-HostStatus -HostName $HostName
        }
    }
    
    # Disconnect from vCenter
    Disconnect-VIServer -Confirm:$false
}
catch {
    Write-Host "Error executing VMware operation: $_" -ForegroundColor Red
    if (Get-VIServer) {
        Disconnect-VIServer -Confirm:$false
    }
    exit 1
} 