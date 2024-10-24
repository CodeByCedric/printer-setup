# TODO's 

Doen de events zich bij iedereen en altijd voor? 
- Local: 105
- VM: 4107

Task Scheduler - vm_set_default_printer.ps1:
- General: Bij task scheduler (general) store password or not? denk van niet, want delay, zou dus niet nodig moeten zijn.
- Actions: is het argument -Windowstyle hidden nodig?
- Conditions Start the task only if the computer is on AC Power: aanvinken? in principe wel, want docking station voorziet stroom.

Task Scheduler - filesystemwatcher.ps1 
- De taak alleen starten als de computer op netstroom werkt?
- Stoppen als de computer op batterij gaat werken?

# Vereisten

Display met docking/ethernet voor een MAC-address.
OneDrive geïnstalleerd op een 'normale' wijze, dus geen afwijkend pad.

# Split PS Scripts via OneDrive
## MAC Address Display

Noteer het MAC-Address van het scherm. Deze is terug te vinden via de settings van het scherm onder de rubriek 'Information'. 

## Instellingen op het lokale toestel
### Event Viewer/Logboeken
Open Event Viewer als administrator
Open Windows Logs - System
Koppel het scherm los
Optioneel: wis de system logs (hiervoor moet je de applicatie als administrator hebben opgestart)
Koppel het scherm aan
Registreer het gepaste Event ID (bv. Event-ID: 105 Source: Kernel-Power)


### Task Scheduler/Taakplanner: Docking Event

In het rechtervak 'actions' een nieuwe taak creëren 'create task'

#### General
- Naam: "Docking Event"
- Description: "Run local_set_default_printer.ps1 in OneDrive printer folder to verify if mac-address of external display equals provided mac-address and update printerConfig.txt in same folder."
- Run whether using is logged on or not: aanvinken, op deze manier ziet de gebruiker geen powershell venster

#### Triggers
New
Begin the task: "On an event"
Settings: Basic
    Log: System
    Source: Kernel-Power
    Event ID: opgezocht ID via Event Viewer (bv. 105)

Delay Task for: 30 seconden

#### Actions
New
Action: Start a program
Program/script: powershell.exe
Add arguments (optional): 
    -displayMacAddress "[XX-XX-XX-XX-XX-XX]"
    -WindowStyle hidden

Waarbij wordt vervangen:
- het MAC-Address door het eerder genoteerde address van het scherm
- de username door de username van de eindgebruiker

#### Conditions

#### Settings
Aanvinken:
- If the task fails, restart every: 1 minute
- Attempt to restart up to: 3 times
- Stop the task if it runs longer than: 4 hours
- If the running task does not end when requested, force it to stop.

## Instellingen op de VM
### Script
Het script vereist de parameters:
- -$printerNameUpstairs
- -$printerNameDownstairs
### Event Viewer/Logboeken
Event opzoeken 





### Task Scheduler/Taakplanner: Set Default Printer; OF via FileSystemWatcher

TODO: enkel filesystemwatcher want events triggeren niet consistent

Open Event Viewer als administrator
Open Windows Logs - System
Koppel het scherm los
Optioneel: wis de system logs (hiervoor moet je de applicatie als administrator hebben opgestart)
Koppel het scherm aan
Registreer het gepaste Event ID (bv. Event-ID: 4107 Source: Display)

#### Task Scheduler/Taakplanner
##### General
Naam: Printer - Set Default
Beschrijving: Set default printer based on printer name in printerSysConfig.txt file on OneDrive.
When running the task, use the following user account:
- From this location: Entire Directory
- Enter the object name to select: adm account

##### Triggers

TODO: enkel filesystemwatcher

2 triggers? Logon & event

New
Begin the task: "On an event"
Settings: Basic
    Log: System
    Source: Display
    Event ID: opgezocht ID via Event Viewer (bv. 4107)

Delay Task for: 1 mminute

#### FileSystemWatcher
Algemeen:
(Voor volledige uitleg, zie uitlegger task scheduler op de lokale machine)
Naam: Printer FileSystemWatcher
Beschrijving: FileSystemWatcher to monitor OneDrive printer folder for changes to the printerConfig.txt and subsequently set the default printer.
Beveiligingsopties; andere gebruiker, adm account
Uitvoeren ongeacht of gebruiker wel of niet is aangemeld

Triggers: Bij aanmelden
Acties: Programma starten
Programma/script: powershell.exe
Parameters toevegen (optioneel): 
    -File "C:\Users\[USERNAME]\OneDrive - Office 365 GPI\printer\filesystemwatcher.ps1"

Voorwaarden:
- De taak alleen starten als de computer op netstroom werkt
- Stoppen als de computer op batterij gaat werken

Instellingen:
- Taak zo snel mogelijk uitvoeren, nadat een geplande activering is gemist.
- Als de taak mislukt, opnieuw starten elke: 1 minuut
- Maximaal aantal keren opnieuw starten: 3
- Stoppen als deze taak langer duurt dan: 1 dag
- De actieve taak geforceerd stoppen als deze niet aangevraagd stopt

# Advies voor de eindgebruiker

1. Het gebruik van de script valt niet onder de normale IT-werking

Dit betekent dat het gebruik van het script ten allen tijde kan worden stopgezet.

Het is gemaakt om jouw dagdagelijkse werking iets te vereenvoudigen, maar biedt geen garantie op onderhoud ervan, of een blijvende werking. 

2. Dit script kan voor problemen zorgen bij gebruik op verplaatsing

Omdat het script de default printer instelt o.b.v. de gebruikelijke werkplek, kan het voorvallen dat bij gebruik op verplaatsing, bv. het CPG, de default printer bij aan- en afkoppelen van een extern scherm, terug op deze van de wijk plaatst.


