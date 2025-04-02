# MedSpace Test Script
# This script demonstrates the functionality of the MedSpace tools

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$TestServer = "localhost",
    
    [Parameter(Mandatory=$false)]
    [string]$TestVM = "TestVM",
    
    [Parameter(Mandatory=$false)]
    [string]$TestUser = "TestUser"
)

# Function to test server health check
function Test-ServerHealthCheck {
    Write-Host "`nTesting Server Health Check..." -ForegroundColor Yellow
    
    try {
        # Test basic health check
        Write-Host "Running basic health check..."
        .\Scripts\HealthCheck.ps1 -ServerName $TestServer
        
        # Test detailed health check
        Write-Host "`nRunning detailed health check..."
        .\Scripts\HealthCheck.ps1 -ServerName $TestServer -DetailedReport
        
        # Test health check with output
        $outputPath = "C:\MedSpace\Logs\health_check_$(Get-Date -Format 'yyyyMMdd_HHmmss').xml"
        Write-Host "`nRunning health check with output..."
        .\Scripts\HealthCheck.ps1 -ServerName $TestServer -OutputPath $outputPath
        
        Write-Host "Server health check tests completed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Error during server health check test: $_" -ForegroundColor Red
    }
}

# Function to test AD management
function Test-ADManagement {
    Write-Host "`nTesting Active Directory Management..." -ForegroundColor Yellow
    
    try {
        # Test user creation
        Write-Host "Testing user creation..."
        .\Scripts\ADManagement.ps1 -Action "CreateUser" -Username $TestUser -FirstName "Test" -LastName "User" -Department "IT" -Title "Test User" -NewPassword "P@ssw0rd123!" -OUPath "OU=Users,DC=example,DC=com"
        
        # Test user modification
        Write-Host "`nTesting user modification..."
        .\Scripts\ADManagement.ps1 -Action "ModifyUser" -Username $TestUser -Department "Engineering" -Title "Test Engineer"
        
        # Test user information retrieval
        Write-Host "`nTesting user information retrieval..."
        .\Scripts\ADManagement.ps1 -Action "GetUserInfo" -Username $TestUser
        
        # Test group membership
        Write-Host "`nTesting group membership..."
        .\Scripts\ADManagement.ps1 -Action "AddToGroup" -Username $TestUser -GroupName "Domain Users"
        
        # Test password reset
        Write-Host "`nTesting password reset..."
        .\Scripts\ADManagement.ps1 -Action "ResetPassword" -Username $TestUser -NewPassword "NewP@ssw0rd123!"
        
        # Test user deletion
        Write-Host "`nTesting user deletion..."
        .\Scripts\ADManagement.ps1 -Action "DeleteUser" -Username $TestUser
        
        Write-Host "Active Directory management tests completed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Error during AD management test: $_" -ForegroundColor Red
    }
}

# Function to test VM management
function Test-VMManagement {
    Write-Host "`nTesting VMware Management..." -ForegroundColor Yellow
    
    try {
        # Test VM status check
        Write-Host "Testing VM status check..."
        .\Scripts\VMManagement.ps1 -Action "GetVMStatus" -VMName $TestVM
        
        # Test VM resource usage
        Write-Host "`nTesting VM resource usage check..."
        .\Scripts\VMManagement.ps1 -Action "GetVMResourceUsage" -VMName $TestVM
        
        # Test snapshot management
        Write-Host "`nTesting snapshot management..."
        .\Scripts\VMManagement.ps1 -Action "CreateSnapshot" -VMName $TestVM -SnapshotName "TestSnapshot"
        
        # Test VM cloning
        Write-Host "`nTesting VM cloning..."
        .\Scripts\VMManagement.ps1 -Action "CloneVM" -VMName $TestVM -TemplateName "TestTemplate" -DatastoreName "TestDatastore"
        
        # Test host status
        Write-Host "`nTesting host status check..."
        .\Scripts\VMManagement.ps1 -Action "GetHostStatus" -HostName "TestHost"
        
        Write-Host "VMware management tests completed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Error during VM management test: $_" -ForegroundColor Red
    }
}

# Main execution
try {
    Write-Host "Starting MedSpace test suite..." -ForegroundColor Cyan
    
    # Run all tests
    Test-ServerHealthCheck
    Test-ADManagement
    Test-VMManagement
    
    Write-Host "`nTest suite completed!" -ForegroundColor Green
}
catch {
    Write-Host "Error during test suite execution: $_" -ForegroundColor Red
    exit 1
} 