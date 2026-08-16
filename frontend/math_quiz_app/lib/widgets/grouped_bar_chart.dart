import 'package:flutter/material.dart';

class GroupedBarChart extends StatelessWidget {
  final List<String> categories;
  final List<String> periods;
  final List<List<int>> values; // values[categoryIndex][periodIndex]
  final String? unitLabel;
  final double height;

  const GroupedBarChart({
    super.key,
    required this.categories,
    required this.periods,
    required this.values,
    this.unitLabel,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = [scheme.primary, scheme.secondary, scheme.tertiary];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, height);
              final bars = _computeBarRects(size, values);
              return Stack(
                children: [
                  CustomPaint(
                    size: size,
                    painter: _BarChartPainter(bars: bars, colors: colors, axisColor: scheme.outlineVariant),
                  ),
                  for (final bar in bars)
                    Positioned.fromRect(
                      rect: bar.rect,
                      child: Tooltip(
                        message: _tooltipText(bar),
                        child: const MouseRegion(
                          cursor: SystemMouseCursors.basic,
                          child: SizedBox.expand(),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final p in periods)
              Expanded(
                child: Text(p, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < categories.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(categories[i], style: TextStyle(fontSize: 12, color: scheme.onSurface)),
                ],
              ),
          ],
        ),
      ],
    );
  }

  String _tooltipText(_BarRect bar) {
    final category = categories[bar.categoryIndex];
    final period = periods[bar.periodIndex];
    final unit = unitLabel;
    return unit == null ? '$category, $period: ${bar.value}' : '$category, $period: ${bar.value} $unit';
  }
}

/// A single bar's data and its on-screen rectangle. Computed once and shared
/// between the painter (draws it) and the hover tooltips (sit on top of it),
/// so the two can never drift out of alignment with each other.
class _BarRect {
  final int categoryIndex;
  final int periodIndex;
  final int value;
  final Rect rect;

  const _BarRect({required this.categoryIndex, required this.periodIndex, required this.value, required this.rect});
}

List<_BarRect> _computeBarRects(Size size, List<List<int>> values) {
  final categoryCount = values.length;
  final periodCount = categoryCount > 0 ? values[0].length : 0;
  if (categoryCount == 0 || periodCount == 0) return const [];

  var maxValue = 1;
  for (final row in values) {
    for (final v in row) {
      if (v > maxValue) maxValue = v;
    }
  }
  final chartMax = maxValue * 1.15;

  const leftPadding = 4.0;
  final chartHeight = size.height - 4;
  final chartWidth = size.width - leftPadding;

  final groupWidth = chartWidth / periodCount;
  final barGap = groupWidth * 0.08;
  final barWidth = (groupWidth - barGap * (categoryCount + 1)) / categoryCount;

  final bars = <_BarRect>[];
  for (var p = 0; p < periodCount; p++) {
    final groupLeft = leftPadding + p * groupWidth;
    for (var c = 0; c < categoryCount; c++) {
      final value = values[c][p];
      final barHeight = (value / chartMax) * chartHeight;
      final barLeft = groupLeft + barGap + c * (barWidth + barGap);
      final rect = Rect.fromLTWH(barLeft, chartHeight - barHeight, barWidth, barHeight);
      bars.add(_BarRect(categoryIndex: c, periodIndex: p, value: value, rect: rect));
    }
  }
  return bars;
}

class _BarChartPainter extends CustomPainter {
  final List<_BarRect> bars;
  final List<Color> colors;
  final Color axisColor;

  const _BarChartPainter({required this.bars, required this.colors, required this.axisColor});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(4, size.height - 4),
      Offset(size.width, size.height - 4),
      Paint()
        ..color = axisColor
        ..strokeWidth = 1,
    );

    for (final bar in bars) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(bar.rect, topLeft: const Radius.circular(3), topRight: const Radius.circular(3)),
        Paint()..color = colors[bar.categoryIndex % colors.length],
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => !identical(oldDelegate.bars, bars);
}
