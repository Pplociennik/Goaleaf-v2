ECHO OFF

REM This script is used to build the libraries needed for the PP projects.
REM The libraries are built in the following order:
REM    1. pp-base
REM    2. pp-commons
REM    3. pp-modinfo

REM Requirements:
REM    1. Git installed and available in the PATH.
REM    2. Maven installed and available in the PATH.
REM    3. The path to the local maven repository must be provided.
REM    4. The branches/tags to be built must be provided.

REM Environment:

REM A path to the local installation of Maven (if not available in the PATH). Use 'mvn' if Maven is available in the PATH.
SET MVN=mvn
REM A path to the local Git installation (if not available in the PATH). Use 'git' if Git is available in the PATH.
SET GIT=git

REM A path to the local maven repository.
SET MAVEN_REPO=..\..\..\.tools\maven-repo
REM The branches/tags to be built.
SET PP_BASE_BRANCH_OR_TAG=master
SET PP_COMMONS_BRANCH_OR_TAG=master
SET PP_MODINFO_BRANCH_OR_TAG=master

REM These are constants used in the script:
SET HOME=%CD%
SET TEMP_DIR=%HOME%\.temp

REM These are the paths to the libraries' repositories:
SET PP_BASE_REPO=https://github.com/Pplociennik/pp-base.git
SET PP_COMMONS_REPO=https://github.com/Pplociennik/pp-commons.git
SET PP_MODINFO_REPO=https://github.com/Pplociennik/pp-modinfo.git

CALL :log Building the libraries needed for the PP projects...

REM ---------------- First remove temporary directories, if they exist ----------------

IF EXIST %TEMP_DIR% (
    CALL :log Removing the existing temporary directories...
    RD /S /Q %TEMP_DIR% || goto :error
)

REM ---------------- Create temporary directories ----------------

CALL :log Creating temporary directories...
MKDIR %TEMP_DIR% || goto :error

REM ---------------- Clone the repositories ----------------

CALL :log Cloning the repositories...

CALL :log Cloning pp-base...
%GIT% clone %PP_BASE_REPO% %TEMP_DIR%/pp-base || goto :error

CALL :log Cloning pp-commons...
%GIT% clone %PP_COMMONS_REPO% %TEMP_DIR%/pp-commons || goto :error

CALL :log Cloning pp-modinfo...
%GIT% clone %PP_MODINFO_REPO% %TEMP_DIR%/pp-modinfo || goto :error

REM ---------------- Switch to the specified branches/tags ----------------

CALL :log Switching to the specified branches/tags...

CALL :log Switching to branch/tag %PP_BASE_BRANCH_OR_TAG% in pp-base...
CD %TEMP_DIR%/pp-base || goto :error
%GIT% checkout %PP_BASE_BRANCH_OR_TAG% || goto :error

CALL :log Switching to branch/tag %PP_COMMONS_BRANCH_OR_TAG% in pp-commons...

CD %TEMP_DIR%/pp-commons || goto :error
%GIT% checkout %PP_COMMONS_BRANCH_OR_TAG% || goto :error

CALL :log Switching to branch/tag %PP_MODINFO_BRANCH_OR_TAG% in pp-modinfo...
CD %TEMP_DIR%/pp-modinfo || goto :error
%GIT% checkout %PP_MODINFO_BRANCH_OR_TAG% || goto :error

REM ---------------- Build the libraries ----------------
CALL :log Building pp-base...
CD %TEMP_DIR%/pp-base || goto :error
CALL :build

CALL :log Building pp-commons...
CD %TEMP_DIR%/pp-commons || goto :error
CALL :build

CALL :log Building pp-modinfo...
CD %TEMP_DIR%/pp-modinfo || goto :error
CALL :build

REM ---------------- Clean up ----------------

CD %HOME% || goto :error
RD /S /Q %TEMP_DIR% || goto :error

REM ---------------- Done ----------------

CALL :log Building the libraries completed successfully.
goto :eof

REM ---------------- Functions ----------------

:build
%MVN% clean install -Dmaven.repo.local=%MAVEN_REPO% -DskipTests || goto :error
goto :eof

:log
echo [INFO] %* || goto :error
goto :eof

:error
echo [ERROR] %* || goto :eof