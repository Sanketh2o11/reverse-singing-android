import 'dart:async';
import 'dart:io';
import 'dart:math' show sqrt;
import 'package:record/record.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/audio_utils.dart';

class RecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Amplitude>? _ampSub;
  final StreamController<double> _ampController =
      StreamController<double>.broadcast();

  Stream<double> get amplitudeStream => _ampController.stream;

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<void> startRecording(String filePath) async {
    if (!await hasPermission()) {
      throw Exception('Microphone permission denied');
    }
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: AppConstants.sampleRate,
        numChannels: AppConstants.numChannels,
      ),
      path: filePath,
    );
    _ampSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 80))
        .listen((amp) {
      // sqrt curve: boosts quiet signals so bars visibly react to speech
      final linear = ((amp.current + 60) / 60).clamp(0.0, 1.0);
      final normalized = sqrt(linear);
      if (!_ampController.isClosed) _ampController.add(normalized);
    });
  }

  Future<int> stopRecording() async {
    await _ampSub?.cancel();
    _ampSub = null;
    if (!_ampController.isClosed) _ampController.add(0.0);

    final path = await _recorder.stop();
    if (path == null) return 0;

    final bytes = await File(path).length();
    return AudioUtils.computeDurationMs(bytes);
  }

  Future<bool> isRecording() => _recorder.isRecording();

  Future<void> dispose() async {
    await _ampSub?.cancel();
    await _ampController.close();
    _recorder.dispose();
  }
}
