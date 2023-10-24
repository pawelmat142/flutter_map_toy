// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MapModelAdapter extends TypeAdapter<MapModel> {
  @override
  final int typeId = 0;

  @override
  MapModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MapModel(
      fields[0] as String,
      fields[1] as String,
      (fields[2] as List).cast<MapIconModel>(),
      (fields[3] as List).cast<MapDrawingModel>(),
      (fields[4] as List).cast<double>(),
      fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MapModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.icons)
      ..writeByte(3)
      ..write(obj.drawings)
      ..writeByte(4)
      ..write(obj.mainCoordinates)
      ..writeByte(5)
      ..write(obj.modified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
