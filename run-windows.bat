:: Don't show these commands to the user
@echo off
:: Keep variables local, and expand at execution time not parse time
setlocal enabledelayedexpansion
:: Set the title of the window
title Electric Book: Building Android app with expansion file

:: Guidance
:startGuidance
    echo This script will move app images into an expansion file
    echo and zip it with no compression.
    echo.
    echo Please ensure zip.exe is in your PATH.
    echo (To get it, go to the Downloads http://www.info-zip.org/
    echo For Windows, you're probably looking for zip300xn.zip in the win32 folder.
    echo Extract zip300xn.zip and copy only zip.exe to somewhere in your PATH.)
    echo.
    echo Please select:
    echo e to create the expansion file
    echo b to create the expansion file and build a testing (-debug) app
    echo x to exit
    set /p option=

    if "%option%"=="x" echo Exiting && goto:EOF
    if "%option%"=="e" set buildDebugApp=no

    echo Is this a translation app? If so, enter the language code. If not, hit enter.
    set /p language=

:: Move app images to the expansion directory
:: TO DO: 
::   - allow for book folders not called 'book'
::   - move images from '_items' into expansion folder, too
:moveAppImages
    echo Deleting old expansion-main folder
    del "expansion-main"
    echo Moving app images to new expansion-main directory...
    if %language%=="" (
        if exist "www/book/images/app" robocopy "www/book/images/app" "expansion-main" /mov
    ) else (
        if exist "www/book/%language%/images/app" robocopy "www/book/%language%/images/app" "expansion-main" /mov
    )

:: Zip the expansion file (zip updates existing files by default)
:zipExpansionMain
    echo Deleting old expansion-main.zip...
    if exist "expansion-main.zip" del "expansion-main.zip"
    echo Creating new expansion-main.zip...
    zip -0 -j expansion-main expansion-main/*

:: Build app with Cordova
:buildApp
    
    if not "%buildDebugApp%"=="no" (
        :: Install or update node_modules
        :npmInstall
            echo updating Node modules...
            call npm install

        :: Run Cordova, using local cordova in node_modules with npm run
        :cordovaBuildAndroid
            echo Removing old Android platform files...
            npm run cordova -- platform remove android
            rem cordova platform remove android
            echo Fetching latest Android platform files...
            npm run cordova -- platform add android@6.3.0
            rem cordova platform add android@6.4.0
            echo Preparing platforms and plugins...
            npm run cordova -- prepare android
            rem cordova prepare android
            echo Building app...
            npm run cordova -- build android
            rem cordova build android
        )
