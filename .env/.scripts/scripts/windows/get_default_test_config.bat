@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

SET DEBUG=false
REM Do you want to copy files? Sometimes you only want to just test the cloning :)
SET COPY_FILES=false

SET GITHUB_USER=%1
SET GITHUB_TOKEN=%2

SET GIT=git
SET REPO_URL=https://%GITHUB_USER%:%GITHUB_TOKEN%@github.com/Pplociennik/glf-secrets.git

IF "%GITHUB_USER%" == NULL (
    call :debug User login - "%GITHUB_USER%"
    call :debug Access token - "%GITHUB_TOKEN%"
    call :log No valid credentials specified.
    EXIT /B 1
    goto :eof
)

SET HOME=%CD%
SET PROJECT_HOME=%HOME%\..\..\..
SET SECRETS_DIR=%PROJECT_HOME%\.secrets

REM ####################################################################################################################

SET MULTI_DB_ENV_PATH=".docker/compose/qa/multi-db/.env"
REM SET MULTI_DB_KEYCLOAK_VOLUME_PATH=".docker/compose/qa/multi-db/volumes/keycloak"
SET SINGLE_DB_ENV_PATH=".docker/compose/qa/single-db/.env"
REM SET SINGLE_DB_KEYCLOAK_VOLUME_PATH=".docker/compose/qa/single-db/volumes/keycloak"

REM ####################################################################################################################

call :log Starting...
call :removeIfExists %SECRETS_DIR%

%GIT% clone %REPO_URL% %SECRETS_DIR% || goto :error

IF "%COPY_FILES%" == "true" (
    call :log Copying files...
    call :copy %SECRETS_DIR%/%MULTI_DB_ENV_PATH% %PROJECT_HOME%/%MULTI_DB_ENV_PATH%
    call :copy %SECRETS_DIR%/%SINGLE_DB_ENV_PATH% %PROJECT_HOME%/%SINGLE_DB_ENV_PATH%
)

call :log Config prepared successfully.
EXIT /B 0
PAUSE

REM ####################################################################################################################

:copy
call :debug Entered ":copy" with parameters %*
call :log Copying "%1" to "%2"...
xcopy /Y /F %1 %2 || goto :error
call :log File copied successfully.
goto :eof

:removeIfExists
call :debug Entered ":removeIfExists" with parameters %*
IF EXIST "%1" (
    call :log Directory "%1" already exists. Removing.
    RD /S /Q "%1" || goto :error
    call :log Directory "%1" removed.
) ELSE (
    call :log Directory "%1" does not exist.
)
goto :eof

:log
echo %* || goto :error
goto :eof

:debug
IF "%DEBUG%" == "true" (
    ECHO [DEBUG] %* || goto :error
)
goto :eof

:error
echo [ERROR] %*
EXIT /B 1
goto :eof