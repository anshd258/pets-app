import 'package:dio/dio.dart';
import 'package:pet_adoption_app/data/models/favorite_model.dart';
import 'package:pet_adoption_app/data/models/history_model.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/pet_response.dart';
import '../models/pet_model.dart';

class PetApiService {
  final ApiClient _apiClient;
  
  PetApiService({ApiClient? apiClient}) 
      : _apiClient = apiClient ?? ApiClient();
  
  // Get paginated pets with optional search
  Future<PaginatedResponse> getPets({
    String? search,
    int page = 1,
    int limit = ApiConstants.defaultPageSize,
    CancelToken? cancelToken,
  }) async {
    try {
      _apiClient.talker.info('Fetching pets - Page: $page, Limit: $limit, Search: $search');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.pets,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'limit': limit,
        },
        cancelToken: cancelToken,
      );
      
      if (response.data == null) {
        throw Exception('No data received from server');
      }
      
      final paginatedResponse = PaginatedResponse.fromJson(response.data!);
      _apiClient.talker.info('Fetched ${paginatedResponse.pets.length} pets');
      
      return paginatedResponse;
    } on DioException catch (e) {
      _apiClient.talker.error('Failed to fetch pets', e);
      rethrow;
    } catch (e) {
      _apiClient.talker.error('Unexpected error fetching pets', e);
      throw Exception('Failed to fetch pets: $e');
    }
  }
  
  // Get single pet details
  Future<PetResponse> getPetDetails(String petId, {CancelToken? cancelToken}) async {
    try {
      _apiClient.talker.info('Fetching pet details for ID: $petId');
      
      final path = ApiConstants.buildPath(
        ApiConstants.petDetails,
        {'pet_id': petId},
      );
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        path,
        cancelToken: cancelToken,
      );
      
      if (response.data == null) {
        throw Exception('No data received from server');
      }
      
      final petResponse = PetResponse.fromJson(response.data!);
      _apiClient.talker.info('Fetched pet details: ${petResponse.name}');
      
      return petResponse;
    } on DioException catch (e) {
      _apiClient.talker.error('Failed to fetch pet details', e);
      rethrow;
    } catch (e) {
      _apiClient.talker.error('Unexpected error fetching pet details', e);
      throw Exception('Failed to fetch pet details: $e');
    }
  }
  
  // Adopt a pet
  Future<AdoptionResponse> adoptPet(String petId, {CancelToken? cancelToken}) async {
    try {
      _apiClient.talker.info('Adopting pet with ID: $petId');
      
      final path = ApiConstants.buildPath(
        ApiConstants.adoptPet,
        {'pet_id': petId},
      );
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        path,
        cancelToken: cancelToken,
      );
      
      if (response.data == null) {
        throw Exception('No data received from server');
      }
      
      final adoptionResponse = AdoptionResponse.fromJson(response.data!);
      _apiClient.talker.info('Pet adopted successfully: $petId');
      
      return adoptionResponse;
    } on DioException catch (e) {
      _apiClient.talker.error('Failed to adopt pet', e);
      rethrow;
    } catch (e) {
      _apiClient.talker.error('Unexpected error adopting pet', e);
      throw Exception('Failed to adopt pet: $e');
    }
  }
  
  // Get adoption history
  Future<List<HistoryModel>> getAdoptionHistory({CancelToken? cancelToken}) async {
    try {
      _apiClient.talker.info('Fetching adoption history');
      
      final response = await _apiClient.get<dynamic>(
        ApiConstants.adoptionHistory,
        cancelToken: cancelToken,
      );
      
      if (response.data == null) {
        return [];
      }
      
      // Handle both array and object responses
      List<dynamic> historyData;
      if (response.data is List) {
        historyData = response.data as List;
      } else if (response.data is Map && response.data['history'] != null) {
        historyData = response.data['history'] as List;
      } else {
        historyData = [];
      }
      
      final history = historyData
          .map((json) => HistoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      _apiClient.talker.info('Fetched ${history.length} adopted pets');
      
      return history;
    } on DioException catch (e) {
      _apiClient.talker.error('Failed to fetch adoption history', e);
      rethrow;
    } catch (e) {
      _apiClient.talker.error('Unexpected error fetching adoption history', e);
      throw Exception('Failed to fetch adoption history: $e');
    }
  }
  
  // Add pet to favorites
  Future<FavoriteResponse> addToFavorites(String petId, {CancelToken? cancelToken}) async {
    try {
      _apiClient.talker.info('Adding pet to favorites: $petId');
      
      final path = ApiConstants.buildPath(
        ApiConstants.addFavorite,
        {'pet_id': petId},
      );
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        path,
        cancelToken: cancelToken,
      );
      
      if (response.data == null) {
        throw Exception('No data received from server');
      }
      
      final favoriteResponse = FavoriteResponse.fromJson(response.data!);
      _apiClient.talker.info('Pet added to favorites: $petId');
      
      return favoriteResponse;
    } on DioException catch (e) {
      _apiClient.talker.error('Failed to add to favorites', e);
      rethrow;
    } catch (e) {
      _apiClient.talker.error('Unexpected error adding to favorites', e);
      throw Exception('Failed to add to favorites: $e');
    }
  }
  
  // Remove pet from favorites
  Future<FavoriteResponse> removeFromFavorites(String petId, {CancelToken? cancelToken}) async {
    try {
      _apiClient.talker.info('Removing pet from favorites: $petId');
      
      final path = ApiConstants.buildPath(
        ApiConstants.removeFavorite,
        {'pet_id': petId},
      );
      
      final response = await _apiClient.delete<Map<String, dynamic>>(
        path,
        cancelToken: cancelToken,
      );
      
      if (response.data == null) {
        throw Exception('No data received from server');
      }
      
      final favoriteResponse = FavoriteResponse.fromJson(response.data!);
      _apiClient.talker.info('Pet removed from favorites: $petId');
      
      return favoriteResponse;
    } on DioException catch (e) {
      _apiClient.talker.error('Failed to remove from favorites', e);
      rethrow;
    } catch (e) {
      _apiClient.talker.error('Unexpected error removing from favorites', e);
      throw Exception('Failed to remove from favorites: $e');
    }
  }
  
  // Get all favorite pets
  Future<List<FavoriteModel>> getFavorites({CancelToken? cancelToken}) async {
    try {
      _apiClient.talker.info('Fetching favorite pets');
      
      final response = await _apiClient.get<dynamic>(
        ApiConstants.favorites,
        cancelToken: cancelToken,
      );
      
      if (response.data == null) {
        return [];
      }
      
      // Handle both array and object responses
      List<dynamic> favoritesData;
      if (response.data is List) {
        favoritesData = response.data as List;
      } else if (response.data is Map && response.data['favorites'] != null) {
        favoritesData = response.data['favorites'] as List;
      } else {
        favoritesData = [];
      }
      
      final favorites = favoritesData
          .map((json) => FavoriteModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      _apiClient.talker.info('Fetched ${favorites.length} favorite pets');
      
      return favorites;
    } on DioException catch (e) {
      _apiClient.talker.error('Failed to fetch favorites', e);
      rethrow;
    } catch (e) {
      _apiClient.talker.error('Unexpected error fetching favorites', e);
      throw Exception('Failed to fetch favorites: $e');
    }
  }
}