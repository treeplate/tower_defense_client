import 'dart:io';

import 'package:flutter/cupertino.dart';

Socket server;

class WorldState {
  WorldState(this.world, this.size);
  final Size size;
  final List<MapEntry<Position, CellType>> world;
}

class Position {
  Position(this.x, this.y);
  final int x;
  final int y;
  operator *(Size other) {
    return Offset(other.width * x.toDouble(), other.height * y.toDouble());
  }

  operator +(Size other) {
    return Offset(other.width + x.toDouble(), other.height + y.toDouble());
  }
}

enum CellType { enemy, tower }

WorldState parse(List<int> data) {
  int w = data[0];
  int h = data[1];
  int i = 2;
  List<MapEntry<Position, CellType>> world = [];
  while (i < data.length) {
    int x = data[i];
    i++;
    int y = data[i];
    i++;
    CellType type = CellType.values[data[i]];
    i++;
    world.add(MapEntry(Position(x, y), type));
  }
  return WorldState(world, Size(w.toDouble(), h.toDouble()));
}
