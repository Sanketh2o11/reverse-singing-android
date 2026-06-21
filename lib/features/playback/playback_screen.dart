import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../../core/theme/color_palette.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/haptic_utils.dart';
import '../../shared/controllers/game_session_controller.dart';
import '../../shared/services/playback_service.dart';
import '../../shared/widgets/waveform_widget.dart';

class PlaybackScreen extends StatefulWidget {
  const PlaybackScreen({super.key});

  @override
  State<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  bool _isPlaying = false;
  bool _hasPlayedOnce = false;
  bool _isLoaded = false;
  double _progress = 0.0;
  List<double> _peaks = [];
  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadAndPlay();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    context.read<PlaybackService>().stop();
    super.dispose();
  }

  Future<void> _loadAndPlay() async {
    final controller = context.read<GameSessionController>();
    final playback = context.read<PlaybackService>();

    await playback.loadFile(controller.reversedOriginalPath);

    _positionSub = playback.positionStream.listen((pos) {
      if (_duration.inMilliseconds > 0) {
        setState(() {
          _progress = (pos.inMilliseconds / _duration.inMilliseconds)
              .clamp(0.0, 1.0);
        });
      }
    });

    _stateSub = playback.playerStateStream.listen((state) {
      setState(() => _isPlaying = state.playing);
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
          _hasPlayedOnce = true;
          _progress = 0.0;
        });
      }
    });

    final dur = await playback.duration;
    _duration = dur ?? Duration.zero;

    setState(() => _isLoaded = true);
    await playback.play();
    setState(() => _isPlaying = true);
  }

  Future<void> _togglePlay() async {
    final playback = context.read<PlaybackService>();
    if (_isPlaying) {
      await playback.pause();
    } else {
      await playback.play();
    }
    HapticUtils.light();
  }

  Future<void> _skip(Duration delta) async {
    final playback = context.read<PlaybackService>();
    final currentPos = _duration * _progress;
    final newPos = currentPos + delta;
    await playback.seek(newPos.isNegative ? Duration.zero : newPos);
    HapticUtils.light();
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
                const SizedBox(height: 24),
                Text(
                  'Listen carefully...',
                  style: AppTextStyles.screenTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  'This is what you sound like backwards.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 80,
                  child: WaveformWidget.playback(
                    peaks: _peaks.isEmpty
                        ? List.generate(32, (i) => 0.1 + (i % 5) * 0.08)
                        : _peaks,
                    progress: _progress,
                    height: 80,
                  ),
                ),
                const SizedBox(height: 48),
                _buildControls(),
                const Spacer(),
                AnimatedOpacity(
                  opacity: _hasPlayedOnce ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ready to try?',
                        style: AppTextStyles.body,
                      ),
                      GestureDetector(
                        onTap: _hasPlayedOnce
                            ? () {
                                HapticUtils.medium();
                                context.go('/record/attempt');
                              }
                            : null,
                        child: ShaderMask(
                          shaderCallback: (b) =>
                              ColorPalette.gradientA.createShader(b),
                          child: Text(
                            'Start Recording →',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _skipButton(Icons.replay_5_rounded, () => _skip(const Duration(seconds: -5))),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: _isLoaded ? _togglePlay : null,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: ColorPalette.gradientB,
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(width: 24),
        _skipButton(Icons.forward_5_rounded, () => _skip(const Duration(seconds: 5))),
      ],
    );
  }

  Widget _skipButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: ColorPalette.textDim, size: 36),
    );
  }
}
