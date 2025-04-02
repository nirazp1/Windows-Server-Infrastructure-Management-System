# Windows Server Infrastructure Management System

A comprehensive Windows Server infrastructure management solution that demonstrates expertise in systems engineering, automation, and infrastructure management.

## Project Overview

This project is a collection of PowerShell tools and scripts designed to automate and manage Windows Server infrastructure. It showcases expertise in:
- Windows Server Administration
- PowerShell Automation
- Infrastructure Monitoring
- System Center Integration
- Active Directory Management
- Virtualization Management

## Features

### 1. Server Health Monitoring
- Real-time monitoring of server resources
- Automated health checks
- Alert system for critical issues
- Performance metrics collection

### 2. Active Directory Management
- User account automation
- Group policy management
- DNS and DHCP monitoring
- Security policy enforcement

### 3. Virtualization Management
- VMware infrastructure monitoring
- Resource utilization tracking
- VM lifecycle management
- Automated backup scheduling

### 4. Automation Tools
- PowerShell scripts for common tasks
- Scheduled maintenance automation
- Deployment automation
- System updates management

## Prerequisites

- Windows Server 2019 or later
- PowerShell 5.1 or later
- Active Directory environment
- VMware vSphere environment (optional)

## Installation

1. Clone this repository
2. Run the setup script with administrator privileges:
```powershell
.\Setup.ps1 -InstallModules -ConfigureEnvironment -CreateTestEnvironment
```

## Usage Examples

### 1. Server Health Monitoring
```powershell
# Basic health check
.\Scripts\HealthCheck.ps1 -ServerName "ServerName"

# Detailed health check with report
.\Scripts\HealthCheck.ps1 -ServerName "ServerName" -DetailedReport -OutputPath "C:\Reports\health_check.xml"
```

### 2. Active Directory Management
```powershell
# Create a new user
.\Scripts\ADManagement.ps1 -Action "CreateUser" -Username "JohnDoe" -FirstName "John" -LastName "Doe" -Department "IT" -Title "System Engineer" -NewPassword "SecureP@ss123" -OUPath "OU=Users,DC=example,DC=com"

# Get user information
.\Scripts\ADManagement.ps1 -Action "GetUserInfo" -Username "JohnDoe"

# Add user to group
.\Scripts\ADManagement.ps1 -Action "AddToGroup" -Username "JohnDoe" -GroupName "Domain Admins"
```

### 3. VMware Management
```powershell
# Get VM status
.\Scripts\VMManagement.ps1 -Action "GetVMStatus" -VMName "VMName"

# Create VM snapshot
.\Scripts\VMManagement.ps1 -Action "CreateSnapshot" -VMName "VMName" -SnapshotName "PreUpdate"

# Monitor VM resources
.\Scripts\VMManagement.ps1 -Action "GetVMResourceUsage" -VMName "VMName"
```

## Project Structure

```
InfrastructureManagement/
├── Scripts/
│   ├── HealthCheck.ps1
│   ├── ADManagement.ps1
│   ├── VMManagement.ps1
│   └── BackupManagement.ps1
├── Dashboard/
│   ├── index.html
│   └── assets/
├── Documentation/
│   ├── Setup.md
│   └── Usage.md
└── Tests/
    └── TestScripts.ps1
```

## Use Cases

1. **System Administration**
   - Automated server health monitoring
   - Proactive issue detection
   - Performance optimization
   - Resource utilization tracking

2. **Active Directory Management**
   - Bulk user creation and management
   - Group policy enforcement
   - Security compliance monitoring
   - Access control automation

3. **Virtualization Management**
   - VM lifecycle automation
   - Resource optimization
   - Backup and recovery
   - Infrastructure scaling

4. **IT Operations**
   - Automated maintenance tasks
   - System updates management
   - Configuration management
   - Compliance reporting

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

# Windows-Server-Infrastructure-Management-System
