import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:myassistantinterface/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:clipboard/clipboard.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController username = TextEditingController();
  TextEditingController password   = TextEditingController();
  
  Future<void> AuthenticateUser() async {
    SharedPreferences prefs= await SharedPreferences.getInstance();
    prefs.clear();
    final response = await http.post(Uri.parse("http://localhost/voice_Assistant/LoginPage.php"),
      body: {
      'Username':username.text,
      'Password':password.text
      }
    );
    print(response.statusCode);
    print(response.body);
    if(response.statusCode == 200){
      Map<String,dynamic> body = jsonDecode(response.body);
      if(body['status']=='Success'){
        prefs.setString('Gender', body['gender'].toString());
        prefs.setString('UID', body['userid'].toString());
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MainPage()));
      }else if (body['status']=="Failed"){
        print('User not exists...');
      }else {
        //failed connection
      }
    }
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              height: 600,
              width: 550,
              constraints: BoxConstraints(
                minWidth: 600,
                minHeight: 550,
              ),
              child: Card(
                color: Colors.white.withOpacity(0.4),
                elevation: 20,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text("Login",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                      
                      const Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Icon(
                          Icons.account_circle_rounded,
                          size: 140,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: TextField(
                          controller: username,
                          decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: TextField(
                          controller: password,
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: IconButton(
                              onPressed: () {
                                AuthenticateUser();
                              },
                              icon: Icon(
                                Icons.arrow_circle_right_outlined,
                              ),
                              iconSize: 70.0,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New User?',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>RegisterPage()));
                            },
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confrimpassword = TextEditingController();
  static bool GenderBool = true;

  static bool get genderBool => GenderBool;

  static void setToggled(bool value) {
    GenderBool = value;
  }




  @override
  Widget build(BuildContext context) {

    Future<void>RegisterUser() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      String gender = GenderBool? "Male":"Female";
      final response = await http.post(Uri.parse("http://localhost/voice_Assistant/RegisterUser.php"),
        body: {
          "Username":username.text,
          "Password":password.text,
          "Gender":gender
        }
      );
      print(response.body);
      print(jsonDecode(response.body));
      Map<String, dynamic> body = jsonDecode(response.body);
      print(body['userid']);
      print(body['code']);
      print(body['code'].runtimeType);
      print(response.statusCode);
      if(response.statusCode==200) {
        print('Success connection...');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', username.text);
        prefs.setString('Gender', gender);
        prefs.setString('UID', body['userid'].toString());
        prefs.setString('PassResetCode', body['code'].toString());
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ShowCode()));
      }
    }
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              height: 600,
              width: 550,
              constraints: BoxConstraints(
                minWidth: 600,
                minHeight: 700,
              ),
              child: Card(
                color: Colors.white.withOpacity(0.4),
                elevation: 20,
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text("Register",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),

                      const Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Icon(
                          Icons.account_circle_rounded,
                          size: 140,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: TextField(
                          controller: username,
                          decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: TextField(
                          controller: password,
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: TextField(
                          controller: confrimpassword,
                          obscureText: true,
                          decoration: InputDecoration(
                              labelText: 'Confrim Password',
                              labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Switch(
                            activeColor: Colors.white,
                            value: GenderBool,
                            onChanged: (value){
                              setState(() {
                                setToggled(value);
                              });
                            },
                          ),
                          Text(GenderBool? 'Male':'Female',
                            style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: IconButton(
                              onPressed: () {
                                RegisterUser();
                              },
                              icon: Icon(
                                Icons.input_rounded,
                              ),
                              iconSize: 70.0,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already a User?',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ShowCode extends StatefulWidget {
  const ShowCode({super.key});

  @override
  State<ShowCode> createState() => _ShowCodeState();
}

class _ShowCodeState extends State<ShowCode> {

  String code ='';
  @override
  void initState() {
    super.initState();
    getdata();
  }

  Future <void> getdata() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
   setState(() {
     code=prefs.getString('PassResetCode') ?? '';
   });
  }
  


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
      child: Center(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        code,style:  TextStyle(fontSize: 30,decoration: TextDecoration.none,color: Colors.black),
                      ),
                      SizedBox(width: 20,),
                      IconButton(onPressed: (){
                        FlutterClipboard.copy(code).then((value) => print('copied..'));
                      }, icon: Icon(Icons.copy),color: Colors.black,)
                    ],
                  ),
                  SizedBox(height: 10,),
                  Text('This code is used to reset password,make sure you copy this somewhere safely',style: TextStyle(fontSize: 20,decoration: TextDecoration.none,color: Colors.black),),
                  SizedBox(height: 60),
                  IconButton(onPressed: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MainPage()));
                  }, icon: Icon(Icons.navigate_next),iconSize: 60,color: Colors.black,)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


