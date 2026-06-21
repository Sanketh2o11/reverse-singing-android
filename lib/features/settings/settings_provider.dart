import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;
  late int _recordingDuration;

  int get recordingDuration => _recordingDuration;

  SettingsProvider({required StorageService storage}) : _storage = storage {
    _recordingDuration = storage.getSetting<int>(
          'recordingDuration',
          defaultValue: AppConstants.defaultRecordingSeconds,
        ) ??
        AppConstants.defaultRecordingSeconds;
  }

  Future<void> setRecordingDuration(int seconds) async {
    if (!AppConstants.durationOptions.contains(seconds)) return;
    _recordingDuration = seconds;
    await _storage.saveSetting('recordingDuration', seconds);
    notifyListeners();
  }
}
