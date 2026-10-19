; Inno Setup script for the Windows installer.
; Compile with:  iscc /DAppVersion=1.0.0 installer\windows\setup.iss
; Run it after `flutter build windows --release`: it packages that build output.

; Passed by the command line (/DAppVersion=...). The fallback keeps a bare local run working.
#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

#define AppName "Giftcards Management App"
#define AppPublisher "bbesaut"
#define AppExeName "gift_card_front.exe"

[Setup]
; Identifies this application to Windows across versions (upgrade in place, uninstall entry).
; Generated once, never change it. The doubled "{" is Inno Setup's escape for a literal brace.
AppId={{95742F98-8F4F-496A-B211-31961B0AF8B6}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}

; {autopf} is "Program Files" for an all-users install, and the per-user programs folder otherwise.
DefaultDirName={autopf}\{#AppName}
DisableProgramGroupPage=yes

; Per-user install by default (no admin rights needed); the user can choose all-users in a dialog.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

; Flutter desktop requires Windows 10 or later.
MinVersion=10.0

; Upgrading while the app is running: close it first so its files can be replaced.
CloseApplications=yes
RestartApplications=no

; 64-bit only: Flutter's Windows build is x64.
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

; Entry in "Installed apps": icon shown next to the uninstall button.
UninstallDisplayIcon={app}\{#AppExeName}

; Where the installer is written (relative to this script) and how it is named.
OutputDir=..\..\dist
OutputBaseFilename=gift-card-front-{#AppVersion}-windows-x64-setup

Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Tasks]
; Unchecked by default: a desktop icon is the user's choice.
Name: "desktopicon"; Description: "Create a &desktop shortcut"; Flags: unchecked

[Files]
; Copy the whole Flutter build output (exe, dlls, data folder) next to each other.
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
; Offer to launch the app at the end of the wizard (not when installing silently).
Filename: "{app}\{#AppExeName}"; Description: "Launch {#AppName}"; Flags: nowait postinstall skipifsilent
