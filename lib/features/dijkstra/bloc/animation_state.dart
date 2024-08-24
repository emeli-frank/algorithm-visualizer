part of 'animation_bloc.dart';

class AnimationState extends Equatable {
  AnimationState({
    vertices,
    edges,
  }) : vertices = vertices ?? [], edges = edges ?? [];

  final List<Vertex> vertices;
  final List<Edge> edges;

  @override
  List<Object> get props => [
    vertices,
    edges,
  ];
}
