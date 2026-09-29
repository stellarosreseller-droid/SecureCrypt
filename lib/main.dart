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
}

class SecureCryptApp extends StatelessWidget {
  const SecureCryptApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const LockScreen(),
    );
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
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.lock, size: 60),
          Text("SecureCrypt - ${AppConfig.username}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Key: ${AppConfig.encryptionKey}", style: const TextStyle(fontSize: 10, color: Colors.greenAccent)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) => Container(margin: const EdgeInsets.all(6), width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: i < pin.length? Colors.white : Colors.white24)))),
          const SizedBox(height: 20),
          Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: List.generate(10, (i) {
            String t = i == 9? "0" : "${i + 1}";
            return InkWell(
              onTap: () {
                setState(() => pin += t);
                if (pin.length == 4) {
                  if (pin == AppConfig.appPin) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
                  } else {
                    setState(() => pin = "");
                  }
                }
              },
              child: Container(width: 68, height: 68, decoration: const BoxDecoration(color: Color(0xFF222222), shape: BoxShape.circle), child: Center(child: Text(t, style: const TextStyle(fontSize: 22)))),
            );
          }))
        ]),
      ),
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
      body: [ChatPage(myId: myId), const VaultPage(), const VoicePage(), const SettingsPage()][idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => setState(() => idx = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.folder_special), label: "Segreta"),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: "Voce"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Impostazioni"),
        ],
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  final String myId;
  const ChatPage({super.key, required this.myId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Chat ID:$myId"), backgroundColor: Colors.black), body: const Center(child: Text("Chat criptata pronta")));
  }
}

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});
  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  bool open = false;
  String pin = "";
  @override
  Widget build(BuildContext context) {
    if (!open) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: const Text("Cartella Segreta"), backgroundColor: Colors.black),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.folder_special, size: 50),
            Text("Pin: ${AppConfig.vaultPin}", style: const TextStyle(fontSize: 10, color: Colors.white38)),
            const SizedBox(height: 15),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) => Container(margin: const EdgeInsets.all(5), width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: i < pin.length? Colors.white : Colors.white24)))),
            const SizedBox(height: 15),
            Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: List.generate(10, (i) {
              String t = i == 9? "0" : "${i + 1}";
              return InkWell(onTap: () { setState(() => pin += t); if (pin.length == 4) { if (pin == AppConfig.vaultPin) setState(() => open = true); else setState(() => pin = ""); } }, child: Container(width: 60, height: 60, decoration: const BoxDecoration(color: Color(0xFF222222), shape: BoxShape.circle), child: Center(child: Text(t))));
            }))
          ]),
        ),
      );
    }
    return Scaffold(appBar: AppBar(title: const Text("Segreta OK"), backgroundColor: Colors.black, actions: [IconButton(icon: const Icon(Icons.lock), onPressed: () => setState(() => open = false))]), body: const Center(child: Text("File segreti criptati")));
  }
}

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});
  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  final AudioRecorder recorder = AudioRecorder();
  final AudioPlayer player = AudioPlayer();
  bool hasMic = false;
  bool isRec = false;
  String? filePath;

  Future<void> checkMic() async {
    var s = await Permission.microphone.request();
    setState(() => hasMic = s.isGranted);
  }

  @override
  void initState() {
    super.initState();
    checkMic();
  }

  Future<void> startRec() async {
    if (!hasMic) { await checkMic(); if (!hasMic) return; }
    final dir = await getTemporaryDirectory();
    filePath = "${dir.path}/test.m4a";
    await recorder.start(const RecordConfig(), path: filePath!);
    setState(() => isRec = true);
  }

  Future<void> stopRec() async {
    await recorder.stop();
    setState(() => isRec = false);
  }

  Future<void> playSound() async {
    if (filePath == null) return;
    await player.setPlaybackRate(AppConfig.pitch);
    await player.play(DeviceFileSource(filePath!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cambia Voce"), backgroundColor: Colors.black),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (!hasMic) ElevatedButton(onPressed: checkMic, child: const Text("AUTORIZZA MICROFONO")),
          if (hasMic) const Text("Microfono OK", style: TextStyle(color: Colors.greenAccent)),
          const SizedBox(height: 15),
          Wrap(spacing: 8, children: ["Robot", "Scoiattolo", "Gigante", "Alieno"].map((e) => ChoiceChip(label: Text(e), selected: AppConfig.voiceEffect == e, onSelected: (_) => setState(() => AppConfig.voiceEffect = e))).toList()),
          const SizedBox(height: 10),
          Text("Pitch: ${AppConfig.pitch.toStringAsFixed(1)}x"),
          Slider(value: AppConfig.pitch, min: 0.5, max: 2.0, onChanged: (v) => setState(() => AppConfig.pitch = v)),
          const SizedBox(height: 20),
          GestureDetector(
            onLongPress: startRec,
            onLongPressUp: () => stopRec(),
            child: Container(width: isRec? 120 : 90, height: isRec? 120 : 90, decoration: BoxDecoration(color: isRec? Colors.red : Colors.white, shape: BoxShape.circle), child: Icon(isRec? Icons.stop : Icons.mic, color: Colors.black, size: 35)),
          ),
          Text(isRec? "Registra..." : "Tieni premuto"),
          const SizedBox(height: 20),
          if (filePath!= null) ElevatedButton(onPressed: playSound, child: Text("Riascolta ${AppConfig.voiceEffect}"))
        ]),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController u = TextEditingController(text: AppConfig.username);
  TextEditingController k = TextEditingController(text: AppConfig.encryptionKey);
  TextEditingController ap = TextEditingController(text: AppConfig.appPin);
  TextEditingController vp = TextEditingController(text: AppConfig.vaultPin);
  bool o1 = true, o2 = true, o3 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Impostazioni Complete"), backgroundColor: Colors.black),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text("PROFILO", style: TextStyle(fontSize: 11, color: Colors.white54)),
        TextField(controller: u, decoration: const InputDecoration(labelText: "Nome Utente", prefixIcon: Icon(Icons.person))),
        const SizedBox(height: 8),
        TextField(controller: k, obscureText: o3, decoration: InputDecoration(labelText: "Chiave Crittografia", prefixIcon: const Icon(Icons.vpn_key), suffixIcon: IconButton(icon: Icon(o3? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => o3 =!o3)))),
        const SizedBox(height: 20),
        const Text("SICUREZZA - PIN NASCOSTI", style: TextStyle(fontSize: 11, color: Colors.white54)),
        TextField(controller: ap, obscureText: o1, maxLength: 4, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Pin App (nascosto)", prefixIcon: const Icon(Icons.lock), suffixIcon: IconButton(icon: Icon(o1? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => o1 =!o1)), counterText: "")),
        const SizedBox(height: 8),
        TextField(controller: vp, obscureText: o2, maxLength: 4, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Pin Segreta (nascosto)", prefixIcon: const Icon(Icons.folder_special), suffixIcon: IconButton(icon: Icon(o2? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => o2 =!o2)), counterText: "")),
        const SizedBox(height: 20),
        SwitchListTile(title: const Text("Blocco automatico"), value: true, onChanged: (v) {}),
        SwitchListTile(title: const Text("Nascondi anteprima"), value: true, onChanged: (v) {}),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.all(16)),
          onPressed: () {
            setState(() {
              AppConfig.username = u.text;
              AppConfig.encryptionKey = k.text;
              AppConfig.appPin = ap.text;
              AppConfig.vaultPin = vp.text;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Salvato! Utente ${AppConfig.username}")));
          },
          child: const Text("SALVA TUTTO"),
        )
      ]),
    );
  }
}
