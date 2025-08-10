import 'package:hive/hive.dart';
import '../models/pet_model.dart';
import '../models/favorite_model.dart';
import '../models/history_model.dart';

class HiveConfig {
  static void registerAdapters() {
    Hive.registerAdapter(PetModelAdapter());
    Hive.registerAdapter(FavoriteModelAdapter());
    Hive.registerAdapter(HistoryModelAdapter());
  }

  static Future<void> initBoxes() async {
    await Future.wait([
      Hive.openBox<PetModel>('pets_cache'),
      Hive.openBox<FavoriteModel>('favorites'),
      Hive.openBox<HistoryModel>('history'),
      Hive.openBox('metadata'),
    ]);
  }
}
