import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_texture/flutter_texture.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    AnimationController
    // WidgetsBinding.instance?.addPersistentFrameCallback((timeStamp) {
    //   print('addPersistentFrameCallback timeStamp=$timeStamp');
    // });
    // WidgetsBinding.instance?.addTimingsCallback((timings) {
    //   print('addTimingsCallback');
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: const [
              Text('外接纹理Demo'),
              SizedBox(height: 20,),
              SizedBox(
                width: 200,
                height: 200,
                child: TextureDemo(),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
    );
  }
}
