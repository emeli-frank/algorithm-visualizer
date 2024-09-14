part of 'test_bloc.dart';

class TestState extends Equatable {
  const TestState({
    this.preTestStarted = false,
    this.preTestCompleted = false,
    this.postTestStarted = false,
    this.postTestCompleted = false,
    this.preTestAnswers = const {},
    this.postTestAnswers = const {},
    this.questions = const [],
    this.currentQuestionID,
  });

  final Map<int, List<String>> preTestAnswers;
  final Map<int, List<String>> postTestAnswers;
  final bool preTestStarted;
  final bool preTestCompleted;
  final bool postTestStarted;
  final bool postTestCompleted;
  final List<GraphTest> questions;
  final int? currentQuestionID;

  @override
  List<Object?> get props => [
    preTestAnswers,
    postTestAnswers,
    preTestStarted,
    preTestCompleted,
    postTestStarted,
    postTestCompleted,
    questions,
    currentQuestionID,
  ];

  TestState copyWith({
    Map<int, List<String>>? preTestAnswers,
    Map<int, List<String>>? postTestAnswers,
    bool? preTestStarted,
    bool? preTestCompleted,
    bool? postTestStarted,
    bool? postTestCompleted,
    List<GraphTest>? questions,
    int? currentQuestionID,
  }) {
    return TestState(
      preTestAnswers: preTestAnswers ?? this.preTestAnswers,
      postTestAnswers: postTestAnswers ?? this.postTestAnswers,
      preTestStarted: preTestStarted ?? this.preTestStarted,
      preTestCompleted: preTestCompleted ?? this.preTestCompleted,
      postTestStarted: postTestStarted ?? this.postTestStarted,
      postTestCompleted: postTestCompleted ?? this.postTestCompleted,
      questions: questions ?? this.questions,
      currentQuestionID: currentQuestionID ?? this.currentQuestionID,
    );
  }
}
