import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/utils/audio_utils.dart';
import '../../core/utils/file_utils.dart';
import '../models/challenge_model.dart';
import '../services/audio_reverse_service.dart';
import '../services/playback_service.dart';
import '../services/recorder_service.dart';
import '../services/storage_service.dart';

enum GameState {
  idle,
  requestingPermission,
  recordingOriginal,
  reversingOriginal,
  passPhone,
  playingReversed,
  recordingAttempt,
  reversingAttempt,
  revealing,
  saving,
  saved,
  error,
}

class GameSessionController extends ChangeNotifier
    with WidgetsBindingObserver {
  final RecorderService _recorder;
  final AudioReverseService _reverser;
  final PlaybackService _playback;
  final StorageService _storage;

  GameState _state = GameState.idle;
  String? _currentChallengeId;
  String? _challengeDir;
  int _originalDurationMs = 0;
  int _attemptDurationMs = 0;
  String? _lastError;

  // Party mode state
  List<String> _partyPlayerNames = [];
  int _partyRound = 0;
  List<String> _partyCompletedChallengeIds = [];

  GameState get state => _state;
  String? get currentChallengeId => _currentChallengeId;
  String? get challengeDir => _challengeDir;
  int get originalDurationMs => _originalDurationMs;
  int get attemptDurationMs => _attemptDurationMs;
  String? get lastError => _lastError;

  bool get isPartyMode => _partyPlayerNames.isNotEmpty;
  int get partyRound => _partyRound;
  int get partyTotalRounds => _partyPlayerNames.length;
  bool get hasMorePartyRounds =>
      isPartyMode && _partyRound < _partyPlayerNames.length - 1;
  List<String> get partyCompletedChallengeIds =>
      List.unmodifiable(_partyCompletedChallengeIds);

  String get currentPartyChallenger => _partyPlayerNames.isEmpty
      ? ''
      : _partyPlayerNames[_partyRound % _partyPlayerNames.length];

  String get currentPartyImitator => _partyPlayerNames.isEmpty
      ? ''
      : _partyPlayerNames[(_partyRound + 1) % _partyPlayerNames.length];

  String get originalPath => '$_challengeDir/original.wav';
  String get reversedOriginalPath => '$_challengeDir/reversed_original.wav';
  String get attemptPath => '$_challengeDir/attempt.wav';
  String get finalPath => '$_challengeDir/final.wav';

  GameSessionController({
    required RecorderService recorder,
    required AudioReverseService reverser,
    required PlaybackService playback,
    required StorageService storage,
  })  : _recorder = recorder,
        _reverser = reverser,
        _playback = playback,
        _storage = storage {
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> startNewChallenge() async {
    _currentChallengeId = FileUtils.generateUuid();
    _challengeDir =
        await _storage.getChallengeDirectory(_currentChallengeId!);
    _originalDurationMs = 0;
    _attemptDurationMs = 0;
    _lastError = null;
    _setState(GameState.idle);
  }

  Future<void> startRecordingOriginal() async {
    _setState(GameState.recordingOriginal);
    try {
      await _recorder.startRecording(originalPath);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> stopRecordingOriginal() async {
    try {
      _originalDurationMs = await _recorder.stopRecording();
      _setState(GameState.reversingOriginal);
      await _reverser.reverseWav(originalPath, reversedOriginalPath);
      _setState(GameState.passPhone);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> confirmPassPhone() async {
    _setState(GameState.playingReversed);
    try {
      await _playback.loadFile(reversedOriginalPath);
      await _playback.play();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> startRecordingAttempt() async {
    await _playback.stop();
    _setState(GameState.recordingAttempt);
    try {
      await _recorder.startRecording(attemptPath);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> stopRecordingAttempt() async {
    try {
      _attemptDurationMs = await _recorder.stopRecording();
      _setState(GameState.reversingAttempt);
      await _reverser.reverseWav(attemptPath, finalPath);
      await _storage.deleteIntermediateFiles(_challengeDir!);
      _setState(GameState.revealing);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<ChallengeModel> buildChallengeModel({
    required String sessionName,
    String? challengerName,
    String? imitatorName,
  }) async {
    final originalPeaks =
        await AudioUtils.extractAmplitudeEnvelope(originalPath);
    final finalPeaks = await AudioUtils.extractAmplitudeEnvelope(finalPath);

    return ChallengeModel(
      id: _currentChallengeId!,
      sessionName: sessionName,
      createdAt: DateTime.now(),
      originalWavPath: originalPath,
      finalWavPath: finalPath,
      originalWaveformPeaks: originalPeaks,
      finalWaveformPeaks: finalPeaks,
      originalDurationMs: _originalDurationMs,
      finalDurationMs: _attemptDurationMs,
      challengerName: challengerName,
      imitatorName: imitatorName,
    );
  }

  Future<void> saveChallenge(ChallengeModel model) async {
    _setState(GameState.saving);
    await _storage.saveChallenge(model);
    _setState(GameState.saved);
  }

  Future<void> discardChallenge() async {
    if (_currentChallengeId != null) {
      await _storage.deleteChallenge(_currentChallengeId!);
    }
    reset();
  }

  void reset() {
    _currentChallengeId = null;
    _challengeDir = null;
    _originalDurationMs = 0;
    _attemptDurationMs = 0;
    _lastError = null;
    _setState(GameState.idle);
  }

  // Party mode methods
  void startPartyMode(List<String> playerNames) {
    _partyPlayerNames = List.from(playerNames);
    _partyRound = 0;
    _partyCompletedChallengeIds = [];
    notifyListeners();
  }

  void advancePartyRound(String challengeId) {
    _partyCompletedChallengeIds.add(challengeId);
    _partyRound++;
    notifyListeners();
  }

  void endPartyMode() {
    _partyPlayerNames = [];
    _partyRound = 0;
    _partyCompletedChallengeIds = [];
    notifyListeners();
  }

  void _setState(GameState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _lastError = message;
    _state = GameState.error;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_state == GameState.recordingOriginal ||
          _state == GameState.recordingAttempt) {
        _recorder.stopRecording();
        reset();
      }
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
