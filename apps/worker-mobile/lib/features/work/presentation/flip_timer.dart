import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/time/yerevan_time.dart';
import '../../../core/ui/l10n_ext.dart';

/// Round work/break timer (WORKER_APP_SPEC "Work screen"). The front face is
/// the work timer and the back face is the break timer. When [showBreak]
/// changes, the dial turns over around its vertical axis. Tapping it calls
/// [onTap] (start break / resume). The durations come from the caller,
/// which computes them from stored timestamps. The seconds ring is derived
/// from the same value, not from a counter.
class FlipTimer extends StatefulWidget {
  const FlipTimer({
    super.key,
    required this.showBreak,
    required this.work,
    required this.breakTime,
    this.onTap,
    this.size = 280,
  });

  final bool showBreak;
  final Duration work;
  final Duration breakTime;
  final VoidCallback? onTap;
  final double size;

  @override
  State<FlipTimer> createState() => _FlipTimerState();
}

class _FlipTimerState extends State<FlipTimer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    value: widget.showBreak ? 1 : 0,
  );
  late final Animation<double> _turn = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  @override
  void didUpdateWidget(FlipTimer old) {
    super.didUpdateWidget(old);
    if (old.showBreak != widget.showBreak) {
      widget.showBreak ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final front = _Face(
      key: const Key('work.timer.work'),
      size: widget.size,
      color: AppColors.working,
      icon: Icons.construction,
      label: l10n.workTime,
      main: widget.work,
      otherLabel: l10n.breakTime,
      other: widget.breakTime,
      hint: l10n.tapToBreak,
    );
    final back = _Face(
      key: const Key('work.timer.break'),
      size: widget.size,
      color: AppColors.onBreak,
      icon: Icons.coffee,
      label: l10n.breakTime,
      main: widget.breakTime,
      otherLabel: l10n.workTime,
      other: widget.work,
      hint: l10n.tapToResume,
    );

    return Semantics(
      button: widget.onTap != null,
      label: widget.showBreak ? l10n.tapToResume : l10n.tapToBreak,
      child: GestureDetector(
        key: const Key('work.timer'),
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _turn,
          builder: (context, _) {
            final t = _turn.value;
            final backVisible = t >= 0.5;
            // A slight dip mid-turn gives the flip some depth.
            final scale = 1 - 0.08 * math.sin(t * math.pi);
            return Transform.scale(
              scale: scale,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY(t * math.pi),
                child: backVisible
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: back,
                      )
                    : front,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Face extends StatelessWidget {
  const _Face({
    super.key,
    required this.size,
    required this.color,
    required this.icon,
    required this.label,
    required this.main,
    required this.otherLabel,
    required this.other,
    required this.hint,
  });

  final double size;
  final Color color;
  final IconData icon;
  final String label;
  final Duration main;
  final String otherLabel;
  final Duration other;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seconds = main.isNegative ? 0 : main.inMilliseconds % 60000;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.30),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: CustomPaint(
          painter: _RingPainter(color: color, progress: seconds / 60000),
          child: Padding(
            padding: EdgeInsets.all(size * 0.14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: size * 0.12),
                const SizedBox(height: 4),
                FittedBox(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                FittedBox(
                  child: Text(
                    formatHms(main),
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                FittedBox(
                  child: Text(
                    '$otherLabel  ${formatHms(other)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  child: Row(
                    children: [
                      Icon(Icons.touch_app_outlined, size: 18, color: color),
                      const SizedBox(width: 4),
                      Text(
                        hint,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Track ring plus an arc that sweeps once a minute.
class _RingPainter extends CustomPainter {
  const _RingPainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.05;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.width / 2 - stroke,
    );
    canvas
      ..drawArc(
        rect,
        0,
        2 * math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = color.withValues(alpha: 0.15),
      )
      ..drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
