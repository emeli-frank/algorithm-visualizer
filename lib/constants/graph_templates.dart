import 'dart:math';
import 'dart:ui';

import 'package:algorithm_visualizer/features/dijkstra/models/edge.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';

class GraphTemplateSample {
  GraphTemplateSample({required this.vertices, required this.edges});

  final List<Vertex> vertices;
  final List<Edge> edges;
}

/*
* Pre-built graph templates
*/

const customTemplateKey = 'Custom';
const randomTemplateKey = 'Random';
const template1key = 'Template 1';
const defaultTemplateKey = template1key;

var _vertices1 = const [
  Vertex(id: 'A1', offset: Offset(256.4, 61.8)),
  Vertex(id: 'B1', offset: Offset(82.5, 90.2)),
  Vertex(id: 'C1', offset: Offset(152.5, 131.1)),
  Vertex(id: 'D1', offset: Offset(248.2, 157.5)),
  Vertex(id: 'E1', offset: Offset(154.4, 39.5)),
  Vertex(id: 'F1', offset: Offset(91.5, 198.7)),
  Vertex(id: 'G1', offset: Offset(191.7, 219.2)),
];

final _template1 = GraphTemplateSample(
  vertices: _vertices1,
  edges: [
    Edge(id: '1', startVertex: _vertices1[0], endVertex: _vertices1[1], weight: 2),
    Edge(id: '2', startVertex: _vertices1[0], endVertex: _vertices1[2], weight: 3),
    Edge(id: '3', startVertex: _vertices1[0], endVertex: _vertices1[3], weight: 1),
    Edge(id: '4', startVertex: _vertices1[1], endVertex: _vertices1[4], weight: 1),
    Edge(id: '5', startVertex: _vertices1[2], endVertex: _vertices1[5], weight: 2),
    Edge(id: '6', startVertex: _vertices1[3], endVertex: _vertices1[6], weight: 3),
    Edge(id: '7', startVertex: _vertices1[4], endVertex: _vertices1[6], weight: 1),
    Edge(id: '8', startVertex: _vertices1[5], endVertex: _vertices1[6], weight: 2),
  ],
);

Map<String, GraphTemplateSample> _templates = {
  template1key: _template1,
};

GraphTemplateSample getGraphTemplate(String key) {
  if (key == randomTemplateKey) { // todo:: update logic
    return GraphTemplateSample(
      vertices: List.generate(8, (index) {
        return Vertex(
          id: index.toString(),
          offset: Offset(50 + Random().nextDouble() * 400, 50 + Random().nextDouble() * 400),
        );
      }),
      edges: [],
    );
  }

  if (key == customTemplateKey) {
    return GraphTemplateSample(vertices: [], edges: []);
  }

  return _templates[key]!;
}

Map<String, GraphTemplateSample> getPreBuiltGraphTemplate() {
  return _templates;
}
