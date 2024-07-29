part of 'dijkstra_tool_selection_cubit.dart';

enum DijkstraTools { pan, vertices, edge }

final class DijkstraToolSelectionState extends Equatable {
  const DijkstraToolSelectionState({
    this.selection = DijkstraTools.pan,
  });

  final DijkstraTools selection;

  @override
  List<Object> get props => [selection];
}
