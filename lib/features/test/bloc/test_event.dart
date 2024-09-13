part of 'test_bloc.dart';

sealed class TestEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class VertexAdded extends TestEvent {
  VertexAdded({required this.vertex});

  final Vertex vertex;
}

final class VertexUpdated extends TestEvent {
  VertexUpdated({required this.vertex});

  final Vertex vertex;
}

final class StartVertexDragging extends TestEvent {
  StartVertexDragging({required this.draggedVertexID, required this.dragStartOffset});

  final String draggedVertexID;
  final Offset dragStartOffset;
}

final class CompleteVertexDragging extends TestEvent {
  CompleteVertexDragging();
}

final class EdgeAdded extends TestEvent {
  EdgeAdded({required this.edge});

  final Edge edge;
}

final class StartEdgeDrawing extends TestEvent {
  StartEdgeDrawing({required this.startVertex});

  final Vertex startVertex;
}

final class UpdateTemporaryEdge extends TestEvent {
  UpdateTemporaryEdge({required this.temporaryEdgeEnd});

  final Offset temporaryEdgeEnd;
}

final class CompleteEdgeDrawing extends TestEvent {}

final class EdgeUpdated extends TestEvent {
  EdgeUpdated({required this.edge});

  final Edge edge;
}

final class VertexSelected extends TestEvent {
  VertexSelected({required this.vertexID});

  final String? vertexID;
}

final class VertexDeleted extends TestEvent {
  VertexDeleted({required this.vertexID});

  final String vertexID;
}

final class EdgeSelected extends TestEvent {
  EdgeSelected({required this.edgeID});

  final String? edgeID;
}

final class EdgeDeleted extends TestEvent {
  EdgeDeleted({required this.edgeID});

  final String edgeID;
}

// todo:: add a clear graph event

final class GraphElementReset extends TestEvent {
  GraphElementReset({required this.vertices, required this.edges});

  final List<Vertex> vertices;
  final List<Edge> edges;
}

final class EditModeToggled extends TestEvent {
  EditModeToggled({required this.isEditing});

  final bool isEditing;
}
