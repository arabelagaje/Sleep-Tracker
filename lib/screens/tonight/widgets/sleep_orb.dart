import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'live_timer_text.dart';

class SleepOrb extends StatefulWidget {
  const SleepOrb({
    super.key,
    required this.isSleeping,
    this.startedAt,
    required this.onPressed,
    this.onLongPress,
  });

  final bool isSleeping;
  final DateTime? startedAt;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress; // only offered while sleeping (cancel)

  @override
  State<SleepOrb> createState() => _SleepOrbState();
}

class _SleepOrbState extends State<SleepOrb> with SingleTickerProviderStateMixin {
  // Drives the slow "breathing" glow while sleeping.
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2500),
  );
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(SleepOrb old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.isSleeping && !_breath.isAnimating) {
      _breath.repeat(reverse: true);
    } else if (!widget.isSleeping) {
      _breath.stop();
      _breath.value = 0;
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final showStars = dark || widget.isSleeping;
    return SizedBox(
      height: 290,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: showStars ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              child: CustomPaint(painter: _StarsPainter(c.accentInk)),
            ),
          ),
          Semantics(
            button: true,
            label: widget.isSleeping ? 'Stop sleep' : 'Start sleep',
            child: GestureDetector(
              onTapDown: (_) => setState(() => _pressed = true),
              onTapCancel: () => setState(() => _pressed = false),
              onTapUp: (_) => setState(() => _pressed = false),
              onTap: widget.onPressed,
              onLongPress: widget.isSleeping ? widget.onLongPress : null,
              child: AnimatedScale(
                scale: _pressed ? 0.97 : 1,
                duration: const Duration(milliseconds: 200),
                child: AnimatedBuilder(
                  animation: _breath,
                  builder: (context, child) {
                    final t = Curves.easeInOut.transform(_breath.value);
                    final inner = 14 + 8 * t, outer = 30 + 14 * t;
                    return Container(
                      width: 216,
                      height: 216,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(-0.36, -0.44),
                          radius: 0.95,
                          colors: [c.orbA, c.orbB],
                          stops: const [0, 0.7],
                        ),
                        boxShadow: [
                          BoxShadow(color: c.orbGlow, spreadRadius: inner),
                          BoxShadow(
                            color: c.orbGlow.withValues(alpha: c.orbGlow.a * 0.45),
                            spreadRadius: outer,
                          ),
                          BoxShadow(
                            color: c.orbB,
                            blurRadius: 50,
                            spreadRadius: -18,
                            offset: const Offset(0, 24),
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.white, fontFamily: 'PlusJakartaSans'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: widget.isSleeping && widget.startedAt != null
                          ? [
                              LiveTimerText(
                                startedAt: widget.startedAt!,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const _OrbLabel('Tap when you wake'),
                              if (widget.onLongPress != null) ...[
                                const SizedBox(height: 10),
                                const Opacity(
                                  opacity: 0.65,
                                  child: Text(
                                    'Hold to cancel',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ]
                          : const [
                              Icon(Icons.bedtime_outlined, size: 42, color: Colors.white),
                              SizedBox(height: 6),
                              _OrbLabel('Start sleep'),
                            ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbLabel extends StatelessWidget {
  const _OrbLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: 0.9,
    child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
  );
}

class _StarsPainter extends CustomPainter {
  _StarsPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 26; i++) {
      final paint = Paint()..color = color.withValues(alpha: 0.15 + (i % 5) / 10);
      final o = Offset(size.width * ((i * 37) % 100) / 100, size.height * ((i * 53) % 100) / 100);
      canvas.drawCircle(o, 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.color != color;
}
