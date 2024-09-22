import 'package:algorithm_visualizer/features/dijkstra/bloc/animation_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Pseudocode extends StatelessWidget {
  const Pseudocode({super.key});

  @override
  Widget build(BuildContext context) {
    List<Position> positions = [];

    final animationState = context.watch<AnimationBloc>().state;

    if (animationState.currentNeighbor != null && animationState.step == AnimationStep.findingCurrentEdge2) {
      positions = [Position.tentativeDistance,];
    } else if (animationState.currentNeighbor != null && animationState.step == AnimationStep.findingCurrentEdge) {
      positions = [Position.shouldUpdateDistanceAndPrevious,];
      if (animationState.tentativeDistanceUpdated == true) {
        positions.add(Position.updateDistanceAndPrevious);
      }
    } else if (animationState.step == AnimationStep.findingCurrentEdge) {
      positions = [Position.neighborLoop,];
    } else if (animationState.step == AnimationStep.findingCurrentVertex && animationState.currentEdge == null && animationState.currentNeighbor == null) {
      positions = [Position.markVisited,];
    } else if (animationState.currentVertex != null) {
      positions = [Position.visit,];
    }  else if (animationState.unvisitedVertices.isEmpty && animationState.currentVertex == null && animationState.currentNeighbor == null) {
      positions = [Position.end,];
    } else if (animationState.isRunning) {
      positions = [Position.initialization,];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Row(text: ['1. Initialize:']),
        _Row(
          isHighlighted: positions.contains(Position.initialization),
          text: const [
            'Set the distance of the start vertex to 0.',
            'Set the distance of all other vertices to infinity.',
            'Mark all vertices as unvisited.',
          ],
          level: 1,
        ),
        const _Row(
          text: ['2. Repeat until all vertices have been visited:'],
        ),
        _Row(
          isHighlighted: positions.contains(Position.visit),
          text: const [
            'Select the unvisited vertex with the smallest known distance (current vertex).'
          ],
          level: 1,
        ),
        _Row(
            isHighlighted: positions.contains(Position.neighborLoop),
            text: const ['For each unvisited neighbor of the current vertex:'],
            level: 1),
        _Row(
          isHighlighted: positions.contains(Position.tentativeDistance),
          text: const [
            'Calculate the tentative distance from the start vertex to this neighbor.'
          ],
          level: 2,
        ),
        _Row(
          isHighlighted: positions.contains(Position.shouldUpdateDistanceAndPrevious),
          text: const [
            'If the tentative distance is less than the current known distance:'
          ],
          level: 2,
        ),
        _Row(
          isHighlighted: positions.contains(Position.updateDistanceAndPrevious),
          text: const [
            'Update the shortest distance to this neighbor.',
            'Update the previous vertex for this neighbor to the current vertex.'
          ],
          level: 3,
        ),
        _Row(
          isHighlighted: positions.contains(Position.markVisited),
          text: const ['Mark the current vertex as visited.'],
          level: 1,
        ),
        _Row(
          isHighlighted: positions.contains(Position.end),
          text: const ['3. End when all vertices have been visited.'],
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({super.key, required this.text, this.level = 0, this.isHighlighted = false});

  final List<String> text;
  final int level;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16.0 * level, top: 4.0, bottom: 4.0, right: 4.0),
      decoration: isHighlighted
          ? BoxDecoration(
              color: isHighlighted ? Colors.orange.shade700 : null,
              border: Border(
                left: BorderSide(
                  color: Colors.orange.shade900,
                  width: 4.0,
                ),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: text
            .map((e) => Text(
                  e,
                  style: TextStyle(
                    // color: isHighlighted ? Theme.of(context).colorScheme.surface : null,
                    fontSize: 12.0,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

enum Position {
  initialization,
  visit,
  neighborLoop,
  tentativeDistance,
  shouldUpdateDistanceAndPrevious,
  updateDistanceAndPrevious,
  markVisited,
  end,
}
