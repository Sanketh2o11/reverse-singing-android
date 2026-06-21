import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/color_palette.dart';
import '../../core/theme/text_styles.dart';
import '../../shared/widgets/gradient_button.dart';

class PermissionExplanationScreen extends StatefulWidget {
  const PermissionExplanationScreen({super.key});

  @override
  State<PermissionExplanationScreen> createState() =>
      _PermissionExplanationScreenState();
}

class _PermissionExplanationScreenState
    extends State<PermissionExplanationScreen>
    with SingleTickerProviderStateMixin {
  bool _denied = false;
  late AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    if (!mounted) return;
    if (status.isGranted) {
      context.go('/record/original');
    } else {
      setState(() => _denied = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: ColorPalette.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                _buildMicIllustration(),
                const Spacer(),
                if (!_denied) ...[
                  Text(
                    'Your mic stays yours',
                    style: AppTextStyles.screenTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We record audio locally.\nIt never leaves your phone, ever.',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  GradientButton(
                    label: 'Allow Access',
                    onPressed: _requestPermission,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Text(
                      'Maybe later',
                      style: AppTextStyles.smallBody,
                    ),
                  ),
                ] else ...[
                  Text(
                    'No mic, no game.',
                    style: AppTextStyles.screenTitle
                        .copyWith(color: ColorPalette.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Open your phone settings to allow microphone access.',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () => openAppSettings(),
                    child: Text(
                      'Open Settings',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: ColorPalette.cyan),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Text('Go back', style: AppTextStyles.smallBody),
                  ),
                ],
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMicIllustration() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...[60.0, 90.0, 120.0].asMap().entries.map((entry) {
            final delay = entry.key * 0.3;
            return AnimatedBuilder(
              animation: _ringController,
              builder: (_, __) {
                final progress =
                    ((_ringController.value + delay) % 1.0);
                return Opacity(
                  opacity: (1 - progress).clamp(0.0, 0.6),
                  child: Container(
                    width: entry.value * (0.7 + 0.3 * progress),
                    height: entry.value * (0.7 + 0.3 * progress),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _denied
                            ? ColorPalette.error
                            : ColorPalette.purple,
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          Icon(
            Icons.mic_rounded,
            size: 56,
            color: _denied ? ColorPalette.error : Colors.white,
          ),
        ],
      ),
    );
  }
}
