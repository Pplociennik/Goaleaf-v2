@ECHO OFF

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

ECHO Stopping Goaleaf containers...
ECHO.

ECHO [single-db]
docker compose -f compose/single-db/docker-compose.yml down
ECHO.
ECHO [multi-db]
docker compose -f compose/multi-db/docker-compose.yml down

ECHO.
ECHO Goaleaf has been stopped successfully.
ECHO Log files are available in the .logs/ directory.
ECHO.
PAUSE
