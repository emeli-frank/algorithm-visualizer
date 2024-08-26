import 'package:algorithm_visualizer/features/dijkstra/models/edge.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';
import 'package:algorithm_visualizer/models/optional.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'animation_state.dart';
part 'animation_event.dart';

class AnimationBloc extends Bloc<AnimationEvent, AnimationState> {
  AnimationBloc() : super(AnimationState()) {
    on<AnimationStarted>((AnimationStarted event, Emitter<AnimationState> emit) async {
      final result = await _dijkstra(emit, event.startVertex, event.vertices, event.edges);
      print(result);
    });
  }

  Future<Result> _dijkstra(
      Emitter<AnimationState> emit,
      Vertex startVertex,
      List<Vertex> vertices,
      List<Edge> edges) async {

    const delayDuration = Duration(milliseconds: 1000); // todo:: obtain from use input
    final distances = <Vertex, double>{};
    final previousVertices = <Vertex, Vertex?>{};
    final unvisitedVertices = Set<Vertex>.from(vertices);

    // Initialize distances
    for (var vertex in vertices) {
      distances[vertex] = double.infinity;
      previousVertices[vertex] = null;
    }
    distances[startVertex] = 0;

    while (unvisitedVertices.isNotEmpty) {
      await Future.delayed(delayDuration);

      // Find the unvisited vertex with the smallest distance
      final currentVertex = unvisitedVertices.reduce((a, b) {
        return distances[a]! < distances[b]! ? a : b;
      });

      emit(state.copyWith(currentVertex: Optional<Vertex>(currentVertex)));
      await Future.delayed(delayDuration);

      // Remove the current vertex from the unvisited set
      unvisitedVertices.remove(currentVertex);

      // Get all the edges starting from the current vertex
      final currentEdges =
          edges.where((edge) => edge.startVertex == currentVertex);

      emit(state.copyWith(currVertexEdges: currentEdges.toList()));
      await Future.delayed(delayDuration);

      for (var edge in currentEdges) {
        emit(state.copyWith(currentEdge: Optional<Edge>(edge)));
        await Future.delayed(delayDuration);

        final neighbor = edge.endVertex; // todo:: maybe set this dynamically
        if (!unvisitedVertices.contains(neighbor)) {
          emit(state.copyWith(currentEdge: const Optional<Edge?>(null)));
          continue;
        }

        final newDist = distances[currentVertex]! + edge.weight;

        // If the new distance is shorter
        if (newDist < distances[neighbor]!) {
          distances[neighbor] = newDist;
          previousVertices[neighbor] = currentVertex;
        }

        emit(state.copyWith(currentEdge: const Optional<Edge?>(null)));
        if (edge != currentEdges.last) {
          await Future.delayed(delayDuration);
        }
      }

      emit(state.copyWith(currVertexEdges: []));
      emit(state.copyWith(currentVertex: const Optional<Vertex?>(null)));
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
