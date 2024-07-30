import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'dijkstra_graph_state.dart';
part 'dijkstra_graph_event.dart';

class DijkstraGraphBloc extends Bloc<DijkstraGraphEvent, DijkstraGraphState> {
  DijkstraGraphBloc() : super(DijkstraGraphState()) {
    on<DijkstraGraphVerticesAdded>((DijkstraGraphVerticesAdded event, Emitter<DijkstraGraphState> emit) {
      var verticesCopy = [...state.vertices];
      verticesCopy.add(event.vertices);
      emit(DijkstraGraphState(vertices: verticesCopy));
    });
  }
}
