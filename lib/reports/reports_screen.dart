import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/appcolors.dart';

const _green = Color(0xFF16A34A);
const _orange = Color(0xFFF59E0B);
const _darkRed = Color(0xFFB91C1C);

/// Draws centered text on a canvas.
void _paintText(Canvas c, String text, Offset center,
    {double size = 12,
      Color color = AppColors.navy,
      FontWeight weight = FontWeight.w500}) {
  final tp = TextPainter(
    text: TextSpan(
        text: text,
        style: TextStyle(fontSize: size, color: color, fontWeight: weight)),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  // ---- Dummy data (replace with backend data later) ----
  static const _completed = 9, _pending = 2, _critical = 1;
  static const _months = ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'];
  static const _trend = <double>[3, 5, 4, 7, 8, 9];
  static const _incidentLabels = ['Minor', 'Major', 'Critical', 'Resolved'];
  static const _incidentValues = <double>[3, 2, 1, 1];
  static const _incidentColors = [AppColors.red, _orange, _darkRed, _green];
  static const _riskValues = <double>[50, 30, 20]; // high, medium, low

  @override
  Widget build(BuildContext context) {
    final total = _completed + _pending + _critical;
    final percent = (_completed / total * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reports',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy)),
          const SizedBox(height: 4),
          const Text('Sample data for now. It will connect to the backend later.',
              style: TextStyle(color: AppColors.grey)),
          const SizedBox(height: 20),
          SizedBox(
            height: 310,
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _Card(
                    title: 'Audit Overview',
                    icon: Icons.bar_chart,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 170,
                          height: 170,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(170, 170),
                                painter: _DonutPainter(
                                    [_completed, _pending, _critical]
                                        .map((e) => e.toDouble())
                                        .toList(),
                                    const [_green, _orange, AppColors.red]),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('$percent%',
                                      style: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.navy)),
                                  const Text('Compliance',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            _LegendRow(_green, 'Completed', '$_completed'),
                            _LegendRow(_orange, 'Pending', '$_pending'),
                            _LegendRow(AppColors.red, 'Critical', '$_critical'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: _Card(
                    title: 'Monthly Audit Trend',
                    icon: Icons.trending_up,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Last 6 Months', style: TextStyle(fontSize: 12)),
                          Icon(Icons.keyboard_arrow_down, size: 18),
                        ],
                      ),
                    ),
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _LinePainter(_trend, _months, 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 310,
            child: Row(
              children: [
                Expanded(
                  child: _Card(
                    title: 'Fire Safety Incidents',
                    icon: Icons.local_fire_department,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _BarPainter(_incidentValues, _incidentLabels,
                          _incidentColors, 4),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _Card(
                    title: 'Risk Distribution',
                    icon: Icons.shield,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 190,
                          height: 190,
                          child: CustomPaint(
                            size: const Size(190, 190),
                            painter: _PiePainter(_riskValues,
                                const [AppColors.red, _orange, _green]),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            _LegendRow(AppColors.red, 'High Risk', ''),
                            _LegendRow(_orange, 'Medium Risk', ''),
                            _LegendRow(_green, 'Low Risk', ''),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- widgets

class _Card extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final Widget child;
  const _Card(
      {required this.title,
        required this.icon,
        required this.child,
        this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.red, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy)),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label, value;
  const _LegendRow(this.color, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: 150,
        child: Row(
          children: [
            CircleAvatar(radius: 6, backgroundColor: color),
            const SizedBox(width: 10),
            Expanded(child: Text(label)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- painters

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  _DonutPainter(this.values, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 34.0;
    final rect = Rect.fromLTWH(
        stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final total = values.fold<double>(0, (a, b) => a + b);
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * math.pi;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => false;
}

class _LinePainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final double maxY;
  _LinePainter(this.values, this.labels, this.maxY);

  @override
  void paint(Canvas canvas, Size size) {
    const l = 30.0, r = 12.0, t = 24.0, b = 28.0;
    final w = size.width - l - r;
    final h = size.height - t - b;
    final grid = Paint()
      ..color = AppColors.border.withOpacity(0.5)
      ..strokeWidth = 1;

    for (var v = 0; v <= maxY; v += 2) {
      final y = t + h * (1 - v / maxY);
      canvas.drawLine(Offset(l, y), Offset(l + w, y), grid);
      _paintText(canvas, '$v', Offset(l - 14, y), size: 12);
    }

    final pts = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = l + w * (i + 0.5) / values.length;
      final y = t + h * (1 - values[i] / maxY);
      pts.add(Offset(x, y));
    }

    // area under the line
    final area = Path()..moveTo(pts.first.dx, t + h);
    for (final p in pts) {
      area.lineTo(p.dx, p.dy);
    }
    area
      ..lineTo(pts.last.dx, t + h)
      ..close();
    canvas.drawPath(area, Paint()..color = AppColors.red.withOpacity(0.15));

    // line
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );

    // dots, values, month labels
    for (var i = 0; i < pts.length; i++) {
      canvas.drawCircle(pts[i], 5, Paint()..color = AppColors.red);
      _paintText(canvas, values[i].toInt().toString(),
          pts[i] - const Offset(0, 16),
          weight: FontWeight.w600);
      _paintText(canvas, labels[i], Offset(pts[i].dx, t + h + 16));
    }
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) => false;
}

class _BarPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final List<Color> colors;
  final double maxY;
  _BarPainter(this.values, this.labels, this.colors, this.maxY);

  @override
  void paint(Canvas canvas, Size size) {
    const l = 28.0, r = 8.0, t = 24.0, b = 28.0;
    final w = size.width - l - r;
    final h = size.height - t - b;
    final grid = Paint()
      ..color = AppColors.border.withOpacity(0.5)
      ..strokeWidth = 1;

    for (var v = 0; v <= maxY; v++) {
      final y = t + h * (1 - v / maxY);
      canvas.drawLine(Offset(l, y), Offset(l + w, y), grid);
      _paintText(canvas, '$v', Offset(l - 12, y));
    }

    final slot = w / values.length;
    final barW = slot * 0.5;
    for (var i = 0; i < values.length; i++) {
      final cx = l + slot * (i + 0.5);
      final barH = h * values[i] / maxY;
      final rect = Rect.fromLTWH(cx - barW / 2, t + h - barH, barW, barH);
      canvas.drawRRect(
        RRect.fromRectAndCorners(rect,
            topLeft: const Radius.circular(6),
            topRight: const Radius.circular(6)),
        Paint()..color = colors[i],
      );
      _paintText(canvas, values[i].toInt().toString(),
          Offset(cx, rect.top - 12),
          weight: FontWeight.w600);
      _paintText(canvas, labels[i], Offset(cx, t + h + 16));
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) => false;
}

class _PiePainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  _PiePainter(this.values, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final total = values.fold<double>(0, (a, b) => a + b);
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * math.pi;
      canvas.drawArc(rect, start, sweep, true, Paint()..color = colors[i]);
      final mid = start + sweep / 2;
      final pos = center +
          Offset(math.cos(mid), math.sin(mid)) * (radius * 0.6);
      _paintText(canvas, '${values[i].toInt()}%', pos,
          size: 16, color: Colors.white, weight: FontWeight.w700);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter old) => false;
}