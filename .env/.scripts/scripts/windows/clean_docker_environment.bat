@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

REM List of container names to exclude from removal
SET EXCEPTIONS_LIST="portainer"

REM Remove all containers except those in the exceptions list
FOR /F "tokens=1" %%A IN ('docker ps -a --format "{{.Names}}"') DO (
    CALL :checkException %%A
    IF "!IS_EXCEPTION!"=="false" (
        ECHO Removing container %%A
        docker rm -f %%A
    ) ELSE (
        ECHO Skipping container %%A
    )
)

REM Remove all images
ECHO Removing all images
for /F %%i in ('docker images -a -q') do docker rmi -f %%i

REM Remove all networks
ECHO Removing all networks
for /F %%i in ('docker network ls -q') do docker rm -f %%i

REM Prune the Docker system
ECHO Pruning the Docker system
docker system prune -f --volumes=false

ECHO Docker environment cleaned successfully.

REM ==============================

REM Function to check if a container is in the exceptions list
:checkException
SET "IS_EXCEPTION=false"
FOR %%E IN (%EXCEPTIONS_LIST%) DO (
    IF /I "%%~1"=="%%~E" SET "IS_EXCEPTION=true"
)
goto :eof

ENDLOCAL