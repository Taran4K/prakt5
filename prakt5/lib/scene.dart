import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prakt5/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Screen extends StatelessWidget{
  const Screen({super.key, required this.counter});

  final String counter;

  @override
  Widget build(BuildContext context) {
    TextEditingController textController = TextEditingController();
    final Future<SharedPreferences> futurePreferences = SharedPreferences.getInstance();
    late final SharedPreferences sharedPreferences;

      late SharedPreferences shared;

      Future<void> initShared() async{
        shared=await SharedPreferences.getInstance();
        textController.text=  shared.getString('string')??"";
      }
      Future<void> PreferencLoading() async {
        sharedPreferences = await futurePreferences;
        }
      @override
      void initState(){
        initShared();
        shared.setString('string', textController.text);
      }

    PreferencLoading();
    return Scaffold(
      body: Center(child: Column(
        children: [
          Text(counter.toString()),
          ElevatedButton(
              onPressed: () {
                sharedPreferences.setString('string', counter.toString());
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyApp(),
                  ),
                );
              },
              child: Text('Перейти на первое окно'),
            ),
        ],
      )),
      
    );
  }
}