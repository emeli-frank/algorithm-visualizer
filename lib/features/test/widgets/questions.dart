import 'package:algorithm_visualizer/features/test/models/graph_test.dart';
import 'package:flutter/material.dart';

class Questions extends StatelessWidget {
  const Questions({super.key, required this.question, required this.imagePath, required this.data, required this.startVertex});

  final String question;
  final String imagePath;
  final Map<String, GraphTableData> data;
  final String startVertex;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(question),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Image.asset(imagePath),
              ),
              const SizedBox(width: 24.0),
              Expanded(
                flex: 3,
                child: TestVisualizationStateTable(data: data, startVertex: startVertex),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class TestVisualizationStateTable extends StatelessWidget {
  const TestVisualizationStateTable({super.key, required this.data, required this.startVertex});

  final Map<String, GraphTableData> data;
  final String startVertex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Cell(child: Text('Vertex'),),
            Cell(child: Text('Shortest Distance from $startVertex')),
            const Cell(child: Text('Previous'),),
          ],
        ),
        const SizedBox(height: 8.0),
        _buildTable(data: data),
      ],
    );
  }

  Widget _buildTable({required Map<String, GraphTableData> data}) {
    List<Widget> rows = [];

    for (String vertex in data.keys) {
      rows.add(
          Row(
            children: [
              Cell(child: Text(vertex),),
              Cell(
                child: TextField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
              Cell(
                child: TextField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          )
      );
    }

    return Column(
      children: rows,
    );
  }
}

class Cell extends StatelessWidget {
  const Cell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.0,
      child: Center(
        child: child,
      ),
    );
  }
}
