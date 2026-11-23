import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Rounded bar chart. [progress] (0..1) animates the bars growing.
class BarChartPainter extends CustomPainter {
  BarChartPainter({
    required this.values,
    required this.barColor,
    required this.highlightColor,
    required this.trackColor,
    this.progress = 1,
  });

  final List<double> values;
  final Color barColor;
  final Color highlightColor;
  final Color trackColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxValue = values.reduce(math.max);
    final slot = size.width / values.length;
    final barWidth = slot * 0.5;
    final radius = Radius.circular(math.min(barWidth / 2, 10));

    for (var i = 0; i < values.length; i++) {
      final left = i * slot + (slot - barWidth) / 2;
      final track = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, 0, barWidth, size.height),
        radius,
      );
      canvas.drawRRect(track, Paint()..color = trackColor);

      final ratio = maxValue == 0 ? 0.0 : values[i] / maxValue;
      final height = math.max(6.0, ratio * size.height) * progress;
      final bar = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - height, barWidth, height),
        radius,
      );
      final isLast = i == values.length - 1;
      canvas.drawRRect(
        bar,
        Paint()..color = isLast ? highlightColor : barColor,
      );
    }
  }

  @override
  bool shouldRepaint(BarChartPainter old) =>
      old.progress != progress ||
      old.barColor != barColor ||
      old.values.length != values.length ||
      !_same(old.values, values);

  bool _same(List<double> a, List<double> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class DonutSlice {
  const DonutSlice(this.value, this.color);
  final double value;
  final Color color;
}

/// Donut chart with small gaps between slices.
class DonutPainter extends CustomPainter {
  DonutPainter({
    required this.slices,
    required this.trackColor,
    this.strokeWidth = 24,
    this.progress = 1,
  });

  final List<DonutSlice> slices;
  final Color trackColor;
  final double strokeWidth;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height) - strokeWidth;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: side,
      height: side,
    );
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, 0, math.pi * 2, false, base..color = trackColor);

    final total = slices.fold(0.0, (sum, s) => sum + s.value);
    if (total == 0) return;
    final gap = slices.length > 1 ? 0.04 : 0.0;
    var start = -math.pi / 2;
    for (final slice in slices) {
      final sweep = slice.value / total * math.pi * 2 * progress;
      if (sweep > gap) {
        canvas.drawArc(
          rect,
          start + gap / 2,
          sweep - gap,
          false,
          base..color = slice.color,
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(DonutPainter old) =>
      old.progress != progress || old.slices != slices;
}
