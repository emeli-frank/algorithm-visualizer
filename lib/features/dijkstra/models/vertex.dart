import 'dart:ui';

import 'package:equatable/equatable.dart';

class Vertex extends Equatable {
  const Vertex({required this.id, required this.offset});

  final String id;
  final Offset offset;

  String get label {
    if (id.endsWith('1')) {
      return id.substring(0, 1);
    }
    return id;
  }

  @override
  List<Object> get props => [id, offset];
}
