import 'package:algorithm_visualizer/features/dijkstra/bloc/dijkstra_graph_bloc.dart';
import 'package:algorithm_visualizer/features/dijkstra/cubit/dijkstra_tool_selection_cubit.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DijkstraScreen extends StatelessWidget {
  const DijkstraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(),
        DijkstraCanvas(),
      ],
    );
  }
}

class AppBar extends StatelessWidget {
  const AppBar({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = context.watch<DijkstraToolSelectionCubit>();

    return Container(
      color: Colors.white,
      height: 54.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.undo),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.redo),
          ),
          ToolBarButtons(
            onPressed: () {
              cubit.setSelection(DijkstraTools.pan);
            },
            iconData: Icons.pan_tool_outlined,
            isActive: cubit.state.selection == DijkstraTools.pan,
          ),
          ToolBarButtons(
            onPressed: () {
              cubit.setSelection(DijkstraTools.vertices);
            },
            iconData: Icons.device_hub_outlined,
            isActive: cubit.state.selection == DijkstraTools.vertices,
          ),
          ToolBarButtons(
            onPressed: () {
              cubit.setSelection(DijkstraTools.edge);
            },
            iconData: Icons.linear_scale_outlined,
            isActive: cubit.state.selection == DijkstraTools.edge,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}

class DijkstraCanvas extends StatelessWidget {
  const DijkstraCanvas({super.key});

  final vertexRadius = 25.0;

  void _addVertex(BuildContext context, Offset offset) {
    var graphBloc = context.read<DijkstraGraphBloc>();
    var vertex = Vertex.fromOffset(id: Vertex.generateID(), offset: offset);
    graphBloc.add(DijkstraGraphVerticesAdded(vertex: vertex));
  }

  void _startDraggingVertex(BuildContext context, Offset offset, List<Vertex> vertices) {
    for (var vertex in vertices) {
      if ((vertex.toOffset() - offset).distance <= vertexRadius) {
        context.read<DijkstraGraphBloc>().add(DijkstraGraphVerticesMoved(draggedVertex: vertex, dragStartOffset: offset));
        break;
      }
    }
  }

  void _updateVertexPosition(BuildContext context, Offset offset) {
    var graphBloc = context.read<DijkstraGraphBloc>();

    if (graphBloc.state.isDragging) {
      final dx = offset.dx - graphBloc.state.dragStartOffset!.dx;
      final dy = offset.dy - graphBloc.state.dragStartOffset!.dy;

      var updatedVertex = Vertex(id: graphBloc.state.draggedVertex!.id, dx: graphBloc.state.dragStartOffset!.dx + dx, dy: graphBloc.state.dragStartOffset!.dy + dy);
      graphBloc.add(DijkstraGraphVerticesUpdated(vertex: updatedVertex));
    }
  }

  void _endDraggingVertex(BuildContext context) {
    context.read<DijkstraGraphBloc>().add(DijkstraGraphVerticesDragStopped());
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapUp: (details) {
          _addVertex(context, details.localPosition);
        },
        onPanStart: (details) {
          _startDraggingVertex(context, details.localPosition, context.read<DijkstraGraphBloc>().state.vertices);
        },
        onPanUpdate: (details) {
          _updateVertexPosition(context, details.localPosition);
        },
        onPanEnd: (details) {
          _endDraggingVertex(context);
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: VertexPainter(
            vertices: context.watch<DijkstraGraphBloc>().state.vertices
                .map((Vertex vertex) => vertex.toOffset()).toList(),
            vertexRadius: vertexRadius,
          ),
        ),
      ),
    );
  }
}

class VertexPainter extends CustomPainter {
  VertexPainter({required this.vertexRadius, required this.vertices});

  final List<Offset> vertices;
  final double vertexRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    for (var vertex in vertices) {
      canvas.drawCircle(vertex, vertexRadius, paint);
      canvas.drawCircle(vertex, vertexRadius, borderPaint);
    }
  }

  @override
  bool shouldRepaint(VertexPainter oldDelegate) {
    return oldDelegate.vertices != vertices;
  }
}

class ToolBarButtons extends StatelessWidget {
  const ToolBarButtons({super.key, required this.iconData, this.onPressed, this.isActive});

  final IconData iconData;
  final Function()? onPressed;
  final bool? isActive;

  @override
  Widget build(BuildContext context) {
    var color = (isActive != null && isActive == true) ? Colors.deepOrange : Colors.black54; // todo:: get from theme data

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        iconData,
        color: color,
      ),
    );
  }
}
