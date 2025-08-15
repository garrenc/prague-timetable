import 'package:flutter/material.dart';

enum TransportType {
  bus,
  tram,
  metro,
  unknown;

  static TransportType parse(String value) {
    switch (value) {
      case 'bus':
        return TransportType.bus;
      case 'tram':
        return TransportType.tram;
      case 'metro':
        return TransportType.metro;
      default:
        return TransportType.unknown;
    }
  }

  IconData get icon {
    switch (this) {
      case TransportType.bus:
        return Icons.directions_bus;
      case TransportType.tram:
        return Icons.tram;
      case TransportType.metro:
        return Icons.arrow_downward;
      case TransportType.unknown:
        return Icons.question_mark;
    }
  }
}
