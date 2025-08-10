// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetModelAdapter extends TypeAdapter<PetModel> {
  @override
  final int typeId = 0;

  @override
  PetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetModel(
      id: fields[0] as String,
      name: fields[1] as String,
      age: fields[2] as int,
      price: fields[3] as double,
      breed: fields[4] as String,
      description: fields[5] as String,
      imageUrl: fields[6] as String,
      isAdopted: fields[7] as bool,
      isFavorite: fields[8] as bool,
      adoptedAt: fields[9] as DateTime?,
      species: fields[10] as String,
      gender: fields[11] as String,
      size: fields[12] as String,
      status: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PetModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.breed)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.isAdopted)
      ..writeByte(8)
      ..write(obj.isFavorite)
      ..writeByte(9)
      ..write(obj.adoptedAt)
      ..writeByte(10)
      ..write(obj.species)
      ..writeByte(11)
      ..write(obj.gender)
      ..writeByte(12)
      ..write(obj.size)
      ..writeByte(13)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
