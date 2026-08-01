// Floating "Free 7-Day Trial" sticker badge for the home hero. Plays a
// short scale+fade entrance, then settles into a continuous slow float.
// Purely decorative — wrap with Positioned in the caller and this widget
// wraps itself in IgnorePointer so it never intercepts taps.

import 'package:flutter/material.dart';

class FloatingTrialBadge extends StatefulWidget {
  const FloatingTrialBadge({super.key, this.size});

  /// Explicit size override. When null, the badge sizes itself responsively
  /// from the screen width (scaling down on narrow/mobile widths).
  final double? size;

  @override
  State<FloatingTrialBadge> createState() => _FloatingTrialBadgeState();
}

class _FloatingTrialBadgeState extends State<FloatingTrialBadge> with TickerProviderStateMixin {
  // Continuous up/down float loop.
  late final AnimationController _floatController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);
  late final Animation<double> _floatY = Tween<double>(begin: -8, end: 8).animate(
    CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
  );

  // One-shot entrance: scale 0.8 → 1.0, fade 0 → 1.
  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final Animation<double> _entranceScale = Tween<double>(begin: 0.8, end: 1.0).animate(
    CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
  );
  late final Animation<double> _entranceFade = CurvedAnimation(
    parent: _entranceController,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    _entranceController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  double _responsiveSize(double screenWidth) {
    if (screenWidth >= 1100) return 125;
    if (screenWidth >= 900) return 100;
    if (screenWidth >= 600) return 80;
    return 64;
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size ?? _responsiveSize(MediaQuery.of(context).size.width);

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatController, _entranceController]),
        builder: (context, child) => Opacity(
          opacity: _entranceFade.value,
          child: Transform.scale(
            scale: _entranceScale.value,
            child: Transform.translate(
              offset: Offset(0, _floatY.value),
              child: child,
            ),
          ),
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset('assets/images/7days_nobg.png', fit: BoxFit.contain),
        ),
      ),
    );
  }
}
