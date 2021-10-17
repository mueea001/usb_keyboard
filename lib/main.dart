import 'package:flutter/material.dart';
import 'package:root/root.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USB Keyboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'USB Keyboard'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  //TODO: - add root check
  //      - check /dev/hidg0 is available
  //      - design system to support different layouts

  /// Test function that presses A key on QWERTY UK Layout
  Future<void> presskey() async {
    String akey =
        "echo -ne \\\\x2\\\\x0\\\\x4\\\\x0\\\\x0\\\\x0\\\\x0\\\\x0 > /dev/hidg0";
    String keyup =
        "echo -ne \\\\x0\\\\x0\\\\x0\\\\x0\\\\x0\\\\x0\\\\x0\\\\x0 > /dev/hidg0";
    var cmd = akey;
    var res = await Root.exec(cmd: cmd);
    await Root.exec(cmd: keyup);
  }

  void _keyPress(String key) {
    print(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
            children: "QWERTYUIOP ASDFGHJKL ZXCVBNM"
                .split(" ")
                .map((rows) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: rows
                        .split("")
                        .map((key) => ElevatedButton(
                              onPressed: () => _keyPress(key),
                              child: Text(key),
                            ))
                        .toList()))
                .toList()
            ),
      ),
    );
  }
}
