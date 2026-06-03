import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_native_backup_guard/flutter_native_backup_guard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Native Backup Guard',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Sleek indigo
          brightness: Brightness.dark,
          surface: const Color(0xFF0F172A), // Slate 900
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E293B), // Slate 800
          elevation: 4,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _documentsPath;
  String? _tempPath;
  String? _noBackupPath;

  File? _documentsFile;
  File? _tempFile;
  File? _noBackupFile;

  String _documentsStatus = 'No file created';
  String _tempStatus = 'No file created';
  String _noBackupStatus = 'No file created';

  bool _documentsExcluded = false;
  bool _tempExcluded = false;
  bool _noBackupExcluded = false;

  @override
  void initState() {
    super.initState();
    _initPaths();
  }

  Future<void> _initPaths() async {
    final docs = await getApplicationDocumentsDirectory();
    final temp = await getTemporaryDirectory();
    final noBackup = await FlutterNativeBackupGuard.getNoBackupFilesDir();
    setState(() {
      _documentsPath = docs.path;
      _tempPath = temp.path;
      _noBackupPath = noBackup;
    });
  }

  Future<void> _createDocumentsFile() async {
    if (_documentsPath == null) return;
    final file = File('$_documentsPath/backup_guard_test_doc.txt');
    await file.writeAsString('Test file content for documents');
    setState(() {
      _documentsFile = file;
      _documentsStatus = 'File created at: ${file.path.split('/').last}';
      _documentsExcluded = false;
    });
  }

  Future<void> _createTempFile() async {
    if (_tempPath == null) return;
    final file = File('$_tempPath/backup_guard_test_temp.txt');
    await file.writeAsString('Test file content for cache/temp');
    setState(() {
      _tempFile = file;
      _tempStatus = 'File created at: ${file.path.split('/').last}';
      _tempExcluded = false;
    });
  }

  Future<void> _createNoBackupFile() async {
    if (_noBackupPath == null) return;
    final file = File('$_noBackupPath/backup_guard_test_nobackup.txt');
    await file.writeAsString('Test file content for no_backup directory');
    setState(() {
      _noBackupFile = file;
      _noBackupStatus = 'File created at: ${file.path.split('/').last}';
      _noBackupExcluded = false;
    });
  }

  Future<void> _excludeDocumentsFile() async {
    if (_documentsFile == null) return;
    try {
      final success = await FlutterNativeBackupGuard.excludeFromBackup(
        _documentsFile!.path,
      );
      setState(() {
        _documentsExcluded = success;
        _documentsStatus = success
            ? 'Successfully excluded from backups'
            : 'Excluded returned false (Requires XML configuration on Android)';
      });
    } catch (e) {
      setState(() {
        _documentsStatus = 'Error: $e';
      });
    }
  }

  Future<void> _excludeTempFile() async {
    if (_tempFile == null) return;
    try {
      final success = await FlutterNativeBackupGuard.excludeFromBackup(
        _tempFile!.path,
      );
      setState(() {
        _tempExcluded = success;
        _tempStatus = success
            ? 'Successfully excluded (Inherent exception/Automatic on Android)'
            : 'Exclusion returned false';
      });
    } catch (e) {
      setState(() {
        _tempStatus = 'Error: $e';
      });
    }
  }

  Future<void> _excludeNoBackupFile() async {
    if (_noBackupFile == null) return;
    try {
      final success = await FlutterNativeBackupGuard.excludeFromBackup(
        _noBackupFile!.path,
      );
      setState(() {
        _noBackupExcluded = success;
        _noBackupStatus = success
            ? 'Successfully excluded (Inherently excluded on Android/iOS)'
            : 'Exclusion returned false';
      });
    } catch (e) {
      setState(() {
        _noBackupStatus = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Slate 900
              Color(0xFF1E1B4B), // Indigo 950
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: Color(0xFF818CF8), // Indigo 400
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Backup Guard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Exclude your files and directories programmatically from iCloud (iOS) and verify Auto Backup status (Android).',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF94A3B8), // Slate 400
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView(
                    children: [
                      _buildDirectoryCard(
                        title: 'Documents Directory',
                        subtitle: 'Backed up by default on both platforms.',
                        path: _documentsPath,
                        fileCreated: _documentsFile != null,
                        statusText: _documentsStatus,
                        isExcluded: _documentsExcluded,
                        onCreate: _createDocumentsFile,
                        onExclude: _documentsFile == null
                            ? null
                            : _excludeDocumentsFile,
                        isAndroidWarning: Platform.isAndroid,
                      ),
                      const SizedBox(height: 20),
                      _buildDirectoryCard(
                        title: 'Temporary/Cache Directory',
                        subtitle: 'Inherently excluded on Android by default.',
                        path: _tempPath,
                        fileCreated: _tempFile != null,
                        statusText: _tempStatus,
                        isExcluded: _tempExcluded,
                        onCreate: _createTempFile,
                        onExclude: _tempFile == null ? null : _excludeTempFile,
                        isAndroidWarning: false,
                      ),
                      const SizedBox(height: 20),
                      _buildDirectoryCard(
                        title: 'No-Backup Directory',
                        subtitle:
                            'Automatic backup exclusion directory returned by this plugin.',
                        path: _noBackupPath,
                        fileCreated: _noBackupFile != null,
                        statusText: _noBackupStatus,
                        isExcluded: _noBackupExcluded,
                        onCreate: _createNoBackupFile,
                        onExclude: _noBackupFile == null
                            ? null
                            : _excludeNoBackupFile,
                        isAndroidWarning: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectoryCard({
    required String title,
    required String subtitle,
    required String? path,
    required bool fileCreated,
    required String statusText,
    required bool isExcluded,
    required VoidCallback onCreate,
    required VoidCallback? onExclude,
    required bool isAndroidWarning,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0x7F334155), // Slate 700 with 50% opacity
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x7F0F172A), // 50% opacity
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DIRECTORY PATH:',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    path ?? 'Loading path...',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCreate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF334155),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Create File'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onExclude,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isExcluded
                          ? const Color(0xFF10B981) // Green 500
                          : const Color(0xFF6366F1), // Indigo 500
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(isExcluded ? 'Excluded' : 'Exclude Backup'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  isExcluded
                      ? Icons.check_circle_outline
                      : (fileCreated ? Icons.info_outline : Icons.help_outline),
                  size: 16,
                  color: isExcluded
                      ? const Color(0xFF10B981)
                      : (fileCreated
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF94A3B8)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 13,
                      color: isExcluded
                          ? const Color(0xFF34D399)
                          : (fileCreated
                                ? const Color(0xFFFBBF24)
                                : const Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
              ],
            ),
            if (isAndroidWarning && fileCreated && !isExcluded) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0x4C7F1D1D), // Red 900 with 30% opacity
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0x4CEF4444), // Red 500 with 30% opacity
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFFCA5A5),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'On Android, you must configure backup_rules.xml to exclude files in Documents directory. Programmatic exclusion is iOS-only.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFFEE2E2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
