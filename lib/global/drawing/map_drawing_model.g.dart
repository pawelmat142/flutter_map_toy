// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_drawing_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MapDrawingModelAdapter extends TypeAdapter<MapDrawingModel> {
  @override
  final int typeId = 2;

  @override
  MapDrawingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MapDrawingModel(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
      (fields[3] as List).cast<double>(),
      fields[4] as int,
      fields[5] as double,
      (fields[6] as List)
          .map((dynamic e) => (e as List)
              .map((dynamic e) => (e as List).cast<double>())
              .toList())
          .toList(),
    );
  }

  @override
  void write(BinaryWriter writer, MapDrawingModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.coordinates)
      ..writeByte(4)
      ..write(obj.colorInt)
      ..writeByte(5)
      ..write(obj.width)
      ..writeByte(6)
      ..write(obj.points);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapDrawingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
