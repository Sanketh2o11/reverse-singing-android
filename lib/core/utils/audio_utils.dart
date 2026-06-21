import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import '../constants/app_constants.dart';

class AudioUtils {
  static Future<List<double>> extractAmplitudeEnvelope(
    String wavPath, {
    int samplesPerSecond = 10,
  }) async {
    final file = File(wavPath);
    if (!await file.exists()) return [];

    final bytes = await file.readAsBytes();
    if (bytes.length < AppConstants.wavHeaderBytes) return [];

    final bd = bytes.buffer.asByteData();
    final sampleRate = bd.getUint32(24, Endian.little);
    final numChannels = bd.getUint16(22, Endian.little);
    final dataChunkSize = bd.getUint32(40, Endian.little);

    final windowSize = (sampleRate / samplesPerSecond).round();
    final bytesPerFrame = numChannels * 2;
    final List<double> envelope = [];

    int offset = AppConstants.wavHeaderBytes;
    final end = AppConstants.wavHeaderBytes + dataChunkSize;

    while (offset + windowSize * bytesPerFrame <= end &&
        offset + windowSize * bytesPerFrame <= bytes.length) {
      double sumSq = 0;
      for (int i = 0; i < windowSize * numChannels; i++) {
        final sampleOffset = offset + i * 2;
        if (sampleOffset + 2 <= bytes.length) {
          final sample = bd.getInt16(sampleOffset, Endian.little);
          sumSq += sample * sample;
        }
      }
      final rms = sqrt(sumSq / (windowSize * numChannels));
      envelope.add((rms / 32768).clamp(0.0, 1.0));
      offset += windowSize * bytesPerFrame;
    }

    return envelope;
  }

  static int computeDurationMs(int fileBytes) {
    final audioBytes = fileBytes - AppConstants.wavHeaderBytes;
    if (audioBytes <= 0) return 0;
    return ((audioBytes /
                (AppConstants.sampleRate *
                    AppConstants.numChannels *
                    AppConstants.bytesPerSample)) *
            1000)
        .round();
  }
}
