import 'package:hive_flutter/hive_flutter.dart';

Future<void> setupHive() async {
  await Hive.initFlutter();
  // Register adapters here when we have them
  await Hive.openBox('settings');
  await Hive.openBox('appointments_offline');
  await Hive.openBox('queue_cache');
}
