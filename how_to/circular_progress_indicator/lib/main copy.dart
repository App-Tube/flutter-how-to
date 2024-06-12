import 'dart:math';
import 'package:flutter/material.dart';

final Color _blue = const Color(0xff3da8fc);
final Color _gray = const Color(0xfff4f4f4);
final Color _orange = const Color(0xfff6813a);
final Color _green = const Color(0xff4ecca3);
final double _circularProgressSize = 0.2;

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
  double _currentProgress = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: <Widget>[
              Text(
                  "Hi Flutter dev, here' you can see a circular progress indicator with animations"),
              SizedBox(
                height: 32,
              ),
              CircularProgressWidget(
                progress: _currentProgress,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentProgress += 0.1;
            if (_currentProgress > 1) {
              _currentProgress = 0;
            }
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
  late AnimationController _controller;
  Animation<double>? _tweenProgressAnimation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));

    _tweenProgressAnimation =
        Tween<double>(begin: 0, end: widget.progress).animate(_controller)
          ..addListener(() {
            setState(() {});
          });

    _controller.forward();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant CircularProgressWidget oldWidget) {
    _controller.reset();

    _tweenProgressAnimation =
        Tween<double>(begin: oldWidget.progress, end: widget.progress)
            .animate(_controller)
          ..addListener(() {});
    _controller.forward();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CirclePainter(
        screenSize: MediaQuery.sizeOf(context),
        progress: _tweenProgressAnimation?.value ?? 0,
      ),
      child: Container(
        height: MediaQuery.sizeOf(context).width * _circularProgressSize * 2,
        width: MediaQuery.sizeOf(context).width * _circularProgressSize * 2,
        child: Center(
            child: Text(
          "${((_tweenProgressAnimation?.value ?? 0) * 100).toStringAsFixed(0)}%",
          style: TextStyle(
            color: _green,
            fontSize: 42,
            fontWeight: FontWeight.bold,
          ),
        )),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CirclePainter extends CustomPainter {
  final onePercentageToRadian = 0.06283;
  final Size screenSize;
  final double progress;

  const CirclePainter({
    required this.screenSize,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _gray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;

    final arcPaint = Paint()
      ..color = _green
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14;

    // empty circle
    canvas.drawCircle(
        Offset(screenSize.width * _circularProgressSize,
            screenSize.width * _circularProgressSize),
        screenSize.width * _circularProgressSize,
        paint);

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(screenSize.width * _circularProgressSize,
            screenSize.width * _circularProgressSize),
        width: screenSize.width * _circularProgressSize * 2,
        height: screenSize.width * _circularProgressSize * 2,
      ),
      3 * pi / 2,
      _calculatePercentageToRadian(),
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  double _calculatePercentageToRadian() {
    return min(progress, 1) * 100 * onePercentageToRadian;
  }
}
