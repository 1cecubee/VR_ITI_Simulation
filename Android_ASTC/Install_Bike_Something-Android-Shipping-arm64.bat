setlocal
if NOT "%UE_SDKS_ROOT%"=="" (call %UE_SDKS_ROOT%\HostWin64\Android\SetupEnvironmentVars.bat)
set ANDROIDHOME=%ANDROID_HOME%
if "%ANDROIDHOME%"=="" set ANDROIDHOME=C:/Users/GAME/AppData/Local/Android/Sdk
set ADB=%ANDROIDHOME%\platform-tools\adb.exe
set AFS=.\win-x64\UnrealAndroidFileTool.exe
set DEVICE=
if not "%1"=="" set DEVICE=-s %1
for /f "delims=" %%A in ('%ADB% %DEVICE% shell "echo $EXTERNAL_STORAGE"') do @set STORAGE=%%A
@echo.
@echo Uninstalling existing application. Failures here can almost always be ignored.
%ADB% %DEVICE% uninstall com.YourCompany.Bike_Something
@echo.
@echo Installing existing application. Failures here indicate a problem with the device (connection or storage permissions) and are fatal.
%ADB% %DEVICE% install AFS_Bike_Something-Android-Shipping-arm64.apk
@if "%ERRORLEVEL%" NEQ "0" goto Error
%ADB% %DEVICE% shell pm list packages com.YourCompany.Bike_Something
%ADB% %DEVICE% shell pm grant com.YourCompany.Bike_Something android.permission.FOREGROUND_SERVICE >nul 2>&1
%ADB% %DEVICE% shell pm grant com.YourCompany.Bike_Something android.permission.FOREGROUND_SERVICE_DATA_SYNC >nul 2>&1
%ADB% %DEVICE% shell pm grant com.YourCompany.Bike_Something android.permission.POST_NOTIFICATIONS >nul 2>&1
%ADB% %DEVICE% shell rm -r %STORAGE%/UnrealGame/Bike_Something
%ADB% %DEVICE% shell rm -r %STORAGE%/UnrealGame/UECommandLine.txt
%ADB% %DEVICE% shell rm -r %STORAGE%/obb/com.YourCompany.Bike_Something
%ADB% %DEVICE% shell rm -r %STORAGE%/Android/obb/com.YourCompany.Bike_Something
%ADB% %DEVICE% shell rm -r %STORAGE%/Download/obb/com.YourCompany.Bike_Something
@echo.
@echo Installing new data. Failures here indicate storage problems (missing SD card or bad permissions) and are fatal.
	%AFS% %DEVICE% -p com.YourCompany.Bike_Something -k D9F602CF46CB1DD44DA6F0B082EA1EF6 push main.1.com.YourCompany.Bike_Something.obb "^mainobb"
if "%ERRORLEVEL%" NEQ "0" goto Error






%ADB% %DEVICE% install -r Bike_Something-Android-Shipping-arm64.apk
if "%ERRORLEVEL%" NEQ "0" goto Error
@echo.
@echo Grant READ_EXTERNAL_STORAGE and WRITE_EXTERNAL_STORAGE to the apk for reading OBB file or game file in external storage.
%ADB% %DEVICE% shell pm grant com.YourCompany.Bike_Something android.permission.READ_EXTERNAL_STORAGE >nul 2>&1
%ADB% %DEVICE% shell pm grant com.YourCompany.Bike_Something android.permission.WRITE_EXTERNAL_STORAGE >nul 2>&1

@echo.
@echo Installation successful
goto:eof
:Error
@echo.
@echo There was an error installing the game or the obb file. Look above for more info.
@echo.
@echo Things to try:
@echo Check that the device (and only the device) is listed with "%ADB$ devices" from a command prompt.
@echo Make sure all Developer options look normal on the device
@echo Check that the device has an SD card.
@pause
