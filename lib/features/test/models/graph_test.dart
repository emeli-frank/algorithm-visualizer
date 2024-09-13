import 'package:equatable/equatable.dart';

class GraphTest extends Equatable {
  const GraphTest({required this.id, required this.question, required this.imagePath, required this.data});

  final int id;
  final String question;
  final String imagePath;
  final Map<String, GraphTableData> data;

  @override
  List<Object?> get props => [id, question, imagePath];
}

class GraphTableData {
  GraphTableData({this.distance, this.previous});

  final int? distance;
  final String? previous;
}
