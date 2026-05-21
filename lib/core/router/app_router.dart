import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/player/player_screen.dart';
import '../../presentation/library/library_screen.dart';
import '../../presentation/review/review_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/review',
            builder: (context, state) => const ReviewScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/player/:videoId',
        builder: (context, state) => PlayerScreen(
          videoId: state.pathParameters['videoId']!,
        ),
      ),
    ],
  );
});

class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = switch (location) {
      '/library' => 1,
      '/review' => 2,
      _ => 0,
    };

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/');
            case 1:
              context.go('/library');
            case 2:
              context.go('/review');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.video_library), label: '视频库'),
          NavigationDestination(icon: Icon(Icons.book), label: '单词本'),
          NavigationDestination(icon: Icon(Icons.quiz), label: '复习'),
        ],
      ),
    );
  }
}
