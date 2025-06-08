import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  late stt.SpeechToText _speech;
  String userInput = "Give a word to";
  bool _isListening = false;
  String _text = '';
  int wordCount = 0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  void _initSpeech() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      bool available = await _speech.initialize();
      if (!available) {
        dialogBox("No speech available");
      }
    }
    else{
      dialogBox("No microphone permission enabled. Please restart the app and allow permission");
    }
  }


  void _startListening() async {
    if (!_isListening) {
      await _speech.listen(
       localeId: "el_GR",
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords.toLowerCase();
            wordCount = _text.split(RegExp(r'\b'+userInput+'\b')).length - 1;
          });
        },
       // listenMode: stt.ListenMode.dictation,
       // SpeechListenOptions.listenMode,
      );
      setState(() => _isListening = true);
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
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
                  onPressed: _isListening ? _stopListening : _startListening,
                  child: const Icon(Icons.record_voice_over, size: 60,),
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
                userInput = value;
              });
            },
          ),
    );
  }
}
