// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeModelAdapter extends TypeAdapter<ChallengeModel> {
  @override
  final typeId = 0;

  @override
  ChallengeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChallengeModel(
      id: fields[0] as String,
      sessionName: fields[1] as String,
      createdAt: fields[2] as DateTime,
      originalWavPath: fields[3] as String,
      finalWavPath: fields[4] as String,
      originalWaveformPeaks: (fields[5] as List).cast<double>(),
      finalWaveformPeaks: (fields[6] as List).cast<double>(),
      originalDurationMs: (fields[7] as num).toInt(),
      finalDurationMs: (fields[8] as num).toInt(),
      challengerName: fields[9] as String?,
      imitatorName: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChallengeModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionName)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.originalWavPath)
      ..writeByte(4)
      ..write(obj.finalWavPath)
      ..writeByte(5)
      ..write(obj.originalWaveformPeaks)
      ..writeByte(6)
      ..write(obj.finalWaveformPeaks)
      ..writeByte(7)
      ..write(obj.originalDurationMs)
      ..writeByte(8)
      ..write(obj.finalDurationMs)
      ..writeByte(9)
      ..write(obj.challengerName)
      ..writeByte(10)
      ..write(obj.imitatorName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
