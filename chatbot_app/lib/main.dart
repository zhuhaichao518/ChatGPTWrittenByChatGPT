import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart' as http_io;

void main() {
  runApp(const ChatbotApp());
}

class ChatbotApp extends StatelessWidget {
  const ChatbotApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ChatScreen(),
    );
  }
}

http.Client createHttpClient() {
  var httpClient = HttpClient();
  httpClient.findProxy = (uri) {
    return 'PROXY 127.0.0.1:4780';
  };
  return http_io.IOClient(httpClient);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];
  final List<Map<String, String>> _conversation = [];
  bool _isButtonDisabled = false;

  Widget _buildMessageList() {
    return ListView.builder(
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        bool isUserMessage = index % 2 == 0;
        return Column(
          children: [
            Row(
              mainAxisAlignment: isUserMessage
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!isUserMessage) ...[
                  CircleAvatar(
                    backgroundImage:
                        AssetImage('assets/images/chatbot_avatar.png'),
                  ),
                  SizedBox(width: 8.0),
                ],
                CustomPaint(
                  painter: BubblePainter(isUser: isUserMessage),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    margin: EdgeInsets.fromLTRB(
                      isUserMessage ? 16.0 : 16.0,
                      4.0,
                      isUserMessage ? 16.0 : 16.0,
                      4.0,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: SelectableText(
                      _messages[index],
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (isUserMessage) ...[
                  SizedBox(width: 8.0),
                  CircleAvatar(
                    backgroundImage:
                        AssetImage('assets/images/user_avatar.png'),
                  ),
                ],
              ],
            ),
            SizedBox(height: 8.0),
          ],
        );
      },
    );
  }

  Future<void> sendMessage(String message) async {
    setState(() {
      _isButtonDisabled = true;
      _conversation.add({'role': 'user', 'content': message});
      _messages.add('$message');
    });
    String apiKey = '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';
    String apiUrl = 'https://api.openai.com/v1/chat/completions';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    Map<String, dynamic> body = {
      'model': 'gpt-4', //'gpt-3.5-turbo',
      'messages': _conversation,
      'temperature': 0.7,
      'stream': true,
    };

    try {
      http.Client httpClient = createHttpClient();
      final request = http.Request('POST', Uri.parse(apiUrl));
      request.headers.addAll(headers);
      request.body = json.encode(body);
      final streamedResponse = await httpClient.send(request);

      final linesStream = streamedResponse.stream
          .asBroadcastStream()
          .transform(utf8.decoder)
          .transform(const LineSplitter());
      
      _messages.add('');
      int myid = _messages.length -1;
      await for (String line in linesStream) {
        if (line != '' && line!= 'data: [DONE]') {
          String jsonData = line.substring(6);
          Map<String, dynamic> decodedJson = jsonDecode(jsonData);
          if (decodedJson['choices'][0]['delta'].containsKey('content')) {
            String deltaContent = decodedJson['choices'][0]['delta']['content'];
            print('Delta content: $deltaContent');
            setState(() {
              _messages[myid] = _messages[myid] + deltaContent;
              _isButtonDisabled = false;
            });
          }
        }
      }
      setState(() {
          _conversation.add({'role': 'assistant', 'content': _messages.last});
          _isButtonDisabled = false;
      });
    } catch (error) {
      setState(() {
        _messages.add('$error');
        _isButtonDisabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatGPT Chatbot'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Flexible(
                  // 新增的 Flexible 部件
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type your message',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _isButtonDisabled
                      ? null
                      : () {
                          final String message = _textController.text.trim();
                          if (message.isNotEmpty) {
                            sendMessage(message);
                            _textController.clear();
                          }
                        },
                  child: const Text('Send'),
                  style: ElevatedButton.styleFrom(
                    primary:
                        _isButtonDisabled ? Colors.grey : Colors.blue.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: Size(88, 58),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  final bool isUser;

  BubblePainter({required this.isUser});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isUser ? Colors.grey.shade300 : Colors.blue.shade100
      ..style = PaintingStyle.fill;

    final borderRadius = 12.0;
    final arrowHeight = 7.0;
    final arrowWidth = 8.0;
    final arrowOffset = 16.0;
    final mid = size.height / 2;
    final path = Path();

    path.moveTo(borderRadius, 0);
    path.lineTo(size.width - borderRadius, 0);
    path.arcToPoint(Offset(size.width, borderRadius),
        radius: Radius.circular(borderRadius));

    if (isUser) {
      path.lineTo(size.width, mid - arrowHeight);
      path.lineTo(size.width + arrowWidth, mid);
      path.lineTo(size.width, mid + arrowHeight);
      path.lineTo(size.width, size.height - borderRadius);
      path.arcToPoint(Offset(size.width - borderRadius, size.height),
          radius: Radius.circular(borderRadius));
    } else {
      path.lineTo(size.width, size.height - borderRadius);
      path.arcToPoint(Offset(size.width - borderRadius, size.height),
          radius: Radius.circular(borderRadius));
    }

    path.lineTo(borderRadius, size.height);
    path.arcToPoint(Offset(0, size.height - borderRadius),
        radius: Radius.circular(borderRadius));

    if (!isUser) {
      path.lineTo(0, mid + arrowHeight);
      path.lineTo(0 - arrowWidth, mid);
      path.lineTo(0, mid - arrowHeight);
      path.lineTo(0, borderRadius);
      path.arcToPoint(Offset(borderRadius, 0),
          radius: Radius.circular(borderRadius));
    } else {
      path.lineTo(0, borderRadius);
      path.arcToPoint(Offset(borderRadius, 0),
          radius: Radius.circular(borderRadius));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
