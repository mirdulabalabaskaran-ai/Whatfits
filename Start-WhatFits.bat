@echo off
setlocal
cd /d "%~dp0"
title WhatFits - Local Starter

echo.
echo ==============================================
echo   Starting WhatFits with Docker PostgreSQL
 echo ==============================================
echo.

where docker >nul 2>nul
if errorlevel 1 (
  echo Docker Desktop is required but was not found.
  echo Install and open Docker Desktop, then double-click this file again.
  pause
  exit /b 1
)

docker info >nul 2>nul
if errorlevel 1 (
  echo Docker Desktop is installed but is not running.
  echo Open Docker Desktop, wait for it to finish starting, then try again.
  pause
  exit /b 1
)

where mvn >nul 2>nul
if errorlevel 1 (
  echo Apache Maven was not found on this computer.
  echo Open this folder in IntelliJ IDEA and run WhatFitsApplication instead.
  pause
  exit /b 1
)

echo Starting PostgreSQL database...
docker compose up -d postgres
if errorlevel 1 (
  echo Could not start the PostgreSQL container.
  pause
  exit /b 1
)

echo.
echo Database is starting. Spring Boot will create the WhatFits tables automatically.
echo When you see "Started WhatFitsApplication", open http://localhost:8080 in your browser.
echo.
call mvn spring-boot:run

pause
