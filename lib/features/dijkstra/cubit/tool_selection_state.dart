part of 'tool_selection_cubit.dart';

enum DijkstraTools { pan, vertices, edge }

final class ToolSelectionState extends Equatable {
  const ToolSelectionState({
    this.selection = DijkstraTools.pan,
  });

  final DijkstraTools selection;

  @override
  List<Object> get props => [selection];
}
