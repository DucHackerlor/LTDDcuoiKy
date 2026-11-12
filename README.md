# TravelMate

Ứng dụng quản lý và lên lịch trình du lịch bằng Flutter, hỗ trợ Android và Web.

## Chức năng

- Tạo tài khoản với Gmail, số điện thoại, mật khẩu và đăng nhập trước khi dùng ứng dụng.
- Quên mật khẩu bằng cách đối chiếu Gmail và số điện thoại đã đăng ký trên thiết bị.
- Tạo và quản lý chuyến đi, lịch trình hoạt động, địa điểm tham quan và danh sách hành lý.
- Khám phá gợi ý điểm đến và dự toán chi phí chuyến đi.
- Quản lý hồ sơ, tùy chọn hiển thị và giao diện thích ứng với điện thoại và trình duyệt Web.

## Yêu cầu

- Flutter SDK phù hợp với Dart SDK từ 3.3 đến dưới 4.0.
- Visual Studio Code hoặc Android Studio.
- Android SDK và máy ảo/điện thoại để chạy Android; Chrome để chạy Web.

## Khởi chạy

Mở thư mục `TravelMate` chứa tệp `pubspec.yaml`. Nếu mới giải nén và chưa có thư mục `android`/`web`, chạy một lần:

```powershell
flutter create --platforms=android,web .
```

Cài dependency và khởi chạy:

```powershell
flutter pub get
flutter run -d chrome --web-port=7357
```

Chạy Android sau khi mở giả lập hoặc kết nối thiết bị:

```powershell
flutter devices
flutter run -d emulator-5554
```

Kiểm tra:

```powershell
flutter analyze
flutter test
```

Có thể chạy nhanh trên Windows bằng `run_web.bat` hoặc `run_android.bat`.

## Thành viên nhóm

| MSSV | Thành viên |
|---|---|
| 24100430 | Nguyễn Minh Đức |
| 24100302 | Hoàng Quang Lâm |
| 24100372 | Nguyễn Yến Nhi |

## Phạm vi dữ liệu

Thông tin tài khoản và chuyến đi được lưu cục bộ bằng `shared_preferences`; không có backend, OTP hoặc xác minh quyền sở hữu Gmail/SĐT. Quên mật khẩu chỉ đối chiếu dữ liệu được lưu trên cùng thiết bị/trình duyệt, không phù hợp triển khai cho người dùng thật. Dữ liệu giữa Android và Web không tự đồng bộ. Không lưu dữ liệu nhạy cảm trong ứng dụng thử nghiệm.
