Red: [
    Title: "Redlinks Build Script"
    File: %build.red
    Version: "0.0.1"
    License: "MIT"
    Description: "Builds the Redlinks CLI executable & installer."
]

; -- Includes --
#include %globals.red ; --> import global functions and variables
#include %lib/logutils.red ; --> For logging utilities

; -- Build Macros -- 
#define _COMPILE "redc -c" ; Command to compile Red code
#define _LINK "redc -l" ; Command to link Red code into an executable
#define _OUTPUT "redlinks.exe" ; Default output executable name
#define _GCC_COMPILE "gcc" ; Command for GCC (not needed right now, but may be used for native extensions in the future)

; -- Rules --
; Note: Array of source files to ignore during the build process (e.g., tests, docs, the build script itself, etc.)
buildignore: [%.buildignore] 

; -- Functions --
start: func [] [
    log-warning ["the following sources will be ignored:" buildignore]
    wait 2 ; Pause to allow the user to read the warning
]

; -- Build Steps --
build: func [] [

    log-info "Build process is running... please do not close this window."
    wait 1 

    ; -- Build the executable --
    call _LINK ["lib/global.red"] ; compile global functions
    call _LINK ["lib/logutils.red"] ; compile logging utilities
    call _LINK ["lib/logutils_export.red"] ; dependency for logutils compilation
    call _COMPILE ["redlinks.red"] ; compile the main program
        ; (Note: Red's build process may automatically handle dependencies, but we're explicitly compiling key components here for clarity)
    
        ; Move the compiled executable to the desired output location
        if exists? _OUTPUT [delete _OUTPUT] ; Remove existing executable if it exists
        move %redlinks.exe _OUTPUT
    
        log-debug ["Executable built successfully:" _OUTPUT]
        wait 1 
    
        ; -- Run tests (if any) --
        ; (This is a placeholder - actual test execution would depend on the testing framework and test scripts available)
        ; call "red" ["test/test_suite.red"] ; Example for running tests
    ; -- Build the installer (if needed) --
    ; (This is a placeholder - actual installer creation would depend on the target platform and tools available)
    ; call "makensis" ["installer_script.nsi"] ; Example for NSIS
]
