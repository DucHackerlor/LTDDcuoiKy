import 'package:flutter/material.dart';

class WebPhoneViewport extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const WebPhoneViewport({super.key, required this.enabled, required this.child});

  static const double _desktopBreakpoint = 560;
  static const double _phoneWidth = 396;
  static const double _phoneHeight = 840;
  static const double _statusBarHeight = 48;
  static const double _gestureBarHeight = 24;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _desktopBreakpoint ||
            constraints.maxHeight < 430) {
          return child;
        }

        final scale = [
          1.0,
          (constraints.maxWidth - 32) / _phoneWidth,
          (constraints.maxHeight - 24) / _phoneHeight,
        ].reduce((a, b) => a < b ? a : b);

        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0C1821), Color(0xFF142838), Color(0xFF07141D)],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: -180,
                left: -160,
                child: _AmbientGlow(
                  size: 500,
                  color: const Color(0x261AAE84),
                ),
              ),
              Positioned(
                bottom: -220,
                right: -140,
                child: _AmbientGlow(
                  size: 540,
                  color: const Color(0x172987B7),
                ),
              ),
              Center(
                child: SizedBox(
                  key: const ValueKey('web-phone-scaled'),
                  width: _phoneWidth * scale,
                  height: _phoneHeight * scale,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: _phoneWidth,
                      height: _phoneHeight,
                      child: Container(
                  key: const ValueKey('web-phone-surface'),
                  width: _phoneWidth,
                  height: _phoneHeight,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFD9E1E2),
                        Color(0xFF6D7E82),
                        Color(0xFFE8EDEF),
                        Color(0xFF47565B),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(47),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xB8000000),
                        blurRadius: 42,
                        offset: Offset(0, 22),
                        spreadRadius: 3,
                      ),
                      BoxShadow(
                        color: Color(0x34000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF10191A),
                      borderRadius: BorderRadius.circular(43),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: ColoredBox(
                          color: const Color(0xFFFFF9EE),
                          child: Column(
                            children: [
                              const SizedBox(
                                key: ValueKey('web-phone-status-bar'),
                                height: _statusBarHeight,
                                child: _PhoneStatusBar(),
                              ),
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, screen) {
                                    final original = MediaQuery.of(context);
                                    return MediaQuery(
                                      data: original.copyWith(
                                        size: Size(screen.maxWidth, screen.maxHeight),
                                        padding: EdgeInsets.zero,
                                        viewPadding: EdgeInsets.zero,
                                      ),
                                      child: child,
                                    );
                                  },
                                ),
