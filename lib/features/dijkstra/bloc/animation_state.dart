part of 'animation_bloc.dart';

class AnimationState extends Equatable {
  AnimationState({
    vertices,
    edges,
    this.currentVertex,
    this.currentEdge,
    this.currVertexEdges = const [],
  }) : vertices = vertices ?? [], edges = edges ?? [];

  final List<Vertex> vertices;
  final List<Edge> edges;
  final Vertex? currentVertex;
  final List<Edge> currVertexEdges;
  final Edge? currentEdge;

  @override
  List<Object?> get props => [
    vertices,
    edges,
    currentVertex,
    currentEdge,
    currVertexEdges,
  ];

  AnimationState copyWith({
    List<Vertex>? vertices,
    List<Edge>? edges,
    Optional<Vertex?>? currentVertex,
    Optional<Edge?>? currentEdge,
    List<Edge>? currVertexEdges,
  }) {
    return AnimationState(
      vertices: vertices ?? this.vertices,
      edges: edges ?? this.edges,
      currentVertex: currentVertex == null ? this.currentVertex : currentVertex.value,
      currentEdge: currentEdge == null ? this.currentEdge : currentEdge.value,
      currVertexEdges: currVertexEdges ?? this.currVertexEdges,
    );
  }
}
