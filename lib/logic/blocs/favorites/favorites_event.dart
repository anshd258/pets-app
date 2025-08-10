part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class RemoveFromFavorites extends FavoritesEvent {
  final PetModel pet;

  const RemoveFromFavorites({required this.pet});

  @override
  List<Object> get props => [pet];
}