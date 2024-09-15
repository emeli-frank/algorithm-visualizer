import 'package:algorithm_visualizer/features/test/models/graph_test.dart';
import 'package:flutter/material.dart';

class Questions extends StatefulWidget {
  const Questions({
    super.key,
    required this.currentQuestion,
    required this.onAnswer,
    required this.selectedOptions,
  });

  final List<String> selectedOptions;
  final GraphTest? currentQuestion;
  final Function(String id, List<String> answers) onAnswer;

  @override
  State<Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> {
  @override
  Widget build(BuildContext context) {
    if (widget.currentQuestion == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(widget.currentQuestion!.imagePath),
        const SizedBox(height: 24.0),
        Text(
          widget.currentQuestion!.question,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.currentQuestion!.options.map((option) {
            return Option(
              option: option,
              isSelected: widget.selectedOptions.contains(option),
              onPress: (isSelected) {
                widget.onAnswer(widget.currentQuestion!.id, isSelected ? [...widget.selectedOptions, option] : widget.selectedOptions.where((element) => element != option).toList());
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class Option extends StatelessWidget {
  const Option({super.key, required this.option, required this.isSelected, required this.onPress});

  final String option;
  final bool isSelected;
  final Function(bool) onPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Checkbox(value: isSelected, onChanged: (value) {
              onPress(!isSelected);
            }),
            const SizedBox(width: 8.0),
            Text(option)
          ],
        ),
      ),
      onTap: () {
        onPress(!isSelected);
      },
    );
  }
}
