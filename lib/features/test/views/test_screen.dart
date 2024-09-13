import 'package:algorithm_visualizer/features/test/models/graph_test.dart';
import 'package:algorithm_visualizer/features/test/widgets/test_instructions.dart';
import 'package:algorithm_visualizer/features/test/widgets/questions.dart';
import 'package:flutter/material.dart';

var testData = {
  "A": GraphTableData(),
  "B": GraphTableData(),
  "C": GraphTableData(),
  "D": GraphTableData(),
  "E": GraphTableData(),
};

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool _isTestStarted = false;
  late GraphTest _currentQuestion;

  List<GraphTest> questions = [
    GraphTest(id: 1, question: "Question one.", imagePath: "assets/images/graph1.png", data: testData),
    GraphTest(id: 2, question: "Question two.", imagePath: "assets/images/graph1.png", data: testData),
    GraphTest(id: 3, question: "Question three.", imagePath: "assets/images/graph1.png", data: testData),
  ];

  @override
  void initState() {
    super.initState();
    _currentQuestion = questions.first;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (!_isTestStarted) {
      child = TestInstructions();
    } else {
      child = Questions(question: _currentQuestion.question, imagePath: _currentQuestion.imagePath, data: _currentQuestion.data, startVertex: 'A',);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            child,
            if (!_isTestStarted)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isTestStarted = true;
                      });
                    },
                    child: const Text('Start Test'),
                  ),
                ],
              ),
            if (_isTestStarted)
              TestControls(questions: questions, onQuestionSelected: (id) {
                print("Selected question: $id");
                final question = questions.firstWhere((question) => question.id == id);
                setState(() {
                  _currentQuestion = question;
                });
                print("Question: ${question.question}");
              }),
          ],
        ),
      ),
    );
  }
}

class TestControls extends StatelessWidget {
  const TestControls({super.key, required this.questions, required this.onQuestionSelected});

  final List<GraphTest> questions;
  final Function(int id) onQuestionSelected;

  @override
  Widget build(BuildContext context) {
    List<ControlButton> buttons = questions.map((question) {
      return ControlButton(
        number: question.id,
        isSelected: false,
        onPress: onQuestionSelected,
      );
    }).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons,
    );
  }
}

class ControlButton extends StatelessWidget {
  const ControlButton({super.key, required this.number, this.isSelected = false, required this.onPress});

  final int number;
  final bool isSelected;
  final Function(int id) onPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).colorScheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Text(
            number.toString(),
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.black54,
            ),
          ),
        ),
        onTap: isSelected ? null : () {
          onPress(number);
        },
      ),
    );
  }
}
