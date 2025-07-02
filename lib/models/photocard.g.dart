// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photocard.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhotocardAdapter extends TypeAdapter<Photocard> {
  @override
  final int typeId = 0;

  @override
  Photocard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Photocard(
      imagePath: fields[0] as String,
      title: fields[1] as String,
      number: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Photocard obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.imagePath)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.number);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotocardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
