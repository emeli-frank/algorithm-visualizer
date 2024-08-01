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

  // Returns a vertex if the offset is within the radius of a vertex, otherwise returns null
  Vertex? _isOffsetWithinRadiusOfVertices(List<Vertex> vertices, Offset offset) {
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
    graphBloc.add(VerticesAdded(vertex: vertex));
  }

  void _startDraggingVertex(BuildContext context, Offset offset, List<Vertex> vertices) {
    var vertex = _isOffsetWithinRadiusOfVertices(vertices, offset);
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

      graphBloc.add(VerticesUpdated(vertex: updatedVertex));
    }
  }

  void _endDraggingVertex(BuildContext context) {
    context.read<GraphBloc>().add(CompleteVertexDragging());
  }

  // Set start vertex for edge drawing
  void _startDrawingEdge(BuildContext context, Offset offset, List<Vertex> vertices) {
    var vertex = _isOffsetWithinRadiusOfVertices(vertices, offset);
    if (vertex != null) {
      context.read<GraphBloc>().add(StartEdgeDrawing(startVertexOffset: vertex.offset));
    }
  }

  void _updateTemporaryEdge(BuildContext context, Offset offset) {
    context.read<GraphBloc>().add(UpdateTemporaryEdge(temporaryEdgeEnd: offset));
  }

  // Save edge if tracing ends on a vertex
  void _endDrawingEdge(BuildContext context, Offset offset, List<Vertex> vertices) {
    final startVertex = context.read<GraphBloc>().state.startVertexOffset;
    if (startVertex != null) {
      var vertex = _isOffsetWithinRadiusOfVertices(vertices, offset);
      if (vertex != null) {
        var edge = Edge(id: Edge.generateID(), start: startVertex, end: vertex.offset);
        context.read<GraphBloc>().add(EdgeAdded(edge: edge));
      }
    }

    context.read<GraphBloc>().add(CompleteEdgeDrawing());
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
              startVertex: context.watch<GraphBloc>().state.startVertexOffset,
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
  });

  final List<Vertex> vertices;
  final List<Edge> edges;
  final double vertexRadius;
  final Offset? temporaryEdgeEnd;
  final Offset? startVertex;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw edges
    final edgePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    for (var edge in edges) {
      canvas.drawLine(edge.start, edge.end, edgePaint);
    }

    if (startVertex != null && temporaryEdgeEnd != null) {
      canvas.drawLine(startVertex!, temporaryEdgeEnd!, edgePaint..color = Colors.grey);
    }

    // Draw vertices
    final vertexPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final vertexBorderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    for (var vertex in vertices) {
      canvas.drawCircle(vertex.offset, vertexRadius, vertexPaint);
      canvas.drawCircle(vertex.offset, vertexRadius, vertexBorderPaint);
    }
  }

  @override
  bool shouldRepaint(GraphPainter oldDelegate) {
    return oldDelegate.vertices != vertices ||
        oldDelegate.edges != edges ||
        oldDelegate.temporaryEdgeEnd != temporaryEdgeEnd ||
        oldDelegate.startVertex != startVertex;
  }
}
