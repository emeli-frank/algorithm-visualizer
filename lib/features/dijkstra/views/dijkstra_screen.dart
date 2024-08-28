import 'dart:math';

import 'package:algorithm_visualizer/exceptions/max_allowed_vertex_exceeded_exception.dart';
import 'package:algorithm_visualizer/features/dijkstra/bloc/animation_bloc.dart';
import 'package:algorithm_visualizer/features/dijkstra/bloc/graph_bloc.dart';
import 'package:algorithm_visualizer/features/dijkstra/cubit/tool_selection_cubit.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/edge.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';
import 'package:algorithm_visualizer/utils/extensions/offset_extensions.dart';
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

  // Save edge if tracing ends on a vertex
  void _endDrawingEdge(BuildContext context, Offset offset, List<Vertex> vertices) {
    final startVertex = context.read<GraphBloc>().state.startVertex;
    if (startVertex != null) {
      var vertex = _offsetWithinRadiusOfVertices(vertices, offset);
      if (vertex != null) {
        var edge = Edge(id: Edge.generateID(), startVertex: startVertex, endVertex: vertex);
        context.read<GraphBloc>().add(EdgeAdded(edge: edge));
      }
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

    if (toolSelectionCubit.state.selection == DijkstraTools.vertices) {
      onTapHandler = (details) {
        _addVertex(context, details.localPosition);
      };

      cursor = SystemMouseCursors.precise;
    }

    if (toolSelectionCubit.state.selection == DijkstraTools.pan) {
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

    if (toolSelectionCubit.state.selection == DijkstraTools.edge) {
      cursor = SystemMouseCursors.click;

      onPanStartHandler = (details) {
        _startDrawingEdge(context, details.localPosition, context.read<GraphBloc>().state.vertices);
      };

      onPanUpdateHandler = (details) {
        _updateTemporaryEdge(context, details.localPosition);
      };

      onPanEndHandler = (details) {
        _endDrawingEdge(context, details.localPosition, context.read<GraphBloc>().state.vertices);
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
                CustomPaint(
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
                Visibility(
                  visible: context.watch<GraphBloc>().state.selectedEdgeID != null,
                  child: Positioned(
                    bottom: 100,
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
                        return Row(
                          children: [
                            Text(vertex.id),
                            const SizedBox(width: 24.0),
                            Text(distance.toString()),
                            const SizedBox(width: 24.0),
                            Text(previous?.id ?? 'null'),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Visibility(
                          visible: !context.watch<AnimationBloc>().state.isRunning,
                          child: TextButton(
                            onPressed: () {
                              context.read<AnimationBloc>().add(AnimationStarted(
                                startVertex: context.read<GraphBloc>().state.vertices.first, // todo:: should be selected dynamically
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
                        Visibility(
                          visible: context.watch<AnimationBloc>().state.isRunning,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.skip_previous_outlined),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.play_arrow_outlined),
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
        _drawVertex(canvas: canvas, vertex: vertex, hasThickBorder: true, color: Colors.green, isVisited: isVisited);
      } else if (selectedVertexID != null && vertex.id == selectedVertexID) {
        _drawVertex(canvas: canvas, vertex: vertex, hasThickBorder: true, color: vertexFocusedFillColor, isVisited: isVisited);
      } else if (currentNeighbor != null && currentNeighbor!.id == vertex.id) {
        _drawVertex(canvas: canvas, vertex: vertex, hasThickBorder: true, color: Colors.yellow, isVisited: isVisited);
      } else if (neighbors.contains(vertex)) {
        _drawVertex(canvas: canvas, vertex: vertex, hasThickBorder: false, color: Colors.yellow, isVisited: isVisited);
      } else {
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

    // Iterate through all edges and determine the appropriate paint for each
    for (var edge in edges) {
      var visited = visitedEdges.contains(edge) && currentEdgeID != edge.id; // todo:: compare ids instead?
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

      // Draw the edge
      canvas.drawLine(edge.startVertex.offset, edge.endVertex.offset, paint);

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
