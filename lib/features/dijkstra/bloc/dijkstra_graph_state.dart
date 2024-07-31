part of 'dijkstra_graph_bloc.dart';

class DijkstraGraphState extends Equatable {
  DijkstraGraphState({
    List<Vertex>? vertices,
    List<Edge>? edges,
    this.draggedVertexID,
    this.dragStartOffset,
    this.temporaryEdgeEnd,
    this.startVertex,
  })  : vertices = vertices ?? [],
        edges = edges ?? [];

  final List<Vertex> vertices;
  final List<Edge> edges;

  // Represents the ID of the vertex that is currently being dragged
  final String? draggedVertexID;

  // Represents the offset of the vertex that is currently being dragged
  final Offset? dragStartOffset;

  // Represents the offset of the temporary edge end (where the cursor is)
  final Offset? temporaryEdgeEnd;

  // Represents the offset of the vertex where the dragging started
  final Offset? startVertex;

  bool get isDraggingVertex => draggedVertexID != null && dragStartOffset != null;

  @override
  List<Object?> get props => [vertices, edges, draggedVertexID, dragStartOffset, temporaryEdgeEnd, startVertex];

  DijkstraGraphState copyWith({
    List<Vertex>? vertices,
    List<Edge>? edges,
    Optional<String?>? draggedVertexID,
    Optional<Offset?>? dragStartOffset,
    Optional<Offset?>? temporaryEdgeEnd,
    Optional<Offset?>? startVertex,
  }) {
    return DijkstraGraphState(
      vertices: vertices ?? this.vertices,
      edges: edges ?? this.edges,
      draggedVertexID: draggedVertexID == null ? this.draggedVertexID : draggedVertexID.value,
      dragStartOffset: dragStartOffset == null ? this.dragStartOffset : dragStartOffset.value,
      temporaryEdgeEnd: temporaryEdgeEnd == null ? this.temporaryEdgeEnd : temporaryEdgeEnd.value,
      startVertex: startVertex == null ? this.startVertex : startVertex.value,
    );
  }
}
