#!/usr/bin/env pwsh

Param(
    [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $false)]
    [System.String]
    $XmlFile
)


function Get-AssignedAccessCspBridgeWmi {
    return Get-CimInstance -Namespace "root\cimv2\mdm\dmmap" -ClassName MDM_AssignedAccess
}

function Set-ShellLauncherBridgeWMI([Parameter(Mandatory = $True)][String] $FilePath) {
    $Xml = Get-Content -Path $FilePath
    $AssignedAccessCsp = Get-AssignedAccessCspBridgeWmi
    $AssignedAccessCsp.ShellLauncher = [System.Security.SecurityElement]::Escape($Xml)
    Set-CimInstance -CimInstance $AssignedAccessCsp

    # get a new instance and print the value
    return (Get-AssignedAccessCspBridgeWmi).ShellLauncher
}

function Clear-ShellLauncherBridgeWMI {
    $AssignedAccessCsp = Get-AssignedAccessCspBridgeWmi
    $AssignedAccessCsp.ShellLauncher = $NULL
    Set-CimInstance -CimInstance $AssignedAccessCsp
}

function Get-ShellLauncherBridgeWMI {
    (Get-AssignedAccessCspBridgeWmi).ShellLauncher
}

# Create a handle to the class instance so we can call the static methods.
try {
    # Get-AssignedAccessCspBridgeWmi | Write-Error
    Set-ShellLauncherBridgeWMI($XmlFile)
}
catch [Exception] {
    write-host $_.Exception.Message;
    write-host "Make sure Shell Launcher feature is enabled"
    exit
}
