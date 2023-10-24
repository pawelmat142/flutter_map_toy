// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_icon_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MapIconModelAdapter extends TypeAdapter<MapIconModel> {
  @override
  final int typeId = 1;

  @override
  MapIconModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MapIconModel(
      fields[0] as int,
      fields[1] as int,
      fields[2] as double,
      fields[3] as String,
      (fields[4] as List).cast<double>(),
      fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MapIconModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.iconDataPoint)
      ..writeByte(1)
      ..write(obj.colorInt)
      ..writeByte(2)
      ..write(obj.size)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.coordinates)
      ..writeByte(5)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapIconModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
