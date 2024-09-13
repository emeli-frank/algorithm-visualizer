part of 'test_bloc.dart';

class TestState extends Equatable {
  const TestState({required this.preTestTaken, required this.postTestTaken});

  final bool preTestTaken;
  final bool postTestTaken;

  @override
  List<Object?> get props => [];
}
