part of 'test_bloc.dart';

sealed class TestEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class TestCompleted extends TestEvent {
  TestCompleted({
    this.preTestTaken = false,
    this.postTestTaken = false,
    this.preTestAnswers = const {},
    this.postTestAnswers = const {},
  });

  final Map<int, List<String>> preTestAnswers;
  final Map<int, List<String>> postTestAnswers;
  final bool preTestTaken;
  final bool postTestTaken;
}
