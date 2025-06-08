import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SpeechCounter(),
    );
  }
}

class SpeechCounter extends StatefulWidget {
  @override
  _SpeechCounterState createState() => _SpeechCounterState();
}

class _SpeechCounterState extends State<SpeechCounter> {
  SpeechToText _speechToText = SpeechToText();
  String userInput = "";
  String _text = '';
  int wordCount = 0;

  @override
  void initState() {
    super.initState();
    //_speechToText = stt.SpeechToText();
    _initSpeech();
  }

  void _initSpeech() async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.denied) {
      dialogBox("Please enable mic permission");
    }
    await _speechToText.initialize();
    setState(() {
    });
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.microphone.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
      await [Permission.microphone].request();
      return permissionStatus[Permission.microphone] ??
          PermissionStatus.permanentlyDenied;
    } else {
      return permission;
    }
  }

  void _startListening() async {
    await _speechToText.listen(
        onResult: _onSpeechResult
    );
    setState(() {
      wordCount = 0;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _text = result.recognizedWords;
      //print(_text);
      List<String> words = _text.split(" "); // Split the string into words
      wordCount = words.where((word) => word == userInput).length;
    });
  }


  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
    });
  }

  dialogBox(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
          content: const Column(
              mainAxisSize: MainAxisSize.min
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Speech Word Counter"), centerTitle: true, backgroundColor: Colors.lightBlueAccent,),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
          Center(
            child:
            Column(
              children: [
                SizedBox(height: 20),
                Text("$userInput count: $wordCount", style:  TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 150),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(40),
                  ),
                  onPressed: _speechToText.isListening ? _stopListening : _startListening,
                  child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic, size: 60,),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar:
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Give a word to count',
            ),
            onSubmitted: (String value) async {
              setState(() {
                List<String> list = value.split(" ");
                if(list.length > 1 && list.last != ''){
                  dialogBox("Please give only one word");
                }
                userInput = list.first;
              });
            },
          ),
    );
  }
}
