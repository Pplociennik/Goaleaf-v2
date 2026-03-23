@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

SET VERSION=1.0

REM ===================================================================================================

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

CALL :logASCII
ECHO.
ECHO   Goaleaf Testpack v%VERSION%
ECHO.
timeout /t 1 /nobreak >nul

ECHO.
ECHO Checking Docker images...
ECHO.

docker image inspect com.goaleaf/glf-accounts:0.0.1-SNAPSHOT >nul 2>&1
IF ERRORLEVEL 1 (
    ECHO Loading Docker images from .images/ directory...
    ECHO.

    FOR %%F IN (.images\*.tar) DO (
        ECHO Loading %%F...
        docker load -i %%F || (
            ECHO [ERROR] Failed to load %%F
            PAUSE
            EXIT /B 1
        )
        ECHO.
    )

    ECHO All images loaded successfully.
) ELSE (
    ECHO Docker images already loaded, skipping...
)
ECHO.

:ask
SET /P CHOICE=Run single database version? (y/n):
IF /I "%CHOICE%"=="y" goto :runSingleDb
IF /I "%CHOICE%"=="n" goto :runMultiDb
ECHO Invalid input. Please enter 'y' or 'n'.
goto :ask

:runSingleDb
SET COMPOSE_FILE=compose/single-db/docker-compose.yml
ECHO.
ECHO Starting Goaleaf with single database configuration...
goto :startContainers

:runMultiDb
SET COMPOSE_FILE=compose/multi-db/docker-compose.yml
ECHO.
ECHO Starting Goaleaf with multi database configuration...
goto :startContainers

:startContainers
docker compose -f %COMPOSE_FILE% up -d || (
    ECHO [ERROR] Failed to start containers.
    EXIT /B 1
)
CALL :startLogging
goto :done

:done
ECHO.
ECHO Goaleaf has been started successfully.
ECHO.
ECHO               ( ctrl + click to open )
ECHO   Webclient:    http://localhost:4200
ECHO   Keycloak:     http://localhost:7080
ECHO.
ECHO   Logs:         .logs\%TIMESTAMP%\
ECHO.
ECHO =====================================================
ECHO   WARNING: Do NOT close this window while using
ECHO   Goaleaf! This process captures container logs.
ECHO   Closing it will stop all log recording.
ECHO.
ECHO   Use stop.bat in a separate terminal to shut
ECHO   down Goaleaf when you are done.
ECHO =====================================================
ECHO.

:keepAlive
timeout /t 3600 /nobreak >nul
goto :keepAlive

REM ===================================================================================================

:startLogging
FOR /F "usebackq delims=" %%T IN (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd_HHmmss'"`) DO SET TIMESTAMP=%%T
SET LOG_DIR=.logs\%TIMESTAMP%
MKDIR "%LOG_DIR%" >nul 2>&1
ECHO.
ECHO Capturing container logs to %LOG_DIR%\...
FOR /F "usebackq delims=" %%C IN (`docker compose -f %COMPOSE_FILE% ps -a --format "{{.Name}}"`) DO (
    START "" /B CMD /C "docker logs -f %%C > %LOG_DIR%\%%C.log 2>&1"
)
goto :eof

REM ===================================================================================================

:logASCII
:::
:::    ____             _            __
:::   / ___| ___   __ _| | ___  __ _/ _|
:::  | |  _ / _ \ / _` | |/ _ \/ _` | |_
:::  | |_| | (_) | (_| | |  __/ (_| |  _|
:::   \____|\___/ \__,_|_|\___|\__,_|_|
:::                TESTPACK
:::
for /f "delims=: tokens=*" %%A in ('findstr /b ::: "%~f0"') do @echo(%%A
goto :eof
