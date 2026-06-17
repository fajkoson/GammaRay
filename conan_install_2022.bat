@echo off
setlocal

set ROOT_DIR=%~dp0
set VENV_DIR=%ROOT_DIR%.env
set CONAN_PROFILE_NAME=tescan-msvc2022
set CONAN_HOME_DIR=C:\.conan2\

cd /d "%ROOT_DIR%"

if not exist "%VENV_DIR%" (
    @echo Python virtual environment not found. Installing...
    py --version >NUL 2>NUL || goto PYLAUNCHER_FAILURE
    py -m venv --upgrade-deps "%VENV_DIR%" || goto PYTHON_SETUP_FAILURE
)

@echo Syncing python virtual environment...
"%VENV_DIR%\Scripts\python.exe" -m pip install --disable-pip-version-check --require-virtualenv --requirement tools\requirements.txt || goto PYTHON_SETUP_FAILURE


@echo Setting Conan home...
set CONAN_HOME=%CONAN_HOME_DIR%
setx CONAN_HOME "%CONAN_HOME_DIR%" >NUL

@echo Installing Conan configuration...
"%VENV_DIR%\Scripts\conan.exe" config install tools\conan || goto CONAN_SETUP_FAILURE

@echo Installing Release and Debug dependencies...
"%VENV_DIR%\Scripts\conan.exe" install . --output-folder=out -pr:a %CONAN_PROFILE_NAME% -s:a build_type=Debug || goto CONAN_INSTALL_DEBUG_FAILURE
"%VENV_DIR%\Scripts\conan.exe" install . --output-folder=out -pr:a %CONAN_PROFILE_NAME% -s:a build_type=RelWithDebInfo || goto CONAN_INSTALL_RELWITHDEBINFO_FAILURE

@echo SUCCESS
if not defined PIPELINE_MODE pause
exit /b 0

:PYLAUNCHER_FAILURE
@echo FATAL ERROR: Python launcher is not installed or is not in your PATH!
if not defined PIPELINE_MODE pause
exit /b %ERRORLEVEL%

:PYTHON_SETUP_FAILURE
@echo FATAL ERROR: Python virtual environment setup has failed!
if not defined PIPELINE_MODE pause
exit /b %ERRORLEVEL%

:CONAN_SETUP_FAILURE
@echo FATAL ERROR: Conan configuration setup has failed!
if not defined PIPELINE_MODE pause
exit /b %ERRORLEVEL%

:CONAN_INSTALL_FAILURE
@echo FATAL ERROR: Conan dependency install has failed!
if not defined PIPELINE_MODE pause
exit /b %ERRORLEVEL%