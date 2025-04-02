# MedSpace Active Directory Management Script
# This script provides comprehensive Active Directory management capabilities

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [ValidateSet('CreateUser', 'ModifyUser', 'DeleteUser', 'GetUserInfo', 'ResetPassword', 'EnableUser', 'DisableUser', 'AddToGroup', 'RemoveFromGroup')]
    [string]$Action,
    
    [Parameter(Mandatory=$true)]
    [string]$Username,
    
    [Parameter(Mandatory=$false)]
    [string]$FirstName,
    
    [Parameter(Mandatory=$false)]
    [string]$LastName,
    
    [Parameter(Mandatory=$false)]
    [string]$Department,
    
    [Parameter(Mandatory=$false)]
    [string]$Title,
    
    [Parameter(Mandatory=$false)]
    [string]$NewPassword,
    
    [Parameter(Mandatory=$false)]
    [string]$GroupName,
    
    [Parameter(Mandatory=$false)]
    [string]$OUPath
)

# Import required modules
Import-Module ActiveDirectory

# Function to create a new user
function New-ADUserAccount {
    param (
        [string]$Username,
        [string]$FirstName,
        [string]$LastName,
        [string]$Department,
        [string]$Title,
        [string]$OUPath
    )
    
    try {
        $securePassword = ConvertTo-SecureString -String $NewPassword -AsPlainText -Force
        
        $userParams = @{
            SamAccountName = $Username
            UserPrincipalName = "$Username@$env:USERDNSDOMAIN"
            Name = "$FirstName $LastName"
            GivenName = $FirstName
            Surname = $LastName
            Department = $Department
            Title = $Title
            AccountPassword = $securePassword
            Enabled = $true
            Path = $OUPath
            ChangePasswordAtLogon = $true
        }
        
        New-ADUser @userParams
        Write-Host "User $Username created successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Error creating user: $_" -ForegroundColor Red
        throw
    }
}

# Function to modify user properties
function Set-ADUserProperties {
    param (
        [string]$Username,
        [string]$FirstName,
        [string]$LastName,
        [string]$Department,
        [string]$Title
    )
    
    try {
        $user = Get-ADUser -Identity $Username
        
        $setParams = @{
            Identity = $user
        }
        
        if ($FirstName) { $setParams.GivenName = $FirstName }
        if ($LastName) { $setParams.Surname = $LastName }
        if ($Department) { $setParams.Department = $Department }
        if ($Title) { $setParams.Title = $Title }
        
        Set-ADUser @setParams
        Write-Host "User $Username modified successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Error modifying user: $_" -ForegroundColor Red
        throw
    }
}

# Function to delete a user
function Remove-ADUserAccount {
    param ([string]$Username)
    
    try {
        $user = Get-ADUser -Identity $Username
        Remove-ADUser -Identity $user -Confirm:$false
        Write-Host "User $Username deleted successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Error deleting user: $_" -ForegroundColor Red
        throw
    }
}

# Function to get user information
function Get-ADUserInformation {
    param ([string]$Username)
    
    try {
        $user = Get-ADUser -Identity $Username -Properties *
        $user | Format-List
    }
    catch {
        Write-Host "Error getting user information: $_" -ForegroundColor Red
        throw
    }
}

# Function to reset user password
function Reset-ADUserPassword {
    param (
        [string]$Username,
        [string]$NewPassword
    )
    
    try {
        $securePassword = ConvertTo-SecureString -String $NewPassword -AsPlainText -Force
        Set-ADAccountPassword -Identity $Username -NewPassword $securePassword
        Write-Host "Password reset successfully for user $Username" -ForegroundColor Green
    }
    catch {
        Write-Host "Error resetting password: $_" -ForegroundColor Red
        throw
    }
}

# Function to enable/disable user account
function Set-ADUserAccountStatus {
    param (
        [string]$Username,
        [bool]$Enabled
    )
    
    try {
        Enable-ADAccount -Identity $Username
        $status = if ($Enabled) { "enabled" } else { "disabled" }
        Write-Host "User $Username $status successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "Error changing account status: $_" -ForegroundColor Red
        throw
    }
}

# Function to manage group membership
function Set-ADGroupMembership {
    param (
        [string]$Username,
        [string]$GroupName,
        [bool]$Add
    )
    
    try {
        if ($Add) {
            Add-ADGroupMember -Identity $GroupName -Members $Username
            Write-Host "User $Username added to group $GroupName successfully" -ForegroundColor Green
        }
        else {
            Remove-ADGroupMember -Identity $GroupName -Members $Username -Confirm:$false
            Write-Host "User $Username removed from group $GroupName successfully" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Error managing group membership: $_" -ForegroundColor Red
        throw
    }
}

# Main execution
try {
    switch ($Action) {
        'CreateUser' {
            if (-not $FirstName -or -not $LastName -or -not $NewPassword -or -not $OUPath) {
                throw "Missing required parameters for user creation"
            }
            New-ADUserAccount -Username $Username -FirstName $FirstName -LastName $LastName -Department $Department -Title $Title -OUPath $OUPath
        }
        
        'ModifyUser' {
            Set-ADUserProperties -Username $Username -FirstName $FirstName -LastName $LastName -Department $Department -Title $Title
        }
        
        'DeleteUser' {
            Remove-ADUserAccount -Username $Username
        }
        
        'GetUserInfo' {
            Get-ADUserInformation -Username $Username
        }
        
        'ResetPassword' {
            if (-not $NewPassword) {
                throw "New password is required for password reset"
            }
            Reset-ADUserPassword -Username $Username -NewPassword $NewPassword
        }
        
        'EnableUser' {
            Set-ADUserAccountStatus -Username $Username -Enabled $true
        }
        
        'DisableUser' {
            Set-ADUserAccountStatus -Username $Username -Enabled $false
        }
        
        'AddToGroup' {
            if (-not $GroupName) {
                throw "Group name is required for group operations"
            }
            Set-ADGroupMembership -Username $Username -GroupName $GroupName -Add $true
        }
        
        'RemoveFromGroup' {
            if (-not $GroupName) {
                throw "Group name is required for group operations"
            }
            Set-ADGroupMembership -Username $Username -GroupName $GroupName -Add $false
        }
    }
}
catch {
    Write-Host "Error executing AD operation: $_" -ForegroundColor Red
    exit 1
} 