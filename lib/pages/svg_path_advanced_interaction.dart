import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:xml/xml.dart' as xml;

class SvgPathAdvancedInteraction extends StatefulWidget {
  const SvgPathAdvancedInteraction({super.key});

  @override
  State<SvgPathAdvancedInteraction> createState() =>
      _SvgPathAdvancedInteractionState();
}

class _SvgPathAdvancedInteractionState
    extends State<SvgPathAdvancedInteraction> {
  ValueNotifier<ExtractedPathData?> selectedPath = ValueNotifier(null);

  List<ExtractedPathData> paths = [];

  List<Rect> rects = [];
  Size svgSize = Size.zero;

  Size? screenSize;

  @override
  void dispose() {
    selectedPath.dispose();
    super.dispose();
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() {
    try {
      final document = xml.XmlDocument.parse(svgContent);
      final pathContents = document.findAllElements('path');
      final textContents = document.findAllElements('text');
      final rectContents = document.findAllElements('rect');
      getSvgSize(document.findAllElements('svg').first);
      for (var element in pathContents) {
        final String? id = element.getAttribute('id');
        final String? path = element.getAttribute('d');

        if (id != null && path != null) {
          final int textElementIndex = textContents.toList().indexWhere(
              (element) => element.getAttribute('id') == '${id}-text');
          Tuple2<String, Offset>? textData;
          if (textElementIndex != -1) {
            Offset? offset;
            final double? dx = double.tryParse(
                textContents.elementAt(textElementIndex).getAttribute('x') ??
                    '');
            final double? dy = double.tryParse(
                textContents.elementAt(textElementIndex).getAttribute('y') ??
                    '');
            if (dx != null && dy != null) {
              offset = Offset(dx, dy);
              textData =
                  Tuple2(textContents.elementAt(textElementIndex).text, offset);
            }
          }
          final pathData = parseSvgPath(path);
          final extractedPathData =
              ExtractedPathData(id, pathData, textData: textData);
          paths.add(extractedPathData);
        }
      }

      for (var element in rectContents) {
        final double? x = double.tryParse(element.getAttribute('x') ?? '');
        final double? y = double.tryParse(element.getAttribute('y') ?? '');
        final double? width =
            double.tryParse(element.getAttribute('width') ?? '');
        final double? height =
            double.tryParse(element.getAttribute('height') ?? '');
        if (x != null && y != null && width != null && height != null) {
          rects.add(Rect.fromLTWH(x, y, width, height));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void getSvgSize(xml.XmlElement svgElement) {
    final viewBox = svgElement.getAttribute('viewBox');

    final viewBoxValues =
        viewBox?.split(' ').map((value) => double.parse(value)).toList();
    if (viewBoxValues != null) {
      final double width = viewBoxValues[2];
      final double height = viewBoxValues[3];
      svgSize = Size(width, height);
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize ??= MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SVG Path Advanced Interaction'),
      ),
      body: Center(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: svgSize.width,
                height: svgSize.height,
                child: Transform.scale(
                  alignment: Alignment.topLeft,
                  scale: screenSize!.width / svgSize.width,
                  child: Stack(
                    children: [
                      Container(
                        width: svgSize.width,
                        height: svgSize.height,
                        color: Colors.white,
                      ),
                      Stack(
                        children: [
                          ...rects.map((rect) => drawRect(rect)).toList(),
                          ...paths
                              .map((pathData) => drawPath(pathData))
                              .toList(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ValueListenableBuilder(
                valueListenable: selectedPath,
                builder: (context, ExtractedPathData? pathData, child) {
                  return pathData != null
                      ? Text('You have selected section: ${pathData.id}')
                      : const SizedBox.shrink();
                }),
          ],
        ),
      ),
    );
  }

  Widget drawPath(ExtractedPathData pathData) {
    Color randomColor =
        Colors.primaries[paths.indexOf(pathData) % Colors.primaries.length];
    return ClipPath(
      clipper: CustomShapeClipper(pathData.path),
      child: Material(
        color: Colors.white,
        child: InkWell(
          splashColor: randomColor,
          onTap: () {
            print('Tapped ${pathData.id}');
            selectedPath.value = pathData;
          },
          child: CustomPaint(
            painter: PathPainter(pathData.path, randomColor,
                textData: pathData.textData),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget drawRect(Rect rect) {
    return CustomPaint(
      painter: RectPainter(rect, const Color(0xff70826c)),
      child: Container(
        width: rect.width,
        height: rect.height,
        color: Colors.transparent,
      ),
    );
  }
}

class CustomShapeClipper extends CustomClipper<Path> {
  final Path path;

  CustomShapeClipper(this.path);

  @override
  Path getClip(Size size) {
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class RectPainter extends CustomPainter {
  final Rect rect;

  final Color color;

  RectPainter(this.rect, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class PathPainter extends CustomPainter {
  final Path path;

  final Color color;

  final Tuple2<String, Offset>? textData;

  PathPainter(this.path, this.color, {this.textData});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;
    //draw text
    if (textData != null) {
      final text = textData!.value1;
      final offset = textData!.value2;

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(color: color, fontSize: 30),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        textScaleFactor: 1.0,
        textWidthBasis: TextWidthBasis.longestLine,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(offset.dx, offset.dy - 15));
    }
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ExtractedPathData {
  final String id;
  final Path path;

  final Tuple2<String, Offset>? textData;

  ExtractedPathData(this.id, this.path, {this.textData});
}

const String svgContent = '''<?xml version="1.0" encoding="utf-8"?>
<svg viewBox="0 0 500 500" xmlns="http://www.w3.org/2000/svg">
  <path id="section-b1" style="fill: rgb(216, 216, 216); stroke: rgb(0, 0, 0);" d="M 35.593 177.346 C 45.932 107.735 64.207 26.843 160.473 11.571 L 173.903 96.604 C 145.196 107.197 142.591 183.297 143.05 173.127 C 143.05 173.127 34.665 178.472 35.593 177.346 Z" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)"/>
  <path id="section-c1" style="fill: rgb(216, 216, 216); stroke: rgb(0, 0, 0);" d="M 181.945 95.747 L 169.142 10.881 C 169.142 3.793 247.576 4.503 247.675 9.46 C 246.778 9.351 241.985 96.13 242.452 93.747 C 242.92 91.363 174.825 93.151 181.945 95.747 Z" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)"/>
  <path id="section-c2" style="fill: rgb(216, 216, 216); stroke: rgb(0, 0, 0);" d="M 257.286 10.469 L 251.373 94.847 C 251.805 92.513 304.346 99.382 304.017 101.16 L 314.567 15.538 C 315.207 14.847 260.145 7.386 257.286 10.469 Z" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)"/>
  <path id="section-c3" style="fill: rgb(216, 216, 216); stroke: rgb(0, 0, 0);" d="M 327.866 19.425 L 312.869 103.783 C 313.432 102.617 345.435 108.363 343.498 112.373 C 343.498 112.373 370.994 34.754 371.879 32.789 C 372.766 30.824 330.249 15.232 327.866 19.425 Z" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)"/>
  <path id="section-c4" style="fill: rgb(216, 216, 216); stroke: rgb(0, 0, 0);" d="M 382.099 37.662 C 387.467 32.771 422.383 58.032 429.1 73.074 L 373.241 133.549 C 378.464 134.647 360.433 117.561 352.677 115.929 L 382.099 37.662 Z" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)"/>
  <path id="section-b2" style="fill: rgb(216, 216, 216); stroke: rgb(0, 0, 0);" d="M 434.725 83.88 L 377.553 137.918 C 382.449 139.129 390.165 205.207 385.457 205.397 C 380.751 205.585 462.016 200.316 470.679 200.701 C 479.34 201.087 465.409 98.211 434.725 83.88 Z" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)"/>
  <path id="section-a1" style="fill: rgb(216, 216, 216); stroke: rgb(0, 0, 0);" d="M 385.493 212.653 L 471.346 211.148 L 464.677 381.934 L 377.325 374.273 L 380.615 308.93 L 404.743 311.141 L 406.123 289.238 L 422.61 290.974 L 423.085 264.147 C 423.085 264.147 407.611 263.31 407.611 263.226 C 407.611 263.14 407.276 241.005 407.276 241.005 C 407.276 241.005 384.02 238.127 384.091 238.214 C 384.164 238.301 385.955 213.579 385.493 212.653 Z" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)"/>
  <path id="section-b4" style="fill: rgb(216, 216, 216); stroke: rgb(0, 0, 0);" d="M 34.07 190.634 L 55.31 190.017 C 52.569 192.736 54.2 257.779 55.83 256.162 L 81.367 256.129 C 78.18 256.256 78.971 342.028 78.292 340.44 C 78.292 340.44 31.626 342.78 29.348 342.082 C 27.07 341.385 31.215 188.283 34.07 190.634 Z" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)"/>
  <path id="section-vip" style="fill: rgb(216, 216, 216); stroke: rgb(0, 0, 0);" d="M 63.111 190.573 L 62.545 248.382 L 87.325 247.632 C 87.325 247.632 138.258 247.894 138.33 247.982 C 138.403 248.069 141.177 189.305 141.249 189.218 C 141.321 189.13 63.278 190.013 63.111 190.573 Z" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)"/>
  <path id="section-a2" style="fill: rgb(216, 216, 216); stroke: rgb(0, 0, 0);" d="M 87.22 257.106 L 85.008 341.422 L 138.892 342.507 L 138.505 259.498 L 87.22 257.106 Z" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)"/>
  <path id="section-b3" style="fill: rgb(216, 216, 216); stroke: rgb(0, 0, 0);" d="M 28.213 350.925 L 138.51 353.463 C 143.736 396.634 143.954 411.051 176.818 415.406 L 162.805 482.749 C 52.821 466.514 31.417 436.201 28.213 350.925 Z" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)"/>
  <path id="section-c7" style="fill: rgb(216, 216, 216); stroke: rgb(0, 0, 0);" d="M 182.451 419.105 L 169.487 484.266 C 169.307 486.978 233.14 494.278 233.35 491.157 L 233.532 423.913 C 233.344 425.661 181.307 421.449 182.451 419.105 Z" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)"/>
  <path id="section-c6" style="fill: rgb(216, 216, 216); stroke: rgb(0, 0, 0);" d="M 240.865 425.645 L 240.699 493.011 L 323.403 490.315 C 323.162 492.721 302.789 431.552 302.683 427.709 L 240.865 425.645 Z" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)"/>
  <path id="section-c5" style="fill: rgb(216, 216, 216); stroke: rgb(0, 0, 0);" d="M 309.363 426.147 L 332.289 486.973 C 351.702 486.244 473.424 394.724 461.163 395.186 C 460.717 396.457 365.949 387.535 374.712 387.334 C 383.474 387.134 314.778 432.641 309.363 426.147 Z" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)"/>
  <rect id="yard" x="178.608" y="111.901" width="158.275" height="297.035" style="fill: rgb(216, 216, 216); stroke: rgb(0, 0, 0);" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)"/>
  <text id="section-b1-text" style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 28px;" x="82.051" y="104.094" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)">B1</text>
  <text id="section-c1-text" style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 28px;" x="192.768" y="55.119" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)">C1</text>
  <text id="section-c2-text" style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 28px;" x="266.135" y="54.268" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)">C2</text>
  <text id="section-c3-text" style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 28px;" x="324.184" y="66.67" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)">C3</text>
  <text id="section-c4-text" style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 28px;" x="369.566" y="89.154" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)">C4</text>
  <text id="section-b2-text" style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 28px;" x="402.638" y="173.227" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)">B2</text>
  <text id="section-a1-text" style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 28px;" x="426.708" y="284.711" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)">A1</text>
  <text id="section-c5-text" style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 28px;" x="348.466" y="442.657" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)">C5</text>
  <text id="section-c6-text" style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 28px;" x="249.967" y="461.866" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)">C6</text>
  <text id="section-c7-text" style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 28px;" x="183.804" y="455.621" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)">C7</text>
  <text id="section-b3-text" style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 28px;" x="66.933" y="407.623" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)">B3</text>
  <text id="section-a2-text" style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 28px;" x="91.197" y="297.158" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)">A2</text>
  <text id="section-b4-text" style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 28px;" x="34.09" y="288.961" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)">B4</text>
  <text id="section-vip-text" style="white-space: pre; fill: rgb(51, 51, 51); font-family: Arial, sans-serif; font-size: 28px;" x="75.244" y="228.176" transform="matrix(1, 0, 0, 1, 5.684341886080802e-14, 0)">VIP</text>
</svg>''';
