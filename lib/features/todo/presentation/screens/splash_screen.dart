import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:unicon_todo/features/todo/presentation/screens/main_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  /// Splash ekranni qancha ushlab turish (animatsiya bilan birga).
  static const Duration totalDuration = Duration(milliseconds: 1600);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    // Status bar rangini moslash (optional)
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scale = CurvedAnimation(parent: _ac, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeIn);
    _slideUp = Tween<Offset>(begin: const Offset(0, .2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));

    // Animatsiyani boshlash
    _ac.forward();

    scheduleMicrotask(() async {
      await Future.delayed(SplashPage.totalDuration);
      if (!mounted) return;

      // Keyingi sahifaga o'tish
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary.withOpacity(.95),
                primary.withOpacity(.75),
                primary.withOpacity(.55),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      height: 104,
                      width: 104,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(.25),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.1),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slideUp,
                      child: Column(
                        children: [
                          Text(
                            'UniCon Todo',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: .2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Vazifalar — tartib va samaradorlik',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _fade,
                    child: const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.8, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
