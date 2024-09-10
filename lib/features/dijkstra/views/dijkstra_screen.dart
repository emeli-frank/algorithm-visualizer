import 'dart:math';

import 'package:algorithm_visualizer/exceptions/max_allowed_vertex_exceeded_exception.dart';
import 'package:algorithm_visualizer/features/dijkstra/bloc/animation_bloc.dart';
import 'package:algorithm_visualizer/features/dijkstra/bloc/graph_bloc.dart';
import 'package:algorithm_visualizer/features/dijkstra/cubit/tool_selection_cubit.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/edge.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';
import 'package:algorithm_visualizer/features/sidebar/cubit/sidebar_cubit.dart';
import 'package:algorithm_visualizer/utils/extensions/offset_extensions.dart';
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

    if (!isRunning && toolSelectionCubit.state.selection == DijkstraTools.vertices) {
      onTapHandler = (details) {
        _addVertex(context, details.localPosition);
      };

      cursor = SystemMouseCursors.precise;
    }

    if (!isRunning && toolSelectionCubit.state.selection == DijkstraTools.pan) {
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

    if (!isRunning && toolSelectionCubit.state.selection == DijkstraTools.edge) {
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

    Widget instructionWidgetChild = Container();

    if (context.watch<GraphBloc>().state.vertices.length < 2) {
      instructionWidgetChild = const Text('Add at least two vertices to begin.');
    } else if (!context.watch<AnimationBloc>().state.isRunning) {
      instructionWidgetChild = const Text('Select a start vertex and click the start button below to begin.');
    } else if (context.read<GraphBloc>().state.vertices.length < 2) {
      instructionWidgetChild = const Text('Add at least two vertices to begin.');
    } else if (!context.read<AnimationBloc>().state.distances.values.any((element) => element != double.infinity) && context.read<AnimationBloc>().state.isRunning) {
      instructionWidgetChild = Text('A table showing the distances of each vertex from the start vertex has now been created. In this table, all the distances from the starting vertex (${context.read<AnimationBloc>().state.startVertex?.label}) to every other vertex have been set to infinity as we haven\'t determined them yet.');
    } else if (context.read<AnimationBloc>().state.currentNeighbor != null &&
        context.read<AnimationBloc>().state.step == AnimationStep.findingCurrentEdge2) {
      final currentVertex = context.read<AnimationBloc>().state.currentVertex;
      final currentNeighbor = context.read<AnimationBloc>().state.currentNeighbor;
      final currentEdge = context.read<AnimationBloc>().state.currentEdge;
      final distances = context.read<AnimationBloc>().state.distances;
      final tentativeDistance = distances[currentVertex]! + currentEdge!.weight;

      instructionWidgetChild = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current total distance for the current vertex ${currentVertex?.label} is ${distances[currentVertex]}'),
          Text('Weight of the current edge is ${currentEdge?.weight}'),
          Text('Tentative distance ${distances[currentVertex]} + ${currentEdge!.weight} = $tentativeDistance'),
          Text('Total distance of the neighbor ${currentNeighbor?.label} is ${distances[currentNeighbor]}'),
          if (distances[currentNeighbor]! > tentativeDistance)
            Text('The total distance of vertex ${currentNeighbor?.label} is greater than the sum of the total distance of vertex ${currentVertex?.label} and the weight of the edge between them. The total distance of vertex ${currentNeighbor?.label} will be updated to $tentativeDistance'),
          if (distances[currentNeighbor]! <= tentativeDistance)
            Text('The total distance of vertex ${currentNeighbor?.label} which is ${distances[currentNeighbor]} is ${distances[currentNeighbor]! < tentativeDistance ? 'less than' : 'equal to'} the sum of the total distance of vertex ${currentVertex?.label} and the weight of the edge between them. The total distance of vertex ${currentNeighbor?.label} will remain ${distances[currentNeighbor]}'),
        ],
      );
    } else if (context.read<AnimationBloc>().state.currentNeighbor != null &&
        context.read<AnimationBloc>().state.step == AnimationStep.findingCurrentEdge) {
      final currentVertex = context.read<AnimationBloc>().state.currentVertex;
      final currentNeighbor = context.read<AnimationBloc>().state.currentNeighbor;
      final currentEdge = context.read<AnimationBloc>().state.currentEdge;
      final distances = context.read<AnimationBloc>().state.distances;
      final tentativeDistance = distances[currentVertex]! + currentEdge!.weight;

      String text;
      if (context.read<AnimationBloc>().state.tentativeDistanceUpdated ?? false) {
        text = 'The tentative distance of vertex ${currentNeighbor?.label} has been updated to $tentativeDistance.';
      } else {
        text = 'The tentative distance of vertex ${currentNeighbor?.label} remains unchanged.';
      }

      var isLastNeighbor = false;
      var neighbors = context.read<AnimationBloc>().state.neighbors;
      if (neighbors.isNotEmpty && neighbors.last == currentNeighbor) {
        isLastNeighbor = true;
      }
      if (!isLastNeighbor) {
        text += 'The algorithm will now move to the next neighbouring vertex.';
      }

      instructionWidgetChild = Text(text);
    } else if (context.read<AnimationBloc>().state.currVertexEdges.isNotEmpty) {
      final currentVertex = context.read<AnimationBloc>().state.currentVertex;
      final neighbors = context.read<AnimationBloc>().state.neighbors;
      if (neighbors.isEmpty) {
        instructionWidgetChild = Text('Vertex ${currentVertex?.label} has no neighbors');
      } else {
        var neighborLabel = neighbors.length > 1 ? 'neighbors' : 'neighbor';
        String neighborLabels = '';

        for (var i = 0; i < neighbors.length; i++) {
          neighborLabels += neighbors[i].label;

          if (i != neighbors.length - 1) { // neither the first nor the last element
            neighborLabels += ', ';
          }

          if (neighbors.length > 1 && i == neighbors.length - 2) { // last element
            neighborLabels += ' and ';
            continue;
          }
        }

        instructionWidgetChild = Text('The $neighborLabel: $neighborLabels of the current vertex, ${currentVertex?.label}, ${neighbors.length > 1 ? 'are' : 'is'} highlighted. These are the vertices directly connected to ${currentVertex?.label} via edges. The algorithm will now calculate the tentative shortest path to each of these neighbors.');
      }
    } else if (context.read<AnimationBloc>().state.step == AnimationStep.findingCurrentVertex &&
        context.read<AnimationBloc>().state.currentEdge == null &&
        context.read<AnimationBloc>().state.currentNeighbor == null) {
      instructionWidgetChild = Text('The vertex ${context.read<AnimationBloc>().state.currentVertex?.label} and its neighbours have been evaluated. It will be grayed out in the next step to indicate that it has been visited. The algorithm will now find the next vertex to visit.'); // todo:: describe the criteria for selecting the next vertex
    } else if (context.read<AnimationBloc>().state.currentVertex != null) {
      String reason;
      if (context.read<AnimationBloc>().state.currentVertex == context.read<AnimationBloc>().state.startVertex) {
        reason = 'it is the starting vertex';
      } else {
        reason = 'it is the unvisited vertex with the total lowest distance';
      }
      instructionWidgetChild = Text('Vertex ${context.read<AnimationBloc>().state.currentVertex?.label} is selected because $reason. This vertex is now the current point of consideration. The algorithm will evaluate the shortest path from this vertex to its neighboring vertices.');
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
                Positioned(
                  right: 0,
                  bottom: 60,
                  child: Container(
                    width: 200.0,
                    height: 400.0,
                    child: ListView.builder(
                      itemCount: context.watch<AnimationBloc>().state.distances.length,
                      itemBuilder: (context, index) {
                        var distance = context.watch<AnimationBloc>().state.distances.values.toList()[index];
                        var previous = context.watch<AnimationBloc>().state.previousVertices.values.toList()[index];
                        var vertex = context.watch<AnimationBloc>().state.distances.keys.toList()[index];
                        final visitedVertices = context.watch<AnimationBloc>().state.visitedEdges.map((e) => e.startVertex).toSet();
                        final currentVertex = context.watch<AnimationBloc>().state.currentVertex;
                        final currentNeighbor = context.watch<AnimationBloc>().state.currentNeighbor;
                        Color textColor;

                        if (visitedVertices.contains(vertex)) {
                          textColor = Colors.black12;
                        } else if (currentVertex != null && currentVertex.id == vertex.id) {
                          textColor = Colors.green;
                        } else if (currentNeighbor != null && currentNeighbor.id == vertex.id) {
                          textColor = Colors.yellow;
                        } else {
                          textColor = Colors.black;
                        }
                        
                        return Row(
                          children: [
                            Text(
                              vertex.label,
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 24.0),
                            Text(
                              distance == double.infinity ? '\u221E' : distance.toStringAsFixed(0),
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 24.0),
                            Text(
                              previous?.label ?? 'null',
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Controls for the animation
                Positioned(
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
                        Visibility(
                          visible: !context.watch<GraphBloc>().state.isEditing,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12.0, bottom: 20.0, right: 12.0, top: 4.0),
                            child: instructionWidgetChild,
                          ),
                        ),

                        // Animation controls
                        Visibility(
                          visible: !context.watch<GraphBloc>().state.isEditing,
                          child: Row(
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
                        ),
                      ],
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

class GraphPainter extends CustomPainter {
  GraphPainter({
    required this.vertexRadius,
    required this.edgeThickness,
    required this.vertices,
    required this.edges,
    this.temporaryEdgeEnd,
    this.startVertex,
    this.selectedVertexID,
    this.selectedEdgeID,
    this.currentVertexID,
    this.currentEdgeID,
    this.currVertexEdges = const [],
    required this.neighbors,
    this.currentNeighbor,
    required this.unvisitedVertices,
    required this.isAnimationRunning,
    required this.visitedEdges,
  });

  final List<Vertex> vertices;
  final List<Edge> edges;
  final double vertexRadius;
  final double edgeThickness;
  final Offset? temporaryEdgeEnd;
  final Offset? startVertex;
  final String? selectedVertexID;
  final String? selectedEdgeID;
  final String? currentVertexID;
  final String? currentEdgeID;
  final List<Edge> currVertexEdges;
  final List<Vertex> neighbors;
  final Vertex? currentNeighbor;
  final Set<Vertex> unvisitedVertices;
  final bool isAnimationRunning;
  final List<Edge> visitedEdges;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw edges
    _drawEdges(canvas, visitedEdges);

    // Draw vertices
    _drawVertices(canvas);
  }

  void _drawVertex({
    required Canvas canvas,
    required Vertex vertex,
    Color color = Colors.white,
    bool hasThickBorder = false,
    bool isVisited = false,
  }) {
    var borderThickness = hasThickBorder ? 2.5 : 1.0;
    var borderColor = isVisited ? Colors.black12 : Colors.black;
    color = isVisited ? const Color(0xFFEFF4E9) : color;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderThickness;

    // Draw the filled circle
    canvas.drawCircle(vertex.offset, vertexRadius, fillPaint);

    // Draw the border circle
    canvas.drawCircle(vertex.offset, vertexRadius - borderThickness + 1.5, borderPaint);
  }

  void _drawVertices(Canvas canvas) {
    const vertexFocusedFillColor = Colors.orange;

    // Iterate through all vertices
    for (var vertex in vertices) {
      var isVisited = !unvisitedVertices.contains(vertex) && currentVertexID != vertex.id && isAnimationRunning;

      if (currentVertexID != null && vertex.id == currentVertexID) {
        // If drawing the current visited vertex
        _drawVertex(canvas: canvas, vertex: vertex, hasThickBorder: true, color: Colors.green, isVisited: isVisited);
      } else if (selectedVertexID != null && vertex.id == selectedVertexID) {
        // If drawing the user-selected vertex
        _drawVertex(canvas: canvas, vertex: vertex, hasThickBorder: true, color: vertexFocusedFillColor, isVisited: isVisited);
      } else if (currentNeighbor != null && currentNeighbor!.id == vertex.id) {
        // If drawing the current neighbor being processed
        _drawVertex(canvas: canvas, vertex: vertex, hasThickBorder: true, color: Colors.yellow, isVisited: isVisited);
      } else if (neighbors.contains(vertex)) {
        // If drawing a neighbors of the current vertex
        _drawVertex(canvas: canvas, vertex: vertex, hasThickBorder: false, color: Colors.yellow, isVisited: isVisited);
      } else {
        // If drawing a regular vertex
        _drawVertex(canvas: canvas, vertex: vertex, hasThickBorder: false, isVisited: isVisited);
      }

      // Draw the label
      _drawVertexLabel(canvas, vertex, isVisited);
    }
  }

  void _drawVertexLabel(Canvas canvas, Vertex vertex, bool isVisited) {
    var color = isVisited ? Colors.black12 : Colors.black;

    // Prepare the label
    final textSpan = TextSpan(
      text: vertex.label,
      style: TextStyle(
        color:color,
        fontSize: 14.0,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Calculate the position to center the label on the vertex
    final textOffset = Offset(
      vertex.offset.dx - textPainter.width / 2,
      vertex.offset.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  void _drawEdges(Canvas canvas, List<Edge> visitedEdges) {
    // Define paint styles for different edge states
    final edgePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = edgeThickness;

    final selectedEdgePaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = edgeThickness + 2;

    final currentVertexEdgesPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = edgeThickness + 1.5;

    final currentEdgePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = edgeThickness + 1.5;

    const double arrowSize = 10.0;
    // Arrowhead angle in radians
    const double arrowAngle = 25 * (3.1416 / 180);

    // Iterate through all edges and determine the appropriate paint for each
    for (var edge in edges) {
      var visited = visitedEdges.contains(edge) && currentEdgeID != edge.id;
      Paint paint;

      // Determine paint based on edge's state
      if (edge.id == currentEdgeID) {
        paint = currentEdgePaint;
      } else if (currVertexEdges.contains(edge)) {
        paint = currentVertexEdgesPaint;
      } else if (edge.id == selectedEdgeID) {
        paint = selectedEdgePaint;
      } else {
        paint = Paint()
          ..color = visited ? Colors.black12 : Colors.black
          ..strokeWidth = edgeThickness;
      }

      // Draw the edge line
      canvas.drawLine(edge.startVertex.offset, edge.endVertex.offset, paint);

      // Calculate the direction of the edge to draw the arrow
      final dx = edge.endVertex.offset.dx - edge.startVertex.offset.dx;
      final dy = edge.endVertex.offset.dy - edge.startVertex.offset.dy;
      final angle = atan2(dy, dx);

      // Calculate the arrow position, moving it away from the end vertex
      final arrowEndX = edge.endVertex.offset.dx - vertexRadius * cos(angle);
      final arrowEndY = edge.endVertex.offset.dy - vertexRadius * sin(angle);

      // Calculate points for the arrowhead
      final arrowX1 = arrowEndX - arrowSize * cos(angle - arrowAngle);
      final arrowY1 = arrowEndY - arrowSize * sin(angle - arrowAngle);
      final arrowX2 = arrowEndX - arrowSize * cos(angle + arrowAngle);
      final arrowY2 = arrowEndY - arrowSize * sin(angle + arrowAngle);

      final path = Path()
        ..moveTo(arrowEndX, arrowEndY)  // Arrow tip
        ..lineTo(arrowX1, arrowY1)      // Left side of arrowhead
        ..lineTo(arrowX2, arrowY2)      // Right side of arrowhead
        ..close();

      // Draw the arrowhead
      canvas.drawPath(path, paint);

      // Draw the weight label at the midpoint of the edge
      final midPoint = Offset(
        (edge.startVertex.offset.dx + edge.endVertex.offset.dx) / 2,
        (edge.startVertex.offset.dy + edge.endVertex.offset.dy) / 2,
      );

      final textSpan = TextSpan(
        text: edge.weight.toString(),
        style: TextStyle(
          color: visited ? Colors.black12 : Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Calculate the position to draw the text so it is centered
      final offset = midPoint.translate(
        -textPainter.width / 2,
        -textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
    }

    // Draw a temporary edge if necessary (e.g., during edge creation)
    if (startVertex != null && temporaryEdgeEnd != null) {
      canvas.drawLine(
        startVertex!,
        temporaryEdgeEnd!,
        edgePaint..color = Colors.grey,
      );
    }
  }

  @override
  bool shouldRepaint(GraphPainter oldDelegate) {
    return oldDelegate.vertices != vertices ||
        oldDelegate.edges != edges ||
        oldDelegate.temporaryEdgeEnd != temporaryEdgeEnd ||
        oldDelegate.startVertex != startVertex ||
        oldDelegate.selectedVertexID != selectedVertexID ||
        oldDelegate.selectedEdgeID != selectedEdgeID ||
        oldDelegate.currentVertexID != currentVertexID ||
        oldDelegate.currVertexEdges != currVertexEdges ||
        oldDelegate.currentEdgeID != currentEdgeID ||
        oldDelegate.neighbors != neighbors ||
        oldDelegate.currentNeighbor != currentNeighbor ||
        oldDelegate.unvisitedVertices != unvisitedVertices ||
        oldDelegate.visitedEdges != visitedEdges;
  }
}

class EdgeWeightTextField extends StatefulWidget {
  const EdgeWeightTextField({super.key, required this.weight, required this.onWeightChanged});

  final int? weight;
  final Function(int) onWeightChanged;

  @override
  State<EdgeWeightTextField> createState() => _EdgeWeightTextFieldState();
}

class _EdgeWeightTextFieldState extends State<EdgeWeightTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.weight.toString() ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Weight',
        hintText: 'Enter the weight of the edge',
      ),
      onChanged: (value) {
        int weight = int.tryParse(value) ?? 1;
        widget.onWeightChanged(weight);
      },
    );
  }
}
