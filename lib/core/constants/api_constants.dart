class ApiConstants {
  // Base URL - Update this to point to your actual API server
  static const String baseUrl =
      'https://pets-backend-production-c424.up.railway.app';

  // API Endpoints
  static const String pets = '/pets/';
  static const String petDetails = '/pets/{pet_id}';
  static const String adoptPet = '/adopt/{pet_id}';
  static const String adoptionHistory = '/history';
  static const String addFavorite = '/favorite/{pet_id}';
  static const String removeFavorite = '/favorite/{pet_id}';
  static const String favorites = '/favorites';

  // Pagination defaults
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;

  // Network timeouts (in milliseconds)
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // Debounce duration for search (in milliseconds)
  static const int searchDebounceMs = 500;

  // Helper method to replace path parameters
  static String buildPath(String path, Map<String, dynamic> params) {
    String result = path;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }
}
