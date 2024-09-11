import 'package:algorithm_visualizer/features/dijkstra/bloc/animation_bloc.dart';
import 'package:algorithm_visualizer/features/dijkstra/bloc/graph_bloc.dart';
import 'package:algorithm_visualizer/features/dijkstra/widgets/vertex_text_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VisualizationInfo extends StatelessWidget {
  const VisualizationInfo({super.key});

  @override
  Widget build(BuildContext context) {
    Widget instructionWidgetChild = Container();

    if (context.watch<GraphBloc>().state.vertices.length < 2) {
      instructionWidgetChild = const Text('Add at least two vertices to begin.');
    } else if (!context.watch<AnimationBloc>().state.isRunning) {
      instructionWidgetChild = const Text('Select a start vertex and click the start button below to begin.');
    } else if (context.read<GraphBloc>().state.vertices.length < 2) {
      instructionWidgetChild = const Text('Add at least two vertices to begin.');
    } else if (!context.read<AnimationBloc>().state.distances.values.any((element) => element != double.infinity) && context.read<AnimationBloc>().state.isRunning) {
      instructionWidgetChild = RichText(
        text: TextSpan(
          style: const TextStyle(
            height: 1.5,
            color: Colors.black,
          ),
          children: [
            const TextSpan(
              text: 'A table showing the distances from the start vertex to each vertex has been created. Currently, the distances from the starting vertex ',
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: VertexTextLabel(label: '${context.read<AnimationBloc>().state.startVertex?.label}'),
            ),
            const TextSpan(
              text: ' to all other vertices are set to infinity, as they have not yet been determined. Since ',
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: VertexTextLabel(label: '${context.read<AnimationBloc>().state.startVertex?.label}'),
            ),
            const TextSpan(
              text: ' is the starting vertex, its distance is set to 0. On the table, the "Shortest distance" column displays the current distance from the starting vertex to each vertex, and the "Previous vertex" column indicates the vertex that precedes each one in the shortest path.',
            ),
          ],
        ),
      );
    } else if (context.read<AnimationBloc>().state.currentNeighbor != null &&
        context.read<AnimationBloc>().state.step == AnimationStep.findingCurrentEdge2) {
      final currentVertex = context.read<AnimationBloc>().state.currentVertex;
      final currentNeighbor = context.read<AnimationBloc>().state.currentNeighbor;
      final currentEdge = context.read<AnimationBloc>().state.currentEdge;
      final distances = context.read<AnimationBloc>().state.distances;
      final tentativeDistance = distances[currentVertex]! + currentEdge!.weight;

      List<InlineSpan> changeInfo;

      if (distances[currentNeighbor]! > tentativeDistance) {
        changeInfo = [
          const TextSpan(
            text: ' Since this tentative distance is less than the current distance of vertex ',
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: VertexTextLabel(label: currentNeighbor!.label, color: Colors.green.shade300,),
          ),
          const TextSpan(
            text: ', the distance of vertex ',
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: VertexTextLabel(label: currentNeighbor.label, color: Colors.green.shade300,),
          ),
          const TextSpan(
            text: ' will be updated to ',
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Text('${tentativeDistance.toStringAsFixed(0)}.'),
          ),
        ];
      } else {
        changeInfo = [
          const TextSpan(
            text: ' Since this tentative distance is not less than the current distance of vertex ',
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: VertexTextLabel(label: currentNeighbor!.label, color: Colors.green.shade300,),
          ),
          const TextSpan(
            text: ', the distance of vertex ',
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: VertexTextLabel(label: currentNeighbor.label, color: Colors.green.shade300,),
          ),
          const TextSpan(
            text: ' will remain unchanged.',
          ),
        ];
      }

      instructionWidgetChild = Column(
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                height: 1.5,
                color: Colors.black,
              ),
              children: [
                const TextSpan(
                  text: 'The new tentative distance is the sum of the current total distance of vertex ',
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: VertexTextLabel(label: currentVertex!.label, color: Colors.green.shade300,),
                ),
                const TextSpan(
                  text: ' which is ',
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Text(distances[currentVertex]!.toStringAsFixed(0)),
                ),
                const TextSpan(
                  text: ', and the edge weight of vertex ',
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: VertexTextLabel(label: currentNeighbor.label, color: Colors.yellow.shade300,),
                ),
                const TextSpan(
                  text: ' , which is ',
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Text(currentEdge.weight.toStringAsFixed(0)),
                ),
                const TextSpan(
                  text: ', resulting in ',
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Text(tentativeDistance.toStringAsFixed(0)),
                ),
                const TextSpan(
                  text: '.',
                ),
                ...changeInfo,
              ],
            ),
          ),
        ],
      );
    } else if (context.read<AnimationBloc>().state.currentNeighbor != null &&
        context.read<AnimationBloc>().state.step == AnimationStep.findingCurrentEdge) {
      final currentVertex = context.read<AnimationBloc>().state.currentVertex;
      final currentNeighbor = context.read<AnimationBloc>().state.currentNeighbor;
      final currentEdge = context.read<AnimationBloc>().state.currentEdge;
      final distances = context.read<AnimationBloc>().state.distances;
      final tentativeDistance = distances[currentVertex]! + currentEdge!.weight;

      var isLastNeighbor = false;
      var neighbors = context.read<AnimationBloc>().state.neighbors;
      if (neighbors.isNotEmpty && neighbors.last == currentNeighbor) {
        isLastNeighbor = true;
      }

      instructionWidgetChild = RichText(
        text: TextSpan(
          style: const TextStyle(
            height: 1.5,
            color: Colors.black,
          ),
          children: [
            const TextSpan(
              text: 'The tentative distance of vertex ',
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: VertexTextLabel(label: '${currentNeighbor?.label}', color: Colors.yellow.shade300,),
            ),
            TextSpan(
              text: context.read<AnimationBloc>().state.tentativeDistanceUpdated ?? false ? ' has been updated to ${tentativeDistance.toStringAsFixed(0)} and the previous vertex has been set to ' : ' remains unchanged. ',
            ),
            if (context.read<AnimationBloc>().state.tentativeDistanceUpdated ?? false)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: VertexTextLabel(label: '${currentVertex?.label}', color: Colors.green.shade300,),
              ),
            if (context.read<AnimationBloc>().state.tentativeDistanceUpdated ?? false)
              const TextSpan(
                text: '.',
              ),
            if (!isLastNeighbor)
              const TextSpan(
                text: ' The algorithm will now move to the next neighbouring vertex.',
              ),
          ],
        ),
      );
    } else if (context.read<AnimationBloc>().state.currVertexEdges.isNotEmpty) {
      final currentVertex = context.read<AnimationBloc>().state.currentVertex;
      final neighbors = context.read<AnimationBloc>().state.neighbors;
      if (neighbors.isEmpty) {
        instructionWidgetChild = RichText(
          text: TextSpan(
            style: const TextStyle(
              height: 1.5,
              color: Colors.black,
            ),
            children: [
              const TextSpan(
                text: 'The current vertex ',
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: VertexTextLabel(label: '${currentVertex?.label}', color: Colors.green.shade300,),
              ),
              const TextSpan(
                text: ' has no neighbors. The algorithm will now find the next vertex to visit.',
              ),
            ],
          ),
        );
      } else {
        List<InlineSpan> neighborWidgets = [];

        for (var i = 0; i < neighbors.length; i++) {
          neighborWidgets.add(
            WidgetSpan(
              child: VertexTextLabel(
                label: neighbors[i].label,
                color: Colors.yellow.shade300,
              ),
            ),
          );

          if (i != neighbors.length - 1) { // neither the first nor the last element
            neighborWidgets.add(const TextSpan(text: ', '));
          }

          if (neighbors.length > 1 && i == neighbors.length - 2) { // last element
            neighborWidgets.add(const TextSpan(text: ' and '));
            continue;
          }
        }

        instructionWidgetChild = RichText(
          text: TextSpan(
            style: const TextStyle(
              height: 1.5,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: 'The ${neighbors.length > 1 ? 'neighbors' : 'neighbor'} ',
              ),
              ...neighborWidgets,
              const TextSpan(
                text: ' of the current vertex ',
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: VertexTextLabel(label: '${currentVertex?.label}', color: Colors.green.shade300,),
              ),
              TextSpan(
                text: ' ${neighbors.length > 1 ? 'are' : 'is'} highlighted. ${neighbors.length > 1 ? 'These vertices are' : 'This vertex is'} directly connected to ',
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: VertexTextLabel(label: '${currentVertex?.label}', color: Colors.green.shade300,),
              ),
              TextSpan(
                text: ' via ${neighbors.length > 1 ? 'edges' : 'an edge'}. The algorithm will now calculate the tentative shortest path to each of these neighbors.',
              ),
            ],
          ),
        );
      }
    } else if (context.read<AnimationBloc>().state.step == AnimationStep.findingCurrentVertex &&
        context.read<AnimationBloc>().state.currentEdge == null &&
        context.read<AnimationBloc>().state.currentNeighbor == null) {
      instructionWidgetChild = RichText(
        text: TextSpan(
          style: const TextStyle(
            height: 1.5,
            color: Colors.black,
          ),
          children: [
            const TextSpan(
              text: 'The vertex ',
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: VertexTextLabel(label: '${context.read<AnimationBloc>().state.currentVertex?.label}', color: Colors.green.shade300,),
            ),
            const TextSpan(
              text: ' and its neighbors have been evaluated. It will be grayed out in the next step to indicate that it has been visited. The algorithm will now find the next vertex to visit.',
            ),
          ],
        ),
      );
    } else if (context.read<AnimationBloc>().state.currentVertex != null) {
      instructionWidgetChild = RichText(
        text: TextSpan(
          style: const TextStyle(
            height: 1.5,
            color: Colors.black,
          ),
          children: [
            const TextSpan(
              text: 'The vertex ',
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: VertexTextLabel(label: '${context.read<AnimationBloc>().state.currentVertex?.label}', color: Colors.green.shade300,),
            ),
            const TextSpan(
              text: ' is selected as it is the unvisited vertex with the smallest known distance. It is now the current point of consideration. The algorithm will evaluate the shortest path from this vertex to its neighboring vertices.',
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, bottom: 20.0, right: 12.0, top: 4.0),
      child: instructionWidgetChild,
    );
  }
}
