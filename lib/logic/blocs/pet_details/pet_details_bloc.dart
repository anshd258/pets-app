import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/pet_model.dart';
import '../../../data/repositories/pet_repository.dart';

part 'pet_details_event.dart';
part 'pet_details_state.dart';

class PetDetailsBloc extends Bloc<PetDetailsEvent, PetDetailsState> {
  final PetRepository _repository;

  PetDetailsBloc({required PetRepository repository})
      : _repository = repository,
        super(PetDetailsInitial()) {
    on<LoadPetDetails>(_onLoadPetDetails);
    on<AdoptPet>(_onAdoptPet);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  void _onLoadPetDetails(LoadPetDetails event, Emitter<PetDetailsState> emit) {
    emit(PetDetailsLoaded(pet: event.pet));
  }

  Future<void> _onAdoptPet(AdoptPet event, Emitter<PetDetailsState> emit) async {
    if (state is! PetDetailsLoaded) return;
    
    final currentState = state as PetDetailsLoaded;
    final pet = currentState.pet;
    
    if (pet.isAdopted) {
      emit(currentState.copyWith(
        error: 'This pet has already been adopted!',
      ));
      return;
    }
    
    try {
      await _repository.adoptPet(pet);
      final updatedPet = pet.copyWith(
        isAdopted: true,
        adoptedAt: DateTime.now(),
      );
      
      emit(PetDetailsLoaded(
        pet: updatedPet,
        showConfetti: true,
        adoptionMessage: "You've now adopted ${pet.name}!",
      ));
    } catch (e) {
      emit(currentState.copyWith(
        error: 'Failed to adopt pet: ${e.toString()}',
      ));
    }
  }

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<PetDetailsState> emit) async {
    if (state is! PetDetailsLoaded) return;
    
    final currentState = state as PetDetailsLoaded;
    final pet = currentState.pet;
    
    try {
      await _repository.toggleFavorite(pet);
      final updatedPet = pet.copyWith(isFavorite: !pet.isFavorite);
      
      emit(PetDetailsLoaded(
        pet: updatedPet,
        showConfetti: currentState.showConfetti,
        adoptionMessage: currentState.adoptionMessage,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        error: 'Failed to update favorite: ${e.toString()}',
      ));
    }
  }
}