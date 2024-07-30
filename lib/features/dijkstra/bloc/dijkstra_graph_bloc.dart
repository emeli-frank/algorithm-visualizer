import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'dijkstra_graph_state.dart';
part 'dijkstra_graph_event.dart';

class DijkstraGraphBloc extends Bloc<DijkstraGraphEvent, DijkstraGraphState> {
  DijkstraGraphBloc() : super(DijkstraGraphState()) {
    on<DijkstraGraphVerticesAdded>((DijkstraGraphVerticesAdded event, Emitter<DijkstraGraphState> emit) {
      var verticesCopy = [...state.vertices];
      verticesCopy.add(event.vertex);
      emit(DijkstraGraphState(vertex: verticesCopy));
    });

    on<DijkstraGraphVerticesUpdated>((DijkstraGraphVerticesUpdated event, Emitter<DijkstraGraphState> emit) {
      var verticesCopy = [...state.vertices];
      for (var i = 0; i < verticesCopy.length; i++) {
        if (verticesCopy[i].id == event.vertex.id) {
          verticesCopy[i] = event.vertex;
          break;
        }
      }

      emit(DijkstraGraphState(vertex: verticesCopy));
    });
  }
}
