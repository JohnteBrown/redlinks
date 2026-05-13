Red [
    Title: "Redlinks Build Script"
    File: %build.red
    Version: "0.0.2"
    License: "MIT"
    Description: "Builds the Redlinks CLI executable & installer."
]

; -- includes --
do %globals.red ; use globals 
do %lib/logutils.red ; use logging utilities


; ============
; Build Macros 
; ============

#define _REDC "redc"
#define _COMPILE "-c"
#define _LINK "-l"
#define _OUTPUT %redlinks.exe


; ============
; Build config
; ============

buildignore-file: %.buildignore
output: _OUTPUT


; ============
; Build Rules
; ============

load-buildignore: func [] [
    ignored: make block! []

    if not exists? buildignore-file [
        log-warning "No .buildignore found — continuing without ignore rules"
        return ignored
    ]

    content: read buildignore-file

    foreach line split content LF [
        line: trim line

        if all [
            not empty? line
            not find line "#"
        ][
            append ignored to-file line
        ]
    ]

    return ignored
]


buildignore: load-buildignore


; ============
; Helper Services
; ============

should-ignore?: func [file] [
    foreach item buildignore [
        if find form file form item [
            return true
        ]
    ]
    false
]


run-cmd: func [args] [
    call rejoin args
]


; ============
; Logging Services
; ============

start: func [] [
    log-warning rejoin [
        "Ignoring files from .buildignore: " mold buildignore
    ]
    wait 1
]


; ============
; Build Steps
; ============

build: func [] [

    log-info "Build process starting..."
    wait 1

    start


    ; ============
    ; Sources Map
    ; ============

    sources: [
        %lib/global.red
        %lib/logutils.red
        %redlinks.red
    ]


    ; ============
    ; Build config
    ; ============

    foreach src sources [

        if should-ignore? src [
            log-warning rejoin ["Skipping ignored file: " src]
            continue
        ]

        log-info rejoin ["Compiling: " src]

        run-cmd [
            _REDC " "
            _COMPILE " "
            form src
        ]
    ]


   ; ============
   ; Output
   ; ============

    if exists? output [
        delete output
    ]

    if exists? %redlinks.exe [
        rename %redlinks.exe output
    ]

    log-debug rejoin ["Build complete: " output]

    wait 2
    print "Exit in 2 seconds..."
    wait 2
    quit
]