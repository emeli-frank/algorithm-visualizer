import 'package:flutter/material.dart';

class EdgeWeightTextField extends StatefulWidget {
  const EdgeWeightTextField({super.key, required this.weight, required this.onWeightChanged, required this.onDone});

  final int? weight;
  final Function(int) onWeightChanged;
  final Function() onDone;

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 40.0,
            width: 80.0,
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Weight',
                hintText: 'Enter the weight of the edge',
              ),
              onChanged: (value) {
                int weight = int.tryParse(value) ?? 1;
                if (weight < 1) {
                  weight = 1;
                }
                widget.onWeightChanged(weight);
              },
            ),
          ),
          const SizedBox(width: 8.0),
          const SizedBox(width: 8.0),
          IconButton(
            onPressed: () {
              widget.onDone();
            },
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}
