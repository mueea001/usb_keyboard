import 'package:flutter/material.dart';
import 'package:root/root.dart';
import 'hid_table.dart';

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
  //TODO: - add root check
  //      - check /dev/hidg0 is available
  //      - design system to support different layouts

  /// Test function that presses A key on QWERTY UK Layout
  Future<void> presskey() async {
    String akey =
        "echo -ne \\\\x2\\\\x0\\\\x4\\\\x0\\\\x0\\\\x0\\\\x0\\\\x0 > /dev/hidg0";
    String keyup =
        "echo -ne \\\\x0\\\\x0\\\\x0\\\\x0\\\\x0\\\\x0\\\\x0\\\\x0 > /dev/hidg0";
    print(akey);
    print(keyup);
    var cmd = akey;
    await Root.exec(cmd: cmd);
    await Root.exec(cmd: keyup);
  }

  String createHIDPacket(int modCode, int code1, int code2, int code3,
      int code4, int code5, int code6, int code7) {
    return "\\\\x" +
        modCode.toRadixString(16) +
        "\\\\x" +
        code1.toRadixString(16) +
        "\\\\x" +
        code2.toRadixString(16) +
        "\\\\x" +
        code3.toRadixString(16) +
        "\\\\x" +
        code4.toRadixString(16) +
        "\\\\x" +
        code5.toRadixString(16) +
        "\\\\x" +
        code6.toRadixString(16) +
        "\\\\x" +
        code7.toRadixString(16);
  }

  /// This function will write to /dev/hidg0
  void sendEvent(String packet) {
    String cmd = "echo -ne " + packet + " > /dev/hidg0";
    print(cmd);
    Root.exec(cmd: cmd);
  }

  void sendKey(hidKeyCode, hidModCode) {
    sendEvent(createHIDPacket(hidModCode, 0, hidKeyCode, 0, 0, 0, 0, 0));
    keyUp();
  }

  void keyUp() {
    sendEvent(createHIDPacket(0, 0, 0, 0, 0, 0, 0, 0));
  }

  void _keyPress(String key) {
    print(key + ": " + keyToKeycode[key.toLowerCase()].toString());
    if (key.length == 1) {
      // int hidKeyCode = key.toLowerCase().codeUnitAt(0) - 93;
      // print(key.toLowerCase().codeUnitAt(0));
      // if (hidKeyCode <= 29 && hidKeyCode >= 4) {
      //   // print(createHIDPacket(0, 0, hidKeyCode, 0, 0, 0, 0, 0));
      //   sendKey(hidKeyCode, 0);
      // }
      sendKey(keyToKeycode[key.toLowerCase()], 0);
    }
    switch (key) {
      case "[Backspace]":
        sendKey(42, 0);
        break;
      case "Space":
        sendKey(44, 0);
        break;
      default:
        break;
    }
    // print(hidKeyCode);
  }

  void _parseText(String text) {
    print(text);
  }

  @override
  Widget build(BuildContext context) {
    var icons = {
      "[Backspace]": Icons.backspace,
      "[Shift]": Icons.arrow_upward,
    };
    var textCont = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
                  Row(children: [
                    Flexible(
                      flex: 6,
                      child: TextField(
                        controller: textCont,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () => _parseText(textCont.text),
                        child: const Icon(Icons.send),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                        ),
                      ),
                    )
                  ])
                ] +
                "1234567890 QWERTYUIOP ASDFGHJKL [Shift]ZXCVBNM[Backspace]"
                    .split(" ")
                    .map((rows) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: RegExp(r'\[\w+\]|[\w]')
                            .allMatches(rows)
                            .map((key) => Flexible(
                                child: ElevatedButton(
                                    onPressed: () => _keyPress(key.input
                                        .substring(key.start, key.end)),
                                    child:
                                        // Text(
                                        //   key.input.substring(key.start, key.end),
                                        // ),
                                        (() {
                                      var k = key.input
                                          .substring(key.start, key.end);
                                      if (k.length > 1) {
                                        if (k[0] == "[" &&
                                            k[k.length - 1] == "]") {
                                          return Icon(icons[k]);
                                        }
                                        return Icon(Icons.cancel);
                                      } else {
                                        return Text(
                                          key.input
                                              .substring(key.start, key.end),
                                        );
                                      }
                                    }()))))
                            .toList()))
                    .toList() +
                [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 6,
                          child: ElevatedButton(
                            child: const Text("Space"),
                            onPressed: () => _keyPress("Space"),
                          )),
                      Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () => _keyPress("Enter"),
                            child: const Icon(Icons.keyboard_return),
                          ))
                    ],
                  )
                ]),
      ),
    );
  }
}
