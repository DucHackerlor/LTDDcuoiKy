import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelmate/main.dart';
import 'package:travelmate/trip_store.dart';

void main() {
  testWidgets('Đã đăng nhập có 4 tab và không trùng nút tài khoản trên đầu', (tester) async {
    final store = TripStore()..loaded = true;
    store.currentUser = 'thanhvien@gmail.com';
    await tester.pumpWidget(TravelMate(store: store));
    expect(find.text('Truy cập nhanh'), findsOneWidget);
    expect(find.text('Chuyến đi tiếp theo'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Tài khoản'), findsOneWidget);
    expect(find.byIcon(Icons.account_circle_outlined), findsNothing);
    expect(find.byIcon(Icons.person_outline_rounded), findsNothing);
  });

  testWidgets('Tab tài khoản không còn Bộ nhớ hoặc Sắp ra mắt', (tester) async {
    final store = TripStore()..loaded = true;
    store.currentUser = 'thanhvien@gmail.com';
    await tester.pumpWidget(TravelMate(store: store));
    await tester.tap(find.text('Tài khoản'));
    await tester.pumpAndSettle();
    expect(find.text('Giao diện tiếng Anh'), findsOneWidget);
    expect(find.text('Đăng xuất'), findsOneWidget);
    expect(find.text('Bộ nhớ thiết bị'), findsNothing);
    expect(find.text('Sắp ra mắt'), findsNothing);
    expect(find.textContaining('Đăng nhập mô phỏng'), findsNothing);
  });

  testWidgets('Trang thông tin nhóm hiển thị đủ 3 thành viên', (tester) async {
    final store = TripStore()..loaded = true;
    store.currentUser = 'thanhvien@gmail.com';
    await tester.pumpWidget(TravelMate(store: store));
    await tester.tap(find.text('Tài khoản'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thông tin nhóm'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Nguyễn Minh Đức'), 180);
    expect(find.text('Nguyễn Minh Đức'), findsOneWidget);
    expect(find.textContaining('24100430'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Hoàng Quang Lâm'), 180);
    expect(find.text('Hoàng Quang Lâm'), findsOneWidget);
    expect(find.textContaining('24100302'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Nguyễn Yến Nhi'), 180);
    expect(find.text('Nguyễn Yến Nhi'), findsOneWidget);
    expect(find.textContaining('24100372'), findsOneWidget);
    expect(find.textContaining('Hãy thay thông tin'), findsNothing);
  });

}
