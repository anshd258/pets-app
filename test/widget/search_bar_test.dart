import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_adoption_app/presentation/widgets/search_bar.dart';

void main() {
  group('CustomSearchBar Widget Test', () {
    testWidgets('should display search bar with hint text', (tester) async {
      String searchQuery = '';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomSearchBar(
              onSearch: (query) {
                searchQuery = query;
              },
            ),
          ),
        ),
      );

      expect(find.text('Search pets by name, breed...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should trigger onSearch when text is entered', (tester) async {
      String searchQuery = '';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomSearchBar(
              onSearch: (query) {
                searchQuery = query;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Labrador');
      await tester.pump();

      expect(searchQuery, 'Labrador');
    });

    testWidgets('should show clear button when text is entered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomSearchBar(
              onSearch: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsNothing);

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should clear text when clear button is pressed', (tester) async {
      String searchQuery = 'initial';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomSearchBar(
              onSearch: (query) {
                searchQuery = query;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();

      expect(searchQuery, 'Test');
      expect(find.byIcon(Icons.clear), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(searchQuery, '');
      expect(find.byIcon(Icons.clear), findsNothing);
      
      final TextField textField = tester.widget(find.byType(TextField));
      expect(textField.controller?.text, '');
    });

    testWidgets('should display initial query if provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomSearchBar(
              onSearch: (_) {},
              initialQuery: 'Initial Query',
            ),
          ),
        ),
      );

      final TextField textField = tester.widget(find.byType(TextField));
      expect(textField.controller?.text, 'Initial Query');
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should filter pet list based on search query', (tester) async {
      final pets = ['Max', 'Bella', 'Charlie', 'Luna'];
      final filteredPets = <String>[];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CustomSearchBar(
                  onSearch: (query) {
                    filteredPets.clear();
                    if (query.isEmpty) {
                      filteredPets.addAll(pets);
                    } else {
                      filteredPets.addAll(
                        pets.where((pet) => 
                          pet.toLowerCase().contains(query.toLowerCase())
                        ),
                      );
                    }
                  },
                ),
                Expanded(
                  child: ListView(
                    children: filteredPets.map((pet) => Text(pet)).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Initially, all pets should be shown
      filteredPets.addAll(pets);
      await tester.pump();

      // Search for 'Ma'
      await tester.enterText(find.byType(TextField), 'Ma');
      await tester.pump();

      expect(filteredPets, ['Max']);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(filteredPets, pets);
    });
  });
}