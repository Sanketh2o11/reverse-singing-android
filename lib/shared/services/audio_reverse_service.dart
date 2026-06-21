import 'dart:io';
import 'dart:typed_data';
import '../../core/constants/app_constants.dart';

class AudioReverseService {
  Future<void> reverseWav(String inputPath, String outputPath) async {
    final bytes = await File(inputPath).readAsBytes();
    _validateWavHeader(bytes);

    final bd = bytes.buffer.asByteData();
    final numChannels = bd.getUint16(22, Endian.little);
    final bitsPerSample = bd.getUint16(34, Endian.little);
    final dataChunkSize = bd.getUint32(40, Endian.little);

    if (bitsPerSample != 16) {
      throw UnsupportedError(
          'Only 16-bit PCM WAV is supported, got $bitsPerSample-bit');
    }

    const headerSize = AppConstants.wavHeaderBytes;
    final pcmEnd = headerSize + dataChunkSize;
    final pcmBytes = bytes.sublist(
        headerSize, pcmEnd.clamp(headerSize, bytes.length));

    final bytesPerFrame = numChannels * 2;
    final frameCount = pcmBytes.length ~/ bytesPerFrame;
    final reversed = Uint8List(pcmBytes.length);

    for (int i = 0; i < frameCount; i++) {
      final srcOffset = (frameCount - 1 - i) * bytesPerFrame;
      final dstOffset = i * bytesPerFrame;
      for (int b = 0; b < bytesPerFrame; b++) {
        reversed[dstOffset + b] = pcmBytes[srcOffset + b];
      }
    }

    final builder = BytesBuilder();
    builder.add(bytes.sublist(0, headerSize));
    builder.add(reversed);

    await File(outputPath).writeAsBytes(builder.toBytes());
  }

  void _validateWavHeader(Uint8List bytes) {
    if (bytes.length < AppConstants.wavHeaderBytes) {
      throw const FormatException('File too small to be a valid WAV');
    }
    final riff = String.fromCharCodes(bytes.sublist(0, 4));
    final wave = String.fromCharCodes(bytes.sublist(8, 12));
    if (riff != 'RIFF' || wave != 'WAVE') {
      throw const FormatException('Not a valid WAV file');
    }
    final audioFormat =
        bytes.buffer.asByteData().getUint16(20, Endian.little);
    if (audioFormat != 1) {
      throw UnsupportedError(
          'Only PCM WAV (audioFormat=1) supported, got $audioFormat');
    }
  }
}
