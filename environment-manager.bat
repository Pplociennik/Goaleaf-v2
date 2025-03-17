@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

REM Settings
SET DEFAULT_PROJECT_NAME=EnvManager
SET DEBUG=false

SET SCRIPT_DIR=%CD%
SET SUBSCRIPTS_DIR="%SCRIPT_DIR%\.env\.scripts\scripts\windows"

SET PROJECT_NAME=%DEFAULT_PROJECT_NAME%
SET PERMITTED_GOALS=CLONE DEPS RUN STOP CLEAN

SET ALL_GOALS_VALID=true

REM ==================================================================================================================================
REM Script flow
CALL :logStartingScreen
CALL :log Enter the number of the goal chain you want to execute:
SET /P GOAL=

SET CHAIN=

IF "%GOAL%" == "1" (
    SET CHAIN=RUN
) ELSE IF "%GOAL%" == "2" (
    SET CHAIN=STOP
) ELSE IF "%GOAL%" == "3" (
    SET CHAIN=DEPS
) ELSE IF "%GOAL%" == "4" (
    SET CHAIN=DEPS CLONE
) ELSE IF "%GOAL%" == "5" (
    SET CHAIN=CLEAN
) ELSE IF "%GOAL%" == "6" (
    SET CHAIN=DEPS CLONE RUN
) ELSE IF "%GOAL%" == "7" (
    SET CHAIN=DEPS RUN
) ELSE IF "%GOAL%" == "99" (
    SET /P CHAIN=Enter the goal chain you want to execute:
) ELSE (
    CALL :error The goal chain number %GOAL% is not valid.
    EXIT /B 1
)

CALL :validateChain
IF "%ALL_GOALS_VALID%" == "false" (
    CALL :error The goal chain %CHAIN% is not valid.
    goto :error
    EXIT /B 1
    goto :eof
) ELSE (
    CALL :executeChain
    CALL :log The goal chain %CHAIN% has been executed successfully.
    goto :eof
)
REM ==================================================================================================================================
REM Execution
:executeChain
    FOR %%A IN (%CHAIN%) DO (
        IF "%%A" == "CLONE" (
            CALL :callClone || goto :error
        ) ELSE IF "%%A" == "DEPS" (
            CALL :callDeps || goto :error
        ) ELSE IF "%%A" == "RUN" (
            CALL :callRun || goto :error
        ) ELSE IF "%%A" == "STOP" (
            CALL :callStop || goto :error
        ) ELSE IF "%%A" == "CLEAN" (
            CALL :callClean || goto :error
        )
    )
goto :eof

:validateChain
SET ALL_GOALS_VALID=true
FOR %%A IN (%CHAIN%) DO (
    SET GOAL_FOUND=false
    FOR %%B IN (%PERMITTED_GOALS%) DO (
        IF "%%A" == "%%B" (
            SET GOAL_FOUND=true
            GOTO :FOUND
        )
    )
    :FOUND
    IF "%GOAL_FOUND%" == "false" (
        CALL :error The goal %%A is not valid.
        SET ALL_GOALS_VALID=false
        EXIT /B 1
        goto :eof
    )
)
goto :eof

REM ==================================================================================================================================
REM Calling scripts
:callClone
CALL :log Executing the CLONE goal.
pushd "%SUBSCRIPTS_DIR%"
CALL "prepare_dev_environment.bat" || goto :error
popd
goto :eof

:callDeps
CALL :log Executing the DEPS goal.
pushd "%SUBSCRIPTS_DIR%"
CALL "build_pp_libs.bat" || goto :error
popd
goto :eof

:callRun
CALL :log Executing the RUN goal.
CALL :debug Running [ "%SUBSCRIPTS_DIR%\running\setUp.bat" ]
pushd "%SUBSCRIPTS_DIR%\running"
CALL "setUp.bat" || goto :error
popd
goto :eof

:callStop
CALL :log Executing the STOP goal.
pushd "%SUBSCRIPTS_DIR%\running"
CALL "tearDown.bat" || goto :error
popd
goto :eof

:callClean
CALL :log Executing the CLEAN goal.
pushd "%SUBSCRIPTS_DIR%"
CALL "clean_docker_environment.bat" || goto :error
popd
goto :eof

REM Environment

:logStartingScreen
CALL :logManagerASCII
ECHO.
timeout /t 1 /nobreak >nul
CALL :log Welcome to the Environment Manager
ECHO.
timeout /t 1 /nobreak >nul
ECHO This script will help you manage your environment.
ECHO The base operations you can perform are:
ECHO    1. Cloning/updating the repositories (CLONE),
ECHO        - glf-configServer
ECHO        - glf-servicediscovery
ECHO        - glf-api-gateway
ECHO        - glf-accounts
ECHO        - glf-communities
ECHO    2. Downloading and building the necessary dependencies (DEPS),
ECHO        - pp-base
ECHO        - pp-commons
ECHO        - pp-modinfo
ECHO    3. Running the environment (RUN),
ECHO        - building the projects
ECHO        - building docker images
ECHO        - running the docker containers
ECHO    4. Stopping the environment (STOP),
ECHO        - stopping the docker containers
ECHO    5. Cleaning the environment (CLEAN).
ECHO.
ECHO ATTENTION! With the default configuration, there is no possibility to run the containers properly. You can find more about configuring the scripts in the README.md file.
ECHO.
ECHO Here you can find a few default goal chains. Choose a number or use 99 to use your own goal chain
ECHO    1. RUN ( WARNING! This one will not work properly with the default configuration. The docker containers will not start properly )
ECHO    2. STOP
ECHO    3. DEPS
ECHO    4. DEPS CLONE
ECHO    5. CLEAN
ECHO    6. DEPS CLONE RUN ( WARNING! This one will not work properly with the default configuration. The docker containers will not start properly )
ECHO    7. DEPS RUN ( WARNING! This one will not work properly with the default configuration. The docker containers will not start properly )
ECHO    ...
ECHO    99. Your custom goal chain
ECHO.
goto :eof

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
CALL :log ==================================================================================================================================
CALL :log ==================================================================================================================================
CALL :log ==================================================================================================================================
ECHO.
goto :eof

REM Prints a message in the log.
REM Parameters:
REM    1. The message to be printed.
:log
ECHO %PROJECT_NAME% --- [INFO] %*
goto :eof

:logManagerASCII
::: ___________           .__                                            __       _____
::: \_   _____/ _______  _|__|______  ____   ____   _____   ____   _____/  |_    /     \ _____    ____ _____     ____   ___________
:::  |    __)_ /    \  \/ /  \_  __ \/  _ \ /    \ /     \_/ __ \ /    \   __\  /  \ /  \\__  \  /    \\__  \   / ___\_/ __ \_  __ \
:::  |        \   |  \   /|  ||  | \(  <_> )   |  \  Y Y  \  ___/|   |  \  |   /    Y    \/ __ \|   |  \/ __ \_/ /_/  >  ___/|  | \/
::: /_______  /___|  /\_/ |__||__|   \____/|___|  /__|_|  /\___  >___|  /__|   \____|__  (____  /___|  (____  /\___  / \___  >__|
:::         \/     \/                           \/      \/     \/     \/               \/     \/     \/     \//_____/      \/
for /f "delims=: tokens=*" %%A in ('findstr /b ::: "%~f0"') do @echo(%%A
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