import 'package:flutter/material.dart';

class VertexTextLabel extends StatelessWidget {
  const VertexTextLabel({super.key, required this.label, this.color = Colors.white});

  final String label;
  final size = 20.0;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}
