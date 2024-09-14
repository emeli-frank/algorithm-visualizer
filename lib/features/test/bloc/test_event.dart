part of 'test_bloc.dart';

sealed class TestEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class TestCompleted extends TestEvent {
  TestCompleted({
    this.preTestCompleted = false,
    this.postTestCompleted = false,
    this.preTestAnswers = const {},
    this.postTestAnswers = const {},
  });

  final Map<int, List<String>> preTestAnswers;
  final Map<int, List<String>> postTestAnswers;
  final bool preTestCompleted;
  final bool postTestCompleted;
}

final class TestRequested extends TestEvent {}

final class TestAnswerSaved extends TestEvent {
  TestAnswerSaved({required this.answers, required this.isPreTest, required this.questionId});

  final List<String> answers;
  final int questionId;
  final bool isPreTest;
}

final class TestSubmitted extends TestEvent {
  TestSubmitted(this.answers);

  final List<Map<int, List<String>>> answers;
}

final class QuestionSelected extends TestEvent {
  QuestionSelected({required this.id});

  final int id;
}

final class TestStarted extends TestEvent {
  TestStarted({required this.isPreTest});

  final bool isPreTest;
}

/*final class TestsLoaded extends TestEvent {
  TestsLoaded(this.tests);

  final List<GraphTest> tests;
}*/
