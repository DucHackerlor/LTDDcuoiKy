@echo off
cd /d "%~dp0"
where flutter >nul 2>nul
if errorlevel 1 (
  echo Khong tim thay Flutter SDK trong PATH.
  pause
  exit /b 1
)
if not exist "android\app\src\main\AndroidManifest.xml" (
  echo Dang tao cau hinh Android con thieu...
  call flutter create --platforms=android,web . || goto error
)
call flutter pub get || goto error
call flutter devices
set /p DEVICE=Nhap Android device ID (vi du: emulator-5554):
if "%DEVICE%"=="" goto error
call flutter run -d "%DEVICE%"
goto end
:error
echo Khong chay duoc. Kiem tra SDK, Android Emulator va log tren.
pause
exit /b 1
:end
pause
