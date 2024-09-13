import 'dart:ui';

import 'package:algorithm_visualizer/features/dijkstra/models/edge.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';
import 'package:algorithm_visualizer/models/optional.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'test_state.dart';
part 'test_event.dart';

class TestBloc extends Bloc<TestEvent, TestState> {
  TestBloc({
    required List<Vertex> vertices,
    required List<Edge> edges,
  }) : super(TestState(
          vertices: vertices,
          edges: edges,
        )) {
    // Adds a new vertex
    on<VertexAdded>((VertexAdded event, Emitter<TestState> emit) {
      var verticesCopy = [...state.vertices];
      verticesCopy.add(event.vertex);

      emit(state.copyWith(vertices: verticesCopy));
    });

    // Updates (the position of) an existing vertex while dragging
    on<VertexUpdated>((VertexUpdated event, Emitter<TestState> emit) {
      var verticesCopy = [...state.vertices];
      for (var i = 0; i < verticesCopy.length; i++) {
        if (verticesCopy[i].id == event.vertex.id) {
          verticesCopy[i] = event.vertex;
          break;
        }
      }

      emit(state.copyWith(vertices: verticesCopy));
    });

    // Saves the info of the vertex that is currently being dragged
    on<StartVertexDragging>((StartVertexDragging event, Emitter<TestState> emit) {
      emit(state.copyWith(
        draggedVertexID: Optional<String>(event.draggedVertexID),
        dragStartOffset: Optional<Offset>(event.dragStartOffset),
      ));
    });

    // Resets the info of the vertex being dragged after the dragging is completed
    on<CompleteVertexDragging>((
      CompleteVertexDragging event,
      Emitter<TestState> emit,
    ) {
      emit(state.copyWith(
        draggedVertexID: const Optional<String?>(null),
        dragStartOffset: const Optional<Offset?>(null),
      ));
    });

    // Saves the vertex where the edge drawing started
    on<StartEdgeDrawing>((StartEdgeDrawing event, Emitter<TestState> emit) {
      emit(state.copyWith(startVertex: Optional<Vertex>(event.startVertex)));
    });

    // Updates the position of the temporary edge end
    on<UpdateTemporaryEdge>((UpdateTemporaryEdge event, Emitter<TestState> emit) {
      emit(state.copyWith(temporaryEdgeEnd: Optional<Offset>(event.temporaryEdgeEnd)));
    });

    // Resets the start vertex and the temporary edge end after the edge drawing is completed
    on<CompleteEdgeDrawing>((CompleteEdgeDrawing event, Emitter<TestState> emit) {
      emit(state.copyWith(
        startVertex: const Optional<Vertex?>(null),
        temporaryEdgeEnd: const Optional<Offset?>(null),
      ));
    });

    // Adds a new edge after the drawing is completed
    on<EdgeAdded>((EdgeAdded event, Emitter<TestState> emit) {
      var edgesCopy = [...state.edges];
      edgesCopy.add(event.edge);

      emit(state.copyWith(edges: edgesCopy));
    });

    // Updates (the position of) an existing edge
    on<EdgeUpdated>((EdgeUpdated event, Emitter<TestState> emit) {
      var edgesCopy = [...state.edges];
      for (var i = 0; i < edgesCopy.length; i++) {
        if (edgesCopy[i].id == event.edge.id) {
          edgesCopy[i] = event.edge;
          break;
        }
      }

      emit(state.copyWith(edges: edgesCopy));
    });

    // Selects/unselects a vertex
    on<VertexSelected>((VertexSelected event, Emitter<TestState> emit) {
      emit(state.copyWith(selectedVertexID: Optional<String?>(event.vertexID)));
    });

    // Deletes a vertex
    on<VertexDeleted>((VertexDeleted event, Emitter<TestState> emit) {
      var verticesCopy = [...state.vertices];
      verticesCopy.removeWhere((vertex) => vertex.id == event.vertexID);

      var edgesCopy = [...state.edges];
      edgesCopy.removeWhere((edge) =>
          edge.startVertex.id == event.vertexID ||
          edge.endVertex.id == event.vertexID);

      emit(
        state.copyWith(
            vertices: verticesCopy,
            edges: edgesCopy,
            selectedVertexID: const Optional<String?>(null)),
      );
    });

    // Selects/unselects a vertex
    on<EdgeSelected>((EdgeSelected event, Emitter<TestState> emit) {
      emit(state.copyWith(selectedEdgeID: Optional<String?>(event.edgeID)));
    });

    // Deletes a edge
    on<EdgeDeleted>((EdgeDeleted event, Emitter<TestState> emit) {
      var edgesCopy = [...state.edges];
      edgesCopy.removeWhere((edge) => edge.id == event.edgeID);

      emit(
        state.copyWith(
            edges: edgesCopy,
            selectedVertexID: const Optional<String?>(null)),
      );
    });

    on<GraphElementReset>((GraphElementReset event, Emitter<TestState> emit) {
      emit(state.copyWith(vertices: event.vertices, edges: event.edges));
    });

    on<EditModeToggled>((EditModeToggled event, Emitter<TestState> emit) {
      emit(state.copyWith(isEditing: event.isEditing, selectedVertexID: const Optional<String?>(null)));
    });
  }
}
