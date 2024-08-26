import 'dart:ui';

import 'package:equatable/equatable.dart';

class Vertex extends Equatable {
  const Vertex({required this.id, required this.offset});

  final String id;
  final Offset offset;

  String get label => id;

  @override
  List<Object> get props => [id, offset];
}
