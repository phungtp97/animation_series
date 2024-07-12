import 'package:flutter/material.dart';

mixin PageEntryAnimationMixin<T extends StatefulWidget>
    on SingleTickerProviderStateMixin<T> {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  Widget slideTransition(Widget child, {Offset? begin, Offset? end}) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin ?? const Offset(0, 1),
        end: end ?? const Offset(0, 0),
      ).animate(_animation),
      child: child,
    );
  }

  Widget fadeTransition(Widget child) {
    return FadeTransition(
      opacity: _animation,
      child: child,
    );
  }

  Widget scaleTransition(Widget child) {
    return ScaleTransition(
      scale: _animation,
      child: child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class DemoAnimatedPageEntry extends StatelessWidget {
  const DemoAnimatedPageEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Animated Page Entry'),
      ),
      body: Align(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(FadePageRoute(
              builder: (context) => const AnimatedPageEntry(),
            ));
          },
          child: const Hero(
            tag: 'registerKey',
            child: RegisterTextField(
                disable: true, hintText: 'Click here to input'),
          ),
        ),
      ),
    );
  }
}

class AnimatedPageEntry extends StatefulWidget {
  const AnimatedPageEntry({super.key});

  @override
  State<AnimatedPageEntry> createState() => _AnimatedPageEntryState();
}

class _AnimatedPageEntryState extends State<AnimatedPageEntry>
    with SingleTickerProviderStateMixin, PageEntryAnimationMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Page Entry'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Hero(
              tag: 'registerKey',
              child: RegisterTextField(
                  disable: false, hintText: 'Enter your username')),
          Expanded(
            child: slideTransition(
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ///Some random policy below
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      'By clicking Register, you agree to our Terms and Conditions',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: SizedBox.shrink(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
                          )),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              begin: const Offset(0, 1),
              end: const Offset(0, 0),
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterTextField extends StatelessWidget {
  final bool disable;

  final String hintText;

  const RegisterTextField(
      {super.key, required this.disable, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          enabled: !disable,
          decoration: InputDecoration(
            hintText: hintText,
            fillColor: Colors.white,
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 3),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 3),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            disabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 3),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
      ),
    );
  }
}

class FadePageRoute extends PageRouteBuilder {
  final WidgetBuilder builder;

  FadePageRoute({required this.builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}
