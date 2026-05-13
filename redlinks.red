Red [
    Title: "Redlinks CLI Interface"
    File: %redlinks.red
    Version: "0.0.1"
    License: "MIT"
]

; -- includes --
#include %globals.red
#include %lib/logutils.red


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