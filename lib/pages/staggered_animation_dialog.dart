import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StaggeredAnimationDialog extends StatefulWidget {
  const StaggeredAnimationDialog({Key? key}) : super(key: key);

  @override
  State createState() => _StaggeredAnimationDialogState();
}

class _StaggeredAnimationDialogState extends State<StaggeredAnimationDialog>
    with SingleTickerProviderStateMixin {
  bool success = false;
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 1500),
    reverseDuration: const Duration(milliseconds: 1000),
    vsync: this,
  );

  late final _sweepAnimation =
      Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.25, curve: Curves.easeInOut),
  ));

  late final _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.5, curve: Curves.easeInOut),
    ),
  );

  late final _scaleAnimation = Tween(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.66, curve: Curves.bounceInOut),
    ),
  );

  late final _borderRadiusAnimation = BorderRadiusTween(
          begin: const BorderRadius.all(Radius.circular(100)),
          end: const BorderRadius.all(Radius.circular(20)))
      .animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.66, 0.75, curve: Curves.easeOut),
    ),
  );

  late final _sizeAnimation =
      SizeTween(begin: const Size(88, 88), end: const Size(300, 230)).animate(
    CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.80, 0.91, curve: Curves.easeInOut)),
  );

  late final _offsetAnimation = Tween(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.91, 1.0),
    ),
  );

  @override
  void initState() {
    forward();
    super.initState();
  }

  void forward() {
    _controller.forward().then((value) {
      if (!success) {
        Future.delayed(const Duration(milliseconds: 2000), () => reverse());
      }
    });
  }

  void reverse() {
    _controller.animateBack(0.5).then((value) {
      if (!success) {
        success = true;
        forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Staggered Animation Dialog'),
      ),
      body: Stack(
        children: [
          Dialog(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0.0,
            child: SizedBox(
              width: 300,
              height: 230,
              child: Center(
                child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return Stack(
                        children: [
                          Center(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                width: _sizeAnimation.value!.width + 12,
                                height: _sizeAnimation.value!.height + 12,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: _borderRadiusAnimation.value,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: Container(
                                  width: 88,
                                  height: 88,
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                )),
                          ),
                          Center(
                            child: CustomPaint(
                              painter: CirclePainter(
                                startDegree:
                                    driveDegreeRight(_sweepAnimation.value),
                                endDegree: _sweepAnimation.value * 360,
                                borderColor: Colors.white,
                                radius: 44.0,
                                borderWidth: 10.0,
                              ),
                            ),
                          ),
                          Center(
                            child: FadeTransition(
                                opacity: _fadeAnimation,
                                child: ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Lottie.asset(
                                        width: 100,
                                        height: 100,
                                        success
                                            ? 'assets/lottie/success.json'
                                            : 'assets/lottie/loading.json',
                                        repeat: !success))),
                          ),
                          if (success)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              left: 8,
                              child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.3),
                                    end: const Offset(0, 0),
                                  ).animate(_offsetAnimation),
                                  child: FadeTransition(
                                    opacity: _offsetAnimation,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: double.infinity,
                                        height: 55,
                                        child: const Text(
                                          'OK',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  )),
                            ),
                          Positioned(
                            top: 8,
                            right: 8,
                            left: 8,
                            child: FadeTransition(
                              opacity: _offsetAnimation,
                              child: Container(
                                alignment: Alignment.center,
                                width: double.infinity,
                                height: 55,
                                child: Text(
                                  success ? 'Success!' : 'Loading...',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double driveDegreeLeft(double value) {
    return value * 180 + 180;
  }

  double driveDegreeRight(double value) {
    return 90 - (value * 180);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CirclePainter extends CustomPainter {
  final double startDegree;
  final double endDegree;
  final Color borderColor;
  final double radius;
  final double borderWidth;

  CirclePainter({
    required this.startDegree,
    required this.endDegree,
    required this.borderColor,
    required this.radius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = borderWidth;

    final Rect rect = Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2), radius: radius);
    canvas.drawArc(rect, angleToRadians(startDegree), angleToRadians(endDegree),
        false, paint);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return oldDelegate.startDegree != startDegree ||
        oldDelegate.endDegree != endDegree ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.radius != radius ||
        oldDelegate.borderWidth != borderWidth;
  }

  double angleToRadians(double angle) {
    return angle * (3.14159265358979323846 / 180);
  }
}
