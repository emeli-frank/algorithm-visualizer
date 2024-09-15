part of 'dijkstra_screen.dart';

class AppBar extends StatelessWidget {
  const AppBar({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = context.watch<ToolSelectionCubit>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      height: 48.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Visibility(
                visible: !context.watch<SidebarCubit>().state.isOpen,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: NavIconButton(
                    iconData: Icons.menu_open_outlined,
                    onPressed: () {
                      context.read<SidebarCubit>().toggle(isOpen: true);
                    },
                    tooltip: 'Open sidebar',
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              const GraphTemplateDropdown(template: defaultTemplateKey),
              Visibility(
                visible: !context.watch<GraphBloc>().state.isEditing,
                child: TextButton(
                  onPressed: () {
                    context.read<GraphBloc>().add(EditModeToggled(isEditing: true));
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined, size: 16.0,),
                      SizedBox(width: 8),
                      Text('Edit graph'),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: !context.watch<GraphBloc>().state.isEditing && !kIsWeb,
                child: TextButton(
                  onPressed: () async {
                    try {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['json'],
                      );

                      if (result == null || result.files.single.path == null) {
                        // User canceled the picker
                        return;
                      }

                      // Get the file path
                      String filePath = result.files.single.path!;
                      File file = File(filePath);

                      // Read the file content as a string
                      String fileContent = await file.readAsString();

                      // Decode the JSON string to a Map or List
                      Map<String, dynamic> jsonData = jsonDecode(fileContent);

                      final GraphTemplateSample deserializedGraph = GraphTemplateSample.fromJson(jsonData);

                      context.read<GraphBloc>().add(GraphElementReset(vertices: deserializedGraph.vertices, edges: deserializedGraph.edges));
                    } catch(e) {
                      print(e);
                    }
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save_alt_outlined, size: 16.0,),
                      SizedBox(width: 8),
                      Text('Import graph'),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: !context.watch<GraphBloc>().state.isEditing && !kIsWeb,
                child: TextButton(
                  onPressed: () async {
                    final vertices = context.read<GraphBloc>().state.vertices;
                    final edges = context.read<GraphBloc>().state.edges;
                    final template = GraphTemplateSample(vertices: vertices, edges: edges);
                    final String graphJson = jsonEncode(template.toJson());
                    print('Serialized Graph: $graphJson');

                    String? outputPath = await FilePicker.platform.saveFile(
                      dialogTitle: 'Save Graph as JSON',
                      fileName: 'graph.json',
                    );

                    if (outputPath == null) {
                      return;
                    }

                    try {
                      File file = File(outputPath);
                      await file.writeAsString(graphJson);
                    } catch (e) {
                      /*ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save the file: $e')),
                      );*/
                      print(e);
                    }
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.upload_outlined, size: 16.0,),
                      SizedBox(width: 8),
                      Text('Export graph'),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: context.watch<GraphBloc>().state.isEditing,
                child: TextButton(
                  onPressed: () {
                    context.read<GraphBloc>().add(EditModeToggled(isEditing: false));
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 16.0,),
                      SizedBox(width: 8),
                      Text('Complete edit'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Visibility(
                visible: context.watch<GraphBloc>().state.isEditing,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    NavIconButton(
                      onPressed: context.watch<GraphBloc>().state.canUndo ? () {
                        context.read<GraphBloc>().add(UndoEvent());
                      } : null,
                      iconData: Icons.undo,
                      tooltip: 'Undo (Ctrl + Z)',
                    ),
                    NavIconButton(
                      onPressed: context.watch<GraphBloc>().state.canRedo ? () {
                        context.read<GraphBloc>().add(RedoEvent());
                      } : null,
                      iconData: Icons.redo,
                      tooltip: 'Redo (Ctrl + Shift + Z)',
                    ),
                    // Add vertical demarcation
                    const SizedBox(
                      height: 18.0,
                      width: 20.0,
                      child: VerticalDivider(width: 1, color: Colors.black12),
                    ),
                    NavIconButton(
                      onPressed: () {
                        cubit.setSelection(DijkstraTools.pan);
                      },
                      iconData: Icons.pan_tool_outlined,
                      isActive: cubit.state.selection == DijkstraTools.pan,
                      tooltip: 'Move',
                    ),
                    NavIconButton(
                      onPressed: () {
                        cubit.setSelection(DijkstraTools.vertices);
                      },
                      iconData: Icons.spoke_outlined,
                      isActive: cubit.state.selection == DijkstraTools.vertices,
                      tooltip: 'Add Vertex',
                    ),
                    NavIconButton(
                      onPressed: () {
                        cubit.setSelection(DijkstraTools.edge);
                      },
                      iconData: Icons.linear_scale_outlined,
                      isActive: cubit.state.selection == DijkstraTools.edge,
                      tooltip: 'Add Edge',
                    ),
                    const SizedBox(
                      height: 18.0,
                      width: 20.0,
                      child: VerticalDivider(width: 1, color: Colors.black12),
                    ),
                    Visibility(
                      visible:
                      context.watch<GraphBloc>().state.selectedVertexID != null ||
                          context.watch<GraphBloc>().state.selectedEdgeID != null,
                      child: NavIconButton(
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
                    Visibility(
                      visible: context.watch<GraphBloc>().state.vertices.isNotEmpty,
                      child: NavIconButton(
                        onPressed: () {
                          context.read<GraphBloc>().add(GraphElementReset(vertices: const [], edges: const []));
                        },
                        iconData: Icons.clear,
                        tooltip: 'Clear graph',
                      ),
                    ),
                    const SizedBox(
                      height: 18.0,
                      width: 20.0,
                      child: VerticalDivider(width: 1, color: Colors.black12),
                    ),
                  ],
                ),
              ),
              NavIconButton(
                onPressed: () {},
                iconData: Icons.info_outline,
                tooltip: 'Algorithm Info',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GraphTemplateDropdown extends StatefulWidget {
  const GraphTemplateDropdown({super.key, required this.template});

  final String template;

  @override
  State<GraphTemplateDropdown> createState() => _GraphTemplateDropdownState();
}

class _GraphTemplateDropdownState extends State<GraphTemplateDropdown> {
  late String _template;

  @override
  void initState() {
    super.initState();
    _template = widget.template;
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> prebuiltTemplates = [];
    final templates = getPreBuiltGraphTemplate();

    for (var templateName in templates.keys) {
      prebuiltTemplates.add(DropdownMenuItem(
        value: templateName,
        child: Text(templateName),
      ));
    }

    return DropdownButton<String>(
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 14.0,
      ),
      underline: const SizedBox.shrink(),
      value: _template.toString(),
      items: [
        DropdownMenuItem(
          value: customTemplateKey,
          enabled: _template != customTemplateKey,
          child: const Text('Custom'),
        ),
        ...prebuiltTemplates,
        const DropdownMenuItem(
          value: randomTemplateKey,
          child: Text('Random'),
        ),
      ],
      onChanged: (value) {
        if (value == null ||
            (value == _template && value != randomTemplateKey)) return;

        setState(() {
          if (value == customTemplateKey) {
            _template = customTemplateKey;
          } else if (value == randomTemplateKey) {
            _template = randomTemplateKey;
          } else {
            _template = value;
          }
        });

        final template = getGraphTemplate(value);
        final vertices = template.vertices;
        final edges = template.edges;

        context.read<AnimationBloc>().add(AnimationReset());
        context.read<GraphBloc>().add(GraphElementReset(vertices: vertices, edges: edges));
        context.read<GraphBloc>().add(EditModeToggled(isEditing: value == customTemplateKey));
      },
    );
  }
}
