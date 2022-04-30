$Website="MYFTP"
$Path = "C:\FTPRoot"

Get-Website | Where-Object {$_.name -match $Website} | Remove-Website
Get-item $Path | Remove-Item -Force -Recurse
Uninstall-WindowsFeature -Name Web-Ftp-Server