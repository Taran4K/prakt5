import 'package:flutter/material.dart';
import 'package:prakt5/scene.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(message: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.message});

  final String message;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController textController = TextEditingController();


  late SharedPreferences shared;

  Future<void> initShared() async{
    shared=await SharedPreferences.getInstance();
    textController.text=  shared.getString('string')??"";
  }

  @override
  void initState(){
    initShared();
    super.initState();
  }

  void _incrementCounter() async{
    setState(() {
    });


    await shared.setString('string', textController.text);
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.message),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
                  controller: textController,
                  decoration: InputDecoration( border: UnderlineInputBorder()),
                ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Screen(counter: textController.text),
                  ),
                );
              },
              child: Text('Перейти на второе окно'),
            ),
          ],
        ),
      ),
    );
  }
}
