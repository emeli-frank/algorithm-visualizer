import 'package:algorithm_visualizer/features/dijkstra/bloc/dijkstra_graph_bloc.dart';
import 'package:algorithm_visualizer/features/dijkstra/cubit/dijkstra_tool_selection_cubit.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          ToolBarButtons(
            onPressed: () {},
            iconData: Icons.undo,
            tooltip: 'Undo (Ctrl + Z)',
          ),
          ToolBarButtons(
            onPressed: () {},
            iconData: Icons.redo,
            tooltip: 'Redo (Ctrl + Shift + Z)',
          ),
          ToolBarButtons(
            onPressed: () {
              cubit.setSelection(DijkstraTools.pan);
            },
            iconData: Icons.pan_tool_outlined,
            isActive: cubit.state.selection == DijkstraTools.pan,
            tooltip: 'Move',
          ),
          ToolBarButtons(
            onPressed: () {
              cubit.setSelection(DijkstraTools.vertices);
            },
            iconData: Icons.device_hub_outlined,
            isActive: cubit.state.selection == DijkstraTools.vertices,
            tooltip: 'Add Vertex',
          ),
          ToolBarButtons(
            onPressed: () {
              cubit.setSelection(DijkstraTools.edge);
            },
            iconData: Icons.linear_scale_outlined,
            isActive: cubit.state.selection == DijkstraTools.edge,
            tooltip: 'Add Edge',
          ),
          ToolBarButtons(
            onPressed: () {},
            iconData: Icons.info_outline,
            tooltip: 'Algorithm Info',
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
    var toolSelectionCubit = context.watch<DijkstraToolSelectionCubit>();
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
        _startDraggingVertex(context, details.localPosition, context.read<DijkstraGraphBloc>().state.vertices);
      };

      onPanUpdateHandler = (details) {
        _updateVertexPosition(context, details.localPosition);
      };

      onPanEndHandler = (details) {
        _endDraggingVertex(context);
      };

      cursor = SystemMouseCursors.grab;

      if (context.watch<DijkstraGraphBloc>().state.isDragging) {
        cursor = SystemMouseCursors.grabbing;
      }
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
            painter: VertexPainter(
              vertices: context.watch<DijkstraGraphBloc>().state.vertices
                  .map((Vertex vertex) => vertex.toOffset()).toList(),
              vertexRadius: vertexRadius,
            ),
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
  const ToolBarButtons({super.key, required this.iconData, this.onPressed, this.isActive, required this.tooltip});

  final IconData iconData;
  final Function()? onPressed;
  final bool? isActive;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    var color = (isActive != null && isActive == true) ? Colors.deepOrange : Colors.black54; // todo:: get from theme data

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(
        iconData,
        color: color,
      ),
    );
  }
}
