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
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
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
  bool _isOpenExpanded = false;
  bool _isClosedExpanded = false;
  Map<String, dynamic>? serverData;

  final String serverUrl = "http://34.100.147.30:8000/status";

  Future<void> connectToServer() async {
    setState(() {
      isLoading = true;
      statusMessage = "Connecting to server...";
    });

    try {
      final client = http.Client(); final response = await client.get(Uri.parse(serverUrl), headers: {"Connection": "close", "Cache-Control": "no-cache"}).timeout(const Duration(seconds: 15)); client.close();

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

  Color _getPnlColor(String valStr) {
    if (valStr.contains("-") || valStr.startsWith("-")) {
      return Colors.redAccent;
    }
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    // Mock script-wise breakdown for open positions
    final List<Map<String, dynamic>> openScripts = serverData != null ? [
      {"script": "NIFTY 24000 CE", "qty": "75", "pnl": "+₹950.00"},
      {"script": "BANKNIFTY 51000 PE", "qty": "30", "pnl": "-₹250.00"},
      {"script": "FINNIFTY 23500 CE", "qty": "50", "pnl": "+₹750.00"},
    ] : [];

    // Mock script-wise breakdown for closed positions
    final List<Map<String, dynamic>> closedScripts = serverData != null ? [
      {"script": "RELIANCE 2900 CE", "qty": "250", "pnl": "+₹1,800.00"},
      {"script": "TCS 4100 PE", "qty": "150", "pnl": "-₹400.00"},
      {"script": "INFY 1800 CE", "qty": "400", "pnl": "+₹1,800.00"},
    ] : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Algo Trading Terminal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.greenAccent),
            onPressed: isLoading ? null : connectToServer,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (serverData == null) ...[
              const SizedBox(height: 60),
              const Center(
                child: Icon(Icons.analytics_rounded, size: 80, color: Colors.greenAccent),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  statusMessage,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
            ] else ...[
              // Connected Header Banner (System Online card auto-hides once connected)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF065F46).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                    SizedBox(width: 10),
                    Text("Server Connected Live", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // TAB 1: Open Positions with tap-to-expand script-wise P&L breakdown
              Card(
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  initiallyExpanded: false,
                  onExpansionChanged: (val) => setState(() => _isOpenExpanded = val),
                  leading: const Icon(Icons.trending_up, color: Colors.blueAccent),
                  title: const Text("Open Positions", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: const Text("3 Trades | P&L: +₹1,450.00", style: TextStyle(color: Colors.greenAccent, fontSize: 13)),
                  trailing: Icon(_isOpenExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white70),
                  children: openScripts.map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey[800]!)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item["script"], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              Text("Qty: ${item["qty"]}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                          Text(
                            item["pnl"],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getPnlColor(item["pnl"]),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // TAB 2: Closed Positions with tap-to-expand script-wise P&L breakdown
              Card(
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  initiallyExpanded: false,
                  onExpansionChanged: (val) => setState(() => _isClosedExpanded = val),
                  leading: const Icon(Icons.history, color: Colors.orangeAccent),
                  title: const Text("Closed Positions", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: const Text("3 Trades | P&L: +₹3,200.00", style: TextStyle(color: Colors.greenAccent, fontSize: 13)),
                  trailing: Icon(_isClosedExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white70),
                  children: closedScripts.map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey[800]!)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item["script"], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              Text("Qty: ${item["qty"]}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                          Text(
                            item["pnl"],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getPnlColor(item["pnl"]),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // TAB 3: Profit & Loss Summary (Realised, Unrealised, Total)
              Card(
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Colors.greenAccent, size: 20),
                          SizedBox(width: 8),
                          Text("Profit & Loss Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        ],
                      ),
                      const Divider(color: Colors.grey, height: 24),
                      _pnlRow("Realised PnL", "+₹3,200.00"),
                      const SizedBox(height: 10),
                      _pnlRow("Unrealised PnL", "+₹1,450.00"),
                      const Divider(color: Colors.grey, height: 24),
                      _pnlRow("Total PnL", "+₹4,650.00", isTotal: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Connect / Refresh Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF334155),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isLoading ? null : connectToServer,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.greenAccent)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(serverData == null ? Icons.power_settings_new : Icons.refresh, color: Colors.greenAccent),
                          const SizedBox(width: 8),
                          Text(
                            serverData == null ? "Connect to Server" : "Refresh Dashboard",
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pnlRow(String label, String value, {bool isTotal = false}) {
    final isNegative = value.contains("-");
    final color = isNegative ? Colors.redAccent : Colors.greenAccent;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.white70,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 17 : 14,
          ),
        ),
      ],
    );
  }
}
