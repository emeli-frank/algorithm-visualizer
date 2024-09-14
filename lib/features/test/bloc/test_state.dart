part of 'test_bloc.dart';

class TestState extends Equatable {
  const TestState({
    this.preTestTaken = false,
    this.postTestTaken = false,
    this.preTestAnswers = const {},
    this.postTestAnswers = const {},
    this.questions = const [],
  });

  final Map<int, List<String>> preTestAnswers;
  final Map<int, List<String>> postTestAnswers;
  final bool preTestTaken;
  final bool postTestTaken;
  final List<GraphTest> questions;

  @override
  List<Object?> get props => [];

  TestState copyWith({
    Map<int, List<String>>? preTestAnswers,
    Map<int, List<String>>? postTestAnswers,
    bool? preTestTaken,
    bool? postTestTaken,
    List<GraphTest>? questions,
  }) {
    return TestState(
      preTestAnswers: preTestAnswers ?? this.preTestAnswers,
      postTestAnswers: postTestAnswers ?? this.postTestAnswers,
      preTestTaken: preTestTaken ?? this.preTestTaken,
      postTestTaken: postTestTaken ?? this.postTestTaken,
      questions: questions ?? this.questions,
    );
  }
}
