import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../models/pet_model.dart';
import '../models/pet_response.dart';
import '../models/favorite_model.dart';
import '../models/history_model.dart';
import '../services/pet_api_service.dart';
import '../../core/services/connectivity_service.dart';

class PetRepository {
  static const String _favoritesBoxName = 'favorites';
  static const String _historyBoxName = 'history';
  static const String _petsBoxName = 'pets_cache';
  static const String _lastSyncKey = 'last_sync';

  final PetApiService _apiService;
  final ConnectivityService _connectivityService;
  late Box<FavoriteModel> _favoritesBox;
  late Box<HistoryModel> _historyBox;
  late Box<PetModel> _petsBox;
  late Box _metadataBox;

  // Cache for current favorites list
  Set<String> _favoriteIds = {};

  // Cancel tokens for managing requests
  CancelToken? _searchCancelToken;

  PetRepository({
    PetApiService? apiService,
    ConnectivityService? connectivityService,
  }) : _apiService = apiService ?? PetApiService(),
       _connectivityService = connectivityService ?? ConnectivityService();

  Future<void> init() async {
    _favoritesBox = await Hive.openBox<FavoriteModel>(_favoritesBoxName);
    _historyBox = await Hive.openBox<HistoryModel>(_historyBoxName);
    _petsBox = await Hive.openBox<PetModel>(_petsBoxName);
    _metadataBox = await Hive.openBox('metadata');

    // Load cached favorite IDs

    // Try to sync favorites from API if online
    if (_connectivityService.isConnected) {
      try {
        await _syncFavorites();
      } catch (e) {
        // If sync fails, continue with local data
        // Silently fail - continue with local data
      }
    }
  }

  // Sync favorites with API
  Future<void> _syncFavorites() async {
    try {
      final apiFavorites = await _apiService.getFavorites();

      // Clear and update local favorites
      await _favoritesBox.clear();
      _favoriteIds.clear();

      for (final pet in apiFavorites) {
        await _favoritesBox.put(pet.pet.id, pet);
        _favoriteIds.add(pet.pet.id);
      }
    } catch (e) {
      throw Exception('Failed to sync favorites: $e');
    }
  }

  // Fetch pets with pagination and search
  Future<PaginatedResponse> fetchPets({
    int page = 1,
    int limit = 10,
    String? searchQuery,
    bool forceRefresh = false,
  }) async {
    // Check connectivity
    final isOnline = await _connectivityService.checkConnectivity();

    if (!isOnline || !forceRefresh) {
      // Return cached data when offline
      return _fetchPetsFromCache(
        page: page,
        limit: limit,
        searchQuery: searchQuery,
      );
    }

    try {
      // Cancel previous search if exists
      _searchCancelToken?.cancel();
      _searchCancelToken = CancelToken();

      final paginatedResponse = await _apiService.getPets(
        search: searchQuery,
        page: page,
        limit: limit,
        cancelToken: _searchCancelToken,
      );

      // Cache the fetched pets
      if (searchQuery == null || searchQuery.isEmpty) {
        await _cachePets(paginatedResponse.pets, page);
      }

      // Update last sync time
      await _metadataBox.put(_lastSyncKey, DateTime.now().toIso8601String());

      return PaginatedResponse(
        pets: paginatedResponse.pets,
        total: paginatedResponse.total,
        page: paginatedResponse.page,
        limit: paginatedResponse.limit,
        totalPages: paginatedResponse.totalPages,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw Exception('Search cancelled');
      }

      // If network error, fall back to cache
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return _fetchPetsFromCache(
          page: page,
          limit: limit,
          searchQuery: searchQuery,
        );
      }

      throw Exception(e.message ?? 'Failed to fetch pets');
    } catch (e) {
      // Fall back to cache on any error
      return _fetchPetsFromCache(
        page: page,
        limit: limit,
        searchQuery: searchQuery,
      );
    }
  }

  // Fetch pets from local cache
  Future<PaginatedResponse> _fetchPetsFromCache({
    required int page,
    required int limit,
    String? searchQuery,
  }) async {
    final allCachedPets = _petsBox.values.toList();

    // Apply search filter if needed
    List<PetModel> filteredPets = allCachedPets;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredPets = allCachedPets.where((pet) {
        return pet.name.toLowerCase().contains(query) ||
            pet.breed.toLowerCase().contains(query) ||
            pet.species.toLowerCase().contains(query);
      }).toList();
    }

    // Apply pagination
    final startIndex = (page - 1) * limit;
    final paginatedPets = filteredPets.skip(startIndex).take(limit).toList();

    // Convert to PetResponse for consistency
    final petResponses = paginatedPets
        .map(
          (pet) => PetResponse(
            id: pet.id,
            name: pet.name,
            age: pet.age,
            price: pet.price,
            breed: pet.breed,
            description: pet.description,
            imageUrl: pet.imageUrl,
            isAdopted: pet.isAdopted,
            species: pet.species,
            gender: pet.gender,
            size: pet.size,
            status: pet.status,
          ),
        )
        .toList();

    return PaginatedResponse(
      pets: petResponses,
      total: filteredPets.length,
      page: page,
      limit: limit,
      totalPages: (filteredPets.length / limit).ceil(),
    );
  }

  // Cache pets to local storage
  Future<void> _cachePets(List<PetResponse> pets, int page) async {
    // If first page, clear existing cache
    if (page == 1) {
      await _petsBox.clear();
    }

    // Cache each pet
    for (final petResponse in pets) {
      final isFavorite = _favoriteIds.contains(petResponse.id);
      final petModel = PetModel.fromResponse(
        petResponse,
        isFavorite: isFavorite,
      );
      await _petsBox.put(petModel.id, petModel);
    }
  }

  // Get single pet details
  Future<PetModel> getPetDetails(String petId) async {
    try {
      final petResponse = await _apiService.getPetDetails(petId);
      final isFavorite = _favoriteIds.contains(petResponse.id);
      return PetModel.fromResponse(petResponse, isFavorite: isFavorite);
    } catch (e) {
      throw Exception('Failed to get pet details: $e');
    }
  }

  // Adopt a pet
  Future<void> adoptPet(PetModel pet) async {
    try {
      // Call API
      final adoptionResponse = await _apiService.adoptPet(pet.id);

      // Update local history
      final adoptedPet = pet.copyWith(
        isAdopted: true,
        adoptedAt: adoptionResponse.adoptedAt,
      );
      final historyItem = HistoryModel(
        pet: adoptedPet,
        addedAt: adoptionResponse.adoptedAt ?? DateTime.now(),
      );
      await _historyBox.put(pet.id, historyItem);
    } catch (e) {
      throw Exception('Failed to adopt pet: $e');
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite(PetModel pet) async {
    try {
      if (pet.isFavorite) {
        // Remove from favorites
        await _apiService.removeFromFavorites(pet.id);
        await _favoritesBox.delete(pet.id);
        _favoriteIds.remove(pet.id);
      } else {
        // Add to favorites
        await _apiService.addToFavorites(pet.id);
        final favoritePet = pet.copyWith(isFavorite: true);
        final favorite = FavoriteModel(
          pet: favoritePet,
          addedAt: DateTime.now(),
        );
        await _favoritesBox.put(pet.id, favorite);
        _favoriteIds.add(pet.id);
      }
    } catch (e) {
      throw Exception('Failed to update favorite: $e');
    }
  }

  // Get all favorites
  Future<List<FavoriteModel>> getFavorites() async {
    try {
      // Try to get from API first
      final apiFavorites = await _apiService.getFavorites();

      // Update local cache
      await _favoritesBox.clear();
      _favoriteIds.clear();

      final favorites = apiFavorites.map((pet) {
        final favoritePet = pet.copyWith(
          pet: pet.pet.copyWith(isFavorite: true),
        );

        _favoriteIds.add(pet.pet.id);
        return favoritePet;
      }).toList();

      // Sort by most recent first
      favorites.sort((a, b) => b.addedAt.compareTo(a.addedAt));

      // Save to box
      for (final favorite in favorites) {
        await _favoritesBox.put(favorite.pet.id, favorite);
      }

      return favorites;
    } catch (e) {
      // Fallback to local data
      final favorites = _favoritesBox.values.toList()
        ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return favorites;
    }
  }

  // Get adoption history
  Future<List<HistoryModel>> getAdoptionHistory() async {
    try {
      // Try to get from API first
      final apiHistory = await _apiService.getAdoptionHistory();

      // Update local cache
      await _historyBox.clear();

      // Sort by most recent first
      apiHistory.sort((a, b) => b.addedAt.compareTo(a.addedAt));

      // Save to box
      for (final item in apiHistory) {
        await _historyBox.put(item.pet.id, item);
      }

      return apiHistory;
    } catch (e) {
      // Fallback to local data
      final historyItems = _historyBox.values.toList()
        ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return historyItems;
    }
  }

  // Clear all local data
  Future<void> clearAllData() async {
    await _favoritesBox.clear();
    await _historyBox.clear();
    _favoriteIds.clear();
  }

  // Cancel ongoing search
  void cancelSearch() {
    _searchCancelToken?.cancel();
  }

  // Check if a pet is favorite (local check)
  bool isFavorite(String petId) {
    return _favoriteIds.contains(petId);
  }

  // Get connectivity status
  bool get isOnline => _connectivityService.isConnected;

  // Get connectivity stream
  Stream<bool> get connectionStatus => _connectivityService.connectionStatus;

  // Get last sync time
  DateTime? getLastSyncTime() {
    final lastSync = _metadataBox.get(_lastSyncKey);
    if (lastSync != null) {
      return DateTime.tryParse(lastSync);
    }
    return null;
  }
}
