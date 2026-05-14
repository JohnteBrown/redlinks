Red [
    Title: "Redlinks CLI Interface"
    File: %redlinks.red
    Version: "0.0.1"
    License: "MIT"
    Description: "This is the main CLI interface for Redlinks."
]

; -- includes --
#include %globals.red
#include %lib/logutils.red
;#include %lib/doctorutils.red


load-links: func [/local content line name path links] [
    links: make map! []

    if not exists? links-file [return links]

    content: read links-file

    foreach line split content LF [
        line: trim line

        if all [
            not empty? line
            find line "="
        ][
            set [name path] split line "="
            put links trim name trim path
        ]
    ]

    return links
]


save-links: func [links [map!]] [
    out: copy ""

    foreach key keys-of links [
        append out rejoin [
            key "="
            select links key
            lf
        ]
    ]

    write links-file out
]


args: system/script/args

if none? args [
    log-info "Usage: redlinks <command>"
    quit
]

if string? args [
    args: split args " "
]

if not block? args [
    log-error ["Unexpected args format:" mold args]
    quit
]

command: first args
params: next args


if command = "add" [
    if not params [
        log-info "Usage: redlinks add <name> <path>"
        quit
    ]

    name: first params
    path: second params

    links: load-links
    put links name path
    save-links links

    print ["Added:" name "->" path]
]


if command = "run" [
    links: load-links
    name: first params

    if not find links name [
        log-error ["Unknown command:" name]
        quit
    ]

    call select links name
]


if command = "list" [
    links: load-links

    foreach key keys-of links [
        print [key "->" select links key]
    ]
]

if command = "remove" [
    links: load-links
    name: first params

    if not find links name [
        log-error ["Unknown command:" name]
        quit
    ]

    remove links name
    save-links links

    print ["Removed:" name]
]

; -- Doctor command --
; Work in progress, not fully implemented yet.

; if command = "doctor" [
;
;    log-info "Running Redlinks diagnostics..."
;
;    warnings: 0
;    failures: 0
;
;
;    either command-exists? "red" [
;        doctor-ok "red executable found"
;    ][
;        doctor-fail "red executable missing"
;        failures: failures + 1
;    ]
;
;
;    either command-exists? "redc" [
;        doctor-ok "redc executable found"
;    ][
;        doctor-fail "redc executable missing"
;        failures: failures + 1
;    ]
;
;
;    either exists? %keys/links.txt [
;        doctor-ok "links.txt exists"
;    ][
;        doctor-fail "links.txt missing"
;        failures: failures + 1
;    ]
;
;
;    either exists? %.buildignore [
;        doctor-ok ".buildignore found"
;    ][
;        log-warning ".buildignore missing"
;        warnings: warnings + 1
;    ]
;
;
;    either exists? %bin/ [
;        doctor-ok "bin directory exists"
;    ][
;        log-warning "bin directory missing"
;        warnings: warnings + 1
;    ]
;
;
;    print ""
;
;    either failures > 0 [
;
;        log-error rejoin [
;            "Doctor completed with "
;            failures
;            " failure(s) and "
;            warnings
;            " warning(s)."
;        ]
;
;    ][
;
;        log-info rejoin [
;            "Doctor completed successfully with "
;            warnings
;            " warning(s)."
;        ]
;    ]
; ]