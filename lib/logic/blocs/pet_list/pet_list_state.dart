part of 'pet_list_bloc.dart';

abstract class PetListState extends Equatable {
  const PetListState();

  @override
  List<Object?> get props => [];
}

class PetListInitial extends PetListState {}

class PetListLoading extends PetListState {}

class PetListLoaded extends PetListState {
  final List<PetModel> pets;
  final List<PetModel> filteredPets;
  final bool hasReachedMax;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool isLoadingMore;
  final bool isSearching;
  final String? searchQuery;
  final bool isOnline;
  final DateTime? lastSyncTime;

  const PetListLoaded({
    required this.pets,
    required this.filteredPets,
    this.hasReachedMax = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.isLoadingMore = false,
    this.isSearching = false,
    this.searchQuery,
    this.isOnline = true,
    this.lastSyncTime,
  });

  PetListLoaded copyWith({
    List<PetModel>? pets,
    List<PetModel>? filteredPets,
    bool? hasReachedMax,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? isLoadingMore,
    bool? isSearching,
    String? searchQuery,
    bool? isOnline,
    DateTime? lastSyncTime,
  }) {
    return PetListLoaded(
      pets: pets ?? this.pets,
      filteredPets: filteredPets ?? this.filteredPets,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      isOnline: isOnline ?? this.isOnline,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  @override
  List<Object?> get props => [
    pets,
    filteredPets,
    hasReachedMax,
    error,
    currentPage,
    totalPages,
    totalItems,
    isLoadingMore,
    isSearching,
    searchQuery,
    isOnline,
    lastSyncTime,
  ];
}

class PetListError extends PetListState {
  final String message;

  const PetListError({required this.message});

  @override
  List<Object?> get props => [message];
}