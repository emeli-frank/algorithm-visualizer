part of 'dijkstra_screen.dart';

enum GraphTemplate {
  custom,
  sample1,
  random,
}

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
          const GraphTemplateDropdown(template: GraphTemplate.custom),
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

class GraphTemplateDropdown extends StatefulWidget {
  const GraphTemplateDropdown({super.key, required this.template});

  final GraphTemplate template;

  @override
  State<GraphTemplateDropdown> createState() => _GraphTemplateDropdownState();
}

class _GraphTemplateDropdownState extends State<GraphTemplateDropdown> {
  late GraphTemplate _template;

  @override
  void initState() {
    super.initState();
    _template = widget.template;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<GraphTemplate>(
      value: _template,
      items: [
        DropdownMenuItem(
          value: GraphTemplate.custom,
          enabled: _template != GraphTemplate.custom,
          child: const Text('Custom'),
        ),
        DropdownMenuItem(
          value: GraphTemplate.sample1,
          enabled: _template != GraphTemplate.sample1,
          child: const Text('Sample 1'),
        ),
        const DropdownMenuItem(
          value: GraphTemplate.random,
          child: Text('Random'),
        ),
      ],
      onChanged: (value) {
        if (value == null ||
            (value == _template && value != GraphTemplate.random)) return;

        setState(() {
          _template = value;
        });

        List<Vertex> vertices = [];
        List<Edge> edges = [];

        switch (value) {
          case GraphTemplate.custom:
            break;
          case GraphTemplate.sample1:
          // todo:: move to a separate file
            vertices = const [
              Vertex(id: '1', offset: Offset(256.4, 61.8)),
              Vertex(id: '2', offset: Offset(82.5, 90.2)),
              Vertex(id: '3', offset: Offset(152.5, 131.1)),
              Vertex(id: '4', offset: Offset(248.2, 157.5)),
              Vertex(id: '5', offset: Offset(154.4, 39.5)),
              Vertex(id: '6', offset: Offset(91.5, 198.7)),
              Vertex(id: '7', offset: Offset(191.7, 219.2)),
            ];
            edges = [
              Edge(id: '1', startVertex: vertices[0], endVertex: vertices[1], weight: 2),
              Edge(id: '2', startVertex: vertices[0], endVertex: vertices[2], weight: 3),
              Edge(id: '3', startVertex: vertices[0], endVertex: vertices[3], weight: 1),
              Edge(id: '4', startVertex: vertices[1], endVertex: vertices[4], weight: 1),
              Edge(id: '5', startVertex: vertices[2], endVertex: vertices[5], weight: 2),
              Edge(id: '6', startVertex: vertices[3], endVertex: vertices[6], weight: 3),
              Edge(id: '7', startVertex: vertices[4], endVertex: vertices[6], weight: 1),
              Edge(id: '8', startVertex: vertices[5], endVertex: vertices[6], weight: 2),
            ];
            break;
          case GraphTemplate.random:
          // todo:: refine this logic
            vertices = List.generate(8, (index) {
              return Vertex(
                id: index.toString(),
                offset: Offset(50 + Random().nextDouble() * 400, 50 + Random().nextDouble() * 400),
              );
            });
            break;
        }

        context.read<AnimationBloc>().add(AnimationReset());
        context.read<GraphBloc>().add(GraphElementReset(vertices: vertices, edges: edges));
      },
    );
  }
}

