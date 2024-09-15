import 'package:equatable/equatable.dart';

class GraphTest extends Equatable {
  const GraphTest({required this.id, required this.question, required this.imagePath, required this.options});

  final String id;
  final String question;
  final List<String> options;
  final String imagePath;

  @override
  List<Object?> get props => [id, question, imagePath];
}

