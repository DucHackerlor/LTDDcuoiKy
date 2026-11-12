import 'package:flutter/material.dart';
import 'discover_page.dart';
import 'fun_ui.dart';
import 'models.dart';
import 'trip_store.dart';

const _green = Color(0xFF06A65F);
const _dark = Color(0xFF12352A);
const _muted = Color(0xFF6F8179);

class DashboardPage extends StatelessWidget {
  final TripStore store;
  final VoidCallback onCreate;
  final VoidCallback onTrips;
  final VoidCallback onExplore;
  final void Function(Trip trip) onOpenTrip;

  const DashboardPage({
    super.key,
    required this.store,
    required this.onCreate,
    required this.onTrips,
    required this.onExplore,
    required this.onOpenTrip,
  });

  @override
  Widget build(BuildContext context) {
    final now = dateOnly(DateTime.now());
    final next = store.trips.where((trip) => !dateOnly(trip.end).isBefore(now)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    final upcoming = next.isEmpty ? null : next.first;
    final width = MediaQuery.sizeOf(context).width;
    final hour = DateTime.now().hour;
    final greetEmoji = hour < 11 ? '☀️' : (hour < 18 ? '🌤️' : '🌙');

    final quick = [
      _QuickAction(emoji: '📍', title: store.tr('Tạo lịch trình', 'New trip'),
        palette: funPalettes[0], onTap: onCreate),
      _QuickAction(emoji: '🗺️', title: store.tr('Chuyến đi', 'My trips'),
        palette: funPalettes[1], onTap: onTrips),
      _QuickAction(emoji: '🧭', title: store.tr('Gợi ý điểm đến', 'Explore'),
        palette: funPalettes[2], onTap: onExplore),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 118),
      children: [
        PopIn(
          index: 0,
          child: Row(
            children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(store.tr('CHÀO BẠN, NGƯỜI YÊU XÊ DỊCH', 'HELLO, EXPLORER'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                        letterSpacing: 1.1, color: _green)),
                const SizedBox(height: 4),
                Text(store.tr('Hôm nay đi đâu? ✨', 'Where to next? ✨'),
                    style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900,
                        height: 1.2, color: _dark)),
              ])),
              const SizedBox(width: 10),
              EmojiBadge(emoji: greetEmoji, size: 54, color: sunSoft, angle: .12),
            ],
          ),
        ),
        const SizedBox(height: 18),
        PopIn(index: 1, child: _Banner(store: store, onCreate: onCreate)),
        const SizedBox(height: 25),
        _sectionTitle(store.tr('Truy cập nhanh', 'Quick actions')),
        const SizedBox(height: 13),
        LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth >= 650;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: wide ? 16 : 10,
              mainAxisExtent: width < 370 ? 144 : 134,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quick.length,
            itemBuilder: (context, index) => PopIn(index: 2 + index, child: quick[index]),
          );
        }),
        const SizedBox(height: 26),
        Row(children: [
          Expanded(child: _sectionTitle(store.tr('Chuyến đi tiếp theo', 'Next adventure'))),
          TextButton(onPressed: onTrips, child: Text(store.tr('Xem tất cả', 'See all'))),
        ]),
        const SizedBox(height: 12),
        PopIn(
          index: 3,
          child: upcoming != null
              ? _UpcomingCard(trip: upcoming, store: store, onTap: () => onOpenTrip(upcoming))
              : _EmptyJourney(store: store, onCreate: onCreate),
        ),
        const SizedBox(height: 25),
        Row(children: [
          Expanded(child: _sectionTitle(store.tr('Một chút cảm hứng', 'A little inspiration'))),
          const Text('🌈', style: TextStyle(fontSize: 22)),
        ]),
        const SizedBox(height: 12),
        PopIn(index: 4, child: _InspirationCard(store: store, onExplore: onExplore)),
        const SizedBox(height: 12),
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final t = templates[i];
              final pal = funPalettes[(i + 3) % funPalettes.length];
              return Pressable(
                child: Material(
                  color: pal.soft,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: onExplore,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(emojiForDestination(t.enDestination), style: const TextStyle(fontSize: 19)),
                        const SizedBox(width: 7),
                        Text(store.english ? t.enDestination : t.destination,
                            style: const TextStyle(color: _dark, fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) => Text(title,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: _dark));
}

class _Banner extends StatelessWidget {
  final TripStore store;
  final VoidCallback onCreate;
  const _Banner({required this.store, required this.onCreate});

  Widget _dot(Color c, double size) => Container(
      width: size, height: size, decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 214),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
          colors: [Color(0xFF19D08A), Color(0xFF06A65F), Color(0xFF0B8F9C)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(30),
      boxShadow: const [BoxShadow(color: Color(0x4406A65F), blurRadius: 26, offset: Offset(0, 12))],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(children: [
        Positioned(right: -45, top: -65,
          child: Container(width: 210, height: 210,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 34)))),
        Positioned(right: 118, top: 20, child: _dot(sunYellow, 10)),
        Positioned(right: 38, top: 128, child: _dot(bubblegum, 9)),
        Positioned(right: 160, bottom: 74, child: _dot(const Color(0xFFB8F5DA), 7)),
        Positioned(right: 78, bottom: 22,
          child: Transform.rotate(angle: -.35,
            child: const Text('✈️', style: TextStyle(fontSize: 38)))),
        const Positioned(right: 22, bottom: 14,
          child: Text('🌴', style: TextStyle(fontSize: 46))),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
              child: Text(store.tr('TRAVELMATE • LÊN KẾ HOẠCH THẬT DỄ', 'TRAVELMATE • PLAN WITH EASE'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800,
                    fontSize: 10.5, letterSpacing: .4)),
            ),
            const SizedBox(height: 18),
            Text(store.tr('Đi nhiều hơn.\nLo ít hơn.', 'Travel more.\nWorry less.'),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                  color: Colors.white, height: 1.12)),
            const SizedBox(height: 8),
            Text(store.tr('Lịch trình của bạn, theo cách của bạn.',
