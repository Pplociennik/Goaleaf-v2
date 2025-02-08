ECHO OFF

REM This script is used to build the auth component Docker image. The auth component is necessary for the rest of microservices to work as it provides the authentication and authorization functionalities.

REM Requirements:
REM    1. Git installed and available in the PATH.
REM    2. Maven installed and available in the PATH.
REM    3. Docker installed and available in the PATH.
REM    4. The path to the local maven repository must be provided.
REM    5. The branches/tags to be built must be provided.

REM Environment:

REM A path to the local installation of Maven (if not available in the PATH). Use 'mvn' if Maven is available in the PATH.
SET MVN=mvn
REM A path to the local Git installation (if not available in the PATH). Use 'git' if Git is available in the PATH.
SET GIT=git

REM A path to the local maven repository.
SET MAVEN_REPO=D:\Development\Maven\local_m2\repository
REM The branches/tags to be built.
SET PP_AUTH_BRANCH_OR_TAG=master

REM These are constants used in the script:
SET HOME=%CD%
SET TEMP_DIR=%HOME%\.temp-auth

REM These are the paths to the libraries' repositories:
SET PP_AUTH_REPO=https://github.com/Pplociennik/pp-auth.git

CALL :log Building the PP-AUTH component...

REM ---------------- First remove temporary directories, if they exist ----------------

IF EXIST %TEMP_DIR% (
    CALL :log Removing the existing temporary directories...
    RD /S /Q %TEMP_DIR% || goto :error
)

REM ---------------- Create temporary directories ----------------

CALL :log Creating temporary directories...
MKDIR %TEMP_DIR% || goto :error

REM ---------------- Clone the repository ----------------

CALL :log Cloning the repositories...
%GIT% clone %PP_AUTH_REPO% %TEMP_DIR%/pp-auth || goto :error
CALL :log Cloning pp-auth completed successfully.

REM ---------------- Build the component ----------------

CALL :log Building the component...
CD %TEMP_DIR%/pp-auth || goto :error
CALL :build || goto :error
CALL :log Building the component completed successfully.

REM ---------------- Clean up ----------------

CALL :log Cleaning up...
CD %HOME% || goto :error
RD /S /Q %TEMP_DIR% || goto :error

REM ---------------- Done ----------------

CALL :log Component built successfully.
goto :eof

REM ---------------- Functions ----------------

:build
%MVN% clean install -Dmaven.repo.local=%MAVEN_REPO% -PwithDockerImage -DskipTests || goto :error
goto :eof

:log
echo [INFO] %* || goto :error
goto :eof

:error
echo [ERROR] %* || goto :eof