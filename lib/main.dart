import 'package:flutter/material.dart';

void main() {
  // Catch any unexpected errors during startup
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  
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
      home: const ErrorCatcherHome(),
    );
  }
}

class ErrorCatcherHome extends StatefulWidget {
  const ErrorCatcherHome({super.key});

  @override
  State<ErrorCatcherHome> createState() => _ErrorCatcherHomeState();
}

class _ErrorCatcherHomeState extends State<ErrorCatcherHome> {
  String status = "Initializing Algo Monitor...";

  @override
  void initState() {
    super.initState();
    // Test connection or async initialization here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Algo Monitor Dashboard'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.analytics, size: 80, color: Colors.greenAccent),
              const SizedBox(height: 20),
              Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    status = "Connecting to trading server...";
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
