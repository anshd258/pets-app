import 'package:equatable/equatable.dart';

class PetResponse extends Equatable {
  final String id;
  final String name;
  final int age;
  final double price;
  final String breed;
  final String description;
  final String imageUrl;
  final String species;
  final String gender;
  final String size;
  final String status;
  final bool isAdopted;

  const PetResponse({
    required this.id,
    required this.name,
    required this.age,
    required this.price,
    required this.breed,
    required this.description,
    required this.imageUrl,
    required this.species,
    required this.gender,
    required this.size,
    required this.status,
    required this.isAdopted,
  });

  factory PetResponse.fromJson(Map<String, dynamic> json) {
    return PetResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      price: (json['price'] as num).toDouble(),
      breed: json['breed'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      species: json['species'] as String,
      gender: json['gender'] as String,
      size: json['size'] as String,
      status: json['status'] as String,
      isAdopted: json['is_adopted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'price': price,
      'breed': breed,
      'description': description,
      'image_url': imageUrl,
      'species': species,
      'gender': gender,
      'size': size,
      'status': status,
      'is_adopted': isAdopted,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        age,
        price,
        breed,
        description,
        imageUrl,
        species,
        gender,
        size,
        status,
        isAdopted,
      ];
}

class PaginatedResponse extends Equatable {
  final List<PetResponse> pets;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginatedResponse({
    required this.pets,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedResponse(
      pets: (json['pets'] as List<dynamic>)
          .map((e) => PetResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['total_pages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pets': pets.map((e) => e.toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
      'total_pages': totalPages,
    };
  }

  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [pets, total, page, limit, totalPages];
}

class AdoptionResponse extends Equatable {
  final String message;
  final String petId;
  final DateTime adoptedAt;

  const AdoptionResponse({
    required this.message,
    required this.petId,
    required this.adoptedAt,
  });

  factory AdoptionResponse.fromJson(Map<String, dynamic> json) {
    return AdoptionResponse(
      message: json['message'] as String,
      petId: json['pet_id'] as String,
      adoptedAt: DateTime.parse(json['adopted_at'] as String),
    );
  }

  @override
  List<Object?> get props => [message, petId, adoptedAt];
}

class FavoriteResponse extends Equatable {
  final String message;
  final String petId;
  final DateTime? addedAt;

  const FavoriteResponse({
    required this.message,
    required this.petId,
    this.addedAt,
  });

  factory FavoriteResponse.fromJson(Map<String, dynamic> json) {
    return FavoriteResponse(
      message: json['message'] as String,
      petId: json['pet_id'] as String,
      addedAt: json['added_at'] != null 
          ? DateTime.parse(json['added_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [message, petId, addedAt];
}