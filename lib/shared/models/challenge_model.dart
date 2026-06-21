import 'package:hive_ce/hive.dart';

part 'challenge_model.g.dart';

@HiveType(typeId: 0)
class ChallengeModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String sessionName;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  String originalWavPath;

  @HiveField(4)
  String finalWavPath;

  @HiveField(5)
  List<double> originalWaveformPeaks;

  @HiveField(6)
  List<double> finalWaveformPeaks;

  @HiveField(7)
  int originalDurationMs;

  @HiveField(8)
  int finalDurationMs;

  @HiveField(9)
  String? challengerName;

  @HiveField(10)
  String? imitatorName;

  ChallengeModel({
    required this.id,
    required this.sessionName,
    required this.createdAt,
    required this.originalWavPath,
    required this.finalWavPath,
    required this.originalWaveformPeaks,
    required this.finalWaveformPeaks,
    required this.originalDurationMs,
    required this.finalDurationMs,
    this.challengerName,
    this.imitatorName,
  });
}
