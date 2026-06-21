import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/color_palette.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/haptic_utils.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/widgets/gradient_button.dart';
import 'settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showClearConfirmSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(sheetContext).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clear all sessions?', style: AppTextStyles.cardHeader),
            const SizedBox(height: 8),
            Text(
              'This permanently deletes all recordings. No undo.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Yes, delete everything',
              gradient: const LinearGradient(
                colors: [Color(0xFFF43F5E), Color(0xFFEC4899)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              showGlow: false,
              onPressed: () async {
                Navigator.pop(sheetContext);
                await context.read<StorageService>().clearAllHistory();
                HapticUtils.success();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'All sessions cleared',
                        style: AppTextStyles.bodyWhite,
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(sheetContext),
                child: Text('Cancel', style: AppTextStyles.smallBody),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: ColorPalette.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: ColorPalette.textDim),
                    ),
                    const SizedBox(width: 16),
                    Text('Settings', style: AppTextStyles.screenTitle),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 8),
                    Text('RECORDING', style: AppTextStyles.label),
                    const SizedBox(height: 16),
                    Text(
                      'How long each person gets',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 12),
                    _DurationSelector(
                      selected: settings.recordingDuration,
                      onSelect: (s) =>
                          context.read<SettingsProvider>().setRecordingDuration(s),
                    ),
                    const SizedBox(height: 40),
                    const Divider(),
                    const SizedBox(height: 28),
                    Text('DATA', style: AppTextStyles.label),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _showClearConfirmSheet(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Clear all sessions',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: ColorPalette.error),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Removes recordings too',
                            style: AppTextStyles.smallMuted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Divider(),
                    const SizedBox(height: 28),
                    Text(
                      'Reverse Sing Challenge',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Made for chaotic friend groups',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 4),
                    Text('v1.0.0', style: AppTextStyles.smallMuted),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _DurationSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AppConstants.durationOptions.map((s) {
        final isSelected = s == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticUtils.light();
              onSelect(s);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 46,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: isSelected ? ColorPalette.gradientA : null,
                color: isSelected ? null : ColorPalette.surface,
                borderRadius: BorderRadius.circular(23),
                border: isSelected
                    ? null
                    : Border.all(color: ColorPalette.border),
              ),
              alignment: Alignment.center,
              child: Text(
                '${s}s',
                style: AppTextStyles.timerPill.copyWith(
                  color: isSelected ? Colors.white : ColorPalette.textDim,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
