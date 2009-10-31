
@echo off

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                                                                            ::
:: Test system: Windows XP x64 SP2, all patches applied                       ::
:: Succesfull builds of both 32 and 64 bit flavours on:                       ::
::                                                                            ::
:: Microsoft Visual Studio 6.0 SP6 (32-bit only)                              ::
:: Microsoft Platform SDK for Windows Server 2003 R2 (64-bit only)            ::
:: Microsoft Visual Studio 2005 SP1                                           ::
:: Microsoft Visual Studio 2008 SP1                                           ::
:: Microsoft Windows SDK for Windows 7 and .NET Framework 3.5 SP1             ::
:: Visual Studio 2010 (Beta1)                                                 ::
::                                                                            ::
::                       degski [ta] gmail [tod] com                          ::
::                                                                            ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SETLOCAL

:debugging
:: (Un-)comment as appropriate
:: Normal operation
set "REDIR_TO_NUL=> nul"
:: Debugging
:: set "REDIR_TO_NUL="
:end_debugging

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                                                                            ::
:: EP! is the Export Prefix, all & any variable prefixed in this way          ::
:: will be exported to config.dat                                             ::
::                                                                            ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:what_host
set "EP!WINDIR=%SystemRoot%"
if defined ProgramFiles(x86) (set "EP!HOST_OS_ARCH=X64") ELSE (set "EP!HOST_OS_ARCH=X86")
if "%EP!HOST_OS_ARCH%"=="X64" (set "EP!PROGRAM_FILES_32=%ProgramFiles(x86)%") else (set "EP!PROGRAM_FILES_32=%ProgramFiles%")
:end_what_host


:start_create_welcome
echo Welcome to SWI-Prolog Windows Build Environment Configuration Utility > welcome.txt
echo Copyright (c) 1990-2009 University of Amsterdam. >> welcome.txt
echo SWI-Prolog comes with ABSOLUTELY NO WARRANTY. This is free software, >> welcome.txt
echo and you are welcome to redistribute it under certain conditions. >> welcome.txt
echo Please visit http://www.swi-prolog.org for details. >> welcome.txt
echo. >> welcome.txt
:end_start_create_welcome


:what_target
cls
type welcome.txt
set /P "BITS=Would you like to do a 32bit or 64bit build? (32 or 64): "
if "%BITS%"=="32" (goto what_target_bits_oke)
if "%BITS%"=="64" (goto what_target_bits_oke)
echo The only choices possible are 32 and 64!
goto what_target
:what_target_bits_oke
if "%BITS%"=="32" (set "EP!TARGET_OS_ARCH=X86") else (set "EP!TARGET_OS_ARCH=X64")
if "%BITS%"=="32" (set "EP!TARGET_PROGRAM_FILES=%EP!PROGRAM_FILES_32%") else (set "EP!TARGET_PROGRAM_FILES=%ProgramFiles%")
if "%BITS%"=="32" (set "EP!MD=WIN32") else (set "EP!MD=WIN64")
:end_what_target


:sanity_check
if not "%EP!HOST_OS_ARCH%%EP!TARGET_OS_ARCH%"=="X86X64" (goto end_sanity_check)
cls
type welcome.txt
echo A 64-bit target install cannot be built on a 32-bit host operating system, exiting...
goto end
:end_sanity_check


:set_vc_or_sdk_environment
::determine_vc_version
set "VCXX=UNKNOWN"
if exist "%EP!PROGRAM_FILES_32%\Microsoft Visual Studio\VC98\" (set "VCXX=VC06")
if exist "%ProgramFiles%\Microsoft Platform SDK for Windows Server 2003 R2\" (set "VCXX=VC08")
if exist "%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 8\" (set "VCXX=VC08")
if exist "%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 9.0\" (set "VCXX=VC09")
if exist "%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 10.0\" (set "VCXX=VC10")
::set_vc6_environment_file
if "%VCXX%_%BITS%"=="VC06_32" (@echo call "%EP!PROGRAM_FILES_32%\Microsoft Visual Studio\VC98\Bin\VCVARS32.BAT" ^> nul > call_vcvars.cmd)
if "%VCXX%_%BITS%"=="VC06_64" (goto this_build_is_not_possible)
::set_vc8_or_sdk2003_R2_environment_file
if exist "%ProgramFiles%\Microsoft Platform SDK for Windows Server 2003 R2\SetEnv.Cmd" (set "TYPE=SDK")
if exist "%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 8\VC\vcvarsall.bat" (set "TYPE=STU")
if "%VCXX%_%TYPE%_%BITS%"=="VC08_SDK_64" (@echo call "%ProgramFiles%\Microsoft Platform SDK for Windows Server 2003 R2\SetEnv.Cmd" /X64 /RETAIL ^> nul > call_vcvars.cmd)
if "%VCXX%_%TYPE%_%BITS%"=="VC08_SDK_32" (goto this_build_is_not_possible)
if "%VCXX%_%TYPE%_%BITS%"=="VC08_STU_64" (@echo call "%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 8\VC\vcvarsall.bat" x86_amd64 ^> nul > call_vcvars.cmd)
if "%VCXX%_%TYPE%_%BITS%"=="VC08_STU_32" (@echo call "%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 8\VC\vcvarsall.bat" x86 ^> nul > call_vcvars.cmd)
::set_vc9_or_sdk2008_sdkwin7_environment_file
if exist "%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 9.0\VC\vcvarsall.bat" (set "TYPE=STU")
if "%VCXX%_%TYPE%_%BITS%"=="VC09_STU_64" (@echo call "%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 9.0\VC\vcvarsall.bat" x86_amd64 ^> nul > call_vcvars.cmd)
if "%VCXX%_%TYPE%_%BITS%"=="VC09_STU_32" (@echo call "%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 9.0\VC\vcvarsall.bat" x86 ^> nul > call_vcvars.cmd)
if "%VCXX%_%BITS%"=="VC09_64" (@echo call "%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 9.0\VC\bin\vcvarsx86_amd64.bat" ^> nul > call_vcvars.cmd)
if "%VCXX%_%BITS%"=="VC09_32" (@echo call "%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 9.0\VC\bin\vcvars32.bat" ^> nul > call_vcvars.cmd)
::set_vc10_or_sdkwin7_environment_file
if "%VCXX%_%BITS%"=="VC10_64" (@echo call "%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86_amd64 ^> nul > call_vcvars.cmd)
if "%VCXX%_%BITS%"=="VC10_32" (@echo call "%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86 ^> nul > call_vcvars.cmd)
:is_vc_version_determined
if not "%VCXX%"=="UNKNOWN" (goto set_vc_environment)
cls
type welcome.txt
echo VC version could not be determined, exiting...
goto end
:this_build_is_not_possible
cls
type welcome.txt
echo The requested %BITS%-bits build is not possible on %VCXX%, exiting...
goto end
:set_vc_environment
call call_vcvars.cmd
:end_set_vc_or_sdk_environment


:set_manifest_tool
set "EP!MTEXE=rem"
if "%VCXX%_%TYPE%"=="VC08_STU" (SET "EP!MTEXE=mt.exe -nologo")
if "%VCXX%"=="VC09" (SET "EP!MTEXE=mt.exe -nologo")
if "%EP!MTEXE%"=="rem" (goto end_set_manifest_tool)
:have_mt_exe in path
@for %%i in (mt.exe) do @if NOT "%%!$PATH:i"=="" (goto end_set_manifest_tool)
cls
type welcome.txt
echo mt.exe cannot be found in the current path, exiting...
goto end
:end_set_manifest_tool


:determine_plhome
set "_=%CD%"
cd ..
set "EP!HOME=%CD%"
cd \
set "EP!HOME_DRIVE=%CD%"
cd "%_%"
:end_determine_plhome


:set_additional_variables
set "EP!EXTRALIBDIR=%EP!HOME%\lib"
set "EP!PLBOOTFILE=boot%BITS%.prc"
if "%BITS%"=="32" (set "EP!LIBPTHREAD=pthreadVC") else (set "EP!LIBPTHREAD=pthreadVC2")
if "%BITS%"=="32" (set "EP!LIBZLIB=zlib1") else (set "EP!LIBZLIB=zlibwapi")
if "%BITS%"=="32" (set "EP!ARCH=i386-win32") else (set "EP!ARCH=x64-win64")
:set_extra_libs
if "%VCXX%_%TYPE%_%BITS%"=="VC08_SDK_64" (set "BUFFEROVERFLOW=bufferoverflowU.lib") else (set "BUFFEROVERFLOW=")
set "EP!EXTRALIBS=%EP!GMP_LIB% %BUFFEROVERFLOW%"
:end_set_extra_libs

:: MSVC Runtime(s)
:msvcrt8_sdk
if not "%VCXX%"=="VC08_SDK" (goto end_msvcrt8_sdk)
set "EP!MSVCRTDIR=%ProgramFiles%\Microsoft Platform SDK for Windows Server 2003 R2\Bin\win64"
set "EP!MSVCRT=msvcr80.dll"
:end_msvcrt8_sdk
:msvcrt8_studio
if not "%VCXX%"=="VC08_STU" (goto end_msvcrt8_studio)
if "%BITS%"=="32" (set "EP!MSVCRTDIR=%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 8\VC\redist\x86\Microsoft.VC80.CRT") else (set "EP!MSVCRTDIR=%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 8\VC\redist\amd64\Microsoft.VC80.CRT")
set "EP!MSVCRT=msvcr80.dll"
:end_msvcrt8_studio
:msvcrt9
if not "%VCXX%"=="VC09" (goto end_msvcrt9)
if "%BITS%"=="32" (set "EP!MSVCRTDIR=%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 9.0\VC\redist\x86\Microsoft.VC90.CRT") else (set "EP!MSVCRTDIR=%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 9.0\VC\redist\amd64\Microsoft.VC90.CRT")
set "EP!MSVCRT=msvcr90.dll"
:end_msvcrt9
:msvcrt10
if not "%VCXX%"=="VC10" (goto end_msvcrt10)
if "%BITS%"=="32" (set "EP!MSVCRTDIR=%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 10.0\VC\redist\x86\Microsoft.VC100.CRT") else (set "EP!MSVCRTDIR=%EP!PROGRAM_FILES_32%\Microsoft Visual Studio 10.0\VC\redist\x64\Microsoft.VC100.CRT")
set "EP!MSVCRT=msvcr100.dll"
:end_msvcrt10


if exist "%EP!PROGRAM_FILES_32%\NSIS\MakeNSIS.exe" (set "NSIS=%EP!PROGRAM_FILES_32%\NSIS\MakeNSIS.exe")
if exist "%EP!PROGRAM_FILES_32%\NSIS\MakeNSIS.exe" (set "NSISDEFS=/DWIN%BITS% /DMSVCRT=$(MSVCRT)")
if "%VCXX%_%TYPE%" GEQ "VC08_STU" (SET "EP!VC_VERSION=VC8_OR_MORE") else (SET "EP!VC_VERSION=VC7_OR_LESS")
:end_set_additional_variables


:get_pre-requisites
set "PRE-REQ_FILE=reqs%BITS%.cab"
if exist "%PRE-REQ_FILE%" (goto have_pre-requisites)
set "PRE-REQ_LOCA=http://www.swi-prolog.org/download/MS-Windows/"
cls
type welcome.txt
echo In order for the build process to be able to complete successfully, an archive
echo with the appropriate pre-requisites for your target-build (%PRE-REQ_FILE%) needs
echo to be downloaded from %PRE-REQ_LOCA%
echo You could also provide these (or some of them) yourself, you will be prompted
echo for this.
echo.
echo This archive will be placed in the following directory:
echo.
echo %EP!HOME%\src
set "ANSWER=enter"
:get_pre-requisites_ask_again
echo.
set /P "ANSWER=Would you like to download %PRE-REQ_FILE% now? (y/[enter] or n): "
if "%ANSWER%"=="y" (goto get_pre-requisites_start)
if "%ANSWER%"=="n" (goto get_pre-requisites_answer_no)
if "%ANSWER%"=="Y" (goto get_pre-requisites_start)
if "%ANSWER%"=="N" (goto get_pre-requisites_answer_no)
if "%ANSWER%"=="enter" (goto get_pre-requisites_start)
echo.
echo The only choices possible are y/Y and n/N or [enter]!
goto get_pre-requisites_ask_again
:get_pre-requisites_answer_no
cls
type welcome.txt
echo You have chosen not to download the pre-requisites for your target-
echo build (%PRE-REQ_FILE%). Without the libraries and headers included in this
echo package, the build process cannot proceed. The build-process will now be ended,
echo exiting...
goto end
:get_pre-requisites_start
echo set oHTTP = WScript.CreateObject("Microsoft.XMLHTTP") > reqs%BITS%.vbs
echo oHTTP.open "GET"^, "%PRE-REQ_LOCA%" ^& "%PRE-REQ_FILE%"^, False >> reqs%BITS%.vbs
echo oHTTP.send >> reqs%BITS%.vbs
echo set oStream = createobject("adodb.stream") >> reqs%BITS%.vbs
echo oStream.type = 1 >> reqs%BITS%.vbs
echo oStream.open >> reqs%BITS%.vbs
echo oStream.write oHTTP.responseBody >> reqs%BITS%.vbs
echo oStream.savetofile "%PRE-REQ_FILE%"^, 2 >> reqs%BITS%.vbs
echo set oStream = nothing >> reqs%BITS%.vbs
echo set oHTTP = nothing >> reqs%BITS%.vbs
goto execute_get_pre-requisites_script
set "NO_TRIES=0"
:execute_get_pre-requisites_script_wait
ping -n 5 localhost > nul
:execute_get_pre-requisites_script
reqs%BITS%.vbs
if exist %PRE-REQ_FILE% (goto get_pre-requisites_succes)
set /A NO_TRIES+=1
cls
type welcome.txt
echo Download of the SWI-Prolog %BITS%-bit Pre-requisites failed on try %NO_TRIES% (of 3),
echo trying again in about 5 seconds...
echo.
if %NO_TRIES% LEQ 3 (goto execute_get_pre-requisites_script_wait)
cls
type welcome.txt
echo Download of the SWI-Prolog %BITS%-bit Pre-requisites failed permanently, exiting...
goto end
:get_pre-requisites_succes
cls
type welcome.txt
echo Successfully downloaded the SWI-Prolog %BITS%-bit Pre-requisites...
if exist reqs%BITS%.vbs (del /Q reqs%BITS%.vbs)
goto end_get_pre-requisites
:have_pre-requisites
cls
type welcome.txt
echo Already downloaded the SWI-Prolog %BITS%-bit Pre-requisites...
:end_get_pre-requisites


:start_expanding_pre-requisites
if exist "%EP!HOME%\bin" (rd /S /Q "%EP!HOME%\bin")
md "%EP!HOME%\bin"
if exist "%EP!HOME%\include" (rd /S /Q "%EP!HOME%\include")
md "%EP!HOME%\include"
expand "reqs%BITS%.cab" -F:include.cab "%EP!HOME%\include" %REDIR_TO_NUL%
expand "%EP!HOME%\include\include.cab" -F:* "%EP!HOME%\include" %REDIR_TO_NUL%
if exist "%EP!HOME%\include\include.cab" (del /Q "%EP!HOME%\include\include.cab")
if exist "%EP!HOME%\lib" (rd /S /Q "%EP!HOME%\lib")
md "%EP!HOME%\lib"
expand "reqs%BITS%.cab" -F:lib.cab "%EP!HOME%\lib" %REDIR_TO_NUL%
expand "%EP!HOME%\lib\lib.cab" -F:* "%EP!HOME%\lib" %REDIR_TO_NUL%
if exist "%EP!HOME%\lib\lib.cab" (del /Q "%EP!HOME%\lib\lib.cab")
echo.
echo Expanded the Pre-Requisites Package header files to %EP!HOME%\include
echo and the libraries to %EP!HOME%\lib
echo.
pause
:end_start_expanding_pre-requisites


:create_user_lib_dirs
if exist "%EP!HOME%\%EP!TARGET_OS_ARCH%\lib\*.lib" (goto assumed_user_lib_dirs_complete)
if exist "%EP!HOME%\%EP!TARGET_OS_ARCH%\bin\*.exe" (goto assumed_user_lib_dirs_complete)
if exist "%EP!HOME%\%EP!TARGET_OS_ARCH%\bin\*.dll" (goto assumed_user_lib_dirs_complete)
if exist "%EP!HOME%\%EP!TARGET_OS_ARCH%\include\*.h" (goto assumed_user_lib_dirs_complete)
cls
type welcome.txt
set "ANSWER=enter"
:create_user_lib_dirs_ask_again
echo.
set /P "ANSWER=Would you like to provide your own libraries/header-files? (y or n/[enter]): "
if "%ANSWER%"=="y" (goto create_user_lib_dirs_answer_yes)
if "%ANSWER%"=="n" (goto end_create_user_lib_dirs)
if "%ANSWER%"=="Y" (goto create_user_lib_dirs_answer_yes)
if "%ANSWER%"=="N" (goto end_create_user_lib_dirs)
if "%ANSWER%"=="enter" (goto end_create_user_lib_dirs)
echo.
echo The only choices possible are y/Y and n/N or [enter]!
goto create_user_lib_dirs_ask_again
:create_user_lib_dirs_answer_yes
cls
type welcome.txt
echo The pre-requisites provided by you, should be placed in the sub-folders of
echo      %EP!HOME%\X86
echo and
echo      %EP!HOME%\X64
echo for 32- and 64-bit libraries respectively.
echo.
echo The 32-bit files should be placed in:
echo      %EP!HOME%\X86\bin
echo      %EP!HOME%\X86\include
echo      %EP!HOME%\X86\lib
echo.
echo The 64-bit files should be placed in:
echo      %EP!HOME%\X64\bin
echo      %EP!HOME%\X64\include
echo      %EP!HOME%\X64\lib
echo.
echo Those folders will now be created.
echo.
:make_user_lib_dirs
if not exist "%EP!HOME%\X86" (md "%EP!HOME%\X86")
if not exist "%EP!HOME%\X86\bin" (md "%EP!HOME%\X86\bin")
if not exist "%EP!HOME%\X86\include" (md "%EP!HOME%\X86\include")
if not exist "%EP!HOME%\X86\lib" (md "%EP!HOME%\X86\lib")
if not exist "%EP!HOME%\X64" (md "%EP!HOME%\X64")
if not exist "%EP!HOME%\X64\bin" (md "%EP!HOME%\X64\bin")
if not exist "%EP!HOME%\X64\include" (md "%EP!HOME%\X64\include")
if not exist "%EP!HOME%\X64\lib" (md "%EP!HOME%\X64\lib")
goto assumed_user_lib_dirs_complete_answer_no
:assumed_user_lib_dirs_complete
cls
type welcome.txt
echo At least one user provided pre-requisite is found...
set "ANSWER=enter"
:assumed_user_lib_dirs_complete_ask_again
echo.
set /P "ANSWER=Are ALL user-provided pre-requisites in place? (y/[enter] or n): "
if "%ANSWER%"=="y" (goto assumed_user_lib_dirs_complete_answer_yes)
if "%ANSWER%"=="n" (goto assumed_user_lib_dirs_complete_answer_no)
if "%ANSWER%"=="Y" (goto assumed_user_lib_dirs_complete_answer_yes)
if "%ANSWER%"=="N" (goto assumed_user_lib_dirs_complete_answer_no)
if "%ANSWER%"=="enter" (goto assumed_user_lib_dirs_complete_answer_yes)
echo.
echo The only choices possible are y/Y and n/N or [enter]!
goto assumed_user_lib_dirs_complete_ask_again
:assumed_user_lib_dirs_complete_answer_no
echo.
echo Re-Run this script again after providing all pre-requisites, exiting...
goto end
:assumed_user_lib_dirs_complete_answer_yes
echo.
echo Continuing (in 2 secs)...
ping -n 2 localhost > nul
:end_create_user_lib_dirs


:delete_previous_install
if exist "%EP!TARGET_PROGRAM_FILES%\pl" (rd /S /Q "%EP!TARGET_PROGRAM_FILES%\pl" %REDIR_TO_NUL%)
:end_delete_previous_install


:detect_gmp
if not exist "%EP!HOME%\lib\gmp.lib" (goto detect_gmp_not_detected)
if not exist "%EP!HOME%\include\gmp.h" (goto detect_gmp_not_detected)
goto detect_gmp_detected
:detect_gmp_not_detected
cls
type welcome.txt
echo GMP (or one of its components) not found...
echo.
echo The build will continue without GMP, its functionality will not be
echo available. If GMP is required, install GMP and run this script again.
echo.
pause
set "EP!GMP=false"
set "EP!GMP_LIB="
goto end_detect_gmp
:detect_gmp_detected
set "EP!GMP=true"
set "EP!GMP_LIB=gmp.lib"
:end_detect_gmp


:detect_zlib
if not exist "%EP!HOME%\lib\%EP!LIBZLIB%.lib" (goto detect_zlib_not_detected)
if not exist "%EP!HOME%\lib\%EP!LIBZLIB%.dll" (goto detect_zlib_not_detected)
if not exist "%EP!HOME%\include\zlib.h" (goto detect_zlib_not_detected)
goto detect_zlib_detected
:detect_zlib_not_detected
cls
type welcome.txt
echo ZLIB (or one of its components) not found...
echo.
echo The build will continue without ZLIB, its functionality will not be
echo available. If ZLIB is required, install ZLIB and run this script again.
echo.
pause
set "EP!BUILD_ZLIB="
goto end_detect_zlib
:detect_zlib_detected
set "EP!BUILD_ZLIB=zlib"
:end_detect_zlib


:detect_ssl
if exist "%EP!TARGET_PROGRAM_FILES%\OpenSSL" (goto detect_ssl_pf_detected)
if exist "%SystemDrive%\OpenSSL" (goto detect_ssl_sd_detected)
cls
type welcome.txt
echo OpenSSl must be installed in "Program Files". For building a 32-bit target on a
echo 64-bit host OS, OpenSSL must be installed in "Program Files (x86)". During
echo installation, you are asked where to install the executables. They should
echo be installed in the OpenSSL directory. This is NOT the default!
echo.
echo OpenSSL not found, OpenSSL must be installed in %EP!TARGET_PROGRAM_FILES%\OpenSSL.
echo.
echo The OpenSSL for Windows packages can be downloaded at:
echo http://www.slproweb.com/products/Win32OpenSSL.html.
echo Please, choose the full (i.e. not the light) distribution package.
echo.
echo The build will continue without OpenSSL, its functionality will not be
echo available. If OpenSSL is required, please install OpenSSL following the above
echo instructions and run this script again.
echo.
set "EP!BUILD_SSL="
pause
goto end_detect_ssl
:detect_ssl_pf_detected
set "EP!BUILD_SSL=ssl"
set "EP!OPENSSL_CONF=%EP!TARGET_PROGRAM_FILES%\OpenSSL\bin\openssl.cfg"
goto end_detect_ssl
:detect_ssl_sd_detected
set "EP!BUILD_SSL=ssl"
set "EP!OPENSSL_CONF=%SystemDrive%\OpenSSL\bin\openssl.cfg"
goto end_detect_ssl
:end_detect_ssl


:detect_java
if exist "%EP!TARGET_PROGRAM_FILES%\Java\jdk*" (goto detect_java_pf_detected)
if exist "%SystemDrive%\Java\jdk*" (goto detect_java_sd_detected)
if exist "%SystemDrive%\jdk*" (goto detect_java_sdnjd_detected)
cls
type welcome.txt
echo Java JDK not found...
echo.
echo The build will continue without the SWI-Prolog Java Package, its functionality
echo will not be available. If Java is required, install the Java JDK and run this
echo script again.
echo.
pause
set "PLBUILD_JPL="
goto end_detect_java
:detect_java_pf_detected
for /F %%_ in ('dir "%EP!TARGET_PROGRAM_FILES%\Java\jdk*" /A:D /B') do (set "EP!JAVA_JDK_VERSION=%%_")
set "EP!JAVA_HOME=%EP!TARGET_PROGRAM_FILES%\Java\%EP!JAVA_SDK_VERSION%"
goto detect_java_detected
:detect_java_sd_detected
for /F %%_ in ('dir "%SystemDrive%\Java\jdk*" /A:D /B') do (set "EP!JAVA_JDK_VERSION=%%_")
set "EP!JAVA_HOME=%SystemDrive%\Java\%EP!JAVA_SDK_VERSION%"
goto detect_java_detected
:detect_java_sdnjd_detected
for /F %%_ in ('dir "%SystemDrive%\jdk*" /A:D /B') do (set "EP!JAVA_JDK_VERSION=%%_")
set "EP!JAVA_HOME=%SystemDrive%\%EP!JAVA_SDK_VERSION%"
goto detect_java_detected
:detect_java_detected
if not exist "%EP!HOME%\lib\junit.jar" (goto detect_junit_jar_not_detected)
set "EP!JUNIT=%EP!HOME%\lib\junit.jar"
set "EP!BUILD_JPL=jpl"
goto end_detect_java
:detect_junit_jar_not_detected
cls
type welcome.txt
echo Java %EP!JAVA_JDK_VERSION% found, but %EP!HOME%\lib\junit.jar not found...
echo.
echo The build will continue without the SWI-Prolog Java Package, its functionality
echo will not be available. If Java is required, install the Java JDK and run this
echo script again.
echo.
pause
set "EP!BUILD_JPL="
:end_detect_java


:export_environment
if exist "config.dat" (del /Q "config.dat")
for /F "delims=! tokens=2*" %%_ in ('set EP!') do (echo %%_ >> "config.dat")
:end_export_environment


:build_now
set "ANSWER=enter"
cls
type welcome.txt
set /P "ANSWER=Would you like to build and install SWI-Prolog %BITS%-bits now? (y/[enter] or n): "
if "%ANSWER%"=="y" (goto build_now_answer_yes)
if "%ANSWER%"=="n" (goto build_now_answer_no)
if "%ANSWER%"=="Y" (goto build_now_answer_yes)
if "%ANSWER%"=="N" (goto build_now_answer_no)
if "%ANSWER%"=="enter" (goto build_now_answer_yes)
echo The only choices possible are y/Y and n/N or [enter]!
goto build_now
:build_now_answer_no
cls
type welcome.txt
echo The environment has now been set up, the configuration has been saved in the
echo file config.dat in the current directory. automake.cmd starts the build process.
echo For consecutive builds (with the current setup), it's not necessary to run this
echo script again. When changes are made, or when a different target is required,
echo please run this script.
echo.
echo The environment variables are setup as follows:
echo.
type config.dat
echo.
goto end_build_now
:build_now_answer_yes
call automake.cmd
goto end_no_pause
:end_build_now


:end
echo.
pause
:end_no_pause
if exist welcome.txt (del /Q welcome.txt %REDIR_TO_NUL%)

ENDLOCAL

