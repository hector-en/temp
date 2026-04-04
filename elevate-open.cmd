@echo off
setlocal EnableExtensions DisableDelayedExpansion

if "%~1"=="" (
  echo Usage: elevate-open "C:\path\to\file-or-folder" [args...]
  exit /b 64
)

:: Build a properly quoted argument list for relaunch
set "args="
:argloop
if "%~1"=="" goto :doneargs
set "args=%args% ""%~1"""
shift
goto :argloop
:doneargs

:: If already admin, open via Explorer shell (respects file associations)
net file 1>nul 2>nul
if %errorlevel%==0 goto :admin

:: Elevate self
set "vbs=%temp%\elev_%~n0_%random%.vbs"
> "%vbs%" echo Set UAC=CreateObject("Shell.Application")
>>"%vbs%" echo UAC.ShellExecute "cmd.exe","/c ""%~f0"" %args%","","runas",1
cscript //nologo "%vbs%" 1>nul
del "%vbs%" 1>nul 2>nul
exit /b

:admin
:: Explorer shell open (works for files/folders/URLs; uses default app)
explorer.exe %args%
exit /b
