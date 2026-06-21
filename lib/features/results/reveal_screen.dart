import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/theme/color_palette.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/haptic_utils.dart';
import '../../shared/controllers/game_session_controller.dart';
import '../../shared/models/challenge_model.dart';
import '../../shared/services/playback_service.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/waveform_widget.dart';

class RevealScreen extends StatefulWidget {
  final String? historyId;

  const RevealScreen({super.key, this.historyId});

  @override
  State<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends State<RevealScreen> {
  ChallengeModel? _challenge;
  bool _isLoaded = false;
  bool _playingOriginal = false;
  bool _playingFinal = false;
  bool _playingBoth = false;
  final PlaybackService _originalPlayback = PlaybackService();
  final PlaybackService _finalPlayback = PlaybackService();
  StreamSubscription? _origStateSub;
  StreamSubscription? _finalStateSub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.historyId != null) {
      final storage = context.read<StorageService>();
      _challenge = await storage.loadChallenge(widget.historyId!);
    } else {
      final controller = context.read<GameSessionController>();
      _challenge = ChallengeModel(
        id: controller.currentChallengeId ?? '',
        sessionName: '',
        createdAt: DateTime.now(),
        originalWavPath: controller.originalPath,
        finalWavPath: controller.finalPath,
        originalWaveformPeaks: [],
        finalWaveformPeaks: [],
        originalDurationMs: controller.originalDurationMs,
        finalDurationMs: controller.attemptDurationMs,
      );
    }

    if (_challenge != null) {
      await _originalPlayback.loadFile(_challenge!.originalWavPath);
      await _finalPlayback.loadFile(_challenge!.finalWavPath);

      _origStateSub =
          _originalPlayback.playerStateStream.listen((state) {
        setState(() => _playingOriginal = state.playing);
      });
      _finalStateSub =
          _finalPlayback.playerStateStream.listen((state) {
        setState(() => _playingFinal = state.playing);
      });
    }

    if (mounted) setState(() => _isLoaded = true);
  }

  @override
  void dispose() {
    _origStateSub?.cancel();
    _finalStateSub?.cancel();
    _originalPlayback.dispose();
    _finalPlayback.dispose();
    super.dispose();
  }

  Future<void> _playBoth() async {
    setState(() => _playingBoth = true);
    await _originalPlayback.play();
    await _originalPlayback.playerStateStream.firstWhere(
      (s) => s.processingState == ProcessingState.completed,
    );
    if (!mounted) return;
    await _finalPlayback.play();
    await _finalPlayback.playerStateStream.firstWhere(
      (s) => s.processingState == ProcessingState.completed,
    );
    if (mounted) setState(() => _playingBoth = false);
  }

  void _showSaveSheet() {
    final nameController = TextEditingController(
      text: _buildDefaultName(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name this session', style: AppTextStyles.cardHeader),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: true,
              style:
                  AppTextStyles.bodyWhite.copyWith(color: ColorPalette.textWhite),
              decoration: const InputDecoration(
                hintText: 'e.g. John vs Maria',
              ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Save',
              onPressed: () async {
                Navigator.pop(sheetContext);
                await _saveSession(nameController.text.trim().isEmpty
                    ? _buildDefaultName()
                    : nameController.text.trim());
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    context.go('/record/original');
                  },
                  child: Text('Play Again',
                      style: AppTextStyles.smallBody
                          .copyWith(color: ColorPalette.cyan)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    context.go('/home');
                  },
                  child: Text('Go Home', style: AppTextStyles.smallBody),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSession(String name) async {
    if (_challenge == null) return;
    final controller = context.read<GameSessionController>();
    final model = await controller.buildChallengeModel(sessionName: name);
    await controller.saveChallenge(model);
    HapticUtils.success();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved!', style: AppTextStyles.bodyWhite),
          backgroundColor: ColorPalette.success,
          duration: const Duration(seconds: 2),
        ),
      );
      context.go('/home');
    }
  }

  Future<void> _savePartyRound() async {
    if (_challenge == null) return;
    final controller = context.read<GameSessionController>();
    final roundName =
        'Round ${controller.partyRound + 1}: ${controller.currentPartyChallenger} vs ${controller.currentPartyImitator}';
    final model = await controller.buildChallengeModel(
      sessionName: roundName,
      challengerName: controller.currentPartyChallenger,
      imitatorName: controller.currentPartyImitator,
    );
    await controller.saveChallenge(model);
    HapticUtils.success();
    if (mounted) {
      controller.advancePartyRound(model.id);
      context.go('/party/flow');
    }
  }

  String _buildDefaultName() {
    final now = DateTime.now();
    return '${now.month}/${now.day} · ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
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
            child: _isLoaded ? _buildContent() : _buildLoading(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: ColorPalette.purple),
    );
  }

  Widget _buildContent() {
    if (_challenge == null) {
      return Center(
        child: Text('Session not found', style: AppTextStyles.body),
      );
    }

    final origPeaks = _challenge!.originalWaveformPeaks.isEmpty
        ? List.generate(32, (i) => 0.1 + (i % 7) * 0.04)
        : _challenge!.originalWaveformPeaks;
    final finalPeaks = _challenge!.finalWaveformPeaks.isEmpty
        ? List.generate(32, (i) => 0.15 + (i % 5) * 0.05)
        : _challenge!.finalWaveformPeaks;

    final controller = context.watch<GameSessionController>();
    final isPartyRound =
        controller.isPartyMode && widget.historyId == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Here we go.', style: AppTextStyles.screenTitle),
        const SizedBox(height: 28),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardLabel('ORIGINAL', ColorPalette.purple),
              const SizedBox(height: 12),
              WaveformWidget.staticDisplay(peaks: origPeaks, height: 50),
              const SizedBox(height: 12),
              _playButton(
                'Play Original',
                _playingOriginal,
                gradient: ColorPalette.gradientB,
                onTap: () async {
                  await _finalPlayback.stop();
                  _playingOriginal
                      ? await _originalPlayback.pause()
                      : await _originalPlayback.play();
                  HapticUtils.light();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardLabel('IMITATION', ColorPalette.pink),
              const SizedBox(height: 12),
              WaveformWidget.staticDisplay(peaks: finalPeaks, height: 50),
              const SizedBox(height: 12),
              _playButton(
                'Play Imitation',
                _playingFinal,
                gradient: ColorPalette.gradientA,
                onTap: () async {
                  await _originalPlayback.stop();
                  _playingFinal
                      ? await _finalPlayback.pause()
                      : await _finalPlayback.play();
                  HapticUtils.light();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GradientButton(
          label: _playingBoth ? 'Playing...' : '▶  Play Both',
          onPressed: _playingBoth ? null : _playBoth,
        ),
        const SizedBox(height: 16),
        if (isPartyRound) ...[
          GradientButton(
            label: controller.hasMorePartyRounds
                ? 'Next Round →'
                : 'Party Summary',
            gradient: ColorPalette.gradientB,
            showGlow: false,
            onPressed: _savePartyRound,
          ),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: () {
                controller.endPartyMode();
                context.go('/home');
              },
              child: Text('Leave party', style: AppTextStyles.smallMuted),
            ),
          ),
        ] else if (widget.historyId == null) ...[
          Center(
            child: GestureDetector(
              onTap: _showSaveSheet,
              child: Text(
                'Save session',
                style: AppTextStyles.smallBody
                    .copyWith(color: ColorPalette.textDim),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onTap: () {
                context.read<GameSessionController>().discardChallenge();
                context.go('/home');
              },
              child: Text('Discard', style: AppTextStyles.smallMuted),
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _cardLabel(String text, Color color) {
    return Text(
      text,
      style: AppTextStyles.label.copyWith(color: color, letterSpacing: 1.0),
    );
  }

  Widget _playButton(
    String label,
    bool isPlaying, {
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(label,
                style: AppTextStyles.smallBody.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
