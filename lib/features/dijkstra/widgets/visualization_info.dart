import 'package:algorithm_visualizer/features/dijkstra/bloc/animation_bloc.dart';
import 'package:algorithm_visualizer/features/dijkstra/bloc/graph_bloc.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/edge.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';
import 'package:algorithm_visualizer/features/dijkstra/widgets/vertex_text_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VisualizationInfo extends StatelessWidget {
  const VisualizationInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final animationState = context.watch<AnimationBloc>().state;

    final distances = animationState.distances;
    final isAnimationRunning = animationState.isRunning;
    final currentNeighbor = animationState.currentNeighbor;
    final graphVertices = context.watch<GraphBloc>().state.vertices;
    final startVertex = animationState.startVertex;
    final step = animationState.step;
    final currentVertex = animationState.currentVertex;
    final currentEdge = animationState.currentEdge;
    var neighbors = animationState.neighbors;
    var isTentativeDistanceUpdated = animationState.tentativeDistanceUpdated ?? false;

    Widget instruction = Container();

    if (graphVertices.length < 2) {

      // Not enough vertices to run the algorithm
      instruction = const Text('Add at least two vertices to begin.');
    } else if (!isAnimationRunning) {

      // Visualization has not started
      instruction = const Text('Select a start vertex and click the start button below to begin.');
    } else if (!distances.values.any((element) => element != double.infinity) && isAnimationRunning) {

      // State table has not be initialized
      instruction = Messages.getTableInitializationMessage(startVertex!);
    } else if (currentNeighbor != null && step == AnimationStep.findingCurrentEdge2) {

      // Tentative distance evaluation
      instruction = Messages.getTentativeDistanceEvaluationMessage(currentVertex!, currentNeighbor, currentEdge!, distances);
    } else if (currentNeighbor != null && step == AnimationStep.findingCurrentEdge) {

      // Tentative distance update notice
      instruction = Messages.getTentativeDistanceUpdateMessage(currentVertex!, currentNeighbor, currentEdge!, distances, isTentativeDistanceUpdated, neighbors);
    } else if (step == AnimationStep.findingCurrentEdge) {

      // Neighbors have been found
      instruction = Messages.getNeighborsFoundMessage(neighbors, currentVertex!);
    } else if (step == AnimationStep.findingCurrentVertex &&
        currentEdge == null &&
        currentNeighbor == null) {

      // Vertex has been visited
      instruction = Messages.getGrayOutMessage(currentVertex!);
    } else if (currentVertex != null) {

      // New vertex to visit
      instruction = Messages.getNewVisitedVertexMessage(currentVertex, startVertex!);
    } else if (animationState.isComplete) {

        // Algorithm has completed
        instruction = const Text('The algorithm has completed. The table now displays the shortest distance from the starting vertex to each vertex, as well as the preceding vertex in the shortest path. Click the "End" button to finish.');
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, bottom: 20.0, right: 12.0, top: 4.0),
      child: instruction,
    );
  }
}

class Messages {
  static Widget getTableInitializationMessage(Vertex startVertex) {
   return RichText(
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
           child: VertexTextLabel(label: startVertex.label),
         ),
         const TextSpan(
           text: ' to all other vertices are set to infinity, as they have not yet been determined. Since ',
         ),
         WidgetSpan(
           alignment: PlaceholderAlignment.middle,
           child: VertexTextLabel(label: startVertex.label),
         ),
         const TextSpan(
           text: ' is the starting vertex, its distance is set to 0. On the table, the "Shortest distance" column displays the current distance from the starting vertex to each vertex, and the "Previous vertex" column indicates the vertex that precedes each one in the shortest path.',
         ),
       ],
     ),
   );
  }

  static Widget getNewVisitedVertexMessage(Vertex currentVertex, Vertex startVertex) {
    return RichText(
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
            child: VertexTextLabel(label: currentVertex.label, color: Colors.green.shade300,),
          ),
          const TextSpan(
            text: ' is selected as it is the unvisited vertex with the smallest known distance from ',
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: VertexTextLabel(label: startVertex.label),
          ),
          const TextSpan(
            text: '. It is now the current point of consideration. The algorithm will evaluate the shortest path from this vertex to its neighboring vertices.',
          ),
        ],
      ),
    );
  }

  static Widget getGrayOutMessage(Vertex currentVertex) {
    return RichText(
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
            child: VertexTextLabel(label: currentVertex.label, color: Colors.green.shade300,),
          ),
          const TextSpan(
            text: ' and its neighbors have been evaluated. It will be grayed out in the next step to indicate that it has been visited. The algorithm will now find the next vertex to visit.',
          ),
        ],
      ),
    );
  }

  static Widget getNeighborsFoundMessage(List<Vertex> neighbors, Vertex currentVertex) {
    if (neighbors.isEmpty) {
      return RichText(
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
              child: VertexTextLabel(label: currentVertex.label, color: Colors.green.shade300,),
            ),
            const TextSpan(
              text: ' has no neighbors so the algorithm will now find the next vertex to visit.',
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

      return RichText(
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
              child: VertexTextLabel(label: currentVertex.label, color: Colors.green.shade300,),
            ),
            TextSpan(
              text: ' ${neighbors.length > 1 ? 'are' : 'is'} highlighted. ${neighbors.length > 1 ? 'These vertices are' : 'This vertex is'} directly connected to ',
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: VertexTextLabel(label: currentVertex.label, color: Colors.green.shade300,),
            ),
            TextSpan(
              text: ' via ${neighbors.length > 1 ? 'edges' : 'an edge'}. The algorithm will now calculate the tentative shortest path to each of these neighbors.',
            ),
          ],
        ),
      );
    }
  }

  static Widget getTentativeDistanceEvaluationMessage(Vertex currentVertex, Vertex currentNeighbor, Edge currentEdge, Map<Vertex, double> distances) {
    final tentativeDistance = distances[currentVertex]! + currentEdge.weight;

    List<InlineSpan> changeInfo;

    if (distances[currentNeighbor]! > tentativeDistance) {
      changeInfo = [
        const TextSpan(
          text: ' Since this tentative distance is less than the current distance of vertex ',
        ),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: VertexTextLabel(label: currentNeighbor.label, color: Colors.green.shade300,),
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
          child: VertexTextLabel(label: currentNeighbor.label, color: Colors.green.shade300,),
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

    return Column(
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
                child: VertexTextLabel(label: currentVertex.label, color: Colors.green.shade300,),
              ),
              const TextSpan(
                text: ' which is ',
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Text(distances[currentVertex]!.toStringAsFixed(0)),
              ),
              const TextSpan(
                text: ', and the weight of the edge to vertex ',
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
  }

  static Widget getTentativeDistanceUpdateMessage(Vertex currentVertex, Vertex currentNeighbor, Edge currentEdge, Map<Vertex, double> distances, bool isTentativeDistanceUpdated, List<Vertex> neighbors) {
    final tentativeDistance = distances[currentVertex]! + currentEdge.weight;

    var isLastNeighbor = false;
    if (neighbors.isNotEmpty && neighbors.last == currentNeighbor) {
      isLastNeighbor = true;
    }

    return RichText(
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
            child: VertexTextLabel(label: currentNeighbor.label, color: Colors.yellow.shade300,),
          ),
          TextSpan(
            text: isTentativeDistanceUpdated ? ' has been updated to ${tentativeDistance.toStringAsFixed(0)} and it\'s previous vertex has been set to ' : ' remains unchanged. ',
          ),
          if (isTentativeDistanceUpdated)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: VertexTextLabel(label: currentVertex.label, color: Colors.green.shade300,),
            ),
          if (isTentativeDistanceUpdated)
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
  }
}
