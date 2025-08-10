import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/data/models/favorite_model.dart';
import 'package:pet_adoption_app/data/models/pet_model.dart';

void main() {
  group('FavoriteModel', () {
    test('should create FavoriteModel from JSON', () {
      final json = {
        'pet': {
          'id': '1',
          'name': 'Max',
          'age': 3,
          'price': 250.0,
          'breed': 'Labrador',
          'description': 'Friendly dog',
          'imageUrl': 'https://example.com/max.jpg',
          'species': 'Dog',
          'gender': 'Male',
          'size': 'Large',
          'status': 'adoptable',
        },
        'added_at': '2024-01-01T12:00:00.000Z',
      };

      final favorite = FavoriteModel.fromJson(json);

      expect(favorite.pet.id, '1');
      expect(favorite.pet.name, 'Max');
      expect(favorite.addedAt, DateTime.parse('2024-01-01T12:00:00.000Z'));
    });

    test('should convert FavoriteModel to JSON', () {
      final pet = const PetModel(
        id: '1',
        name: 'Max',
        age: 3,
        price: 250.0,
        breed: 'Labrador',
        description: 'Friendly dog',
        imageUrl: 'https://example.com/max.jpg',
        species: 'Dog',
        gender: 'Male',
        size: 'Large',
        status: 'adoptable',
      );
      
      final favorite = FavoriteModel(
        pet: pet,
        addedAt: DateTime(2024, 1, 1, 12, 0, 0),
      );

      final json = favorite.toJson();

      expect(json['pet']['id'], '1');
      expect(json['pet']['name'], 'Max');
      expect(json['added_at'], '2024-01-01T12:00:00.000');
    });

    test('should compare two FavoriteModel instances for equality', () {
      final date = DateTime(2024, 1, 1, 12, 0, 0);
      final pet1 = const PetModel(
        id: '1',
        name: 'Max',
        age: 3,
        price: 250.0,
        breed: 'Labrador',
        description: 'Friendly dog',
        imageUrl: 'https://example.com/max.jpg',
        species: 'Dog',
        gender: 'Male',
        size: 'Large',
        status: 'adoptable',
      );
      
      final pet2 = const PetModel(
        id: '2',
        name: 'Bella',
        age: 2,
        price: 200.0,
        breed: 'Beagle',
        description: 'Playful dog',
        imageUrl: 'https://example.com/bella.jpg',
        species: 'Dog',
        gender: 'Female',
        size: 'Medium',
        status: 'adoptable',
      );
      
      final favorite1 = FavoriteModel(
        pet: pet1,
        addedAt: date,
      );

      final favorite2 = FavoriteModel(
        pet: pet1,
        addedAt: date,
      );

      final favorite3 = FavoriteModel(
        pet: pet2,
        addedAt: date,
      );

      expect(favorite1, equals(favorite2));
      expect(favorite1, isNot(equals(favorite3)));
    });

    test('should generate correct hashCode', () {
      final date = DateTime(2024, 1, 1, 12, 0, 0);
      final pet = const PetModel(
        id: '1',
        name: 'Max',
        age: 3,
        price: 250.0,
        breed: 'Labrador',
        description: 'Friendly dog',
        imageUrl: 'https://example.com/max.jpg',
        species: 'Dog',
        gender: 'Male',
        size: 'Large',
        status: 'adoptable',
      );
      
      final favorite1 = FavoriteModel(
        pet: pet,
        addedAt: date,
      );

      final favorite2 = FavoriteModel(
        pet: pet,
        addedAt: date,
      );

      expect(favorite1.hashCode, equals(favorite2.hashCode));
    });
  });
}