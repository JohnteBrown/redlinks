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

initialize-db: func [] [
    none
]

add-link: func [name [string!] path [string!]] [
    call rejoin [
        "powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File helper/sqlite-links.ps1 -Action add -Name '"
        name
        "' -Path '"
        path
        "'"
    ]
]

remove-link: func [name [string!]] [
    call rejoin [
        "powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File helper/sqlite-links.ps1 -Action remove -Name '"
        name
        "'"
    ]
]

lookup-link: func [name [string!]] [
    output-file: to-file %keys/.query.out

    call rejoin [
        "powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File helper/sqlite-links.ps1 -Action lookup -Name '"
        name
        "' -OutputFile '"
        to-local-file output-file
        "'"
    ]

    result: read-safe output-file
    delete output-file
    trim result
]

load-links: func [/local output output-file line name path links] [
    links: make map! []
    output-file: to-file %keys/.query.out

    call rejoin [
        "powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File helper/sqlite-links.ps1 -Action list -OutputFile '"
        to-local-file output-file
        "'"
    ]
    output: read-safe output-file
    delete output-file

    if none? output [return links]

    foreach line split output LF [
        line: trim line

        if not empty? line [
            set [name path] split line tab

            if all [
                not empty? name
                not empty? path
            ][
                put links trim name trim path
            ]
        ]
    ]

    links
]

save-links: func [links [map!]] [
    none
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

initialize-db

command: first args
params: next args

if command = "add" [
    if not params [
        log-info "Usage: redlinks add <name> <path>"
        quit
    ]

    name: first params
    path: second params
    add-link name path
    print ["Added:" name "->" path]
]

if command = "run" [
    name: first params
    target: lookup-link name

    if empty? target [
        log-error ["Unknown command:" name]
        quit
    ]

    call target
]

if command = "list" [
    links: load-links

    foreach key keys-of links [
        print [key "->" select links key]
    ]
]

if command = "remove" [
    name: first params

    if empty? lookup-link name [
        log-error ["Unknown command:" name]
        quit
    ]

    remove-link name
    print ["Removed:" name]
]

if command = "help" [
    log-info "Usage: redlinks <add|run|list|remove>"
]