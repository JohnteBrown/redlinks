================================================
FILE: README.adoc
================================================
= Redlinks

Redlinks is a alternative environment variable registry for Windows. It provides a way to manage your envionment without potentially damaging or breaking actual environment variables, think of this as a PATH emulator, or a second PATH. not a actual tool that manages your Windows PATH. 

== Installation

1. Download the latest release from the [GitHub releases page]
2. Make the executable global
    - Move the executable to a directory in your PATH (e.g., `C:\Windows\System32` or `C:\Program Files\Redlinks`)
    - Alternatively, you can add the directory containing the executable to your PATH environment variable
3. Verify the installation by opening a new command prompt and running `redlinks --version`

== Usage

- To list all environment variables: `redlinks list`
- To add a new environment variable: `redlinks add <name> <value>`
- To remove an environment variable: `redlinks remove <name>`
- To update an existing environment variable: `redlinks update <name> <new_value>`


================================================
FILE: AGENTS.md
================================================
# Agent Instructions
&nbsp;This file acts as the primary index for AI agents operating in this codebase. 
Refer to the individual markdown files below for detailed specs, standards, and domain context.

## Context Blobs
* [System Overview](.github/instructions/blobs/context.general.blob.md) — General codebase information & summary.

## 💻 Development Standards
* [Coding Guidelines](.github/instructions/coding-standards.md) — Language conventions, file naming, and formatting rules.
* [Git & Workflow](.github/instructions/git-workflow.md) — Branch naming, PR conventions, and commit message formats.

## 🛠 Domain Context & Workflows
* [Building & CI/CD](.github/instructions/build-system-agent.md) — Environment configs, build steps, and pipeline rules.
---
### Quick Reference Commands
- Include `@.github/instructions/<filename>.md` in prompt context when working on specific features.


================================================
FILE: appveyor.yml
================================================
version: 1.0.{build}

image: Visual Studio 2022

branches:
  only:
    - master

skip_non_tags: true

environment:
  GH_TOKEN:
    secure: IjFa9PuaLV0Y9uAu85s+V+uj18dozWkwJUHEBmELMcQJyhZMHUqKpURk2xYasayR

build_script:
  - echo Building Redlinks...

  - ps: |
      Invoke-WebRequest `
        -Uri "https://static.red-lang.org/dl/win/red-toolchain-066.exe" `
        -OutFile "redc.exe"

  - dir redc.exe

  - redc.exe -c redlinks.red

artifacts:
  - path: redlinks.exe
    name: redlinks

deploy:
  - provider: GitHub
    release: redlinks-v$(APPVEYOR_BUILD_VERSION)
    description: "Redlinks build"
    auth_token: $(GH_TOKEN)
    artifact: redlinks
    draft: false
    prerelease: false
    on:
      APPVEYOR_REPO_TAG: true


================================================
FILE: build.red
================================================
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


================================================
FILE: globals.red
================================================
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


================================================
FILE: LICENSE
================================================
MIT License

Copyright (c) 2026 John Brown

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.



================================================
FILE: redlinks.red
================================================
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


================================================
FILE: .buildignore
================================================
build.red


================================================
FILE: helper/build-helper.ps1
================================================
param(
    [string]$InputFile,
    [string]$OutputFile
)

$redCompiler = "redc"

# I fucking guess $args is reserved in powershell, so we have to use a different variable name for the arguments array. What the fuck.
$args1 = @(
    "-o",
    $OutputFile,
    $InputFile
)

$process = Start-Process `
    -FilePath $redCompiler `
    -ArgumentList $args1 `
    -NoNewWindow `
    -Wait `
    -PassThru

if ($process.ExitCode -ne 0) {
    exit $process.ExitCode
}


================================================
FILE: helper/sqlite-links.ps1
================================================
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('initialize','add','remove','list','lookup')]
    [string]$Action,

    [string]$Name,
    [string]$Path,
    [string]$OutputFile
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$dbPath = Join-Path $repoRoot 'keys\keys.sqlite3'
$sqlDir = Join-Path $repoRoot 'keys\sql'

if (-not (Test-Path $dbPath)) {
    New-Item -ItemType File -Path $dbPath -Force | Out-Null
}

$createTable = Join-Path $sqlDir 'create-links-table.sql'
if (Test-Path $createTable) {
    & 'C:\ProgramData\chocolatey\bin\sqlite3.exe' $dbPath ".read '$createTable'" | Out-Null
}

function Escape-SqlValue {
    param([string]$Value)
    return $Value.Replace("'", "''")
}

switch ($Action) {
    'add' {
        $sql = Get-Content (Join-Path $sqlDir 'add-link.sql') -Raw
        $sql = $sql.Replace('__NAME__', (Escape-SqlValue $Name))
        $sql = $sql.Replace('__PATH__', (Escape-SqlValue $Path))
        & 'C:\ProgramData\chocolatey\bin\sqlite3.exe' $dbPath $sql | Out-Null
    }
    'remove' {
        $sql = Get-Content (Join-Path $sqlDir 'remove-link.sql') -Raw
        $sql = $sql.Replace('__NAME__', (Escape-SqlValue $Name))
        & 'C:\ProgramData\chocolatey\bin\sqlite3.exe' $dbPath $sql | Out-Null
    }
    'list' {
        $sql = Get-Content (Join-Path $sqlDir 'list-links.sql') -Raw
        if ($OutputFile) {
            & 'C:\ProgramData\chocolatey\bin\sqlite3.exe' $dbPath $sql | Out-File -Encoding utf8 $OutputFile
        } else {
            & 'C:\ProgramData\chocolatey\bin\sqlite3.exe' $dbPath $sql
        }
    }
    'lookup' {
        $sql = Get-Content (Join-Path $sqlDir 'find-link.sql') -Raw
        $sql = $sql.Replace('__NAME__', (Escape-SqlValue $Name))

        if ($OutputFile) {
            & 'C:\ProgramData\chocolatey\bin\sqlite3.exe' $dbPath $sql | Out-File -Encoding utf8 $OutputFile
        } else {
            & 'C:\ProgramData\chocolatey\bin\sqlite3.exe' $dbPath $sql
        }
    }
}



================================================
FILE: installer/installer.nsi
================================================
; Redlinks installer script
; blah blah blah, follow the MIT license, etc.

Name "Redlinks"
OutFile "Redlinks-Setup.exe"

InstallDir "$PROGRAMFILES\Redlinks"

Page directory
Page instfiles

;--------------------------------
; Installation
;--------------------------------

Section "Install"

    ; Main application
    SetOutPath "$INSTDIR"
    File "..\bin\redlinks.exe"

    ; Database
    SetOutPath "$INSTDIR\keys"
    File "..\keys\keys.sqlite3"

    ; SQL files
    SetOutPath "$INSTDIR\keys\sql"
    File /r "..\keys\sql\*.*"

    ; Logs directory
    CreateDirectory "$INSTDIR\logs"

    ; Powershell Helpers
    SetOutPath "$INSTDIR\helper"
    File "..\helper\sqlite-links.ps1"

    ; LibRedRT
    SetOutPath "$INSTDIR"
    File "..\bin\*.dll"
    File "..\bin\*.red"
    File "..\bin\*.r"

    ; Desktop shortcut
    CreateShortcut "$DESKTOP\Redlinks.lnk" "$INSTDIR\redlinks.exe"

    ; Uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd


;--------------------------------
; Uninstallation
;--------------------------------

Section "Uninstall"

    ; Remove desktop shortcut
    Delete "$DESKTOP\Redlinks.lnk"

    ; Remove application
    Delete "$INSTDIR\redlinks.exe"

    ; Remove database
    Delete "$INSTDIR\keys\keys.sqlite3"

    ; Remove Powershell helper

    ; Remove LibRedRT files
    Delete "$INSTDIR\*.dll"
    Delete "$INSTDIR\*.red"
    Delete "$INSTDIR\*.r"

    ; Remove everything under the SQL directory
    RMDir /r "$INSTDIR\keys\sql"

    ; Remove directories created by the installer
    RMDir "$INSTDIR\keys"
    RMDir "$INSTDIR\logs"
    RMDir "$INSTDIR\helper"

    ; Remove uninstaller
    Delete "$INSTDIR\Uninstall.exe"

    ; Finally remove the installation directory
    RMDir "$INSTDIR"

SectionEnd


================================================
FILE: keys/README.adoc
================================================
= SQLite-backed link storage

Redlinks now stores its link index in SQLite instead of the legacy plaintext key/value file.

The database lives at `keys/keys.sqlite3`, and the SQL command templates live under `keys/sql/`.
These SQL files are the pre-stored command definitions that the CLI reads and executes when it needs to add, remove, list, or resolve links.

This keeps the storage layer predictable and easy to extend while still remaining compatible with the system SQLite CLI installed via Chocolatey.


================================================
FILE: keys/sql/add-link.sql
================================================
INSERT INTO links (name, path)
VALUES ('__NAME__', '__PATH__')
ON CONFLICT(name) DO UPDATE SET path = excluded.path;



================================================
FILE: keys/sql/create-links-table.sql
================================================
CREATE TABLE IF NOT EXISTS links (
    name TEXT PRIMARY KEY,
    path TEXT NOT NULL
);



================================================
FILE: keys/sql/find-link.sql
================================================
SELECT path
FROM links
WHERE name = '__NAME__';



================================================
FILE: keys/sql/list-links.sql
================================================
SELECT name || char(9) || path AS entry
FROM links
ORDER BY name;



================================================
FILE: keys/sql/remove-link.sql
================================================
DELETE FROM links
WHERE name = '__NAME__';



================================================
FILE: lib/logutils.red
================================================
Red [
    Title: "Redlinks Logging Utilities"
    File: %logutils.red
    Version: "0.0.2"
    License: "MIT"
]

; -- Level wrappers & usage --
  comment {
   * #include %lib/logutils.red to use the logging utilities in your application
     * log levels are INFO, ERROR, WARNING, DEBUG, and SYSTEM
      - it is best practice to use the appropriate log level for each message, as this allows for better organization and filtering of log messages

  USAGE:
  * log-info "This is an info message"

    ; -- EXAMPLE USAGE --

     if empty? args [
        log-info "No command provided. Use 'help' for usage information."
    ]

  * log-error "This is an error message"
    - it is best practice to use the error log level for messages that are followed by a application exit 
     
    ; -- EXAMPLE USAGE --

     if not find links name [
        log-error ["Unknown command:" name]
        quit -->  this is an example of a situation where it is appropriate to use the error log level, because the application is exiting due to an error condition
    ]

  * log-warning "This is a warning message"
    - it is best practice to use the warning log level for messages that indicate a potential issue or something that may require attention but is not necessarily an error

    ; -- EXAMPLE USAGE --
    
    if empty? name [
        log-warning "No name provided. Using default name 'default'."
        name: "default" --> this is an example of a situation where it is appropriate to use the warning log level, because the application can continue to function but there is a potential issue that the user should be aware of
        ]

  * log-debug "This is a debug message"
    - it is best practice to use the debug log level for messages that are useful for debugging but not necessarily important for end users
    
    ; -- EXAMPLE USAGE --

     log-debug ["Received command:" name]

  * log-system "This is a system message" 
    - it is best practice to use the system log level for messages sent by the operating system or other external systems that are relevant to the application but not necessarily generated by the application itself

     ; -- EXAMPLE USAGE --

     log-system "System is running low on memory" 
}

; -- ANSI Color Values --
reset:     "^[[0m"
red:       "^[[31m"
green:     "^[[32m"
yellow:    "^[[33m"
blue:      "^[[34m"
gray:      "^[[90m"
purple:    "^[[35m"


log: func [level color msg] [
    print rejoin [
        color "[" level "] " reset msg
    ]
]

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

log-system: func [msg] [
    log "SYSTEM" purple msg 
]



================================================
FILE: tests/test-sqlite-storage.red
================================================
Red [
    Title: "SQLite storage smoke test"
]

; Expect the database and SQL command directory to exist before the migration is considered complete.
db-file: %../keys/keys.sqlite3
sql-dir: %../keys/sql

if not exists? to-file db-file [
    print ["Missing database:" db-file]
    quit 1
]

if not exists? to-file sql-dir [
    print ["Missing SQL directory:" sql-dir]
    quit 1
]

print "SQLite storage test passed"



================================================
FILE: .github/instructions/build-system-agent.md
================================================
**Build System Agent Instructions**

**Overview:**
- **Purpose:** Concise, reproducible instructions for agents and contributors to build the Redlinks executable and understand the repository's build system.
- **Primary artifacts:** the build orchestrator [build.red](build.red#L1-L200), the PowerShell helper [helper/build-helper.ps1](helper/build-helper.ps1#L1-L200), and the compiler input [redlinks.red](redlinks.red#L1-L200).

**Prerequisites:**
- **`redc` (Red compiler):** Install the Red toolchain and ensure `redc` is on your `PATH` (Windows: place `redc.exe` in a folder on `PATH`).
- **PowerShell (Windows):** Required to run `helper/build-helper.ps1` and the helper called by `build.red`.
- **Working directory:** Run commands from the repository root (where [build.red](build.red#L1-L200) lives).

**Quick build (recommended, reproducible):**
- **Direct compile (same as CI):**

```
redc -c redlinks.red
```

- After the command completes, the produced artifact is `redlinks.exe` in the repo root (see [appveyor.yml](appveyor.yml#L1-L40) for the CI artifact definition).

**Build via helper script (explicit, mirrors `build.red` internal step):**
- The included helper is `helper/build-helper.ps1`. It wraps the `redc` invocation and is called by the Red orchestrator.
- Example (PowerShell):

```
powershell -ExecutionPolicy Bypass -File helper/build-helper.ps1 redlinks.red bin/redlinks.exe
```

- Confirm output: `bin\\redlinks.exe` should exist after the helper finishes.

**Using the Red orchestrator (`build.red`):**
- `build.red` is a Red script that sets `output` and invokes `helper/build-helper.ps1` to perform compilation. If you prefer the orchestrated flow, execute the script with your Red runtime. Two safe approaches:
  - Run the helper directly (recommended) as shown above.
  - Or run the Red script using your installed Red runtime. If your installation exposes a `red` or `redc` runner that can execute scripts, invoke that runner with `build.red` as the entrypoint.

**.buildignore and ignored files:**
- The file [%.buildignore](.buildignore#L1-L10) lists repository files the build orchestrator will ignore. By default `.buildignore` in this repo includes `build.red` so the build script itself won't be treated as an input to compilation.

**CI notes:**
- AppVeyor builds the project using the Red toolchain and compiles `redlinks.red` directly (see [appveyor.yml](appveyor.yml#L1-L40)). The CI run downloads a Windows Red toolchain and runs `redc.exe -c redlinks.red`.
- The CI artifact name is defined in `appveyor.yml` and matches the produced `redlinks.exe` binary.

**Troubleshooting:**
- `redc` not found: ensure the Red toolchain is installed and `redc`/`redc.exe` is on your `PATH`. On Windows you can download the toolchain from the Red project site and place `redc.exe` alongside your build tools.
- Permission / ExecutionPolicy errors when running `build-helper.ps1`: run PowerShell as Administrator or use `-ExecutionPolicy Bypass` as shown above.
- Output file not created: check the helper invocation and ensure `redc` exit code is zero. The helper script returns the compiler's exit code on failure.

**What agents should do (concrete checklist):**
- **Verify prerequisites:** check `redc` in `PATH` and PowerShell availability.
- **Run direct compile:** `redc -c redlinks.red` and validate `redlinks.exe` exists.
- **If using orchestrator:** run the helper or the `build.red` script and confirm `bin/redlinks.exe` or configured `output` exists.
- **Inspect CI config:** consult [appveyor.yml](appveyor.yml#L1-L40) for reproducing CI steps locally.

**Maintainer tips:**
- Keep `output` in [build.red](build.red#L1-L20) in sync with release packaging and installer scripts.
- Add important build inputs to `.buildignore` only when you intentionally want the build system to skip them.

**Contact / Links:**
- See repository README for higher-level project info.

---

This document is intended to be a minimal, reproducible guide agents and contributors can follow to build the project locally and mirror CI behavior.



================================================
FILE: .github/instructions/coding-standards.md
================================================
# Coding Guidelines

Coding standards and conventions for the Red project. These rules apply to source code, scripts, tests, tooling, and supporting files unless a more specific project convention overrides them.

## 1. General Principles

* Prefer readable, idiomatic Red over clever or unnecessarily compact code.
* Keep functions and blocks small enough to understand without excessive scrolling.
* Favor simple data transformations and Red's native series/block operations over manual bookkeeping.
* Avoid introducing abstractions until they solve a real, recurring problem.
* Follow existing conventions in the surrounding code before introducing a new pattern.
* Do not optimize prematurely. Prefer correctness and clarity unless performance is an established concern.
* Comments should explain **why**, not simply restate what the code does.

## 2. File Naming

Use lowercase names with hyphens for Red source files.

```text
lexer.red
parser.red
type-checker.red
http-client.red
test-parser.red
```

Use descriptive names that communicate the file's responsibility.

Avoid:

```text
Parser.red
parser_utils.red
misc.red
stuff.red
thing.red
```

Test files should normally use the `test-` prefix:

```text
test-parser.red
test-lexer.red
test-runtime.red
```

## 3. Formatting

### Indentation

* Use **4 spaces** for indentation.
* Do not use tabs.
* Keep indentation consistent within nested blocks.

```red
parse-file: func [file [file!]] [
    data: read file

    if empty? data [
        return none
    ]

    parse-data data
]
```

### Line Length

Prefer lines under **100 characters**.

Long expressions should be broken at logical boundaries rather than arbitrarily.

```red
result: process-data
    input
    options
    context
```

Do not sacrifice readability merely to satisfy the limit.

### Whitespace

Use one space around operators and after commas.

```red
result: value + offset
items: copy [one two three]
```

Avoid unnecessary whitespace:

```red
result:value+offset
```

## 4. Naming

Use lowercase names with hyphens.

```red
source-file
token-type
parse-expression
load-config
```

Do not use snake_case or camelCase for normal Red identifiers.

```red
; Avoid
source_file
tokenType
parseExpression
```

### Constants

Project-wide constants should use descriptive uppercase names when the value is conceptually constant.

```red
MAX-TOKEN-SIZE: 4096
DEFAULT-PORT: 8080
VERSION: "1.0.0"
```

Do not use uppercase merely because a value happens to be assigned once.

### Functions

Function names should describe an action or operation.

```red
parse-token
read-source
emit-code
validate-config
```

Predicates should generally read naturally as questions.

```red
valid-token?
empty-input?
has-errors?
```

## 5. Functions

Prefer explicit argument specifications.

```red
parse-token: func [
    token [string!]
    /local result
][
    ...
]
```

Use type specifications when they communicate an important contract.

Avoid unnecessarily broad or restrictive specifications when the function intentionally accepts multiple Red types.

### Refinements

Use refinements when they represent meaningful variations of an operation.

```red
load-file: func [
    path [file!]
    /binary
][
    either binary [
        read/binary path
    ][
        read path
    ]
]
```

Do not create refinements solely to avoid writing a separate function.

## 6. Blocks and Data

Remember that blocks are both executable code and data in Red.

Prefer direct block operations when they make the intent clearer.

```red
names: ["alice" "bob" "charlie"]
append names "dave"
```

Avoid unnecessary conversions or temporary structures.

```red
; Prefer
foreach item items [
    process item
]

; Over unnecessary manual indexing
repeat index length? items [
    process pick items index
]
```

Use `copy` deliberately when ownership or mutation matters.

```red
result: copy source
append result value
```

Do not assume assignment automatically creates an independent copy of a series.

## 7. Conditionals

Prefer Red's expression-oriented constructs when they improve clarity.

```red
status: either valid? input [
    'valid
][
    'invalid
]
```

Use `unless` when it naturally expresses the condition.

```red
unless connected? socket [
    connect socket
]
```

Avoid deeply nested conditionals. Use early returns or guard conditions when appropriate.

```red
parse: func [input [string!]] [
    if empty? input [
        return none
    ]

    if invalid? input [
        return none
    ]

    parse-valid-input input
]
```

## 8. Errors and Failure Handling

Do not silently ignore errors.

Failures should either:

* be propagated,
* be explicitly handled,
* or be intentionally converted into a documented fallback.

Use `try`, `attempt`, or explicit error handling according to the semantics required by the operation.

Do not use `attempt` merely to suppress errors you have not considered.

```red
result: try [
    read file
]

if error? result [
    print rejoin ["Unable to read " file]
]
```

For library code, avoid printing errors directly unless logging/output is explicitly part of the API.

## 9. Type Handling

Use Red's type system instead of relying on implicit assumptions.

Prefer:

```red
if string? value [
    process-string value
]
```

over fragile assumptions about the value's type.

When multiple types are intentionally supported, make that behavior explicit in the function contract and implementation.

## 10. Parsing and Evaluation

Code that parses, evaluates, compiles, or transforms Red values must clearly distinguish between:

* source text,
* Red values,
* blocks representing code,
* and evaluated results.

Do not evaluate arbitrary input merely to inspect its structure.

Prefer structural operations such as `load`, `parse`, `find`, `select`, and series traversal where appropriate.

Any use of `do`, `reduce`, or other evaluation mechanisms on external/untrusted input must be treated as a security-sensitive operation.

## 11. Mutability

Be deliberate about mutation.

Prefer local mutation when it makes an algorithm simpler, but avoid unexpectedly modifying values supplied by callers.

```red
normalize: func [items [block!]] [
    result: copy items

    ; mutate result, not caller-owned data
    ...
    
    result
]
```

Document functions that intentionally mutate caller-provided series.

## 12. Comments and Documentation

Comments should explain intent, constraints, or non-obvious behavior.

Good:

```red
; Keep the original block intact because callers may reuse it.
tokens: copy input
```

Bad:

```red
; Copy the input
tokens: copy input
```

Public APIs should have documentation describing:

* what the function does,
* accepted argument types,
* refinements,
* return values,
* side effects,
* and important failure conditions.

## 13. Modules and Imports

Keep imports/directives organized and minimal.

Remove unused dependencies.

Avoid importing an entire subsystem when only a small, independent component is required.

Keep module dependencies directional and avoid unnecessary circular dependencies.

## 14. Tests

Tests should be deterministic and independent of execution order.

Test normal behavior as well as:

* empty input,
* invalid input,
* boundary values,
* unexpected types,
* failure paths,
* and regression cases.

Name tests after the behavior they verify.

```red
test-empty-input: func [] [
    ...
]

test-invalid-token: func [] [
    ...
]
```

A bug fix should generally include a regression test when practical.

## 15. Source Layout

Prefer organizing source code by responsibility.

Example:

```text
src/
    lexer.red
    parser.red
    evaluator.red
    runtime.red
    errors.red

tests/
    test-lexer.red
    test-parser.red
    test-evaluator.red
    test-runtime.red

scripts/
    build.red
    test.red
```

Avoid large miscellaneous files containing unrelated functionality.

## 16. CLI and User-Facing Output

Command-line output should be concise and predictable.

Use consistent wording for errors, warnings, and status messages.

Errors should provide enough context to identify the operation that failed.

```text
error: unable to parse source file: example.red
```

Do not include internal implementation details in user-facing errors unless they are useful for diagnosing the problem.

## 17. Performance

Red's series and value semantics should be considered when writing performance-sensitive code.

Avoid unnecessary:

* copying,
* repeated conversions,
* parsing,
* allocations,
* and traversal of the same series.

However, do not replace clear code with obscure micro-optimizations without evidence that performance matters.

For performance-critical code, document the reason for the non-obvious implementation.

## 18. Security

Treat external input as untrusted.

This includes:

* files,
* command-line arguments,
* network data,
* environment variables,
* configuration files,
* and dynamically supplied Red code.

Never execute untrusted input with evaluation primitives without an explicit security boundary.

Avoid embedding credentials, API keys, private keys, or other secrets in source code.

## 19. Git and Changes

Keep commits focused.

A commit should generally represent one logical change.

Avoid mixing:

* formatting-only changes,
* unrelated refactors,
* dependency upgrades,
* and functional changes

in the same commit unless there is a good reason.

Do not commit generated files unless they are explicitly tracked by the project.

## 20. Pull Requests

Pull requests should:

* describe the problem being solved,
* explain the implementation at a high level,
* include relevant tests,
* mention compatibility concerns,
* and call out breaking changes.

New public APIs should include documentation and tests.

Reviewers should prioritize correctness, maintainability, security, and compatibility over personal stylistic preferences.

## 21. Rule of Thumb

When a rule conflicts with readability, correctness, or idiomatic Red, prefer the implementation that is easiest for another Red developer to understand and maintain.

**Readable Red is better than clever Red.**



================================================
FILE: .github/instructions/git-workflow.md
================================================
# Git & Workflow Standards

## 1. Branching

All development work must be performed on a dedicated branch. Do not commit directly to `main`.

### Branch Naming

Use the following format:

```text
<type>/<short-description>
```

Supported branch types:

| Type        | Purpose                                     |
| ----------- | ------------------------------------------- |
| `feature/`  | New functionality                           |
| `fix/`      | Bug fixes                                   |
| `refactor/` | Code restructuring without behavior changes |
| `perf/`     | Performance improvements                    |
| `docs/`     | Documentation-only changes                  |
| `test/`     | Adding or modifying tests                   |
| `build/`    | Build system/toolchain changes              |
| `ci/`       | CI/CD changes                               |
| `chore/`    | Maintenance work                            |
| `release/`  | Release preparation                         |
| `hotfix/`   | Critical fixes requiring expedited review   |

Examples:

```text
feature/parser-error-recovery
fix/string-buffer-overflow
refactor/runtime-dispatch
perf/lexer-tokenization
docs/compiler-internals
test/lexer-regressions
build/update-toolchain
ci/github-actions
```

Use lowercase names and hyphens. Keep branch names short and descriptive.

Avoid:

```text
my-branch
test
stuff
valerie-changes
fix-final-final
feature/THIS_IS_A_LONG_BRANCH_NAME
```

---

## 2. Main Branch

`main` represents the latest stable and review-approved state of the project.

Rules:

* Never push directly to `main`.
* All changes must go through a Pull Request.
* CI checks must pass before merging.
* Changes should receive appropriate review before merging.
* Do not merge known-broken compiler, runtime, or build-system changes.
* Keep `main` buildable whenever reasonably possible.

For release branches, use the project's release process rather than treating `main` as a temporary development branch.

---

## 3. Commits

Commits must use a concise, imperative format:

```text
<type>(<scope>): <description>
```

Examples:

```text
feat(parser): add hexadecimal literal support
fix(runtime): prevent invalid series access
refactor(lexer): simplify token dispatch
perf/evaluator: reduce allocation during evaluation
docs/compiler: document lexer architecture
test(parser): add malformed literal cases
build(toolchain): update Red compiler bootstrap
```

### Commit Types

| Type       | Meaning                    |
| ---------- | -------------------------- |
| `feat`     | New functionality          |
| `fix`      | Bug fix                    |
| `refactor` | Internal restructuring     |
| `perf`     | Performance improvement    |
| `docs`     | Documentation              |
| `test`     | Tests                      |
| `build`    | Build/toolchain changes    |
| `ci`       | CI changes                 |
| `chore`    | Maintenance                |
| `release`  | Release/versioning changes |

### Commit Rules

* Use the imperative mood: `add`, `fix`, `remove`, `update`.
* Keep the subject concise, preferably under 72 characters.
* Do not end the subject with a period.
* Explain non-obvious reasoning in the commit body.
* Avoid combining unrelated changes into one commit.
* Do not use meaningless messages such as `stuff`, `changes`, `fix`, or `WIP`.
* Do not commit generated artifacts unless the repository explicitly requires them.

Good:

```text
fix(parser): reject unterminated strings

The lexer previously consumed the remainder of the input when a
closing quote was missing. Stop lexing and emit the appropriate
syntax error instead.
```

Bad:

```text
fixed parser stuff
```

---

## 4. Red-Specific Commit Scopes

When practical, use scopes corresponding to the affected subsystem.

Common scopes include:

```text
lexer
parser
compiler
runtime
interpreter
evaluator
types
series
string
unicode
io
network
ffi
gc
memory
modules
loader
rebol
red
red-system
tests
docs
toolchain
bootstrap
build
ci
```

Use the smallest meaningful scope rather than forcing every commit into a generic scope.

For example:

```text
fix(lexer): correctly tokenize escaped quotes
fix(series): preserve index after insertion
feat(compiler): add constant folding for integers
fix(runtime): handle null series references
test(parser): cover nested block expressions
```

---

## 5. Pull Requests

Every Pull Request must:

* Have a clear title following the commit convention.
* Explain what changed and why.
* Identify relevant tests.
* Mention breaking changes explicitly.
* Keep unrelated changes out of the PR.
* Pass all required CI checks.
* Be reviewable without requiring undocumented local setup.

PR titles should follow:

```text
<type>(<scope>): <description>
```

Example:

```text
feat(parser): support additional literal forms
```

### PR Description

Use the following structure when appropriate:

```markdown
## Summary

- What changed?
- Why was it needed?

## Testing

- What was tested?
- Which test suites were run?

## Breaking Changes

- None
```

For compiler, parser, runtime, or language-semantics changes, include examples when they make the behavioral change easier to understand.

---

## 6. Code Review

Reviewers should prioritize:

1. Correctness
2. Language/runtime semantics
3. Memory safety
4. Compatibility
5. Performance
6. Maintainability
7. Style

For compiler and runtime changes, reviewers should pay particular attention to:

* Memory ownership and lifetime.
* Bounds checking.
* Invalid or malformed input.
* Parser/lexer state transitions.
* Error propagation.
* ABI/FFI compatibility.
* Platform-specific behavior.
* Changes to language semantics.
* Unintended performance regressions.
* Compatibility with existing Red/Rebol behavior.

Do not approve code solely because it compiles.

---

## 7. Rebasing and Merging

Branches should be kept reasonably up to date with `main`.

Before merging:

```text
feature branch
      ↓
update/rebase
      ↓
run tests
      ↓
Pull Request
      ↓
review + CI
      ↓
main
```

Prefer a clean project history. Squash commits when a branch contains numerous temporary or fixup commits and the project's merge policy permits it.

Do not rewrite shared branches that other contributors are actively using without coordination.

---

## 8. Fixup and Work-in-Progress Commits

During local development, temporary commits are acceptable:

```text
WIP: parser changes
fixup! feat(parser): add literal support
```

However, these should not normally remain in the final merged history.

Before merging, clean up temporary commits when appropriate.

---

## 9. Generated Files

Do not commit generated files, compiler outputs, temporary files, IDE metadata, or local build artifacts unless they are explicitly maintained as part of the repository.

Examples of files that generally should not be committed:

```text
*.o
*.obj
*.exe
*.dll
*.so
*.dylib
build/
dist/
tmp/
```

Repository-specific generated artifacts may be committed when required by the project's build or release process.

---

## 10. Language Semantics Changes

Changes that modify Red language behavior require additional care.

A change affecting:

* Syntax
* Evaluation rules
* Datatypes
* Functions
* Error behavior
* Type coercion
* Series semantics
* Evaluation order
* Module behavior
* Compatibility with Rebol/Red

must include appropriate regression tests.

If the behavior is intentionally incompatible with previous behavior, the Pull Request must explicitly document the compatibility impact.

---

## 11. Tests

Bug fixes should include a regression test whenever practical.

New functionality should include tests covering:

* Normal behavior.
* Boundary conditions.
* Invalid input.
* Error handling.
* Relevant platform-specific behavior.

A compiler/runtime change that cannot reasonably be tested should explain why in the Pull Request.

---

## 12. Releases

Release-related changes must not be mixed casually with unrelated development work.

Release commits should clearly identify the version:

```text
release: prepare Red 0.x.y
```

or:

```text
release(red): prepare 0.x.y
```

Version changes, changelogs, release notes, and generated release artifacts must follow the project's established release procedure.

---

## 13. Security-Sensitive Changes

Security fixes should avoid exposing vulnerability details in public commit messages or Pull Requests until disclosure is appropriate.

Do not commit:

* Credentials
* API keys
* Private certificates
* Access tokens
* Personal secrets
* Production configuration containing sensitive information

If a secret is accidentally committed, removing the file from the latest commit is not sufficient. Treat the secret as compromised and rotate it.

---

## 14. General Rules

The repository should maintain a history that is:

* Understandable
* Searchable
* Bisectable
* Revertible
* Reproducible

When choosing between a clever Git workflow and a boring predictable one, prefer the boring predictable one.

**Small, focused commits. Clear branches. Tested changes. Review before merge.**



================================================
FILE: .github/instructions/blobs/context.general.blob.md
================================================
# Codebase Context Blob
this was generated by [git ingest](https://gitingest.com) and remains unstructured


================================================
FILE: README.adoc
================================================
= Redlinks

Redlinks is a alternative environment variable registry for Windows. It provides a way to manage your envionment without potentially damaging or breaking actual environment variables, think of this as a PATH emulator, or a second PATH. not a actual tool that manages your Windows PATH. 

== Installation

1. Download the latest release from the [GitHub releases page]
2. Make the executable global
    - Move the executable to a directory in your PATH (e.g., `C:\Windows\System32` or `C:\Program Files\Redlinks`)
    - Alternatively, you can add the directory containing the executable to your PATH environment variable
3. Verify the installation by opening a new command prompt and running `redlinks --version`

== Usage

- To list all environment variables: `redlinks list`
- To add a new environment variable: `redlinks add <name> <value>`
- To remove an environment variable: `redlinks remove <name>`
- To update an existing environment variable: `redlinks update <name> <new_value>`
- To run a health check on the environment variables: `redlinks doctor`


================================================
FILE: appveyor.yml
================================================
version: 1.0.{build}

image: Visual Studio 2022

branches:
  only:
    - master

skip_non_tags: true

environment:
  GH_TOKEN:
    secure: IjFa9PuaLV0Y9uAu85s+V+uj18dozWkwJUHEBmELMcQJyhZMHUqKpURk2xYasayR

build_script:
  - echo Building Redlinks...

  - ps: |
      Invoke-WebRequest `
        -Uri "https://static.red-lang.org/dl/win/red-toolchain-066.exe" `
        -OutFile "redc.exe"

  - dir redc.exe

  - redc.exe -c redlinks.red

artifacts:
  - path: redlinks.exe
    name: redlinks

deploy:
  - provider: GitHub
    release: redlinks-v$(APPVEYOR_BUILD_VERSION)
    description: "Redlinks build"
    auth_token: $(GH_TOKEN)
    artifact: redlinks
    draft: false
    prerelease: false
    on:
      APPVEYOR_REPO_TAG: true


================================================
FILE: build.red
================================================
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


================================================
FILE: globals.red
================================================
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


================================================
FILE: LICENSE
================================================
MIT License

Copyright (c) 2026 John Brown

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.



================================================
FILE: redlinks.red
================================================
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


================================================
FILE: .buildignore
================================================
build.red


================================================
FILE: helper/build-helper.ps1
================================================
param(
    [string]$InputFile,
    [string]$OutputFile
)

$redCompiler = "redc"

# I fucking guess $args is reserved in powershell, so we have to use a different variable name for the arguments array. What the fuck.
$args1 = @(
    "-o",
    $OutputFile,
    $InputFile
)

$process = Start-Process `
    -FilePath $redCompiler `
    -ArgumentList $args1 `
    -NoNewWindow `
    -Wait `
    -PassThru

if ($process.ExitCode -ne 0) {
    exit $process.ExitCode
}


================================================
FILE: installer/installer.nsi
================================================
; Redlinks installer script
; blah blah blah, follow the MIT license, etc etc

OutFile "Redlinks-Setup.exe"

InstallDir "$PROGRAMFILES\Redlinks"

Page directory
Page instfiles


Section "Install"

    SetOutPath "$INSTDIR"

    File "bin\redlinks.exe"

    SetOutPath "$INSTDIR\keys"

    File "keys\links.txt"

    CreateDirectory "$INSTDIR\logs"

    CreateShortcut "$DESKTOP\Redlinks.lnk" "$INSTDIR\redlinks.exe"

    WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd



Section "Uninstall"

    Delete "$INSTDIR\redlinks.exe"

    Delete "$INSTDIR\keys\links.txt"

    Delete "$INSTDIR\Uninstall.exe"

    Delete "$DESKTOP\Redlinks.lnk"

    RMDir "$INSTDIR\keys"
    RMDir "$INSTDIR\logs"
    RMDir "$INSTDIR"

SectionEnd


================================================
FILE: keys/README.adoc
================================================
= WTF why .txt?!

this tool is still very much a toy utility, things will change, but for now, the .txt extension is just a placeholder until we decide on a more appropriate one. The content of these files is not meant to be human-readable, so the .txt extension is misleading. We will likely switch to a different format in the future that better reflects the nature of the data being stored.

== Why what idea is next?

A custom binary format likely will act as our keyvalue store, but we are open to suggestions. The main goal is to have a format that is efficient for both reading and writing, and that can easily be parsed by our tools. We want to avoid formats that are too verbose or that require a lot of overhead to read and write.


================================================
FILE: keys/links.txt
================================================
[Empty file]


================================================
FILE: lib/logutils.red
================================================
Red [
    Title: "Redlinks Logging Utilities"
    File: %logutils.red
    Version: "0.0.2"
    License: "MIT"
]

; -- Level wrappers & usage --
  comment {
   * #include %lib/logutils.red to use the logging utilities in your application
     * log levels are INFO, ERROR, WARNING, DEBUG, and SYSTEM
      - it is best practice to use the appropriate log level for each message, as this allows for better organization and filtering of log messages

  USAGE:
  * log-info "This is an info message"

    ; -- EXAMPLE USAGE --

     if empty? args [
        log-info "No command provided. Use 'help' for usage information."
    ]

  * log-error "This is an error message"
    - it is best practice to use the error log level for messages that are followed by a application exit 
     
    ; -- EXAMPLE USAGE --

     if not find links name [
        log-error ["Unknown command:" name]
        quit -->  this is an example of a situation where it is appropriate to use the error log level, because the application is exiting due to an error condition
    ]

  * log-warning "This is a warning message"
    - it is best practice to use the warning log level for messages that indicate a potential issue or something that may require attention but is not necessarily an error

    ; -- EXAMPLE USAGE --
    
    if empty? name [
        log-warning "No name provided. Using default name 'default'."
        name: "default" --> this is an example of a situation where it is appropriate to use the warning log level, because the application can continue to function but there is a potential issue that the user should be aware of
        ]

  * log-debug "This is a debug message"
    - it is best practice to use the debug log level for messages that are useful for debugging but not necessarily important for end users
    
    ; -- EXAMPLE USAGE --

     log-debug ["Received command:" name]

  * log-system "This is a system message" 
    - it is best practice to use the system log level for messages sent by the operating system or other external systems that are relevant to the application but not necessarily generated by the application itself

     ; -- EXAMPLE USAGE --

     log-system "System is running low on memory" 
}

; -- ANSI Color Values --
reset:     "^[[0m"
red:       "^[[31m"
green:     "^[[32m"
yellow:    "^[[33m"
blue:      "^[[34m"
gray:      "^[[90m"
purple:    "^[[35m"


log: func [level color msg] [
    print rejoin [
        color "[" level "] " reset msg
    ]
]

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

log-system: func [msg] [
    log "SYSTEM" purple msg 
]




