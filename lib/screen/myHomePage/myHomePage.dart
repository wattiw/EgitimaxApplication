import 'package:egitimaxapplication/screen/questionPage/questionPage.dart';
import 'package:egitimaxapplication/screen/quizPage/quizPage.dart';
import 'package:egitimaxapplication/utils/constant/appConstant/generalAppConstant.dart';
import 'package:egitimaxapplication/utils/constant/router/appRouterConstant.dart';
import 'package:egitimaxapplication/utils/constant/router/heroTagConstant.dart';
import 'package:egitimaxapplication/utils/widget/layout/mainLayout.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  TextEditingController questionIdController = TextEditingController();
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> routes = AppRouterConstant.routeConstants;
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body:Center(
        widthFactor: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              children: [
                SizedBox(
                  width: 250,
                  child: TextField(
                    maxLines: 1,
                    cursorHeight: 10,
                    controller: questionIdController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(10),
                      labelText: 'To Be Loaded Id',
                    ),
                    textInputAction: TextInputAction.done,
                    onChanged: (qId){
                      GeneralAppConstant.TempIdSilSonra=qId;
                    },
                    onSubmitted: (value) {
                      GeneralAppConstant.TempIdSilSonra=questionIdController.text;
                    },
                  ),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final routeName = routes[index];

                return InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, routeName);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center the children horizontally
                    children: [
                      Text(
                        routeName.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const IconButton(
                        icon: Icon(Icons.navigate_next),
                        onPressed: null,
                        iconSize: 40,
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
