import 'package:algorithm_visualizer/features/dijkstra/bloc/animation_bloc.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VisualizationStateTable extends StatelessWidget {
  const VisualizationStateTable({super.key});

  @override
  Widget build(BuildContext context) {
    final currentVertex = context.watch<AnimationBloc>().state.currentVertex;
    final startVertex = context.watch<AnimationBloc>().state.startVertex;

    return Column(
      children: [
        Row(
          children: [
            const Cell(label: 'Vertex', fontSize: 11.0, weight: FontWeight.bold),
            Cell(label: 'Shortest Distance from ${startVertex?.label}', fontSize: 11.0, weight: FontWeight.bold),
            const Cell(label: 'Previous', fontSize: 11.0, weight: FontWeight.bold),
          ],
        ),
        const SizedBox(height: 8.0),
        _buildTable(context: context, currentVertex: currentVertex),
      ],
    );
  }

  Widget _buildTable({required BuildContext context, required Vertex? currentVertex}) {
    var distances = context.watch<AnimationBloc>().state.distances;
    var previousVertices = context.watch<AnimationBloc>().state.previousVertices;
    final unVisitedVertices = context.watch<AnimationBloc>().state.unvisitedVertices;
    final currentNeighbor = context.watch<AnimationBloc>().state.currentNeighbor;
    final isComplete = context.watch<AnimationBloc>().state.isComplete;

    List<Widget> rows = [];

    for (int i = 0; i < context.watch<AnimationBloc>().state.distances.length; i++) {
      var distance = distances.values.toList()[i];
      var previous = previousVertices.values.toList()[i];
      var vertex = distances.keys.toList()[i];
      Color textColor = Colors.black;
      Color bgColor = Colors.transparent;

      if (!unVisitedVertices.contains(vertex) && vertex != currentVertex && !isComplete) {

        // Visited vertex
        textColor = Colors.black12;
      } else if (currentVertex != null && currentVertex.id == vertex.id && !isComplete) {

        // Current vertex
        textColor = Colors.green;
        bgColor = textColor.withOpacity(0.1);
      } else if (currentNeighbor != null && currentNeighbor.id == vertex.id && !isComplete) {

        // Current neighbor being evaluated
        textColor = Colors.yellow.shade700;
        bgColor = textColor.withOpacity(0.05);
      }

      rows.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: bgColor,
            ),
            child: Row(
              children: [
                Cell(label: vertex.label, textColor: textColor),
                Cell(label: distance == double.infinity ? '\u221E' : distance.toStringAsFixed(0), textColor: textColor),
                Cell(label: previous?.label ?? 'null', textColor: textColor),
              ],
            ),
          )
      );
    }

    return Column(
      children: rows,
    );
  }
}

class Cell extends StatelessWidget {
  const Cell({super.key, required this.label, this.textColor = Colors.black, this.fontSize = 14.0, this.weight = FontWeight.normal});
  
  final String label;
  final Color textColor;
  final double fontSize;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.0,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: weight,
          ),
        ),
      ),
    );
  }
}

