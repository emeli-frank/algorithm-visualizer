import 'package:algorithm_visualizer/features/dijkstra/models/edge.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';
import 'package:algorithm_visualizer/models/optional.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'animation_state.dart';
part 'animation_event.dart';

class AnimationBloc extends Bloc<AnimationEvent, AnimationState> {
  // Stack of previous states
  List<AnimationState> _undoStack = [];

  late List<Vertex> vertices;
  late List<Edge> edges;

  AnimationBloc() : super(AnimationState()) {
    on<AnimationStarted>((AnimationStarted event, Emitter<AnimationState> emit) async {
      _undoStack.add(state);
      emit(state.copyWith(canUndo: _undoStack.isNotEmpty));
      _initializeDijkstra(emit, state, event);
    });

    on<AnimationEnded>((AnimationEnded event, Emitter<AnimationState> emit) async {
      _undoStack = [];
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
        neighbors: [],
        currentNeighbor: const Optional<Vertex?>(null),
        visitedEdges: [],
        tempVisitedEdges: [],
        startVertex: const Optional<Vertex?>(null),
        unvisitedVertices: {},
        tentativeDistanceUpdated: const Optional<bool>(false),
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
        neighbors: [],
        currentNeighbor: const Optional<Vertex?>(null),
        visitedEdges: [],
        tempVisitedEdges: [],
        startVertex: const Optional<Vertex?>(null),
        unvisitedVertices: {},
        tentativeDistanceUpdated: const Optional<bool>(false),
      ));
    });

    on<AnimationNextStep>((event, emit) {
      _undoStack.add(state);
      emit(state.copyWith(canUndo: _undoStack.isNotEmpty));
      _processNextStep(event, emit, state);
    });

    // Undo event handler
    on<AnimationUndoEvent>((event, emit) {
      if (_undoStack.isNotEmpty) {
        // Pop from the undo stack and emit the previous state
        final previousState = _undoStack.removeLast();

        // Emit the previous state and update undo/redo availability
        emit(previousState.copyWith(canUndo: _undoStack.isNotEmpty));
      }
    });
  }

  void _initializeDijkstra(Emitter<AnimationState> emit, AnimationState state, AnimationStarted event) {
    vertices = event.vertices;
    edges = event.edges;
    // currentVertex = event.startVertex;
    final unvisitedVertices = Set<Vertex>.from(vertices);

    final Map<Vertex, double> distances = {};
    final Map<Vertex, Vertex?> previousVertices = {};
    for (var vertex in vertices) {
      distances[vertex] = double.infinity;
      previousVertices[vertex] = null;
    }

    emit(state.copyWith(
      previousVertices: previousVertices,
      distances: distances,
      unvisitedVertices: unvisitedVertices,
      isRunning: true,
      isComplete: false,
      step: const Optional<AnimationStep>(AnimationStep.initStartVertex),
      startVertex: Optional<Vertex>(event.startVertex),
      tempCurrentVertex: event.startVertex,
    ));
  }

  void _initializeStartDistance(Emitter<AnimationState> emit, AnimationState state) {
    var distances = state.distances;
    distances[state.tempCurrentVertex!] = 0;

    emit(state.copyWith(
      distances: distances,
    ));

    _findCurrentVertex(state, emit);
  }

  void _findCurrentVertex(AnimationState state, Emitter<AnimationState> emit) {
    // Find the unvisited vertex with the smallest distance
    final distances = {...state.distances};
    final currentVertex = state.unvisitedVertices.reduce((a, b) {
      return distances[a]! < distances[b]! ? a : b;
    });

    // Remove the current vertex from the unvisited set
    final updatedUnvisitedVertices = {...state.unvisitedVertices};
    updatedUnvisitedVertices.remove(currentVertex);

    emit(state.copyWith(
      currentEdge: const Optional<Edge?>(null), // clear previous if existing
      currVertexEdges: [], // clear previous if existing
      currentVertex: Optional<Vertex>(currentVertex),
      neighbors: [],
      unvisitedVertices: updatedUnvisitedVertices,
      currentNeighbor: const Optional<Vertex?>(null),
      visitedEdges: [...state.visitedEdges, ...state.tempVisitedEdges],
      tempVisitedEdges: [],
      step: const Optional<AnimationStep>(AnimationStep.findingCurrentEdges),
    ));
  }

  void _findCurrentEdges(Emitter<AnimationState> emit) {
    // Get all the edges starting from the current vertex
    final currVertexEdges = edges
        .where((edge) =>
            (state.unvisitedVertices.contains(edge.endVertex) &&
                edge.startVertex == state.currentVertex) ||
            (state.unvisitedVertices.contains(edge.startVertex) &&
                edge.endVertex == state.currentVertex))
        .toList();
    final tempVisitedEdges = [...state.tempVisitedEdges, ...currVertexEdges];

    List<Vertex> neighbors = [];
    for (var edge in currVertexEdges) {
      if (edge.startVertex == state.currentVertex) {
        neighbors.add(edge.endVertex);
      } else {
        neighbors.add(edge.startVertex);
      }
    }

    emit(state.copyWith(
        currVertexEdges: currVertexEdges,
        neighbors: neighbors,
        tempVisitedEdges: tempVisitedEdges,
        step: const Optional<AnimationStep>(AnimationStep.findingCurrentEdge),
    ));
  }

  void _findCurrentEdge(AnimationState state, Emitter<AnimationState> emit) {
    // If dealing with the last edge, set next step to AnimationStep.processingNextStep
    // so that this function is exited in the next iteration
    if (state.currVertexEdges.length <= 1) {
      if (state.currVertexEdges.isEmpty) {
        emit(state.copyWith(
          currentEdge: const Optional(null),
          step: const Optional<AnimationStep>(AnimationStep.findingCurrentVertex),
          currentNeighbor: const Optional<Vertex?>(null),
        ));
        return;
      }
    }

    final currentEdge = state.currVertexEdges.removeAt(0);
    final neighbor = currentEdge.startVertex == state.currentVertex
        ? currentEdge.endVertex
        : currentEdge.startVertex;

    // Set next step to AnimationStep.findingCurrentEdge2 to proceed to sister function
    emit(state.copyWith(
      step: const Optional<AnimationStep>(AnimationStep.findingCurrentEdge2),
      currentNeighbor: Optional(neighbor),
      currentEdge: Optional<Edge?>(currentEdge),
    ));
  }

  void _findCurrentEdge2(AnimationState state, Emitter<AnimationState> emit) {
    final neighbor = state.currentNeighbor!;
    if (!state.unvisitedVertices.contains(neighbor)) {
      emit(state.copyWith(currentEdge: const Optional<Edge?>(null)));
      return;
    }

    final distances = {...state.distances};
    final previousVertices = {...state.previousVertices};
    final newDist = distances[state.currentVertex]! + state.currentEdge!.weight;

    var tentativeDistanceUpdated = false;

    // If the new distance is shorter, update the distance and previous vertex of the neighbor
    if (newDist < distances[neighbor]!) {
      distances[neighbor] = newDist;
      previousVertices[neighbor] = state.currentVertex;
      tentativeDistanceUpdated = true;
    }

    // Continue iteration on edges
    emit(state.copyWith(
      distances: distances,
      previousVertices: previousVertices,
      currentNeighbor: Optional(neighbor),
      step: const Optional<AnimationStep>(AnimationStep.findingCurrentEdge),
      tentativeDistanceUpdated: Optional(tentativeDistanceUpdated),
    ));
  }

  void _processNextStep(AnimationNextStep event, Emitter<AnimationState> emit, AnimationState state) {
    if (state.unvisitedVertices.isEmpty) {
      emit(state.copyWith(
        isComplete: true,
        // isRunning: false,
        currentVertex: const Optional<Vertex?>(null),
      ));
      return;
    }

    switch(state.step) {
      case AnimationStep.initStartVertex:
        _initializeStartDistance(emit, state);
        break;
      case AnimationStep.findingCurrentVertex:
        _findCurrentVertex(state, emit);
        break;
      case AnimationStep.findingCurrentEdges:
        _findCurrentEdges(emit);
        break;
      case AnimationStep.findingCurrentEdge:
        _findCurrentEdge(state, emit);
        break;
      case AnimationStep.findingCurrentEdge2:
        _findCurrentEdge2(state, emit);
        break;
      case AnimationStep.complete:
        break;
    }
  }
}
