part of 'graph_bloc.dart';

class GraphState extends Equatable {
  GraphState({
    List<Vertex>? vertices,
    List<Edge>? edges,
    this.draggedVertexID,
    this.dragStartOffset,
    this.temporaryEdgeEnd,
    this.startVertexOffset,
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
  final Offset? startVertexOffset;

  bool get isDraggingVertex => draggedVertexID != null && dragStartOffset != null;

  @override
  List<Object?> get props => [vertices, edges, draggedVertexID, dragStartOffset, temporaryEdgeEnd, startVertexOffset];

  GraphState copyWith({
    List<Vertex>? vertices,
    List<Edge>? edges,
    Optional<String?>? draggedVertexID,
    Optional<Offset?>? dragStartOffset,
    Optional<Offset?>? temporaryEdgeEnd,
    Optional<Offset?>? startVertexOffset,
  }) {
    return GraphState(
      vertices: vertices ?? this.vertices,
      edges: edges ?? this.edges,
      draggedVertexID: draggedVertexID == null ? this.draggedVertexID : draggedVertexID.value,
      dragStartOffset: dragStartOffset == null ? this.dragStartOffset : dragStartOffset.value,
      temporaryEdgeEnd: temporaryEdgeEnd == null ? this.temporaryEdgeEnd : temporaryEdgeEnd.value,
      startVertexOffset: startVertexOffset == null ? this.startVertexOffset : startVertexOffset.value,
    );
  }
}
