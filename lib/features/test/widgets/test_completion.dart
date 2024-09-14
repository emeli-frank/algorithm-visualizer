import 'package:flutter/material.dart';

class TestCompletion extends StatelessWidget {
  const TestCompletion({super.key, required this.isPostTest});

  final bool isPostTest;

  @override
  Widget build(BuildContext context) {
    String message;

    if (!isPostTest) {
      message = 'Pre-test Completed. Please proceed to see the demonstration of Dijkstra\'s Algorithm by selecting that option from the sidebar.';
    } else {
      message = 'Post-test Completed. The exercise is now complete. You can play around with the graph tool and after that, please proceed to fill out the questioner that you have received.';
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          textAlign: TextAlign.center,
          message,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
