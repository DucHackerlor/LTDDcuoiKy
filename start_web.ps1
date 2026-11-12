$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { throw 'Chua tim thay Flutter SDK trong PATH.' }
if (-not ((Test-Path android) -and (Test-Path web))) {
    flutter create --platforms=android,web .
    if ($LASTEXITCODE -ne 0) { throw 'Khong tao duoc thu muc Android/Web.' }
}
flutter pub get
if ($LASTEXITCODE -ne 0) { throw 'flutter pub get that bai.' }
flutter run -d chrome --web-port=7357
