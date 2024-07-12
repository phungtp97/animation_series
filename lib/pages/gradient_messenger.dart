import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lorem_gen/lorem_gen.dart';

class GradientMessenger extends StatefulWidget {
  const GradientMessenger({super.key});

  @override
  State createState() => _GradientMessengerState();
}

class _GradientMessengerState extends State<GradientMessenger> {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    ///scroll the listview all the way to bottom
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   controller.jumpTo(controller.position.maxScrollExtent);
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget user = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.only(right: 12),
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: const FlutterLogo(size: 30)),
        const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Chat')],
        ),
      ],
    );
    Widget actionBar = SizedBox(
      width: 122,
      child: Row(
        children: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.call),
              color: Colors.blue),
          const SizedBox(width: 16),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.video_call),
              color: Colors.blue),
        ],
      ),
    );

    Widget content = Column(
      children: [
        Expanded(child: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.pinkAccent,
                    Colors.deepPurpleAccent,
                    Colors.blue,
                  ],
                )),
            child: buildChatContent())),
        //chat input
        Container(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            height: 36,
            child: Row(
              children: [
                const Icon(Icons.add, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Aa',
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(44),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.send, color: Colors.blue),
              ],
            ),
          ),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(child: user),
        elevation: 0.0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
        ),
        titleSpacing: 0,
        centerTitle: false,
        actions: [
          actionBar,
        ],
      ),
      body: SafeArea(
          child: content),
    );
  }

  Widget buildChatContent() {
    List<MessageEntity> messages = List.from(MessageBank.messages.where(
        (element) =>
            (element.sender == MessageBank.me &&
                element.to == MessageBank.sender) ||
            (element.sender == MessageBank.sender &&
                element.to == MessageBank.me)));

    messages.sort((a, b) => b.timeMillis.compareTo(a.timeMillis));

    ///ListView builder for chat content, group by sender and with near timeMillis
    return ListView.builder(
      itemCount: messages.length,
      controller: controller,
      reverse: true,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.sender == MessageBank.me;
        final nextMsg =
            index + 1 < messages.length ? messages[index + 1] : null;
        final lastMsg = index - 1 >= 0 ? messages[index - 1] : null;
        final bool startOfSection = lastMsg == null ||
            lastMsg.sender != message.sender ||
            message.timeMillis - lastMsg.timeMillis > 180000000;
        final bool endOfSection = nextMsg == null ||
            nextMsg.sender != message.sender ||
            nextMsg.timeMillis - message.timeMillis > 180000000;
        return Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.blue.shade100,
                  isMe ? BlendMode.srcOut : BlendMode.dstATop),
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  children: [
                    if (endOfSection)
                      const SizedBox(
                        height: 24,
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 42),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: isMe ? Colors.white : Colors.white,
                            borderRadius: isMe
                                ? buildMyBorder(startOfSection, endOfSection)
                                : buildOtherBorder(
                                    startOfSection, endOfSection)),
                        child: Text(
                          message.message,
                          style: TextStyle(
                            color:
                                isMe ? Colors.transparent : Colors.transparent,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              color: isMe ? Colors.transparent : Colors.blue.shade100,
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                children: [
                  if (endOfSection)
                    Container(
                      width: double.infinity,
                      color: isMe ? Colors.transparent : Colors.blue.shade100,
                      height: 24,
                      alignment: Alignment.center,
                      child: Text(
                        timeAgo(message.timeMillis),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (startOfSection && !isMe)
                        Container(
                            width: 42,
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: const FlutterLogo(size: 20))
                      else
                        const SizedBox(width: 42),
                      Expanded(
                          child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: isMe ? Colors.transparent : Colors.white,
                            borderRadius: isMe
                                ? buildMyBorder(startOfSection, endOfSection)
                                : buildOtherBorder(startOfSection, endOfSection)),
                        child: Text(
                          message.message,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      )),
                      if (startOfSection && isMe)
                        Container(
                            padding: const EdgeInsets.all(3),
                            margin: const EdgeInsets.only(right: 10),
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: const FlutterLogo(size: 20))
                      else
                        const SizedBox(width: 42),
                    ],
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  BorderRadius buildOtherBorder(bool startOfSection, bool endOfSection) {
    if (startOfSection && endOfSection) {
      return BorderRadius.circular(12);
    } else if (startOfSection) {
      return const BorderRadius.only(
        topRight: Radius.circular(12),
        topLeft: Radius.circular(3),
        bottomRight: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      );
    } else if (endOfSection) {
      return const BorderRadius.only(
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
        bottomLeft: Radius.circular(3),
        topLeft: Radius.circular(12),
      );
    } else {
      return const BorderRadius.only(
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12),
        topLeft: Radius.circular(3),
        bottomLeft: Radius.circular(3),
      );
    }
  }

  BorderRadius buildMyBorder(bool startOfSection, bool endOfSection) {
    if (startOfSection && endOfSection) {
      return BorderRadius.circular(12);
    } else if (startOfSection) {
      return const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(3),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      );
    } else if (endOfSection) {
      return const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomRight: Radius.circular(3),
        bottomLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(3),
        bottomRight: Radius.circular(3),
        bottomLeft: Radius.circular(12),
      );
    }
  }

  String timeAgo(int timeMillis) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int diff = now - timeMillis;
    if (diff < 60000) {
      return 'Just now';
    } else if (diff < 3600000) {
      return '${(diff / 60000).floor()} minutes ago';
    } else if (diff < 86400000) {
      return '${(diff / 3600000).floor()} hours ago';
    } else {
      return '${(diff / 86400000).floor()} days ago';
    }
  }
}

class MessageEntity {
  final String message;
  final String sender;
  final String to;
  final int timeMillis;

  MessageEntity({
    required this.message,
    required this.sender,
    required this.to,
    required this.timeMillis,
  });
}

class MessageBank {
  static List<MessageEntity> messages = generatedMessages(100);

  MessageBank._();

  static List<String> senders = [
    'Tom',
    'Dave',
    'Bob',
    'Charlie',
    'Alice',
    'Eve'
  ];
  static String me = 'Tom';

  static String sender = 'Dave';
}

List<MessageEntity> generatedMessages(int numberOfMessages) {
  final int currentTimeMillis = DateTime.now().millisecondsSinceEpoch;
  final Random random = Random();

  List<MessageEntity> messages = [];

  for (int i = 0; i < numberOfMessages; i++) {
    int randomInt = random.nextInt(4);
    String sender = MessageBank.senders[randomInt];
    int timeOffset = random.nextInt(1000 * 60 * 120);
    int messageTime = currentTimeMillis - timeOffset;
    String receiver = MessageBank.me;
    // Ensure sender is not the same as receiver
    if (sender == MessageBank.me) {
      receiver = MessageBank.senders[random.nextInt(4) + 1];
    }

    messages.add(
      MessageEntity(
        message:
            'Message $i from $sender to $receiver\n${Lorem.sentence(numSentences: Random().nextInt(1) + 1)}',
        sender: sender,
        to: receiver,
        timeMillis: messageTime,
      ),
    );
    print('Message $i from $sender to $receiver');
  }

  return messages;
}
