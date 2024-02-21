import 'package:floating_navbar/nav_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floating NavBar Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Floating NavBar Demo Page'),
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
  int _curnetNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Text("Selected tab $_curnetNavIndex"),
              Expanded(
                child: ListView.builder(itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("List Item $index"),
                  );
                }),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NavBar(
              navBarItems: [
                NavBarData(icon: Icons.home),
                NavBarData(icon: Icons.search),
                NavBarData(icon: Icons.favorite_outline),
                NavBarData(icon: Icons.shopping_bag_outlined),
                NavBarData(icon: Icons.person_outline),
              ],
              onItemChanged: (int newPosition) {
                setState(() {
                  _curnetNavIndex = newPosition;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
