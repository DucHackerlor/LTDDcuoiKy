import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelmate/web_phone_viewport.dart';

void main() {
  testWidgets('Web desktop: khung dien thoai co vien, status bar va home bar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: WebPhoneViewport(
          enabled: true,
          child: ColoredBox(color: Colors.green),
        ),
      ),
    ));

    final frame = find.byKey(const ValueKey('web-phone-surface'));
    expect(frame, findsOneWidget);
    expect(tester.getSize(frame).width, 396);
    expect(tester.getSize(frame).height, 840);
    expect(tester.getSize(find.byKey(const ValueKey('web-phone-scaled'))),
        const Size(396, 840));
    expect(find.byKey(const ValueKey('web-phone-status-bar')), findsOneWidget);
    expect(find.byKey(const ValueKey('web-phone-gesture-bar')), findsOneWidget);
  });

  const ratio = 396 / 840;

  Future<void> pumpAt(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: WebPhoneViewport(enabled: true, child: SizedBox.expand()),
      ),
    ));
  }

  testWidgets('Web desktop cua so thap: khung thu nho deu, khong bi map', (tester) async {
    await pumpAt(tester, const Size(900, 600));
    final shown = tester.getSize(find.byKey(const ValueKey('web-phone-scaled')));
    expect(shown.height, closeTo(576, .01));
    expect(shown.width / shown.height, closeTo(ratio, .001));
    expect(tester.getSize(find.byKey(const ValueKey('web-phone-surface'))),
        const Size(396, 840));
  });

  testWidgets('Web laptop 1366x768: dung ti le thon gon', (tester) async {
    await pumpAt(tester, const Size(1366, 768));
    final shown = tester.getSize(find.byKey(const ValueKey('web-phone-scaled')));
    expect(shown.height, closeTo(744, .01));
    expect(shown.width / shown.height, closeTo(ratio, .001));
  });

  testWidgets('Web desktop cua so rat thap: van giu ti le', (tester) async {
    await pumpAt(tester, const Size(900, 500));
    final shown = tester.getSize(find.byKey(const ValueKey('web-phone-scaled')));
    expect(shown.height, closeTo(476, .01));
    expect(shown.width / shown.height, closeTo(ratio, .001));
  });

  testWidgets('Web mobile / F12 device toolbar: khong long them vien may', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: WebPhoneViewport(
          enabled: true,
          child: ColoredBox(color: Colors.green),
        ),
      ),
    ));

    expect(find.byKey(const ValueKey('web-phone-surface')), findsNothing);
  });

  testWidgets('Android/native: khong hien khung dien thoai gia', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 960));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: WebPhoneViewport(
          enabled: false,
          child: ColoredBox(color: Colors.green),
        ),
      ),
    ));

    expect(find.byKey(const ValueKey('web-phone-surface')), findsNothing);
  });
}
