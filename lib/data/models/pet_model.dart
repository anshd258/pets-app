import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'pet_response.dart';

part 'pet_model.g.dart';

@HiveType(typeId: 0)
class PetModel extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final int age;
  
  @HiveField(3)
  final double price;
  
  @HiveField(4)
  final String breed;
  
  @HiveField(5)
  final String description;
  
  @HiveField(6)
  final String imageUrl;
  
  @HiveField(7)
  final bool isAdopted;
  
  @HiveField(8)
  final bool isFavorite;
  
  @HiveField(9)
  final DateTime? adoptedAt;
  
  @HiveField(10)
  final String species;
  
  @HiveField(11)
  final String gender;
  
  @HiveField(12)
  final String size;
  
  @HiveField(13)
  final String status;

  const PetModel({
    required this.id,
    required this.name,
    required this.age,
    required this.price,
    required this.breed,
    required this.description,
    required this.imageUrl,
    this.isAdopted = false,
    this.isFavorite = false,
    this.adoptedAt,
    required this.species,
    required this.gender,
    required this.size,
    required this.status,
  });

  // Create PetModel from API response
  factory PetModel.fromResponse(PetResponse response, {bool isFavorite = false}) {
    return PetModel(
      id: response.id,
      name: response.name,
      age: response.age,
      price: response.price,
      breed: response.breed,
      description: response.description,
      imageUrl: response.imageUrl,
      isAdopted: response.isAdopted,
      isFavorite: isFavorite,
      adoptedAt: null,
      species: response.species,
      gender: response.gender,
      size: response.size,
      status: response.status,
    );
  }

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      age: json['age'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      breed: json['breed'] ?? 'Mixed',
      description: json['description'] ?? 'No description available',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? 'https://via.placeholder.com/300',
      isAdopted: json['is_adopted'] ?? json['isAdopted'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      adoptedAt: json['adoptedAt'] != null 
          ? DateTime.parse(json['adoptedAt']) 
          : null,
      species: json['species'] ?? 'Unknown',
      gender: json['gender'] ?? 'Unknown',
      size: json['size'] ?? 'Medium',
      status: json['status'] ?? 'adoptable',
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
      'imageUrl': imageUrl,
      'isAdopted': isAdopted,
      'isFavorite': isFavorite,
      'adoptedAt': adoptedAt?.toIso8601String(),
      'species': species,
      'gender': gender,
      'size': size,
      'status': status,
    };
  }

  PetModel copyWith({
    String? id,
    String? name,
    int? age,
    double? price,
    String? breed,
    String? description,
    String? imageUrl,
    bool? isAdopted,
    bool? isFavorite,
    DateTime? adoptedAt,
    String? species,
    String? gender,
    String? size,
    String? status,
  }) {
    return PetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      price: price ?? this.price,
      breed: breed ?? this.breed,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isAdopted: isAdopted ?? this.isAdopted,
      isFavorite: isFavorite ?? this.isFavorite,
      adoptedAt: adoptedAt ?? this.adoptedAt,
      species: species ?? this.species,
      gender: gender ?? this.gender,
      size: size ?? this.size,
      status: status ?? this.status,
    );
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
        isAdopted,
        isFavorite,
        adoptedAt,
        species,
        gender,
        size,
        status,
      ];
}