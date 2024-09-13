import 'dart:math';

import 'package:algorithm_visualizer/features/dijkstra/models/edge.dart';
import 'package:algorithm_visualizer/features/dijkstra/models/vertex.dart';
import 'package:flutter/material.dart';

class GraphPainter extends CustomPainter {
  GraphPainter({
    required this.vertexRadius,
    required this.edgeThickness,
    required this.vertices,
    required this.edges,
    this.temporaryEdgeEnd,
    this.startVertex,
    this.selectedVertexID,
    this.selectedEdgeID,
    this.currentVertexID,
    this.currentEdgeID,
    this.currVertexEdges = const [],
    required this.neighbors,
    this.currentNeighbor,
    required this.unvisitedVertices,
    required this.isAnimationRunning,
    required this.visitedEdges,
  });

  final List<Vertex> vertices;
  final List<Edge> edges;
  final double vertexRadius;
  final double edgeThickness;
  final Offset? temporaryEdgeEnd;
  final Offset? startVertex;
  final String? selectedVertexID;
  final String? selectedEdgeID;
  final String? currentVertexID;
  final String? currentEdgeID;
  final List<Edge> currVertexEdges;
  final List<Vertex> neighbors;
  final Vertex? currentNeighbor;
  final Set<Vertex> unvisitedVertices;
  final bool isAnimationRunning;
  final List<Edge> visitedEdges;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw edges
    _drawEdges(canvas, visitedEdges);

    // Draw vertices
    _drawVertices(canvas);
  }

  void _drawVertex({
    required Canvas canvas,
    required Vertex vertex,
    Color color = Colors.white,
    bool hasThickBorder = false,
    bool isVisited = false,
  }) {
    var borderThickness = hasThickBorder ? 2.5 : 1.0;
    var borderColor = isVisited ? Colors.black12 : Colors.black;
    color = isVisited ? const Color(0xFFEFF4E9) : color;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderThickness;

    // Draw the filled circle
    canvas.drawCircle(vertex.offset, vertexRadius, fillPaint);

    // Draw the border circle
    canvas.drawCircle(vertex.offset, vertexRadius - borderThickness + 1.5, borderPaint);
  }

  void _drawVertices(Canvas canvas) {
    const vertexFocusedFillColor = Colors.orange;

    // Iterate through all vertices
    for (var vertex in vertices) {
      var isVisited = !unvisitedVertices.contains(vertex) && currentVertexID != vertex.id && isAnimationRunning;

      if (currentVertexID != null && vertex.id == currentVertexID) {
        // If drawing the current visited vertex
        _drawVertex(canvas: canvas, vertex: vertex, hasThickBorder: true, color: Colors.green, isVisited: isVisited);
      } else if (selectedVertexID != null && vertex.id == selectedVertexID) {
        // If drawing the user-selected vertex
        _drawVertex(canvas: canvas, vertex: vertex, hasThickBorder: true, color: vertexFocusedFillColor, isVisited: isVisited);
      } else if (currentNeighbor != null && currentNeighbor!.id == vertex.id) {
        // If drawing the current neighbor being processed
        _drawVertex(canvas: canvas, vertex: vertex, hasThickBorder: true, color: Colors.yellow, isVisited: isVisited);
      } else if (neighbors.contains(vertex)) {
        // If drawing a neighbors of the current vertex
        _drawVertex(canvas: canvas, vertex: vertex, hasThickBorder: false, color: Colors.yellow, isVisited: isVisited);
      } else {
        // If drawing a regular vertex
        _drawVertex(canvas: canvas, vertex: vertex, hasThickBorder: false, isVisited: isVisited);
      }

      // Draw the label
      _drawVertexLabel(canvas, vertex, isVisited);
    }
  }

  void _drawVertexLabel(Canvas canvas, Vertex vertex, bool isVisited) {
    var color = isVisited ? Colors.black12 : Colors.black;

    // Prepare the label
    final textSpan = TextSpan(
      text: vertex.label,
      style: TextStyle(
        color:color,
        fontSize: 14.0,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Calculate the position to center the label on the vertex
    final textOffset = Offset(
      vertex.offset.dx - textPainter.width / 2,
      vertex.offset.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  void _drawEdges(Canvas canvas, List<Edge> visitedEdges) {
    // Define paint styles for different edge states
    final edgePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = edgeThickness;

    final selectedEdgePaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = edgeThickness + 2;

    final currentVertexEdgesPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = edgeThickness + 1.5;

    final currentEdgePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = edgeThickness + 1.5;

    const double arrowSize = 10.0;
    // Arrowhead angle in radians
    const double arrowAngle = 25 * (3.1416 / 180);

    // Iterate through all edges and determine the appropriate paint for each
    for (var edge in edges) {
      var visited = visitedEdges.contains(edge) && currentEdgeID != edge.id;
      Paint paint;

      // Determine paint based on edge's state
      if (edge.id == currentEdgeID) {
        paint = currentEdgePaint;
      } else if (currVertexEdges.contains(edge)) {
        paint = currentVertexEdgesPaint;
      } else if (edge.id == selectedEdgeID) {
        paint = selectedEdgePaint;
      } else {
        paint = Paint()
          ..color = visited ? Colors.black12 : Colors.black
          ..strokeWidth = edgeThickness;
      }

      // Draw the edge line
      canvas.drawLine(edge.startVertex.offset, edge.endVertex.offset, paint);

      // Calculate the direction of the edge to draw the arrow
      final dx = edge.endVertex.offset.dx - edge.startVertex.offset.dx;
      final dy = edge.endVertex.offset.dy - edge.startVertex.offset.dy;
      final angle = atan2(dy, dx);

      /*// Calculate the arrow position, moving it away from the end vertex
      final arrowEndX = edge.endVertex.offset.dx - vertexRadius * cos(angle);
      final arrowEndY = edge.endVertex.offset.dy - vertexRadius * sin(angle);

      // Calculate points for the arrowhead
      final arrowX1 = arrowEndX - arrowSize * cos(angle - arrowAngle);
      final arrowY1 = arrowEndY - arrowSize * sin(angle - arrowAngle);
      final arrowX2 = arrowEndX - arrowSize * cos(angle + arrowAngle);
      final arrowY2 = arrowEndY - arrowSize * sin(angle + arrowAngle);

      final path = Path()
        ..moveTo(arrowEndX, arrowEndY)  // Arrow tip
        ..lineTo(arrowX1, arrowY1)      // Left side of arrowhead
        ..lineTo(arrowX2, arrowY2)      // Right side of arrowhead
        ..close();

      // Draw the arrowhead
      canvas.drawPath(path, paint);*/

      // Draw the weight label at the midpoint of the edge
      final midPoint = Offset(
        (edge.startVertex.offset.dx + edge.endVertex.offset.dx) / 2,
        (edge.startVertex.offset.dy + edge.endVertex.offset.dy) / 2,
      );

      final textSpan = TextSpan(
        text: edge.weight.toString(),
        style: TextStyle(
          color: visited ? Colors.black12 : Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Calculate the position to draw the text so it is centered
      final offset = midPoint.translate(
        -textPainter.width / 2,
        -textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
    }

    // Draw a temporary edge if necessary (e.g., during edge creation)
    if (startVertex != null && temporaryEdgeEnd != null) {
      canvas.drawLine(
        startVertex!,
        temporaryEdgeEnd!,
        edgePaint..color = Colors.grey,
      );
    }
  }

  @override
  bool shouldRepaint(GraphPainter oldDelegate) {
    return oldDelegate.vertices != vertices ||
        oldDelegate.edges != edges ||
        oldDelegate.temporaryEdgeEnd != temporaryEdgeEnd ||
        oldDelegate.startVertex != startVertex ||
        oldDelegate.selectedVertexID != selectedVertexID ||
        oldDelegate.selectedEdgeID != selectedEdgeID ||
        oldDelegate.currentVertexID != currentVertexID ||
        oldDelegate.currVertexEdges != currVertexEdges ||
        oldDelegate.currentEdgeID != currentEdgeID ||
        oldDelegate.neighbors != neighbors ||
        oldDelegate.currentNeighbor != currentNeighbor ||
        oldDelegate.unvisitedVertices != unvisitedVertices ||
        oldDelegate.visitedEdges != visitedEdges;
  }
}