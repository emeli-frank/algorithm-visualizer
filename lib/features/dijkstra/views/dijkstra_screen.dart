import 'dart:math';

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

  final vertexRadius = 25.0;
  final edgeThickness = 2.0;
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
    var vertex = Vertex(id: Vertex.generateID(), offset: offset);
    graphBloc.add(VertexAdded(vertex: vertex));
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
                var updatedEdge = Edge(
                  id: edge.id,
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
            child: CustomPaint(
              size: Size.infinite,
              painter: GraphPainter(
                vertices: context.watch<GraphBloc>().state.vertices,
                edges: context.watch<GraphBloc>().state.edges,
                vertexRadius: vertexRadius,
                temporaryEdgeEnd: context.watch<GraphBloc>().state.temporaryEdgeEnd,
                startVertex: context.watch<GraphBloc>().state.startVertex?.offset,
                selectedVertexID: context.watch<GraphBloc>().state.selectedVertexID,
                selectedEdgeID: context.watch<GraphBloc>().state.selectedEdgeID,
              ),
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
    required this.vertices,
    required this.edges,
    this.temporaryEdgeEnd,
    this.startVertex,
    this.selectedVertexID,
    this.selectedEdgeID,
  });

  final List<Vertex> vertices;
  final List<Edge> edges;
  final double vertexRadius;
  final Offset? temporaryEdgeEnd;
  final Offset? startVertex;
  final String? selectedVertexID;
  final String? selectedEdgeID;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw edges
    final edgePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    final selectedEdgePaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 4;

    for (var edge in edges) {
      Paint paint = edge.id == selectedEdgeID ? selectedEdgePaint : edgePaint;
      canvas.drawLine(edge.startVertex.offset, edge.endVertex.offset, paint);
    }

    if (startVertex != null && temporaryEdgeEnd != null) {
      canvas.drawLine(startVertex!, temporaryEdgeEnd!, edgePaint..color = Colors.grey);
    }

    // Draw vertices
    const vertexFillColor = Colors.white;
    const vertexFocusedFillColor = Colors.orange;

    final vertexFillPaint = Paint()
      ..color = vertexFillColor
      ..style = PaintingStyle.fill;

    final vertexFocusFillPaint = Paint()
      ..color = vertexFocusedFillColor
      ..style = PaintingStyle.fill;

    final vertexBorderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    for (var vertex in vertices) {
      if (selectedVertexID != null && vertex.id == selectedVertexID) {
        canvas.drawCircle(vertex.offset, vertexRadius, vertexFocusFillPaint);
      } else {
        canvas.drawCircle(vertex.offset, vertexRadius, vertexFillPaint);
      }
      canvas.drawCircle(vertex.offset, vertexRadius, vertexBorderPaint);
    }
  }

  @override
  bool shouldRepaint(GraphPainter oldDelegate) {
    return oldDelegate.vertices != vertices ||
        oldDelegate.edges != edges ||
        oldDelegate.temporaryEdgeEnd != temporaryEdgeEnd ||
        oldDelegate.startVertex != startVertex ||
        oldDelegate.selectedVertexID != selectedVertexID ||
        oldDelegate.selectedEdgeID != selectedEdgeID;
  }
}
