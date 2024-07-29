import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    var defaultOutlineBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(16.0),
    );

    return SizedBox(
      width: 250.0,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.black12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: IconButton(
                onPressed: () {},
                tooltip: 'Close sidebar',
                icon: const Icon(Icons.menu_open_outlined),
              ),
            ),
            SizedBox(
              height: 40.0,
              child: TextField(
                decoration: InputDecoration(
                  enabledBorder: defaultOutlineBorder,
                  focusedBorder: defaultOutlineBorder,
                  border: defaultOutlineBorder,
                  hintText: 'Filter algorithms',
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  fillColor: Colors.black12,
                  filled: true,
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Expanded(
              child: ListView(
                children: [
                  SidebarList(
                    name: 'Dijkstra\'s algorithm',
                    onTap: () {
                      context.go('/dijkstra-visualizer');
                    },
                  ),
                  SidebarList(
                    name: 'A (A-star) Algorithm*',
                    onTap: () {
                      context.go('/a-star-visualizer');
                    },
                  ),
                  SidebarList(name: 'Bellman-Ford Algorithm', onTap: () {},),
                  SidebarList(name: 'Floyd-Warshall Algorithm', onTap: () {},),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SidebarList extends StatelessWidget {
  const SidebarList({super.key, required this.name, required this.onTap});

  final String name;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    // return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), child: Text(name),);
    return InkWell(
      onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), child: Text(name),),
    );
  }
}
