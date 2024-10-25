# Vereisten

Display met docking/ethernet voor een MAC-address.
OneDrive geïnstalleerd op een 'normale' wijze, dus geen afwijkend pad.

Tip: om te troubleshooten, laat het script eens lopen met de parameter -Verbose

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
    -File "LOCATIE PSSCRIPT"
    -WindowStyle hidden

#### Conditions

#### Settings
Aanvinken:
- If the task fails, restart every: 1 minute
- Attempt to restart up to: 3 times
- Stop the task if it runs longer than: 4 hours
- If the running task does not end when requested, force it to stop.

## Instellingen op de VM
### Task Scheduler/Taakplanner
Er moeten drie taken worden aangemaakt waarbij enkel de eerste op een bepaalde event triggert.

De eerste taak wordt uitgevoerd als administrator en wijzigt de execution policy naar remote signed, en start de tweede taak. Dit laat toe dat er scripts door de gebruiker worden uitgevoerd. 

De tweede taak voert het script uit om de default printer aan te passen, en start de derde taak. 

De derde taak wijzigt de execution policy terug naar remote signed.

#### Taak 1:
##### Tabblad 'General'
Name: Printer (1) - Set-ExecutionPolicy and run script (Admin)
Description: Set execution policy to remote signed and start task "Printer (2) - Set Default Printer (User)"
Security options: change user en uitvoeren als admin (from this location aanpassen naar volledige directory) 
Run whether user is logged on or not.

##### Tabblad 'Triggers'
New:
Begin the task: At log on
Delay task for: 5 minuten? (om de logon tijd te geven, nodig voor taak 2)
Repeat task every: 10 minutes for a duration of 8 hours (of aanpassen naar iets dat wenselijk is)
Stop the task if it runs longer than 1 day (?)

##### Tabblad 'Actions' (in volgorde!)
New:
Action: Start a program
Program/script: powershell.exe
Add arguments: -Command "Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force -WindowStyle Hidden"

New:
Action: Start a program
Program/script: schtasks
Add arguments: /run /tn "Printer (2) - Set Default Printer (User)"

##### Tabblad 'Conditions'
Uitvinken: start the task only if the computer is on AC power.

##### Tabblad 'Settings'
Aanvinken: Run task as soon as possible after a scheduled start is missed
Aanvinken: if the task fails, restart every ... 

#### Taak 2:
##### Tabblad 'General'
Name: Printer (2) - Set Default Printer (User)
Description: Run powershell script to set default printer and start task "Printer (3) - Reset Execution Policy (Admin)"
Run only when the user is logged on (uit te  voeren als de eindgebruiker)

##### Tabblad 'Triggers'
Geen

##### Tabblad 'Actions' (in volgorde!)
New:
Action: Start a program
Program/script: powershell.exe
Add arguments: -File "C:\Users\602150536\OneDrive - Office 365 GPI\printer\VM-SetDefaultPrinter.ps1 -WindowStyle Hidden"

New:
Action: Start a program
Program/script: schtasks
Add arguments: /run /tn "Printer (3) - Reset Execution Policy (Admin)"

##### Tabblad 'Conditions'
Uitvinken: start the task only if the computer is on AC power.

##### Tabblad 'Settings'
Aanvinken: Run task as soon as possible after a scheduled start is missed
Aanvinken: if the task fails, restart every ... 

#### Taak 3:
##### Tabblad 'General'
Name: Printer (3) - Reset Execution Policy (Admin)
Description: Set execution policy to restricted
Security options: change user en uitvoeren als admin (from this location aanpassen naar volledige directory) 
Run whether user is logged on or not.

##### Tabblad 'Triggers'
Geen

##### Tabblad 'Actions' 
New:
Action: Start a program
Program/script: powershell.exe
Add arguments: -Command "Set-ExecutionPolicy Restricted-Scope LocalMachine -Force -WindowStyle Hidden"

##### Tabblad 'Conditions'
Uitvinken: start the task only if the computer is on AC power.

##### Tabblad 'Settings'
Aanvinken: Run task as soon as possible after a scheduled start is missed
Aanvinken: if the task fails, restart every ... 



# Advies voor de eindgebruiker

Het gebruik van de script valt niet onder de normale IT-werking

Dit betekent dat het gebruik van het script ten allen tijde kan worden stopgezet.

Het is gemaakt om jouw dagdagelijkse werking iets te vereenvoudigen, maar biedt geen garantie op onderhoud ervan, of een blijvende werking. 

