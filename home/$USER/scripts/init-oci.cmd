@ECHO OFF

SETLOCAL
SETLOCAL ENABLEEXTENSIONS

IF "%~1" == "" GOTO :HELP
IF "%~2" == "" GOTO :HELP

NET SESSION > NUL: 2>&1
IF ERRORLEVEL 1 GOTO :ERR_NOT_ELEVATED

SET "OCI_PATH=%~2"
SET "TNS_ADMIN=%OCI_PATH%\Network\Admin"
SET "OCI_NAME=%~1"

IF NOT EXIST "%OCI_PATH%\oci.dll" GOTO :ERR_OCI_NOT_FOUND

IF NOT EXIST "%TNS_ADMIN%\TNSNames.ora" CALL :CREATE_CONFIG
IF NOT EXIST "%TNS_ADMIN%\SQLNet.ora" CALL :CREATE_CONFIG

reg ADD "HKLM\SOFTWARE\oracle\KEY_%OCI_NAME%" /v "ORACLE_HOME_KEY" /d "SOFTWARE\ORACLE\KEY_%OCI_NAME%" /f > NUL:
reg ADD "HKLM\SOFTWARE\oracle\KEY_%OCI_NAME%" /v "ORACLE_HOME_NAME" /d "%OCI_NAME%" /f > NUL:
reg ADD "HKLM\SOFTWARE\oracle\KEY_%OCI_NAME%" /v "ORACLE_HOME" /d "%OCI_PATH%" /f > NUL:
reg ADD "HKLM\SOFTWARE\oracle\KEY_%OCI_NAME%" /v "NLS_LANG" /d "RUSSIAN_RUSSIA.AL32UTF8" /f > NUL:

EXIT /B

:HELP
    ECHO Register Oracle Instant Client installation in the Windows registry.
    ECHO Usage:
    ECHO.
    ECHO     ^"%~nx0^" ^<Installation_Name^> ^<Path_to_OracleInstantClient^>
    ECHO.
    ECHO Example:
    ECHO.
    ECHO     ^"%~nx0^" OCI8_12c C:\Oracle\instantclient_12_2
    ECHO.
    ECHO Note: Only supports 64-bit clients!
    EXIT /B

:ERR_NOT_ELEVATED
    CALL :HELP
    ECHO.
    ECHO ERROR: Session not elevated.
    ECHO Please run this script from an elevated command prompt.
    EXIT /B

:ERR_OCI_NOT_FOUND
    CALL :HELP
    ECHO.
    ECHO ERROR: Wrong OCI installation path supplied.
    EXIT /B

:CREATE_DIRECTORIES
    ECHO Creating configuration directories...
    MKDIR "%TNS_ADMIN%"
    EXIT /B

:CREATE_CONFIG
    IF NOT EXIST "%TNS_ADMIN%" CALL :CREATE_DIRECTORIES
    ECHO Creating default configuration files...
    IF NOT EXIST "%TNS_ADMIN%\TNSNames.ora" SET /P _= >> "%TNS_ADMIN%\TNSNames.ora" < NUL:
    IF NOT EXIST "%TNS_ADMIN%\SQLNet.ora" SET /P _= >> "%TNS_ADMIN%\SQLNet.ora" < NUL:
    EXIT /B
