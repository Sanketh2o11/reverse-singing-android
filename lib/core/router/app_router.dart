import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/create_challenge/permission_explanation_screen.dart';
import '../../features/recording/recording_screen.dart';
import '../../features/playback/playback_screen.dart';
import '../../features/results/reveal_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/party_mode/party_setup_screen.dart';
import '../../features/party_mode/party_flow_screen.dart';

enum RecordingMode { original, attempt }

class PartyConfig {
  final List<String> playerNames;
  final int currentRound;
  final int totalRounds;

  const PartyConfig({
    required this.playerNames,
    this.currentRound = 0,
    this.totalRounds = 1,
  });
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/permission',
      builder: (context, state) => const PermissionExplanationScreen(),
    ),
    GoRoute(
      path: '/record/original',
      builder: (context, state) => const RecordingScreen(
        mode: RecordingMode.original,
      ),
    ),
    GoRoute(
      path: '/playback/reversed',
      builder: (context, state) => const PlaybackScreen(),
    ),
    GoRoute(
      path: '/record/attempt',
      builder: (context, state) => const RecordingScreen(
        mode: RecordingMode.attempt,
      ),
    ),
    GoRoute(
      path: '/reveal',
      builder: (context, state) => const RevealScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/history/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return RevealScreen(historyId: id);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/party/setup',
      builder: (context, state) => const PartySetupScreen(),
    ),
    GoRoute(
      path: '/party/flow',
      builder: (context, state) => const PartyFlowScreen(),
    ),
  ],
);
