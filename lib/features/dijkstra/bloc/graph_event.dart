part of 'graph_bloc.dart';

sealed class GraphEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class VertexAdded extends GraphEvent {
  VertexAdded({required this.vertex});

  final Vertex vertex;
}

final class VertexUpdated extends GraphEvent {
  VertexUpdated({required this.vertex});

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
  StartEdgeDrawing({required this.startVertex});

  final Vertex startVertex;
}

final class UpdateTemporaryEdge extends GraphEvent {
  UpdateTemporaryEdge({required this.temporaryEdgeEnd});

  final Offset temporaryEdgeEnd;
}

final class CompleteEdgeDrawing extends GraphEvent {}

final class EdgeUpdated extends GraphEvent {
  EdgeUpdated({required this.edge});

  final Edge edge;
}

final class VertexSelected extends GraphEvent {
  VertexSelected({required this.vertexID});

  final String? vertexID;
}

final class VertexDeleted extends GraphEvent {
  VertexDeleted({required this.vertexID});

  final String vertexID;
}

final class EdgeSelected extends GraphEvent {
  EdgeSelected({required this.edgeID});

  final String? edgeID;
}

final class EdgeDeleted extends GraphEvent {
  EdgeDeleted({required this.edgeID});

  final String edgeID;
}

// todo:: add a clear graph event

final class GraphElementReset extends GraphEvent {
  GraphElementReset({required this.vertices, required this.edges});

  final List<Vertex> vertices;
  final List<Edge> edges;
}

final class EditModeToggled extends GraphEvent {
  EditModeToggled({required this.isEditing});

  final bool isEditing;
}
