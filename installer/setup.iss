#define MyAppName "MOV to MP4 Converter"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Your Name"
#define MyAppURL "https://github.com/<your-username>/<repo-name>"

[Setup]
AppId={{B7B8D9A1-6C2E-4F3B-9A1D-3E7F5C8A2B10}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={localappdata}\Programs\MovToMp4Converter
DisableProgramGroupPage=yes
; Installs per-user (HKCU only) so no admin rights are required
PrivilegesRequired=lowest
OutputDir=Output
OutputBaseFilename=MovToMp4Converter-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\convert-to-mp4.bat
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "contextmenu"; Description: "Add ""Convert to MP4"" to the right-click menu for .mov files"; GroupDescription: "Context menu integration:"
Name: "othermenu"; Description: "Also add it for .avi, .mkv, .wmv and .flv files"; GroupDescription: "Context menu integration:"; Flags: unchecked

Name: "quality_fast"; Description: "Fast (smaller file, lower quality, quick conversion)"; GroupDescription: "Default conversion quality:"; Flags: exclusive unchecked
Name: "quality_balanced"; Description: "Balanced (recommended)"; GroupDescription: "Default conversion quality:"; Flags: exclusive
Name: "quality_high"; Description: "High quality (larger file, slower conversion)"; GroupDescription: "Default conversion quality:"; Flags: exclusive unchecked

[Files]
Source: "..\src\convert-to-mp4.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion

[Registry]
; --- .mov (primary target) ---
Root: HKCU; Subkey: "Software\Classes\SystemFileAssociations\.mov\shell\ConvertToMP4"; ValueType: string; ValueName: ""; ValueData: "Convert to MP4"; Tasks: contextmenu; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\SystemFileAssociations\.mov\shell\ConvertToMP4"; ValueType: string; ValueName: "Icon"; ValueData: "shell32.dll,-16769"; Tasks: contextmenu
Root: HKCU; Subkey: "Software\Classes\SystemFileAssociations\.mov\shell\ConvertToMP4\command"; ValueType: string; ValueName: ""; ValueData: """{app}\convert-to-mp4.bat"" ""%1"""; Tasks: contextmenu; Flags: uninsdeletekey

; --- .avi ---
Root: HKCU; Subkey: "Software\Classes\SystemFileAssociations\.avi\shell\ConvertToMP4"; ValueType: string; ValueName: ""; ValueData: "Convert to MP4"; Tasks: othermenu; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\SystemFileAssociations\.avi\shell\ConvertToMP4"; ValueType: string; ValueName: "Icon"; ValueData: "shell32.dll,-16769"; Tasks: othermenu
Root: HKCU; Subkey: "Software\Classes\SystemFileAssociations\.avi\shell\ConvertToMP4\command"; ValueType: string; ValueName: ""; ValueData: """{app}\convert-to-mp4.bat"" ""%1"""; Tasks: othermenu; Flags: uninsdeletekey

; --- .mkv ---
Root: HKCU; Subkey: "Software\Classes\SystemFileAssociations\.mkv\shell\ConvertToMP4"; ValueType: string; ValueName: ""; ValueData: "Convert to MP4"; Tasks: othermenu; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\SystemFileAssociations\.mkv\shell\ConvertToMP4"; ValueType: string; ValueName: "Icon"; ValueData: "shell32.dll,-16769"; Tasks: othermenu
Root: HKCU; Subkey: "Software\Classes\SystemFileAssociations\.mkv\shell\ConvertToMP4\command"; ValueType: string; ValueName: ""; ValueData: """{app}\convert-to-mp4.bat"" ""%1"""; Tasks: othermenu; Flags: uninsdeletekey

; --- .wmv ---
Root: HKCU; Subkey: "Software\Classes\SystemFileAssociations\.wmv\shell\ConvertToMP4"; ValueType: string; ValueName: ""; ValueData: "Convert to MP4"; Tasks: othermenu; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\SystemFileAssociations\.wmv\shell\ConvertToMP4"; ValueType: string; ValueName: "Icon"; ValueData: "shell32.dll,-16769"; Tasks: othermenu
Root: HKCU; Subkey: "Software\Classes\SystemFileAssociations\.wmv\shell\ConvertToMP4\command"; ValueType: string; ValueName: ""; ValueData: """{app}\convert-to-mp4.bat"" ""%1"""; Tasks: othermenu; Flags: uninsdeletekey

; --- .flv ---
Root: HKCU; Subkey: "Software\Classes\SystemFileAssociations\.flv\shell\ConvertToMP4"; ValueType: string; ValueName: ""; ValueData: "Convert to MP4"; Tasks: othermenu; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\SystemFileAssociations\.flv\shell\ConvertToMP4"; ValueType: string; ValueName: "Icon"; ValueData: "shell32.dll,-16769"; Tasks: othermenu
Root: HKCU; Subkey: "Software\Classes\SystemFileAssociations\.flv\shell\ConvertToMP4\command"; ValueType: string; ValueName: ""; ValueData: """{app}\convert-to-mp4.bat"" ""%1"""; Tasks: othermenu; Flags: uninsdeletekey

[Code]
procedure CreateConfigFile;
var
  Quality: String;
  ConfigPath: String;
  Lines: TArrayOfString;
begin
  if WizardIsTaskSelected('quality_fast') then
    Quality := 'fast'
  else if WizardIsTaskSelected('quality_high') then
    Quality := 'high'
  else
    Quality := 'balanced';

  ConfigPath := ExpandConstant('{app}\config.ini');
  SetArrayLength(Lines, 2);
  Lines[0] := '[Settings]';
  Lines[1] := 'Quality=' + Quality;
  SaveStringsToFile(ConfigPath, Lines, False);
end;

function IsFfmpegInstalled: Boolean;
var
  ResultCode: Integer;
begin
  Result := Exec('cmd.exe', '/c where ffmpeg >nul 2>nul', '', SW_HIDE,
    ewWaitUntilTerminated, ResultCode) and (ResultCode = 0);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    CreateConfigFile;
    if not IsFfmpegInstalled then
    begin
      MsgBox(
        'ffmpeg was not found on your system PATH.' + #13#10 + #13#10 +
        'The context menu entry has been installed, but conversions will fail ' +
        'until ffmpeg is installed.' + #13#10 + #13#10 +
        'Install it with "winget install ffmpeg", then reopen Explorer.',
        mbInformation, MB_OK);
    end;
  end;
end;
