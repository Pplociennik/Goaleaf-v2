ECHO OFF

REM This script is used to prepare the development environment for the project.
REM It will download repositories of all the microservices.
REM The repositories will be downloaded in the main directory in such an order:
REM    1. glf-configServer
REM    2. glf-servicediscovery
REM    3. glf-api-gateway
REM    4. glf-accounts
REM    5. glf-communities

REM Requirements:
REM    1. Git should be installed on the system.
REM    2. The system should have access to the internet.

REM These are the variables that will be used in the script.
SET HOME=%CD%
SET DEBUG=false

REM A git installation. If git is available in the system path, just use 'git'.
SET GIT=git

REM The repositories to be cloned.
SET CONFIG_SERVER_REPO=https://github.com/Pplociennik/glf-config-server.git
SET SERVICE_DISCOVERY_REPO=https://github.com/Pplociennik/glf-servicediscovery.git
SET API_GATEWAY_REPO=https://github.com/Pplociennik/glf-api-gateway.git
SET ACCOUNTS_REPO=https://github.com/Pplociennik/glf_accounts.git
SET COMMUNITIES_REPO=https://github.com/Pplociennik/glf_communities.git

REM The directories where the repositories will be cloned.
SET CONFIG_SERVER_DIR=glf-configServer
SET SERVICE_DISCOVERY_DIR=glf-servicediscovery
SET API_GATEWAY_DIR=glf-api-gateway
SET ACCOUNTS_DIR=glf-accounts
SET COMMUNITIES_DIR=glf-communities

REM Branches/Tags to checkout.
SET CONFIG_SERVER_BRANCH=main
SET SERVICE_DISCOVERY_BRANCH=main
SET API_GATEWAY_BRANCH=main
SET ACCOUNTS_BRANCH=main
SET COMMUNITIES_BRANCH=main

REM Temporary directory for cloning
SET TEMP_DIR=%HOME%\.temp

REM Target directory for moving the cloned repositories
SET TARGET_DIR=..\..\..\..\..

REM ====================================================================================================================

CALL :log Preparing the development environment for the project...

REM ---------------- Create temporary directory ----------------
IF EXIST %TEMP_DIR% (
    CALL :log Removing the existing temporary directory...
    RD /S /Q %TEMP_DIR% || goto :error
)
CALL :log Creating temporary directory...
MKDIR %TEMP_DIR% || goto :error

CALL :switchDirectory %TEMP_DIR%

REM ---------------- Config Server ----------------
CALL :checkAndClone %CONFIG_SERVER_REPO% %CONFIG_SERVER_DIR% ConfigServer

REM ---------------- Service Discovery ----------------
CALL :checkAndClone %SERVICE_DISCOVERY_REPO% %SERVICE_DISCOVERY_DIR% ServiceDiscovery

REM ---------------- API Gateway ----------------
CALL :checkAndClone %API_GATEWAY_REPO% %API_GATEWAY_DIR% ApiGateway

REM ---------------- Accounts ----------------
CALL :checkAndClone %ACCOUNTS_REPO% %ACCOUNTS_DIR% Accounts

REM ---------------- Communities ----------------
CALL :checkAndClone %COMMUNITIES_REPO% %COMMUNITIES_DIR% Communities

REM ---------------- Clean up temporary directory ----------------
CALL :switchDirectory %HOME%
CALL :log Cleaning up temporary directory...
RD /S /Q %TEMP_DIR% || goto :error

CALL :log The development environment has been prepared successfully.

IF "%DEBUG%"=="true" (
    exit /b 0
) ELSE (
    cmd /k
)

REM ====================================================================================================================
REM ------------------------------------------------ Functions ---------------------------------------------------------

:checkAndClone
REM This function will check if the repository directory exists in the target location.
REM If it does not exist, it will clone the repository.
REM Parameters:
REM    1. The repository URL.
REM    2. The directory where the repository should be cloned.
REM    3. The name of the repository.
CALL :debug Function 'checkAndClone' called with parameters "%*"
IF EXIST "%TARGET_DIR%\%2" (
    CALL :log %3 already exists in the target directory. Skipping clone.
) ELSE (
    CALL :clone %1 %2 %3
    CALL :moveRepo %2
)
CALL :debug Function 'checkAndClone' finished.
goto :eof

:clone
REM This function will clone the repository.
REM Parameters:
REM    1. The repository URL.
REM    2. The directory where the repository should be cloned.
REM    3. The name of the repository.
CALL :debug Function 'clone' called with parameters "%*"
CALL :log Cloning "%3"...
%GIT% clone "%1" "%2" || goto :error
CALL :log %3 has been cloned successfully.
CALL :debug Function 'clone' finished.
goto :eof

:moveRepo
REM This function will move the cloned repository to the target directory.
REM Parameters:
REM    1. The directory to move.
CALL :debug Function 'moveRepo' called with parameters "%*"
CALL :log Moving "%1" to target directory...
MOVE "%1" "%TARGET_DIR%" || goto :error
CALL :log %1 has been moved successfully.
CALL :debug Function 'moveRepo' finished.
goto :eof

:switchDirectory
REM This function will switch to the specified directory.
REM Parameters:
REM    1. The directory to switch to.
CALL :debug Switching to %1
CD %1 || goto :error
CALL :debug Switched to %cd%
goto :eof

:log
echo [INFO] %*
goto :eof

:debug
IF "%DEBUG%"=="true" (
echo.
echo [DEBUG] %*
)
goto :eof

:error
echo [ERROR] %*
goto :eof