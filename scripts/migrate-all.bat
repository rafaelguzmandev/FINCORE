@echo off
:: Thin Windows wrapper: all migration logic lives in migrate-all.sh (Git Bash).
setlocal
set "BASH_EXE=C:\Program Files\Git\bin\bash.exe"
if not exist "%BASH_EXE%" (
    echo ERROR: Git Bash not found at "%BASH_EXE%". Install Git for Windows. >&2
    exit /b 1
)
"%BASH_EXE%" "%~dp0migrate-all.sh"
