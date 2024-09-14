import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'test_state.dart';
part 'test_event.dart';

class TestBloc extends Bloc<TestEvent, TestState> {
  TestBloc() : super(const TestState()) {
    on<TestCompleted>((TestCompleted event, Emitter<TestState> emit) {
      emit(state.copyWith(
        preTestTaken: event.preTestTaken,
        postTestTaken: event.postTestTaken,
        preTestAnswers: event.preTestAnswers,
        postTestAnswers: event.postTestAnswers,
      ));
    });
  }
}
