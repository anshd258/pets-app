import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'pet_model.dart';

part 'favorite_model.g.dart';

@HiveType(typeId: 1)
class FavoriteModel extends Equatable {
  @HiveField(0)
  final PetModel pet;

  @HiveField(1)
  final DateTime addedAt;

  const FavoriteModel({required this.pet, required this.addedAt});

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      pet: PetModel.fromJson(json['pet'] as Map<String, dynamic>),
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'pet': pet.toJson(),
    'added_at': addedAt.toIso8601String(),
  };

  FavoriteModel copyWith({PetModel? pet, DateTime? addedAt}) {
    return FavoriteModel(
      pet: pet ?? this.pet,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [pet, addedAt];
}
