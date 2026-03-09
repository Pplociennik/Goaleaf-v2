@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

REM Check if Docker is running
docker info >nul 2>&1
IF ERRORLEVEL 1 (
    ECHO.
    ECHO        ___.
    ECHO       / _  \
    ECHO      ^| / \. ^|        _  _
    ECHO      ^| \_/  ^|       ^| \/ ^|
    ECHO       \____/     ___^|    ^|
    ECHO       /    \    /  _    _^|
    ECHO      / .-   \  ^| / \__/
    ECHO     / /    ^ \  \\
    ECHO    /_/      \_\ \\___
    ECHO                  \__ \
    ECHO                     \ \
    ECHO                      \/
    ECHO.
    ECHO   Oops! It seems you have no Docker instance running!
    ECHO   Better fix it, you naughty, or Santa Claus will
    ECHO   miss your house this year!
    ECHO.
    ECHO   Please start Docker Desktop and try again.
    ECHO.
    PAUSE
    EXIT /B 1
)

ECHO.
ECHO Cleaning Goaleaf Docker environment...
ECHO.

REM Ask about volumes
:askVolumes
SET /P REMOVE_VOLUMES=Remove Docker volumes too? (y/n):
IF /I "%REMOVE_VOLUMES%"=="y" goto :volumesYes
IF /I "%REMOVE_VOLUMES%"=="n" goto :volumesNo
ECHO Invalid input. Please enter 'y' or 'n'.
goto :askVolumes

:volumesYes
SET COMPOSE_DOWN_FLAGS=down -v --rmi all
goto :askPrune

:volumesNo
SET COMPOSE_DOWN_FLAGS=down --rmi all
goto :askPrune

REM Ask about system prune
:askPrune
SET /P DO_PRUNE=Run Docker system prune? (y/n):
IF /I "%DO_PRUNE%"=="y" goto :askLogs
IF /I "%DO_PRUNE%"=="n" goto :askLogs
ECHO Invalid input. Please enter 'y' or 'n'.
goto :askPrune

REM Ask about log files
:askLogs
SET REMOVE_LOGS=n
IF NOT EXIST ".logs" goto :doClean
SET /P REMOVE_LOGS=Remove log files? (y/n):
IF /I "%REMOVE_LOGS%"=="y" goto :doClean
IF /I "%REMOVE_LOGS%"=="n" goto :doClean
ECHO Invalid input. Please enter 'y' or 'n'.
goto :askLogs

:doClean
ECHO.
ECHO Removing Goaleaf containers, images and networks...
ECHO.

docker compose -f compose/single-db/docker-compose.yml %COMPOSE_DOWN_FLAGS% 2>nul
docker compose -f compose/multi-db/docker-compose.yml %COMPOSE_DOWN_FLAGS% 2>nul

IF /I "%DO_PRUNE%"=="y" (
    ECHO.
    ECHO Pruning Docker system...
    docker system prune -f --volumes=false
)

IF /I "!REMOVE_LOGS!"=="y" (
    IF EXIST ".logs" (
        ECHO.
        ECHO Removing log files...
        RMDIR /S /Q ".logs"
    )
)

ECHO.
ECHO Goaleaf Docker environment has been cleaned successfully.
ECHO.
PAUSE

ENDLOCAL
