import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF0F0F0F)),
      home: const PinScreen(),
    );
  }
}

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});
  @override State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final ctrl = TextEditingController();
  String err = "";
  void go() {
    final pin = ctrl.text.trim();
    if (pin == '123456') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen(fake: false)));
    } else if (pin == '000000') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen(fake: true)));
    } else {
      setState(() => err = "PIN errato");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.lock_outline, size: 80, color: Color(0xFF00FF88)),
            const SizedBox(height: 12),
            const Text("SecureCrypt.com", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("123456=reale 000000=fake", style: TextStyle(fontSize: 11, color: Colors.white54)),
            const SizedBox(height: 24),
            TextField(controller: ctrl, obscureText: true, keyboardType: TextInputType.number, textAlign: TextAlign.center, decoration: InputDecoration(hintText: "PIN", errorText: err.isEmpty? null : err, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onSubmitted: (_) => go()),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: go, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF88), foregroundColor: Colors.black, padding: const EdgeInsets.all(16)), child: const Text("SBLOCCA", style: TextStyle(fontWeight: FontWeight.bold)))),
          ]),
        ),
      ),
    );
  }
}

class GhostMessage { String text; int ttl; Timer? timer; GhostMessage(this.text, this.ttl); }

class HomeScreen extends StatefulWidget {
  final bool fake; const HomeScreen({super.key, required this.fake});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController tab;
  final recorder = AudioRecorder();
  final player = AudioPlayer();
  bool isRec = false;
  List<File> files = [];
  String vaultPath = '';
  double pitch = 1.0;
  String vname = "Normale";
  File? lastRecording;
  List<GhostMessage> chats = [];
  final chatController = TextEditingController();
  int ttlSeconds = 30;

  @override
  void initState() { super.initState(); tab = TabController(length: 4, vsync: this); initVault(); }

  Future<void> initVault() async {
    await Permission.microphone.request();
    final dir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory(p.join(dir.path, 'vault'));
    if (!await vaultDir.exists()) await vaultDir.create(recursive: true);
    vaultPath = vaultDir.path;
    refreshFiles();
  }

  void refreshFiles() {
    if (vaultPath.isEmpty) return;
    final list = Directory(vaultPath).listSync().whereType<File>().toList();
    setState(() => files = list);
  }

  Future<void> toggleRecord() async {
    if (isRec) {
      final path = await recorder.stop();
      setState(() => isRec = false);
      if (path!= null) lastRecording = File(path);
      refreshFiles();
    } else {
      if (await recorder.hasPermission()) {
        final path = p.join(vaultPath, 'ghost_${DateTime.now().millisecondsSinceEpoch}.m4a');
        await recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
        setState(() => isRec = true);
      }
    }
  }

  Future<void> playWithPitch(File f) async {
    await player.stop();
    await player.setFilePath(f.path);
    await player.setSpeed(pitch);
    await player.play();
  }

  void setVoice(double p, String n) { setState(() { pitch = p; vname = n; }); if (player.playing) player.setSpeed(p); }

  void sendGhost() {
    if (chatController.text.trim().isEmpty) return;
    final msg = GhostMessage(chatController.text.trim(), ttlSeconds);
    setState(() { chats.insert(0, msg); chatController.clear(); });
    msg.timer = Timer.periodic(const Duration(seconds: 1), (t) {
      msg.ttl--;
      if (msg.ttl <= 0) { t.cancel(); if (mounted) setState(() => chats.remove(msg)); } else { if (mounted) setState(() {}); }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fake) return Scaffold(appBar: AppBar(title: const Text("Calculator")), body: const Center(child: Text("0", style: TextStyle(fontSize: 48))));
    return Scaffold(
      appBar: AppBar(title: const Text("SecureCrypt.com"), backgroundColor: const Color(0xFF1A1A1A), bottom: TabBar(controller: tab, isScrollable: true, indicatorColor: const Color(0xFF00FF88), tabs: const [Tab(icon: Icon(Icons.mic), text: "Ghost Rec"), Tab(icon: Icon(Icons.graphic_eq), text: "Voice"), Tab(icon: Icon(Icons.timer), text: "Ghost Chat"), Tab(icon: Icon(Icons.folder_special), text: "Vault")])),
      body: TabBarView(controller: tab, children: [
        Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(isRec? Icons.mic : Icons.mic_none, size: 90, color: isRec? Colors.red : const Color(0xFF00FF88)), const SizedBox(height: 12), Text(isRec? "REGISTRAZIONE IN CORSO" : "Registratore fantasma"), const SizedBox(height: 40), GestureDetector(onTap: toggleRecord, child: Container(width: 100, height: 100, decoration: BoxDecoration(color: isRec? Colors.red : const Color(0xFF00FF88), shape: BoxShape.circle), child: Icon(isRec? Icons.stop : Icons.mic, size: 45, color: Colors.black))), const SizedBox(height: 20), if (lastRecording!= null) ElevatedButton.icon(onPressed: () => playWithPitch(lastRecording!), icon: const Icon(Icons.play_arrow), label: Text("Ascolta $vname"), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF88), foregroundColor: Colors.black)) ])),
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Scegli voce:", style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 12), Wrap(spacing: 8, runSpacing: 8, children: [ChoiceChip(label: const Text("Normale"), selected: pitch==1.0, selectedColor: const Color(0xFF00FF88), onSelected: (_)=>setVoice(1.0,"Normale")), ChoiceChip(label: const Text("Profonda"), selected: pitch==0.7, selectedColor: const Color(0xFF00FF88), onSelected: (_)=>setVoice(0.7,"Profonda")), ChoiceChip(label: const Text("Acuta"), selected: pitch==1.4, selectedColor: const Color(0xFF00FF88), onSelected: (_)=>setVoice(1.4,"Acuta")), ChoiceChip(label: const Text("Robot"), selected: pitch==0.85, selectedColor: const Color(0xFF00FF88), onSelected: (_)=>setVoice(0.85,"Robot")), ChoiceChip(label: const Text("Gigante"), selected: pitch==0.6, selectedColor: const Color(0xFF00FF88), onSelected: (_)=>setVoice(0.6,"Gigante")), ChoiceChip(label: const Text("Scoiattolo"), selected: pitch==1.8, selectedColor: const Color(0xFF00FF88), onSelected: (_)=>setVoice(1.8,"Scoiattolo"))]), const SizedBox(height: 24), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.graphic_eq, color: Color(0xFF00FF88)), const SizedBox(width: 12), Text("Attiva: $vname ${pitch}x")])), const Spacer(), if (lastRecording!= null) SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => playWithPitch(lastRecording!), icon: const Icon(Icons.play_arrow), label: Text("Prova voce $vname"), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF88), foregroundColor: Colors.black, padding: const EdgeInsets.all(16))))])),
        Column(children: [Container(color: Colors.white10, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Row(children: [const Icon(Icons.timer, size: 18), const SizedBox(width: 8), const Text("Autodistruzione:"), const SizedBox(width: 12), DropdownButton<int>(value: ttlSeconds, underline: const SizedBox(), items: const [DropdownMenuItem(value: 5, child: Text("5s")), DropdownMenuItem(value: 30, child: Text("30s")), DropdownMenuItem(value: 60, child: Text("1 min")), DropdownMenuItem(value: 300, child: Text("5 min"))], onChanged: (v) => setState(() => ttlSeconds = v!))])), Expanded(child: ListView.builder(reverse: true, itemCount: chats.length, itemBuilder: (c,i){ final m = chats[i]; return Container(margin: const EdgeInsets.all(8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF00FF88).withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00FF88))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m.text, style: const TextStyle(fontSize: 15)), const SizedBox(height: 6), Text("${m.ttl}s alla distruzione", style: const TextStyle(fontSize: 11, color: Color(0xFF00FF88)))]));})), Padding(padding: const EdgeInsets.all(8), child: Row(children: [Expanded(child: TextField(controller: chatController, decoration: InputDecoration(hintText: "Messaggio segreto...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)), contentPadding: const EdgeInsets.symmetric(horizontal: 16)), onSubmitted: (_) => sendGhost())), const SizedBox(width: 8), CircleAvatar(backgroundColor: const Color(0xFF00FF88), child: IconButton(icon: const Icon(Icons.send, color: Colors.black), onPressed: sendGhost))]))]),
        Column(children: [Padding(padding: const EdgeInsets.all(12), child: SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () async { final r = await FilePicker.platform.pickFiles(); if (r!= null && r.files.single.path!= null) { final src = File(r.files.single.path!); final dest = File(p.join(vaultPath, p.basename(src.path))); await src.copy(dest.path); refreshFiles(); }}, icon: const Icon(Icons.upload_file), label: const Text("Nascondi file segreto"), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF88), foregroundColor: Colors.black)))), Expanded(child: files.isEmpty? const Center(child: Text("Vault vuoto", style: TextStyle(color: Colors.white54))) : ListView.builder(itemCount: files.length, itemBuilder: (c,i){ final f = files[i]; return ListTile(leading: const Icon(Icons.insert_drive_file, color: Color(0xFF00FF88)), title: Text(p.basename(f.path), style: const TextStyle(fontSize: 13)), subtitle: Text("${(f.lengthSync()/1024).toStringAsFixed(1)} KB", style: const TextStyle(fontSize: 11)), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () { f.deleteSync(); refreshFiles(); }));}))],
      ]),
    );
  }
  @override void dispose() { tab.dispose(); player.dispose(); recorder.dispose(); for (var m in chats) m.timer?.cancel(); super.dispose(); }
}
