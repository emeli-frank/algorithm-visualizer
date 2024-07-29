import 'package:flutter/material.dart';

class DijkstraVisualizer extends StatelessWidget {
  const DijkstraVisualizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(),
        DijkstraCanvas(),
      ],
    );
  }
}

class AppBar extends StatelessWidget {
  const AppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 54.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.undo),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.redo),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.pan_tool_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.device_hub_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.linear_scale_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}

class DijkstraCanvas extends StatelessWidget {
  const DijkstraCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
