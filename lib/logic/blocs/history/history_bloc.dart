import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pet_adoption_app/data/models/history_model.dart';
import '../../../data/models/pet_model.dart';
import '../../../data/repositories/pet_repository.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final PetRepository _repository;

  HistoryBloc({required PetRepository repository})
      : _repository = repository,
        super(HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
  }

  Future<void> _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    try {
      final history = await _repository.getAdoptionHistory();
      emit(HistoryLoaded(adoptedPets: history));
    } catch (e) {
      emit(HistoryError(message: e.toString()));
    }
  }
}