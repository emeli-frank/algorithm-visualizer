import 'dart:convert';

import 'package:algorithm_visualizer/exceptions/http_exception.dart';
import 'package:algorithm_visualizer/features/test/models/graph_test.dart';
import 'package:http/http.dart' as http;

List<GraphTest> questions = [
  const GraphTest(
    id: '1',
    question: "Considering the graph and the table above, assuming the neighbouring vertex G and I have been evaluated and their distances from the starting vertex has been updated in the table, which vertex will be visited next? (Previously explored vertices are shown in a faint color)",
    imagePath: "assets/images/graph1.png",
    options: [
      'G', // Correct answer
      'H',
      'I',
      'I have no idea',
    ],
  ),
  const GraphTest(
    id: '2',
    question: "Which vertices are unvisited neighbouring vertices to the highlighted vertex E? (Select all that apply)",
    imagePath: "assets/images/graph2.png",
    options: [
      'C', // Correct answer
      'B',
      'I', // Correct answer
      'E',
      'F', // Correct answer
      'I have no idea',
    ],
  ),
  const GraphTest(
    id: '3',
    question: "After visiting vertex E, which of its neighbouring vertices will have their shortest distance updated?",
    imagePath: "assets/images/graph3.png",
    options: [
      'C', // Neighbor but not updated
      'I', // Correct answer
      'F', // Correct answer
      'I have no idea',
    ],
  ),
  const GraphTest(
    id: '4',
    question: "Using the graph and the table, what is the shortest distance from vertex G to the start vertex A?",
    imagePath: "assets/images/graph4.png",
    options: [
      '10', // Correct answer
      '19',
      '7',
      '2'
      'I have no idea',
    ],
  ),
  const GraphTest(
    id: '5',
    question: "Using the graph and the table, what vertices are along the shortest path from start vertex A to the vertex H?",
    imagePath: "assets/images/graph4.png",
    options: [
      'A -> B -> D -> F -> H',
      'A -> F -> H',
      'A -> D -> F -> H', // Correct answer
      'I have no idea',
    ],
  ),
  const GraphTest(
    id: '6',
    question: "Using the graph, what is the shortest distance from vertex G to the start vertex A?",
    imagePath: "assets/images/graph5.png",
    options: [
      '2',
      '3',
      '4', // Correct answer
      'I have no idea',
    ],
  ),
  const GraphTest(
    id: '7',
    question: "Using the graph, what vertices are along the shortest path from vertex G to vertex A?",
    imagePath: "assets/images/graph5.png",
    options: [
      'ADG', // Correct answer
      'ACFG',
      'ABEG',
      'I have no idea',
    ],
  ),
];

class TestRepository {
  List<GraphTest> fetchTest() {
    return questions;
  }

  final String baseUrl = 'https://2316808.linux.studentwebserver.co.uk';

  Future<void> submitTest(String participantID, Map<String, List<String>> preTestAnswers, Map<String, List<String>> postTestAnswers) async {
    final Map<String, dynamic> payload = {
      'participant_id': participantID,
      'pre_test_answers': preTestAnswers,
      'post_test_answers': postTestAnswers,
    };

    final String jsonPayload = jsonEncode(payload);

    final String url = '$baseUrl/algorithm_visualization/submission.php';

    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonPayload,
      );

      if (response.statusCode != 201)  {
        throw HttpException('Request failed with status: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw HttpException('Error occurred while submitting the test: $e');
    }
  }
}
