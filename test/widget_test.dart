import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:pet_adoption_app/core/theme/theme_provider.dart';
import 'package:pet_adoption_app/data/repositories/pet_repository.dart';
import 'package:pet_adoption_app/logic/blocs/pet_list/pet_list_bloc.dart';
import 'package:pet_adoption_app/logic/blocs/favorites/favorites_bloc.dart';
import 'package:pet_adoption_app/logic/blocs/history/history_bloc.dart';
import 'package:pet_adoption_app/presentation/pages/home_page.dart';
import 'package:pet_adoption_app/main.dart';

class MockPetRepository extends Mock implements PetRepository {}
class MockBox extends Mock implements Box {}

void main() {
  late MockPetRepository mockRepository;
  late MockBox mockThemeBox;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Mock Hive initialization - don't actually initialize Hive in tests
    mockThemeBox = MockBox();
  });

  setUp(() {
    mockRepository = MockPetRepository();
    when(() => mockRepository.connectionStatus)
        .thenAnswer((_) => Stream.value(true));
    when(() => mockRepository.isOnline).thenReturn(true);
    
    // Mock the theme box behavior
    when(() => mockThemeBox.get('isDarkMode', defaultValue: any(named: 'defaultValue')))
        .thenReturn(false);
    when(() => mockThemeBox.put(any(), any())).thenAnswer((_) async {});
  });

  Widget createTestableWidget(Widget child) {
    final themeProvider = ThemeProvider();
    // Initialize the theme provider with the mock box
    themeProvider.setTestBox(mockThemeBox);
    
    return ChangeNotifierProvider.value(
      value: themeProvider,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => PetListBloc(repository: mockRepository),
          ),
          BlocProvider(
            create: (_) => FavoritesBloc(repository: mockRepository),
          ),
          BlocProvider(
            create: (_) => HistoryBloc(repository: mockRepository),
          ),
        ],
        child: MaterialApp(
          home: child,
        ),
      ),
    );
  }

  testWidgets('PetAdoptionApp has a home page', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();
    themeProvider.setTestBox(mockThemeBox);
    
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeProvider,
        child: PetAdoptionApp(repository: mockRepository),
      ),
    );

    // Wait for the app to build
    await tester.pumpAndSettle();

    // Verify that HomePage is rendered
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('HomePage shows app bar with title', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(const HomePage()));

    // Wait for the page to build
    await tester.pumpAndSettle();

    // Verify that the app bar exists
    expect(find.byType(AppBar), findsOneWidget);
    
    // Verify that the title is displayed
    expect(find.text('Posha'), findsOneWidget);
  });

  testWidgets('HomePage shows loading indicator initially', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(const HomePage()));

    // First pump to show initial state
    await tester.pump();
    
    // Initially, the BLoC should be in loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('HomePage shows bottom navigation bar', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(const HomePage()));

    await tester.pumpAndSettle();

    // Verify that the bottom navigation bar exists
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Verify navigation items
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.byIcon(Icons.history_rounded), findsOneWidget);
  });

  testWidgets('Theme toggle button works', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(const HomePage()));

    await tester.pumpAndSettle();

    // Find the theme toggle button - should show dark mode icon initially (system theme defaults to light)
    final themeButton = find.byIcon(Icons.dark_mode);
    expect(themeButton, findsOneWidget);

    // Tap the theme toggle button
    await tester.tap(themeButton);
    await tester.pumpAndSettle();

    // After toggling, it should switch icons
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });
}