[Setup]
AppId={{C6D0A0F4-86A9-4C53-8C0F-7FAE6E5F9CF9}
AppName=CodeForge
AppVersion=1.0.0
AppPublisher=CodeForge Dev
AppPublisherURL=https://github.com/zhbfrorum/CodeForge
AppSupportURL=https://github.com/zhbfrorum/CodeForge/issues
AppUpdatesURL=https://github.com/zhbfrorum/CodeForge/releases
DefaultDirName={autopf}\CodeForge
DefaultGroupName=CodeForge
SetupIconFile=..\windows\runner\resources\app_icon.ico
OutputBaseFilename=CodeForge-Setup
OutputDir=..\dist\windows-installer
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\CodeForge"; Filename: "{app}\mobile_app.exe"
Name: "{commondesktop}\CodeForge"; Filename: "{app}\mobile_app.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\mobile_app.exe"; Description: "Launch CodeForge"; Flags: nowait postinstall skipifsilent
