# MedSpace Setup Script
# This script sets up the required environment and dependencies for the MedSpace project

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [switch]$InstallModules,
    
    [Parameter(Mandatory=$false)]
    [switch]$ConfigureEnvironment,
    
    [Parameter(Mandatory=$false)]
    [switch]$CreateTestEnvironment
)

# Function to check if running with administrative privileges
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to install required PowerShell modules
function Install-RequiredModules {
    Write-Host "Installing required PowerShell modules..." -ForegroundColor Yellow
    
    $modules = @(
        @{
            Name = "ActiveDirectory"
            Version = "1.0.0"
        },
        @{
            Name = "VMware.VimAutomation.Core"
            Version = "12.7.0"
        }
    )
    
    foreach ($module in $modules) {
        if (-not (Get-Module -ListAvailable -Name $module.Name)) {
            Write-Host "Installing $($module.Name) module..." -ForegroundColor Yellow
            Install-Module -Name $module.Name -MinimumVersion $module.Version -Force -AllowClobber
        } else {
            Write-Host "$($module.Name) module is already installed" -ForegroundColor Green
        }
    }
}

# Function to configure environment variables
function Set-EnvironmentVariables {
    Write-Host "Configuring environment variables..." -ForegroundColor Yellow
    
    $envVars = @{
        "MEDSPACE_VCENTER_SERVER" = "vcenter.example.com"
        "MEDSPACE_DEFAULT_DOMAIN" = "example.com"
        "MEDSPACE_LOG_PATH" = "C:\MedSpace\Logs"
        "MEDSPACE_CONFIG_PATH" = "C:\MedSpace\Config"
    }
    
    foreach ($var in $envVars.GetEnumerator()) {
        [System.Environment]::SetEnvironmentVariable($var.Key, $var.Value, [System.EnvironmentVariableTarget]::User)
        Write-Host "Set environment variable: $($var.Key)" -ForegroundColor Green
    }
}

# Function to create test environment
function New-TestEnvironment {
    Write-Host "Creating test environment..." -ForegroundColor Yellow
    
    # Create test directories
    $directories = @(
        "C:\MedSpace\Logs",
        "C:\MedSpace\Config",
        "C:\MedSpace\Scripts",
        "C:\MedSpace\Tests"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force
            Write-Host "Created directory: $dir" -ForegroundColor Green
        }
    }
    
    # Create test configuration file
    $configContent = @"
{
    "vCenter": {
        "Server": "vcenter.example.com",
        "Username": "administrator@vsphere.local",
        "UseSSL": true
    },
    "ActiveDirectory": {
        "Domain": "example.com",
        "DefaultOU": "OU=Users,DC=example,DC=com"
    },
    "Monitoring": {
        "LogPath": "C:\\MedSpace\\Logs",
        "RetentionDays": 30
    }
}
"@
    
    $configPath = "C:\MedSpace\Config\config.json"
    if (-not (Test-Path $configPath)) {
        $configContent | Out-File -FilePath $configPath -Encoding UTF8
        Write-Host "Created configuration file: $configPath" -ForegroundColor Green
    }
}

# Main execution
try {
    # Check for administrative privileges
    if (-not (Test-Administrator)) {
        Write-Host "This script requires administrative privileges. Please run as administrator." -ForegroundColor Red
        exit 1
    }
    
    # Install modules if requested
    if ($InstallModules) {
        Install-RequiredModules
    }
    
    # Configure environment if requested
    if ($ConfigureEnvironment) {
        Set-EnvironmentVariables
    }
    
    # Create test environment if requested
    if ($CreateTestEnvironment) {
        New-TestEnvironment
    }
    
    Write-Host "`nSetup completed successfully!" -ForegroundColor Green
    Write-Host "`nNext steps:"
    Write-Host "1. Update the configuration file at C:\MedSpace\Config\config.json with your environment details"
    Write-Host "2. Test the scripts using the provided test cases"
    Write-Host "3. Review the documentation for detailed usage instructions"
}
catch {
    Write-Host "Error during setup: $_" -ForegroundColor Red
    exit 1
} 