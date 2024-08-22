import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myassistantinterface/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    ),
  );
}



class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ChatScreenState> _chatScreenStateKey = GlobalKey<ChatScreenState>();
  static bool _IsToggled = true;

  static bool get isToggled => _IsToggled;

  static void setToggled(bool value) {
    _IsToggled = value;
  }

  static String avatarImagePath = "assets/emotions_boy_and_girl/Boy_angry_lv2.png"; // Initial image path

  void updateAvatarImage(String imagePath) {

    setState(() {
      avatarImagePath = imagePath;
    });

  }
  static _MainPageState? instance;

  String wallpaperGender = '';

  @override
  void initState() {
    super.initState();
    instance = this;
    getGenderDetails();
  }

  Future<void> getGenderDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String gender = prefs.getString('Gender') ?? '';
    updateWallpaper(gender);
  }

  Future<void> ChangeWallpaper() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String gender = prefs.getString('Gender') ?? '';
    updateWallpaper(gender);
  }

  void updateWallpaper(String gender) {
    String Imagename = _IsToggled ? 'Technical' : 'NonTechnical';

    if (gender == "Male") {
      setState(() {
        wallpaperGender = 'assets/Wallpapers/Boy$Imagename.png';
      });
    } else if (gender == "Female") {
      setState(() {
        wallpaperGender = 'assets/Wallpapers/Girl$Imagename.png';
      });
    } else {
      // Handle other cases or provide a default wallpaper
      setState(() {
        wallpaperGender = 'assets/Wallpapers/Default.png';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:AssetImage(wallpaperGender),fit: BoxFit.cover
          )
        ),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left:20.0),
                  child: InkWell(
                    onTap: () {
                      ChatScreenState? chatScreenState = _chatScreenStateKey.currentState;
                      if(chatScreenState!=null && chatScreenState.mounted) {
                        chatScreenState._onClickImage();
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width*1/4,
                      height: MediaQuery.of(context).size.width*1/4,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 2,
                            offset: Offset(3,3)
                          )
                        ]
                      ),
                      child: CircleAvatar(
                        backgroundImage: AssetImage(_MainPageState.avatarImagePath),
                        radius: 190,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Row(
                  children: [
                    Switch(
                      activeColor: Colors.green,
                        value: _IsToggled, onChanged: (value){
                        ChangeWallpaper();
                            setState(() {
                              setToggled(value);
                            });
                    }),
                    Text(
                      _IsToggled ? 'Technical' : 'Personal',
                      style: TextStyle(fontSize: 18.0),
                    )
                  ],
                ),
      
              ],
            ),
            SizedBox(width: 30,),
            Expanded(child: ChatScreen(
              key: _chatScreenStateKey,
            ))
          ],
        ),
      ),
    );
  }
}




class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();
  String UserInput='';
  String SystemResponse='';

  void _onClickImage() async {
    print('Image is pressed for recording voice');
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/recvoiceOnclick'),headers: {'Content-Type': 'application/json'});
    print(response.statusCode);
    if(response.statusCode==200){
      print(response.body);
      var Output = jsonDecode(response.body);
      print(Output);
      _handleSubmitted(Output);
    }
  }

  Future<void> UploadDataToDB(String userinput, String systemoutput) async {
    final response = await http.post(
      Uri.parse('http://192.168.29.77/voice_Assistant/InsertChats.php'),
      body:  {
        'User': 'SampleUser',
        'UserInput': userinput,
        'SystemOutput': systemoutput,
      },
    );

    print('Upload to db status code is...');
    try {
      // Check if the response body is not empty
      if (response.body.isNotEmpty) {
        var decodedResponse = jsonDecode(response.body);
        print(decodedResponse);
      } else {
        print('Response body is empty');
      }
    } catch (e) {
      print('Error decoding JSON: $e');
    }
  }

  Future<void> _handleSubmitted(String text) async {
    print("The toggle button gives...");
    print(_MainPageState.isToggled);
    String parameter = text;
    _textController.clear();
    ChatMessage message = ChatMessage(
      text: text,
      isCurrentUser: true,
    );
    setState(() {
      _messages.insert(0, message);
    });
    if(_MainPageState.isToggled==true) {
      final response= await http.get(
        Uri.parse('http://127.0.0.1:8000/textanalysis?query=$parameter'),
        headers: {'Content-Type': 'application/json'},
      );
      setState(() {
        UserInput=parameter;
      });
      print(response.statusCode);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        await Future.delayed(Duration(seconds: 1));
        print("Recieved from backend in _handleSubmitted is $responseBody");

        if (responseBody['index'] == 3) {
          dynamic jsonData = responseBody['text'];
          setState(() {
            SystemResponse=jsonDecode(responseBody['text']);
          });
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
          setState(() {
            SystemResponse=responseBody['text'];
          });
          _handleReceived(responseBody['index'], responseBody['text']);
        }
      } else {
        setState(() {
          SystemResponse='';
        });
        print('Error sending message to the backend: ${response.statusCode}');
      }

      UploadDataToDB(UserInput,SystemResponse);


    }
    else if(_MainPageState.isToggled==false){
      setState(() {
        UserInput=parameter;
      });
      final response_2 = await http.get(
        Uri.parse('http://127.0.0.1:8000/personalSentenceAnalysis?statement=$parameter'),
        headers: {'Content-Type': 'application/json'},
      );
      print(response_2.statusCode);
      if(response_2.statusCode==200){
        print(response_2.body);
        var Body = jsonDecode(response_2.body);
        String emotion=Body['emotion'].toString();
        //String score = Body['score'].toString();

          Map<String, dynamic> emotionMapping = {
            "joy": {"reply_low": "Feeling happy? That's great!", "reply_medium": "You seem quite joyful!", "reply_high": "assets/Boy_happy.png"},
            "sadness": {"reply_low": "Cheer up! Things will get better.", "reply_medium": "I'm sorry you're feeling this way.", "reply_high": "assets/Boy_Sad.png"},
            "fear": {"reply_low": "It's okay to be cautious.", "reply_medium": "Feeling a bit fearful? I understand.", "reply_high": "assets/Boy_fear.png"},
            "love": {"reply_low": "I love you too!", "reply_medium": "You're feeling quite affectionate!", "reply_high": "assets/Boy_love.png"},
            "surprise": {"reply_low": "That's a bit unexpected!", "reply_medium": "You seem surprised. What happened?", "reply_high": "assets/Boy_Surprise.png"},
            "anger": {"reply_low": "Take a deep breath. It'll be okay.", "reply_medium": "Feeling a bit angry? Let's talk it out.", "reply_high": "assets/Boy_Surprise.png"}
          };

          String imagePath = emotionMapping[emotion]?["reply_high"];

          print("Image path is: $imagePath");
        _MainPageState?.instance?.updateAvatarImage(imagePath);

        String text = Body["reply"].toString();
        setState(() {
          SystemResponse=text;
        });

        UploadDataToDB(UserInput, SystemResponse);

        ChatMessage message = ChatMessage(
          text: text,
          isCurrentUser: false,
        );
        setState(() {
          _messages.insert(0, message);
        });
        final response_3 =await http.get(Uri.parse('http://127.0.0.1:8000/SentimentSpeak?sentence_2=$text'),headers: {'Content-Type': 'application/json'},);
        print(response_3.statusCode);
      }
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
