part of 'graph_bloc.dart';

class GraphState extends Equatable {
  GraphState({
    List<Vertex>? vertices,
    List<Edge>? edges,
    this.draggedVertexID,
    this.dragStartOffset,
    this.temporaryEdgeEnd,
    this.startVertex,
    this.selectedVertexID,
    this.selectedEdgeID,
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

  // Represents the vertex where the dragging started
  final Vertex? startVertex;

  // Represents the vertex that is currently selected
  final String? selectedVertexID;

  // Represents the edge that is currently selected
  final String? selectedEdgeID;

  bool get isDraggingVertex => draggedVertexID != null && dragStartOffset != null;

  Edge? get selectedEdge {
    for (var edge in edges) {
      if (edge.id == selectedEdgeID) {
        return edge;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [
        vertices,
        edges,
        draggedVertexID,
        dragStartOffset,
        temporaryEdgeEnd,
        startVertex,
        selectedVertexID,
        selectedEdgeID,
      ];

  GraphState copyWith({
    List<Vertex>? vertices,
    List<Edge>? edges,
    Optional<String?>? draggedVertexID,
    Optional<Offset?>? dragStartOffset,
    Optional<Offset?>? temporaryEdgeEnd,
    Optional<Vertex?>? startVertex,
    Optional<String?>? selectedVertexID,
    Optional<String?>? selectedEdgeID,
  }) {
    return GraphState(
      vertices: vertices ?? this.vertices,
      edges: edges ?? this.edges,
      draggedVertexID: draggedVertexID == null ? this.draggedVertexID : draggedVertexID.value,
      dragStartOffset: dragStartOffset == null ? this.dragStartOffset : dragStartOffset.value,
      temporaryEdgeEnd: temporaryEdgeEnd == null ? this.temporaryEdgeEnd : temporaryEdgeEnd.value,
      startVertex: startVertex == null ? this.startVertex : startVertex.value,
      selectedVertexID: selectedVertexID == null ? this.selectedVertexID : selectedVertexID.value,
      selectedEdgeID: selectedEdgeID == null ? this.selectedEdgeID : selectedEdgeID.value,
    );
  }
}
