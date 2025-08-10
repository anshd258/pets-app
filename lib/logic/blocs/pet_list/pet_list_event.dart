part of 'pet_list_bloc.dart';

abstract class PetListEvent extends Equatable {
  const PetListEvent();

  @override
  List<Object?> get props => [];
}

class LoadPets extends PetListEvent {}

class RefreshPets extends PetListEvent {}

class LoadMorePets extends PetListEvent {}

class SearchPets extends PetListEvent {
  final String query;

  const SearchPets({required this.query});

  @override
  List<Object?> get props => [query];
}

class UpdatePetInList extends PetListEvent {
  final PetModel pet;

  const UpdatePetInList({required this.pet});

  @override
  List<Object?> get props => [pet];
}

class ConnectivityChanged extends PetListEvent {
  final bool isOnline;

  const ConnectivityChanged({required this.isOnline});

  @override
  List<Object?> get props => [isOnline];
}