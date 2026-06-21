import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/color_palette.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/haptic_utils.dart';

class PassPhoneOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final String? nextPlayerName;

  const PassPhoneOverlay({
    super.key,
    required this.onComplete,
    this.nextPlayerName,
  });

  @override
  State<PassPhoneOverlay> createState() => _PassPhoneOverlayState();
}

class _PassPhoneOverlayState extends State<PassPhoneOverlay>
    with SingleTickerProviderStateMixin {
  int _count = 3;
  late AnimationController _numController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _numController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _numController, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _numController,
          curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
    );

    _startCountdown();
  }

  Future<void> _startCountdown() async {
    await _tick(3, HapticUtils.heavy);
    await _tick(2, HapticUtils.medium);
    await _tick(1, HapticUtils.light);
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) widget.onComplete();
  }

  Future<void> _tick(int count, Future<void> Function() haptic) async {
    setState(() => _count = count);
    _numController.forward(from: 0);
    await haptic();
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  void dispose() {
    _numController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        color: Colors.black.withOpacity(0.85),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _numController,
              builder: (_, __) => Opacity(
                opacity: _fadeAnim.value,
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        ColorPalette.gradientA.createShader(bounds),
                    child: Text(
                      '$_count',
                      style: AppTextStyles.countdown
                          .copyWith(color: Colors.white, fontSize: 120),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.nextPlayerName != null
                  ? 'Pass it to ${widget.nextPlayerName}'
                  : 'Pass the phone',
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Don't show the screen",
              style: AppTextStyles.smallBody,
            ),
          ],
        ),
      ),
    );
  }
}
