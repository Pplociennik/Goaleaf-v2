ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

REM Path to the .env file
SET ENV_FILE="%cd%\.env"
SET DEFAULT_PROJECT_NAME=Setup script

REM Settings
REM Debug mode. Prints additional information.
SET DEBUG=false
REM Maven executable. Just use 'mvn' if it is in the PATH.
SET MVN=mvn
REM List of variables that can have values different than 'true' or 'false'.
SET EXCEPTIONS_LIST="ACTIVE_PROFILE OS LOCAL_MAVEN_REPOSITORY DOCKER_COMPOSE_SINGLE_DB DOCKER_COMPOSE_MULTI_DB WITHOUT_OBSERVABILITY ONLY_SINGLE_DATABASE ONLY_MULTI_DATABASE"
REM ATTENTION: These variables should not be changed.
SET SCRIPT_DIR="%CD%"
SET HOME_DIR="%SCRIPT_DIR%\..\..\..\..\.."
SET ACCOUNTS_DIR="%HOME_DIR%\glf-accounts"
SET COMMUNITIES_DIR="%HOME_DIR%\glf-communities"
SET CONFIG_SERVER_DIR="%HOME_DIR%\glf-configServer"
SET SERVICE_DISCOVERY_DIR="%HOME_DIR%\glf-servicediscovery"
SET API_GATEWAY_DIR="%HOME_DIR%\glf-api-gateway"

SET WEBCLIENT_DIR="%HOME_DIR%\glf-webclient"

REM =======================================================================================================

REM Set the default project name.
SET PROJECT_NAME=%DEFAULT_PROJECT_NAME%

REM Read the .env file and set the variables. Prints an error if the value is not 'true' or 'false' (excluding variables from the exceptions list).
FOR /F "tokens=1,2 delims==" %%A IN ('TYPE %ENV_FILE% ^| FINDSTR /R "^[a-zA-Z]"') DO (
    SET %%A=%%B
    SET "IS_EXCEPTION=false"
    FOR %%E IN (%EXCEPTIONS_LIST%) DO (
        IF /I "%%A"=="%%E" SET "IS_EXCEPTION=true"
    )
    IF /I "%IS_EXCEPTION%"=="false" IF /I NOT "%%B"=="true" IF /I NOT "%%B"=="false" (
        ECHO [ERROR] Invalid value "%%B" for variable "%%A". Expected "true" or "false".
        EXIT /B 1
    )
)
CALL :log Loaded environment variables from .env file

REM =======================================================================================================

CALL :log Starting the setup...

IF "%BUILD_ACCOUNTS%" == "true" (
    CALL :logDelimiter
    CALL :buildAccounts
)

IF "%BUILD_COMMUNITIES%" == "true" (
    CALL :logDelimiter
    CALL :buildCommunities
)

IF "%BUILD_CONFIGSERVER%" == "true" (
    CALL :logDelimiter
    CALL :buildConfigServer
)

IF "%BUILD_SERVICEDISCOVERY%" == "true" (
    CALL :logDelimiter
    CALL :buildServiceDiscovery
)

IF "%BUILD_APIGATEWAY%" == "true" (
    CALL :logDelimiter
    CALL :buildApiGateway
)

IF "%WEBCLIENT_BUILD_DOCKER_IMAGE%" == "true" (
    CALL :logDelimiter
    CALL :buildWebclient
)

IF "%RUN_ON_DOCKER%" == "true" (
    CALL :logDelimiter
    CALL :runOnDocker
)

ECHO.
SET PROJECT_NAME=%DEFAULT_PROJECT_NAME%
CALL :log Setup completed successfully.
exit /b 0

REM =================================================================================================

REM This function will build the Accounts project.
:buildAccounts
CALL :debug Function buildAccounts started...
CALL :debug Setting the project name to Accounts...
SET PROJECT_NAME=Accounts
CALL :log Building Accounts...
CALL :debug [ "BUILD_ACCOUNTS=%BUILD_ACCOUNTS%, BUILD_ACCOUNTS_DOCKER_IMAGE=%BUILD_ACCOUNTS_DOCKER_IMAGE%, BUILD_ACCOUNTS_WITH_TESTS=%BUILD_ACCOUNTS_WITH_TESTS%, RUN_UNIT_TESTS=%RUN_UNIT_TESTS%, BUILD_ACCOUNTS_OFFLINE=%BUILD_ACCOUNTS_OFFLINE%" ]
CALL :switchDirectory %SCRIPT_DIR%
SET ACCOUNTS_CMD=clean install
IF "%BUILD_ACCOUNTS_OFFLINE%" == "true" (
    CALL :debug Building Accounts in offline mode...
    SET ACCOUNTS_CMD=-o %ACCOUNTS_CMD%
    CALL :debug Current command "%ACCOUNTS_CMD%"
)
IF "%BUILD_ACCOUNTS_WITH_TESTS%" == "false" (
    CALL :debug Skipping tests for Accounts...
    SET ACCOUNTS_CMD=%ACCOUNTS_CMD% -DskipTests
    CALL :debug Current command "%ACCOUNTS_CMD%"
)
CALL :debug Setting the OS to %OS%...
SET ACCOUNTS_CMD=%ACCOUNTS_CMD% -P %OS%
CALL :debug Current command "%ACCOUNTS_CMD%"
IF "%RUN_INTEGRATION_TESTS%" == "true" (
    CALL :debug Building Accounts with integration tests...
    SET ACCOUNTS_CMD=%ACCOUNTS_CMD%,integration
    CALL :debug Current command "%ACCOUNTS_CMD%"
)
IF "%BUILD_ACCOUNTS_DOCKER_IMAGE%" == "true" (
    CALL :debug Building Accounts with Docker image...
    SET ACCOUNTS_CMD=%ACCOUNTS_CMD%,withDockerImage
    CALL :debug Current command "%ACCOUNTS_CMD%"
)
IF NOT "%LOCAL_MAVEN_REPOSITORY%" == "" (
    CALL :debug Using local Maven repository...
    SET ACCOUNTS_CMD=%ACCOUNTS_CMD% -Dmaven.repo.local=%cd%\%LOCAL_MAVEN_REPOSITORY%
    CALL :debug Current command "%ACCOUNTS_CMD%"
)
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
CALL :debug [ "BUILD_COMMUNITIES=%BUILD_COMMUNITIES%, BUILD_COMMUNITIES_DOCKER_IMAGE=%BUILD_COMMUNITIES_DOCKER_IMAGE%, BUILD_COMMUNITIES_WITH_TESTS=%BUILD_COMMUNITIES_WITH_TESTS%, BUILD_COMMUNITIES_OFFLINE=%BUILD_COMMUNITIES_OFFLINE%" ]
CALL :switchDirectory %SCRIPT_DIR%
SET COMMUNITIES_CMD=clean install
IF "%BUILD_COMMUNITIES_OFFLINE%" == "true" (
    CALL :debug Building Communities in offline mode...
    SET COMMUNITIES_CMD=-o %COMMUNITIES_CMD%
    CALL :debug Current command "%COMMUNITIES_CMD%"
)
IF "%BUILD_COMMUNITIES_WITH_TESTS%" == "false" (
    CALL :debug Skipping tests for Communities...
    SET COMMUNITIES_CMD=%COMMUNITIES_CMD% -DskipTests
    CALL :debug Current command "%COMMUNITIES_CMD%"
)
CALL :debug Setting the OS to %OS%...
SET COMMUNITIES_CMD=%COMMUNITIES_CMD% -P %OS%
CALL :debug Current command "%COMMUNITIES_CMD%"
IF "%BUILD_COMMUNITIES_DOCKER_IMAGE%" == "true" (
    CALL :debug Building Communities with Docker image...
    SET COMMUNITIES_CMD=%COMMUNITIES_CMD%,withDockerImage
    CALL :debug Current command "%COMMUNITIES_CMD%"
)
IF NOT "%LOCAL_MAVEN_REPOSITORY%" == "" (
    CALL :debug Using local Maven repository...
    SET COMMUNITIES_CMD=%COMMUNITIES_CMD% -Dmaven.repo.local=%cd%\%LOCAL_MAVEN_REPOSITORY%
    CALL :debug Current command "%COMMUNITIES_CMD%"
)
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
CALL :debug [ "BUILD_CONFIGSERVER=%BUILD_CONFIGSERVER%, BUILD_CONFIGSERVER_DOCKER_IMAGE=%BUILD_CONFIGSERVER_DOCKER_IMAGE%, BUILD_CONFIGSERVER_WITH_TESTS=%BUILD_CONFIGSERVER_WITH_TESTS%, BUILD_CONFIGSERVER_OFFLINE=%BUILD_CONFIGSERVER_OFFLINE%" ]
CALL :switchDirectory %SCRIPT_DIR%
SET CONFIGSERVER_CMD=clean install
IF "%BUILD_CONFIGSERVER_OFFLINE%" == "true" (
    CALL :debug Building ConfigServer in offline mode...
    SET CONFIGSERVER_CMD=-o %CONFIGSERVER_CMD%
    CALL :debug Current command "%CONFIGSERVER_CMD%"
)
IF "%BUILD_CONFIGSERVER_WITH_TESTS%" == "false" (
    CALL :debug Skipping tests for ConfigServer...
    SET CONFIGSERVER_CMD=%CONFIGSERVER_CMD% -DskipTests
    CALL :debug Current command "%CONFIGSERVER_CMD%"
)
CALL :debug Setting the OS to %OS%...
SET CONFIGSERVER_CMD=%CONFIGSERVER_CMD% -P %OS%
CALL :debug Current command "%CONFIGSERVER_CMD%"
IF "%BUILD_CONFIGSERVER_DOCKER_IMAGE%" == "true" (
    CALL :debug Building ConfigServer with Docker image...
    SET CONFIGSERVER_CMD=%CONFIGSERVER_CMD%,withDockerImage
    CALL :debug Current command "%CONFIGSERVER_CMD%"
)
IF NOT "%LOCAL_MAVEN_REPOSITORY%" == "" (
    CALL :debug Using local Maven repository...
    SET CONFIGSERVER_CMD=%CONFIGSERVER_CMD% -Dmaven.repo.local=%cd%\%LOCAL_MAVEN_REPOSITORY%
    CALL :debug Current command "%CONFIGSERVER_CMD%"
)
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
CALL :debug [ "BUILD_SERVICEDISCOVERY=%BUILD_SERVICEDISCOVERY%, BUILD_SERVICEDISCOVERY_DOCKER_IMAGE=%BUILD_SERVICEDISCOVERY_DOCKER_IMAGE%, BUILD_SERVICEDISCOVERY_WITH_TESTS=%BUILD_SERVICEDISCOVERY_WITH_TESTS%, BUILD_SERVICEDISCOVERY_OFFLINE=%BUILD_SERVICEDISCOVERY_OFFLINE%" ]
CALL :switchDirectory %SCRIPT_DIR%
SET SERVICEDISCOVERY_CMD=clean install
IF "%BUILD_SERVICEDISCOVERY_OFFLINE%" == "true" (
    CALL :debug Building ServiceDiscovery in offline mode...
    SET SERVICEDISCOVERY_CMD=-o %SERVICEDISCOVERY_CMD%
    CALL :debug Current command "%SERVICEDISCOVERY_CMD%"
)
IF "%BUILD_SERVICEDISCOVERY_WITH_TESTS%" == "false" (
    CALL :debug Skipping tests for ServiceDiscovery...
    SET SERVICEDISCOVERY_CMD=%SERVICEDISCOVERY_CMD% -DskipTests
    CALL :debug Current command "%SERVICEDISCOVERY_CMD%"
)
CALL :debug Setting the OS to %OS%...
SET SERVICEDISCOVERY_CMD=%SERVICEDISCOVERY_CMD% -P %OS%
CALL :debug Current command "%SERVICEDISCOVERY_CMD%"
IF "%BUILD_SERVICEDISCOVERY_DOCKER_IMAGE%" == "true" (
    CALL :debug Building ServiceDiscovery with Docker image...
    SET SERVICEDISCOVERY_CMD=%SERVICEDISCOVERY_CMD%,withDockerImage
    CALL :debug Current command "%SERVICEDISCOVERY_CMD%"
)
IF NOT "%LOCAL_MAVEN_REPOSITORY%" == "" (
    CALL :debug Using local Maven repository...
    SET SERVICEDISCOVERY_CMD=%SERVICEDISCOVERY_CMD% -Dmaven.repo.local=%cd%\%LOCAL_MAVEN_REPOSITORY%
    CALL :debug Current command "%SERVICEDISCOVERY_CMD%"
)
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
CALL :debug [ "BUILD_APIGATEWAY=%BUILD_APIGATEWAY%, BUILD_APIGATEWAY_DOCKER_IMAGE=%BUILD_APIGATEWAY_DOCKER_IMAGE%, BUILD_APIGATEWAY_WITH_TESTS=%BUILD_APIGATEWAY_WITH_TESTS%, BUILD_APIGATEWAY_OFFLINE=%BUILD_APIGATEWAY_OFFLINE%" ]
CALL :switchDirectory %SCRIPT_DIR%
SET APIGATEWAY_CMD=clean install
IF "%BUILD_APIGATEWAY_OFFLINE%" == "true" (
    CALL :debug Building ApiGateway in offline mode...
    SET APIGATEWAY_CMD=-o %APIGATEWAY_CMD%
    CALL :debug Current command "%APIGATEWAY_CMD%"
)
IF "%BUILD_APIGATEWAY_WITH_TESTS%" == "false" (
    CALL :debug Skipping tests for ApiGateway...
    SET APIGATEWAY_CMD=%APIGATEWAY_CMD% -DskipTests
    CALL :debug Current command "%APIGATEWAY_CMD%"
)
CALL :debug Setting the OS to %OS%...
SET APIGATEWAY_CMD=%APIGATEWAY_CMD% -P %OS%
CALL :debug Current command "%APIGATEWAY_CMD%"
IF "%BUILD_APIGATEWAY_DOCKER_IMAGE%" == "true" (
    CALL :debug Building ApiGateway with Docker image...
    SET APIGATEWAY_CMD=%APIGATEWAY_CMD%,withDockerImage
    CALL :debug Current command "%APIGATEWAY_CMD%"
)
IF NOT "%LOCAL_MAVEN_REPOSITORY%" == "" (
    CALL :debug Using local Maven repository...
    SET APIGATEWAY_CMD=%APIGATEWAY_CMD% -Dmaven.repo.local=%cd%\%LOCAL_MAVEN_REPOSITORY%
    CALL :debug Current command "%APIGATEWAY_CMD%"
)
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
CALL :debug [ "WEBCLIENT_BUILD_DOCKER_IMAGE=%WEBCLIENT_BUILD_DOCKER_IMAGE%" ]
CALL :switchDirectory %SCRIPT_DIR%
IF "%WEBCLIENT_BUILD_DOCKER_IMAGE%" == "true" (
    CALL :debug Building Webclient docker image...
    CALL :switchDirectory %WEBCLIENT_DIR%
    docker build -t glf-webclient --no-cache . || goto :error
    CALL :log Webclient docker image has been built successfully.
)
CALL :debug Function buildWebClient ended...
goto :eof

REM Running on docker
:runOnDocker
CALL :log Running the development environment on Docker...
CALL :debug Running the development environment on Docker...
CALL :debug [ "RUN_ON_DOCKER=%RUN_ON_DOCKER%, RUN_IN_DETACHED_MODE=%RUN_IN_DETACHED_MODE%, SINGLE_DB=%SINGLE_DB%, OBSERVABILITY=%OBSERVABILITY%" ]
CALL :switchDirectory %SCRIPT_DIR%
SET DOCKER_COMPOSE_CMD=up
IF "%SINGLE_DB%" == "true" (
    CALL :debug Running the development environment with a single database...
    SET DOCKER_COMPOSE_CMD=-f "%DOCKER_COMPOSE_SINGLE_DB%" %DOCKER_COMPOSE_CMD%
    CALL :debug Current command "%DOCKER_COMPOSE_CMD%"
) ELSE (
    CALL :debug Running the development environment with multiple databases...
    SET DOCKER_COMPOSE_CMD=-f "%DOCKER_COMPOSE_MULTI_DB%" %DOCKER_COMPOSE_CMD%
    CALL :debug Current command "%DOCKER_COMPOSE_CMD%"
)
IF "%OBSERVABILITY%" == "false" (
    IF "%RUN_DATABASE_ONLY%" == "false" (
        CALL :debug Running the development environment without observability...
        SET DOCKER_COMPOSE_CMD=%DOCKER_COMPOSE_CMD% %WITHOUT_OBSERVABILITY%
        CALL :debug Current command "%DOCKER_COMPOSE_CMD%"
    ) ELSE (
        CALL :debug The RUN_DATABASE_ONLY variable is set to true. The command will not be modified.
    )
)
IF "%RUN_DATABASE_ONLY%" == "true" (
    CALL :log Running only the database...
    CALL :debug [ "ONLY_SINGLE_DATABASE=%ONLY_SINGLE_DATABASE%" ]
    IF "%SINGLE_DB%" == "true" (
        SET DOCKER_COMPOSE_CMD=%DOCKER_COMPOSE_CMD% %ONLY_SINGLE_DATABASE%
    ) ELSE (
        SET DOCKER_COMPOSE_CMD=%DOCKER_COMPOSE_CMD% %ONLY_MULTI_DATABASE%
    )
    CALL :debug Current command "%DOCKER_COMPOSE_CMD%"
)
IF "%RUN_IN_DETACHED_MODE%" == "true" (
    CALL :debug Running the development environment in detached mode...
    SET DOCKER_COMPOSE_CMD=%DOCKER_COMPOSE_CMD% -d
    CALL :debug Current command "%DOCKER_COMPOSE_CMD%"
)
CALL :debug Final command "[ docker compose %DOCKER_COMPOSE_CMD% ]"
CALL :log Running Docker Compose command "docker compose %DOCKER_COMPOSE_CMD%"
docker compose %DOCKER_COMPOSE_CMD% || goto :error
CALL :log The development environment has been started successfully.
CALL :debug Function runOnDocker ended...
goto :eof

REM Environment

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
goto :eof