import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;

void main() => runApp(const MaterialApp(home: VaultPage()));

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});
  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  final recorder = AudioRecorder();
  String vaultPath = "";
  bool isRec = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final d = await getApplicationDocumentsDirectory();
    vaultPath = p.join(d.path, "vault");
    await Directory(vaultPath).create(recursive: true);
    setState(() {});
  }

  Future<void> toggle() async {
    if (isRec) {
      await recorder.stop();
      setState(() => isRec = false);
    } else {
      if (await recorder.hasPermission()) {
        final filePath = p.join(vaultPath, "${DateTime.now().millisecondsSinceEpoch}.m4a");
        await recorder.start(const RecordConfig(), path: filePath);
        setState(() => isRec = true);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (vaultPath.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final files = Directory(vaultPath).listSync().whereType<File>().toList();
    return Scaffold(
      appBar: AppBar(title: const Text("SecureCrypt")),
      body: files.isEmpty
         ? const Center(child: Text("Nessun file"))
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (_, i) {
                final f = files[i];
                return ListTile(
                  title: Text(p.basename(f.path)),
                  subtitle: Text("${f.lengthSync()} bytes"),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isRec? Colors.red : Colors.blue,
        onPressed: toggle,
        child: Icon(isRec? Icons.stop : Icons.mic),
      ),
    );
  }
}
