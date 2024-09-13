import 'package:algorithm_visualizer/features/sidebar/cubit/sidebar_cubit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/nav_icon_button.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
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
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                height: 38.0,
                child: TextField(
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Filter algorithms',
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                    hintStyle: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Expanded(
              child: ListView(
                children: [
                  const SidebarSectionTitle(title: 'ALGORITHMS'),
                  SidebarListItem(
                    name: 'Dijkstra\'s algorithm',
                    onTap: () {
                      context.go('/dijkstra-visualizer');
                    },
                  ),
                  SidebarListItem(
                    name: 'A (A-star) Algorithm*',
                    onTap: () {
                      context.go('/a-star-visualizer');
                    },
                  ),
                  const SizedBox(height: 24.0),
                  const SidebarSectionTitle(title: 'TESTS'),
                  SidebarListItem(
                    name: 'Pre-test',
                    onTap: () {
                      context.go('/test');
                    },
                  ),
                  SidebarListItem(
                    name: 'Post-test',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SidebarListItem extends StatelessWidget {
  const SidebarListItem({super.key, required this.name, required this.onTap});

  final String name;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    // return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), child: Text(name),);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Text(
          name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
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

