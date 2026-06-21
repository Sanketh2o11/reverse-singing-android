import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../core/theme/color_palette.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/haptic_utils.dart';
import '../../shared/controllers/game_session_controller.dart';
import '../../shared/widgets/gradient_button.dart';

class PartySetupScreen extends StatefulWidget {
  const PartySetupScreen({super.key});

  @override
  State<PartySetupScreen> createState() => _PartySetupScreenState();
}

class _PartySetupScreenState extends State<PartySetupScreen> {
  int _playerCount = 3;
  final List<TextEditingController> _nameControllers =
      List.generate(6, (_) => TextEditingController());

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _getPlayerNames() {
    return List.generate(_playerCount, (i) {
      final name = _nameControllers[i].text.trim();
      return name.isEmpty ? 'Player ${i + 1}' : name;
    });
  }

  Future<void> _startParty() async {
    HapticUtils.medium();
    final names = _getPlayerNames();

    final status = await Permission.microphone.status;
    if (!mounted) return;

    context.read<GameSessionController>().startPartyMode(names);

    if (status.isGranted) {
      context.go('/party/flow');
    } else {
      final result = await Permission.microphone.request();
      if (!mounted) return;
      if (result.isGranted) {
        context.go('/party/flow');
      } else {
        context.push('/permission');
      }
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
                    Text('Party Mode', style: AppTextStyles.screenTitle),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'How many players?',
                      style: AppTextStyles.cardHeader,
                    ),
                    const SizedBox(height: 16),
                    _PlayerCountRow(
                      count: _playerCount,
                      onChanged: (c) => setState(() => _playerCount = c),
                    ),
                    const SizedBox(height: 32),
                    Text('Name them (optional)', style: AppTextStyles.body),
                    const SizedBox(height: 16),
                    ...List.generate(
                      _playerCount,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: _nameControllers[i],
                          style: AppTextStyles.bodyWhite,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            hintText: 'Player ${i + 1}',
                            prefixText: '${i + 1}   ',
                            prefixStyle: AppTextStyles.body,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    GradientButton(
                      label: "Let's Play",
                      onPressed: _startParty,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '$_playerCount rounds · pass the phone between turns',
                        style: AppTextStyles.smallMuted,
                      ),
                    ),
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

class _PlayerCountRow extends StatelessWidget {
  final int count;
  final ValueChanged<int> onChanged;

  const _PlayerCountRow({required this.count, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final n = i + 2;
        final isSelected = n == count;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticUtils.light();
              onChanged(n);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                gradient: isSelected ? ColorPalette.gradientA : null,
                color: isSelected ? null : ColorPalette.surface,
                borderRadius: BorderRadius.circular(24),
                border: isSelected
                    ? null
                    : Border.all(color: ColorPalette.border),
              ),
              alignment: Alignment.center,
              child: Text(
                '$n',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? Colors.white : ColorPalette.textDim,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
