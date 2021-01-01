import 'dart:io';

import 'package:flutter/cupertino.dart';

Socket server;

class WorldState {
  WorldState(this.world, this.size, this.lasers);
  final Size size;
  final List<MapEntry<Position, CellType>> world;
  final List<List<List<int>>> lasers;
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
  if(data.isEmpty) throw "NO DATA";
  int w = data[0];
  int h = data[1];
  int i = 2;
  List<List<List<int>>> lasers = [];
  List<MapEntry<Position, CellType>> world = [];
  while (i < data.length) {
    if(data[i] == 0) {
      i++;
      int x = data[i];
      i++;
      int y = data[i];
      i++;
      CellType type = CellType.values[data[i]];
      i++;
      world.add(MapEntry(Position(x, y), type));
      //print("$x $y ${type.index}");
    } else if (data[i] == 1) {
      i++;
      int sx = data[i];
      i++;
      int sy = data[i];
      i++;
      int dx = data[i];
      i++;
      int dy = data[i];
      i++;
      lasers.add([[sx, sy], [dx, dy]]);
    }
  }
  return WorldState(world, Size(w.toDouble(), h.toDouble()), lasers);
}
