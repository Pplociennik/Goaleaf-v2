@ECHO OFF

REM Path to the .env file
SET ENV_FILE="%cd%\.env"

REM Reads the .env file and set the variables.
FOR /F "tokens=1,2 delims==" %%A IN ('TYPE %ENV_FILE% ^| FINDSTR /R "^[a-zA-Z]"') DO (
    SET %%A=%%B
)

ECHO Shutting down the Docker environment...

IF "%SINGLE_DB%" == "true" (
    docker compose -f "%DOCKER_COMPOSE_SINGLE_DB%" down || goto :error
) ELSE (
    docker compose -f "%DOCKER_COMPOSE_MULTI_DB%" down || goto :error
)

ECHO Docker environment has been shut down successfully.

REM =============================================================================================

REM Prints an error message in the log.
:error
ECHO [ERROR] %*
goto :eof