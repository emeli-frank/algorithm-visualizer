part of 'dijkstra_graph_bloc.dart';

sealed class DijkstraGraphEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class DijkstraGraphVerticesAdded extends DijkstraGraphEvent {
  DijkstraGraphVerticesAdded({required this.vertex});

  final Vertex vertex;
}

final class DijkstraGraphVerticesUpdated extends DijkstraGraphEvent {
  DijkstraGraphVerticesUpdated({required this.vertex});

  final Vertex vertex;
}

final class DijkstraGraphVerticesMoved extends DijkstraGraphEvent {
  DijkstraGraphVerticesMoved({required this.draggedVertex, required this.dragStartOffset});

  final Vertex draggedVertex;
  final Offset dragStartOffset;
}

final class DijkstraGraphVerticesDragStopped extends DijkstraGraphEvent {
  DijkstraGraphVerticesDragStopped();
}

final class DijkstraGraphEdgeAdded extends DijkstraGraphEvent {
  DijkstraGraphEdgeAdded({required this.edge});

  final Edge edge;
}
