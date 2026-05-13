Red [
    Title: "Redlinks Logging Utilities"
    File: %logutils.red
    Version: "0.0.2"
    License: "MIT"
]

; -- ANSI Color Values --
reset:     "^[[0m"
red:       "^[[31m"
green:     "^[[32m"
yellow:    "^[[33m"
blue:      "^[[34m"
gray:      "^[[90m"


log: func [level color msg] [
    print rejoin [
        color "[" level "] " reset msg
    ]
]


; -- Level wrappers --

log-info: func [msg] [
    log "INFO" blue msg
]

log-error: func [msg] [
    log "ERROR" red msg
]

log-warning: func [msg] [
    log "WARNING" yellow msg
]

log-debug: func [msg] [
    log "DEBUG" green msg
]