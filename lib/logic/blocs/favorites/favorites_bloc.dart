import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pet_adoption_app/data/models/favorite_model.dart';
import '../../../data/models/pet_model.dart';
import '../../../data/repositories/pet_repository.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final PetRepository _repository;

  FavoritesBloc({required PetRepository repository})
      : _repository = repository,
        super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
  }

  Future<void> _onLoadFavorites(LoadFavorites event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    try {
      final favorites = await _repository.getFavorites();
      emit(FavoritesLoaded(favorites: favorites));
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    if (state is! FavoritesLoaded) return;
    
    try {
      await _repository.toggleFavorite(event.pet);
      final favorites = await _repository.getFavorites();
      emit(FavoritesLoaded(favorites: favorites));
    } catch (e) {
      final currentState = state as FavoritesLoaded;
      emit(FavoritesLoaded(
        favorites: currentState.favorites,
        error: 'Failed to remove from favorites',
      ));
    }
  }
}