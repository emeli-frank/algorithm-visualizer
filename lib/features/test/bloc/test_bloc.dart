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
        preTestCompleted: event.preTestCompleted,
        postTestCompleted: event.postTestCompleted,
        postTestStarted: false,
        preTestStarted: false,
        preTestAnswers: event.preTestAnswers,
        postTestAnswers: event.postTestAnswers,
      ));
    });

    on<TestRequested>((TestRequested event, Emitter<TestState> emit) {
      final questions = repo.fetchTest();
      emit(state.copyWith(questions: questions));
    });

    on<TestAnswerSaved>((TestAnswerSaved event, Emitter<TestState> emit) {
      final preTestAnswers = {...state.preTestAnswers};
      final postTestAnswers = {...state.postTestAnswers};
      if (event.isPreTest) {
        preTestAnswers[event.questionId] = event.answers;
      } else {
        postTestAnswers[event.questionId] = event.answers;
      }
      emit(state.copyWith(preTestAnswers: preTestAnswers, postTestAnswers: postTestAnswers));
    });

    on<QuestionSelected>((QuestionSelected event, Emitter<TestState> emit) {
      emit(state.copyWith(currentQuestionID: event.id));
    });

    on<TestStarted>((TestStarted event, Emitter<TestState> emit) {
      if (event.isPreTest) {
        emit(state.copyWith(preTestStarted: true));
      } else {
        emit(state.copyWith(postTestStarted: true));
      }
    });

    on<TestSubmitted>((TestSubmitted event, Emitter<TestState> emit) {
      emit(state.copyWith(isSubmitting: true));
      try {
        repo.submitTest(event.participantID, event.preTestAnswers, event.postTestAnswers);
        emit(state.copyWith(isSubmitted: true, isSubmitting: false));
      } catch (e) {
        emit(state.copyWith(isSubmitted: false, isSubmitting: false));
      }
    });
  }

  final TestRepository repo;
}
