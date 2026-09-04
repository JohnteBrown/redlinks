; Redlinks installer script
; blah blah blah, follow the MIT license, etc etc

OutFile "Redlinks-Setup.exe"

InstallDir "$PROGRAMFILES\Redlinks"

Page directory
Page instfiles


Section "Install"

    SetOutPath "$INSTDIR"

    File "bin\redlinks.exe"

    SetOutPath "$INSTDIR\keys"

    File "keys\keys.sqlite3"

    SetOutPath "$INSTDIR\keys\sql"
    File /r "keys\sql\*.*"

    CreateDirectory "$INSTDIR\logs"

    CreateShortcut "$DESKTOP\Redlinks.lnk" "$INSTDIR\redlinks.exe"

    WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd



Section "Uninstall"

    Delete "$INSTDIR\redlinks.exe"

    Delete "$INSTDIR\keys\keys.sqlite3"
    Delete "$INSTDIR\keys\sql\*.*"

    Delete "$INSTDIR\Uninstall.exe"

    Delete "$DESKTOP\Redlinks.lnk"

    RMDir "$INSTDIR\keys"
    RMDir "$INSTDIR\logs"
    RMDir "$INSTDIR"

SectionEnd