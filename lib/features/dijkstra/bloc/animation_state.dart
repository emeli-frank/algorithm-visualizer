part of 'animation_bloc.dart';

class AnimationState extends Equatable {
  AnimationState({
    vertices,
    edges,
    this.highlightedVertex,
    this.highlightedEdges = const [],
  }) : vertices = vertices ?? [], edges = edges ?? [];

  final List<Vertex> vertices;
  final List<Edge> edges;
  final Vertex? highlightedVertex;
  final List<Edge> highlightedEdges;

  @override
  List<Object?> get props => [
    vertices,
    edges,
    highlightedVertex,
    highlightedEdges,
  ];

  AnimationState copyWith({
    List<Vertex>? vertices,
    List<Edge>? edges,
    Optional<Vertex?>? highlightedVertex,
    List<Edge>? highlightedEdges,
  }) {
    return AnimationState(
      vertices: vertices ?? this.vertices,
      edges: edges ?? this.edges,
      highlightedVertex: highlightedVertex == null ? this.highlightedVertex : highlightedVertex.value,
      highlightedEdges: highlightedEdges ?? this.highlightedEdges,
    );
  }
}
