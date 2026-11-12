import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelmate/main.dart';
import 'package:travelmate/trip_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Chưa đăng ký chỉ hiện màn tạo tài khoản', (tester) async {
    final store = TripStore()..loaded = true;
    await tester.pumpWidget(TravelMate(store: store));
    expect(find.text('TravelMate'), findsOneWidget);
    expect(find.text('Đăng ký tài khoản'), findsOneWidget);
    expect(find.byKey(const ValueKey('register-gmail')), findsOneWidget);
    expect(find.byKey(const ValueKey('register-phone')), findsOneWidget);
    expect(find.byKey(const ValueKey('register-password')), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Tiếp tục không đăng nhập'), findsNothing);
  });

  testWidgets('Gmail sai định dạng không được đăng ký', (tester) async {
    final store = TripStore()..loaded = true;
    await tester.pumpWidget(TravelMate(store: store));
    await tester.enterText(find.byKey(const ValueKey('register-gmail')),
        'abc@hotmail.com');
    await tester.enterText(find.byKey(const ValueKey('register-phone')),
        '0912345678');
    await tester.enterText(find.byKey(const ValueKey('register-password')),
        '12345678');
    await tester.ensureVisible(find.text('Đăng ký tài khoản'));
    await tester.tap(find.text('Đăng ký tài khoản'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Gmail đúng định dạng'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Đăng ký xong phải đăng nhập mới vào được app', (tester) async {
    final store = TripStore()..loaded = true;
    await tester.pumpWidget(TravelMate(store: store));
    await tester.enterText(find.byKey(const ValueKey('register-gmail')),
        'traveler@gmail.com');
    await tester.enterText(find.byKey(const ValueKey('register-phone')),
        '0912345678');
    await tester.enterText(find.byKey(const ValueKey('register-password')),
        'trip2026');
    await tester.ensureVisible(find.text('Đăng ký tài khoản'));
    await tester.tap(find.text('Đăng ký tài khoản'));
    await tester.pumpAndSettle();

    expect(store.hasRegisteredAccount, isTrue);
    expect(store.currentUser, isNull);
    expect(find.byKey(const ValueKey('registration-success')), findsOneWidget);
    expect(find.byKey(const ValueKey('login-identifier')), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.enterText(find.byKey(const ValueKey('login-password')), 'sai123');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.pumpAndSettle();
    expect(store.currentUser, isNull);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.enterText(find.byKey(const ValueKey('login-password')), 'trip2026');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.pumpAndSettle();
    expect(store.currentUser, 'traveler@gmail.com');
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Quên mật khẩu yêu cầu đúng Gmail và SĐT, sau đó đăng nhập lại',
      (tester) async {
    final store = TripStore();
    await store.load();
    await store.registerLocal(
      gmail: 'traveler@gmail.com',
      phone: '0912345678',
      password: 'passwordcu',
    );
    await tester.pumpWidget(TravelMate(store: store));

    await tester.ensureVisible(find.byKey(const ValueKey('forgot-password-link')));
    await tester.tap(find.byKey(const ValueKey('forgot-password-link')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('recovery-gmail')), findsOneWidget);
    expect(find.byKey(const ValueKey('recovery-phone')), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('recovery-gmail')),
        'traveler@gmail.com');
    await tester.enterText(find.byKey(const ValueKey('recovery-phone')),
        '0987654321');
    await tester.ensureVisible(find.byKey(const ValueKey('recovery-verify-button')));
    await tester.tap(find.byKey(const ValueKey('recovery-verify-button')));
    await tester.pumpAndSettle();
    expect(find.textContaining('không khớp'), findsOneWidget);
    expect(find.byKey(const ValueKey('recovery-new-password')), findsNothing);

    await tester.enterText(find.byKey(const ValueKey('recovery-phone')),
        '0912345678');
    await tester.tap(find.byKey(const ValueKey('recovery-verify-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('recovery-new-password')), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('recovery-new-password')),
        'passwordmoi');
    await tester.enterText(find.byKey(const ValueKey('recovery-confirm-password')),
        'passwordmoi');
    await tester.ensureVisible(find.byKey(const ValueKey('recovery-reset-button')));
    await tester.tap(find.byKey(const ValueKey('recovery-reset-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('login-identifier')), findsOneWidget);
    expect(find.textContaining('Đặt lại mật khẩu thành công'), findsOneWidget);
    expect(store.currentUser, isNull);
    await tester.enterText(find.byKey(const ValueKey('login-password')),
        'passwordmoi');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.pumpAndSettle();
    expect(store.currentUser, 'traveler@gmail.com');
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
