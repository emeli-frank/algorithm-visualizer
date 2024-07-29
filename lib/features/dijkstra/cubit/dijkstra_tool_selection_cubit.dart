import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'dijkstra_tool_selection_state.dart';

class DijkstraToolSelectionCubit extends Cubit<DijkstraToolSelectionState> {
  DijkstraToolSelectionCubit(super.initialState);

  void setSelection(DijkstraTools tool) => emit(DijkstraToolSelectionState(selection: tool));
}
