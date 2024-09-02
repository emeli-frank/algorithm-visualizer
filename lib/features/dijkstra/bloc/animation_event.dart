part of 'animation_bloc.dart';

sealed class AnimationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class AnimationStarted extends AnimationEvent {
  AnimationStarted({
    required this.startVertex,
    required this.vertices,
    required this.edges,
  });

  final Vertex startVertex;
  final List<Vertex> vertices;
  final List<Edge> edges;
}

final class AnimationNextStep extends AnimationEvent {}

final class AnimationEnded extends AnimationEvent {}

final class AnimationReset extends AnimationEvent {}

/*final class StartVertexSelected extends AnimationEvent {
  StartVertexSelected({required this.vertex});

  final Vertex vertex;
}*/
