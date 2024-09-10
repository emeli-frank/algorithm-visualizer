import 'package:algorithm_visualizer/features/a_star/views/a_star_screen.dart';
import 'package:algorithm_visualizer/features/dijkstra/bloc/animation_bloc.dart';
import 'package:algorithm_visualizer/features/dijkstra/bloc/graph_bloc.dart';
import 'package:algorithm_visualizer/features/dijkstra/cubit/tool_selection_cubit.dart';
import 'package:algorithm_visualizer/features/dijkstra/views/dijkstra_screen.dart';
import 'package:algorithm_visualizer/features/sidebar/cubit/sidebar_cubit.dart';
import 'package:algorithm_visualizer/features/sidebar/views/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            MultiBlocProvider(
              providers: [
                BlocProvider<SidebarCubit>(
                  create: (_) => SidebarCubit(const SidebarState(isOpen: true)),
                ),
              ],
              child: ShellScaffold(child: child),
            ),
        routes: [
          GoRoute(
            path: '/home',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const MyHomePage(),
          ),
          GoRoute(
            path: '/dijkstra-visualizer',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider<ToolSelectionCubit>(
                  create: (_) => ToolSelectionCubit(
                    const ToolSelectionState(),
                  ),
                ),
                BlocProvider<GraphBloc>(
                  create: (_) => GraphBloc(),
                ),
                BlocProvider<AnimationBloc>(
                  create: (_) => AnimationBloc(),
                ),
              ],
              child: const DijkstraScreen(),
            ),
          ),
          GoRoute(
            path: '/a-star-visualizer',
            parentNavigatorKey: _shellNavigatorKey,
            builder: (context, state) => const AStarScreen(),
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D4154),
          brightness: Brightness.light,
          primary: const Color(0xFF2D4154),
          secondary: Colors.deepOrange,
          secondaryContainer: Colors.deepOrange.shade50,
          surface: const Color(0xFFF8F5F2),
        ),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          Visibility(
            visible: context.watch<SidebarCubit>().state.isOpen,
            child: const Sidebar(),
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
