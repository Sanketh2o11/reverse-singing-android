import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/color_palette.dart';
import '../../core/theme/text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/haptic_utils.dart';
import '../../shared/controllers/game_session_controller.dart';
import '../../shared/services/recorder_service.dart';
import '../settings/settings_provider.dart';
import '../../shared/widgets/waveform_widget.dart';
import '../../shared/widgets/pass_phone_overlay.dart';

class RecordingScreen extends StatefulWidget {
  final RecordingMode mode;

  const RecordingScreen({super.key, required this.mode});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _isDone = false;
  bool _isProcessing = false;
  bool _showPassPhone = false;
  int _elapsed = 0;
  Timer? _timer;
  int _maxSeconds = AppConstants.defaultRecordingSeconds;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    final controller = context.read<GameSessionController>();
    if (controller.state == GameState.idle &&
        widget.mode == RecordingMode.original) {
      _initSession();
    }

    _maxSeconds = context.read<SettingsProvider>().recordingDuration;
  }

  Future<void> _initSession() async {
    await context.read<GameSessionController>().startNewChallenge();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    final controller = context.read<GameSessionController>();
    if (_isRecording) {
      await _stopRecording(controller);
    } else {
      await _startRecording(controller);
    }
  }

  Future<void> _startRecording(GameSessionController controller) async {
    await HapticUtils.heavy();
    setState(() {
      _isRecording = true;
      _elapsed = 0;
    });
    _pulseController.repeat(reverse: true);

    if (widget.mode == RecordingMode.original) {
      await controller.startRecordingOriginal();
    } else {
      await controller.startRecordingAttempt();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _elapsed++);
      if (_elapsed >= _maxSeconds) _stopRecording(controller);
    });
  }

  Future<void> _stopRecording(GameSessionController controller) async {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.value = 0;

    await HapticUtils.heavy();

    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    if (widget.mode == RecordingMode.original) {
      await controller.stopRecordingOriginal();
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isDone = true;
          _showPassPhone = true;
        });
      }
    } else {
      await controller.stopRecordingAttempt();
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isDone = true;
        });
        context.go('/reveal');
      }
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(1, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final recorder = context.read<RecorderService>();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!_isRecording) {
          if (context.mounted) context.go('/home');
          return;
        }
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Discard recording?'),
            content: const Text('Your current recording will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Discard',
                  style: TextStyle(color: ColorPalette.error),
                ),
              ),
            ],
          ),
        );
        if (shouldLeave == true && context.mounted) {
          _timer?.cancel();
          final recorder = context.read<RecorderService>();
          await recorder.stopRecording();
          if (context.mounted) context.go('/home');
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
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
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildWaveform(recorder),
                      const SizedBox(height: 20),
                      _buildStatusText(),
                      const Spacer(),
                      _buildMicButton(),
                      const SizedBox(height: 12),
                      if (!_isRecording && !_isDone)
                        Center(
                          child: Text(
                            'Max ${_maxSeconds} seconds',
                            style: AppTextStyles.smallMuted,
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            if (_showPassPhone)
              PassPhoneOverlay(
                onComplete: () {
                  setState(() => _showPassPhone = false);
                  context.go('/playback/reversed');
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final remaining = _maxSeconds - _elapsed;
    final isWarning = _isRecording && remaining <= 5;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            if (!_isRecording) context.go('/home');
          },
          child: Icon(
            Icons.arrow_back_rounded,
            color: _isRecording ? ColorPalette.textMuted : ColorPalette.textDim,
          ),
        ),
        Text(
          widget.mode == RecordingMode.original ? 'Your Turn' : 'Their Turn',
          style: AppTextStyles.screenTitle,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0x15FFFFFF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _isRecording
                ? _formatTime(_elapsed)
                : '0:${_maxSeconds.toString().padLeft(2, '0')}',
            style: AppTextStyles.timerPill.copyWith(
              color: isWarning ? ColorPalette.warning : ColorPalette.textWhite,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaveform(RecorderService recorder) {
    return SizedBox(
      height: 80,
      child: _isRecording
          ? WaveformWidget.recording(
              amplitudeStream: recorder.amplitudeStream,
              height: 80,
            )
          : WaveformWidget.staticDisplay(
              peaks: List.generate(32, (i) => 0.03 + (i % 4) * 0.015),
              height: 80,
            ),
    );
  }

  Widget _buildStatusText() {
    String text;
    Color color;
    if (_isProcessing) {
      text = 'Processing...';
      color = ColorPalette.textDim;
    } else if (_isRecording) {
      text = 'Recording...';
      color = ColorPalette.textWhite;
    } else if (_isDone) {
      text = 'Got it.';
      color = ColorPalette.textWhite;
    } else {
      text = 'Tap the mic to start recording';
      color = ColorPalette.textDim;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        text,
        key: ValueKey(text),
        style: AppTextStyles.body.copyWith(color: color),
      ),
    );
  }

  Widget _buildMicButton() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, child) => Transform.scale(
          scale: _isRecording ? _pulseAnim.value : 1.0,
          child: child,
        ),
        child: GestureDetector(
          onTap: _isProcessing ? null : _toggleRecording,
          child: Container(
            width: 144,
            height: 144,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _isRecording ? ColorPalette.gradientA : null,
              color: _isRecording ? null : ColorPalette.surface,
              border: _isRecording
                  ? null
                  : Border.all(
                      color: ColorPalette.purple,
                      width: 3,
                    ),
              boxShadow: _isRecording
                  ? [
                      BoxShadow(
                        color: ColorPalette.pink.withOpacity(0.50),
                        blurRadius: 40,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              _isRecording
                  ? Icons.stop_rounded
                  : Icons.mic_rounded,
              color: Colors.white,
              size: _isRecording ? 48 : 56,
            ),
          ),
        ),
      ),
    );
  }
}
