import 'package:algorithm_visualizer/features/sidebar/cubit/sidebar_cubit.dart';
import 'package:algorithm_visualizer/features/test/bloc/test_bloc.dart';
import 'package:algorithm_visualizer/features/test/models/graph_test.dart';
import 'package:algorithm_visualizer/features/test/widgets/test_completion.dart';
import 'package:algorithm_visualizer/features/test/widgets/test_instructions.dart';
import 'package:algorithm_visualizer/features/test/widgets/questions.dart';
import 'package:algorithm_visualizer/widgets/nav_icon_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key, required this.type});

  final String type;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  void initState() {
    super.initState();
    final questions = context.read<TestBloc>().state.questions;
    context.read<TestBloc>().add(QuestionSelected(id: questions.first.id));
  }

  @override
  Widget build(BuildContext context) {
    final isPreTest = widget.type == 'pre-test';
    final graphTestState = context.watch<TestBloc>().state;
    final List<GraphTest> questions = graphTestState.questions;
    final preTestAnswers = graphTestState.preTestAnswers;
    final postTestAnswers = graphTestState.postTestAnswers;
    final GraphTest? currentQuestion = questions.firstWhereOrNull((question) => question.id == graphTestState.currentQuestionID);
    Widget child = const SizedBox();
    bool isTestStarted = false;
    if (isPreTest) {
      isTestStarted = graphTestState.preTestStarted;
    } else {
      isTestStarted = graphTestState.postTestStarted;
    }
    bool isTestCompleted = false;
    if (isPreTest) {
      isTestCompleted = graphTestState.preTestCompleted;
    } else {
      isTestCompleted = graphTestState.postTestCompleted;
    }

    if (isTestCompleted) {
      child = TestCompletion(
        isPostTest: context.watch<TestBloc>().state.postTestCompleted,
      );
    } else if (isTestStarted && currentQuestion != null) {
      final selectedOptions = isPreTest ? preTestAnswers[currentQuestion.id] ?? [] : postTestAnswers[currentQuestion.id] ?? [];
      child = Questions(
        currentQuestion: currentQuestion,
        onAnswer: (id, selectedOptions) {
          context.read<TestBloc>().add(TestAnswerSaved(questionId: id, answers: selectedOptions, isPreTest: isPreTest));
        },
        selectedOptions: selectedOptions,
      );
    } else {
      child = TestInstructions();
    }

    String title = isPreTest ? 'Pre test' : 'Post test';
    title += ' - Question ${currentQuestion?.id ?? 1} of ${questions.length}';

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40.0,
        leading: Visibility(
          visible: !context.watch<SidebarCubit>().state.isOpen,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: NavIconButton(
              iconData: Icons.menu_open_outlined,
              onPressed: () {
                context.read<SidebarCubit>().toggle(isOpen: true);
              },
              tooltip: 'Open sidebar',
            ),
          ),
        ),
        title: Text(title),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: child),
            if (!isTestStarted && !isTestCompleted)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      context.read<TestBloc>().add(TestStarted(isPreTest: isPreTest));
                    },
                    child: const Text('Start Test'),
                  ),
                ],
              ),
            if (isTestStarted && !isTestCompleted && currentQuestion != null)
              TestControls(
                questions: questions,
                onQuestionSelected: (id) {
                  context.read<TestBloc>().add(QuestionSelected(id: id));
                },
                selectedQuestionId: currentQuestion.id,
                answers: isPreTest ? context.watch<TestBloc>().state.preTestAnswers : context.watch<TestBloc>().state.postTestAnswers,
                testCompleted: () {
                  context.read<TestBloc>().add(TestCompleted(
                    preTestCompleted: isPreTest ? true : graphTestState.preTestCompleted,
                    postTestCompleted: isPreTest ? graphTestState.postTestCompleted : true,
                    preTestAnswers: context.read<TestBloc>().state.preTestAnswers,
                    postTestAnswers: context.read<TestBloc>().state.postTestAnswers,
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
    return answers.length == questions.length && answers.values.every((element) => element.isNotEmpty);
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
