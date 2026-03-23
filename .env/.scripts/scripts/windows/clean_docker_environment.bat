@ECHO OFF
SETLOCAL

SET SINGLE_DB_COMPOSE=..\..\..\.docker\compose\qa\single-db\docker-compose.yml
SET MULTI_DB_COMPOSE=..\..\..\.docker\compose\qa\multi-db\docker-compose.yml

ECHO.
ECHO Cleaning Goaleaf Docker environment...
ECHO.

ECHO Removing Goaleaf containers, images, networks and volumes...
ECHO.

docker compose -f "%SINGLE_DB_COMPOSE%" down -v --rmi all 2>nul
docker compose -f "%MULTI_DB_COMPOSE%" down -v --rmi all 2>nul

ECHO.
ECHO Goaleaf Docker environment has been cleaned successfully.

ENDLOCAL
