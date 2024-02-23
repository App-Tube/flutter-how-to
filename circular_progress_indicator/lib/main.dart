import 'dart:math';

import 'package:flutter/material.dart';

final Color _blue = const Color(0xff3da8fc);
final Color _gray = const Color(0xfff4f4f4);
final Color _orange = const Color(0xfff6813a);
final Color _green = const Color(0xff4ecca3);
final double _circularProgressSize = 0.3;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
                "Hi Flutter dev, here' you can see a circular progress indicator with animations."),
            SizedBox(
              height: 32,
            ),
            CircularProgressWidget(
              progress: _progress,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _progress += 0.1;

            if (_progress > 1) {
              _progress = 0;
            }

            print(_progress);
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CircularProgressWidget extends StatefulWidget {
  final double progress;
  const CircularProgressWidget({
    super.key,
    required this.progress,
  });

  @override
  State<CircularProgressWidget> createState() => _CircularProgressWidgetState();
}

class _CircularProgressWidgetState extends State<CircularProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Animation<double>? _progressTweenAnimation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));

    _progressTweenAnimation = Tween<double>(begin: 0, end: widget.progress)
        .animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    _animationController.forward();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant CircularProgressWidget oldWidget) {
    _animationController.reset();

    _progressTweenAnimation =
        Tween<double>(begin: oldWidget.progress, end: widget.progress)
            .animate(_animationController)
          ..addListener(() {});

    _animationController.forward();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    print("Progress value: ${_progressTweenAnimation?.value}");
    return Column(
      children: [
        CustomPaint(
          painter: CircularProgressPainter(
            circularProgressSize: size.width * _circularProgressSize,
            progress: _progressTweenAnimation?.value ?? 0,
          ),
          child: Container(
            width: size.width * _circularProgressSize,
            height: size.width * _circularProgressSize,
            child: Center(
              child: Text(
                "${((_progressTweenAnimation?.value ?? 0) * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  color: _green,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 32,
        ),
        CustomPaint(
          painter: ArchProgressPainter(
            circularProgressSize: size.width * _circularProgressSize,
            progress: _progressTweenAnimation?.value ?? 0,
          ),
          child: Container(
            width: size.width * _circularProgressSize,
            height: size.width * _circularProgressSize,
            child: Center(
              child: Text(
                "${((_progressTweenAnimation?.value ?? 0) * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  color: _orange,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class CircularProgressPainter extends CustomPainter {
  final double circularProgressSize;
  final double progress;
  final onePercentageToRadian = 0.06283;

  CircularProgressPainter({
    required this.circularProgressSize,
    required this.progress,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paintBackhround = Paint()
      ..strokeWidth = 16
      ..color = _gray
      ..style = PaintingStyle.stroke;

    final paintProgress = Paint()
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = _green;

    canvas.drawCircle(
      Offset(circularProgressSize / 2, circularProgressSize / 2),
      circularProgressSize / 2,
      paintBackhround,
    );

    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(circularProgressSize / 2, circularProgressSize / 2),
          width: circularProgressSize,
          height: circularProgressSize),
      3 * pi / 2,
      _convertPercentageToRadian(),
      false,
      paintProgress,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  double _convertPercentageToRadian() {
    return onePercentageToRadian * progress * 100;
  }
}

class ArchProgressPainter extends CustomPainter {
  final double circularProgressSize;
  final double progress;
  final onePercentageToRadian = (3 * pi / 2) / 100;

  ArchProgressPainter({
    required this.circularProgressSize,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintBackhround = Paint()
      ..strokeWidth = 16
      ..color = _orange.withOpacity(0.25)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintProgress = Paint()
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = _orange;

    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(circularProgressSize / 2, circularProgressSize / 2),
          width: circularProgressSize,
          height: circularProgressSize),
      3 * pi / 4,
      3 * pi / 2,
      false,
      paintBackhround,
    );

    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(circularProgressSize / 2, circularProgressSize / 2),
          width: circularProgressSize,
          height: circularProgressSize),
      3 * pi / 4,
      _convertPercentageToRadian(),
      false,
      paintProgress,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  double _convertPercentageToRadian() {
    return onePercentageToRadian * progress * 100;
  }
}
