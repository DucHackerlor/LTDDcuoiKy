@echo off
cd /d "%~dp0"
where flutter >nul 2>nul || (echo Flutter not found in PATH.& pause & exit /b 1)
flutter pub get || (pause & exit /b 1)
flutter analyze
if errorlevel 1 (pause & exit /b 1)
flutter test
pause
