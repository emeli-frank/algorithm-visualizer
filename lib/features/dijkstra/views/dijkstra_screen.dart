import 'package:algorithm_visualizer/features/dijkstra/bloc/dijkstra_graph_bloc.dart';
import 'package:algorithm_visualizer/features/dijkstra/cubit/dijkstra_tool_selection_cubit.dart';
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

  void _addVertex(BuildContext context, Offset offset) {
    var graphBloc = context.read<DijkstraGraphBloc>();
    graphBloc.add(DijkstraGraphVerticesAdded(vertices: offset));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapUp: (details) {
          _addVertex(context, details.localPosition);
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: VertexPainter(context.watch<DijkstraGraphBloc>().state.vertices),
        ),
      ),
    );
  }
}

class VertexPainter extends CustomPainter {
  final List<Offset> vertices;
  final double vertexRadius = 25.0;

  VertexPainter(this.vertices);

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
