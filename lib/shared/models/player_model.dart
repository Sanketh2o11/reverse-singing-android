import 'package:hive_ce/hive.dart';

part 'player_model.g.dart';

@HiveType(typeId: 2)
class PlayerModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? avatar;

  @HiveField(3)
  String? accentColor;

  @HiveField(4)
  int score;

  PlayerModel({
    required this.id,
    required this.name,
    this.avatar,
    this.accentColor,
    this.score = 0,
  });
}
