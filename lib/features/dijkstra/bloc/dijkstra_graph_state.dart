part of 'dijkstra_graph_bloc.dart';

class DijkstraGraphState extends Equatable {
  DijkstraGraphState({List<Vertex>? vertex}) : vertices = vertex ?? [];

  final List<Vertex> vertices;

  @override
  List<Object?> get props => [vertices];
}
