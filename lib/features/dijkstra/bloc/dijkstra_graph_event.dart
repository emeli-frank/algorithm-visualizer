part of 'dijkstra_graph_bloc.dart';

sealed class DijkstraGraphEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class DijkstraGraphVerticesAdded extends DijkstraGraphEvent {
  DijkstraGraphVerticesAdded({required this.vertices});

  final Offset vertices;
}
