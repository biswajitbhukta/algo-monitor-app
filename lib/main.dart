import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const AlgoMonitorApp());
}

class AlgoMonitorApp extends StatelessWidget {
  const AlgoMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algo Monitor',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
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

  final String serverUrl = "http://34.100.147.30:8000/status";

  Future<void> connectToServer() async {
    setState(() {
      isLoading = true;
      statusMessage = "Connecting to server...";
    });

    try {
      final response = await http.get(Uri.parse(serverUrl)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        setState(() {
          serverData = jsonDecode(response.body);
          statusMessage = "Connected Successfully!";
          isLoading = false;
        });
      } else {
        setState(() {
          statusMessage = "Server error: ${response.statusCode}";
          serverData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "Connection failed: $e";
        serverData = null;
        isLoading = false;
      });
    }
  }

  Widget _buildMetricCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[850]!),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Algo Monitor Dashboard"),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics_rounded, size: 70, color: Colors.greenAccent),
            const SizedBox(height: 20),
            Text(
              serverData == null ? statusMessage : "Connected Successfully!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: serverData == null ? Colors.white70 : Colors.greenAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            if (serverData != null) ...[
              Card(
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.cloud_done, color: Colors.greenAccent),
                  title: const Text("System Online", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(serverData!["message"] ?? "", style: const TextStyle(color: Colors.white60)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetricCard("Active Strategies", "${serverData!["active_strategies"] ?? 0}"),
                  _buildMetricCard("Live PnL", "${serverData!["pnl"] ?? "₹0.00"}"),
                ],
              ),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isLoading ? null : connectToServer,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.greenAccent)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh, color: Colors.greenAccent),
                          SizedBox(width: 8),
                          Text("Connect to Server", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
