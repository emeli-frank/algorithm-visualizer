import 'dart:ui';

extension OffsetExtensions on Offset {
  bool isWithinRadius(Offset other, double radius) {
    return (this - other).distance <= radius;
  }
}
