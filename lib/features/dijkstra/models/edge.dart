import 'dart:math';
import 'dart:ui';

import 'package:equatable/equatable.dart';

class Edge extends Equatable {
  const Edge({required this.id, required this.start, required this.end});

  final String id;
  final Offset start;
  final Offset end;

  @override
  List<Object> get props => [id, start, end];

  static String generateID() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(16, (index) => chars[rand.nextInt(chars.length)]).join();
  }
}
