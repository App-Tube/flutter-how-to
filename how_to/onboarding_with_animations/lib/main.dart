import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onboarding With Animations Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _pageController = PageController();
  int _position = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                OnboardingPage(pageData: OnboardingData.first),
                OnboardingPage(pageData: OnboardingData.second),
                OnboardingPage(pageData: OnboardingData.third),
              ],
            ),
          ),
          if (_position < 2)
            Column(
              children: [
                GestureDetector(
                  onTap: () => _moveToNext(),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Color(0xff58CC02),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Image.asset(
                      "assets/onboarding/arrow_right.png",
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                TextButton(
                  onPressed: () => _skip(),
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: Color(0xff727374),
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  height: 32,
                ),
              ],
            ),
          if (_position >= 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 46,
                    color: Color(0xff58CC02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Get started",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 46,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        width: 2,
                        color: Color(0xffE5E5E5),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      "I ALREADY HAVE AN ACCOUNT",
                      style: TextStyle(
                        color: Color(0xff58CC02),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _moveToNext() {
    if (_position < 2) {
      setState(() {
        _position++;
      });

      _pageController.nextPage(
        duration: Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  void _skip() {
    setState(() {
      _position = 2;
    });
    _pageController.jumpToPage(_position);
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData pageData;
  const OnboardingPage({
    super.key,
    required this.pageData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Image.asset(pageData.imagePath).animate().fadeIn(
                  delay: 100.ms,
                  duration: 700.ms,
                ),
          ),
          Text(
            pageData.title,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.14,
              color: Color(0xff4B4B4B),
            ),
          )
              .animate()
              .visibility(
                delay: 350.ms,
              )
              .moveX(
                begin: -500,
                end: 0,
                delay: 450.ms,
                duration: 500.ms,
              ),
          SizedBox(height: 16),
          Text(
            pageData.description,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xff727374),
            ),
          ).animate().scale(
                duration: 500.ms,
                delay: 600.ms,
              ),
        ],
      ),
    );
  }
}

enum OnboardingData {
  first(
    title: "The free, fun, and effective way to learn a language!",
    description:
        "Learning with Duolingo is fun, and research shows that it works.",
    imagePath: "assets/onboarding/onboarding_image_1.png",
  ),
  second(
    title: "Free, Fun & Effective",
    description:
        "Learning with Duolingo is fun, and research shows that it works.",
    imagePath: "assets/onboarding/onboarding_image_2.png",
  ),
  third(
    title: "Personalized learning",
    description:
        "Combining the best of AI and language science, lessons are tailored to help you learn at just the right level and pace.",
    imagePath: "assets/onboarding/onboarding_image_3.png",
  );

  const OnboardingData(
      {required this.title,
      required this.description,
      required this.imagePath});

  final String title;
  final String description;
  final String imagePath;
}
