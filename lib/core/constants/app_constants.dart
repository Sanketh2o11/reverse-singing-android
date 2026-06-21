class AppConstants {
  static const int sampleRate = 22050;
  static const int numChannels = 1;
  static const int bytesPerSample = 2;
  static const int wavHeaderBytes = 44;
  static const int defaultRecordingSeconds = 10;
  static const List<int> durationOptions = [5, 10, 15];
  static const int maxSavedSessions = 50;
  static const int storageWarningThresholdMb = 100;
  static const String hiveBoxChallenges = 'reverse_sing_sessions';
  static const String hiveBoxSessions = 'sessions';
  static const String hiveBoxSettings = 'settings';
  static const String challengeDirPrefix = 'challenge_';
}
