import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_adoption_app/data/models/pet_model.dart';
import 'package:pet_adoption_app/data/repositories/pet_repository.dart';
import 'package:pet_adoption_app/logic/blocs/pet_list/pet_list_bloc.dart';

class MockPetRepository extends Mock implements PetRepository {}

void main() {
  late PetListBloc petListBloc;
  late MockPetRepository mockRepository;

  setUp(() {
    mockRepository = MockPetRepository();
    petListBloc = PetListBloc(repository: mockRepository);
  });

  tearDown(() {
    petListBloc.close();
  });

  group('PetListBloc', () {
    final testPets = [
      const PetModel(
        id: '1',
        name: 'Max',
        age: 3,
        price: 250.0,
        breed: 'Labrador',
        description: 'Friendly dog',
        imageUrl: 'https://example.com/max.jpg',
      ),
      const PetModel(
        id: '2',
        name: 'Bella',
        age: 2,
        price: 200.0,
        breed: 'Beagle',
        description: 'Playful dog',
        imageUrl: 'https://example.com/bella.jpg',
      ),
    ];

    test('initial state is PetListInitial', () {
      expect(petListBloc.state, PetListInitial());
    });

    blocTest<PetListBloc, PetListState>(
      'emits [PetListLoading, PetListLoaded] when LoadPets is added successfully',
      build: () {
        when(() => mockRepository.fetchPets(page: 1))
            .thenAnswer((_) async => testPets);
        return petListBloc;
      },
      act: (bloc) => bloc.add(LoadPets()),
      expect: () => [
        PetListLoading(),
        PetListLoaded(
          pets: testPets,
          filteredPets: testPets,
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<PetListBloc, PetListState>(
      'emits [PetListLoading, PetListError] when LoadPets fails',
      build: () {
        when(() => mockRepository.fetchPets(page: 1))
            .thenThrow(Exception('Failed to load pets'));
        return petListBloc;
      },
      act: (bloc) => bloc.add(LoadPets()),
      expect: () => [
        PetListLoading(),
        isA<PetListError>(),
      ],
    );

    blocTest<PetListBloc, PetListState>(
      'emits [PetListLoaded] with filtered pets when SearchPets is added',
      build: () {
        when(() => mockRepository.fetchPets(page: 1))
            .thenAnswer((_) async => testPets);
        return petListBloc;
      },
      act: (bloc) async {
        bloc.add(LoadPets());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const SearchPets(query: 'Max'));
      },
      skip: 2, // Skip LoadPets states
      expect: () => [
        PetListLoaded(
          pets: testPets,
          filteredPets: [testPets[0]],
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<PetListBloc, PetListState>(
      'emits [PetListLoaded] with all pets when SearchPets is added with empty query',
      build: () {
        when(() => mockRepository.fetchPets(page: 1))
            .thenAnswer((_) async => testPets);
        return petListBloc;
      },
      act: (bloc) async {
        bloc.add(LoadPets());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const SearchPets(query: 'Max'));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const SearchPets(query: ''));
      },
      skip: 3, // Skip previous states
      expect: () => [
        PetListLoaded(
          pets: testPets,
          filteredPets: testPets,
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<PetListBloc, PetListState>(
      'emits [PetListLoaded] with updated pet when UpdatePetInList is added',
      build: () {
        when(() => mockRepository.fetchPets(page: 1))
            .thenAnswer((_) async => testPets);
        return petListBloc;
      },
      act: (bloc) async {
        bloc.add(LoadPets());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(UpdatePetInList(
          pet: testPets[0].copyWith(isAdopted: true),
        ));
      },
      skip: 2, // Skip LoadPets states
      expect: () => [
        PetListLoaded(
          pets: [
            testPets[0].copyWith(isAdopted: true),
            testPets[1],
          ],
          filteredPets: [
            testPets[0].copyWith(isAdopted: true),
            testPets[1],
          ],
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<PetListBloc, PetListState>(
      'emits [PetListLoaded] with more pets when LoadMorePets is added',
      build: () {
        when(() => mockRepository.fetchPets(page: 1))
            .thenAnswer((_) async => testPets);
        when(() => mockRepository.fetchPets(page: 2))
            .thenAnswer((_) async => [
          const PetModel(
            id: '3',
            name: 'Charlie',
            age: 4,
            price: 300.0,
            breed: 'Poodle',
            description: 'Smart dog',
            imageUrl: 'https://example.com/charlie.jpg',
          ),
        ]);
        return petListBloc;
      },
      act: (bloc) async {
        bloc.add(LoadPets());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(LoadMorePets());
      },
      skip: 2, // Skip LoadPets states
      expect: () => [
        PetListLoaded(
          pets: [
            ...testPets,
            const PetModel(
              id: '3',
              name: 'Charlie',
              age: 4,
              price: 300.0,
              breed: 'Poodle',
              description: 'Smart dog',
              imageUrl: 'https://example.com/charlie.jpg',
            ),
          ],
          filteredPets: [
            ...testPets,
            const PetModel(
              id: '3',
              name: 'Charlie',
              age: 4,
              price: 300.0,
              breed: 'Poodle',
              description: 'Smart dog',
              imageUrl: 'https://example.com/charlie.jpg',
            ),
          ],
          hasReachedMax: true,
        ),
      ],
    );
  });
}