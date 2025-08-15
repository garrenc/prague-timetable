import 'package:flutter/material.dart';

enum MetroLine {
  A,
  B,
  C;

  Color get color {
    switch (this) {
      case MetroLine.A:
        // dark green
        return Color(0xFF008000);
      case MetroLine.B:
        return Colors.yellow;
      case MetroLine.C:
        return Colors.red;
    }
  }
}
