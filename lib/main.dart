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
