; Redlinks installer script
; blah blah blah, follow the MIT license, etc.

Name "Redlinks"
OutFile "Redlinks-Setup.exe"

InstallDir "$PROGRAMFILES\Redlinks"

Page directory
Page instfiles

;--------------------------------
; Installation
;--------------------------------

Section "Install"

    ; Main application
    SetOutPath "$INSTDIR"
    File "..\bin\redlinks.exe"

    ; Database
    SetOutPath "$INSTDIR\keys"
    File "..\keys\keys.sqlite3"

    ; SQL files
    SetOutPath "$INSTDIR\keys\sql"
    File /r "..\keys\sql\*.*"

    ; Logs directory
    CreateDirectory "$INSTDIR\logs"

    ; Powershell Helpers
    SetOutPath "$INSTDIR\helper"
    File "..\helper\sqlite-links.ps1"

    ; LibRedRT
    SetOutPath "$INSTDIR"
    File "..\bin\*.dll"
    File "..\bin\*.red"
    File "..\bin\*.r"

    ; Desktop shortcut
    CreateShortcut "$DESKTOP\Redlinks.lnk" "$INSTDIR\redlinks.exe"

    ; Uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd


;--------------------------------
; Uninstallation
;--------------------------------

Section "Uninstall"

    ; Remove desktop shortcut
    Delete "$DESKTOP\Redlinks.lnk"

    ; Remove application
    Delete "$INSTDIR\redlinks.exe"

    ; Remove database
    Delete "$INSTDIR\keys\keys.sqlite3"

    ; Remove Powershell helper

    ; Remove LibRedRT files
    Delete "$INSTDIR\*.dll"
    Delete "$INSTDIR\*.red"
    Delete "$INSTDIR\*.r"

    ; Remove everything under the SQL directory
    RMDir /r "$INSTDIR\keys\sql"

    ; Remove directories created by the installer
    RMDir "$INSTDIR\keys"
    RMDir "$INSTDIR\logs"
    RMDir "$INSTDIR\helper"

    ; Remove uninstaller
    Delete "$INSTDIR\Uninstall.exe"

    ; Finally remove the installation directory
    RMDir "$INSTDIR"

SectionEnd