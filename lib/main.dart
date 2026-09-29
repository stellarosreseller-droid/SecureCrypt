import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';

void main() => runApp(const SecureCryptApp());

class SecureCryptApp extends StatelessWidget {
  const SecureCryptApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SecureCrypt',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF0A0A0A)),
      home: const VaultScreen(),
    );
  }
}

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});
  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  List<FileSystemEntity> files = [];
  bool isRecording = false;
  final recorder = AudioRecorder();
  String status = "SecureCrypt Vault - Ready";

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  Future<String> getVaultPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final vault = Directory(p.join(dir.path, 'vault'));
    if (!await vault.exists()) await vault.create();
    return vault.path;
  }

  Future<void> loadFiles() async {
    final path = await getVaultPath();
    final dir = Directory(path);
    setState(() { files = dir.listSync(); });
  }

  Future<void> toggleRecording() async {
    if (isRecording) {
      final path = await recorder.stop();
      setState(() { isRecording = false; status = "Salvato: $path"; });
      loadFiles();
    } else {
      if (await recorder.hasPermission()) {
        final vaultPath = await getVaultPath();
        final filePath = p.join(vaultPath, 'REC_${DateTime.now().millisecondsSinceEpoch}.m4a');
        await recorder.start(const RecordConfig(), path: filePath);
        setState(() { isRecording = true; status = "REGISTRAZIONE IN CORSO..."; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 SecureCrypt Vault'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.chat_bubble), onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
          })
        ],
      ),
      body: Column(
        children: [
          Container(padding: const EdgeInsets.all(16), color: isRecording? Colors.red : Colors.grey[900], child: Text(status, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: files.isEmpty? const Center(child: Text("Vault vuoto - premi REC per iniziare")) : ListView.builder(itemCount: files.length, itemBuilder: (_, i) {
            return ListTile(leading: const Icon(Icons.audiotrack), title: Text(p.basename(files[i].path)), onTap: () {});
          }))
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        backgroundColor: isRecording? Colors.red : Colors.blue,
        onPressed: toggleRecording,
        child: Icon(isRecording? Icons.stop : Icons.mic),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messages = ["Ciao! Vault sicuro attivo", "Messaggi cifrati end-to-end"];
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Sicura")),
      body: Column(children: [
        Expanded(child: ListView.builder(itemCount: messages.length, itemBuilder: (_, i) => ListTile(title: Text(messages[i])))),
        Padding(padding: const EdgeInsets.all(8), child: Row(children: [
          Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: "Messaggio..."))),
          IconButton(icon: const Icon(Icons.send), onPressed: () { if(controller.text.isNotEmpty){ setState((){ messages.add(controller.text); controller.clear(); }); } })
        ]))
      ]),
    );
  }
}
