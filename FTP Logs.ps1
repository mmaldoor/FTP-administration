Get-ChildItem -Path  C:\inetpub\logs\LogFiles\FTPSVC1  | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content | Out-GridView

Get-Content -Path C:\inetpub\logs\LogFiles\FTPSVC3\u_ex210409.log | Out-GridView

### Install the module from the PowerShell Gallery (must be run as Admin)
Install-Module -Name msrcsecurityupdates -force
Import-module MsrcSecurityUpdates
Get-Command -Module MsrcSecurityUpdates
$monthOfInterest = '2020-Apr'
New-Item -Path C:\test -Value "upd" -ItemType File
Get-MsrcCvrfDocument -ID $monthOfInterest -Verbose | Get-MsrcSecurityBulletinHtml -Verbose | Out-File -FilePath "C:\test\upd.html" -Force

$content = Get-MsrcCvrfDocument -ID $monthOfInterest # can also specity seach by year with $monthofinterest = "2021-*"
$content | Get-Member
$content.Vulnerability | Get-Member
$content.Vulnerability.notes | Where-Object {$_.title -like "*FTP*" -or $_.title -like "*IIS*" -or $_.Value -like "*FTP*" -or $_.Value -like "IIS" } 


$monthOfInterest = "2017-Mar"

$CVEsWanted = @(
        "CVE-2017-0001", 
        "CVE-2017-0005"
        )
$Output_Location = "C:\your\path\here"

$CVRFDoc = Get-MsrcCvrfDocument -ID $monthOfInterest -Verbose
$CVRFHtmlProperties = @{
    Vulnerability = $CVRFDoc.Vulnerability | Where-Object {$_.CVE -in $CVEsWanted}
    ProductTree = $CVRFDoc.ProductTree
    DocumentTracking = $CVRFDoc.DocumentTracking
    DocumentTitle = $CVRFDoc.DocumentTitle
}

Get-MsrcSecurityBulletinHtml @CVRFHtmlProperties -Verbose | Out-File $Output_Location
