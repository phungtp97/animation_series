import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

import 'drag_transform.dart';

class SplashLikeAnimation extends StatefulWidget {
  const SplashLikeAnimation({super.key});

  @override
  State<StatefulWidget> createState() => SplashLikeAnimationState();
}

class SplashLikeAnimationState extends State<SplashLikeAnimation>
    with SingleTickerProviderStateMixin {
  bool like = false;

  late final animController = AnimationController(
    duration: const Duration(milliseconds: 1000),
    vsync: this,
  );

  late final colorAnim = ColorTween(begin: Colors.transparent, end: Colors.red)
      .animate(CurvedAnimation(
    parent: animController,
    curve: const Interval(0, 0.250, curve: Curves.ease),
  ));

  late final borderAnim = BorderRadiusTween(
          begin: BorderRadius.circular(0), end: BorderRadius.circular(80))
      .animate(CurvedAnimation(
          parent: animController,
          curve: const Interval(0.200, 0.500, curve: Curves.ease)));

  void setLike(bool like) {
    if (like) {
      forwardAnim();
    } else {
      unLike();
    }
  }

  void forwardAnim() {
    like = true;
    setState(() {});
    animController.forward().then((value) {
      animController.reset();
      print('reset');
    });
  }

  void unLike() {
    like = false;
    setState(() {});
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Splash Like Animation'),
        automaticallyImplyLeading: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setLike(!like);
                        },
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://i0.wp.com/radojuva.com/wp-content/uploads/sg/nikon-d3100-new/nikon-d3100-sample-shot-lynx-tassi-mode-23.jpg?ssl=1',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      AnimatedBuilder(
                          animation: animController,
                          builder: (context, _) {
                            return animController.value > 0.0
                                ? Center(
                                    child: Lottie.asset(
                                      'assets/lottie/like_anim.json',
                                      controller: animController,
                                      onLoaded: (composition) {},
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }),
                    ],
                  ),
                ),
                SizedBox(
                  height: 188,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Material(
                              borderRadius: BorderRadius.circular(50),
                              color: const Color(0xfffc8a8a),
                              clipBehavior: Clip.hardEdge,
                              child: InkWell(
                                onTap: () {
                                  setLike(!like);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                      'assets/svg/heart.svg',
                                      width: 34,
                                      height: 34,
                                      color: !like ? Colors.white : null),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                            'Tap on the Image or the Icon to drop a like',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          AnimatedBuilder(
              animation: animController,
              builder: (context, _) {
                return animController.value > 0.0
                    ? Column(
                        children: [
                          Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: colorAnim.value!, width: 20)),
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                      colorAnim.value!, BlendMode.srcOut),
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: borderAnim.value!,
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.all(40.0),
                                    child: Lottie.asset(
                                      'assets/lotte/like_anim.json',
                                      controller: animController,
                                      onLoaded: (composition) {
                                        // Configure the AnimationController with the duration of the
                                        // Lottie file and start the animation.
                                        animController
                                          ..duration = composition.duration
                                          ..forward();
                                      },
                                    ),
                                  ),
                                )),
                          ),
                          Container(
                            color: colorAnim.value!,
                            height: 188,
                          )
                        ],
                      )
                    : const SizedBox.shrink();
              }),
        ],
      ),
    );
  }
}
