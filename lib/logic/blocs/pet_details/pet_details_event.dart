part of 'pet_details_bloc.dart';

abstract class PetDetailsEvent extends Equatable {
  const PetDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadPetDetails extends PetDetailsEvent {
  final PetModel pet;

  const LoadPetDetails({required this.pet});

  @override
  List<Object> get props => [pet];
}

class AdoptPet extends PetDetailsEvent {}

class ToggleFavorite extends PetDetailsEvent {}