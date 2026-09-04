Red [
    Title: "Redlinks Globals"
    File: %globals.red
    Version: "0.0.1"
    License: "MIT"
    Description: "This file contains global variables and helper functions for Redlinks."
]

; =====
; Global App data
; =====

app-name: "Redlinks"
app-version: "0.1.0"

db-file: %keys/keys.sqlite3
sql-dir: %keys/sql
sqlite-executable: "C:\ProgramData\chocolatey\bin\sqlite3.exe"

; =====
; GlobalHelpers
; =====

file-exists?: func [path] [
    exists? to-file path
]

read-safe: func [file] [
    either exists? file [
        read file
    ] [
        none
    ]
]

trim-lines: func [text] [
    collect [
        foreach line split text LF [
            line: trim line

            if not empty? line [
                keep line
            ]
        ]
    ]
]

sql-script: func [name [string!]] [
    to-file rejoin [to-local-file sql-dir "/" name]
]

escape-sql-value: func [value [string!]] [
    replace/all value "'" "''"
]

render-sql-template: func [template-name [string!] name [string!] path [string!] /local template content] [
    template: read sql-script template-name
    content: copy template

    if not empty? name [
        content: replace/all content "__NAME__" escape-sql-value name
    ]

    if not empty? path [
        content: replace/all content "__PATH__" escape-sql-value path
    ]

    content
]