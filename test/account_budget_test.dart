import 'package:flutter_test/flutter_test.dart';
import 'package:travelmate/models.dart';
import 'package:travelmate/profile_page.dart';
import 'package:travelmate/trip_budget_page.dart';

void main() {
  test('Chấp nhận đúng định dạng Gmail, SĐT Việt Nam', () {
    expect(isValidGmail('ban@gmail.com'), isTrue);
    expect(isValidGmail('bad@gmail'), isFalse);
    expect(isValidGmail('ban@yahoo.com'), isFalse);
    expect(isValidPhone('0912345678'), isTrue);
    expect(isValidPhone('+84912345678'), isTrue);
    expect(isValidPhone('123'), isFalse);
    expect(isValidPassword('abc123'), isTrue);
    expect(isValidPassword('123'), isFalse);
  });

  test('Tổng dự kiến và JSON được lưu và đọc lại', () {
    final t = Trip(
      id: 'trip1',
      name: 'Đà Lạt', destination: 'Đà Lạt',
      start: DateTime(2026, 12, 12), end: DateTime(2026, 12, 14),
      plannedCosts: {'transport': 300000, 'food': 500000},
    );
    expect(t.plannedTotal, 800000);
    final copied = Trip.fromJson(t.toJson());
    expect(copied.plannedCosts['food'], 500000);
    expect(copied.plannedTotal, 800000);
    expect(formatVnd(copied.plannedTotal), '800.000 ₫');
  });

  test('Đọc lại dữ liệu v3 không có dự kiến', () {
    final t = Trip.fromJson({
      'id': 'old', 'name': 'Hà Nội', 'destination': 'Hà Nội',
      'start': '2026-12-01T00:00:00.000',
      'end': '2026-12-02T00:00:00.000',
      'activities': [], 'packing': [],
    });
    expect(t.plannedCosts, isEmpty);
    expect(t.plannedTotal, 0);
  });
}
