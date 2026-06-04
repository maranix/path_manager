import 'dart:io';
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
  Directory? _temporaryDirectory;
  Directory? _applicationSupportDirectory;
  Directory? _documentsDirectory;
  Directory? _cachesDirectory;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPaths();
  }

  Future<void> _loadPaths() async {
    try {
      final temp = await PathManager.getTemporaryDirectory();
      final appSupport = await PathManager.getApplicationSupportDirectory();
      final docs = await PathManager.getApplicationDocumentsDirectory();
      final caches = await PathManager.getCachesDirectory();
      setState(() {
        _temporaryDirectory = temp;
        _applicationSupportDirectory = appSupport;
        _documentsDirectory = docs;
        _cachesDirectory = caches;
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
                    _buildPathCard('Temporary Directory', _temporaryDirectory),
                    _buildPathCard(
                      'Application Support Directory',
                      _applicationSupportDirectory,
                    ),
                    _buildPathCard('Documents Directory', _documentsDirectory),
                    _buildPathCard('Caches Directory', _cachesDirectory),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPathCard(String title, Directory? directory) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              directory?.path ?? 'Loading...',
              style: TextStyle(
                fontFamily: 'monospace',
                color: directory != null ? Colors.greenAccent : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
