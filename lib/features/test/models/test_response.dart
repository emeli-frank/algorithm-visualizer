import 'package:equatable/equatable.dart';

abstract class TestResponse extends Equatable {
  const TestResponse({required this.questionID, required this.participantID});

  final int questionID;
  final String participantID;

  @override
  List<Object?> get props => [questionID, participantID];
}

class FullGraphResponse extends TestResponse {
  const FullGraphResponse({
    required super.questionID,
    required super.participantID,
    required this.responses,
  });

  final List<String> responses;

  @override
  List<Object?> get props => [...super.props, responses];
}

class PartialGraphResponse extends TestResponse {
  const PartialGraphResponse({
    required super.questionID,
    required super.participantID,
    required this.response,
  });

  final String response;

  @override
  List<Object?> get props => [...super.props, response];
}
