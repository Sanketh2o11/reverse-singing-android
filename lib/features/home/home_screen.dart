import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/color_palette.dart';
import '../../core/theme/text_styles.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/waveform_widget.dart';
import '../../core/utils/haptic_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _onCreateChallenge(BuildContext context) async {
    HapticUtils.medium();
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      if (context.mounted) context.push('/record/original');
    } else {
      if (context.mounted) context.push('/permission');
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                _buildBranding(),
                const Spacer(),
                _buildActions(context),
                const SizedBox(height: 12),
                _buildFooter(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranding() {
    final staticPeaks = List<double>.generate(
      20,
      (i) => 0.1 + 0.6 * (0.5 + 0.5 * _wave(i, 20)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              ColorPalette.gradientA.createShader(bounds),
          child: Text(
            'REVERSE SING',
            style: AppTextStyles.appTitle.copyWith(
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) =>
              ColorPalette.gradientA.createShader(bounds),
          child: Text(
            'CHALLENGE',
            style: AppTextStyles.appTitle.copyWith(
              color: Colors.white.withOpacity(0.7),
              fontSize: 28,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: WaveformWidget.staticDisplay(peaks: staticPeaks, height: 48),
        ),
        const SizedBox(height: 12),
        Text(
          'Record it. Reverse it. Cringe at it.',
          style: AppTextStyles.tagline,
        ),
      ],
    );
  }

  double _wave(int i, int total) {
    final x = i / total * 3.14159 * 2;
    return (0.5 * (1 + _sin(x)));
  }

  double _sin(double x) {
    x = x % (2 * 3.14159);
    double result = x;
    double term = x;
    for (int n = 1; n < 8; n++) {
      term *= -x * x / ((2 * n) * (2 * n + 1));
      result += term;
    }
    return result;
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        GradientButton(
          label: 'CREATE CHALLENGE',
          onPressed: () => _onCreateChallenge(context),
          showGlow: true,
        ),
        const SizedBox(height: 14),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            child: OutlinedGradientButton(
              label: 'Party Mode',
              onPressed: () {
                HapticUtils.light();
                context.push('/party/setup');
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _footerLink(
            context,
            icon: Icons.history_rounded,
            label: 'History',
            onTap: () => context.push('/history'),
          ),
          const SizedBox(width: 40),
          _footerLink(
            context,
            icon: Icons.settings_rounded,
            label: 'Settings',
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _footerLink(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticUtils.light();
        onTap();
      },
      child: Row(
        children: [
          Icon(icon, color: ColorPalette.textDim, size: 16),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.smallBody),
        ],
      ),
    );
  }
}
