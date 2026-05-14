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

    File "keys\links.txt"

    CreateDirectory "$INSTDIR\logs"

    CreateShortcut "$DESKTOP\Redlinks.lnk" "$INSTDIR\redlinks.exe"

    WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd



Section "Uninstall"

    Delete "$INSTDIR\redlinks.exe"

    Delete "$INSTDIR\keys\links.txt"

    Delete "$INSTDIR\Uninstall.exe"

    Delete "$DESKTOP\Redlinks.lnk"

    RMDir "$INSTDIR\keys"
    RMDir "$INSTDIR\logs"
    RMDir "$INSTDIR"

SectionEnd