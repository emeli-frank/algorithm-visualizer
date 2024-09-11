import 'dart:math';

import 'package:algorithm_visualizer/exceptions/max_allowed_vertex_exceeded_exception.dart';
import 'package:algorithm_visualizer/features/dijkstra/bloc/animation_bloc.dart';
import 'package:algorithm_visualizer/features/dijkstra/bloc/graph_bloc.dart';
import 'package:algorithm_visualizer/features/dijkstra/cubit/tool_selection_cubit.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/edge.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';
import 'package:algorithm_visualizer/features/dijkstra/widgets/visualization_info.dart';
import 'package:algorithm_visualizer/features/dijkstra/widgets/edge_weight_text_field.dart';
import 'package:algorithm_visualizer/features/dijkstra/widgets/visualization_state_table.dart';
import 'package:algorithm_visualizer/features/sidebar/cubit/sidebar_cubit.dart';
import 'package:algorithm_visualizer/utils/extensions/offset_extensions.dart';
import 'package:algorithm_visualizer/widgets/graph_painter.dart';
import 'package:algorithm_visualizer/widgets/nav_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'appbar.dart';

class DijkstraScreen extends StatelessWidget {
  const DijkstraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        AppBar(),
        DijkstraCanvas(),
      ],
    );
  }
}

class DijkstraCanvas extends StatelessWidget {
  const DijkstraCanvas({super.key});

  final vertexRadius = 16.0;
  final edgeThickness = 1.0;
  final edgeClickableThickness = 8.0;

  bool _isPointOnLineSegment(double x1, double y1, double x2, double y2, double x, double y, double thickness) {
    // Calculate the distance from the point to the line
    double distance = ((y2 - y1) * x - (x2 - x1) * y + x2 * y1 - y2 * x1).abs() /
        sqrt(pow(y2 - y1, 2) + pow(x2 - x1, 2));

    // Check if the distance is within half the thickness of the line
    if (distance > thickness / 2) {
      return false;
    }

    // Check if the point is within the bounding box defined by the two coordinates
    bool withinXBounds = (x >= x1 && x <= x2) || (x >= x2 && x <= x1);
    bool withinYBounds = (y >= y1 && y <= y2) || (y >= y2 && y <= y1);

    return withinXBounds && withinYBounds;
  }

  Edge? _offsetOnLineSegment(List<Edge> edges, Offset offset) {
    for (var edge in edges) {
      var onSegment = _isPointOnLineSegment(
        edge.startVertex.offset.dx,
        edge.startVertex.offset.dy,
        edge.endVertex.offset.dx,
        edge.endVertex.offset.dy,
        offset.dx,
        offset.dy,
        edgeClickableThickness,
      );
      if (onSegment) {
        return edge;
      }
    }
    return null;
  }

  // Returns a vertex if the offset is within the radius of a vertex, otherwise returns null
  Vertex? _offsetWithinRadiusOfVertices(List<Vertex> vertices, Offset offset) {
    for (var vertex in vertices) {
      if (vertex.offset.isWithinRadius(offset, vertexRadius)) {
        return vertex;
      }
    }
    return null;
  }

  void _addVertex(BuildContext context, Offset offset) {
    var graphBloc = context.read<GraphBloc>();
    var vertex = Vertex(id: _getNextVertexID(context.read<GraphBloc>().state.vertices), offset: offset);
    graphBloc.add(VertexAdded(vertex: vertex));
  }

  String _getNextVertexID(List<Vertex> vertices) {
    const upperLimit = 9;

    final existingIDs = vertices.map((v) => v.id).toSet();

    for (var number = 1; number <= upperLimit; number++) {
      for (var letterCode = 'A'.codeUnitAt(0); letterCode <= 'Z'.codeUnitAt(0); letterCode++) {
        final letter = String.fromCharCode(letterCode);
        final potentialID = '$letter$number';

        if (!existingIDs.contains(potentialID)) {
          return potentialID;
        }
      }
    }

    throw MaxAllowedVertexExceededException();
  }

  void _startDraggingVertex(BuildContext context, Offset offset, List<Vertex> vertices) {
    var vertex = _offsetWithinRadiusOfVertices(vertices, offset);
    if (vertex != null) {
      context.read<GraphBloc>().add(StartVertexDragging(draggedVertexID: vertex.id, dragStartOffset: offset));
    }
  }

  // Update the position of the vertex that is being dragged
  void _updateVertexPosition(BuildContext context, Offset offset) {
    var graphBloc = context.read<GraphBloc>();

    if (graphBloc.state.isDraggingVertex) {
      // Get the difference between the current offset and the initial offset
      final dx = offset.dx - graphBloc.state.dragStartOffset!.dx;
      final dy = offset.dy - graphBloc.state.dragStartOffset!.dy;

      // Create a new vertex with the updated position
      var updatedVertex = Vertex(
        id: graphBloc.state.draggedVertexID!,
        offset: Offset(
          graphBloc.state.dragStartOffset!.dx + dx,
          graphBloc.state.dragStartOffset!.dy + dy,
        ),
      );

      graphBloc.add(VertexUpdated(vertex: updatedVertex));
    }
  }

  void _endDraggingVertex(BuildContext context) {
    context.read<GraphBloc>().add(CompleteVertexDragging());
  }

  // Set start vertex for edge drawing
  void _startDrawingEdge(BuildContext context, Offset offset, List<Vertex> vertices) {
    var vertex = _offsetWithinRadiusOfVertices(vertices, offset);
    if (vertex != null) {
      context.read<GraphBloc>().add(StartEdgeDrawing(startVertex: vertex));
    }
  }

  void _updateTemporaryEdge(BuildContext context, Offset offset) {
    context.read<GraphBloc>().add(UpdateTemporaryEdge(temporaryEdgeEnd: offset));
  }

  // Save edge if tracing ends on a valid vertex
  void _endDrawingEdge(BuildContext context, Offset offset, List<Vertex> vertices, List<Edge> edges) {
    final startVertex = context.read<GraphBloc>().state.startVertex;
    if (startVertex != null) {
      // Prevent creating duplicate edges and edges connecting same vertex
      var vertex = _offsetWithinRadiusOfVertices(vertices, offset);

      // Exit if no vertex is selected
      if (vertex == null) {
        context.read<GraphBloc>().add(CompleteEdgeDrawing());
        return;
      }

      // Prevent creating an edge that connects a vertex to itself
      if (vertex == startVertex) {
        context.read<GraphBloc>().add(CompleteEdgeDrawing());
        return;
      }

      // Prevent creating duplicate edges
      List<Vertex> verticesToExclude = [];

      for (var v in vertices) {
        for (var edge in edges) {
          if ((edge.startVertex.id == startVertex.id && edge.endVertex.id == v.id) || (edge.startVertex.id == v.id && edge.endVertex.id == startVertex.id)) {
            verticesToExclude.add(v);
          }
        }
      }

      if (verticesToExclude.contains(vertex)) {
        context.read<GraphBloc>().add(CompleteEdgeDrawing());
        return;
      }

      var edge = Edge(id: Edge.generateID(), startVertex: startVertex, endVertex: vertex);
      context.read<GraphBloc>().add(EdgeAdded(edge: edge));
    }

    context.read<GraphBloc>().add(CompleteEdgeDrawing());
  }

  void _selectOrUnselectVertexOrEdge(BuildContext context, Offset offset) {
    context.read<GraphBloc>().add(VertexSelected(vertexID: null));
    context.read<GraphBloc>().add(EdgeSelected(edgeID: null));

    var v = _offsetWithinRadiusOfVertices(context.read<GraphBloc>().state.vertices, offset);
    context.read<GraphBloc>().add(VertexSelected(vertexID: v?.id));
    if (v != null) {
      return;
    }

    var edge = _offsetOnLineSegment(context.read<GraphBloc>().state.edges, offset);
    context.read<GraphBloc>().add(EdgeSelected(edgeID: edge?.id));
  }

  @override
  Widget build(BuildContext context) {
    var toolSelectionCubit = context.watch<ToolSelectionCubit>();
    SystemMouseCursor cursor = SystemMouseCursors.basic;
    Function(TapUpDetails)? onTapHandler;
    Function(DragStartDetails)? onPanStartHandler;
    Function(DragUpdateDetails)? onPanUpdateHandler;
    Function(DragEndDetails)? onPanEndHandler;
    final isRunning = context.read<AnimationBloc>().state.isRunning;

    onPanStartHandler = (details) {
      _selectOrUnselectVertexOrEdge(context, details.localPosition);
    };

    if (!isRunning && toolSelectionCubit.state.selection == DijkstraTools.vertices && context.read<GraphBloc>().state.isEditing) {
      onTapHandler = (details) {
        _addVertex(context, details.localPosition);
      };

      cursor = SystemMouseCursors.precise;
    }

    if (!isRunning && toolSelectionCubit.state.selection == DijkstraTools.pan && context.read<GraphBloc>().state.isEditing) {
      onPanStartHandler = (details) {
        _selectOrUnselectVertexOrEdge(context, details.localPosition);
        _startDraggingVertex(context, details.localPosition, context.read<GraphBloc>().state.vertices);
      };

      onPanUpdateHandler = (details) {
        _updateVertexPosition(context, details.localPosition);
      };

      onPanEndHandler = (details) {
        _endDraggingVertex(context);
      };

      cursor = SystemMouseCursors.grab;

      if (context.watch<GraphBloc>().state.isDraggingVertex) {
        cursor = SystemMouseCursors.grabbing;
      }
    }

    if (!isRunning && toolSelectionCubit.state.selection == DijkstraTools.edge && context.read<GraphBloc>().state.isEditing) {
      cursor = SystemMouseCursors.click;

      onPanStartHandler = (details) {
        _startDrawingEdge(context, details.localPosition, context.read<GraphBloc>().state.vertices);
      };

      onPanUpdateHandler = (details) {
        _updateTemporaryEdge(context, details.localPosition);
      };

      onPanEndHandler = (details) {
        _endDrawingEdge(context, details.localPosition, context.read<GraphBloc>().state.vertices, context.read<GraphBloc>().state.edges);
      };
    }

    return Expanded(
      child: BlocListener<GraphBloc, GraphState>(
        listener: (context, state) {
          if (state.draggedVertexID != null) {
            for (var edge in state.edges) {
              if (edge.startVertex.id == state.draggedVertexID ||
                  edge.endVertex.id == state.draggedVertexID) {
                var vertices = context.read<GraphBloc>().state.vertices;
                var vertex = vertices
                    .firstWhere((element) => element.id == state.draggedVertexID);
                var startVertex = (edge.startVertex.id == state.draggedVertexID)
                    ? vertex
                    : edge.startVertex;
                var endVertex = (edge.endVertex.id == state.draggedVertexID)
                    ? vertex
                    : edge.endVertex;
                var updatedEdge = edge.copyWith(
                  startVertex: startVertex,
                  endVertex: endVertex,
                );
                context.read<GraphBloc>().add(EdgeUpdated(edge: updatedEdge));
              }
            }
          }
        },
        listenWhen: (previous, current) {
          return previous.vertices != current.vertices ||
              previous.edges != current.edges ||
              previous.selectedVertexID != current.selectedVertexID;
        },
        child: GestureDetector(
          onTapUp: onTapHandler,
          onPanStart: onPanStartHandler,
          onPanUpdate: onPanUpdateHandler,
          onPanEnd: onPanEndHandler,
          child: MouseRegion(
            cursor: cursor,
            child: Stack(
              children: [
                ClipRect(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: GraphPainter(
                      vertices: context.watch<GraphBloc>().state.vertices,
                      edges: context.watch<GraphBloc>().state.edges,
                      vertexRadius: vertexRadius,
                      edgeThickness: edgeThickness,
                      temporaryEdgeEnd: context.watch<GraphBloc>().state.temporaryEdgeEnd,
                      startVertex: context.watch<GraphBloc>().state.startVertex?.offset,
                      selectedVertexID: context.watch<GraphBloc>().state.selectedVertexID,
                      selectedEdgeID: context.watch<GraphBloc>().state.selectedEdgeID,
                      currentVertexID: context.watch<AnimationBloc>().state.currentVertex?.id,
                      currentEdgeID: context.watch<AnimationBloc>().state.currentEdge?.id,
                      currVertexEdges: context.watch<AnimationBloc>().state.currVertexEdges,
                      neighbors: context.watch<AnimationBloc>().state.neighbors,
                      currentNeighbor: context.watch<AnimationBloc>().state.currentNeighbor,
                      unvisitedVertices: context.watch<AnimationBloc>().state.unvisitedVertices,
                      isAnimationRunning: context.watch<AnimationBloc>().state.isRunning,
                      visitedEdges: context.watch<AnimationBloc>().state.visitedEdges,
                    ),
                  ),
                ),

                // Form field that allows you to change the weight of the selected edge
                Visibility(
                  visible: context.watch<GraphBloc>().state.selectedEdgeID != null,
                  child: Positioned(
                    bottom: 140,
                    child: SizedBox(
                      height: 40.0,
                      width: 60.0,
                      child: EdgeWeightTextField(
                        weight: context.watch<GraphBloc>().state.selectedEdge?.weight,
                        onWeightChanged: (weight) {
                          var selectedEdge = context.read<GraphBloc>().state.selectedEdge;
                          if (selectedEdge != null) {
                            var newEdge = selectedEdge.copyWith(weight: weight);
                            context.read<GraphBloc>().add(EdgeUpdated(edge: newEdge));
                          }
                        },
                      ),
                    ),
                  ),
                ),

                // Displays a table that shows the current state of the algorithm
                Visibility(
                  visible: context.watch<AnimationBloc>().state.isRunning,
                  child: const Positioned(
                    right: 8.0,
                    top: 30.0,
                    child: SizedBox(
                      width: 250.0,
                      height: 600.0,
                      child: SingleChildScrollView(
                        child: VisualizationStateTable(),
                      ),
                    ),
                  ),
                ),

                // Controls for the animation and visualization information
                Visibility(
                  visible: !context.watch<GraphBloc>().state.isEditing,
                  child: Positioned(
                    bottom: 16,
                    right: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Shows the visualization information to the user
                          const VisualizationInfo(),

                          // Animation controls
                          Row(
                            children: [
                              Visibility(
                                visible: !context.watch<AnimationBloc>().state.isRunning,
                                child: TextButton(
                                  onPressed: context.read<GraphBloc>().state.selectedVertexID == null ? null : () {
                                    context.read<GraphBloc>().add(VertexSelected(vertexID: null));
                                    context.read<AnimationBloc>().add(AnimationStarted(
                                      startVertex: context.read<GraphBloc>().state.vertices
                                          .firstWhere((v) => v.id == context.read<GraphBloc>().state.selectedVertexID),
                                      vertices: context.read<GraphBloc>().state.vertices,
                                      edges: context.read<GraphBloc>().state.edges,
                                    ));
                                  },
                                  child: const Text('Start'),
                                ),
                              ),
                              Visibility(
                                visible: context.watch<AnimationBloc>().state.isRunning,
                                child: TextButton(
                                  onPressed: () {
                                    context.read<AnimationBloc>().add(AnimationEnded());
                                  },
                                  child: const Text('End'),
                                ),
                              ),
                              const SizedBox(
                                height: 18.0,
                                width: 20.0,
                                child: VerticalDivider(width: 1, color: Colors.black12),
                              ),
                              const IconButton(
                                onPressed: null,
                                icon: Icon(Icons.play_arrow_outlined),
                              ),
                              IconButton(
                                onPressed: context.watch<AnimationBloc>().state.isComplete ? null : () {
                                  context.read<AnimationBloc>().add(AnimationNextStep());
                                },
                                icon: const Icon(Icons.skip_next_outlined),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
