Red: [
    Title: "export module for logutils"
    File: %redlinks.red
    Version: "0.0.1"
    License: "MIT"
    Description: "this module allows logs to be exported to .log files in _temp"
]

; -- importing globals --
do %../globals.red

log-to-file: func [level msg] [
    out: rejoin [
        "[" level "] " msg LF
    ]

    write/append to-file rejoin [temp-dir "/" app-name ".log"] out
]