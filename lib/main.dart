import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'data/models/pet_model.dart';
import 'data/services/hive_config.dart';
import 'data/repositories/pet_repository.dart';
import 'logic/blocs/pet_list/pet_list_bloc.dart';
import 'logic/blocs/pet_details/pet_details_bloc.dart';
import 'logic/blocs/favorites/favorites_bloc.dart';
import 'logic/blocs/history/history_bloc.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register all Hive adapters
  HiveConfig.registerAdapters();
  await HiveConfig.initBoxes();

  final petRepository = PetRepository();
  await petRepository.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: PetAdoptionApp(repository: petRepository),
    ),
  );
}

class PetAdoptionApp extends StatelessWidget {
  final PetRepository repository;

  const PetAdoptionApp({Key? key, required this.repository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PetListBloc>(
          create: (_) => PetListBloc(repository: repository),
        ),
        BlocProvider<PetDetailsBloc>(
          create: (_) => PetDetailsBloc(repository: repository),
        ),
        BlocProvider<FavoritesBloc>(
          create: (_) => FavoritesBloc(repository: repository),
        ),
        BlocProvider<HistoryBloc>(
          create: (_) => HistoryBloc(repository: repository),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Posha - Pet Adoption',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.themeMode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
