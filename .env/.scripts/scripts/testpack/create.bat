@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

REM === General ===
SET DEFAULT_PROJECT_NAME=Testpack Creator
SET DEBUG=false

REM === Build Flags ===
SET BUILD_WITH_TESTS=false

REM === Maven ===
SET MVN=mvn
SET OS_PROFILE=windows

REM === Paths (relative from SCRIPT_DIR) ===
SET SCRIPT_DIR="%CD%"
SET HOME_DIR="%SCRIPT_DIR%\..\..\..\.."
SET TEMP_DIR=%CD%\.temp
SET TARGET_DIR=%CD%\target
SET LOCAL_MAVEN_REPO=%CD%\..\..\..\..\.env\.tools\maven-repo

SET ACCOUNTS_DIR="%HOME_DIR%\glf-accounts"
SET COMMUNITIES_DIR="%HOME_DIR%\glf-communities"
SET CONFIG_SERVER_DIR="%HOME_DIR%\glf-configServer"
SET SERVICE_DISCOVERY_DIR="%HOME_DIR%\glf-servicediscovery"
SET API_GATEWAY_DIR="%HOME_DIR%\glf-api-gateway"
SET WEBCLIENT_DIR="%HOME_DIR%\glf-webclient"
SET KEYCLOAK_CONFIGURER_DIR="%HOME_DIR%\.env\.docker\keycloak\config-image"

REM === Source .env files (to copy into testpack) ===
SET SINGLE_DB_ENV=%CD%\..\..\..\..\.env\.docker\compose\qa\single-db\.env
SET MULTI_DB_ENV=%CD%\..\..\..\..\.env\.docker\compose\qa\multi-db\.env

REM === Docker Image Names ===
SET ACCOUNTS_IMAGE=com.goaleaf/glf-accounts:0.0.1-SNAPSHOT
SET COMMUNITIES_IMAGE=com.goaleaf/glf-communities:0.0.1-SNAPSHOT
SET CONFIGSERVER_IMAGE=com.goaleaf/glf-configserver:0.0.1-SNAPSHOT
SET APIGATEWAY_IMAGE=com.goaleaf/glf-api-gateway:0.0.1-SNAPSHOT
SET SERVICEDISCOVERY_IMAGE=com.goaleaf/glf-servicediscovery:0.0.1-SNAPSHOT
SET WEBCLIENT_IMAGE=glf-webclient
SET KEYCLOAK_CONFIGURER_IMAGE=keycloak-configurer:runtime

REM === .tar Output Filenames ===
SET ACCOUNTS_TAR=glf-accounts.tar
SET COMMUNITIES_TAR=glf-communities.tar
SET CONFIGSERVER_TAR=glf-configserver.tar
SET APIGATEWAY_TAR=glf-api-gateway.tar
SET SERVICEDISCOVERY_TAR=glf-servicediscovery.tar
SET WEBCLIENT_TAR=glf-webclient.tar
SET KEYCLOAK_CONFIGURER_TAR=keycloak-configurer.tar

REM === Version (auto-generated timestamp: yyyyMMddHHmmss) ===
FOR /F %%i IN ('powershell -NoProfile -Command "Get-Date -Format yyyyMMddHHmmss"') DO SET TESTPACK_VERSION=%%i

REM === Output ===
SET TESTPACK_ZIP=goaleaf-testpack-%TESTPACK_VERSION%.zip

REM =======================================================================================================

REM Set the default project name.
SET PROJECT_NAME=%DEFAULT_PROJECT_NAME%

REM Clean and create .temp/ directory
IF EXIST "%TEMP_DIR%" rd /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

REM Create target/ directory
IF NOT EXIST "%TARGET_DIR%" mkdir "%TARGET_DIR%"

REM =======================================================================================================

CALL :logASCII
ECHO.
timeout /t 1 /nobreak >nul

CALL :log Starting testpack creation...
ECHO.

REM =============================== BUILD PHASE ===============================

CALL :logDelimiter
CALL :buildAccounts

CALL :logDelimiter
CALL :buildCommunities

CALL :logDelimiter
CALL :buildConfigServer

CALL :logDelimiter
CALL :buildServiceDiscovery

CALL :logDelimiter
CALL :buildApiGateway

CALL :logDelimiter
CALL :buildWebclient

CALL :logDelimiter
CALL :buildKeycloakConfigurer

REM =============================== SAVE PHASE ===============================

CALL :logDelimiter
CALL :saveImages

REM =============================== PACKAGE PHASE ===============================

CALL :logDelimiter
CALL :createTestpack

REM =============================== CLEANUP ===============================

CALL :logDelimiter
CALL :cleanup

REM =============================== SUCCESS ===============================

ECHO.
SET PROJECT_NAME=%DEFAULT_PROJECT_NAME%
CALL :log =================================================================================================
CALL :log =================================================================================================
CALL :log Testpack created successfully!
CALL :log Output: %TARGET_DIR%\%TESTPACK_ZIP%
CALL :log =================================================================================================
CALL :log =================================================================================================
exit /b 0

REM =================================================================================================
REM Build Functions
REM =================================================================================================

REM This function will build the Accounts project.
:buildAccounts
CALL :debug Function buildAccounts started...
CALL :debug Setting the project name to Accounts...
SET PROJECT_NAME=Accounts
CALL :log Building Accounts...
CALL :switchDirectory %SCRIPT_DIR%
SET ACCOUNTS_CMD=clean install
IF "%BUILD_WITH_TESTS%" == "false" (
    CALL :debug Skipping tests for Accounts...
    SET ACCOUNTS_CMD=%ACCOUNTS_CMD% -DskipTests
)
SET ACCOUNTS_CMD=%ACCOUNTS_CMD% -P %OS_PROFILE%,withDockerImage
SET ACCOUNTS_CMD=%ACCOUNTS_CMD% -Dmaven.repo.local=%LOCAL_MAVEN_REPO%
CALL :debug Final command "[ %ACCOUNTS_CMD% ]"
CALL :switchDirectory %ACCOUNTS_DIR%
CALL :log Running maven command for Accounts "%ACCOUNTS_CMD%"
%MVN% %ACCOUNTS_CMD% || goto :error
CALL :log Accounts has been built successfully.
CALL :debug Function buildAccounts ended...
goto :eof

REM This function will build the Communities project.
:buildCommunities
CALL :debug Function buildCommunities started...
CALL :debug Setting the project name to Communities...
SET PROJECT_NAME=Communities
CALL :log Building Communities...
CALL :switchDirectory %SCRIPT_DIR%
SET COMMUNITIES_CMD=clean install
IF "%BUILD_WITH_TESTS%" == "false" (
    CALL :debug Skipping tests for Communities...
    SET COMMUNITIES_CMD=%COMMUNITIES_CMD% -DskipTests
)
SET COMMUNITIES_CMD=%COMMUNITIES_CMD% -P %OS_PROFILE%,withDockerImage
SET COMMUNITIES_CMD=%COMMUNITIES_CMD% -Dmaven.repo.local=%LOCAL_MAVEN_REPO%
CALL :debug Final command "[ %COMMUNITIES_CMD% ]"
CALL :switchDirectory %COMMUNITIES_DIR%
CALL :log Running maven command for Communities "%COMMUNITIES_CMD%"
%MVN% %COMMUNITIES_CMD% || goto :error
CALL :log Communities has been built successfully.
CALL :debug Function buildCommunities ended...
goto :eof

REM This function will build the ConfigServer project.
:buildConfigServer
CALL :debug Function buildConfigServer started...
CALL :debug Setting the project name to ConfigServer...
SET PROJECT_NAME=ConfigServer
CALL :log Building ConfigServer...
CALL :switchDirectory %SCRIPT_DIR%
SET CONFIGSERVER_CMD=clean install
IF "%BUILD_WITH_TESTS%" == "false" (
    CALL :debug Skipping tests for ConfigServer...
    SET CONFIGSERVER_CMD=%CONFIGSERVER_CMD% -DskipTests
)
SET CONFIGSERVER_CMD=%CONFIGSERVER_CMD% -P %OS_PROFILE%,withDockerImage
SET CONFIGSERVER_CMD=%CONFIGSERVER_CMD% -Dmaven.repo.local=%LOCAL_MAVEN_REPO%
CALL :debug Final command "[ %CONFIGSERVER_CMD% ]"
CALL :switchDirectory %CONFIG_SERVER_DIR%
CALL :log Running maven command for ConfigServer "%CONFIGSERVER_CMD%"
%MVN% %CONFIGSERVER_CMD% || goto :error
CALL :log ConfigServer has been built successfully.
CALL :debug Function buildConfigServer ended...
goto :eof

REM This function will build the ServiceDiscovery project.
:buildServiceDiscovery
CALL :debug Function buildServiceDiscovery started...
CALL :debug Setting the project name to ServiceDiscovery...
SET PROJECT_NAME=ServiceDiscovery
CALL :log Building ServiceDiscovery...
CALL :switchDirectory %SCRIPT_DIR%
SET SERVICEDISCOVERY_CMD=clean install
IF "%BUILD_WITH_TESTS%" == "false" (
    CALL :debug Skipping tests for ServiceDiscovery...
    SET SERVICEDISCOVERY_CMD=%SERVICEDISCOVERY_CMD% -DskipTests
)
SET SERVICEDISCOVERY_CMD=%SERVICEDISCOVERY_CMD% -P %OS_PROFILE%,withDockerImage
SET SERVICEDISCOVERY_CMD=%SERVICEDISCOVERY_CMD% -Dmaven.repo.local=%LOCAL_MAVEN_REPO%
CALL :debug Final command "[ %SERVICEDISCOVERY_CMD% ]"
CALL :switchDirectory %SERVICE_DISCOVERY_DIR%
CALL :log Running maven command for ServiceDiscovery "%SERVICEDISCOVERY_CMD%"
%MVN% %SERVICEDISCOVERY_CMD% || goto :error
CALL :log ServiceDiscovery has been built successfully.
CALL :debug Function buildServiceDiscovery ended...
goto :eof

REM This function will build the ApiGateway project.
:buildApiGateway
CALL :debug Function buildApiGateway started...
CALL :debug Setting the project name to ApiGateway...
SET PROJECT_NAME=ApiGateway
CALL :log Building ApiGateway...
CALL :switchDirectory %SCRIPT_DIR%
SET APIGATEWAY_CMD=clean install
IF "%BUILD_WITH_TESTS%" == "false" (
    CALL :debug Skipping tests for ApiGateway...
    SET APIGATEWAY_CMD=%APIGATEWAY_CMD% -DskipTests
)
SET APIGATEWAY_CMD=%APIGATEWAY_CMD% -P %OS_PROFILE%,withDockerImage
SET APIGATEWAY_CMD=%APIGATEWAY_CMD% -Dmaven.repo.local=%LOCAL_MAVEN_REPO%
CALL :debug Final command "[ %APIGATEWAY_CMD% ]"
CALL :switchDirectory %API_GATEWAY_DIR%
CALL :log Running maven command for ApiGateway "%APIGATEWAY_CMD%"
%MVN% %APIGATEWAY_CMD% || goto :error
CALL :log ApiGateway has been built successfully.
CALL :debug Function buildApiGateway ended...
goto :eof

REM This function will build the Webclient docker image.
:buildWebclient
CALL :debug Function buildWebclient started...
CALL :debug Setting the project name to Webclient...
SET PROJECT_NAME=Webclient
CALL :log Building Webclient docker image...
CALL :switchDirectory %SCRIPT_DIR%
CALL :switchDirectory %WEBCLIENT_DIR%
docker build -t %WEBCLIENT_IMAGE% --no-cache . || goto :error
CALL :log Webclient docker image has been built successfully.
CALL :debug Function buildWebclient ended...
goto :eof

REM This function will build the keycloak-configurer:runtime image.
:buildKeycloakConfigurer
CALL :debug Function buildKeycloakConfigurer started...
CALL :debug Setting the project name to KeycloakConfigurer...
SET PROJECT_NAME=KeycloakConfigurer
CALL :log Building keycloak-configurer (runtime) docker image...
CALL :switchDirectory %SCRIPT_DIR%
CALL :switchDirectory %KEYCLOAK_CONFIGURER_DIR%
docker build -t %KEYCLOAK_CONFIGURER_IMAGE% --no-cache . || goto :error
CALL :log Keycloak-configurer image (runtime) has been built successfully.
CALL :debug Function buildKeycloakConfigurer ended...
goto :eof

REM =================================================================================================
REM Save Phase
REM =================================================================================================

:saveImages
SET PROJECT_NAME=Docker Save
CALL :log Saving Docker images as .tar archives...
CALL :switchDirectory %SCRIPT_DIR%

CALL :log Saving %ACCOUNTS_IMAGE% as %ACCOUNTS_TAR%...
docker save -o "%TEMP_DIR%\%ACCOUNTS_TAR%" %ACCOUNTS_IMAGE% || goto :error

CALL :log Saving %COMMUNITIES_IMAGE% as %COMMUNITIES_TAR%...
docker save -o "%TEMP_DIR%\%COMMUNITIES_TAR%" %COMMUNITIES_IMAGE% || goto :error

CALL :log Saving %CONFIGSERVER_IMAGE% as %CONFIGSERVER_TAR%...
docker save -o "%TEMP_DIR%\%CONFIGSERVER_TAR%" %CONFIGSERVER_IMAGE% || goto :error

CALL :log Saving %APIGATEWAY_IMAGE% as %APIGATEWAY_TAR%...
docker save -o "%TEMP_DIR%\%APIGATEWAY_TAR%" %APIGATEWAY_IMAGE% || goto :error

CALL :log Saving %SERVICEDISCOVERY_IMAGE% as %SERVICEDISCOVERY_TAR%...
docker save -o "%TEMP_DIR%\%SERVICEDISCOVERY_TAR%" %SERVICEDISCOVERY_IMAGE% || goto :error

CALL :log Saving %WEBCLIENT_IMAGE% as %WEBCLIENT_TAR%...
docker save -o "%TEMP_DIR%\%WEBCLIENT_TAR%" %WEBCLIENT_IMAGE% || goto :error

CALL :log Saving %KEYCLOAK_CONFIGURER_IMAGE% as %KEYCLOAK_CONFIGURER_TAR%...
docker save -o "%TEMP_DIR%\%KEYCLOAK_CONFIGURER_TAR%" %KEYCLOAK_CONFIGURER_IMAGE% || goto :error

CALL :log All Docker images saved successfully.
goto :eof

REM =================================================================================================
REM Package Phase
REM =================================================================================================

:createTestpack
SET PROJECT_NAME=Testpack Packager
CALL :log Assembling testpack...
CALL :switchDirectory %SCRIPT_DIR%

REM Create staging area
SET STAGING_DIR=%TEMP_DIR%\goaleaf-testpack
mkdir "%STAGING_DIR%"
mkdir "%STAGING_DIR%\.images"
mkdir "%STAGING_DIR%\compose"
mkdir "%STAGING_DIR%\compose\single-db"
mkdir "%STAGING_DIR%\compose\multi-db"

REM Copy .tar files into .images/
CALL :log Copying Docker image archives...
copy "%TEMP_DIR%\*.tar" "%STAGING_DIR%\.images\" >nul || goto :error

REM Copy docker-compose files
CALL :log Copying docker-compose files...
copy "%CD%\.scripts\compose\single-db\docker-compose.yml" "%STAGING_DIR%\compose\single-db\" >nul || goto :error
copy "%CD%\.scripts\compose\multi-db\docker-compose.yml" "%STAGING_DIR%\compose\multi-db\" >nul || goto :error

REM Copy .env files from existing qa compose dirs
CALL :log Copying .env files...
copy "%SINGLE_DB_ENV%" "%STAGING_DIR%\compose\single-db\.env" >nul || goto :error
copy "%MULTI_DB_ENV%" "%STAGING_DIR%\compose\multi-db\.env" >nul || goto :error

REM Copy runner scripts and README
CALL :log Copying runner scripts...
copy "%CD%\.scripts\start.bat" "%STAGING_DIR%\" >nul || goto :error
copy "%CD%\.scripts\stop.bat" "%STAGING_DIR%\" >nul || goto :error
copy "%CD%\.scripts\clear.bat" "%STAGING_DIR%\" >nul || goto :error
copy "%CD%\.scripts\README.txt" "%STAGING_DIR%\" >nul || goto :error

REM Delete existing zip if present
IF EXIST "%TARGET_DIR%\%TESTPACK_ZIP%" del "%TARGET_DIR%\%TESTPACK_ZIP%"

REM Create zip
CALL :log Creating %TESTPACK_ZIP%...
powershell -Command "Compress-Archive -Path '%STAGING_DIR%\*' -DestinationPath '%TARGET_DIR%\%TESTPACK_ZIP%' -Force" || goto :error

CALL :log Testpack has been assembled and zipped successfully.
goto :eof

REM =================================================================================================
REM Cleanup Phase
REM =================================================================================================

:cleanup
SET PROJECT_NAME=Cleanup
CALL :log Cleaning up temporary files...
rd /s /q "%TEMP_DIR%"
CALL :log Temporary files cleaned up.
goto :eof

REM =================================================================================================
REM Utility Functions
REM =================================================================================================

:switchDirectory
REM Switches to the specified directory.
REM Parameters:
REM    1. The directory to switch to.
CALL :debug Switching to %1
CD %1 || goto :error
CALL :debug Switched to %cd%
goto :eof

REM Prints a delimiter in the log.
:logDelimiter
SET PROJECT_NAME=%DEFAULT_PROJECT_NAME%
ECHO.
CALL :log =================================================================================================
CALL :log =================================================================================================
CALL :log =================================================================================================
ECHO.
goto :eof

REM Prints a message in the log.
REM Parameters:
REM    1. The message to be printed.
:log
ECHO %PROJECT_NAME% --- [INFO] %*
goto :eof

REM Prints a message in the log when the debug mode is on.
REM Parameters:
REM    1. The message to be printed.
:debug
IF "%DEBUG%" == "true" (
ECHO %DATE% %TIME% %USERNAME% %COMPUTERNAME% --- %PROJECT_NAME% --- [DEBUG] %*
)
goto :eof

REM Prints an error message in the log.
:error
ECHO %DATE% %TIME% %USERNAME% %COMPUTERNAME% %CD% --- %PROJECT_NAME% --- [ERROR] %*
EXIT /B 1
goto :eof

:logASCII
:::
:::   _____         _                  _       ____                _
:::  |_   _|__  ___| |_ _ __  __ _  _| |__   / ___|_ __ ___  __ _| |_ ___  _ __
:::    | |/ _ \/ __| __| '_ \/ _` |/ __| / / | |   | '__/ _ \/ _` | __/ _ \| '__|
:::    | |  __/\__ \ |_| |_) | (_| | (__|  <  | |___| | |  __/ (_| | || (_) | |
:::    |_|\___||___/\__|  .__/\__,_|\___|_\_\  \____|_|  \___|\__,_|\__\___/|_|
:::                     |_|
:::
for /f "delims=: tokens=*" %%A in ('findstr /b ::: "%~f0"') do @echo(%%A
goto :eof
