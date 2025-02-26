ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

REM Path to the .env file
SET ENV_FILE="%cd%\.env"

REM Read the .env file and set the variables
FOR /F "tokens=1,2 delims==" %%A IN ('TYPE %ENV_FILE% ^| FINDSTR /R "^[a-zA-Z]"') DO (
    SET %%A=%%B
)

REM Now you can use the variables from the .env file
CALL :log "Loaded environment variables from .env file"

SET DEBUG=true
SET PROJECT_NAME="Goaleaf v2"

SET HOME_DIR="%cd%\..\..\..\..\.."

SET ACCOUNTS_DIR="%HOME_DIR%\glf-accounts"
SET COMMUNITIES_DIR="%HOME_DIR%\glf-communities"
SET CONFIG_SERVER_DIR="%HOME_DIR%\glf-configServer"
SET SERVICE_DISCOVERY_DIR="%HOME_DIR%\glf-servicediscovery"
SET API_GATEWAY_DIR="%HOME_DIR%\glf-api-gateway"

SET MVN=mvn

CALL :log "Setting up the project..."

CALL :buildAccounts



REM =================================================================================================

REM Maven

:buildAccounts
CALL :debug Function buildAccounts started...
CALL :debug Setting the project name to Accounts...
SET PROJECT_NAME="Accounts"
CALL :log "Building Accounts..."
CALL :debug [ "BUILD_ACCOUNTS=%BUILD_ACCOUNTS%, BUILD_ACCOUNTS_DOCKER_IMAGE=%BUILD_ACCOUNTS_DOCKER_IMAGE%, BUILD_ACCOUNTS_WITH_TESTS=%BUILD_ACCOUNTS_WITH_TESTS%, BUILD_ACCOUNTS_OFFLINE=%BUILD_ACCOUNTS_OFFLINE%" ]
SET ACCOUNT_CMD=clean install
IF "%BUILD_ACCOUNTS_OFFLINE%" == "true" (
    CALL :debug Building Accounts in offline mode...
    SET ACCOUNT_CMD=-o %ACCOUNT_CMD%
    CALL :debug Current command "%ACCOUNT_CMD%"
)
IF "%BUILD_ACCOUNTS_WITH_TESTS%" == "false" (
    CALL :debug Skipping tests for Accounts...
    SET ACCOUNT_CMD=%ACCOUNT_CMD% -DskipTests
    CALL :debug Current command "%ACCOUNT_CMD%"
)
CALL :debug Setting the OS to %OS%...
SET ACCOUNT_CMD=%ACCOUNT_CMD% -P %OS%
CALL :debug Current command "%ACCOUNT_CMD%"
IF "%BUILD_ACCOUNTS_DOCKER_IMAGE%" == "true" (
    CALL :debug Building Accounts with Docker image...
    SET ACCOUNT_CMD=%ACCOUNT_CMD%,withDockerImage
    CALL :debug Current command "%ACCOUNT_CMD%"
)
IF NOT "%LOCAL_MAVEN_REPOSITORY%" == "" (
    CALL :debug Using local Maven repository...
    SET ACCOUNT_CMD=%ACCOUNT_CMD% -Dmaven.repo.local=%cd%\%LOCAL_MAVEN_REPOSITORY%
    CALL :debug Current command "%ACCOUNT_CMD%"
)
CALL :debug Final command "[ %ACCOUNT_CMD% ]"
CALL :switchDirectory %ACCOUNTS_DIR%
CALL :log Running maven command for Accounts "%ACCOUNT_CMD%"
%MVN% %ACCOUNT_CMD% || goto :error
CALL :log Accounts has been built successfully.
CALL :debug Function buildAccounts ended...
goto :eof

REM Environment

:switchDirectory
REM This function will switch to the specified directory.
REM Parameters:
REM    1. The directory to switch to.
CALL :debug Switching to %1
CD %1 || goto :error
CALL :debug Switched to %cd%
goto :eof

:log
ECHO %PROJECT_NAME% --- [INFO] %*
goto :eof

:debug
IF "%DEBUG%" == "true" (
ECHO.
ECHO %DATE% %TIME% %USERNAME% %COMPUTERNAME% --- %PROJECT_NAME% --- [DEBUG] %*
)

:error
ECHO %DATE% %TIME% %USERNAME% %COMPUTERNAME% %CD% --- %PROJECT_NAME% --- [ERROR] %*
goto :eof