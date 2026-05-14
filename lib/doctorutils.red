Red [
    Title: "Redlinks doctor utilities"
    File: %doctorutils.red
    Version: "0.0.1"
    License: "MIT"
    Description: "This file contains utility functions for the Redlinks doctor command."
]

; -- ANSI Color Values --
red:       "^[[31m"
green:     "^[[32m"


; -- Symbols --
check-mark: "^[[32m✓^[[0m"
cross-mark: "^[[31m✗^[[0m"


doctor: func [level color msg] [
    print rejoin [
        color "[" level "] " reset msg
    ]
]

doctor-ok: func [msg] [
    doctor "OK" green msg
]

doctor-fail: func [msg] [
    doctor "FAIL" red msg
]