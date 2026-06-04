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
  Directory? _noBackupDirectory;
  String _exclusionTestResult = 'Not tested';
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
      Directory? noBackup;
      try {
        noBackup = await PathManager.getApplicationNoBackupDirectory();
      } catch (e) {
        // We can't easily display a Directory-with-error, so we might just log it
        debugPrint('Error loading no-backup dir: $e');
      }
      setState(() {
        _temporaryDirectory = temp;
        _applicationSupportDirectory = appSupport;
        _documentsDirectory = docs;
        _cachesDirectory = caches;
        _noBackupDirectory = noBackup;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _testBackupExclusion() async {
    setState(() {
      _exclusionTestResult = 'Testing...';
    });
    try {
      final tempDir = await PathManager.getTemporaryDirectory();
      final testFile = File('${tempDir.path}/example_test_file.txt');
      await testFile.writeAsString('Hello World');

      await PathManager.setApplicationPathIsExcludedFromBackup(
        testFile.path,
        true,
      );

      setState(() {
        _exclusionTestResult = 'Success: Excluded file from backup.';
      });
    } catch (e) {
      setState(() {
        _exclusionTestResult = 'Failed: $e';
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
                    _buildPathCard(
                      'Temporary Directory',
                      _temporaryDirectory?.path,
                    ),
                    _buildPathCard(
                      'Application Support Directory',
                      _applicationSupportDirectory?.path,
                    ),
                    _buildPathCard(
                      'Documents Directory',
                      _documentsDirectory?.path,
                    ),
                    _buildPathCard('Caches Directory', _cachesDirectory?.path),
                    _buildPathCard('No Backup Directory', _noBackupDirectory?.path),

                    const SizedBox(height: 16),
                    Card(
                      color: Colors.blueGrey.shade900,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Test Backup Exclusion API',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Status: $_exclusionTestResult',
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _testBackupExclusion,
                              child: const Text('Run Exclusion Test'),
                            ),
                          ],
                        ),
                      ),
                    ),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
