@echo off
setlocal
cd /d "%~dp0"
title WhatFits - Stop Database

docker compose down
if errorlevel 1 (
  echo Could not stop the WhatFits database. Make sure Docker Desktop is running.
) else (
  echo WhatFits PostgreSQL database stopped.
)
pause
