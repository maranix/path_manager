import 'package:material_ui/material_ui.dart';
import 'package:path_manager_foundation/path_manager_foundation.dart';
import 'package:path_manager_platform_interface/path_manager_platform_interface.dart';

void main() {
  FoundationPathManager.registerWith();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _tempPath;
  String? _docsPath;
  String? _cachePath;
  String? _noBackupPath;
  String? _downloadsPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPaths();
  }

  Future<void> _loadPaths() async {
    try {
      final manager = PlatformPathManager.instance;
      final temp = await manager.getTemporaryPath();
      final docs = await manager.getDocumentsPath();
      final cache = await manager.getApplicationCachePath();
      final noBackup = await manager.getApplicationNoBackupDirectory();
      String? downloads;
      try {
        downloads = await manager.getDownloadsPath();
      } catch (_) {}

      setState(() {
        _tempPath = temp;
        _docsPath = docs;
        _cachePath = cache;
        _noBackupPath = noBackup;
        _downloadsPath = downloads;
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
      home: Scaffold(
        appBar: AppBar(
          title: const Text('path_manager_foundation example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _error != null
              ? Text('Error: $_error', style: const TextStyle(color: Colors.red))
              : ListView(
                  children: [
                    Text('Temp: ${_tempPath ?? "Loading..."}'),
                    const SizedBox(height: 8),
                    Text('Docs: ${_docsPath ?? "Loading..."}'),
                    const SizedBox(height: 8),
                    Text('Cache: ${_cachePath ?? "Loading..."}'),
                    const SizedBox(height: 8),
                    Text('No Backup: ${_noBackupPath ?? "Loading..."}'),
                    const SizedBox(height: 8),
                    Text('Downloads: ${_downloadsPath ?? "Loading..."}'),
                  ],
                ),
        ),
      ),
    );
  }
}
