import 'package:algorithm_visualizer/features/dijkstra/models/edge.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'animation_state.dart';
part 'animation_event.dart';

class AnimationBloc extends Bloc<AnimationEvent, AnimationState> {
  AnimationBloc() : super(AnimationState()) {
    on<AnimationStarted>((AnimationStarted event, Emitter<AnimationState> emit) {
      final result = _dijkstra(event.startVertex, event.vertices, event.edges);
      print('result: \n$result');
    });
  }

  Result _dijkstra(Vertex startVertex, List<Vertex> vertices, List<Edge> edges) {
    final distances = <Vertex, double>{};
    final previousVertices = <Vertex, Vertex?>{};
    final priorityQueue = PriorityQueue<Vertex>(
          (a, b) => distances[a]!.compareTo(distances[b]!),
    );

    // Initialize distances
    for (var vertex in vertices) {
      distances[vertex] = double.infinity;
      previousVertices[vertex] = null;
    }
    distances[startVertex] = 0;

    // Add all vertices to the priority queue
    priorityQueue.addAll(vertices);

    while (priorityQueue.isNotEmpty) {
      final currentVertex = priorityQueue.removeFirst();

      // Get all the edges starting from the current vertex
      final currentEdges = edges.where((edge) =>
      edge.startVertex == currentVertex);

      for (var edge in currentEdges) {
        final neighbor = edge.endVertex;
        final newDist = distances[currentVertex]! + edge.weight;

        // If the new distance is shorter
        if (newDist < distances[neighbor]!) {
          distances[neighbor] = newDist;
          previousVertices[neighbor] = currentVertex;

          // Update the priority queue with the new distance
          priorityQueue.remove(neighbor);
          priorityQueue.add(neighbor);
        }
      }
    }

    return Result(distances, previousVertices);
  }
}

class Result {
  final Map<Vertex, double> distances;
  final Map<Vertex, Vertex?> previousVertices;

  Result(this.distances, this.previousVertices);

  @override
  String toString() {
    String output = 'Vertex, Distance, Previous';
    for (var i = 0; i < distances.length; i++) {
      output += '\n${distances.keys.elementAt(i).id},      '
          '${distances.values.elementAt(i)},      '
          '${previousVertices.values.elementAt(i)?.id ?? 'null'}';
    }
    return output;
  }
}
