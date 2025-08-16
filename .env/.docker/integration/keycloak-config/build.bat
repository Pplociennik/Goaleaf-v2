@ECHO OFF

SET HOME=%~dp0

SET NAME=keycloak-configurer
SET TAG=integration

ECHO Building docker image...
ECHO Name: %NAME%:%TAG%

docker build -t %NAME%:%TAG% %HOME% --no-cache || goto :error

ECHO Docker image '%NAME%:%TAG%' built successfully.

EXIT

:error
ECHO [ERROR] %ERRORLEVEL%
EXIT \B 1
goto :eof