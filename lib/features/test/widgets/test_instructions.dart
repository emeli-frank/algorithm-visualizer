import 'package:flutter/material.dart';

class TestInstructions extends StatelessWidget {
  const TestInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 36.0),
        Text(
          textAlign: TextAlign.center,
          'Welcome to the test section. You will be presented with a series of questions related to the Dijkstra\'s graph traversal. Please answer them to the best of your ability.',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 36.0),
            Text(
                'Quick tips:'
            ),
            SizedBox(height: 16.0,),
            InfoItem(text: 'The circular shapes represent vertices in the graph. These could be cities, towns, or any other location.'),
            InfoItem(text: 'The lines connecting the vertices represent the edges between them. These could be roads, rivers, or any other form of connection.'),
            InfoItem(text: 'The numbers on the edges represent the distance between the vertices.'),
            InfoItem(text: 'Vertices represented in faint green colour have been previously visited.'),
            InfoItem(text: 'Vertices in green colour are the ones that are currently being visited.'),
            InfoItem(text: 'Vertices in yellow colour are the neighbouring vertices that are yet to be visited.'),
          ],
        ),
      ],
    );
  }
}

class InfoItem extends StatelessWidget {
  final String text;

  const InfoItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const SizedBox(height: 8.0),
              Icon(Icons.circle, size: 6.0, color: Theme.of(context).colorScheme.primary),
            ],
          ),
          const SizedBox(width: 10.0),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
