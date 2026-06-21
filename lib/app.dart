import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/settings_provider.dart';
import 'shared/controllers/game_session_controller.dart';
import 'shared/services/audio_reverse_service.dart';
import 'shared/services/playback_service.dart';
import 'shared/services/recorder_service.dart';
import 'shared/services/storage_service.dart';

class ReverseSingApp extends StatelessWidget {
  final StorageService storage;

  const ReverseSingApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storage),
        Provider<RecorderService>(
          create: (_) => RecorderService(),
          dispose: (_, s) => s.dispose(),
        ),
        Provider<AudioReverseService>(
          create: (_) => AudioReverseService(),
        ),
        Provider<PlaybackService>(
          create: (_) => PlaybackService(),
          dispose: (_, s) => s.dispose(),
        ),
        ChangeNotifierProvider<GameSessionController>(
          create: (ctx) => GameSessionController(
            recorder: ctx.read<RecorderService>(),
            reverser: ctx.read<AudioReverseService>(),
            playback: ctx.read<PlaybackService>(),
            storage: ctx.read<StorageService>(),
          ),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (ctx) =>
              SettingsProvider(storage: ctx.read<StorageService>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Reverse Sing',
        theme: buildAppTheme(),
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
