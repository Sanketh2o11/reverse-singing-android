import 'package:hive_ce/hive.dart';

part 'session_model.g.dart';

@HiveType(typeId: 1)
class SessionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  String sessionName;

  @HiveField(3)
  List<String> challengeIds;

  @HiveField(4)
  List<String> playerNames;

  @HiveField(5)
  bool isPartyMode;

  SessionModel({
    required this.id,
    required this.createdAt,
    required this.sessionName,
    required this.challengeIds,
    required this.playerNames,
    required this.isPartyMode,
  });
}
