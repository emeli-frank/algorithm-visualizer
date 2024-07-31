import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';

class Vertex extends Equatable {
  const Vertex({required this.id, required this.offset});

  final String id;
  final Offset offset;

  @override
  List<Object> get props => [id, offset];

  static String generateID() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(16, (index) => chars[rand.nextInt(chars.length)]).join();
  }
}
