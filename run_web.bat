@echo off
cd /d "%~dp0"
where flutter >nul 2>nul
if errorlevel 1 (
  echo Khong tim thay Flutter SDK trong PATH.
  pause
  exit /b 1
)
if not exist "web\index.html" (
  echo Dang tao cau hinh Android va Web con thieu...
  call flutter create --platforms=android,web . || goto error
)
call flutter pub get || goto error
call flutter run -d chrome --web-port=7357
goto end
:error
echo Khong chay duoc. Hay xem thong bao loi o phia tren.
pause
exit /b 1
:end
pause
