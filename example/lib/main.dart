import 'package:flutter/material.dart';
import 'package:path_manager/path_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _temporaryPath;
  String? _applicationSupportPath;
  String? _documentsPath;
  String? _cachesPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPaths();
  }

  Future<void> _loadPaths() async {
    try {
      final temp = await PathManager.getTemporaryPath();
      final appSupport = await PathManager.getApplicationSupportPath();
      final docs = await PathManager.getDocumentsPath();
      final caches = await PathManager.getCachesPath();
      setState(() {
        _temporaryPath = temp;
        _applicationSupportPath = appSupport;
        _documentsPath = docs;
        _cachesPath = caches;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PathManager Example'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _error != null
              ? Center(
                  child: Text(
                    'Error: $_error',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : ListView(
                  children: [
                    _buildPathCard('Temporary Path', _temporaryPath),
                    _buildPathCard('Application Support Path', _applicationSupportPath),
                    _buildPathCard('Documents Path', _documentsPath),
                    _buildPathCard('Caches Path', _cachesPath),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPathCard(String title, String? path) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              path ?? 'Loading...',
              style: TextStyle(
                fontFamily: 'monospace',
                color: path != null ? Colors.greenAccent : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
