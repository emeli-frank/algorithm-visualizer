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
      _initializeDijkstra(emit, state, event);
    });

    on<AnimationEnded>((AnimationEnded event, Emitter<AnimationState> emit) async {
      emit(state.copyWith(
        isRunning: false,
        isComplete: true,
        currentEdge: const Optional<Edge?>(null),
        currentVertex: const Optional<Vertex?>(null),
        currVertexEdges: [],
        edges: [],
        vertices: [],
        distances: {},
        previousVertices: {},
      ));
    });

    on<AnimationReset>((AnimationReset event, Emitter<AnimationState> emit) async {
      emit(state.copyWith(
        isRunning: false,
        isComplete: true,
        currentEdge: const Optional<Edge?>(null),
        currentVertex: const Optional<Vertex?>(null),
        currVertexEdges: [],
        edges: [],
        vertices: [],
        distances: {},
        previousVertices: {},
      ));
    });

    on<AnimationNextStep>((event, emit) {
      _processNextStep(event, emit, state);
    });
  }

  late List<Vertex> vertices;
  late List<Edge> edges;
  late Vertex currentVertex;
  late Set<Vertex> unvisitedVertices;
  Edge? currentEdge;
  List<Edge>? currVertexEdges;

  void _initializeDijkstra(Emitter<AnimationState> emit, AnimationState state, AnimationStarted event) {
    vertices = event.vertices;
    edges = event.edges;
    currentVertex = event.startVertex;
    unvisitedVertices = Set<Vertex>.from(vertices);

    final Map<Vertex, double> distances = {};
    final Map<Vertex, Vertex?> previousVertices = {};
    for (var vertex in vertices) {
      distances[vertex] = double.infinity;
      previousVertices[vertex] = null;
    }
    distances[currentVertex] = 0;

    emit(state.copyWith(
      previousVertices: previousVertices,
      distances: distances,
      isRunning: true,
      isComplete: false,
      step: const Optional<AnimationStep>(AnimationStep.findingCurrentVertex)),
    );
  }

  void _findCurrentVertex(AnimationState state, Emitter<AnimationState> emit) {
    // Find the unvisited vertex with the smallest distance
    final distances = {...state.distances};
    currentVertex = unvisitedVertices.reduce((a, b) {
      return distances[a]! < distances[b]! ? a : b;
    });

    // Remove the current vertex from the unvisited set
    unvisitedVertices.remove(currentVertex);

    emit(state.copyWith(
      currentEdge: const Optional<Edge?>(null), // clear previous if existing
      currVertexEdges: [], // clear previous if existing
      currentVertex: Optional<Vertex>(currentVertex),
      step: const Optional<AnimationStep>(AnimationStep.findingCurrentEdges)),
    );
  }

  void _findCurrentEdges(Emitter<AnimationState> emit) {
    // Get all the edges starting from the current vertex
    currVertexEdges =
        edges.where((edge) => edge.startVertex == currentVertex).toList();

    emit(state.copyWith(
        currVertexEdges: currVertexEdges,
        step: const Optional<AnimationStep>(AnimationStep.findingCurrentEdge),
    ));
  }

  void _findCurrentEdge(AnimationState state, Emitter<AnimationState> emit) {
    Optional<AnimationStep>? nextStep;
    if (currVertexEdges!.length <= 1) {
      nextStep = const Optional<AnimationStep>(AnimationStep.processingNextStep);
      if (currVertexEdges!.isEmpty) {
        emit(state.copyWith(
          currentEdge: Optional<Edge>(currentEdge!),
          step: nextStep,
        ));
        return;
      }
    }

    currentEdge = currVertexEdges!.removeAt(0);

    final neighbor = currentEdge!.endVertex;
    if (!unvisitedVertices.contains(neighbor)) {
      emit(state.copyWith(currentEdge: const Optional<Edge?>(null)));
      return;
    }

    final distances = {...state.distances};
    final previousVertices = {...state.previousVertices};
    final newDist = distances[currentVertex]! + currentEdge!.weight;

    // If the new distance is shorter
    if (newDist < distances[neighbor]!) {
      distances[neighbor] = newDist;
      previousVertices[neighbor] = currentVertex;
    }

    emit(state.copyWith(
      distances: distances,
      previousVertices: previousVertices,
      currentEdge: Optional<Edge>(currentEdge!),
      step: nextStep,
    ));
  }

  void _processNextStep(AnimationNextStep event, Emitter<AnimationState> emit, AnimationState state) {
    if (unvisitedVertices.isEmpty) { // todo:: see if to put the logic at the end
      emit(state.copyWith(isComplete: true));
      return;
    }

    AnimationStep step = state.step;
    if (state.step == AnimationStep.processingNextStep) {
      step = AnimationStep.findingCurrentVertex;
    }

    switch(step) {
      case AnimationStep.findingCurrentVertex:
        _findCurrentVertex(state, emit);
        break;
      case AnimationStep.findingCurrentEdges:
        _findCurrentEdges(emit);
        break;
      case AnimationStep.findingCurrentEdge:
        _findCurrentEdge(state, emit);
        break;
      case AnimationStep.processingNextStep:
        _processNextStep(event, emit, state);
        break;
      case AnimationStep.complete:
        break;
    }

    // If there are no more vertices to visit, the algorithm is complete
    /*if (unvisitedVertices.isEmpty) {
      emit(state.copyWith(isComplete: true));
    }*/
  }
}
