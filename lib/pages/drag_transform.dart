import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';

const String imageUrl =
    'https://d19lgisewk9l6l.cloudfront.net/assetbank/Moonlit_Sanctuary_Victoria_Australia_60587.jpg';

class DragDropExample extends StatefulWidget {
  const DragDropExample({super.key});

  @override
  State createState() => _DragDropExampleState();
}

class _DragDropExampleState extends State<DragDropExample> {
  Duration addItemDuration = const Duration(milliseconds: 300);
  List<String> horizontalItems = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
    'Item 6',
  ];
  List<String> verticalItems = [];

  Tuple2<int, String>? draggingItem;

  String? addingItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drag and Transform'),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Container(
            height: 70,
            padding: const EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: const Text('LongPressDraggable List'),
          ),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: horizontalItems.length,
              itemBuilder: (context, index) {
                return LongPressDraggable(
                  data: horizontalItems[index],
                  feedback: Material(
                      color: Colors.transparent,
                      child: buildItem(1, horizontalItems[index], true)),
                  childWhenDragging:
                      buildItem(1, horizontalItems[index], false),
                  child: buildItem(1, horizontalItems[index], false),
                );
              },
            ),
          ),
          Container(
            height: 70,
            padding: const EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: const Text('DragTarget List'),
          ),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                    itemCount: verticalItems.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return DragTarget<String>(
                          onWillAccept: (data) {
                            if (data != null) {
                              draggingItem = Tuple2(index, data);
                              setState(() {});
                            }
                            return true;
                          },
                          onLeave: (_) {
                            draggingItem = null;
                            setState(() {});
                          },
                          onAccept: (data) {
                            addVerticalItem(data, index + 1);
                          },
                          builder: (BuildContext context,
                                  List<String?> candidateData,
                                  List<dynamic> rejectedData) =>
                              Column(
                                children: [
                                  buildItem(2, verticalItems[index], false),
                                  //shrink animation
                                  AnimatedContainer(
                                    duration: addingItem == null
                                        ? addItemDuration
                                        : Duration.zero,
                                    height: draggingItem != null &&
                                            draggingItem!.value1 == index
                                        ? 74
                                        : 0,
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      transitionBuilder: (Widget child,
                                          Animation<double> animation) {
                                        return ScaleTransition(
                                            scale: animation, child: child);
                                      },
                                      reverseDuration: Duration.zero,
                                      child: draggingItem != null &&
                                              draggingItem!.value1 == index
                                          ? Align(
                                              alignment: Alignment.centerLeft,
                                              child: buildItem(1,
                                                  draggingItem!.value2, true),
                                            )
                                          : const SizedBox(),
                                    ),
                                  )
                                ],
                              ));
                    }),
                if (verticalItems.isEmpty) dragPlaceholder()
              ],
            ),
          ),
        ],
      ),
    );
  }

  void addVerticalItem(String data, int index) {
    setState(() {
      verticalItems.insert(index, data);
      draggingItem = null;
      horizontalItems.remove(data);
      addingItem = data;
      Future.delayed(addItemDuration, () {
        addingItem = null;
        setState(() {});
      });
    });
  }

  Widget buildItem(int mode, String text, bool feedback) {
    return ListItemWidget(
      mode: mode,
      text: text,
      feedback: feedback,
      key: ValueKey(text),
      animate: addingItem == text,
    );
  }

  Widget dragPlaceholder() {
    return DragTarget<String>(
      onAccept: (data) {
        addVerticalItem(data, 0);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: 100,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Center(
            child: Text('Drag Here'),
          ),
        );
      },
    );
  }
}

class ListItemWidget extends StatefulWidget {
  const ListItemWidget(
      {super.key,
      required this.mode,
      required this.text,
      required this.feedback,
      required this.animate});

  final int mode;
  final String text;
  final bool feedback;

  final bool animate;

  @override
  State<ListItemWidget> createState() => _ListItemWidgetState();
}

class _ListItemWidgetState extends State<ListItemWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );

  final ColorTween _colorTween =
      ColorTween(begin: Colors.blue, end: Colors.orange);

  @override
  void initState() {
    _colorTween.animate(_controller);
    if (widget.animate) {
      _controller.forward();
    } else {
      if (widget.mode == 2) {
        _controller.value = 1.0;
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = const Size(0, 0);
    if (widget.mode == 1) {
      size = const Size(200, 50);
    } else {
      size = const Size(double.infinity, 50);
    }
    double maxWidth = MediaQuery.of(context).size.width - 24;
    return AnimatedBuilder(
      builder: (context, _) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: widget.feedback
                  ? Colors.grey[300]
                  : _colorTween.evaluate(_controller),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: SizedBox(
              height: size.height,
              width: 200 + ((maxWidth - 200) * _controller.value),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(5 + (20 * _controller.value)),
                    child: Image.network(
                      imageUrl,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(widget.text,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      },
      animation: _controller,
    );
  }
}
