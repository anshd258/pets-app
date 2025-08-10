import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'pet_model.dart';

part 'history_model.g.dart';

@HiveType(typeId: 2)
class HistoryModel extends Equatable {
  @HiveField(0)
  final PetModel pet;

  @HiveField(1)
  final DateTime addedAt;

  const HistoryModel({required this.pet, required this.addedAt});

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      pet: PetModel.fromJson(json['pet'] as Map<String, dynamic>),
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'pet': pet.toJson(),
    'added_at': addedAt.toIso8601String(),
  };

  HistoryModel copyWith({PetModel? pet, DateTime? addedAt}) {
    return HistoryModel(pet: pet ?? this.pet, addedAt: addedAt ?? this.addedAt);
  }

  @override
  List<Object?> get props => [pet, addedAt];
}
