import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_adoption_app/data/models/pet_model.dart';
import 'package:pet_adoption_app/data/models/pet_response.dart';
import 'package:pet_adoption_app/data/repositories/pet_repository.dart';
import 'package:pet_adoption_app/logic/blocs/pet_list/pet_list_bloc.dart';

class MockPetRepository extends Mock implements PetRepository {}

void main() {
  late PetListBloc petListBloc;
  late MockPetRepository mockRepository;

  setUp(() {
    mockRepository = MockPetRepository();
    when(() => mockRepository.connectionStatus)
        .thenAnswer((_) => Stream.value(true));
    petListBloc = PetListBloc(repository: mockRepository);
  });

  tearDown(() {
    petListBloc.close();
  });

  group('PetListBloc', () {
    final testPetResponses = [
      const PetResponse(
        id: '1',
        name: 'Max',
        age: 3,
        price: 250.0,
        breed: 'Labrador',
        description: 'Friendly dog',
        imageUrl: 'https://example.com/max.jpg',
        isAdopted: false,
        species: 'Dog',
        gender: 'Male',
        size: 'Large',
        status: 'adoptable',
      ),
      const PetResponse(
        id: '2',
        name: 'Bella',
        age: 2,
        price: 200.0,
        breed: 'Beagle',
        description: 'Playful dog',
        imageUrl: 'https://example.com/bella.jpg',
        isAdopted: false,
        species: 'Dog',
        gender: 'Female',
        size: 'Medium',
        status: 'adoptable',
      ),
    ];

    final testPets = [
      const PetModel(
        id: '1',
        name: 'Max',
        age: 3,
        price: 250.0,
        breed: 'Labrador',
        description: 'Friendly dog',
        imageUrl: 'https://example.com/max.jpg',
        isAdopted: false,
        isFavorite: false,
        species: 'Dog',
        gender: 'Male',
        size: 'Large',
        status: 'adoptable',
      ),
      const PetModel(
        id: '2',
        name: 'Bella',
        age: 2,
        price: 200.0,
        breed: 'Beagle',
        description: 'Playful dog',
        imageUrl: 'https://example.com/bella.jpg',
        isAdopted: false,
        isFavorite: false,
        species: 'Dog',
        gender: 'Female',
        size: 'Medium',
        status: 'adoptable',
      ),
    ];

    final testPaginatedResponse = PaginatedResponse(
      pets: testPetResponses,
      total: 2,
      page: 1,
      limit: 10,
      totalPages: 1,
    );

    test('initial state is PetListInitial', () {
      expect(petListBloc.state, PetListInitial());
    });

    blocTest<PetListBloc, PetListState>(
      'emits [PetListLoading, PetListLoaded] when LoadPets is added successfully',
      build: () {
        when(() => mockRepository.fetchPets(
          page: 1,
          limit: any(named: 'limit'),
          forceRefresh: any(named: 'forceRefresh'),
        )).thenAnswer((_) async => testPaginatedResponse);
        
        when(() => mockRepository.isFavorite(any()))
            .thenReturn(false);
        
        when(() => mockRepository.isOnline).thenReturn(true);
        when(() => mockRepository.getLastSyncTime()).thenReturn(null);
        when(() => mockRepository.connectionStatus)
            .thenAnswer((_) => Stream.value(true));
        
        return petListBloc;
      },
      act: (bloc) => bloc.add(LoadPets()),
      expect: () => [
        PetListLoading(),
        isA<PetListLoaded>()
          .having((state) => state.pets.length, 'pets length', 2)
          .having((state) => state.hasReachedMax, 'hasReachedMax', true)
          .having((state) => state.currentPage, 'currentPage', 1)
          .having((state) => state.totalPages, 'totalPages', 1)
          .having((state) => state.isOnline, 'isOnline', true),
      ],
    );

    blocTest<PetListBloc, PetListState>(
      'emits [PetListLoading, PetListError] when LoadPets fails',
      build: () {
        when(() => mockRepository.fetchPets(
          page: 1,
          limit: any(named: 'limit'),
          forceRefresh: any(named: 'forceRefresh'),
        )).thenThrow(Exception('Failed to load pets'));
        
        when(() => mockRepository.isOnline).thenReturn(true);
        when(() => mockRepository.connectionStatus)
            .thenAnswer((_) => Stream.value(true));
        
        return petListBloc;
      },
      act: (bloc) => bloc.add(LoadPets()),
      expect: () => [
        PetListLoading(),
        isA<PetListError>()
          .having((state) => state.message, 'message', 
            contains('Failed to load pets')),
      ],
    );

    blocTest<PetListBloc, PetListState>(
      'emits [PetListLoaded] with updated pet when UpdatePetInList is added',
      build: () {
        when(() => mockRepository.fetchPets(
          page: 1,
          limit: any(named: 'limit'),
          forceRefresh: any(named: 'forceRefresh'),
        )).thenAnswer((_) async => testPaginatedResponse);
        
        when(() => mockRepository.isFavorite(any()))
            .thenReturn(false);
        
        when(() => mockRepository.isOnline).thenReturn(true);
        when(() => mockRepository.getLastSyncTime()).thenReturn(null);
        when(() => mockRepository.connectionStatus)
            .thenAnswer((_) => Stream.value(true));
        
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
        isA<PetListLoaded>()
          .having((state) => state.pets[0].isAdopted, 'first pet adopted', true)
          .having((state) => state.pets[1].isAdopted, 'second pet adopted', false),
      ],
    );

    blocTest<PetListBloc, PetListState>(
      'emits [PetListLoaded] with isOnline false when ConnectivityChanged offline',
      build: () {
        when(() => mockRepository.fetchPets(
          page: 1,
          limit: any(named: 'limit'),
          forceRefresh: any(named: 'forceRefresh'),
        )).thenAnswer((_) async => testPaginatedResponse);
        
        when(() => mockRepository.isFavorite(any()))
            .thenReturn(false);
        
        when(() => mockRepository.isOnline).thenReturn(true);
        when(() => mockRepository.getLastSyncTime()).thenReturn(DateTime.now());
        when(() => mockRepository.connectionStatus)
            .thenAnswer((_) => Stream.value(false));
        
        return petListBloc;
      },
      act: (bloc) async {
        bloc.add(LoadPets());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const ConnectivityChanged(isOnline: false));
      },
      skip: 2, // Skip LoadPets states
      expect: () => [
        isA<PetListLoaded>()
          .having((state) => state.isOnline, 'isOnline', false)
          .having((state) => state.error, 'error', 
            'No internet connection. Showing offline data.'),
      ],
    );
  });
}