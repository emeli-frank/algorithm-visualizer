import 'package:flutter/material.dart';

class EdgeWeightTextField extends StatefulWidget {
  const EdgeWeightTextField({super.key, required this.weight, required this.onWeightChanged});

  final int? weight;
  final Function(int) onWeightChanged;

  @override
  State<EdgeWeightTextField> createState() => _EdgeWeightTextFieldState();
}

class _EdgeWeightTextFieldState extends State<EdgeWeightTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.weight.toString() ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Weight',
        hintText: 'Enter the weight of the edge',
      ),
      onChanged: (value) {
        int weight = int.tryParse(value) ?? 1;
        widget.onWeightChanged(weight);
      },
    );
  }
}
