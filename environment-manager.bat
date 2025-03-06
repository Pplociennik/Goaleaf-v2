@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

REM Settings
SET DEFAULT_PROJECT_NAME=EnvManager
SET DEBUG=true

SET SCRIPT_DIR=%CD%
SET SUBSCRIPTS_DIR=%SCRIPT_DIR%\.scripts\scripts\windows

CALL :logManagerASCII


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
ECHO %DATE% | %TIME% | %USERNAME% | %COMPUTERNAME% --- %PROJECT_NAME% --- [DEBUG] %*
)
goto :eof

REM Prints an error message in the log.
:error
ECHO %DATE% %TIME% %USERNAME% %COMPUTERNAME% %CD% --- %PROJECT_NAME% --- [ERROR] %*
goto :eof