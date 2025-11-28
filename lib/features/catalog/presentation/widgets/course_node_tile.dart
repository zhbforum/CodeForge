import 'package:flutter/material.dart';
import 'package:mobile_app/core/models/course_node.dart';

class CourseNodeTile extends StatefulWidget {
  const CourseNodeTile({
    required this.node,
    required this.onTap,
    super.key,
    this.size = 108,
    this.isActive = false,
    this.pulsePeriod = const Duration(milliseconds: 900),
  });

  final CourseNode node;
  final VoidCallback onTap;
  final double size;
  final bool isActive;
  final Duration pulsePeriod;

  @override
  State<CourseNodeTile> createState() => _CourseNodeTileState();
}

class _CourseNodeTileState extends State<CourseNodeTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.pulsePeriod);
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    if (widget.isActive) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant CourseNodeTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulsePeriod != widget.pulsePeriod) {
      _ctrl.duration = widget.pulsePeriod;
      if (_ctrl.isAnimating) {
        _ctrl
          ..reset()
          ..repeat(reverse: true);
      }
    }
    if (widget.isActive && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.isActive && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locked = widget.node.status == NodeStatus.locked;
    final done = widget.node.status == NodeStatus.done;

    final bg = switch (widget.node.status) {
      NodeStatus.locked => cs.surfaceContainer,
      NodeStatus.available => cs.surface,
      NodeStatus.done => cs.primaryContainer,
    };

    final borderColor = switch (widget.node.status) {
      NodeStatus.locked => cs.outlineVariant,
      NodeStatus.available => cs.primary.withValues(alpha: 0.65),
      NodeStatus.done => cs.primary,
    };

    final radius = (widget.size * 0.22).clamp(14.0, 24.0);
    final iconMainSize = (widget.size * 0.42).clamp(30.0, 46.0);
    final iconBadgeSize = (widget.size * 0.22).clamp(16.0, 22.0);
    final badgeInset = (widget.size * 0.07).clamp(5.0, 8.0);

    final tile = Container(
      width: widget.size,
      height: widget.size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, 6),
            color: Color(0x40000000),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: _Inner(
        node: widget.node,
        locked: locked,
        done: done,
        mainSize: iconMainSize,
        badgeSize: iconBadgeSize,
        badgeInset: badgeInset,
      ),
    );

    if (!widget.isActive || done) return _asSemantic(tile);

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        return _asSemantic(
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _OutlinePulsePainter(
                      progress: _pulse.value,
                      color: cs.primary,
                      radius: radius,
                      borderWidth: 2,
                      intensity: 1.35,
                    ),
                  ),
                ),
              ),
              tile,
            ],
          ),
        );
      },
    );
  }

  Widget _asSemantic(Widget child) {
    final locked = widget.node.status == NodeStatus.locked;
    return Semantics(
      button: true,
      label: widget.node.title,
      child: GestureDetector(onTap: locked ? null : widget.onTap, child: child),
    );
  }
}

class _OutlinePulsePainter extends CustomPainter {
  _OutlinePulsePainter({
    required this.progress,
    required this.color,
    required this.radius,
    required this.borderWidth,
    this.intensity = 1.0,
  });

  final double progress;
  final Color color;
  final double radius;
  final double borderWidth;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final base = RRect.fromRectAndRadius(
      rect.deflate(1.2),
      Radius.circular(radius - 1.2),
    );

    final t = progress;

    final a1 = (0.38 + 0.42 * t) * (0.9 + 0.1 * intensity);
    final w1 = borderWidth + (0.7 + 1.4 * t) * intensity;
    final r1 = base.deflate(0.4);
    final p1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w1
      ..color = color.withValues(alpha: a1);
    canvas.drawRRect(r1, p1);

    final a2 = (0.22 + 0.28 * (1 - t)) * (0.9 + 0.1 * intensity);
    final w2 = borderWidth + (0.4 + 0.9 * (1 - t)) * intensity;
    final r2 = base.deflate(2.2);
    final p2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w2
      ..color = color.withValues(alpha: a2);
    canvas.drawRRect(r2, p2);

    final a3 = 0.10 * intensity;
    if (a3 > 0.01) {
      final w3 = borderWidth + 0.4 * intensity;
      final r3 = base.deflate(3.8);
      final p3 = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w3
        ..color = color.withValues(alpha: a3);
      canvas.drawRRect(r3, p3);
    }
  }

  @override
  bool shouldRepaint(covariant _OutlinePulsePainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.radius != radius ||
      old.borderWidth != borderWidth ||
      old.intensity != intensity;
}

class _Inner extends StatelessWidget {
  const _Inner({
    required this.node,
    required this.locked,
    required this.done,
    required this.mainSize,
    required this.badgeSize,
    required this.badgeInset,
  });

  final CourseNode node;
  final bool locked;
  final bool done;
  final double mainSize;
  final double badgeSize;
  final double badgeInset;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (done) {
      final colorOn = cs.onPrimaryContainer;
      return Center(
        child: Icon(Icons.check_rounded, size: mainSize, color: colorOn),
      );
    }

    if (locked) {
      return Center(
        child: Icon(Icons.lock, size: mainSize, color: cs.onSurfaceVariant),
      );
    }

    final icon = switch (node.type) {
      NodeType.practice => Icons.bolt,
      NodeType.quiz => Icons.help_outline,
      NodeType.boss => Icons.star,
      _ => Icons.play_arrow,
    };

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(icon, size: mainSize, color: cs.onSurface),
        if (node.progress > 0)
          Positioned(
            right: badgeInset,
            top: badgeInset,
            child: Text(
              '${node.progress}%',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
      ],
    );
  }
}
