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
              'Your adventure, your way.'),
              style: const TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 16),
            Pressable(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: sunYellow,
                  foregroundColor: _dark, elevation: 4,
                  shadowColor: const Color(0x66000000),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12)),
                onPressed: onCreate,
                icon: const Icon(Icons.rocket_launch_rounded, size: 19),
                label: Text(store.tr('Bắt đầu ngay', 'Start planning')),
              ),
            ),
          ]),
        ),
      ]),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  final String emoji;
  final String title;
  final FunPalette palette;
  final VoidCallback onTap;
  const _QuickAction({required this.emoji, required this.title,
    required this.palette, required this.onTap});

  @override
  Widget build(BuildContext context) => Pressable(
    child: Material(
      color: palette.soft,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 56, height: 56, alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: palette.shadow, blurRadius: 12, offset: const Offset(0, 5))],
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 28, height: 1)),
            ),
            const SizedBox(height: 10),
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
              style: const TextStyle(color: _dark, fontSize: 12,
                  fontWeight: FontWeight.w800, height: 1.3)),
          ]),
        ),
      ),
    ),
  );
}

class _UpcomingCard extends StatelessWidget {
  final Trip trip;
  final TripStore store;
  final VoidCallback onTap;
  const _UpcomingCard({required this.trip, required this.store, required this.onTap});

  String _countdown() {
    final today = dateOnly(DateTime.now());
    final start = dateOnly(trip.start);
    final end = dateOnly(trip.end);
    if (!today.isBefore(start) && !today.isAfter(end)) {
      return store.tr('Đang diễn ra 🔥', 'Happening now 🔥');
    }
    final days = start.difference(today).inDays;
    if (days <= 1) return store.tr('Ngày mai bay! 🎉', 'Tomorrow! 🎉');
    return store.tr('Còn $days ngày ⏳', '$days days to go ⏳');
  }

  @override
  Widget build(BuildContext context) {
    final pal = paletteFor(trip.destination);
    return Pressable(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              height: 7,
              decoration: BoxDecoration(gradient: pal.gradient),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  EmojiBadge(
                    emoji: emojiForDestination('${trip.destination} ${trip.name}'),
                    size: 56, color: pal.soft, angle: -.08),
                  const SizedBox(width: 13),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(trip.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _dark)),
                    const SizedBox(height: 4),
                    Text('📍 ${trip.destination}', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted)),
                  ])),
                  Icon(Icons.arrow_circle_right_rounded, size: 28, color: pal.b),
                ]),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: sunSoft, borderRadius: BorderRadius.circular(20)),
                  child: Text(_countdown(),
                    style: const TextStyle(fontWeight: FontWeight.w900, color: _dark, fontSize: 13)),
                ),
                const SizedBox(height: 14),
                Wrap(spacing: 14, runSpacing: 7, children: [
                  _detail('📅', '${formatDate(trip.start)} – ${formatDate(trip.end)}'),
                  _detail('📝', '${trip.activities.length} ${store.tr('hoạt động', 'activities')}'),
                  _detail('🎒', '${trip.preparedCount}/${trip.packing.length} ${store.tr('đã chuẩn bị', 'packed')}'),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _detail(String emoji, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Text(emoji, style: const TextStyle(fontSize: 14)), const SizedBox(width: 5),
    Text(label, style: const TextStyle(fontSize: 12.5, color: _muted, fontWeight: FontWeight.w600)),
  ]);
}

class _InspirationCard extends StatelessWidget {
  final TripStore store;
  final VoidCallback onExplore;
  const _InspirationCard({required this.store, required this.onExplore});

  @override
  Widget build(BuildContext context) => Pressable(
    child: Material(
      color: sunSoft,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        onTap: onExplore,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            const EmojiBadge(emoji: '🏝️', size: 60, color: Colors.white, angle: -.1),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(store.tr('Chưa biết đi đâu?', 'Need a destination?'),
                style: const TextStyle(color: _dark, fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text(store.tr('Thử lịch trình mẫu và sửa theo sở thích của bạn.',
                'Start with a template and make it yours.'),
                style: const TextStyle(color: Color(0xFF6B5A1E), fontSize: 13, height: 1.35)),
            ])),
            const Icon(Icons.arrow_forward_rounded, color: _dark, size: 22),
          ]),
        ),
      ),
    ),
  );
}

class _EmptyJourney extends StatelessWidget {
  final TripStore store;
  final VoidCallback onCreate;
  const _EmptyJourney({required this.store, required this.onCreate});

  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(20),
    child: Row(children: [
      const EmojiBadge(emoji: '🧳', size: 58, color: sunSoft, angle: -.08),
      const SizedBox(width: 15),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(store.tr('Chưa có hành trình nào', 'No journeys yet'),
          style: const TextStyle(color: _dark, fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(store.tr('Tạo chuyến đi đầu tiên để bắt đầu.', 'Create your first trip to start.'),
          style: const TextStyle(color: _muted, fontSize: 12.5)),
      ])),
      IconButton(onPressed: onCreate,
        icon: const Icon(Icons.add_circle_rounded, color: _green, size: 32)),
    ]),
  ));
}
