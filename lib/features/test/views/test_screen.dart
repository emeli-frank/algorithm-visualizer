import 'package:algorithm_visualizer/features/test/bloc/test_bloc.dart';
import 'package:algorithm_visualizer/features/test/models/graph_test.dart';
import 'package:algorithm_visualizer/features/test/widgets/test_completion.dart';
import 'package:algorithm_visualizer/features/test/widgets/test_instructions.dart';
import 'package:algorithm_visualizer/features/test/widgets/questions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool _isTestStarted = false;
  bool _isTestCompleted = false;
  late GraphTest _currentQuestion;
  late Map<int, List<String>> _answers;
  late List<GraphTest> questions = context.read<TestBloc>().state.questions;

  @override
  void initState() {
    super.initState();
    _currentQuestion = questions.first;
    _answers = { for (var question in questions) question.id : [] };
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (!_isTestStarted) {
      child = TestInstructions();
    } else if (_isTestStarted && !_isTestCompleted) {
      child = Questions(
        id: _currentQuestion.id,
        question: _currentQuestion.question,
        options: _currentQuestion.options,
        imagePath: _currentQuestion.imagePath,
        onAnswer: (id, selectedOptions) {
          setState(() {
            _answers[id] = selectedOptions;
          });
        }, selectedOptions: _answers[_currentQuestion.id] ?? [],
      );
    } else {
      child = TestCompletion(
        isPostTest: context.watch<TestBloc>().state.postTestTaken,
      );
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
            Expanded(child: child),
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
            if (_isTestStarted && !_isTestCompleted)
              TestControls(
                questions: questions,
                onQuestionSelected: (id) {
                  final question = questions.firstWhere((question) => question.id == id);
                  setState(() {
                    _currentQuestion = question;
                  });
                },
                selectedQuestionId: _currentQuestion.id,
                answers: _answers,
                testCompleted: () {
                  setState(() {
                    _isTestCompleted = true;
                  });
                  context.read<TestBloc>().add(TestCompleted(
                    preTestTaken: true,
                    preTestAnswers: _answers,
                  ));
                },
              ),
          ],
        ),
      ),
    );
  }
}

class TestControls extends StatelessWidget {
  const TestControls({
    super.key,
    required this.questions,
    required this.onQuestionSelected,
    required this.selectedQuestionId,
    required this.testCompleted,
    required this.answers,
  });

  final List<GraphTest> questions;
  final int selectedQuestionId;
  final Map<int, List<String>> answers;
  final Function(int id) onQuestionSelected;
  final Function() testCompleted;

  @override
  Widget build(BuildContext context) {
    List<ControlButton> buttons = questions.map((question) {
      return ControlButton(
        number: question.id,
        isSelected: question.id == selectedQuestionId,
        isCompleted: answers[question.id] != null && answers[question.id]!.isNotEmpty,
        onPress: onQuestionSelected,
      );
    }).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...buttons,
        TextButton(
          onPressed: _canFinish() ? testCompleted : null,
          child: const Text('Finish'),
        ),
      ],
    );
  }

  bool _canFinish() {
    return answers.values.every((element) => element.isNotEmpty);
  }
}

class ControlButton extends StatelessWidget {
  const ControlButton({super.key, required this.number, required this.isSelected, required this.isCompleted, required this.onPress});

  final int number;
  final bool isSelected;
  final bool isCompleted;
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
          child: Row(
            children: [
              Visibility(
                visible: isCompleted,
                child: Icon(
                  Icons.check_circle,
                  size: 12.0,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                number.toString(),
                style: TextStyle(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black26,
                ),
              ),
            ],
          ),
        ),
        onTap: isSelected ? null : () {
          onPress(number);
        },
      ),
    );
  }
}
