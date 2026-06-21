import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/color_palette.dart';

enum WaveformMode { recording, playback, staticDisplay }

class WaveformWidget extends StatefulWidget {
  final Stream<double>? amplitudeStream;
  final List<double>? staticPeaks;
  final double? playbackProgress;
  final WaveformMode mode;
  final double height;

  const WaveformWidget.recording({
    super.key,
    required Stream<double> amplitudeStream,
    this.height = 80,
  })  : amplitudeStream = amplitudeStream,
        staticPeaks = null,
        playbackProgress = null,
        mode = WaveformMode.recording;

  const WaveformWidget.playback({
    super.key,
    required List<double> peaks,
    required double progress,
    this.height = 80,
  })  : amplitudeStream = null,
        staticPeaks = peaks,
        playbackProgress = progress,
        mode = WaveformMode.playback;

  const WaveformWidget.staticDisplay({
    super.key,
    required List<double> peaks,
    this.height = 60,
  })  : amplitudeStream = null,
        staticPeaks = peaks,
        playbackProgress = null,
        mode = WaveformMode.staticDisplay;

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget>
    with SingleTickerProviderStateMixin {
  static const int _barCount = 32;

  final List<double> _bars = List.filled(_barCount, 0.05);
  final List<double> _idleHeights = [];
  late AnimationController _idleController;
  StreamSubscription<double>? _ampSub;

  @override
  void initState() {
    super.initState();

    final rng = Random(42);
    for (int i = 0; i < _barCount; i++) {
      _idleHeights.add(0.15 + rng.nextDouble() * 0.25);
    }

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    if (widget.mode == WaveformMode.recording &&
        widget.amplitudeStream != null) {
      _ampSub = widget.amplitudeStream!.listen((amp) {
        if (!mounted) return;
        setState(() {
          _bars.removeAt(0);
          _bars.add(amp.clamp(0.02, 1.0));
        });
      });
    } else if (widget.mode == WaveformMode.staticDisplay ||
        widget.mode == WaveformMode.playback) {
      _loadStaticPeaks();
    }
  }

  void _loadStaticPeaks() {
    final peaks = widget.staticPeaks;
    if (peaks == null || peaks.isEmpty) return;
    setState(() {
      for (int i = 0; i < _barCount; i++) {
        final idx = (i / _barCount * peaks.length).round().clamp(0, peaks.length - 1);
        _bars[i] = peaks[idx].clamp(0.02, 1.0);
      }
    });
  }

  @override
  void didUpdateWidget(WaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode == WaveformMode.staticDisplay ||
        widget.mode == WaveformMode.playback) {
      _loadStaticPeaks();
    }
  }

  @override
  void dispose() {
    _ampSub?.cancel();
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _idleController,
        builder: (context, _) {
          return CustomPaint(
            size: Size(double.infinity, widget.height),
            painter: _WaveformPainter(
              bars: _bars,
              idleHeights: _idleHeights,
              idleBreath: _idleController.value,
              mode: widget.mode,
              progress: widget.playbackProgress ?? 0.0,
            ),
          );
        },
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> bars;
  final List<double> idleHeights;
  final double idleBreath;
  final WaveformMode mode;
  final double progress;

  _WaveformPainter({
    required this.bars,
    required this.idleHeights,
    required this.idleBreath,
    required this.mode,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 32;
    const gap = 3.0;
    final barWidth = (size.width - gap * (barCount - 1)) / barCount;

    final isIdle = mode == WaveformMode.recording &&
        bars.every((b) => b < 0.06);

    final activeGradient = const LinearGradient(
      colors: [ColorPalette.purple, ColorPalette.pink, ColorPalette.cyan],
      stops: [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final dimPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.fill;

    final activePaint = Paint()
      ..shader = activeGradient
      ..style = PaintingStyle.fill;

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + gap);

      double height;
      if (isIdle) {
        final base = idleHeights[i];
        final breathFactor = 1.0 + 0.30 * idleBreath;
        height = (base * size.height * breathFactor).clamp(4.0, size.height);
      } else {
        height = (bars[i] * size.height).clamp(3.0, size.height);
      }

      final top = (size.height - height) / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, top, barWidth, height),
        const Radius.circular(4),
      );

      final barProgress = i / barCount;
      if (mode == WaveformMode.playback && barProgress > progress) {
        canvas.drawRRect(rect, dimPaint);
      } else {
        canvas.drawRRect(rect, activePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      bars != old.bars ||
      idleBreath != old.idleBreath ||
      progress != old.progress;
}
