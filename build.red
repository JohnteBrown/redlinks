Red [
    Title: "Redlinks Build Script"
    File: %build.red
    Version: "0.0.4"
    License: "MIT"
    Description: "Builds the Redlinks CLI executable & installer."
]
    
; Note: I am truly sorry :')
; for some reason this build script will fail I will fix this at a later date, though I am open to PRs if you want to help out

do %globals.red
do %lib/logutils.red

; ============
; Build Variables
; ============

redc: "redc"
output: %bin/redlinks.exe
buildignore-file: %.buildignore

; ============
; Build Rules
; ============

load-buildignore: func [/local ignored content line] [
    ignored: make block! []

    if not exists? buildignore-file [
        log-warning "No .buildignore found, continuing without ignore rules."
        return ignored
    ]

    content: read buildignore-file

    foreach line split content lf [
        line: trim line

        if all [
            not empty? line
            line/1 <> #"#"
        ][
            append ignored to-file line
        ]
    ]

    ignored
]

buildignore: load-buildignore

should-ignore?: func [file] [
    foreach ignored buildignore [
        if file = ignored [return true]
    ]
    false
]

run-cmd: func [cmd [block!]] [
    call/wait trim rejoin cmd
]

start: func [] [
    either empty? buildignore [
        log-info "No ignored files loaded."
    ][
        log-warning rejoin ["Ignoring files: " mold buildignore]
    ]
    wait 1
]

compile-file: func [file [file!]] [
    log-info rejoin ["Compiling: " form file]

    run-cmd reduce [
        redc " -c -t MSDOS " output " " file
    ]
]

build: func [/local entry-file] [
    log-info "Build process starting..."
    wait 1

    start

    entry-file: %redlinks.red

    if should-ignore? entry-file [
        log-error "Entrypoint is ignored by .buildignore"
        quit
    ]

    log-info rejoin ["Building executable from " form entry-file]

    compile-file entry-file

    either exists? output [
        log-debug rejoin ["Build complete: " form output]
    ][
        log-error "Build failed: output executable was not generated."
        quit
    ]

    wait 2
    print "Exit in 2 seconds..."
    wait 2
    quit
]

; build that mf cuzo
build