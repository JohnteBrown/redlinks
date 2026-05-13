Red [
    Title: "Redlinks Globals"
    File: %globals.red
    Version: "0.0.1"
    License: "MIT"
    Description: "This file contains global variables and helper functions for Redlinks."
]

; =====
; Global Macros
; =====

#define _TEMP "C:\Users\\AppData\Local\Temp"

; =====
; Global App data
; =====

app-name: "Redlinks"
app-version: "0.0.1"

links-file: %keys/links.txt
settings-file: %conf/settings.ini

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