import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'app.dart';
import 'hive_registrar.g.dart';
import 'shared/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapters();

  final storage = StorageService();
  await storage.init();
  await storage.cleanupIncompleteSessions();

  runApp(ReverseSingApp(storage: storage));
}
