import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'tool_selection_state.dart';

class ToolSelectionCubit extends Cubit<ToolSelectionState> {
  ToolSelectionCubit(super.initialState);

  void setSelection(DijkstraTools tool) => emit(ToolSelectionState(selection: tool));
}
