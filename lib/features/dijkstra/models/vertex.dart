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

  Map<String, dynamic> toJson() => {
    'id': id,
    'offset': {'dx': offset.dx, 'dy': offset.dy},
  };

  factory Vertex.fromJson(Map<String, dynamic> json) {
    return Vertex(
      id: json['id'] as String,
      offset: Offset(
        (json['offset']['dx'] as num).toDouble(),
        (json['offset']['dy'] as num).toDouble(),
      ),
    );
  }
}
