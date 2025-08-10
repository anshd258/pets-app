import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/debouncer.dart';
import '../../../data/models/pet_model.dart';
import '../../../data/models/pet_response.dart';
import '../../../data/repositories/pet_repository.dart';

part 'pet_list_event.dart';
part 'pet_list_state.dart';

class PetListBloc extends Bloc<PetListEvent, PetListState> {
  final PetRepository _repository;
  final Debouncer _searchDebouncer = Debouncer(
    milliseconds: ApiConstants.searchDebounceMs,
  );
  
  List<PetModel> _allPets = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasReachedMax = false;
  String _currentSearchQuery = '';
  bool _isLoadingMore = false;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isOnline = true;

  PetListBloc({required PetRepository repository})
      : _repository = repository,
        super(PetListInitial()) {
    on<LoadPets>(_onLoadPets);
    on<RefreshPets>(_onRefreshPets);
    on<LoadMorePets>(_onLoadMorePets);
    on<SearchPets>(_onSearchPets, 
      transformer: (events, mapper) => events
        .debounceTime(const Duration(milliseconds: ApiConstants.searchDebounceMs))
        .switchMap(mapper),
    );
    on<UpdatePetInList>(_onUpdatePetInList);
    on<ConnectivityChanged>(_onConnectivityChanged);
    
    // Listen to connectivity changes
    _connectivitySubscription = _repository.connectionStatus.listen((isOnline) {
      add(ConnectivityChanged(isOnline: isOnline));
    });
  }

  Future<void> _onLoadPets(LoadPets event, Emitter<PetListState> emit) async {
    emit(PetListLoading());
    _isOnline = _repository.isOnline;
    
    try {
      final response = await _repository.fetchPets(
        page: 1,
        limit: ApiConstants.defaultPageSize,
        forceRefresh: _isOnline,
      );
      
      _allPets = response.pets.map((petResponse) {
        final isFavorite = _repository.isFavorite(petResponse.id);
        return PetModel.fromResponse(petResponse, isFavorite: isFavorite);
      }).toList();
      
      _currentPage = response.page;
      _totalPages = response.totalPages;
      _hasReachedMax = !response.hasMore;
      
      emit(PetListLoaded(
        pets: _allPets,
        hasReachedMax: _hasReachedMax,
        filteredPets: _allPets,
        currentPage: _currentPage,
        totalPages: _totalPages,
        totalItems: response.total,
        isOnline: _isOnline,
        lastSyncTime: _repository.getLastSyncTime(),
        error: !_isOnline ? 'No internet connection. Showing offline data.' : null,
      ));
    } catch (e) {
      emit(PetListError(message: e.toString()));
    }
  }

  Future<void> _onRefreshPets(RefreshPets event, Emitter<PetListState> emit) async {
    try {
      final response = await _repository.fetchPets(
        page: 1,
        limit: ApiConstants.defaultPageSize,
        searchQuery: _currentSearchQuery.isNotEmpty ? _currentSearchQuery : null,
        forceRefresh: true,
      );
      
      _allPets = response.pets.map((petResponse) {
        final isFavorite = _repository.isFavorite(petResponse.id);
        return PetModel.fromResponse(petResponse, isFavorite: isFavorite);
      }).toList();
      
      _currentPage = response.page;
      _totalPages = response.totalPages;
      _hasReachedMax = !response.hasMore;
      
      emit(PetListLoaded(
        pets: _allPets,
        hasReachedMax: _hasReachedMax,
        filteredPets: _allPets,
        currentPage: _currentPage,
        totalPages: _totalPages,
        totalItems: response.total,
        isOnline: _repository.isOnline,
        lastSyncTime: _repository.getLastSyncTime(),
      ));
    } catch (e) {
      if (state is PetListLoaded) {
        final currentState = state as PetListLoaded;
        emit(currentState.copyWith(
          error: 'Failed to refresh: ${e.toString()}',
        ));
      } else {
        emit(PetListError(message: e.toString()));
      }
    }
  }

  Future<void> _onLoadMorePets(LoadMorePets event, Emitter<PetListState> emit) async {
    if (state is! PetListLoaded || _hasReachedMax || _isLoadingMore) return;
    
    _isLoadingMore = true;
    final currentState = state as PetListLoaded;
    
    try {
      emit(currentState.copyWith(isLoadingMore: true));
      
      final response = await _repository.fetchPets(
        page: _currentPage + 1,
        limit: ApiConstants.defaultPageSize,
        searchQuery: _currentSearchQuery.isNotEmpty ? _currentSearchQuery : null,
      );
      
      if (response.pets.isEmpty) {
        _hasReachedMax = true;
        emit(currentState.copyWith(
          hasReachedMax: true,
          isLoadingMore: false,
        ));
      } else {
        final newPets = response.pets.map((petResponse) {
          final isFavorite = _repository.isFavorite(petResponse.id);
          return PetModel.fromResponse(petResponse, isFavorite: isFavorite);
        }).toList();
        
        _currentPage = response.page;
        _totalPages = response.totalPages;
        _hasReachedMax = !response.hasMore;
        _allPets = [..._allPets, ...newPets];
        
        emit(PetListLoaded(
          pets: _allPets,
          hasReachedMax: _hasReachedMax,
          filteredPets: _allPets,
          currentPage: _currentPage,
          totalPages: _totalPages,
          totalItems: response.total,
          isLoadingMore: false,
          isOnline: _repository.isOnline,
          lastSyncTime: _repository.getLastSyncTime(),
        ));
      }
    } catch (e) {
      emit(currentState.copyWith(
        error: 'Failed to load more: ${e.toString()}',
        isLoadingMore: false,
      ));
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> _onSearchPets(SearchPets event, Emitter<PetListState> emit) async {
    _currentSearchQuery = event.query;
    
    // Cancel any ongoing search
    _repository.cancelSearch();
    
    if (state is PetListLoaded) {
      emit((state as PetListLoaded).copyWith(isSearching: true));
    } else {
      emit(PetListLoading());
    }
    
    try {
      final response = await _repository.fetchPets(
        page: 1,
        limit: ApiConstants.defaultPageSize,
        searchQuery: event.query.isNotEmpty ? event.query : null,
      );
      
      _allPets = response.pets.map((petResponse) {
        final isFavorite = _repository.isFavorite(petResponse.id);
        return PetModel.fromResponse(petResponse, isFavorite: isFavorite);
      }).toList();
      
      _currentPage = response.page;
      _totalPages = response.totalPages;
      _hasReachedMax = !response.hasMore;
      
      emit(PetListLoaded(
        pets: _allPets,
        hasReachedMax: _hasReachedMax,
        filteredPets: _allPets,
        currentPage: _currentPage,
        totalPages: _totalPages,
        totalItems: response.total,
        searchQuery: event.query,
        isSearching: false,
        isOnline: _repository.isOnline,
        lastSyncTime: _repository.getLastSyncTime(),
      ));
    } catch (e) {
      if (e.toString().contains('Search cancelled')) {
        // Search was cancelled, don't emit error
        return;
      }
      
      if (state is PetListLoaded) {
        emit((state as PetListLoaded).copyWith(
          error: 'Search failed: ${e.toString()}',
          isSearching: false,
        ));
      } else {
        emit(PetListError(message: e.toString()));
      }
    }
  }

  void _onUpdatePetInList(UpdatePetInList event, Emitter<PetListState> emit) {
    if (state is! PetListLoaded) return;
    
    final currentState = state as PetListLoaded;
    
    _allPets = _allPets.map((pet) {
      return pet.id == event.pet.id ? event.pet : pet;
    }).toList();
    
    emit(currentState.copyWith(
      pets: _allPets,
      filteredPets: _allPets,
    ));
  }
  
  Future<void> _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<PetListState> emit,
  ) async {
    _isOnline = event.isOnline;
    
    if (state is PetListLoaded) {
      final currentState = state as PetListLoaded;
      
      if (event.isOnline && !currentState.isOnline) {
        // Connection restored - auto refresh
        emit(currentState.copyWith(
          isOnline: true,
          error: null,
        ));
        
        // Refresh data from API
        add(RefreshPets());
      } else if (!event.isOnline) {
        // Connection lost
        emit(currentState.copyWith(
          isOnline: false,
          error: 'No internet connection. Showing offline data.',
          lastSyncTime: _repository.getLastSyncTime(),
        ));
      }
    }
  }
  
  @override
  Future<void> close() {
    _searchDebouncer.dispose();
    _repository.cancelSearch();
    _connectivitySubscription?.cancel();
    return super.close();
  }
}