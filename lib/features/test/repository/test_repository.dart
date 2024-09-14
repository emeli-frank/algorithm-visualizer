import 'package:algorithm_visualizer/features/test/models/graph_test.dart';

List<String> options = [
  'A',
  'B',
  'C',
  'D',
  'E',
];

List<GraphTest> questions = [
  GraphTest(id: 1, question: "Question one.", imagePath: "assets/images/graph1.png", options: options),
  GraphTest(id: 2, question: "Question two.", imagePath: "assets/images/graph1.png", options: options),
  GraphTest(id: 3, question: "Question three.", imagePath: "assets/images/graph1.png", options: options),
];


class TestRepository {
  List<GraphTest> fetchTest() {
    return questions;
  }

  Future<void> submitTest(List<Map<int, List<String>>> answer) async {
    // Submit test
  }
}
