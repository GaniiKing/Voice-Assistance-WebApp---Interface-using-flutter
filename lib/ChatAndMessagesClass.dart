import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';



class ChatScreen extends StatefulWidget {
  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();



  Future<void> _handleSubmitted(String text) async {
    String parameter = _textController.text;
    _textController.clear();
    ChatMessage message = ChatMessage(
      text: text,
      isCurrentUser: true,
    );
    setState(() {
      _messages.insert(0, message);
    });

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/textanalysis?query=$parameter'),
      headers: {'Content-Type': 'application/json'},
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      await Future.delayed(Duration(seconds: 1));
      print(responseBody);

      if (responseBody['index'] == 3) {
        dynamic jsonData = responseBody['text'];
        List<Map<String, dynamic>> parsedData;
        if (jsonData is List) {
          parsedData = jsonData.cast<Map<String, dynamic>>();
        } else if (jsonData is String) {
          parsedData = jsonDecode(jsonData).cast<Map<String, dynamic>>();
        } else {
          print('Unexpected type for jsonData: ${jsonData.runtimeType}');
          return;
        }

        for (var i = 0; i < 5 && i < parsedData.length; i++) {
          Map<String, dynamic> data = parsedData[i];
          ChatMessage chatMessage = ChatMessage.fromData(data);

            setState(() {
              _messages.insert(0, chatMessage);
            });
        }
        String text='';
        print(responseBody['index'].runtimeType);
        text=text.toString();
        final response = await http.get(Uri.parse('http://127.0.0.1:8000/speaktext?query_2=$text&index=3'),headers: {'Content-Type': 'application/json'});
        print('SpeakText URL: ${response.request?.url}');
        print(response.statusCode);
        if(response.statusCode==200){
          print('Speak connection successful... to speak text');
        }
      } else {
        _handleReceived(responseBody['index'], responseBody['text']);
      }
    } else {
      print('Error sending message to the backend: ${response.statusCode}');
    }
  }


  void _handleReceived(int index,String text) async {
    print(index.runtimeType);
    print(index);
    ChatMessage message = ChatMessage(
      text: text,
      isCurrentUser: false,
    );
    setState(() {
      _messages.insert(0, message);
    });
    String text_2 = text.toString();
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/speaktext?query_2=$text_2&index=$index'),headers: {'Content-Type': 'application/json'});
    print('SpeakText URL: ${response.request?.url}');
    print(response.statusCode);
    if(response.statusCode==200){
      print('Speak connection successful...');
    }

  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
        ),
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                reverse: true,
                itemBuilder: (_, int index) => _messages[index],
                itemCount: _messages.length,
              ),
            ),
            Divider(height: 1.0),
            Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color:Colors.greenAccent),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration:
                InputDecoration.collapsed(hintText: 'Send a message',border: InputBorder.none,
                fillColor: Colors.white54,filled: true,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isCurrentUser;

  ChatMessage({required this.text, required this.isCurrentUser});

  factory ChatMessage.fromData(Map<String, dynamic> data) {
    String sourceName = data['source']['name'] ?? '';
    String title = data['title'] ?? '';
    String publishedAt = data['publishedAt'] ?? '';
    String url = data['url'] ?? '';
    String text = '$sourceName - $title - $publishedAt-URL:$url';

    return ChatMessage(
      text: text,
      isCurrentUser: false, // Assuming this message is not sent by the current user
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
        isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Padding(
            padding: isCurrentUser ? EdgeInsets.only(left: 20): EdgeInsets.only(right: 20),
            child: Container(
              padding: EdgeInsets.all(8.0),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6
              ),
              decoration: BoxDecoration(
                color:
                isCurrentUser ? Colors.blueAccent : Colors.greenAccent,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                text,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

