import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';

class Vertex extends Equatable {
  const Vertex({required this.id, required this.dx, required this.dy});

  factory Vertex.fromOffset({required String id, required Offset offset}) {
    return Vertex(id: id, dx: offset.dx, dy: offset.dy);
  }

  final String id;
  final double dx;
  final double dy;

  @override
  List<Object> get props => [id, dx, dy];

  Offset toOffset() {
    return Offset(dx, dy);
  }

  static String generateID() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(16, (index) => chars[rand.nextInt(chars.length)]).join();
  }
}
