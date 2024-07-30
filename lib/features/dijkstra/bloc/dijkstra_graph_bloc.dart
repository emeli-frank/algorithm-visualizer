import 'dart:ui';

import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';
import 'package:algorithm_visualizer/models/optional.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'dijkstra_graph_state.dart';
part 'dijkstra_graph_event.dart';

class DijkstraGraphBloc extends Bloc<DijkstraGraphEvent, DijkstraGraphState> {
  DijkstraGraphBloc() : super(DijkstraGraphState()) {
    on<DijkstraGraphVerticesAdded>((DijkstraGraphVerticesAdded event, Emitter<DijkstraGraphState> emit) {
      var verticesCopy = [...state.vertices];
      verticesCopy.add(event.vertex);

      emit(state.copyWith(vertices: verticesCopy));
    });

    on<DijkstraGraphVerticesUpdated>((DijkstraGraphVerticesUpdated event, Emitter<DijkstraGraphState> emit) {
      var verticesCopy = [...state.vertices];
      for (var i = 0; i < verticesCopy.length; i++) {
        if (verticesCopy[i].id == event.vertex.id) {
          verticesCopy[i] = event.vertex;
          break;
        }
      }

      emit(state.copyWith(vertices: verticesCopy));
    });

    on<DijkstraGraphVerticesMoved>((DijkstraGraphVerticesMoved event, Emitter<DijkstraGraphState> emit) {
      emit(state.copyWith(draggedVertex: Optional<Vertex>(event.draggedVertex), dragStartOffset: Optional<Offset>(event.dragStartOffset)));
    });

    on<DijkstraGraphVerticesDragStopped>((DijkstraGraphVerticesDragStopped event, Emitter<DijkstraGraphState> emit) {
      emit(state.copyWith(draggedVertex: const Optional<Vertex?>(null), dragStartOffset: const Optional<Offset?>(null)));
    });
  }
}
