import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const AlmohalelApp());
}

class AlmohalelApp extends StatelessWidget {
  const AlmohalelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final homeController = TextEditingController();
  final awayController = TextEditingController();

  String result = "";

  Future<void> analyze() async {
    try {
      final response = await http.get(Uri.parse(
          "http://192.168.0.1:8000/predict?home_id=${homeController.text}&away_id=${awayController.text}"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          result = """
Home: ${data['1X2']['home']}%
Draw: ${data['1X2']['draw']}%
Away: ${data['1X2']['away']}%

Over 2.5: ${data['over_2_5']}%
BTTS: ${data['btts_yes']}%

Confidence: ${data['confidence']}%
Risk: ${data['risk']}
""";
        });
      } else {
        setState(() {
          result = "Server Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        result = "Connection Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("المحلل"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: homeController,
              decoration: const InputDecoration(
                  hintText: "Home Team ID",
                  hintStyle: TextStyle(color: Colors.green)),
              style: const TextStyle(color: Colors.green),
            ),
            TextField(
              controller: awayController,
              decoration: const InputDecoration(
                  hintText: "Away Team ID",
                  hintStyle: TextStyle(color: Colors.green)),
              style: const TextStyle(color: Colors.green),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: analyze,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green),
              child: const Text("تحليل"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  result,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
