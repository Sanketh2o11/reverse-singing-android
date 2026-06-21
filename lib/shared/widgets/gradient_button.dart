import 'package:flutter/material.dart';
import '../../core/theme/color_palette.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/haptic_utils.dart';

class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final LinearGradient gradient;
  final double height;
  final double? width;
  final IconData? icon;
  final bool showGlow;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.gradient = ColorPalette.gradientA,
    this.height = 56,
    this.width,
    this.icon,
    this.showGlow = true,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) => _scaleController.reverse(),
        onTapCancel: () => _scaleController.reverse(),
        onTap: widget.onPressed == null
            ? null
            : () {
                HapticUtils.medium();
                widget.onPressed!();
              },
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.onPressed == null
                ? const LinearGradient(
                    colors: [Color(0xFF4A3570), Color(0xFF7A3060)],
                  )
                : widget.gradient,
            borderRadius: BorderRadius.circular(widget.height / 2),
            boxShadow: widget.showGlow && widget.onPressed != null
                ? [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: AppTextStyles.buttonText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OutlinedGradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double? width;

  const OutlinedGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 52,
    this.width,
  });

  @override
  State<OutlinedGradientButton> createState() =>
      _OutlinedGradientButtonState();
}

class _OutlinedGradientButtonState extends State<OutlinedGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: widget.onPressed == null
          ? null
          : () {
              HapticUtils.light();
              widget.onPressed!();
            },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: 1.0 - 0.03 * _ctrl.value,
          child: child,
        ),
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.height / 2),
            gradient: ColorPalette.gradientA,
          ),
          child: Container(
            margin: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              color: ColorPalette.background,
              borderRadius: BorderRadius.circular(widget.height / 2 - 1.5),
            ),
            alignment: Alignment.center,
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  ColorPalette.gradientA.createShader(bounds),
              child: Text(
                widget.label,
                style: AppTextStyles.buttonText.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
