import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/color_palette.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/haptic_utils.dart';
import '../../shared/models/challenge_model.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/widgets/glass_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ChallengeModel> _challenges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final storage = context.read<StorageService>();
    final list = await storage.loadAllChallenges();
    if (mounted) setState(() {
      _challenges = list;
      _isLoading = false;
    });
  }

  Future<void> _delete(ChallengeModel challenge) async {
    await context.read<StorageService>().deleteChallenge(challenge.id);
    setState(() => _challenges.remove(challenge));
    HapticUtils.medium();
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/home'),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: ColorPalette.textDim),
                    ),
                    Text('Sessions', style: AppTextStyles.screenTitle),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x10FFFFFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_challenges.length} saved',
                        style: AppTextStyles.smallBody,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: ColorPalette.purple))
                    : _challenges.isEmpty
                        ? _buildEmptyState()
                        : _buildList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 80, left: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎤', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 16),
          Text('Nothing saved yet', style: AppTextStyles.cardHeader),
          const SizedBox(height: 8),
          Text('Play a round and save it here', style: AppTextStyles.body),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => context.go('/home'),
            child: ShaderMask(
              shaderCallback: (b) => ColorPalette.gradientA.createShader(b),
              child: Text(
                'Start a challenge →',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _challenges.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final challenge = _challenges[index];
        return Dismissible(
          key: Key(challenge.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: ColorPalette.error.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline_rounded,
                color: ColorPalette.error),
          ),
          onDismissed: (_) => _delete(challenge),
          child: SolidCard(
            onTap: () {
              HapticUtils.light();
              context.push('/history/${challenge.id}');
            },
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.sessionName.isEmpty
                            ? 'Untitled session'
                            : challenge.sessionName,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(challenge.createdAt),
                        style: AppTextStyles.smallMuted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.play_circle_outline_rounded,
                  color: ColorPalette.cyan,
                  size: 30,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day} · ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
