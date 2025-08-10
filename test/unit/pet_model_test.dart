import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/data/models/pet_model.dart';

void main() {
  group('PetModel', () {
    test('should create PetModel from JSON', () {
      final json = {
        'id': '1',
        'name': 'Max',
        'age': 3,
        'price': 250.0,
        'breeds': {'primary': 'Labrador'},
        'description': 'Friendly dog',
        'photos': [
          {
            'large': 'https://example.com/large.jpg',
            'medium': 'https://example.com/medium.jpg',
            'small': 'https://example.com/small.jpg',
          }
        ],
        'species': 'Dog',
        'gender': 'Male',
        'size': 'Large',
        'status': 'adoptable',
      };

      final pet = PetModel.fromJson(json);

      expect(pet.id, '1');
      expect(pet.name, 'Max');
      expect(pet.age, 3);
      expect(pet.price, 250.0);
      expect(pet.breed, 'Labrador');
      expect(pet.description, 'Friendly dog');
      expect(pet.imageUrl, 'https://example.com/large.jpg');
      expect(pet.species, 'Dog');
      expect(pet.gender, 'Male');
      expect(pet.size, 'Large');
      expect(pet.status, 'adoptable');
      expect(pet.isAdopted, false);
      expect(pet.isFavorite, false);
    });

    test('should convert PetModel to JSON', () {
      final pet = PetModel(
        id: '1',
        name: 'Max',
        age: 3,
        price: 250.0,
        breed: 'Labrador',
        description: 'Friendly dog',
        imageUrl: 'https://example.com/image.jpg',
        isAdopted: true,
        isFavorite: true,
        adoptedAt: DateTime(2024, 1, 1),
        species: 'Dog',
        gender: 'Male',
        size: 'Large',
        status: 'adopted',
      );

      final json = pet.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Max');
      expect(json['age'], 3);
      expect(json['price'], 250.0);
      expect(json['breed'], 'Labrador');
      expect(json['description'], 'Friendly dog');
      expect(json['imageUrl'], 'https://example.com/image.jpg');
      expect(json['isAdopted'], true);
      expect(json['isFavorite'], true);
      expect(json['adoptedAt'], '2024-01-01T00:00:00.000');
      expect(json['species'], 'Dog');
      expect(json['gender'], 'Male');
      expect(json['size'], 'Large');
      expect(json['status'], 'adopted');
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id': '2',
        'name': 'Bella',
        'age': 2,
        'price': 150,
      };

      final pet = PetModel.fromJson(json);

      expect(pet.id, '2');
      expect(pet.name, 'Bella');
      expect(pet.age, 2);
      expect(pet.price, 150.0);
      expect(pet.breed, 'Mixed');
      expect(pet.description, 'No description available');
      expect(pet.imageUrl, 'https://via.placeholder.com/300');
      expect(pet.isAdopted, false);
      expect(pet.isFavorite, false);
      expect(pet.adoptedAt, null);
      expect(pet.species, null);
      expect(pet.gender, null);
      expect(pet.size, null);
      expect(pet.status, null);
    });

    test('should create a copy with updated fields', () {
      final pet = const PetModel(
        id: '1',
        name: 'Max',
        age: 3,
        price: 250.0,
        breed: 'Labrador',
        description: 'Friendly dog',
        imageUrl: 'https://example.com/image.jpg',
      );

      final updatedPet = pet.copyWith(
        isAdopted: true,
        isFavorite: true,
        adoptedAt: DateTime(2024, 1, 1),
      );

      expect(updatedPet.id, '1');
      expect(updatedPet.name, 'Max');
      expect(updatedPet.isAdopted, true);
      expect(updatedPet.isFavorite, true);
      expect(updatedPet.adoptedAt, DateTime(2024, 1, 1));
    });

    test('should compare two PetModel instances for equality', () {
      final pet1 = const PetModel(
        id: '1',
        name: 'Max',
        age: 3,
        price: 250.0,
        breed: 'Labrador',
        description: 'Friendly dog',
        imageUrl: 'https://example.com/image.jpg',
      );

      final pet2 = const PetModel(
        id: '1',
        name: 'Max',
        age: 3,
        price: 250.0,
        breed: 'Labrador',
        description: 'Friendly dog',
        imageUrl: 'https://example.com/image.jpg',
      );

      final pet3 = const PetModel(
        id: '2',
        name: 'Bella',
        age: 2,
        price: 150.0,
        breed: 'Beagle',
        description: 'Playful dog',
        imageUrl: 'https://example.com/image2.jpg',
      );

      expect(pet1, equals(pet2));
      expect(pet1, isNot(equals(pet3)));
    });
  });
}