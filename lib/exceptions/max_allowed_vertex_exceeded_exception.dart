class MaxAllowedVertexExceededException implements Exception {
  MaxAllowedVertexExceededException();

  @override
  String toString() {
    return 'Max allowed vertex exceeded';
  }
}
