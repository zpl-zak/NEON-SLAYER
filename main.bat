@echo off

cd %~dp0
REM detect paths
set msbuild_cmd=msbuild.exe
where /q msbuild.exe
if not %errorlevel%==0 set msbuild_cmd="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"

set devenv_cmd=devenv.exe
where /q devenv.exe
if not %errorlevel%==0 set devenv_cmd="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe"

set "proj=basic"

:begin
	cls

	echo NEON SLAYER game
	echo =======================
	echo  1. Exit
	echo  2. Build
	echo  3. Debug
	echo  4. Deploy - Staging
	echo  5. Deploy - Prod
	echo  6. Open in VS
	echo  7. Open in VS Code
	echo  8. Pull upstream
	echo  9. itch.io build log
	echo  A. Open shell
	echo  C. Open In VS (minimal)
	echo  D. Run production
	echo  E. Run debug
	echo  G. Open in explorer
	echo  I. Open itch.io page
	echo  J. Pull engine changes
	echo =======================
	choice /C 123456789ABCDEFGHIJ /N /M "Your choice:"
	echo.

	if %errorlevel%==1 goto :EOF
	if %errorlevel%==2 call :build
	if %errorlevel%==3 call :debug
	if %errorlevel%==4 call :deploy
	if %errorlevel%==5 call :deploy_prod
	if %errorlevel%==6 call :open_in_vs
	if %errorlevel%==7 call :open_in_vscode
	if %errorlevel%==8 call :git_pull
	if %errorlevel%==9 call :butler_builds
	if %errorlevel%==10 call :shell
	rem if %errorlevel%==11 call :change_project
	if %errorlevel%==12 call :open_in_vs_minimal
	if %errorlevel%==13 call :run_release
	if %errorlevel%==14 call :debug
	rem if %errorlevel%==15 call :new_project
	if %errorlevel%==16 call :open_explorer
	rem if %errorlevel%==17 call :toggle_base
	if %errorlevel%==18 start "" "https://zaklaus.itch.io/neon-slayer"
	if %errorlevel%==19 call :sync_engine

goto :begin

:build
	%msbuild_cmd% code\Lines.sln /p:Configuration=Debug /p:Platform=x64 /m
	pause
exit /B 0

:build_release
	%msbuild_cmd% code\Lines.sln /p:Configuration=Release /p:Platform=x64 /m
	echo.
	echo =======================
	echo  1. Continue with deployment
	echo  2. Cancel deployment
	echo =======================
	choice /C 12 /N /M "Your choice:"
	echo.

	if %errorlevel%==1 exit /B 1
exit /B 0

:debug
	if not exist build\debug\player.exe call :build
	build\debug\player.exe data
exit /B 0

:run_release
	if not exist build\release\player.exe call :build_release
	if %errorlevel%==0 exit /B 0
	build\release\player.exe data
exit /B 0

:open_in_vs_minimal
	if not exist build\debug\player.exe call :build
	call %devenv_cmd% build\debug\player.exe
exit /B 0

:package
	echo Packaging files ...
	rem Package release files
	if exist build\deploy rmdir /S /Q build\deploy
	mkdir build\deploy
	xcopy /Y build\release\*.dll build\deploy\
	xcopy /Y build\release\player.exe build\deploy\
	xcopy /Y /E /exclude:.gitignore "data" "build\deploy\data\"
	xcopy /Y /E /I /exclude:.gitignore libs build\deploy\libs
	xcopy /Y LICENSE.md build\deploy\
	xcopy /Y README.md build\deploy\
	del   /S /Q /F build\deploy\*.blend
	echo.

	:package_prompt
		echo NEON SLAYER DEPLOY
		echo =======================
		echo  1. Proceed with upload
		echo  2. Cancel deployment
		echo  3. Test it first
		echo =======================
		choice /C 123 /N /M "Your choice:"
		echo.
		if %errorlevel%==1 exit /B 1
		if %errorlevel%==2 exit /B 0
		if %errorlevel%==3 (
			pushd build\deploy\
				player.exe data
			popd
		)
	cls
goto :package_prompt

:deploy
	call :build_release
	if %errorlevel%==0 exit /B 0

	call :package
	if %errorlevel%==0 exit /B 0

	rem Upload process
	pushd build\
		echo Deploying to itch.io ...
		butler push deploy zaklaus/neon-slayer:win32-test
	popd
	pause
exit /B 0

:deploy_prod
	call :build_release
	if %errorlevel%==0 exit /B 0

	call :package
	if %errorlevel%==0 exit /B 0
	cls

	:deploy_version
		echo NEON SLAYER VERSION
		echo =======================
		echo  1. Major
		echo  2. Minor
		echo  3. Patch
		echo  4. Cancel deployment
		echo =======================
		choice /C 1234 /N /M "Your choice:"
		echo.
		if %errorlevel%==1 (
			call npm run release-major
		)
		if %errorlevel%==2 (
			call npm run release-minor
		)
		if %errorlevel%==3 (
			call npm run release-patch
		)
		if %errorlevel%==4 exit /B 0

		echo.
		echo NEON SLAYER RELEASE
		echo =======================
		echo  1. RELEASE IT!!!
		echo  2. Cancel deployment
		echo =======================
		choice /C 12 /N /M "Your choice:"
		echo.

		if %errorlevel%==2 exit /B 0
	cls

	rem Upload process
	pushd build\
		echo Deploying to itch.io ...
		butler push deploy zaklaus/neon-slayer:win32-release
	popd
	pause
exit /B 0

:butler_builds
	butler status zaklaus/neon-slayer
	pause
exit /B 0

:open_in_vs
	start code\Lines.sln
exit /B 0


:open_in_vscode
	start cmd /C "code.exe ."
exit /B 0


:open_in_lite
	start lite data
exit /B 0

:sync_engine
	robocopy "W:\neon86\code\engine" "code\engine" /mir
	pause
exit /B 0

:git_pull
	git pull
	pause
exit /B 0

:shell
	cls
	echo NEON86 SHELL
	echo Enter the EXIT command to get back to main menu.
	echo.
	call cmd
exit /B 0

:new_project
	set /p a="Enter name: "
	if "%a%"=="" exit /B 0
	set proj=%a%
	xcopy /Y /E demos\base\ data\
exit /B 0

:toggle_base
	if "%proj%"=="base" (
		set proj=%oldproj%
	) else (
		set oldproj=%proj%
		set proj=base
	)
exit /B 0

:open_explorer
	start explorer.exe data\
exit /B 0