part of 'dijkstra_graph_bloc.dart';

class DijkstraGraphState extends Equatable {
  DijkstraGraphState({List<Offset>? vertices}) : vertices = vertices ?? [];

  final List<Offset> vertices;

  @override
  List<Object?> get props => [vertices];
}
