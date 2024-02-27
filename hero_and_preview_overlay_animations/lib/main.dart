import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:palette_generator/palette_generator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hero and Preview Animations Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Hero and Preview Animations Demo'),
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
  OverlayEntry? _overlayEntry;
  final _globalKeysMap = <int, GlobalKey>{};

  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (context, index) => GestureDetector(
                key: _getKey(index),
                child: Hero(
                  tag: _imageUrl(index),
                  child: Image.network(
                    _imageUrl(index),
                    fit: BoxFit.cover,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePreviewPage(
                        url: _imageUrl(index),
                      ),
                    ),
                  );
                },
                onLongPressDown: (details) {
                  _cancelTimer();
                  _startTimer(index);
                },
                onLongPressCancel: () {
                  _cancelTimer();
                },
                onLongPressUp: () {
                  if (_overlayEntry?.mounted ?? false) {
                    _overlayEntry?.remove();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePreview(String url, Offset offset) async {
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      NetworkImage(url),
      maximumColorCount: 3,
      timeout: 600.ms,
    );

    if (_overlayEntry?.mounted ?? false) {
      _overlayEntry?.remove();
    }
    _overlayEntry = OverlayEntry(builder: (context) {
      final screenSize = MediaQuery.sizeOf(context);
      return Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black54,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: paletteGenerator.colors.length > 2
                    ? paletteGenerator.colors.toList()
                    : [Colors.white, Colors.white],
              ),
            ),
            width: screenSize.width - 32,
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Image.network(url),
          )
              .animate()
              .scale(
                delay: 100.ms,
                duration: 300.ms,
              )
              .move(
                  delay: 100.ms,
                  duration: 300.ms,
                  begin: Offset(offset.dx - 150, offset.dy),
                  end: Offset(16, screenSize.height / 2 - 150)),
        ],
      );
    });

    Overlay.of(context).insert(_overlayEntry!);
  }

  GlobalKey _getKey(int index) {
    if (_globalKeysMap.containsKey(index)) {
      return _globalKeysMap[index]!;
    }

    final newKey = GlobalKey();
    _globalKeysMap[index] = newKey;

    return newKey;
  }

  void _startTimer(int index) {
    _timer = Timer(400.ms, () {
      RenderBox box = _globalKeysMap[index]!.currentContext?.findRenderObject()
          as RenderBox;
      Offset offset = box.localToGlobal(Offset.zero);
      _showImagePreview(_imageUrl(index), offset);
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
  }

  String _imageUrl(int seed) => "https://picsum.photos/seed/$seed/450/300";
}

class ImagePreviewPage extends StatefulWidget {
  final String url;
  const ImagePreviewPage({
    super.key,
    required this.url,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Hero(
          tag: widget.url,
          child: Image.network(
            widget.url,
            width: screenSize.width,
          ),
        ),
      ),
    );
  }
}
