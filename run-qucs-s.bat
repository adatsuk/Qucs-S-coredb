@echo off
rem Launch locally built Qucs-S (Qt DLLs must be deployed via windeployqt).
setlocal EnableExtensions
set "ROOT=%~dp0"
set "EXE=%ROOT%build\qucs\qucs-s.exe"
if not exist "%EXE%" (
  echo ERROR: Build qucs-s first. See docs\CORE.md
  exit /b 1
)
start "" "%EXE%" %*
