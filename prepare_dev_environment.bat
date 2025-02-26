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
SET DEBUG=true

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

REM ====================================================================================================================

CALL :log Preparing the development environment for the project...

CALL :switchDirectory %HOME%

REM ---------------- Config Server ----------------
IF NOT EXIST "%CONFIG_SERVER_REPO%" (
    CALL :clone %CONFIG_SERVER_REPO% %CONFIG_SERVER_DIR% ConfigServer
) ELSE (
    CALL :update %CONFIG_SERVER_DIR% ConfigServer %CONFIG_SERVER_BRANCH%
)

CALL :switchDirectory %HOME%

REM ---------------- Service Discovery ----------------
IF NOT EXIST "%SERVICE_DISCOVERY_REPO%" (
    CALL :clone %SERVICE_DISCOVERY_REPO% %SERVICE_DISCOVERY_DIR% ServiceDiscovery
) ELSE (
    CALL :update %SERVICE_DISCOVERY_DIR% ServiceDiscovery %SERVICE_DISCOVERY_BRANCH%
)

CALL :switchDirectory %HOME%

REM ---------------- API Gateway ----------------
IF NOT EXIST "%API_GATEWAY_REPO%" (
    CALL :clone %API_GATEWAY_REPO% %API_GATEWAY_DIR% ApiGateway
) ELSE (
    CALL :update %API_GATEWAY_DIR% ApiGateway %API_GATEWAY_BRANCH%
)

CALL :switchDirectory %HOME%

REM ---------------- Accounts ----------------
IF NOT EXIST "%ACCOUNTS_REPO%" (
    CALL :clone %ACCOUNTS_REPO% %ACCOUNTS_DIR% Accounts
) ELSE (
    CALL :update %ACCOUNTS_DIR% Accounts %ACCOUNTS_BRANCH%
)

CALL :switchDirectory %HOME%

REM ---------------- Communities ----------------
IF NOT EXIST "%COMMUNITIES_REPO%" (
    CALL :clone %COMMUNITIES_REPO% %COMMUNITIES_DIR% Communities
) ELSE (
    CALL :update %COMMUNITIES_DIR% Communities %COMMUNITIES_BRANCH%
)

CALL :log The development environment has been prepared successfully.

CALL :switchDirectory %SCRIPTS%

exit /b 0

REM ====================================================================================================================
REM ------------------------------------------------ Functions ---------------------------------------------------------

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

:update
REM This function will update the repository.
REM Parameters:
REM    1. The directory where the repository is located.
REM    2. The name of the repository.
REM    3. The branch/tag to checkout.
CALL :debug Function 'update' called with parameters "%*"
CALL :log Pulling the latest changes for "%2"...
CALL :switchDirectory "%1"
CALL :debug Fetching all...
%GIT% fetch --all || goto :error
CALL :debug Finished fetching all.
CALL :debug Checking out "%3"...
%GIT% checkout "%3" || goto :error
CALL :debug Finished checking out "%3".
CALL :debug Pulling...
%GIT% pull || goto :error
CALL :debug Finished pulling.
CALL :switchDirectory "%HOME%"
CALL :log %2 has been updated successfully.
CALL :debug Function 'update' finished.
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
echo [INFO] %* || goto :error
goto :eof

:debug
IF "%DEBUG%"=="true" (
echo.
echo [DEBUG] %* || goto :eof
goto :eof
)

:error
echo [ERROR] %* || goto :eof
