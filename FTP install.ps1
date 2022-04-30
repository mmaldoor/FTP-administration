#Install IIS Feature
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

#Install FTP feature
Install-WindowsFeature -Name Web-Ftp-Server -IncludeAllSubFeature -IncludeManagementTools

Import-Module WebAdministration 

$PageName = "MYFTP "
$RootFolder = "C:\FTPRoot"
$IPAddress = (Get-NetIPConfiguration).IPv4Address.IPAddress
$DomainName = "myftp.com"
$Port = 21

if (!(Test-Path $RootFolder)) { 
 New-Item -Path $RootFolder -ItemType Directory 
}
New-WebFtpSite -Name $PageName -PhysicalPath $RootFolder -Port $Port -IPAddress $IPAddress -HostHeader $DomainName -Force

#https://docs.microsoft.com/en-us/iis/configuration/system.applicationhost/sites/sitedefaults/ftpserver/security/ssl

$FTPPath = "IIS:\Sites\$PageName"
$SSLPolicy = @(
    'ftpServer.security.ssl.controlChannelPolicy',
    'ftpServer.security.ssl.dataChannelPolicy'
)
$SSLPolicy | ForEach-Object {Set-ItemProperty -Path $FTPPath -Name $_ -Value 0 }

$FTPPath = "IIS:\Sites\$PageName"
$BasicAuth = 'ftpServer.security.authentication.basicAuthentication.enabled' #Enable basic Authentication settings on the FTP website
Set-ItemProperty -Path $FTPPath -Name $BasicAuth -Value $True

$Roles = "Administrators" #specifies whos gonna get permissions to access the website
$param = @{
    PSPath = 'IIS:\'
    Location = $PageName
    Filter = '/system.ftpserver/security/authorization' # Adding authorization rule to allow Administrator users to access the FTP website, 
    Value = @{ accesstype = 'Allow'; roles = $Roles; permissions = 3 } #Futher configuration can be made here to allow FTP local-group to access the website
}
Add-WebConfiguration @param
Restart-WebItem $FTPPath
