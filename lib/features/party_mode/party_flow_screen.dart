import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/color_palette.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/haptic_utils.dart';
import '../../shared/controllers/game_session_controller.dart';
import '../../shared/models/challenge_model.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/widgets/gradient_button.dart';

class PartyFlowScreen extends StatelessWidget {
  const PartyFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameSessionController>();

    if (!controller.isPartyMode) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              gradient: ColorPalette.backgroundGradient),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('No active party', style: AppTextStyles.body),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Text(
                      'Go Home',
                      style: AppTextStyles.smallBody
                          .copyWith(color: ColorPalette.cyan),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final allRoundsComplete =
        controller.partyRound >= controller.partyTotalRounds;

    return allRoundsComplete
        ? _PartySummaryScreen(controller: controller)
        : _RoundIntroScreen(controller: controller);
  }
}

class _RoundIntroScreen extends StatelessWidget {
  final GameSessionController controller;

  const _RoundIntroScreen({required this.controller});

  @override
  Widget build(BuildContext context) {
    final round = controller.partyRound + 1;
    final total = controller.partyTotalRounds;
    final challenger = controller.currentPartyChallenger;
    final imitator = controller.currentPartyImitator;

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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        controller.endPartyMode();
                        context.go('/home');
                      },
                      child: const Icon(Icons.close_rounded,
                          color: ColorPalette.textDim),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0x10FFFFFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Round $round of $total',
                        style: AppTextStyles.timerPill.copyWith(
                            fontSize: 13, color: ColorPalette.textDim),
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 2),
                ShaderMask(
                  shaderCallback: (b) => ColorPalette.gradientA.createShader(b),
                  child: Text(
                    'Round $round',
                    style: AppTextStyles.screenTitle.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Here's who's up",
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 28),
                _PlayerCard(
                  label: 'RECORDS',
                  name: challenger,
                  color: ColorPalette.purple,
                ),
                const SizedBox(height: 12),
                _PlayerCard(
                  label: 'IMITATES',
                  name: imitator,
                  color: ColorPalette.pink,
                ),
                const Spacer(flex: 3),
                GradientButton(
                  label: 'Begin Recording',
                  onPressed: () async {
                    HapticUtils.medium();
                    await controller.startNewChallenge();
                    if (context.mounted) context.push('/record/original');
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final String label;
  final String name;
  final Color color;

  const _PlayerCard(
      {required this.label, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: ColorPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorPalette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.label
                    .copyWith(color: color, letterSpacing: 1.0),
              ),
              const SizedBox(height: 4),
              Text(name, style: AppTextStyles.cardHeader),
            ],
          ),
        ],
      ),
    );
  }
}

class _PartySummaryScreen extends StatelessWidget {
  final GameSessionController controller;

  const _PartySummaryScreen({required this.controller});

  @override
  Widget build(BuildContext context) {
    final ids = controller.partyCompletedChallengeIds;

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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Party Summary',
                        style: AppTextStyles.screenTitle),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x10FFFFFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${ids.length} rounds',
                        style: AppTextStyles.smallBody,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ids.isEmpty
                    ? Center(
                        child:
                            Text('No rounds played', style: AppTextStyles.body))
                    : _RoundList(ids: ids),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: GradientButton(
                  label: 'Done',
                  onPressed: () {
                    controller.endPartyMode();
                    context.go('/home');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundList extends StatefulWidget {
  final List<String> ids;

  const _RoundList({required this.ids});

  @override
  State<_RoundList> createState() => _RoundListState();
}

class _RoundListState extends State<_RoundList> {
  List<ChallengeModel?> _challenges = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final storage = context.read<StorageService>();
    final results = await Future.wait(
        widget.ids.map((id) => storage.loadChallenge(id)));
    if (mounted) {
      setState(() {
        _challenges = results;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: ColorPalette.purple),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _challenges.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final c = _challenges[i];
        if (c == null) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () {
            HapticUtils.light();
            context.push('/history/${c.id}');
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: ColorPalette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorPalette.border),
            ),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (b) =>
                      ColorPalette.gradientA.createShader(b),
                  child: Text(
                    'Round ${i + 1}',
                    style: AppTextStyles.timerPill
                        .copyWith(fontSize: 13, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    c.sessionName.isEmpty ? 'Untitled' : c.sessionName,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.play_circle_outline_rounded,
                  color: ColorPalette.cyan,
                  size: 28,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
