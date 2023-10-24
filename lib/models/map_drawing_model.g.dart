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
      fields[2] as Uint8List,
      fields[3] as String,
      (fields[4] as List).cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, MapDrawingModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.bitmap)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.coordinates);
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
