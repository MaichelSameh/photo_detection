import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:image_compare/image_compare.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? imagePath1;
  String? imagePath2;

  Future<String?> pickImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    return image?.path;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).primaryColor,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      imagePath1 = await pickImage();
                      setState(() {});
                    },
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border:
                            Border.all(color: Theme.of(context).primaryColor),
                      ),
                      child: imagePath1 != null
                          ? Image.file(
                              File(imagePath1!),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.contain,
                            )
                          : Center(
                              child: Icon(
                                Icons.add_circle,
                                size: 25,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      imagePath2 = await pickImage();
                      setState(() {});
                    },
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border:
                            Border.all(color: Theme.of(context).primaryColor),
                      ),
                      child: imagePath2 != null
                          ? Image.file(
                              File(imagePath2!),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.contain,
                            )
                          : Center(
                              child: Icon(
                                Icons.add_circle,
                                size: 25,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (imagePath1 != null && imagePath2 != null) ...<Widget>[
            const SizedBox(height: 60),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ElevatedButton(
                onPressed: () async {
                  var image1 = File(imagePath1!).readAsBytesSync().toList();
                  var image2 = File(imagePath2!).readAsBytesSync().toList();
                  await Isolate.spawn<List<List<int>>>(
                    (port) async {
                      double result = await compareImages(
                        src1: port[0],
                        src2: port[1],
                        algorithm: ChiSquareDistanceHistogram(),
                      );
                      print(result);
                      Isolate.current.kill();
                    },
                    [image1, image2],
                  );
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).primaryColor),
                ),
                child: const SizedBox(
                  width: 300,
                  height: 50,
                  child: Center(
                    child: Text(
                      "Compare",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
