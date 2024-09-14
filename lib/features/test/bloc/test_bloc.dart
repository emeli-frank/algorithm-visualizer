import 'package:algorithm_visualizer/features/test/models/graph_test.dart';
import 'package:algorithm_visualizer/features/test/repository/test_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'test_state.dart';
part 'test_event.dart';

class TestBloc extends Bloc<TestEvent, TestState> {
  TestBloc({required this.repo}) : super(const TestState()) {
    on<TestCompleted>((TestCompleted event, Emitter<TestState> emit) {
      emit(state.copyWith(
        preTestTaken: event.preTestTaken,
        postTestTaken: event.postTestTaken,
        preTestAnswers: event.preTestAnswers,
        postTestAnswers: event.postTestAnswers,
      ));
    });

    on<TestRequested>((TestRequested event, Emitter<TestState> emit) {
      final questions = repo.fetchTest();
      emit(state.copyWith(questions: questions));
    });
  }

  final TestRepository repo;
}
