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

Widget _buildMessageList() {
  return ListView.builder(
    itemCount: _messages.length,
    itemBuilder: (context, index) {
      bool isUserMessage = index % 2 == 0;
      return Row(
        mainAxisAlignment: isUserMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUserMessage) ...[
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/chatbot_avatar.png'),
            ),
            SizedBox(width: 8.0),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            margin: EdgeInsets.fromLTRB(
              isUserMessage ? 64.0 : 16.0,
              4.0,
              isUserMessage ? 16.0 : 64.0,
              4.0,
            ),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isUserMessage
                  ? Colors.grey.shade300
                  : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              _messages[index],
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isUserMessage) ...[
            SizedBox(width: 8.0),
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/user_avatar.png'),
            ),
          ],
        ],
      );
    },
  );
}
/*
Widget _buildMessageList() {
  return ListView.builder(
    itemCount: _messages.length,
    itemBuilder: (context, index) {
      bool isUserMessage = index % 2 == 0;
      return Container(
        margin: EdgeInsets.fromLTRB(
          isUserMessage ? 64.0 : 16.0, // Add left margin for chatbot messages
          4.0, // Reduced top margin
          isUserMessage ? 16.0 : 64.0, // Add right margin for user messages
          4.0, // Reduced bottom margin
        ),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.grey.shade300 : Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          _messages[index],
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    },
  );
}*/

  Future<void> sendMessage(String message) async {
    String apiKey = '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';
    //String apiKey = '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';
    String apiUrl = 'https://api.openai.com/v1/chat/completions';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    Map<String, dynamic> body = {
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'user', 'content': message}
      ],
    };

    try {
      http.Client httpClient = createHttpClient();
      final response = await httpClient.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        final String reply = responseData['choices'][0]['message']['content'].trim();

        setState(() {
          _messages.add('$message');
          _messages.add('$reply');
        });
      } else {
        throw Exception('Failed to get response from the ChatGPT API.');
      }
    } catch (error) {
      print('Error: $error');
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
                Expanded(
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
                  onPressed: () {
                    final String message = _textController.text.trim();
                    if (message.isNotEmpty) {
                      sendMessage(message);
                      _textController.clear();
                    }
                  },
                  child: const Text('Send'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
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