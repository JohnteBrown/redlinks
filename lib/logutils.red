Red [
    Title: "Redlinks Logging Utilities"
    File: %logutils.red
    Version: "0.0.2"
    License: "MIT"
]
 
; importing the export module allows logs to be written to .log files in _temp, in addition to being printed to the console
; this module is not used for all logging functions, only application crashes.
do %logutils_export.red 

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


; -- Level wrappers & usage --
  comment {
   * #include %lib/logutils.red to use the logging utilities in your application
     * log levels are INFO, ERROR, WARNING, DEBUG, and SYSTEM
      - it is best practice to use the appropriate log level for each message, as this allows for better organization and filtering of log messages

  USAGE:
  * log-info "This is an info message"

  * log-error "This is an error message"
    - it is best practice to use the error log level for messages that are followed by a application exit 
     
    ; -- EXAMPLE USAGE --

     if not find links name [
        log-error ["Unknown command:" name]
        quit -->  this is an example of a situation where it is appropriate to use the error log level, because the application is exiting due to an error condition
    ]

  * log-warning "This is a warning message"
    - it is best practice to use the warning log level for messages that indicate a potential issue or something that may require attention but is not necessarily an error

  * log-debug "This is a debug message"
    - it is best practice to use the debug log level for messages that are useful for debugging but not necessarily important for end users

  * log-system "This is a system message" 
    - it is best practice to use the system log level for messages sent by the operating system 
}

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
