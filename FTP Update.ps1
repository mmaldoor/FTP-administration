
if (!(Get-InstalledModule -name psWindowsUpdate -ErrorAction SilentlyContinue)) {Install-Module -Name PSWindowsUpdate}
Import-Module -Name PSWindowsUpdate
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Get-Command -Module psWindowsUpdate
Get-WindowsUpdate 

$KBID = "specify the KBID From get-windowsupdate command"  #To install an update with a specific KB id #https://www.catalog.update.microsoft.com/Search.aspx?q=KB4577586
Install-WindowsUpdate -KBArticleID $KBID  #Get-help Install-windowsudate -parameter * // to see the parameters that can be used for this command

Install-WindowsUpdate -Title "*FTP*"
Install-WindowsUpdate -Title "*IIS*"