import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(AlgoMonitorApp());
}

class AlgoMonitorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algo Monitor Desk',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF121212),
        primarySwatch: Colors.amber,
      ),
      home: DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> dashboardData = {};
  bool isLoading = true;
  Timer? _timer;

  // TODO: Replace with your actual Cloud VM Public IP or tunnel URL
  final String apiUrl = "http://YOUR_CLOUD_SERVER_IP:8000/api/dashboard";

  @override
  void initState() {
    super.initState();
    fetchData();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) => fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          dashboardData = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      // Keep running even if network drops temporarily
    }
  }

  @override
  Widget build(BuildContext context) {
    var summary = dashboardData['summary'] ?? {'realized_pnl': 0.0, 'unrealized_pnl': 0.0, 'total_pnl': 0.0};
    double totalPnl = summary['total_pnl'] ?? 0.0;
    List openPositions = dashboardData['open_positions'] ?? [];
    List closedPositions = dashboardData['closed_positions'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("SMC Algo Desk Monitor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF1F1F1F),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchData,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.amber))
          : RefreshIndicator(
              onRefresh: fetchData,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: totalPnl >= 0 ? Colors.greenAccent : Colors.redAccent, 
                        width: 1.5
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("TOTAL P&L (Realized + Unrealized)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        SizedBox(height: 8),
                        Text(
                          "₹ ${totalPnl.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: totalPnl >= 0 ? Colors.greenAccent : Colors.redAccent,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Realized: ₹ ${summary['realized_pnl']}", style: TextStyle(color: Colors.white70, fontSize: 13)),
                            Text("Unrealized: ₹ ${summary['unrealized_pnl']}", style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text("Open Positions (${openPositions.length})", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
                  SizedBox(height: 10),
                  openPositions.isEmpty
                      ? Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
                          child: Text("No active open positions.", style: TextStyle(color: Colors.grey)),
                        )
                      : Column(
                          children: openPositions.map((pos) => Card(
                            color: Color(0xFF1E1E1E),
                            child: ListTile(
                              title: Text(pos['symbol'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("Qty: ${pos['qty']} | Buy: ₹ ${pos['buy_price']} | LTP: ₹ ${pos['ltp']}"),
                              trailing: Text(
                                "₹ ${pos['unrealized_pnl']}",
                                style: TextStyle(
                                  color: (pos['unrealized_pnl'] ?? 0) >= 0 ? Colors.greenAccent : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )).toList(),
                        ),
                  SizedBox(height: 24),
                  Text("Closed Trades History", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
                  SizedBox(height: 10),
                  closedPositions.isEmpty
                      ? Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(8)),
                          child: Text("No closed trades in current session.", style: TextStyle(color: Colors.grey)),
                        )
                      : Column(
                          children: closedPositions.map((pos) => Card(
                            color: Color(0xFF1E1E1E),
                            child: ListTile(
                              title: Text(pos['symbol'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("Exit Time: ${pos['exit_time']} | PnL: ₹ ${pos['realized_pnl']}"),
                              trailing: Icon(Icons.check_circle, color: Colors.green),
                            ),
                          )).toList(),
                        ),
                ],
              ),
            ),
    );
  }
}
