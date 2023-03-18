import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart' as http_io;

void main() {
  runApp(const ChatbotApp());
}

class ChatbotApp extends StatelessWidget {
  const ChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatScreen(),
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
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

// ...

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];

  Widget _buildMessageList() {
    return ListView.builder(
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(_messages[index]));
      },
    );
  }

  Future<void> sendMessage(String message) async {
    String apiKey = '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';
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
      /* no proxy
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(body),
      );*/

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        final String reply = responseData['choices'][0]['message']['content'].trim();

        setState(() {
          _messages.add('User: $message');
          _messages.add('Chatbot: $reply');
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
      appBar: AppBar(title: const Text('ChatGPT Chatbot')),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          TextField(controller: _textController),
          ElevatedButton(
            onPressed: () {
              final String message = _textController.text.trim();
              if (message.isNotEmpty) {
                sendMessage(message);
                _textController.clear();
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
