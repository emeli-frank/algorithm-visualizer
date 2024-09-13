import 'package:flutter/material.dart';

class TestInstructions extends StatelessWidget {
  const TestInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Center(
        child: Text('Test instructions placeholder'),
      ),
      /*child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Test instructions placeholder'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Start Test'),
              )
            ],
          ),
        ],
      ),*/
    );
  }
}
