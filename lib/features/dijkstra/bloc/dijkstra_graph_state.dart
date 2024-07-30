part of 'dijkstra_graph_bloc.dart';

class DijkstraGraphState extends Equatable {
  DijkstraGraphState({List<Vertex>? vertices, this.draggedVertex, this.dragStartOffset}) : vertices = vertices ?? [];

  final List<Vertex> vertices;
  final Vertex? draggedVertex;
  final Offset? dragStartOffset;

  bool get isDragging => draggedVertex != null && dragStartOffset != null;

  @override
  List<Object?> get props => [vertices, draggedVertex, dragStartOffset];

  DijkstraGraphState copyWith({vertices, Optional<Vertex?>? draggedVertex, Optional<Offset?>? dragStartOffset}) {
    return DijkstraGraphState(
      vertices: vertices ?? this.vertices,
      draggedVertex: draggedVertex == null ? this.draggedVertex : draggedVertex.value,
      dragStartOffset: dragStartOffset == null ? this.dragStartOffset : dragStartOffset.value,
    );
  }
}
