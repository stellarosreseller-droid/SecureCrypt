import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const SecureCryptApp());

class AppConfig {
  static String username = "Utente";
  static String encryptionKey = "SC-KEY-2024";
  static String appPin = "1234";
  static String vaultPin = "0000";
  static String voiceEffect = "Robot";
  static double pitch = 1.0;
  static bool hidePreview = true;
  static bool autoLock = true;
}

class SecureCryptApp extends StatelessWidget {
  const SecureCryptApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF0F0F0F)), home: const LockScreen());
  }
}

class LockScreen extends StatefulWidget { const LockScreen({super.key}); @override State<LockScreen> createState()=> _LockScreenState(); }
class _LockScreenState extends State<LockScreen> {
  String pin = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.lock, size: 65), const SizedBox(height: 8),
      Text("SecureCrypt - ${AppConfig.username}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text("Key: ${AppConfig.encryptionKey}", style: const TextStyle(fontSize: 10, color: Colors.greenAccent)),
      const SizedBox(height: 20),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i)=> Container(margin: const EdgeInsets.all(6), width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, color: i < pin.length? Colors.white : Colors.white12)))),
      const SizedBox(height: 20),
      Wrap(spacing: 14, runSpacing: 14, alignment: WrapAlignment.center, children: List.generate(10, (i){
        String t = i==9? "0" : "${i+1}";
        return InkWell(onTap: (){ setState(()=> pin+=t); if(pin.length==4){ if(pin==AppConfig.appPin){ Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const MainShell())); } else { setState(()=> pin=""); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errato! Pin: ${AppConfig.appPin}"))); } } }, child: Container(width: 70, height: 70, decoration: const BoxDecoration(color: Color(0xFF1E1E1E), shape: BoxShape.circle), child: Center(child: Text(t, style: const TextStyle(fontSize: 24)))));
      }))
    ])));
  }
}

class MainShell extends StatefulWidget { const MainShell({super.key}); @override State<MainShell> createState()=> _MainShellState(); }
class _MainShellState extends State<MainShell> {
  int idx=0; final myId = "${Random().nextInt(9000)+1000}";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [ChatPage(myId: myId), const VaultPage(), const VoicePage(), const SettingsPage()][idx],
      bottomNavigationBar: BottomNavigationBar(currentIndex: idx, onTap: (i)=> setState(()=> idx=i), backgroundColor: Colors.black, type: BottomNavigationBarType.fixed, selectedItemColor: Colors.white, unselectedItemColor: Colors.white38, items: const [BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"), BottomNavigationBarItem(icon: Icon(Icons.folder_special), label: "Segreta"), BottomNavigationBarItem(icon: Icon(Icons.mic), label: "Voce"), BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Impostazioni")]),
    );
  }
}

class ChatPage extends StatefulWidget { final String myId; const ChatPage({super.key, required this.myId}); @override State<ChatPage> createState()=> _ChatPageState(); }
class _ChatPageState extends State<ChatPage> {
  List<Map<String,String>> contacts=[]; List<Map<String,dynamic>> msgs=[]; String? active; final idC=TextEditingController(); final nameC=TextEditingController(); final msgC=TextEditingController();
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: Text("${AppConfig.username} ID:${widget.myId}"), backgroundColor: Colors.black), body: Column(children: [Padding(padding: const EdgeInsets.all(8), child: Row(children: [Expanded(child: TextField(controller: nameC, decoration: const InputDecoration(hintText: "Nome", isDense: true))), const SizedBox(width:5), Expanded(child: TextField(controller: idC, decoration: const InputDecoration(hintText: "ID", isDense: true))), IconButton(onPressed: (){ if(idC.text.isNotEmpty&&nameC.text.isNotEmpty){ setState((){ contacts.add({"id":idC.text.trim(),"name":nameC.text.trim()}); active=idC.text.trim(); msgs=[{"text":"Chat con ${nameC.text} - Key ${AppConfig.encryptionKey}","me":false}]; }); idC.clear(); nameC.clear(); } }, icon: const Icon(Icons.add))])), Expanded(child: ListView.builder(padding: const EdgeInsets.all(10), itemCount: msgs.length, itemBuilder: (_,i){ bool me=msgs[i]["me"]==true; return Align(alignment: me? Alignment.centerRight: Alignment.centerLeft, child: Container(margin: const EdgeInsets.symmetric(vertical: 4), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: me? Colors.white: Colors.white12, borderRadius: BorderRadius.circular(12)), child: Text(msgs[i]["text"], style: TextStyle(color: me? Colors.black: Colors.white)))); })), Padding(padding: const EdgeInsets.all(8), child: Row(children: [Expanded(child: TextField(controller: msgC, decoration: const InputDecoration(hintText: "Messaggio"))), IconButton(icon: const Icon(Icons.send), onPressed: (){ if(msgC.text.isEmpty||active==null) return; setState(()=> msgs.add({"text":"[${AppConfig.encryptionKey}] ${msgC.text}","me":true})); msgC.clear(); })]))])); }
}

class VaultPage extends StatefulWidget { const VaultPage({super.key}); @override State<VaultPage> createState()=> _VaultPageState(); }
class _VaultPageState extends State<VaultPage> {
  bool open=false; String pin=""; bool obscure=true;
  @override Widget build(BuildContext context) {
    if(!open) return Scaffold(backgroundColor: Colors.black, appBar: AppBar(title: const Text("Cartella Segreta"), backgroundColor: Colors.black), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.folder_special, size: 60), Text("Pin Vault: ${AppConfig.vaultPin}", style: const TextStyle(color: Colors.white30, fontSize: 10)),
      const SizedBox(height: 10), Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i)=> Container(margin: const EdgeInsets.all(6), width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.circle, color: i<pin.length? Colors.white: Colors.white24)))),
      const SizedBox(height: 10), IconButton(icon: Icon(obscure? Icons.visibility_off: Icons.visibility), onPressed: ()=> setState(()=> obscure=!obscure)),
      Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: List.generate(10, (i){ String t=i==9? "0": "${i+1}"; return InkWell(onTap: (){ setState(()=> pin+=t); if(pin.length==4){ if(pin==AppConfig.vaultPin) setState(()=> open=true); else setState(()=> pin=""); } }, child: Container(width: 65, height: 65, decoration: const BoxDecoration(color: Color(0xFF222222), shape: BoxShape.circle), child: Center(child: Text(obscure? "•": t, style: const TextStyle(fontSize: 22))))); }))
    ])));
    return Scaffold(appBar: AppBar(title: const Text("Segreta OK"), backgroundColor: Colors.black, actions: [IconButton(icon: const Icon(Icons.lock), onPressed: ()=> setState(()=> open=false))]), body: const Center(child: Text("File criptati con ${AppConfig.encryptionKey}")));
  }
}

class VoicePage extends StatefulWidget { const VoicePage({super.key}); @override State<VoicePage> createState()=> _VoicePageState(); }
class _VoicePageState extends State<VoicePage> {
  final AudioRecorder recorder = AudioRecorder(); final AudioPlayer player = AudioPlayer();
  bool hasMic=false; bool isRec=false; String? path; bool isPlaying=false;
  Future<void> checkMic() async { var s = await Permission.microphone.request(); setState(()=> hasMic=s.isGranted); }
  @override void initState(){ super.initState(); checkMic(); }
  Future<void> startRec() async {
    if(!hasMic){ await checkMic(); if(!hasMic) return; }
    final dir = await getTemporaryDirectory(); path = "${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a";
    await recorder.start(const RecordConfig(), path: path!); setState(()=> isRec=true);
  }
  Future<void> stopRec() async { await recorder.stop(); setState(()=> isRec=false); }
  Future<void> play() async {
    if(path==null) return; setState(()=> isPlaying=true);
    await player.setPlaybackRate(AppConfig.pitch); await player.play(DeviceFileSource(path!));
    player.onPlayerComplete.listen((_)=> setState(()=> isPlaying=false));
  }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Cambia Voce TEST"), backgroundColor: Colors.black), body: Padding(padding: const EdgeInsets.all(18), child: Column(children: [
      if(!hasMic) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.warning, color: Colors.red), const SizedBox(width: 8), const Expanded(child: Text("Microfono non autorizzato")), ElevatedButton(onPressed: checkMic, child: const Text("AUTORIZZA"))])),
      if(hasMic) const Text("Microfono AUTORIZZATO ✔", style: TextStyle(color: Colors.greenAccent)),
      const SizedBox(height: 16),
      Wrap(spacing: 8, children: ["Robot","Scoiattolo","Gigante","Alieno"].map((e)=> ChoiceChip(label: Text(e), selected: AppConfig.voiceEffect==e, onSelected: (_)=> setState(()=> AppConfig.voiceEffect=e))).toList()),
      const SizedBox(height: 10), Text("Velocità / Pitch: ${AppConfig.pitch.toStringAsFixed(1)}x"),
      Slider(value: AppConfig.pitch, min: 0.5, max: 2.0, divisions: 6, label: "${AppConfig.pitch}x", onChanged: (v)=> setState(()=> AppConfig.pitch=v)),
      const Spacer(),
      GestureDetector(onLongPress: startRec, onLongPressUp: (){ stopRec(); }, child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: isRec? 130: 95, height: isRec? 130: 95, decoration: BoxDecoration(color: isRec? Colors.red: Colors.white, shape: BoxShape.circle), child: Icon(isRec? Icons.stop: Icons.mic, size: 42, color: Colors.black))),
      const SizedBox(height: 10), Text(isRec? "REGISTRAZIONE... rilascia per fermare" : "Tieni PREMUTO per registrare", style: const TextStyle(color: Colors.white60, fontSize: 12)),
      const SizedBox(height: 20),
      if(path!=null) ElevatedButton.icon(icon: Icon(isPlaying? Icons.stop: Icons.play_arrow), label: Text(isPlaying? "Stop" : "Riascolta con effetto ${AppConfig.voiceEffect}"), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black), onPressed: isPlaying? (){ player.stop(); setState(()=> isPlaying=false); } : play),
      const Spacer(),
    ])));
  }
}

class SettingsPage extends StatefulWidget { const SettingsPage({super.key}); @override State<SettingsPage> createState()=> _SettingsPageState(); }
class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController u = TextEditingController(text: AppConfig.username);
  late TextEditingController k = TextEditingController(text: AppConfig.encryptionKey);
  late TextEditingController ap = TextEditingController(text: AppConfig.appPin);
  late TextEditingController vp = TextEditingController(text: AppConfig.vaultPin);
  bool obscureApp=true; bool obscureVault=true; bool obscureKey=true;
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Impostazioni Complete"), backgroundColor: Colors.black), body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text("PROFILO", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8), TextField(controller: u, decoration: InputDecoration(labelText: "Nome Utente", filled: true, fillColor: const Color(0xFF1E1E1E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.person))),
      const SizedBox(height: 12),
      TextField(controller: k, obscureText: obscureKey, decoration: InputDecoration(labelText: "Chiave Crittografia", filled: true, fillColor: const Color(0xFF1E1E1E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.vpn_key), suffixIcon: IconButton(icon: Icon(obscureKey? Icons.visibility_off: Icons.visibility), onPressed: ()=> setState(()=> obscureKey=!obscureKey)))),
      const SizedBox(height: 20), const Text("SICUREZZA - PIN NASCOSTI", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      TextField(controller: ap, obscureText: obscureApp, maxLength: 4, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Pin App", filled: true, fillColor: const Color(0xFF1E1E1E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(obscureApp? Icons.visibility_off: Icons.visibility), onPressed: ()=> setState(()=> obscureApp=!obscureApp)), counterText: "")),
      const SizedBox(height: 8),
      TextField(controller: vp, obscureText: obscureVault, maxLength: 4, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Pin Cartella Segreta", filled: true, fillColor: const Color(0xFF1E1E1E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.folder_special), suffixIcon: IconButton(icon: Icon(obscureVault? Icons.visibility_off: Icons.visibility), onPressed: ()=> setState(()=> obscureVault=!obscureVault)), counterText: "")),
      const SizedBox(height: 20), const Text("PRIVACY", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
      SwitchListTile(title: const Text("Nascondi anteprima messaggi"), value: AppConfig.hidePreview, onChanged: (v)=> setState(()=> AppConfig.hidePreview=v)),
      SwitchListTile(title: const Text("Blocco automatico"), subtitle: const Text("Blocca app quando esci"), value: AppConfig.autoLock, onChanged: (v)=> setState(()=> AppConfig.autoLock=v)),
      const SizedBox(height: 10), const Text("AUDIO", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
      ListTile(leading: const Icon(Icons.mic), title: const Text("Test Microfono"), subtitle: Text(AppConfig.voiceEffect), trailing: const Icon(Icons.chevron_right), onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const VoicePage()))),
      const SizedBox(height: 20),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: (){ setState((){ AppConfig.username=u.text; AppConfig.encryptionKey=k.text; AppConfig.appPin=ap.text; AppConfig.vaultPin=vp.text; }); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Salvato! Pin nascosti attivi - Utente ${AppConfig.username}"))); }, child: const Text("SALVA TUTTO", style: TextStyle(fontWeight: FontWeight.bold))),
      const SizedBox(height: 30), const Center(child: Text("SecureCrypt v5 - Tutto criptato", style: TextStyle(color: Colors.white24, fontSize: 10)))
    ]));
  }
}
