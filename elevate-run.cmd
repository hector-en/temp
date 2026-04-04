@echo off
setlocal EnableExtensions DisableDelayedExpansion

if "%~1"=="" (
  echo Usage: elevate-run "C:\Path\to\app.exe" [args...]
  exit /b 64
)

set "exe=%~1"
shift

if not exist "%exe%" (
  echo ERROR: EXE not found: "%exe%"
  exit /b 2
)

:: Rebuild args quoted
set "args="
:argloop
if "%~1"=="" goto :doneargs
set "args=%args% ""%~1"""
shift
goto :argloop
:doneargs

net file 1>nul 2>nul
if %errorlevel%==0 goto :admin

set "vbs=%temp%\elev_%~n0_%random%.vbs"
> "%vbs%" echo Set UAC=CreateObject("Shell.Application")
>>"%vbs%" echo UAC.ShellExecute "%exe%","%args%","","runas",1
cscript //nologo "%vbs%" 1>nul
del "%vbs%" 1>nul 2>nul
exit /b

:admin
start "" "%exe%" %args%
exit /b
