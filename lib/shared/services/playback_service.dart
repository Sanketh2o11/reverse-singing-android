import 'dart:async';
import 'package:just_audio/just_audio.dart';

class PlaybackService {
  AudioPlayer? _player;

  Stream<Duration> get positionStream =>
      _player?.positionStream ?? const Stream.empty();

  Stream<Duration?> get durationStream =>
      _player?.durationStream ?? const Stream.empty();

  Stream<PlayerState> get playerStateStream =>
      _player?.playerStateStream ?? const Stream.empty();

  bool get isPlaying => _player?.playing ?? false;

  Future<void> loadFile(String filePath) async {
    await _player?.dispose();
    _player = AudioPlayer();
    await _player!.setFilePath(filePath);
  }

  Future<void> play() async => _player?.play();
  Future<void> pause() async => _player?.pause();
  Future<void> stop() async => _player?.stop();
  Future<void> seek(Duration position) async => _player?.seek(position);

  Future<Duration?> get duration async => _player?.duration;

  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
  }
}
