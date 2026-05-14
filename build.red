Red [
    Title: "Redlinks Build Script"
    File: %build.red
    Version: "0.0.5"
    License: "MIT"
    Description: "Builds the Redlinks CLI executable & installer."
]

do %globals.red
do %lib/logutils.red


; ============
; configure this monstrosity here
; ============

output: %bin/redlinks.exe
buildignore-file: %.buildignore
build-helper: %helper/build-helper.ps1


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
        if file = ignored [
            return true
        ]
    ]

    false
]


run-cmd: func [cmd [string!]] [
    call/wait cmd
]


start: func [] [

    either empty? buildignore [
        log-info "No ignored files loaded."
    ][
        log-warning rejoin [
            "Ignoring files: "
            mold buildignore
        ]
    ]

    wait 1
]


compile-file: func [file [file!]] [

    log-info rejoin [
        "Compiling: "
        form file
    ]

    if not exists? %bin/ [
        make-dir %bin/
    ]

    cmd: rejoin [
        "powershell -ExecutionPolicy Bypass -File "
        form build-helper
        " "
        form file
        " "
        form output
    ]

    log-system rejoin [
        "Running build helper: "
        cmd
    ]

    run-cmd cmd
]


; ============
; Build
; ============

build: func [/local entry-file] [

    log-info "Build process starting..."
    wait 1

    start

    entry-file: %redlinks.red

    if should-ignore? entry-file [
        log-error "Entrypoint is ignored by .buildignore"
        quit
    ]

    log-info rejoin [
        "Building executable from "
        form entry-file
    ]

    compile-file entry-file

    either exists? output [

        log-debug rejoin [
            "Build complete: "
            form output
        ]

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