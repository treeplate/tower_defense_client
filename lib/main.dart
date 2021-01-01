import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:home_automation_tools/all.dart';
import 'handler.dart';
import 'dart:io';

void main() async {
  server = await Socket.connect("ceylon.rooves.house", 9000);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tower Defense',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState() {
    final PacketBuffer buffer = PacketBuffer();
    server.listen((List<int> message) {
      print("packet $message");
      buffer.add(message);
      if (buffer.available >= 8) {
        int size = buffer.readInt64();
        buffer.rewind();
        while (buffer.available > size + 7) {
          print("message received");
          _world = parse(buffer.readUint8List(buffer.readInt64()));
          buffer.checkpoint();
        }
      }
      setState(() {});
    });
  }
  WorldState _world;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          CustomPaint(
            painter: WorldPainter(_world),
            child: SizedBox.expand(),
          ),
          GestureDetector(
            onTapDown: (TapDownDetails details) {
              Size size = Size(constraints.maxWidth, constraints.maxHeight);
              print("Tap");
              double cellWidth = size.width / _world.size.width;
              double cellHeight = size.height / _world.size.height;
              Size cellSize = Size(min<num>(cellWidth, cellHeight),
                  min<num>(cellWidth, cellHeight));
              Size nsize = _world.size * cellSize.width;
              Offset padding = ((size - nsize) as Offset) / 2;
              Offset absPos = details.localPosition;
              Offset place = (absPos - padding) / cellSize.width;
              if (place >= Offset(0, 0) && place < _world.size) {
                server.add([place.dx.toInt(), place.dy.toInt()]);
              }
            },
          ),
        ],
      );
    });
  }
}

class WorldPainter extends CustomPainter {
  WorldPainter(this.world);
  final WorldState world;

  void paint(Canvas canvas, Size isize) {
    Size size = Size(min<num>(isize.width, isize.height),
        min<num>(isize.width, isize.height));
    Offset padding = ((isize - size) as Offset) / 2;
    //canvas.drawRect(Rect.fromLTWH(padding.dx, padding.dy, 100, 100),
    //  Paint()..color = Colors.yellow);
    //print("draw: $isize");
    canvas.drawRect(
        Rect.fromLTWH(padding.dx, padding.dy, size.width, size.height),
        Paint()..color = Colors.green);
    for (MapEntry cell in world?.world ?? []) {
      paintCell(cell, canvas, isize);
    }
    for (List<List<int>> laser in world?.lasers ?? []) {
      double cellWidth = isize.width / world.size.width;
      double cellHeight = isize.height / world.size.height;
      Size cellSize = Size(
          min<num>(cellWidth, cellHeight), min<num>(cellWidth, cellHeight));
      Offset sPosition = Position(laser[0][0], laser[0][1]) * cellSize;
      Offset dPosition = Position(laser[1][0], laser[1][1]) * cellSize;
      Size nsize = world.size * cellSize.width;
      Offset padding = (((isize - nsize) as Offset) / 2);
      canvas.drawOval(
        /*Colors.red*/ Rect.fromLTWH(
          padding.dx + dPosition.dx, //Colors.red
          padding.dy + dPosition.dy, //Colors.red
          cellSize.width, //Colors.red
          cellSize.height, //Colors.red
        ),
        Paint()..color = Colors.red[900],
      );
      canvas.drawLine(
        padding + sPosition + cellSize.center(Offset.zero),
        padding + dPosition + cellSize.center(Offset.zero),
        (Paint()..color = Colors.red)..strokeWidth = 3,
      );
    }
  }

  void paintCell(MapEntry<Position, CellType> cell, Canvas canvas, Size size) {
    double cellWidth = size.width / world.size.width;
    double cellHeight = size.height / world.size.height;
    Size cellSize =
        Size(min<num>(cellWidth, cellHeight), min<num>(cellWidth, cellHeight));
    Offset position = cell.key * cellSize;
    Size nsize = world.size * cellSize.width;
    Offset padding = ((size - nsize) as Offset) / 2;
    // print("XXX $size - $nsize / 2: " + "$padding");
    switch (cell.value) {
      /*Colors.grey*/ case CellType.tower:
        /*Colors.grey*/ //  print("tower at position $position ($cellSize)");
        /*Colors.grey*/ canvas.drawRect(
          /*Colors.grey*/ Rect.fromLTWH(
            padding.dx + position.dx, //Colors.grey
            padding.dy + position.dy, //Colors.grey
            cellSize.width, //Colors.grey
            cellSize.height, //Colors.grey
          ), //Colors.grey
          Paint()..color = Colors.grey,
        ); //Colors.grey
        break; //Colors.grey
      /*Colors.red*/ case CellType.enemy:
        /*Colors.red*/ canvas.drawOval(
          /*Colors.red*/ Rect.fromLTWH(
            padding.dx + position.dx, //Colors.red
            padding.dy + position.dy, //Colors.red
            cellSize.width, //Colors.red
            cellSize.height, //Colors.red
          ), //Colors.red
          Paint()..color = Colors.red,
        ); //Colors.red
        break; //Colors.red
    }
  }

  bool shouldRepaint(WorldPainter old) => old.world == world;
}

Size toSize(Offset o) => Size(o.dx, o.dy);
