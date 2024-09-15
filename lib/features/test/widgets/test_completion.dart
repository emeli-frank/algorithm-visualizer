import 'package:algorithm_visualizer/features/test/bloc/test_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TestCompletion extends StatefulWidget {
  const TestCompletion({super.key, required this.isPostTest});

  final bool isPostTest;

  @override
  State<TestCompletion> createState() => _TestCompletionState();
}

class _TestCompletionState extends State<TestCompletion> {
  String _participantID = '';

  @override
  Widget build(BuildContext context) {
    Widget child = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          textAlign: TextAlign.center,
          'Pre-test Completed. Please proceed to see the demonstration of Dijkstra\'s Algorithm by selecting that option from the sidebar.',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 36.0),
        TextButton(
          onPressed: () {
            context.go('/dijkstra-visualizer');
          },
          child: const Text('Proceed to Dijkstra\'s Algorithm'),
        ),
      ],
    );

    if (widget.isPostTest) {
      child = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            textAlign: TextAlign.center,
            'Post-test Completed. The exercise is now complete. You can play around with the graph tool and after that, please proceed to fill out the questionnaire that you have received.',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 36.0),
          SizedBox(
            width: 300.0,
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Participant ID',
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _participantID = value;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 16.0),
          TextButton(
            onPressed: _participantID.isEmpty ? null : () {
              final preTestAnswers = context.read<TestBloc>().state.preTestAnswers;
              final postTestAnswers = context.read<TestBloc>().state.postTestAnswers;
              context.read<TestBloc>().add(TestSubmitted(
                participantID: _participantID,
                preTestAnswers: preTestAnswers,
                postTestAnswers: postTestAnswers,
              ));
            },
            child: const Text('Submit responses'),
          ),
          const SizedBox(height: 16.0),
          if (context.watch<TestBloc>().state.isSubmitting)
            const CircularProgressIndicator(),
          if (context.watch<TestBloc>().state.isSubmitted ?? false)
            const Text(
              'Responses submitted successfully!',
              style: TextStyle(color: Colors.green),
            ),
          if (context.watch<TestBloc>().state.isSubmitted == false)
            const Text(
              'Failed to submit responses. Please try again.',
              style: TextStyle(color: Colors.red),
            ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: child,
    );
  }
}
