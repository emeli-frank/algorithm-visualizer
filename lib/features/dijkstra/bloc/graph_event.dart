part of 'graph_bloc.dart';

sealed class GraphEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class VerticesAdded extends GraphEvent {
  VerticesAdded({required this.vertex});

  final Vertex vertex;
}

final class VerticesUpdated extends GraphEvent {
  VerticesUpdated({required this.vertex});

  final Vertex vertex;
}

final class StartVertexDragging extends GraphEvent {
  StartVertexDragging({required this.draggedVertexID, required this.dragStartOffset});

  final String draggedVertexID;
  final Offset dragStartOffset;
}

final class CompleteVertexDragging extends GraphEvent {
  CompleteVertexDragging();
}

final class EdgeAdded extends GraphEvent {
  EdgeAdded({required this.edge});

  final Edge edge;
}

final class StartEdgeDrawing extends GraphEvent {
  StartEdgeDrawing({required this.startVertexOffset});

  final Offset startVertexOffset;
}

final class UpdateTemporaryEdge extends GraphEvent {
  UpdateTemporaryEdge({required this.temporaryEdgeEnd});

  final Offset temporaryEdgeEnd;
}

final class CompleteEdgeDrawing extends GraphEvent {}
