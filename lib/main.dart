import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(TranslatorApp());
}

class TranslatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translator App',
      home: TranslatorScreen(),
    );
  }
}

class TranslatorScreen extends StatefulWidget {
  @override
  _TranslatorScreenState createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  TextEditingController _inputController = TextEditingController();
  String _translatedText = '';

 Future<void> _translate() async {
  String inputText = _inputController.text;
  if (inputText.isEmpty) return;

  final Map<String, String> headers = {
    "Authorization": "Bearer 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",
    "Content-Type": "application/json",
  };

  final Map<String, dynamic> requestBody = {
    'inputs': inputText,
  };

  final String apiURL =
      "https://api-inference.huggingface.co/models/Helsinki-NLP/opus-mt-en-bem";

  try {
    final response = await http.post(
      Uri.parse(apiURL),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final List<dynamic> translations = jsonDecode(response.body);
      final String translationText = translations[0]['translation_text'];
      setState(() {
        _translatedText = translationText;
      });
    } else {
      // Handle error response here
      print('Error: ${response.statusCode}');
      print('Response: ${response.body}');
      showErrorDialog('Error: ${response.statusCode}');
    }
  } catch (e) {
    // Handle network or other exceptions here
    print('Exception: $e');
    showErrorDialog('Exception: $e');
  }
}

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Translator App'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                hintText: 'Enter text to translate',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _translate,
              child: Text('Translate'),
            ),
            SizedBox(height: 16.0),
            Text(
              'Translation: $_translatedText',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}
