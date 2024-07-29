import 'package:algorithm_visualizer/features/a_star/views/a_star_visualizer.dart';
import 'package:algorithm_visualizer/features/dijkstra/views/dijkstra_visualizer.dart';
import 'package:algorithm_visualizer/features/sidebar/views/sidebar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(MyApp());
}

var _rootNavigatorKey = GlobalKey<NavigatorState>();
var _shellNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/dijkstra-visualizer',
    navigatorKey: _rootNavigatorKey,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) =>
            ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const MyHomePage(),
          ),
          GoRoute(
            path: '/dijkstra-visualizer',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const DijkstraVisualizer(),
          ),
          GoRoute(
            path: '/a-star-visualizer',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const AStarVisualizer(),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Algorithm Visualization',
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home placeholder'),
    );
  }
}

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
