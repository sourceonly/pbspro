@echo off
REM Copyright (C) 1994-2019 Altair Engineering, Inc.
REM For more information, contact Altair at www.altair.com.
REM
REM This file is part of the PBS Professional ("PBS Pro") software.
REM
REM Open Source License Information:
REM
REM PBS Pro is free software. You can redistribute it and/or modify it under the
REM terms of the GNU Affero General Public License as published by the Free
REM Software Foundation, either version 3 of the License, or (at your option) any
REM later version.
REM
REM PBS Pro is distributed in the hope that it will be useful, but WITHOUT ANY
REM WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
REM PARTICULAR PURPOSE.  See the GNU Affero General Public License for more details.
REM
REM You should have received a copy of the GNU Affero General Public License along
REM with this program.  If not, see <http://www.gnu.org/licenses/>.
REM
REM Commercial License Information:
REM
REM The PBS Pro software is licensed under the terms of the GNU Affero General
REM Public License agreement ("AGPL"), except where a separate commercial license
REM agreement for PBS Pro version 14 or later has been executed in writing with Altair.
REM
REM Altair’s dual-license business model allows companies, individuals, and
REM organizations to create proprietary derivative works of PBS Pro and distribute
REM them - whether embedded or bundled with other software - under a commercial
REM license agreement.
REM
REM Use of Altair’s trademarks, including but not limited to "PBS™",
REM "PBS Professional®", and "PBS Pro™" and Altair’s logos is subject to Altair's
REM trademark licensing policies.

@echo on
setlocal

call "%~dp0set_paths.bat" %~1

cd "%BINARIESDIR%"

if not defined LIBICAL_VERSION (
    echo "Please set LIBICAL_VERSION to libical version!"
    exit /b 1
)

set LIBICAL_DIR_NAME=libical
set BUILD_TYPE=Release
if %DO_DEBUG_BUILD% EQU 1 (
    set LIBICAL_DIR_NAME=libical_debug
    set BUILD_TYPE=Debug
)

if exist "%BINARIESDIR%\%LIBICAL_DIR_NAME%" (
    echo "%BINARIESDIR%\%LIBICAL_DIR_NAME% exist already!"
    exit /b 0
)

if not exist "%BINARIESDIR%\libical-%LIBICAL_VERSION%.zip" (
    "%CURL_BIN%" -qkL -o "%BINARIESDIR%\libical-%LIBICAL_VERSION%.zip" https://github.com/libical/libical/archive/v%LIBICAL_VERSION%.zip
    if not exist "%BINARIESDIR%\libical-%LIBICAL_VERSION%.zip" (
        echo "Failed to download libical"
        exit /b 1
    )
)

2>nul rd /S /Q "%BINARIESDIR%\libical-%LIBICAL_VERSION%"
"%UNZIP_BIN%" -q "%BINARIESDIR%\libical-%LIBICAL_VERSION%.zip"
if not %ERRORLEVEL% == 0 (
    echo "Failed to extract %BINARIESDIR%\libical-%LIBICAL_VERSION%.zip"
    exit /b 1
)
if not exist "%BINARIESDIR%\libical-%LIBICAL_VERSION%" (
    echo "Could not find %BINARIESDIR%\libical-%LIBICAL_VERSION%"
    exit /b 1
)

2>nul rd /S /Q "%BINARIESDIR%\libical-%LIBICAL_VERSION%\build"
mkdir "%BINARIESDIR%\libical-%LIBICAL_VERSION%\build"
cd "%BINARIESDIR%\libical-%LIBICAL_VERSION%\build"

call "%VS90COMNTOOLS%vsvars32.bat"

"%CMAKE_BIN%" -DCMAKE_INSTALL_PREFIX="%BINARIESDIR%\%LIBICAL_DIR_NAME%" -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DUSE_32BIT_TIME_T=True ..
if not %ERRORLEVEL% == 0 (
    echo "Failed to generate makefiles for libical"
    exit /b 1
)
nmake
if not %ERRORLEVEL% == 0 (
    echo "Failed to compile libical"
    exit /b 1
)
nmake install
if not %ERRORLEVEL% == 0 (
    echo "Failed to install libical"
    exit /b 1
)

cd "%BINARIESDIR%"
2>nul rd /S /Q "%BINARIESDIR%\libical-%LIBICAL_VERSION%"

exit /b 0

