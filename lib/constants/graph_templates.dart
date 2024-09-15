import 'dart:math';
import 'dart:ui';

import 'package:algorithm_visualizer/features/dijkstra/models/edge.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';

class GraphTemplateSample {
  GraphTemplateSample({required this.vertices, required this.edges});

  final List<Vertex> vertices;
  final List<Edge> edges;

  Map<String, dynamic> toJson() => {
    'vertices': vertices.map((v) => v.toJson()).toList(),
    'edges': edges.map((e) => e.toJson()).toList(),
  };

  factory GraphTemplateSample.fromJson(Map<String, dynamic> json) {
    return GraphTemplateSample(
      vertices: (json['vertices'] as List)
          .map((v) => Vertex.fromJson(v as Map<String, dynamic>))
          .toList(),
      edges: (json['edges'] as List)
          .map((e) => Edge.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/*
* Pre-built graph templates
*/

const customTemplateKey = 'Custom';
const randomTemplateKey = 'Random';
const template1key = 'Template 1';
const template2key = 'Template 2';
const template3key = 'Template 3';
const template4key = 'Template 4';
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

var _vertices2 = const [
  Vertex(id: 'A1', offset: Offset(80.4, 118.9)),
  Vertex(id: 'B1', offset: Offset(36.1, 189.5)),
  Vertex(id: 'C1', offset: Offset(86.4, 259.8)),
  Vertex(id: 'D1', offset: Offset(187.3, 115.2)),
  Vertex(id: 'E1', offset: Offset(309.2, 112.8)),
  Vertex(id: 'F1', offset: Offset(190.5, 256.6)),
  Vertex(id: 'G1', offset: Offset(304.5, 256.7)),
  Vertex(id: 'H1', offset: Offset(361.7, 182.3)),
  Vertex(id: 'I1', offset: Offset(127.9, 186.3)),
  Vertex(id: 'J1', offset: Offset(243.8, 183.9)),
  Vertex(id: 'K1', offset: Offset(411.7, 111.0)),
  Vertex(id: 'L1', offset: Offset(425.4, 256.4)),
  Vertex(id: 'M1', offset: Offset(465.2, 176.7)),
];

var _edges2 = [
  const Edge(id: 'KrbOZvafe6wZFAH0', startVertex: Vertex(id: 'A1', offset: Offset(80.4, 118.9)), endVertex: Vertex(id: 'B1', offset: Offset(36.1, 189.5)), weight: 10),
  const Edge(id: 'AFxZgdoOGGses51k', startVertex: Vertex(id: 'B1', offset: Offset(36.1, 189.5)), endVertex: Vertex(id: 'C1', offset: Offset(86.4, 259.8)), weight: 3),
  const Edge(id: 'CUIjhQDRkqJS1cq1', startVertex: Vertex(id: 'C1', offset: Offset(86.4, 259.8)), endVertex: Vertex(id: 'I1', offset: Offset(127.9, 186.3)), weight: 6),
  const Edge(id: 'wZAIgKxSvRgWGksw', startVertex: Vertex(id: 'I1', offset: Offset(127.9, 186.3)), endVertex: Vertex(id: 'A1', offset: Offset(80.4, 118.9)), weight: 2),
  const Edge(id: 'fKVjXhTQFXhdbETd', startVertex: Vertex(id: 'I1', offset: Offset(127.9, 186.3)), endVertex: Vertex(id: 'D1', offset: Offset(187.3, 115.2)), weight: 7),
  const Edge(id: 'vKXCt2SzDHSec6ad', startVertex: Vertex(id: 'D1', offset: Offset(187.3, 115.2)), endVertex: Vertex(id: 'J1', offset: Offset(243.8, 183.9)), weight: 2),
  const Edge(id: 'uzldTbfzopPYB0is', startVertex: Vertex(id: 'J1', offset: Offset(243.8, 183.9)), endVertex: Vertex(id: 'F1', offset: Offset(190.5, 256.6)), weight: 6),
  const Edge(id: 'RAaebGyn57a0LvDb', startVertex: Vertex(id: 'F1', offset: Offset(190.5, 256.6)), endVertex: Vertex(id: 'I1', offset: Offset(127.9, 186.3)), weight: 6),
  const Edge(id: 'HEiacoM1F962zvgy', startVertex: Vertex(id: 'C1', offset: Offset(86.4, 259.8)), endVertex: Vertex(id: 'F1', offset: Offset(190.5, 256.6)), weight: 10),
  const Edge(id: 'bDi4phd8v525eiAp', startVertex: Vertex(id: 'A1', offset: Offset(80.4, 118.9)), endVertex: Vertex(id: 'D1', offset: Offset(187.3, 115.2)), weight: 1),
  const Edge(id: '3QaeJU7vNlVxiH9R', startVertex: Vertex(id: 'D1', offset: Offset(187.3, 115.2)), endVertex: Vertex(id: 'E1', offset: Offset(309.2, 112.8)), weight: 1),
  const Edge(id: 'WPcAqommv5Cdkyvz', startVertex: Vertex(id: 'G1', offset: Offset(304.5, 256.7)), endVertex: Vertex(id: 'L1', offset: Offset(425.4, 256.4)), weight: 8),
  const Edge(id: 'G2FMs7Z6sVn9npvm', startVertex: Vertex(id: 'G1', offset: Offset(304.5, 256.7)), endVertex: Vertex(id: 'F1', offset: Offset(190.5, 256.6)), weight: 2),
  const Edge(id: 'cLkZIX8lJP9ONUf4', startVertex: Vertex(id: 'E1', offset: Offset(309.2, 112.8)), endVertex: Vertex(id: 'K1', offset: Offset(411.7, 111.0)), weight: 8),
  const Edge(id: 'iNmPfwFKR2QbRnqt', startVertex: Vertex(id: 'K1', offset: Offset(411.7, 111.0)), endVertex: Vertex(id: 'H1', offset: Offset(361.7, 182.3)), weight: 9),
  const Edge(id: 'dwKUDEgx7yAxC9xi', startVertex: Vertex(id: 'H1', offset: Offset(361.7, 182.3)), endVertex: Vertex(id: 'E1', offset: Offset(309.2, 112.8)), weight: 4),
  const Edge(id: 'zK5aApwVZJrUiuuj', startVertex: Vertex(id: 'E1', offset: Offset(309.2, 112.8)), endVertex: Vertex(id: 'J1', offset: Offset(243.8, 183.9)), weight: 4),
  const Edge(id: 'GUOs5zRRBtNMPSZ7', startVertex: Vertex(id: 'J1', offset: Offset(243.8, 183.9)), endVertex: Vertex(id: 'G1', offset: Offset(304.5, 256.7)), weight: 4),
  const Edge(id: '9YZYBeZbAY7hMFUr', startVertex: Vertex(id: 'L1', offset: Offset(425.4, 256.4)), endVertex: Vertex(id: 'H1', offset: Offset(361.7, 182.3)), weight: 5),
  const Edge(id: '51ruOUDGP20L4Nq5', startVertex: Vertex(id: 'K1', offset: Offset(411.7, 111.0)), endVertex: Vertex(id: 'M1', offset: Offset(465.2, 176.7)), weight: 2),
  const Edge(id: 'h9Sv3qMFGWeG2UFD', startVertex: Vertex(id: 'G1', offset: Offset(304.5, 256.7)), endVertex: Vertex(id: 'H1', offset: Offset(361.7, 182.3)), weight: 7),
  const Edge(id: 'y9aGFLv6ZCtHr1Jv', startVertex: Vertex(id: 'M1', offset: Offset(465.2, 176.7)), endVertex: Vertex(id: 'L1', offset: Offset(425.4, 256.4)), weight: 7),
];

final _template2 = GraphTemplateSample(
  vertices: _vertices2,
  edges: _edges2,
);

var _vertices3 = const [
  Vertex(id: 'A1', offset:Offset(58.8, 146.8)),
  Vertex(id: 'B1', offset:Offset(148.6, 73.0)),
  Vertex(id: 'C1', offset:Offset(144.0, 239.8)),
  Vertex(id: 'D1', offset:Offset(237.1, 72.4)),
  Vertex(id: 'E1', offset:Offset(237.3, 239.6)),
  Vertex(id: 'F1', offset:Offset(342.2, 240.7)),
  Vertex(id: 'G1', offset:Offset(340.9, 70.8)),
  Vertex(id: 'H1', offset:Offset(418.6, 147.1)),
  Vertex(id: 'I1', offset:Offset(237.2, 149.1)),
];

var _edges3 = <Edge>[
  const Edge(id: 'IBnUossQctu1ED7z', startVertex: Vertex(id: 'A1', offset: Offset(58.8, 146.8)), endVertex: Vertex(id: 'B1', offset: Offset(148.6, 73.0)), weight: 3),
  const Edge(id: 'MuTP4hp3rsZcd2Qy', startVertex: Vertex(id: 'B1', offset: Offset(148.6, 73.0)), endVertex: Vertex(id: 'D1', offset: Offset(237.1, 72.4)), weight: 6),
  const Edge(id: 'R6tFrljXizhTcaxN', startVertex: Vertex(id: 'D1', offset: Offset(237.1, 72.4)), endVertex: Vertex(id: 'G1', offset: Offset(340.9, 70.8)), weight: 3),
  const Edge(id: '5ofdyMqmjclkWDBP', startVertex: Vertex(id: 'G1', offset: Offset(340.9, 70.8)), endVertex: Vertex(id: 'H1', offset: Offset(418.6, 147.1)), weight: 10),
  const Edge(id: 'SoKl3bhoZKANTmBR', startVertex: Vertex(id: 'H1', offset: Offset(418.6, 147.1)), endVertex: Vertex(id: 'F1', offset: Offset(342.2, 240.7)), weight: 4),
  const Edge(id: 'rdvPhpChyfl6VRim', startVertex: Vertex(id: 'F1', offset: Offset(342.2, 240.7)), endVertex: Vertex(id: 'E1', offset: Offset(237.3, 239.6)), weight: 6),
  const Edge(id: 'KyAAAGgr5jiEjlI3', startVertex: Vertex(id: 'E1', offset: Offset(237.3, 239.6)), endVertex: Vertex(id: 'C1', offset: Offset(144.0, 239.8)), weight: 5),
  const Edge(id: 'hhD2C5V8ulCIEetA', startVertex: Vertex(id: 'C1', offset: Offset(144.0, 239.8)), endVertex: Vertex(id: 'A1', offset: Offset(58.8, 146.8)), weight: 9),
  const Edge(id: '1464xZ503rwLvHLF', startVertex: Vertex(id: 'B1', offset: Offset(148.6, 73.0)), endVertex: Vertex(id: 'C1', offset: Offset(144.0, 239.8)), weight: 4),
  const Edge(id: '0MeC4xeXYrsUDzYl', startVertex: Vertex(id: 'G1', offset: Offset(340.9, 70.8)), endVertex: Vertex(id: 'F1', offset: Offset(342.2, 240.7)), weight: 10),
  const Edge(id: 'xWhqoUHRobR50bps', startVertex: Vertex(id: 'E1', offset: Offset(237.3, 239.6)), endVertex: Vertex(id: 'B1', offset: Offset(148.6, 73.0)), weight: 3),
  const Edge(id: '63rVUoUfVxxPTNbH', startVertex: Vertex(id: 'D1', offset: Offset(237.1, 72.4)), endVertex: Vertex(id: 'I1', offset: Offset(237.2, 149.1)), weight: 6),
  const Edge(id: 'DsQrHmpZKMvJpzYP', startVertex: Vertex(id: 'I1', offset: Offset(237.2, 149.1)), endVertex: Vertex(id: 'E1', offset: Offset(237.3, 239.6)), weight: 9),
  const Edge(id: 'yOFM02cVmGCDyo6g', startVertex: Vertex(id: 'G1', offset: Offset(340.9, 70.8)), endVertex: Vertex(id: 'I1', offset: Offset(237.2, 149.1)), weight: 5),
];

final _template3 = GraphTemplateSample(
  vertices: _vertices3,
  edges: _edges3,
);

var _vertices4 = const [
  Vertex(id: 'A1', offset: Offset(50.0, 50.0)),
  Vertex(id: 'B1', offset: Offset(50.0, 150.0)),
  Vertex(id: 'C1', offset: Offset(150.0, 50.0)),
  Vertex(id: 'D1', offset: Offset(150.0, 150.0)),
  Vertex(id: 'E1', offset: Offset(250.0, 50.0)),
  Vertex(id: 'F1', offset: Offset(250.0, 150.0)),
  Vertex(id: 'G1', offset: Offset(350.0, 50.0)),
  Vertex(id: 'H1', offset: Offset(350.0, 150.0)),
];

var _edges4 = <Edge>[
  const Edge(id: '1FiETgs84mI1BFt5', startVertex: Vertex(id: 'A1', offset: Offset(50.0, 50.0)), endVertex: Vertex(id: 'B1', offset: Offset(50.0, 150.0)), weight: 2),
  const Edge(id: 'YKE9dHjNMnYf0HHO', startVertex: Vertex(id: 'B1', offset: Offset(50.0, 150.0)), endVertex: Vertex(id: 'D1', offset: Offset(150.0, 150.0)), weight: 3),
  const Edge(id: 'QYfqiFJduJGoYrQy', startVertex: Vertex(id: 'D1', offset: Offset(150.0, 150.0)), endVertex: Vertex(id: 'C1', offset: Offset(150.0, 50.0)), weight: 2),
  const Edge(id: 'gjDBbZ3SrVTZMvYc', startVertex: Vertex(id: 'C1', offset: Offset(150.0, 50.0)), endVertex: Vertex(id: 'A1', offset: Offset(50.0, 50.0)), weight: 10),
  const Edge(id: 'OJ7y3adcZAuV6vrR', startVertex: Vertex(id: 'A1', offset: Offset(50.0, 50.0)), endVertex: Vertex(id: 'D1', offset: Offset(150.0, 150.0)), weight: 1),
  const Edge(id: 'fKQdS5DUYPf8oYwm', startVertex: Vertex(id: 'D1', offset: Offset(150.0, 150.0)), endVertex: Vertex(id: 'E1', offset: Offset(250.0, 50.0)), weight: 6),
  const Edge(id: 'JO2U2boXLy8F7Ii6', startVertex: Vertex(id: 'E1', offset: Offset(250.0, 50.0)), endVertex: Vertex(id: 'H1', offset: Offset(350.0, 150.0)), weight: 5),
  const Edge(id: 'PlgMgNVAjgJaJ1x9', startVertex: Vertex(id: 'H1', offset: Offset(350.0, 150.0)), endVertex: Vertex(id: 'G1', offset: Offset(350.0, 50.0)), weight: 8),
  const Edge(id: 'RPXIlkbaEw43OcX8', startVertex: Vertex(id: 'G1', offset: Offset(350.0, 50.0)), endVertex: Vertex(id: 'E1', offset: Offset(250.0, 50.0)), weight: 3),
  const Edge(id: 'N5XyLMfvUfp3xzvD', startVertex: Vertex(id: 'E1', offset: Offset(250.0, 50.0)), endVertex: Vertex(id: 'F1', offset: Offset(250.0, 150.0)), weight: 10),
  const Edge(id: 'WiaxNUusBSoRu4QA', startVertex: Vertex(id: 'E1', offset: Offset(250.0, 50.0)), endVertex: Vertex(id: 'C1', offset: Offset(150.0, 50.0)), weight: 6),
  const Edge(id: 'fKtpWYjtaMVysJad', startVertex: Vertex(id: 'D1', offset: Offset(150.0, 150.0)), endVertex: Vertex(id: 'F1', offset: Offset(250.0, 150.0)), weight: 1),
  const Edge(id: 'tCVtiv1aI2Mc1ekG', startVertex: Vertex(id: 'F1', offset: Offset(250.0, 150.0)), endVertex: Vertex(id: 'H1', offset: Offset(350.0, 150.0)), weight: 10),
];

final _template4 = GraphTemplateSample(
  vertices: _vertices4,
  edges: _edges4,
);

Map<String, GraphTemplateSample> _templates = {
  template1key: _template1,
  template2key: _template2,
  template3key: _template3,
  template4key: _template4,
};

GraphTemplateSample getGraphTemplate(String key) {
  if (key == randomTemplateKey) { // todo:: update logic
    final randomVertices = generateRandomVertices(numberOfVertices: 8, canvasSize: const Size(300, 300));
    final randomEdges = generateEdges(randomVertices, 10);
    return GraphTemplateSample(
      vertices: randomVertices,
      edges: randomEdges,
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

List<Vertex> generateRandomVertices({
  required int numberOfVertices,
  required Size canvasSize,
  double minDistance = 50.0,
}) {
  List<Vertex> vertices = [];
  Random random = Random();
  int retries = 0;

  bool isTooClose(Offset position) {
    for (Vertex vertex in vertices) {
      double distance = (vertex.offset - position).distance;
      if (distance < minDistance) {
        return true;
      }
    }
    return false;
  }

  for (int i = 0; i < numberOfVertices; i++) {
    bool positionIsValid = false;
    Offset randomPosition;

    // Try to generate a valid random position
    do {
      randomPosition = Offset(
        random.nextDouble() * canvasSize.width,
        random.nextDouble() * canvasSize.height,
      );

      if (!isTooClose(randomPosition)) {
        positionIsValid = true;
      } else {
        retries++;
        // If retried too many times, loosen the constraints (increase minDistance)
        if (retries > 1000) {
          minDistance -= 5;
        }
      }
    } while (!positionIsValid);

    vertices.add(Vertex(id: '$i', offset: randomPosition));
  }

  return vertices;
}

// Randomly connect vertices with edges
List<Edge> generateEdges(List<Vertex> vertices, int numberOfEdges) {
  Random random = Random();
  List<Edge> edges = [];

  while (edges.length < numberOfEdges) {
    Vertex start = vertices[random.nextInt(vertices.length)];
    Vertex end = vertices[random.nextInt(vertices.length)];

    // Ensure no self-loops and no duplicate edges
    if (start != end && !edges.any((e) => (e.startVertex == start && e.endVertex == end) || (e.startVertex == end && e.endVertex == start))) {
      edges.add(Edge(id: Edge.generateID(), startVertex: start, endVertex: end, weight: random.nextInt(10) + 1));
    }
  }

  return edges;
}
