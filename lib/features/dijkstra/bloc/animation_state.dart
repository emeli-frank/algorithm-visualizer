part of 'animation_bloc.dart';

enum AnimationStep {
  findingCurrentVertex,
  findingCurrentEdges,
  findingCurrentEdge,
  processingNextStep,
  complete,
}

class AnimationState extends Equatable {
  AnimationState({
    vertices,
    edges,
    this.currentVertex,
    this.currentEdge,
    this.currVertexEdges = const [],
    this.step = AnimationStep.findingCurrentVertex,
    this.isComplete = false,
    this.isRunning = false,
  }) : vertices = vertices ?? [], edges = edges ?? [];

  final List<Vertex> vertices;
  final List<Edge> edges;
  final Vertex? currentVertex;
  final List<Edge> currVertexEdges;
  final Edge? currentEdge;
  final AnimationStep step;
  final bool isComplete;
  final bool isRunning;

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
    );
  }
}
