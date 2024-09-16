import 'dart:convert';

import 'package:algorithm_visualizer/features/test/bloc/test_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _responseJson = '';

  @override
  Widget build(BuildContext context) {
    bool? isSubmitted = context.watch<TestBloc>().state.isSubmitted;

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
            onPressed: _participantID.isEmpty ||
                    context.watch<TestBloc>().state.isSubmitting ||
                    (isSubmitted != null && isSubmitted == true)
                ? null
                : () {
                    final preTestAnswers =
                        context.read<TestBloc>().state.preTestAnswers;
                    final postTestAnswers =
                        context.read<TestBloc>().state.postTestAnswers;
                    context.read<TestBloc>().add(TestSubmitted(
                          participantID: _participantID,
                          preTestAnswers: preTestAnswers,
                          postTestAnswers: postTestAnswers,
                        ));
                  },
            child: isSubmitted != null && isSubmitted == true
                ? const Text('Submitted')
                : const Text('Submit responses'),
          ),
          const SizedBox(height: 8.0),
          if (context.watch<TestBloc>().state.isSubmitting)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.0,
                  ),
                ),
                SizedBox(width: 8.0),
                Text('Submitting responses...'),
              ],
            ),
          const SizedBox(height: 8.0),
          if (isSubmitted != null && isSubmitted == true)
            const Text(
              'Responses submitted successfully!',
              style: TextStyle(color: Colors.green),
            ),
          if (isSubmitted != null && isSubmitted == false)
            const Text(
              'Failed to submit responses. Please try again.',
              style: TextStyle(color: Colors.red),
            ),

          const SizedBox(height: 36.0),
          const Text(
            'If you encounter any issues submitting your response, please copy the text below and send it to the Researcher.',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 16.0),
          if (_responseJson.isEmpty)
            TextButton(
              onPressed: () async {
                final preTestAnswers = context.read<TestBloc>().state.preTestAnswers;
                final postTestAnswers = context.read<TestBloc>().state.postTestAnswers;
                final response = {
                  'participant_id': _participantID,
                  'pre_test_answers': preTestAnswers,
                  'post_test_answers': postTestAnswers,
                };

                setState(() {
                  _responseJson = jsonEncode(response);
                });
              },
              child: const Text('Show response'),
            ),
          if (_responseJson.isNotEmpty)
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey[300]!),
                    color: Colors.grey[200],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: SelectableText(
                    _responseJson,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _responseJson));
                  },
                  child: const Text('Copy to clipboard'),
                ),
              ],
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
