import 'package:algorithm_visualizer/features/dijkstra/bloc/animation_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VisualizationStateTable extends StatelessWidget {
  const VisualizationStateTable({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: context.watch<AnimationBloc>().state.distances.length,
      itemBuilder: (context, index) {
        var distance = context.watch<AnimationBloc>().state.distances.values.toList()[index];
        var previous = context.watch<AnimationBloc>().state.previousVertices.values.toList()[index];
        var vertex = context.watch<AnimationBloc>().state.distances.keys.toList()[index];
        final visitedVertices = context.watch<AnimationBloc>().state.visitedEdges.map((e) => e.startVertex).toSet();
        final currentVertex = context.watch<AnimationBloc>().state.currentVertex;
        final currentNeighbor = context.watch<AnimationBloc>().state.currentNeighbor;
        Color textColor;
        Color color = Colors.transparent;

        if (visitedVertices.contains(vertex)) {
          textColor = Colors.black12;
        } else if (currentVertex != null && currentVertex.id == vertex.id) {
          textColor = Colors.green;
          color = textColor.withOpacity(0.1);
        } else if (currentNeighbor != null && currentNeighbor.id == vertex.id) {
          textColor = Colors.yellow.shade700;
          color = textColor.withOpacity(0.05);
        } else {
          textColor = Colors.black;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: color,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40.0,
                child: Center(
                  child: Text(
                    vertex.label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 40.0,
                child: Center(
                  child: Text(
                    distance == double.infinity ? '\u221E' : distance.toStringAsFixed(0),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 40.0,
                child: Center(
                  child: Text(
                    previous?.label ?? 'null',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
