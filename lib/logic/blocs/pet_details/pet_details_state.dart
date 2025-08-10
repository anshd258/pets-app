part of 'pet_details_bloc.dart';

abstract class PetDetailsState extends Equatable {
  const PetDetailsState();

  @override
  List<Object?> get props => [];
}

class PetDetailsInitial extends PetDetailsState {}

class PetDetailsLoaded extends PetDetailsState {
  final PetModel pet;
  final bool showConfetti;
  final String? adoptionMessage;
  final String? error;

  const PetDetailsLoaded({
    required this.pet,
    this.showConfetti = false,
    this.adoptionMessage,
    this.error,
  });

  PetDetailsLoaded copyWith({
    PetModel? pet,
    bool? showConfetti,
    String? adoptionMessage,
    String? error,
  }) {
    return PetDetailsLoaded(
      pet: pet ?? this.pet,
      showConfetti: showConfetti ?? false,
      adoptionMessage: adoptionMessage,
      error: error,
    );
  }

  @override
  List<Object?> get props => [pet, showConfetti, adoptionMessage, error];
}