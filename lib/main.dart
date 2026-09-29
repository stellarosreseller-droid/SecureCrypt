import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as p;

void main() => runApp(const SecureCryptApp());

class SecureCryptApp extends StatelessWidget {
  const SecureCryptApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'SecureCrypt', theme: ThemeData.dark(), home: const VaultPage());
  }
}

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});
  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  String vaultPath = "";
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    initVault();
  }

  Future<void> initVault() async {
    final dir = await getApplicationDocumentsDirectory();
    vaultPath = p.join(dir.path, "vault");
    await Directory(vaultPath).create(recursive: true);
    setState(() {});
  }

  Future<void> toggleRecord() async {
    if (isRecording) {
      await _recorder.stopRecorder();
      setState(() => isRecording = false);
      setState(() {});
    } else {
      if (await _recorder.hasPermission()) {
        final path = p.join(vaultPath, 'ghost_${DateTime.now().millisecondsSinceEpoch}.m4a');
        await _recorder.startRecorder(toFile: path, codec: Codec.aacMP4);
        setState(() => isRecording = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (vaultPath.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final files = Directory(vaultPath).listSync().whereType<File>().toList();
    return Scaffold(
      appBar: AppBar(title: const Text("SecureCrypt Vault"), backgroundColor: Colors.black),
      body: files.isEmpty
          ? const Center(child: Text("Nessun file - registra qualcosa", style: TextStyle(color: Colors.white54)))
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final f = files[index];
                final fileName = p.basename(f.path);
                final fileSize = f.lengthSync();
                return ListTile(
                  leading: const Icon(Icons.insert_drive_file, color: Colors.white70),
                  title: Text(fileName, style: const TextStyle(fontSize: 13)),
                  subtitle: Text("$fileSize bytes", style: const TextStyle(fontSize: 11, color: Colors.white54)),
                  onTap: () async {
                    await _player.play(DeviceFileSource(f.path));
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleRecord,
        backgroundColor: isRecording ? Colors.red : Colors.blue,
        child: Icon(isRecording ? Icons.stop : Icons.mic),
      ),
    );
  }
}
