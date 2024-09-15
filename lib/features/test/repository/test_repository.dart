import 'package:algorithm_visualizer/features/test/models/graph_test.dart';

List<GraphTest> questions = [
  const GraphTest(
    id: 1,
    question: "Considering the graph and the table above, assuming the neighbouring vertex G and I have been evaluated and their distances from the starting vertex has been updated, what would be the next vertex to visit? Which vertex will be visited next? (Previously explored vertices are shown in faint green)",
    imagePath: "assets/images/graph1.png",
    options: [
      'G',
      'I',
      'B',
      'I have no idea',
    ],
  ),
  const GraphTest(
    id: 2,
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
    id: 3,
    question: "After visiting vertex E, which of its neighbouring vertices will have their shortest distance updated?",
    imagePath: "assets/images/graph3.png",
    options: [
      'C',
      'I',
      'F',
      'I have no idea',
    ],
  ),
  const GraphTest(
    id: 4,
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
    id: 5,
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
    id: 6,
    question: "Using the graph, what is the shortest distance from vertex X to the start vertex X?",
    imagePath: "assets/images/graph5.png",
    options: [
      '4',
      '2',
      '6',
      'Not obtainable',
    ],
  ),
  const GraphTest(
    id: 7,
    question: "Using the graph, what vertices are along the shortest path from vertex X to vertex X?",
    imagePath: "assets/images/graph5.png",
    options: [
      '4',
      '2',
      '6',
      'Not obtainable',
    ],
  ),
];

class TestRepository {
  List<GraphTest> fetchTest() {
    return questions;
  }

  Future<void> submitTest(List<Map<int, List<String>>> answer) async {
    // Submit test
  }
}
