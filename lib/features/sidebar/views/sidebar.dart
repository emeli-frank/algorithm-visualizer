import 'package:algorithm_visualizer/features/sidebar/cubit/sidebar_cubit.dart';
import 'package:algorithm_visualizer/features/test/bloc/test_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/nav_icon_button.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUrl = GoRouter.of(context).routerDelegate.currentConfiguration.fullPath;

    List<Widget> sidebarItems = [
      const SidebarSectionTitle(title: 'ALGORITHMS'),
      SidebarListItem(
        name: 'Dijkstra\'s algorithm',
        onTap: () {
          context.go('/dijkstra-visualizer');
        },
      ),
      /*SidebarListItem(
                    name: 'A (A-star) Algorithm*',
                    onTap: () {
                      context.go('/a-star-visualizer');
                    },
                  ),*/
      const SizedBox(height: 24.0),
      const SidebarSectionTitle(title: 'TESTS'),
      SidebarListItem(
        name: 'Pre-test',
        isInactive: context.watch<TestBloc>().state.preTestCompleted,
        onTap: () {
          context.go('/test/pre-test');
        },
      ),
      SidebarListItem(
        name: 'Post-test',
        isInactive: !context.watch<TestBloc>().state.preTestCompleted || context.watch<TestBloc>().state.postTestCompleted,
        onTap: () {
          context.go('/test/post-test');
        },
      ),
    ];

    final query = context.watch<SidebarCubit>().state.query;
    List<Widget> filteredSidebarItems = sidebarItems.where((element) {
      if (element is SidebarListItem) {
        return element.name.toLowerCase().contains(query.toLowerCase());
      }
      return true;
    }).toList();

    return SizedBox(
      width: 220.0,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NavIconButton(
              iconData: Icons.close,
              onPressed: () {
                context.read<SidebarCubit>().toggle(isOpen: false);
              },
              tooltip: 'Close sidebar',
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                height: 38.0,
                child: TextField(
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                    hintStyle: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  onChanged: (value) {
                    context.read<SidebarCubit>().filter(query: value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Expanded(
              child: ListView(
                children: filteredSidebarItems,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SidebarListItem extends StatelessWidget {
  const SidebarListItem({super.key, required this.name, required this.onTap, this.isInactive = false, this.isSelected = false});

  final String name;
  final Function() onTap;
  final bool isSelected;
  final bool isInactive;

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (isInactive) {
      color = Theme.of(context).colorScheme.primary.withOpacity(0.5);
    } else {
      if (isSelected) {
        color = Theme.of(context).colorScheme.secondary;
      } else {
        color = Theme.of(context).colorScheme.primary;
      }
    }

    return InkWell(
      onTap: isInactive ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Text(
          name,
          style: TextStyle(
            color: color,
          ),
        ),
      ),
    );
  }
}

class SidebarSectionTitle extends StatelessWidget {
  const SidebarSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 8.0, left: 8.0, bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

