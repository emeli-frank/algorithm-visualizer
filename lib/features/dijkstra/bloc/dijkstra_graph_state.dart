part of 'dijkstra_graph_bloc.dart';

class DijkstraGraphState extends Equatable {
  DijkstraGraphState({List<Vertex>? vertices, List<Edge>? edges, this.draggedVertex, this.dragStartOffset}) : vertices = vertices ?? [], edges = edges ?? [];

  final List<Vertex> vertices;
  final List<Edge> edges;
  final Vertex? draggedVertex;
  final Offset? dragStartOffset;

  bool get isDraggingVertex => draggedVertex != null && dragStartOffset != null;

  @override
  List<Object?> get props => [vertices, edges, draggedVertex, dragStartOffset];

  DijkstraGraphState copyWith({List<Vertex>? vertices, List<Edge>? edges, Optional<Vertex?>? draggedVertex, Optional<Offset?>? dragStartOffset}) {
    return DijkstraGraphState(
      vertices: vertices ?? this.vertices,
      edges: edges ?? this.edges,
      draggedVertex: draggedVertex == null ? this.draggedVertex : draggedVertex.value,
      dragStartOffset: dragStartOffset == null ? this.dragStartOffset : dragStartOffset.value,
    );
  }
}
