part of 'dijkstra_graph_bloc.dart';

sealed class DijkstraGraphEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class VerticesAdded extends DijkstraGraphEvent {
  VerticesAdded({required this.vertex});

  final Vertex vertex;
}

final class VerticesUpdated extends DijkstraGraphEvent {
  VerticesUpdated({required this.vertex});

  final Vertex vertex;
}

final class StartVertexDragging extends DijkstraGraphEvent {
  StartVertexDragging({required this.draggedVertexID, required this.dragStartOffset});

  final String draggedVertexID;
  final Offset dragStartOffset;
}

final class CompleteVertexDragging extends DijkstraGraphEvent {
  CompleteVertexDragging();
}

final class EdgeAdded extends DijkstraGraphEvent {
  EdgeAdded({required this.edge});

  final Edge edge;
}

final class StartEdgeDrawing extends DijkstraGraphEvent {
  StartEdgeDrawing({required this.startVertexOffset});

  final Offset startVertexOffset;
}

final class UpdateTemporaryEdge extends DijkstraGraphEvent {
  UpdateTemporaryEdge({required this.temporaryEdgeEnd});

  final Offset temporaryEdgeEnd;
}

final class CompleteEdgeDrawing extends DijkstraGraphEvent {}
