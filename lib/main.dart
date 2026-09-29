import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const SecureCryptApp());

class SecureCryptApp extends StatelessWidget {
  const SecureCryptApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SecureCrypt',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
      ),
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
  List<File> files = [];
  bool isRecording = false;
  final recorder = AudioRecorder();
  final player = AudioPlayer();
  String status = "🔐 SecureCrypt - Vault Sicuro";

  @override
  void initState() { super.initState(); loadFiles(); }

  Future<String> getVaultPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final vault = Directory(p.join(dir.path, 'vault'));
    if (!await vault.exists()) await vault.create(recursive: true);
    return vault.path;
  }

  Future<void> loadFiles() async {
    final path = await getVaultPath();
    final dir = Directory(path);
    final all = dir.listSync().whereType<File>().toList();
    all.sort((a,b)=> b.statSync().modified.compareTo(a.statSync().modified));
    setState(() { files = all; });
  }

  Future<void> toggleRecording() async {
    if (isRecording) {
      final path = await recorder.stop();
      setState(() { isRecording = false; status = "✅ Salvato"; });
      loadFiles();
    } else {
      if (await recorder.hasPermission()) {
        final vaultPath = await getVaultPath();
        final filePath = p.join(vaultPath, 'VOC_${DateTime.now().millisecondsSinceEpoch}.m4a');
        await recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: filePath);
        setState(() { isRecording = true; status = "🔴 REGISTRAZIONE..."; });
      }
    }
  }

  Future<void> playFile(File f) async {
    await player.stop();
    await player.play(DeviceFileSource(f.path));
    setState(()=> status = "▶️ Riproduzione: ${p.basename(f.path)}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SecureCrypt Vault'),
        actions: [
          IconButton(icon: const Icon(Icons.chat_bubble_outline, color: Colors.cyan), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_)=> const ChatScreen()))),
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadFiles),
        ],
      ),
      body: Column(
        children: [
          Container(width: double.infinity, padding: const EdgeInsets.all(14), color: isRecording? Colors.red[900] : const Color(0xFF1A1A1A), child: Text(status, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: files.isEmpty
           ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lock_outline, size: 60, color: Colors.grey), SizedBox(height:10), Text("Vault vuoto\nPremi il microfono per registrare", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))]))
            : ListView.separated(
                itemCount: files.length,
                separatorBuilder: (_,__)=> const Divider(height:1, color: Colors.white10),
                itemBuilder: (_, i) {
                  final f = files[i];
                  return ListTile(
                    leading: const Icon(Icons.audiotrack, color: Colors.cyan),
                    title: Text(p.basename(f.path), style: const TextStyle(fontSize: 13)),
                    subtitle: Text("${(f.lengthSync()/1024).toStringAsFixed(1)} KB - ${f.statSync().modified.toString().substring(0,16)}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.play_arrow), onPressed: ()=> playFile(f)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size:20), onPressed: () async { await f.delete(); loadFiles(); }),
                    ]),
                  );
                },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isRecording? Colors.red : Colors.cyan[700],
        onPressed: toggleRecording,
        icon: Icon(isRecording? Icons.stop : Icons.mic),
        label: Text(isRecording? "STOP" : "REC"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String,dynamic>> messages = [];
  final ctrl = TextEditingController();
  final recorder = AudioRecorder();
  final player = AudioPlayer();
  bool isRec = false;

  Future<void> toggleVoice() async {
    if(isRec){
      final path = await recorder.stop();
      setState((){ isRec=false; messages.add({"type":"voice","path":path,"text":"Vocale"}); });
    } else {
      if(await recorder.hasPermission()){
        final dir = await getTemporaryDirectory();
        final path = p.join(dir.path, 'chat_${DateTime.now().millisecondsSinceEpoch}.m4a');
        await recorder.start(const RecordConfig(), path: path);
        setState(()=> isRec=true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Segreta")),
      body: Column(children: [
        Expanded(child: ListView.builder(itemCount: messages.length, itemBuilder: (_,i){
          final m = messages[i];
          if(m["type"]=="voice"){
            return ListTile(leading: const Icon(Icons.mic, color: Colors.cyan), title: Text(m["text"]), trailing: IconButton(icon: const Icon(Icons.play_arrow), onPressed: () async { await player.play(DeviceFileSource(m["path"])); }));
          }
          return Align(alignment: Alignment.centerRight, child: Container(margin: const EdgeInsets.all(6), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.cyan[800], borderRadius: BorderRadius.circular(12)), child: Text(m["text"])));
        })),
        if(isRec) Container(color: Colors.red, padding: const EdgeInsets.all(8), child: const Text("🔴 Registrazione vocale...", textAlign: TextAlign.center)),
        Padding(padding: const EdgeInsets.all(8), child: Row(children: [
          IconButton(icon: Icon(isRec? Icons.stop: Icons.mic, color: Colors.red), onPressed: toggleVoice),
          Expanded(child: TextField(controller: ctrl, decoration: const InputDecoration(hintText: "Messaggio cifrato...", border: OutlineInputBorder()))),
          const SizedBox(width:6),
          IconButton(icon: const Icon(Icons.send, color: Colors.cyan), onPressed: (){ if(ctrl.text.isNotEmpty){ setState((){ messages.add({"type":"text","text":ctrl.text}); ctrl.clear(); }); } })
        ]))
      ]),
    );
  }
}
