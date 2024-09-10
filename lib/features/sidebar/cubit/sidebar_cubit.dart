import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'sidebar_state.dart';

class SidebarCubit extends Cubit<SidebarState> {
  SidebarCubit(super.initialState);

  void toggle({required bool isOpen}) => emit(SidebarState(isOpen: isOpen));
}
