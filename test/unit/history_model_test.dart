import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/data/models/history_model.dart';
import 'package:pet_adoption_app/data/models/pet_model.dart';

void main() {
  group('HistoryModel', () {
    test('should create HistoryModel from JSON', () {
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

      final history = HistoryModel.fromJson(json);

      expect(history.pet.id, '1');
      expect(history.pet.name, 'Max');
      expect(history.addedAt, DateTime.parse('2024-01-01T12:00:00.000Z'));
    });

    test('should convert HistoryModel to JSON', () {
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
      
      final history = HistoryModel(
        pet: pet,
        addedAt: DateTime(2024, 1, 1, 12, 0, 0),
      );

      final json = history.toJson();

      expect(json['pet']['id'], '1');
      expect(json['pet']['name'], 'Max');
      expect(json['added_at'], '2024-01-01T12:00:00.000');
    });

    test('should compare two HistoryModel instances for equality', () {
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
      
      final history1 = HistoryModel(
        pet: pet1,
        addedAt: date,
      );

      final history2 = HistoryModel(
        pet: pet1,
        addedAt: date,
      );

      final history3 = HistoryModel(
        pet: pet2,
        addedAt: date,
      );

      expect(history1, equals(history2));
      expect(history1, isNot(equals(history3)));
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
      
      final history1 = HistoryModel(
        pet: pet,
        addedAt: date,
      );

      final history2 = HistoryModel(
        pet: pet,
        addedAt: date,
      );

      expect(history1.hashCode, equals(history2.hashCode));
    });
  });
}