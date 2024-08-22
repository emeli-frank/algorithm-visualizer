import 'dart:math';

import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';
import 'package:equatable/equatable.dart';

class Edge extends Equatable {
  const Edge({
    required this.id,
    required this.startVertex,
    required this.endVertex,
    this.weight = 1,
  });

  final String id;
  final Vertex startVertex;
  final Vertex endVertex;
  final int weight;

  @override
  List<Object> get props => [id, startVertex, endVertex];

  static String generateID() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(16, (index) => chars[rand.nextInt(chars.length)]).join();
  }
}
