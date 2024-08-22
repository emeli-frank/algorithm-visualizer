part of 'dijkstra_screen.dart';

class AppBar extends StatelessWidget {
  const AppBar({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = context.watch<ToolSelectionCubit>();

    return Container(
      color: Colors.white,
      height: 54.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Visibility(
            visible:
                context.watch<GraphBloc>().state.selectedVertexID != null ||
                    context.watch<GraphBloc>().state.selectedEdgeID != null,
            child: ToolBarButtons(
              onPressed: () {
                var selectedVertexID = context.read<GraphBloc>().state.selectedVertexID;
                if (selectedVertexID != null) {
                  context.read<GraphBloc>().add(
                        VertexDeleted(vertexID: selectedVertexID),
                      );
                  return;
                }

                var selectedEdgeID = context.read<GraphBloc>().state.selectedEdgeID;
                if (selectedEdgeID != null) {
                  context.read<GraphBloc>().add(
                    EdgeDeleted(edgeID: selectedEdgeID),
                  );
                }
              },
              iconData: Icons.delete_outline,
              tooltip: 'Delete (Del)',
            ),
          ),
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
