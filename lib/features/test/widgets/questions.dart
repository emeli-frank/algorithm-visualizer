import 'package:flutter/material.dart';

class Questions extends StatefulWidget {
  const Questions({
    super.key,
    required this.question,
    required this.options,
    required this.imagePath,
    required this.onAnswer,
    required this.selectedOptions,
    required this.id,
  });

  final int id;
  final String question;
  final List<String> options;
  final String imagePath;
  final List<String> selectedOptions;
  final Function(int id, List<String> answers) onAnswer;

  @override
  State<Questions> createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(widget.imagePath),
        Text(
          widget.question,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.options.map((option) {
            return Option(
              option: option,
              isSelected: widget.selectedOptions.contains(option),
              onPress: (isSelected) {
                widget.onAnswer(widget.id, isSelected ? [...widget.selectedOptions, option] : widget.selectedOptions.where((element) => element != option).toList());
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
