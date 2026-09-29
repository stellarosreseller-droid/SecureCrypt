import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const SecureCryptApp());

class AppConfig {
  static String username = "Utente";
  static String encryptionKey = "SC-KEY-2024";
  static String appPin = "1234";
  static String vaultPin = "0000";
  static String voiceEffect = "Robot";
  static double pitch = 0;
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
          const SizedBox(height: 10),
          Text("SecureCrypt - ${AppConfig.username}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("Key: ${AppConfig.encryptionKey} | Pin: ${AppConfig.appPin}", style: const TextStyle(fontSize: 10, color: Colors.greenAccent)),
          const SizedBox(height: 20),
          Text(pin.replaceAll(RegExp(r"."), "*"), style: const TextStyle(fontSize: 30, letterSpacing: 10)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 15, runSpacing: 15, alignment: WrapAlignment.center,
            children: List.generate(10, (i) {
              String n = "$i";
              if (i == 9) n = "0";
              if (i == 9) {}
              String label = (i + 1).toString();
              if (i == 9) label = "0";
              if (i == 8) label = "9";
              if (i == 9) label = "0";
              // numeri 1-9,0
              String txt = i == 9? "0" : "${i + 1}";
              return InkWell(
                onTap: () {
                  setState(() => pin += txt);
                  if (pin.length == 4) {
                    if (pin == AppConfig.appPin) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
                    } else {
                      setState(() => pin = "");
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errato! Giusto: ${AppConfig.appPin}")));
                    }
                  }
                },
                child: Container(width: 65, height: 65, decoration: const BoxDecoration(color: Color(0xFF222222), shape: BoxShape.circle), child: Center(child: Text(txt, style: const TextStyle(fontSize: 22)))),
              );
            }),
          )
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
  int index = 0;
  final String myId = "${Random().nextInt(9000) + 1000}";
  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [ChatPage(myId: myId), const VaultPage(), const VoicePage(), const SettingsPage()];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black, type: BottomNavigationBarType.fixed, selectedItemColor: Colors.white, unselectedItemColor: Colors.white38,
        currentIndex: index, onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Segreta"),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: "Voce"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Impostazioni"),
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String myId;
  const ChatPage({super.key, required this.myId});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, String>> contacts = [];
  List<Map<String, dynamic>> msgs = [];
  String? active;
  final idC = TextEditingController();
  final nameC = TextEditingController();
  final msgC = TextEditingController();
  bool hide = true;

  void addContact() {
    if (idC.text.isEmpty || nameC.text.isEmpty) return;
    setState(() {
      contacts.add({"id": idC.text.trim(), "name": nameC.text.trim()});
      active = idC.text.trim();
      msgs = [{"text": "Chat con ${nameC.text} - Key ${AppConfig.encryptionKey}", "me": false}];
    });
    idC.clear(); nameC.clear();
  }

  void send() {
    if (msgC.text.isEmpty || active == null) return;
    setState(() => msgs.add({"text": "[${AppConfig.encryptionKey}] ${msgC.text}", "me": true}));
    msgC.clear();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => msgs.add({"text": "Risposta criptata con ${AppConfig.encryptionKey}", "me": false}));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${AppConfig.username} ID:${widget.myId}"), backgroundColor: Colors.black, actions: [IconButton(icon: const Icon(Icons.visibility), onPressed: () => setState(() => hide =!hide))]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(8), child: Row(children: [
          Expanded(child: TextField(controller: nameC, decoration: const InputDecoration(hintText: "Nome", filled: true, isDense: true))),
          const SizedBox(width: 5),
          Expanded(child: TextField(controller: idC, decoration: const InputDecoration(hintText: "ID", filled: true, isDense: true))),
          IconButton(onPressed: addContact, icon: const Icon(Icons.add))
        ])),
        Expanded(child: ListView.builder(padding: const EdgeInsets.all(10), itemCount: msgs.length, itemBuilder: (_, i) {
          bool me = msgs[i]["me"] == true;
          return Align(alignment: me? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.symmetric(vertical: 4), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: me? Colors.white : Colors.white12, borderRadius: BorderRadius.circular(12)), child: Text(msgs[i]["text"], style: TextStyle(color: me? Colors.black : Colors.white))));
        })),
        Padding(padding: const EdgeInsets.all(8), child: Row(children: [Expanded(child: TextField(controller: msgC, decoration: const InputDecoration(hintText: "Messaggio"))), IconButton(icon: const Icon(Icons.send), onPressed: send)]))
      ]),
    );
  }
}

class VaultPage extends StatefulWidget { const VaultPage({super.key}); @override State<VaultPage> createState() => _VaultPageState(); }
class _VaultPageState extends State<VaultPage> {
  bool open = false; String pin = "";
  @override
  Widget build(BuildContext context) {
    if (!open) {
      return Scaffold(backgroundColor: Colors.black, appBar: AppBar(title: const Text("Cartella Segreta"), backgroundColor: Colors.black), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("Pin: ${AppConfig.vaultPin}", style: const TextStyle(color: Colors.white54)),
        const SizedBox(height: 10),
        Text(pin.replaceAll(RegExp(r"."), "*"), style: const TextStyle(fontSize: 28)),
        Wrap(spacing: 12, children: List.generate(10, (i) { String t = i == 9? "0" : "${i + 1}"; return InkWell(onTap: () { setState(() => pin += t); if (pin.length == 4) { if (pin == AppConfig.vaultPin) setState(() => open = true); else setState(() => pin = ""); } }, child: Container(width: 60, height: 60, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF222222)), child: Center(child: Text(t)))); }))
      ])));
    }
    return Scaffold(appBar: AppBar(title: const Text("Cartella Segreta OK"), backgroundColor: Colors.black, actions: [IconButton(icon: const Icon(Icons.lock), onPressed: () => setState(() => open = false))]), body: GridView.builder(padding: const EdgeInsets.all(12), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8), itemCount: 6, itemBuilder: (_, i) => Container(decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.lock))));
  }
}

class VoicePage extends StatefulWidget { const VoicePage({super.key}); @override State<VoicePage> createState() => _VoicePageState(); }
class _VoicePageState extends State<VoicePage> {
  bool hasMic = false; bool rec = false;
  Future<void> askMic() async { var s = await Permission.microphone.request(); setState(() => hasMic = s.isGranted); }
  @override
  void initState() { super.initState(); askMic(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cambia Voce"), backgroundColor: Colors.black),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (!hasMic) ElevatedButton(onPressed: askMic, child: const Text("AUTORIZZA MICROFONO")),
        if (hasMic) Text("Microfono OK - Effetto: ${AppConfig.voiceEffect}", style: const TextStyle(color: Colors.greenAccent)),
        const SizedBox(height: 20),
        Wrap(spacing: 8, children: ["Robot", "Scoiattolo", "Gigante", "Alieno"].map((e) => ChoiceChip(label: Text(e), selected: AppConfig.voiceEffect == e, onSelected: (_) => setState(() => AppConfig.voiceEffect = e))).toList()),
        const SizedBox(height: 20),
        Slider(value: AppConfig.pitch, min: -10, max: 10, onChanged: (v) => setState(() => AppConfig.pitch = v)),
        const SizedBox(height: 20),
        GestureDetector(onTapDown: (_) => setState(() => rec = true), onTapUp: (_) => setState(() => rec = false), child: Container(width: 100, height: 100, decoration: BoxDecoration(color: rec? Colors.red : Colors.white, shape: BoxShape.circle), child: Icon(rec? Icons.stop : Icons.mic, color: Colors.black, size: 40))),
        const SizedBox(height: 10),
        Text(rec? "Registrazione..." : "Tieni premuto per parlare")
      ])),
    );
  }
}

class SettingsPage extends StatefulWidget { const SettingsPage({super.key}); @override State<SettingsPage> createState() => _SettingsPageState(); }
class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController u = TextEditingController(text: AppConfig.username);
  late TextEditingController k = TextEditingController(text: AppConfig.encryptionKey);
  late TextEditingController ap = TextEditingController(text: AppConfig.appPin);
  late TextEditingController vp = TextEditingController(text: AppConfig.vaultPin);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Impostazioni"), backgroundColor: Colors.black),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text("PROFILO E CHIAVE"),
        TextField(controller: u, decoration: const InputDecoration(labelText: "Nome Utente")),
        const SizedBox(height: 10),
        TextField(controller: k, decoration: const InputDecoration(labelText: "Chiave Crittografia", prefixIcon: Icon(Icons.vpn_key))),
        const SizedBox(height: 20),
        const Text("SICUREZZA"),
        TextField(controller: ap, decoration: const InputDecoration(labelText: "Pin App (4 cifre)"), maxLength: 4, keyboardType: TextInputType.number),
        TextField(controller: vp, decoration: const InputDecoration(labelText: "Pin Cartella Segreta (4 cifre)"), maxLength: 4, keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: () { setState(() { AppConfig.username = u.text; AppConfig.encryptionKey = k.text; AppConfig.appPin = ap.text; AppConfig.vaultPin = vp.text; }); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Salvato!"))); }, child: const Text("SALVA TUTTO"))
      ]),
    );
  }
}
