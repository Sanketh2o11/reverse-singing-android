import 'dart:io';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/file_utils.dart';
import '../models/challenge_model.dart';
import '../models/session_model.dart';

class StorageService {
  late Box<ChallengeModel> _challengeBox;
  late Box<SessionModel> _sessionBox;
  late Box<dynamic> _settingsBox;
  late String _appDocPath;

  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _appDocPath = appDir.path;

    _challengeBox =
        await Hive.openBox<ChallengeModel>(AppConstants.hiveBoxChallenges);
    _sessionBox =
        await Hive.openBox<SessionModel>(AppConstants.hiveBoxSessions);
    _settingsBox = await Hive.openBox(AppConstants.hiveBoxSettings);
  }

  Future<String> getChallengeDirectory(String challengeId) async {
    final dir = Directory(
        '$_appDocPath/${AppConstants.challengeDirPrefix}$challengeId');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }

  Future<void> saveChallenge(ChallengeModel challenge) async {
    await _challengeBox.put(challenge.id, challenge);
    await _enforceSessionLimit();
  }

  Future<List<ChallengeModel>> loadAllChallenges() async {
    final list = _challengeBox.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<ChallengeModel?> loadChallenge(String id) async =>
      _challengeBox.get(id);

  Future<void> deleteChallenge(String id) async {
    final challenge = _challengeBox.get(id);
    if (challenge == null) return;

    for (final path in [
      challenge.originalWavPath,
      challenge.finalWavPath,
    ]) {
      await FileUtils.deleteIfExists(path);
    }

    final dir = Directory(
        '$_appDocPath/${AppConstants.challengeDirPrefix}$id');
    if (await dir.exists()) await dir.delete(recursive: true);

    await _challengeBox.delete(id);
  }

  Future<void> deleteIntermediateFiles(String challengeDir) async {
    await FileUtils.deleteIfExists('$challengeDir/reversed_original.wav');
    await FileUtils.deleteIfExists('$challengeDir/attempt.wav');
  }

  Future<void> clearAllHistory() async {
    final challenges = await loadAllChallenges();
    for (final c in challenges) {
      await deleteChallenge(c.id);
    }
  }

  Future<void> cleanupIncompleteSessions() async {
    final appDir = Directory(_appDocPath);
    if (!await appDir.exists()) return;

    await for (final entity in appDir.list()) {
      if (entity is! Directory) continue;
      final dirName = entity.path.split('/').last;
      if (!dirName.startsWith(AppConstants.challengeDirPrefix)) continue;

      final id = dirName.replaceFirst(AppConstants.challengeDirPrefix, '');
      final isComplete = _challengeBox.containsKey(id);

      if (!isComplete) {
        await entity.delete(recursive: true);
      } else {
        await FileUtils.deleteIfExists(
            '${entity.path}/reversed_original.wav');
        await FileUtils.deleteIfExists('${entity.path}/attempt.wav');
      }
    }
  }

  Future<void> _enforceSessionLimit() async {
    final challenges = await loadAllChallenges();
    if (challenges.length <= AppConstants.maxSavedSessions) return;

    final toDelete = challenges.sublist(AppConstants.maxSavedSessions);
    for (final c in toDelete) {
      await deleteChallenge(c.id);
    }
  }

  Future<void> saveSession(SessionModel session) async {
    await _sessionBox.put(session.id, session);
  }

  Future<List<SessionModel>> loadAllSessions() async =>
      _sessionBox.values.toList();

  Future<void> saveSetting(String key, dynamic value) async =>
      _settingsBox.put(key, value);

  T? getSetting<T>(String key, {T? defaultValue}) =>
      _settingsBox.get(key, defaultValue: defaultValue) as T?;

  Future<void> close() async {
    await _challengeBox.close();
    await _sessionBox.close();
    await _settingsBox.close();
  }
}
