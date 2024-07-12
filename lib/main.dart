import 'package:animation_series/pages/animated_page_entry.dart';
import 'package:animation_series/pages/drag_transform.dart';
import 'package:animation_series/pages/gradient_messenger.dart';
import 'package:animation_series/pages/radar_chart_draw_animation.dart';
import 'package:animation_series/pages/splash_like_animation.dart';
import 'package:animation_series/pages/staggered_animation_dialog.dart';
import 'package:animation_series/pages/svg_path_advanced_interaction.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Animations & Effects Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Animations & Effects Demo'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const DragDropExample()));
                },
                child: const Text('Drag and Transform')),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const GradientMessenger()));
                },
                child: const Text(' Messenger Gradient Background Effects')),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SplashLikeAnimation()));
                },
                child: const Text('Splash Like Animation')),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const DemoAnimatedPageEntry()));
                },
                child: const Text('HeroTag + Animated Page Entry')),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const RadarChartAnimation()));
                },
                child: const Text('Radar chart animation')),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SvgPathAdvancedInteraction()));
                },
                child: const Text('Svg Path Advanced Interaction')),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const StaggeredAnimationDialog()));
                },
                child: const Text('Staggered Animation Dialog')),
            const SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }
}
