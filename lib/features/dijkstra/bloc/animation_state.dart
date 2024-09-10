part of 'animation_bloc.dart';

enum AnimationStep {
  initStartVertex,
  findingCurrentVertex,
  findingCurrentEdges,
  findingCurrentEdge,
  findingCurrentEdge2,
  complete,
}

class AnimationState extends Equatable {
  AnimationState({
    List<Vertex>? vertices,
    List<Edge>? edges,
    this.currentVertex,
    this.currentEdge,
    this.currVertexEdges = const [],
    this.neighbors = const [],
    this.currentNeighbor,
    this.step = AnimationStep.findingCurrentVertex,
    this.isComplete = false,
    this.isRunning = false,
    this.distances = const {},
    this.previousVertices = const {},
    unvisitedVertices,
    this.visitedEdges = const [],
    this.startVertex,
    this.tentativeDistanceUpdated,
  })  : vertices = vertices ?? [],
        edges = edges ?? [],
        unvisitedVertices = unvisitedVertices ?? Set<Vertex>.from(vertices ?? []);

  final List<Vertex> vertices;
  final List<Edge> edges;
  final Vertex? currentVertex;
  final List<Edge> currVertexEdges;
  final Edge? currentEdge;
  final List<Vertex> neighbors;
  final Vertex? currentNeighbor;
  final AnimationStep step;
  final bool isComplete;
  final bool isRunning;
  final Map<Vertex, double> distances;
  final Map<Vertex, Vertex?> previousVertices;
  final Set<Vertex> unvisitedVertices;
  final List<Edge> visitedEdges;
  final Vertex? startVertex;
  final bool? tentativeDistanceUpdated;

  @override
  List<Object?> get props => [
    vertices,
    edges,
    currentVertex,
    currentEdge,
    currVertexEdges,
    step,
    isComplete,
    isRunning,
    distances,
    previousVertices,
    neighbors,
    currentNeighbor,
    unvisitedVertices,
    visitedEdges,
    startVertex,
    tentativeDistanceUpdated,
  ];

  AnimationState copyWith({
    List<Vertex>? vertices,
    List<Edge>? edges,
    Optional<Vertex?>? currentVertex,
    Optional<Edge?>? currentEdge,
    List<Edge>? currVertexEdges,
    Optional<AnimationStep>? step,
    bool? isComplete,
    bool? isRunning,
    Map<Vertex, double>? distances,
    Map<Vertex, Vertex?>? previousVertices,
    List<Vertex>? neighbors,
    Optional<Vertex?>? currentNeighbor,
    Set<Vertex>? unvisitedVertices,
    List<Edge>? visitedEdges,
    Optional<Vertex?>? startVertex,
    Optional<bool>? tentativeDistanceUpdated,
  }) {
    return AnimationState(
      vertices: vertices ?? this.vertices,
      edges: edges ?? this.edges,
      currentVertex: currentVertex == null ? this.currentVertex : currentVertex.value,
      currentEdge: currentEdge == null ? this.currentEdge : currentEdge.value,
      currVertexEdges: currVertexEdges ?? this.currVertexEdges,
      step: step == null ? this.step : step.value,
      isComplete: isComplete ?? this.isComplete,
      isRunning: isRunning ?? this.isRunning,
      distances: distances ?? this.distances,
      previousVertices: previousVertices ?? this.previousVertices,
      neighbors: neighbors ?? this.neighbors,
      currentNeighbor: currentNeighbor == null ? this.currentNeighbor : currentNeighbor.value,
      unvisitedVertices: unvisitedVertices ?? this.unvisitedVertices,
      visitedEdges: visitedEdges ?? this.visitedEdges,
      startVertex: startVertex == null ? this.startVertex : startVertex.value,
      tentativeDistanceUpdated: tentativeDistanceUpdated == null ? this.tentativeDistanceUpdated : tentativeDistanceUpdated.value,
    );
  }
}
