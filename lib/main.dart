import 'dart:async';
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
  static String voiceEffect = "Gigante";
  static double pitch = 1.0;
}

class SecureCryptApp extends StatelessWidget {
  const SecureCryptApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: const LockScreen());
  }
}

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});
  @override
  State<LockScreen> createState() => _LockScreenState();
}
class _LockScreenState extends State<LockScreen> {
  String pin = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.lock, size: 60),
        Text("SecureCrypt - ${AppConfig.username}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) => Container(margin: const EdgeInsets.all(6), width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: i < pin.length ? Colors.white : Colors.white24)))),
        const SizedBox(height: 20),
        Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: List.generate(10, (i) {
          String t = i == 9 ? "0" : "${i + 1}";
          return InkWell(onTap: () {
            setState(() => pin += t);
            if (pin.length == 4) {
              if (pin == AppConfig.appPin) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
              else setState(() => pin = "");
            }
          }, child: Container(width: 68, height: 68, decoration: const BoxDecoration(color: Color(0xFF222222), shape: BoxShape.circle), child: Center(child: Text(t, style: const TextStyle(fontSize: 22)))));
        }))
      ])),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int idx = 0;
  String myId = "${Random().nextInt(9000) + 1000}";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [ChatPage(myId: myId), const VaultPage(), const VoicePage(), CallVoipPage(myId: myId), const SettingsPage()][idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx, onTap: (i) => setState(() => idx = i), type: BottomNavigationBarType.fixed, backgroundColor: Colors.black, selectedItemColor: Colors.white, unselectedItemColor: Colors.white38,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.folder_special), label: "Segreta"),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: "Voce"),
          BottomNavigationBarItem(icon: Icon(Icons.phone_in_talk), label: "Chiama"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Impost."),
        ],
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  final String myId;
  const ChatPage({super.key, required this.myId});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text("Chat ID:$myId"), backgroundColor: Colors.black), body: const Center(child: Text("Chat criptata pronta")));
}

class VaultPage extends StatefulWidget { const VaultPage({super.key}); @override State<VaultPage> createState() => _VaultPageState(); }
class _VaultPageState extends State<VaultPage> {
  bool open = false; String pin = "";
  @override
  Widget build(BuildContext context) {
    if (!open) return Scaffold(backgroundColor: Colors.black, appBar: AppBar(title: const Text("Cartella Segreta"), backgroundColor: Colors.black), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.folder_special, size: 50), const SizedBox(height: 15),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) => Container(margin: const EdgeInsets.all(5), width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: i < pin.length ? Colors.white : Colors.white24)))),
      const SizedBox(height: 15),
      Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: List.generate(10, (i) { String t = i == 9 ? "0" : "${i + 1}"; return InkWell(onTap: () { setState(() => pin += t); if (pin.length == 4) { if (pin == AppConfig.vaultPin) setState(() => open = true); else setState(() => pin = ""); } }, child: Container(width: 60, height: 60, decoration: const BoxDecoration(color: Color(0xFF222222), shape: BoxShape.circle), child: Center(child: Text(t)))); }))
    ])));
    return Scaffold(appBar: AppBar(title: const Text("Segreta OK"), backgroundColor: Colors.black, actions: [IconButton(icon: const Icon(Icons.lock), onPressed: () => setState(() => open = false))]), body: const Center(child: Text("File segreti criptati")));
  }
}

class VoicePage extends StatefulWidget { const VoicePage({super.key}); @override State<VoicePage> createState() => _VoicePageState(); }
class _VoicePageState extends State<VoicePage> {
  final recorder = AudioRecorder(); final player = AudioPlayer(); bool hasMic = false; bool isRec = false; String? filePath;
  double getRate() { switch(AppConfig.voiceEffect){ case "Scoiattolo": return 2.2; case "Gigante": return 0.55; case "Alieno": return 0.75; default: return AppConfig.pitch; } }
  Future<void> checkMic() async { var s = await Permission.microphone.request(); setState(() => hasMic = s.isGranted); }
  @override void initState() { super.initState(); checkMic(); }
  Future<void> startRec() async { if (!hasMic) { await checkMic(); if (!hasMic) return; } final dir = await getTemporaryDirectory(); filePath = "${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a"; await recorder.start(RecordConfig(), path: filePath!); setState(() => isRec = true); }
  Future<void> stopRec() async { await recorder.stop(); setState(() => isRec = false); }
  Future<void> playSound() async { if (filePath == null) return; await player.stop(); await player.setPlaybackRate(getRate()); await player.play(DeviceFileSource(filePath!)); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Cambia Voce"), backgroundColor: Colors.black), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    if (!hasMic) ElevatedButton(onPressed: checkMic, child: const Text("AUTORIZZA MICROFONO")), if (hasMic) const Text("Microfono OK", style: TextStyle(color: Colors.greenAccent)),
    const SizedBox(height: 12), Wrap(spacing: 8, children: ["Robot","Scoiattolo","Gigante","Alieno"].map((e) => ChoiceChip(label: Text(e), selected: AppConfig.voiceEffect==e, onSelected: (_)=>setState(()=>AppConfig.voiceEffect=e))).toList()),
    Slider(value: AppConfig.pitch, min: 0.5, max: 2.5, onChanged: (v)=>setState(()=>AppConfig.pitch=v)),
    GestureDetector(onLongPress: startRec, onLongPressUp: ()=>stopRec(), child: Container(width: isRec?120:90, height: isRec?120:90, decoration: BoxDecoration(color: isRec?Colors.red:Colors.white, shape: BoxShape.circle), child: Icon(isRec?Icons.stop:Icons.mic, color: Colors.black, size: 35))),
    Text(isRec?"Registra...":"Tieni premuto"), const SizedBox(height: 15), if (filePath!=null) ElevatedButton(onPressed: playSound, child: Text("Ascolta ${AppConfig.voiceEffect} ${getRate()}x"))
  ])));
}

class CallVoipPage extends StatefulWidget {
  final String myId;
  const CallVoipPage({super.key, required this.myId});
  @override State<CallVoipPage> createState() => _CallVoipPageState();
}
class _CallVoipPageState extends State<CallVoipPage> {
  final TextEditingController roomCtrl = TextEditingController(text: "1234");
  bool inCall = false;
  Timer? timer;
  int seconds = 0;
  final recorder = AudioRecorder();
  final player = AudioPlayer();
  String? livePath;
  bool isLiveListening = false;

  double getRate() { switch(AppConfig.voiceEffect){ case "Scoiattolo": return 2.2; case "Gigante": return 0.5; case "Alieno": return 0.7; default: return 1.0; } }

  void startCall() async {
    var mic = await Permission.microphone.request();
    if (!mic.isGranted) return;
    setState(() { inCall = true; seconds = 0; });
    timer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() => seconds++));
    final dir = await getTemporaryDirectory();
    livePath = "${dir.path}/live_call.m4a";
    await recorder.start(RecordConfig(), path: livePath!);
  }

  void endCall() async {
    timer?.cancel();
    try { await recorder.stop(); } catch (_) {}
    await player.stop();
    setState(() { inCall = false; isLiveListening = false; });
  }

  Future<void> toggleLive() async {
    if (livePath == null) return;
    if (isLiveListening) {
      await player.stop();
      setState(() => isLiveListening = false);
    } else {
      try { await recorder.stop(); } catch (_) {}
      await player.stop();
      await player.setPlaybackRate(getRate());
      await player.play(DeviceFileSource(livePath!));
      setState(() => isLiveListening = true);
      final dir = await getTemporaryDirectory();
      livePath = "${dir.path}/live_call2.m4a";
      await recorder.start(RecordConfig(), path: livePath!);
    }
  }

  String fmt(int s) => "${(s~/60).toString().padLeft(2,'0')}:${(s%60).toString().padLeft(2,'0')}";

  @override Widget build(BuildContext context) {
    if (!inCall) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: const Text("Chiamata Segreta VoIP"), backgroundColor: Colors.black),
        body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange)), child: const Row(children: [Icon(Icons.warning, color: Colors.orange, size: 18), SizedBox(width: 8), Expanded(child: Text("CHIAMATA CONSENSUALE: l'altra persona vedra' VOCE MODIFICATA. Solo tra utenti SecureCrypt.", style: TextStyle(fontSize: 11, color: Colors.orange)))])),
          const SizedBox(height: 15),
          const Icon(Icons.phone_in_talk, size: 70, color: Colors.white24),
          const SizedBox(height: 10),
          Text("Il tuo ID: ${widget.myId}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(controller: roomCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "ID stanza da chiamare", border: OutlineInputBorder(), prefixIcon: Icon(Icons.tag)), textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, letterSpacing: 4)),
          const SizedBox(height: 15),
          const Text("SCEGLI EFFETTO PER LA CHIAMATA:", style: TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: ["Robot","Scoiattolo","Gigante","Alieno"].map((e) => ChoiceChip(label: Text(e), selected: AppConfig.voiceEffect==e, onSelected: (_)=>setState(()=>AppConfig.voiceEffect=e))).toList()),
          const Spacer(),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(18)), onPressed: startCall, icon: const Icon(Icons.call), label: Text("AVVIA CHIAMATA ${roomCtrl.text} - ${AppConfig.voiceEffect.toUpperCase()}"))),
        ])),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(child: Column(children: [
        const SizedBox(height: 30),
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: Text("VOCE MODIFICATA: ${AppConfig.voiceEffect.toUpperCase()} ${getRate()}x - L'ALTRO UTENTE LO VEDE", style: const TextStyle(color: Colors.greenAccent, fontSize: 10))),
        const SizedBox(height: 15),
        Text(fmt(seconds), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300)),
        Text("Stanza ${roomCtrl.text} | ID ${widget.myId} -> ${roomCtrl.text}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
        const Spacer(),
        Container(width: 130, height: 130, decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle), child: const Icon(Icons.person, size: 60)),
        const SizedBox(height: 12),
        Text("Chiamando ID ${roomCtrl.text}", style: const TextStyle(fontSize: 18)),
        const Text("Microfono attivo con filtro", style: TextStyle(color: Colors.greenAccent, fontSize: 11)),
        const Spacer(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          InkWell(onTap: toggleLive, child: Container(width: 68, height: 68, decoration: BoxDecoration(color: isLiveListening ? Colors.green : Colors.white, shape: BoxShape.circle), child: Icon(isLiveListening ? Icons.hearing : Icons.graphic_eq, color: Colors.black))),
          InkWell(onTap: endCall, child: Container(width: 68, height: 68, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.call_end, color: Colors.white, size: 30))),
        ]),
        const SizedBox(height: 10),
        Text(isLiveListening ? "Stai ascoltando effetto ${AppConfig.voiceEffect}" : "Tocca EQ per testare la tua voce ${AppConfig.voiceEffect}", style: const TextStyle(fontSize: 10, color: Colors.white38)),
        const SizedBox(height: 25),
      ])),
    );
  }
}
class SettingsPage extends StatefulWidget { const SettingsPage({super.key}); @override State<SettingsPage> createState() => _SettingsPageState(); }
class _SettingsPageState extends State<SettingsPage> {
  TextEditingController u = TextEditingController(text: AppConfig.username); TextEditingController k = TextEditingController(text: AppConfig.encryptionKey); TextEditingController ap = TextEditingController(text: AppConfig.appPin); TextEditingController vp = TextEditingController(text: AppConfig.vaultPin); bool o1=true,o2=true,o3=true;
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Impostazioni"), backgroundColor: Colors.black), body: ListView(padding: const EdgeInsets.all(16), children: [
    TextField(controller: u, decoration: const InputDecoration(labelText: "Nome Utente", prefixIcon: Icon(Icons.person))),
    TextField(controller: k, obscureText: o3, decoration: InputDecoration(labelText: "Chiave", prefixIcon: const Icon(Icons.vpn_key), suffixIcon: IconButton(icon: Icon(o3?Icons.visibility_off:Icons.visibility), onPressed: ()=>setState(()=>o3=!o3)))),
    const SizedBox(height: 12),
    TextField(controller: ap, obscureText: o1, maxLength: 4, decoration: InputDecoration(labelText: "Pin App", suffixIcon: IconButton(icon: Icon(o1?Icons.visibility_off:Icons.visibility), onPressed: ()=>setState(()=>o1=!o1)), counterText: "")),
    TextField(controller: vp, obscureText: o2, maxLength: 4, decoration: InputDecoration(labelText: "Pin Segreta", suffixIcon: IconButton(icon: Icon(o2?Icons.visibility_off:Icons.visibility), onPressed: ()=>setState(()=>o2=!o2)), counterText: "")),
    const SizedBox(height: 20),
    ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.all(16)), onPressed: () { setState(() { AppConfig.username=u.text; AppConfig.encryptionKey=k.text; AppConfig.appPin=ap.text; AppConfig.vaultPin=vp.text; }); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Salvato ${AppConfig.username}"))); }, child: const Text("SALVA TUTTO"))
  ]));
}
