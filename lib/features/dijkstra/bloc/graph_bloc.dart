import 'dart:ui';

import 'package:algorithm_visualizer/features/dijkstra/models/edge.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';
import 'package:algorithm_visualizer/models/optional.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'graph_state.dart';
part 'graph_event.dart';

class GraphBloc extends Bloc<GraphEvent, GraphState> {
  // Stack of previous states
  final List<GraphState> _undoStack = [];

  // Stack of future states
  final List<GraphState> _redoStack = [];

  // Offset of the vertex that was previously dragged. Used to determine if to
  // update undo/redo availability
  Offset? _previousVertexDragOffset;

  GraphBloc({
    required List<Vertex> vertices,
    required List<Edge> edges,
  }) : super(GraphState(
          vertices: vertices,
          edges: edges,
        )) {
    // Adds a new vertex
    on<VertexAdded>((VertexAdded event, Emitter<GraphState> emit) {
      _saveStateForUndo();

      var verticesCopy = [...state.vertices];
      verticesCopy.add(event.vertex);

      emit(state.copyWith(
        vertices: verticesCopy,
        canUndo: _undoStack.isNotEmpty,
        canRedo: _redoStack.isNotEmpty,
      ));
    });

    // Updates (the position of) an existing vertex while dragging
    on<VertexUpdated>((VertexUpdated event, Emitter<GraphState> emit) {
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
    on<StartVertexDragging>((StartVertexDragging event, Emitter<GraphState> emit) {
      _previousVertexDragOffset = event.dragStartOffset;

      emit(state.copyWith(
        draggedVertexID: Optional<String>(event.draggedVertexID),
        dragStartOffset: Optional<Offset>(event.dragStartOffset),
      ));
    });

    // Cleans up drag data after the dragging is completed
    on<CompleteVertexDragging>((
      CompleteVertexDragging event,
      Emitter<GraphState> emit,
    ) {
      if (_previousVertexDragOffset != null && _previousVertexDragOffset != event.offset) {
        var updatedVertices = state.vertices.map((vertex) {
          if (vertex.id == state.draggedVertexID) {
            return Vertex(id: vertex.id, offset: _previousVertexDragOffset!);
          }
          return vertex;
        }).toList();
        _saveStateForUndo(vertices: updatedVertices);
      }

      _previousVertexDragOffset = null;
      emit(state.copyWith(
        draggedVertexID: const Optional<String?>(null),
        dragStartOffset: const Optional<Offset?>(null),
        canUndo: _undoStack.isNotEmpty,
        canRedo: _redoStack.isNotEmpty,
      ));
    });

    // Saves the vertex where the edge drawing started
    on<StartEdgeDrawing>((StartEdgeDrawing event, Emitter<GraphState> emit) {
      emit(state.copyWith(startVertex: Optional<Vertex>(event.startVertex)));
    });

    // Updates the position of the temporary edge end
    on<UpdateTemporaryEdge>((UpdateTemporaryEdge event, Emitter<GraphState> emit) {
      emit(state.copyWith(temporaryEdgeEnd: Optional<Offset>(event.temporaryEdgeEnd)));
    });

    // Resets the start vertex and the temporary edge end after the edge drawing is completed
    on<CompleteEdgeDrawing>((CompleteEdgeDrawing event, Emitter<GraphState> emit) {
      emit(state.copyWith(
        startVertex: const Optional<Vertex?>(null),
        temporaryEdgeEnd: const Optional<Offset?>(null),
      ));
    });

    // Adds a new edge after the drawing is completed
    on<EdgeAdded>((EdgeAdded event, Emitter<GraphState> emit) {
      _saveStateForUndo();

      var edgesCopy = [...state.edges];
      edgesCopy.add(event.edge);

      emit(state.copyWith(
        edges: edgesCopy,
        canUndo: _undoStack.isNotEmpty,
        canRedo: _redoStack.isNotEmpty,
      ));
    });

    // Updates (the position of) an existing edge
    on<EdgeUpdated>((EdgeUpdated event, Emitter<GraphState> emit) {
      var edgesCopy = [...state.edges];
      for (var i = 0; i < edgesCopy.length; i++) {
        if (edgesCopy[i].id == event.edge.id) {
          edgesCopy[i] = event.edge;
          break;
        }
      }

      emit(state.copyWith(edges: edgesCopy));
    });

    // Updates edge's weight
    on<EdgeWeightUpdated>((EdgeWeightUpdated event, Emitter<GraphState> emit) {
      _saveStateForUndo();

      var edgesCopy = [...state.edges];
      for (var i = 0; i < edgesCopy.length; i++) {
        if (edgesCopy[i].id == event.edgeID) {
          edgesCopy[i] = edgesCopy[i].copyWith(weight: event.weight);
          break;
        }
      }

      emit(state.copyWith(
        edges: edgesCopy,
        canUndo: _undoStack.isNotEmpty,
        canRedo: _redoStack.isNotEmpty,
      ));
    });

    // Selects/unselects a vertex
    on<VertexSelected>((VertexSelected event, Emitter<GraphState> emit) {
      emit(state.copyWith(selectedVertexID: Optional<String?>(event.vertexID)));
    });

    // Deletes a vertex
    on<VertexDeleted>((VertexDeleted event, Emitter<GraphState> emit) {
      _saveStateForUndo();

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
          selectedVertexID: const Optional<String?>(null),
          canUndo: _undoStack.isNotEmpty,
          canRedo: _redoStack.isNotEmpty,
        ),
      );
    });

    // Selects/unselects a vertex
    on<EdgeSelected>((EdgeSelected event, Emitter<GraphState> emit) {
      emit(state.copyWith(selectedEdgeID: Optional<String?>(event.edgeID)));
    });

    // Deletes a edge
    on<EdgeDeleted>((EdgeDeleted event, Emitter<GraphState> emit) {
      _saveStateForUndo();

      var edgesCopy = [...state.edges];
      edgesCopy.removeWhere((edge) => edge.id == event.edgeID);

      emit(
        state.copyWith(
          edges: edgesCopy,
          selectedVertexID: const Optional<String?>(null),
          canUndo: _undoStack.isNotEmpty,
          canRedo: _redoStack.isNotEmpty,
        ),
      );
    });

    on<GraphElementReset>((GraphElementReset event, Emitter<GraphState> emit) {
      _saveStateForUndo();

      emit(state.copyWith(vertices: event.vertices, edges: event.edges));
    });

    on<EditModeToggled>((EditModeToggled event, Emitter<GraphState> emit) {
      emit(state.copyWith(
        isEditing: event.isEditing,
        selectedVertexID: const Optional<String?>(null),
        canUndo: _undoStack.isNotEmpty,
        canRedo: _redoStack.isNotEmpty,
      ));
    });

    // Undo event handler
    on<UndoEvent>((event, emit) {
      if (_undoStack.isNotEmpty) {
        // Push the current state to the redo stack before undoing
        _redoStack.add(state);

        // Pop from the undo stack and emit the previous state
        final previousState = _undoStack.removeLast();
        // Emit the previous state and update undo/redo availability

        emit(previousState.copyWith(
          canUndo: _undoStack.isNotEmpty,
          canRedo: _redoStack.isNotEmpty,
        ));
      }
    });

    // Redo event handler
    on<RedoEvent>((event, emit) {
      if (_redoStack.isNotEmpty) {
        // Push the current state to the undo stack before redoing
        _undoStack.add(state);

        // Pop from the redo stack and emit the future state
        final futureState = _redoStack.removeLast();

        // Emit the future state and update undo/redo availability
        emit(futureState.copyWith(
          canUndo: _undoStack.isNotEmpty,
          canRedo: _redoStack.isNotEmpty,
        ));
      }
    });
  }

  _saveStateForUndo({List<Vertex>? vertices}) {
    // Save the current state to the undo stack before modifying it
    _undoStack.add(state.copyWith(vertices: vertices));

    // Clear the redo stack because a new action invalidates future states
    _redoStack.clear();
  }
}
