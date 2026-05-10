@echo off
setlocal
title Start AiToEarn

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\start-aitoearn-auto.ps1"
if errorlevel 1 (
  echo.
  echo AiToEarn did not start cleanly. Read the message above, then press any key to close.
  pause >nul
)
