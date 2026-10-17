import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algo Monitor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String statusMessage = "Tap button to connect to trading server";
  bool isLoading = false;
  Map<String, dynamic>? serverData;

  // Change this to your actual server IP and port (e.g., http://YOUR_SERVER_IP:8000)
  // Note: For Android emulators use 'http://10.0.2.2:8000', for real devices use your cloud server public IP.
  final String serverUrl = "http://YOUR_SERVER_IP:8000/status";

  Future<void> connectToServer() async {
    setState(() {
      isLoading = true;
      statusMessage = "Connecting to $serverUrl...";
    });

    try {
      final response = await http.get(Uri.parse(serverUrl)).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          serverData = data;
          statusMessage = "Connected Successfully!";
          isLoading = false;
        });
      } else {
        setState(() {
          statusMessage = "Server error: Status code ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "Connection failed: $e\n\nMake sure your server is running and IP is correct.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Algo Monitor Dashboard'),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics, size: 70, color: Colors.greenAccent),
            const SizedBox(height: 20),
            Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 20),
            if (serverData != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  jsonEncode(serverData),
                  style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace'),
                ),
              ),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: connectToServer,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Connect to Server'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
