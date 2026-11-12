import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'fun_ui.dart';
import 'models.dart';
import 'trip_store.dart';
import 'discover_page.dart';
import 'dashboard_page.dart';
import 'profile_page.dart';
import 'trip_budget_page.dart';
import 'web_phone_viewport.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(TravelMate(store: TripStore()..load()));
}

const primaryTeal = Color(0xFF06A65F);
const deepTeal = Color(0xFF075F42);
const accentMint = Color(0xFFABEDC5);
const softCream = Color(0xFFFFF9EE);
const softCard = Colors.white;
const ink = Color(0xFF12352A);
const muted = Color(0xFF6D8175);
const softBorder = Color(0xFFEDE6D3);

class TravelMate extends StatefulWidget {
  final TripStore store;
  const TravelMate({super.key, required this.store});
  @override
  State<TravelMate> createState() => _TravelMateState();
}

class _TravelMateState extends State<TravelMate> {
  @override
  void initState() {
    super.initState();
    widget.store.addListener(refresh);
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.store.removeListener(refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryTeal,
      brightness: Brightness.light,
      primary: primaryTeal,
      secondary: deepTeal,
      surface: softCard,
    );

    return MaterialApp(
      title: 'TravelMate',
      debugShowCheckedModeBanner: false,
      builder: (context, child) => WebPhoneViewport(
        enabled: kIsWeb,
        child: child ?? const SizedBox.shrink(),
      ),
      locale: Locale(store.english ? 'en' : 'vi'),
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: softCream,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: ink,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: ink,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -.4,
          ),
        ),
        cardTheme: CardThemeData(
          color: softCard,
          elevation: 3,
          shadowColor: const Color(0x2606A65F),
          surfaceTintColor: Colors.transparent,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
            side: const BorderSide(color: softBorder),
          ),
        ),
        chipTheme: ChipThemeData(
          shape: const StadiumBorder(),
          side: const BorderSide(color: softBorder),
          backgroundColor: Colors.white,
          selectedColor: sunSoft,
          checkmarkColor: ink,
          labelStyle: const TextStyle(color: ink, fontWeight: FontWeight.w700),
        ),
        dividerColor: softBorder,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          labelStyle: const TextStyle(color: muted),
          hintStyle: const TextStyle(color: muted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: softBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: softBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: primaryTeal, width: 1.6),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: sunYellow,
          foregroundColor: ink,
          elevation: 6,
          extendedTextStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          shape: StadiumBorder(),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
          height: 74,
          indicatorColor: sunSoft,
          iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
                color: states.contains(WidgetState.selected) ? deepTeal : muted,
                size: 26,
              )),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: states.contains(WidgetState.selected) ? ink : muted,
            );
          }),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTeal,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryTeal,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            side: const BorderSide(color: softBorder),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: ink,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) =>
                states.contains(WidgetState.selected) ? sunSoft : Colors.white),
            foregroundColor: const WidgetStatePropertyAll(ink),
            side: const WidgetStatePropertyAll(BorderSide(color: softBorder)),
          ),
        ),
      ),
      home: !store.loaded
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : store.currentUser == null
              ? AuthPage(store: store)
              : HomePage(store: store),
    );
  }
}

class PageWidth extends StatelessWidget {
  final Widget child;
  const PageWidth({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: child,
        ),
      );
}

class HomePage extends StatefulWidget {
  final TripStore store;
  const HomePage({super.key, required this.store});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  String query = '';
  int tripFilter = 0;

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Transform.rotate(
              angle: -.1,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1FD18A), deepTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Color(0x5506A65F), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.flight_takeoff_rounded, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            const Text('TravelMate', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(width: 6),
            const Text('🌴', style: TextStyle(fontSize: 20)),
          ],
        ),
        actions: const [],
      ),
      body: SafeArea(
        child: PageWidth(child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(
            key: ValueKey(tab),
            child: tab == 0
                ? DashboardPage(
                    store: s,
                    onCreate: () => showTripEditor(context, s),
                    onTrips: () => setState(() => tab = 1),
                    onExplore: () => setState(() => tab = 2),
                    onOpenTrip: (trip) => Navigator.push(context,
                      MaterialPageRoute<void>(builder: (_) => TripPage(store: s, trip: trip))),
                  )
                : tab == 1
                    ? _trips(s)
                    : tab == 2
                        ? DiscoverPage(store: s, onCreated: () => setState(() => tab = 1))
                        : ProfilePage(
                            store: s,
                            onTeam: () => Navigator.push(context,
                              MaterialPageRoute<void>(builder: (_) => TeamPage(store: s))),
                          ),
          ),
        )),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Material(
            elevation: 10,
            shadowColor: const Color(0x4406A65F),
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            clipBehavior: Clip.antiAlias,
            child: NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (x) => setState(() => tab = x),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: s.tr('Trang chủ', 'Home'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.luggage_outlined),
                  selectedIcon: const Icon(Icons.luggage_rounded),
                  label: s.tr('Chuyến đi', 'Trips'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.explore_outlined),
                  selectedIcon: const Icon(Icons.explore),
                  label: s.tr('Khám phá', 'Explore'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.face_outlined),
                  selectedIcon: const Icon(Icons.face_rounded),
                  label: s.tr('Tài khoản', 'Account'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: tab == 1
          ? FloatingActionButton.extended(
              onPressed: () => showTripEditor(context, s),
              icon: const Icon(Icons.add),
              label: Text(s.tr('Tạo chuyến đi', 'New trip')),
            )
          : null,
    );
  }

  Widget _trips(TripStore s) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
        children: [
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.tr('Hành trình của bạn 🧳', 'Your journeys 🧳'),
                      style: const TextStyle(
                        fontSize: 22,
                        color: ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.tr(
                        'Theo dõi và sắp xếp mọi chuyến đi một cách gọn gàng.',
                        'Keep all your trips organized in one place.',
                      ),
                      style: const TextStyle(color: muted),
                    ),
                  ],
                ),
              ),
              Chip(
                backgroundColor: sunSoft,
                side: BorderSide.none,
                label: Text('${s.tr('Tổng', 'Total')}: ${s.trips.length}'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (text) => setState(() => query = text.trim().toLowerCase()),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded, color: primaryTeal),
              hintText: s.tr('Tìm tên chuyến đi hoặc điểm đến...', 'Search trip name or destination...'),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ChoiceChip(label: Text(s.tr('Tất cả', 'All')), selected: tripFilter == 0,
              onSelected: (_) => setState(() => tripFilter = 0)),
            ChoiceChip(label: Text(s.tr('Sắp tới', 'Upcoming')), selected: tripFilter == 1,
              onSelected: (_) => setState(() => tripFilter = 1)),
            ChoiceChip(label: Text(s.tr('Đã qua', 'Past')), selected: tripFilter == 2,
              onSelected: (_) => setState(() => tripFilter = 2)),
          ]),
          const SizedBox(height: 16),
          if (s.error != null) ErrorStrip(message: s.error!),
          if (s.trips.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const EmojiBadge(emoji: '🧳', size: 88, color: sunSoft, angle: -.08),
                    const SizedBox(height: 16),
                    Text(
                      s.tr('Chưa có hành trình nào', 'No journeys yet'),
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.tr(
                        'Nhấn “Tạo chuyến đi” để bắt đầu lên kế hoạch cho hành trình đầu tiên.',
                        'Tap “New trip” to start planning your first adventure.',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: muted),
                    ),
                  ],
                ),
              ),
            ),
          if (s.trips.isNotEmpty)
            Builder(builder: (context) {
              final now = dateOnly(DateTime.now());
              final matches = s.trips.where((trip) {
                final nameMatch = '${trip.name} ${trip.destination}'.toLowerCase().contains(query);
                final dateMatch = tripFilter == 0 ||
                  (tripFilter == 1 && !dateOnly(trip.end).isBefore(now)) ||
                  (tripFilter == 2 && dateOnly(trip.end).isBefore(now));
                return nameMatch && dateMatch;
              }).toList()..sort((a,b) => a.start.compareTo(b.start));
              if (matches.isEmpty) {
                return EmptyCard(text: s.tr('Không tìm thấy chuyến đi phù hợp.',
                  'No matching trips found.'));
              }
              return LayoutBuilder(builder: (context, constraints) {
                final wide = constraints.maxWidth >= 700;
