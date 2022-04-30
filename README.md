# Administering av FTP server

<br>

## Det programvare jeg har valgt 

FTP "File Transfer protocol" er en protokoll som hovedsaklig brukes til å overføre filer mellom en klient og en server i et tcp/ip-basert nettverk. FTP serveren står aktiv, og lytter på netverket etter førespørsler på port 21. Dersom en klient sende en førespørsel til serveren og muligens autentisere seg, så kan klienten administrere, laste opp eller ned filer til og fra harddisken til Serveren. FTP tjenesten er fundamental i mange moderne programvarer som tilbyr opp-nedlasting av filer, og i skytjenester. Microsoft tilbyr en tjeneste som heter "Microsoft FTP Server" som gjør det mulig å installere en FTP tjeneste i en server.

<br>

## Programvaresårbarhetshistorikken

Alle programvarer, fra de enkle til de veldig kompliserte, kan ha sårbarheter/sikkerhetshull. Dette gjelder spesielt de som krever tilkobling via internett. Sikkerhetshullene kan oppstå i for eksempel hvor sikker en tilkobling er, hvor sikker dataoverføringen er, eller under autentisering. Sårbarhetene i slike tjenester kan virke attraktive for de som vil utnytte dem. Hvis vi tar en titt på sårbarhets-[databasen](https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=Microsoft+FTP), kan vi se hvor i programvaren sikkerhetshullet har oppstått, og når det oppstod. Et eksempel på dette er *Tjenestenektangrep* (DoS) og tilkoblingsårbarheter som gjorde at angriperne kunne forstyrre tjenesten, og muligens se på inneholde av data-stream.

<img src="https://i.ibb.co/wr64PsS/Screenshot-2021-04-11-180425.png" border="0"></a>
 <br> <br>
Patching av en programvare er det utviklerne som står for, og for denne tjenesten vi skal installere er utvikleren nemlig Microsoft. Microsoft har levert sikkerhetsoppdateringer for cirka like mange sårbarheter som har oppstått for denne tjenesten. Etter å ha lukket alle sikkerhetshullene, så ble antall påviste sårbarheter færre pg færre helt til det bare var en oppdaget sårbarhet i mellom årene 2013 og 2021. <br>

Tjenesten tilbyr genererering av log filer, noe som er veldig godt egnet til å overvåke sikkerheten til tjenesten. log-filene viser aktiviteten til serveren og da kan man se dersom det er noe mystisk. Visning av log-filene skjer på følgende måte:

```Get-ChildItem -Path C:\inetpub\logs\LogFiles\FTPSVC1 | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content | Out-GridView```

<br>

Det er mulig å oppdage en sårbarhet gjennom overvåking av log-filene, eller ved å se over de rapporterte sårbarhetene. Dette kan hjelpe programvareadministratoren å reagere raskt med å installere sikkerhetsoppdateringer fra *Windows Update* så snart de blir utgitt. Microsoft har en hjemmeside *Microsoft Security Response Center* der de gir en hurtig repons på oppdagede sikkerhetshull, og en oversikt over sikkerhetsoppdateringer. Microsoft tilbyr også en modul [msrcsecurityupdates](https://github.com/microsoft/MSRC-Microsoft-Security-Updates-API) som gjør det lettere å jobbe API for henting av cve-filene gjennom powershell.

`Install-Module -Name msrcsecurityupdates -force` <br>
`Import-module MsrcSecurityUpdates` <br>
`$content = Get-MsrcCvrfDocument -ID "2017-Mar" # can also specity seach by year with $monthofinterest = "2021-*"` <br>
`$content.Vulnerability.notes | Where-Object {$_.title -like "*FTP*" -or $_.title -like "*IIS*" -or $_.Value -like "*FTP*" -or $_.Value -like "IIS" }` <br>

Koden ovenfor viser hvordan kan man bruke kommandoen *Get-MsrcCvrfDocument* for å se over sårbarheter knyttet med *IIS* eller *FTP*. Det er mulig og å kombinere koden ovenfor med en if-setning for å varsle administratoren, eller automatisere sikkerhetsoppdateringen i tillegg til en Task-scheduler . For å demonstrere måten vi kan gjøre det på, antar vi at siste *$content" linje som står ovenfor er lagt i variabelen $VM <br>

`If ($VM) {Send-MailMessage  -From $email1 -To $email2 -Subject "There is a vunderablitiy detected" -Body "specify the body " -Credential $Credential -SmtpServer "specify smtp address" -Port "specify port" -UseSsl}` <br> // *Send-Mailmessage* og *Register-ScheduledTask* står konfigurert i min Ransomware-Protection koden (Mappe 1)

`if ($VM) {Get-WindowsUpdate; Install-WindowsUpdate -Title "*FTP*"; Install-WindowsUpdate -Title "*IIS*"}` <br>

Den ønskede Cve filen kan også lagres lokalt så er den lett tilgjengelig for å les.

`New-Item -Path C:\Cve -Value "Cve1" -ItemType File`
`Get-MsrcCvrfDocument -ID $monthOfInterest -Verbose | Get-MsrcSecurityBulletinHtml | Out-File -FilePath "C:\Cve\Cve1.html" -Force`


## Konfigurering av FTP Server

### Installasjonen av FTP tjenesten. <h5>[1](https://4sysops.com/archives/install-and-configure-an-ftp-server-with-powershell/) [2](https://www.windowscentral.com/how-set-ftp-server-windows-10) </h5>

I denne gjennomgangen fokuserer vi på å få tjenesten installert, og alle kodelinjene nedenfor er nødvendige å ha med for å få FTP siden til å fungere. Kommandoene skal også brukes med **Powershell 5** siden mange av funkjsonene støttes ikke av PS-Core. 

Vi starter med å installere *IIS* og *FTP* moduler. De opererer sammen, og FTP serveren administreres som en del av *IIS*.

`Install-WindowsFeature -Name Web-Server -IncludeManagementTools` <br>
`Install-WindowsFeature -Name Web-Ftp-Server -IncludeAllSubFeature -IncludeManagementTools`  <br>
`Import-Module WebAdministration` <br> <br>

Så installerer vi FTP-website.

`if (!(Test-Path C:\Rootpath)) { New-Item -Path C:\Rootpath -ItemType Directory }`
`New-WebFtpSite -Name "MyFTP" -PhysicalPath C:\Rootpath -Port 21 -IPAddress ServerenIPaddress -HostHeader MyFTP.com -Force` //Merk at jeg prøver å skrive koden i en linje for å minke størrelsen på rapporten <br> <br>

Vi må også tillate tilkoblingen av [controlChannel](https://docs.microsoft.com/en-us/iis/configuration/system.applicationhost/sites/sitedefaults/ftpserver/security/ssl) og [DataChannel](https://docs.microsoft.com/en-us/iis/configuration/system.applicationhost/sites/sitedefaults/ftpserver/security/datachannelsecurity) gjennom en sikker tilkobling

`$FTPPath = "IIS:\Sites\MyFTP"` <br>
`$SSL = @(`
   ` 'ftpServer.security.ssl.controlChannelPolicy',`
  `  'ftpServer.security.ssl.dataChannelPolicy'`
`)` <br>
`$SSL | ForEach-Object {Set-ItemProperty -Path $FTPPath -Name $_ -Value 0 }` /# "0" Står for [Allow](https://docs.microsoft.com/en-us/iis/configuration/system.applicationhost/sites/sitedefaults/ftpserver/security/ssl) <br> <br>


Etter at tjenesten er installert, må vi tillate klientene å autentisere seg ved å aktivere *basicAuthentication* i instilligene på FTP-siden. Man kan finne denne innistillingen i IIS(app)\Sites\MyFTP\authentication

`Set-ItemProperty -Path "IIS:\Sites\MyFTP" -Name 'ftpServer.security.authentication.basicAuthentication.enabled' -Value $True` <br><br>

Til slutt må vi velge hvem vi skal gi tilgangsrettigheter. Vi kan opprette en *local-group* og velge hvem som skal få tilgang via å melde dem inn i gruppen, men jeg gav det til administratorene for å minske kodestørrelsen.

`Add-WebConfiguration -Location 'IIS:\Sites\MYFTP' -Filter '/system.ftpserver/security/authorization' -Value @{ accesstype = 'Allow'; roles = 'Administrators'; permissions = 3 }`    
// "Permission=3" står for "Read", "Write", "Execute" <br>

Merk at FTP sida kan administreres på samme måte med kommandoene *Set-ItemProperty* og *Add-WebConfiguration*. Man må bare sette opp stien til [innstillingene](https://docs.microsoft.com/en-us/iis/configuration/system.ftpserver/) og verdien av innstillingen.

### Oppdatering av tjenesten

Som det ble nevnt innledningsvis er det Microsoft som er utviklere av denne tjenesten, og de tar ansvaret for eventuelle oppdateringer. Tjenestene (Windows-Features) får sine oppdateringer gjennom *Windows Update*, men den kan også administreres ved bruk av powershell. Med module *PSWindowsUpdate* kan man få de nødvendige kommandoene som kan brukes til administrasjonen. <br> <br>


Vi starter med å installere og importere denne modulen. <br>
`Install-Module -Name PSWindowsUpdate` <br>
`Import-Module -Name PSWindowsUpdate` <br>
`Get-WindowsUpdate` // For å få de tilgjenlige oppdateringer <br>
<br>

Det kan installeres en spesifikk oppdatering via sine [KBArticle ID](https://www.catalog.update.microsoft.com/Search.aspx?q=FTP). <br>
`$KBID = "specify the KBID From get-windowsupdate command"` <br> <br>

Man kan også installere oppdateringer som bare gjelder for "IIS" og "FTP". <br>
`Install-WindowsUpdate -Title "*FTP*"` <br>
`Install-WindowsUpdate -Title "*IIS*` <br> <br> 

### Avinstallering av tjenesten 

Avinstalleringsprosessen er det motsatte av installeringen, da trenger vi å avinstallere FTP siden og tjenesten vi har opprettet. <br>

`$Website="MYFTP"` <br>
`$Path = "C:\FTPRoot"` <br>

`Get-Website | Where-Object {$_.name -match $Website} | Remove-Website` <br>
`Get-item $Path | Remove-Item -Force -Recurse` <br>
`Uninstall-WindowsFeature -Name Web-Ftp-Server` <br>


## Refleksjon

Oppgaven var litt forvirrende til å begynne med, siden det var tusenvis av programvarer man kunne velge fra. Da valgte jeg å forholde meg til de appene som var listet opp i oppgaven. Jeg tenkte også at jeg ville ha lært lite dersom jeg valgte en vanlig programvare siden det er noe jeg har jobbet med tidligere i den første øvingen. Derfor rettet jeg meg mot installering av tjenester som DNS, FTp, DHCP osv. Til slutt virket installering av "Microsoft FTP server" interessant, lærerikt, og noe som jeg kan benytte. <br>
Koding av installering og oppdatering av denne tjennesten tok litt lengere tid enn det jeg hadde forventet, siden denne tjenesten trengte en minstekrav konfigurering, i tillegg til at det føltes gøy å eksperimentere litt.<br>
I starten av å konfigurere oppdateringen av denne tjenesten jobbet jeg med *Wsus*, men installeringen av denne tjenesten krevde installering av en server. Etter å ha installert denne tjenesten, krevde det å kjøre videre en "Post-launch". Dette skulle skje automatisk, men installeringen forsvant underveis uten å få se hva error-meldingen var, og derfor brukte jeg *PSWindowsUpdate* istedet. Etterhvert, oppdaget jeg at problemet lå i selve operativsystemet og installasjonen gikk som den skulle i en annen windows server vm. <br>
Resultatet av gjøre denne oppgaven ble det samme som jeg trodde, og det var at jeg lærte mye mer om tjenester og servere og hvordan de fungerer, noe som skal bli hjelpsomt i arbeidslivet. <br>
Notis: Det føltes unødvendig å ha med gitlabben siden jeg kunne krympe koden i rapporten uansett. Ulempen var at jeg måtte fjerne variablene fra koden. <br> 