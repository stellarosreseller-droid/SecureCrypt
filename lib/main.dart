import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const SecureCryptApp());

class SecureCryptApp extends StatelessWidget {
  const SecureCryptApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SecureCrypt',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Color(0xFF0F0F0F)),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final String myId = "${Random().nextInt(9000)+1000}-${Random().nextInt(9000)+1000}";

  final pages = <Widget>[];

  @override
  void initState() {
    super.initState();
    pages.addAll([
      ChatWithIdPage(myId: myId),
      const VaultPage(),
      const VoiceChangerPage(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Chat ID"),
          BottomNavigationBarItem(icon: Icon(Icons.folder_special), label: "Cartella Segreta"),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: "Cambia Voce"),
        ],
      ),
    );
  }
}

// ============== 1. CHAT CON CODICE ID ==============
class ChatWithIdPage extends StatefulWidget {
  final String myId;
  const ChatWithIdPage({super.key, required this.myId});
  @override
  State<ChatWithIdPage> createState() => _ChatWithIdPageState();
}

class _ChatWithIdPageState extends State<ChatWithIdPage> {
  final List<Map<String,String>> contacts = [];
  final List<Map<String,String>> messages = [];
  String? activeContactId;
  final TextEditingController idController = TextEditingController();
  final TextEditingController msgController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  void _addContact() {
    if (idController.text.isEmpty || nameController.text.isEmpty) return;
    setState(() {
      contacts.add({"id": idController.text.trim(), "name": nameController.text.trim()});
      activeContactId = idController.text.trim();
      messages.clear();
      messages.add({"text": "Chat sicura avviata con ${nameController.text} [${idController.text}]", "me": "false"});
    });
    idController.clear();
    nameController.clear();
  }

  void _send() {
    if (msgController.text.trim().isEmpty || activeContactId == null) return;
    setState(() => messages.add({"text": msgController.text.trim(), "me": "true"}));
    msgController.clear();
    // simula risposta
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) setState(() => messages.add({"text": "Ricevuto ✔️ (criptato)", "me": "false"}));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("SecureCrypt", style: TextStyle(fontSize: 18)),
          Text("Il mio ID: ${widget.myId}", style: TextStyle(fontSize: 11, color: Colors.greenAccent)),
        ]),
        actions: [IconButton(icon: Icon(Icons.copy), onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ID copiato: ${widget.myId}")));
        })],
      ),
      body: Column(children: [
        // Aggiungi contatto
        Container(
          color: Color(0xFF1A1A1A),
          padding: EdgeInsets.all(10),
          child: Row(children: [
            Expanded(child: TextField(controller: nameController, decoration: InputDecoration(hintText: "Nome utente", isDense: true, filled: true, fillColor: Color(0xFF2A2A2A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)), style: TextStyle(fontSize: 13))),
            SizedBox(width: 6),
            Expanded(child: TextField(controller: idController, decoration: InputDecoration(hintText: "Codice ID es: 1234-5678", isDense: true, filled: true, fillColor: Color(0xFF2A2A2A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)), style: TextStyle(fontSize: 13))),
            IconButton(onPressed: _addContact, icon: Icon(Icons.person_add, color: Colors.white))
          ]),
        ),
        if (contacts.isNotEmpty)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: contacts.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => setState(() => activeContactId = contacts[i]["id"]),
                child: Container(
                  margin: EdgeInsets.all(6),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: activeContactId == contacts[i]["id"]? Colors.white : Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(child: Text(contacts[i]["name"]!, style: TextStyle(color: activeContactId == contacts[i]["id"]? Colors.black : Colors.white, fontWeight: FontWeight.bold))),
                ),
              ),
            ),
          ),
        Divider(height: 1, color: Colors.white10),
        Expanded(
          child: activeContactId == null
             ? Center(child: Text("Inserisci Nome + Codice ID per iniziare\nuna chat privata", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final m = messages[i];
                    final isMe = m["me"] == "true";
                    return Align(
                      alignment: isMe? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(color: isMe? Colors.white : Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(16)),
                        child: Text(m["text"]!, style: TextStyle(color: isMe? Colors.black : Colors.white)),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: EdgeInsets.all(8),
          color: Colors.black,
          child: Row(children: [
            Expanded(child: TextField(controller: msgController, decoration: InputDecoration(hintText: "Messaggio...", filled: true, fillColor: Color(0xFF1E1E1E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none)), style: TextStyle(color: Colors.white))),
            SizedBox(width: 8),
            CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: Icon(Icons.send, color: Colors.black), onPressed: _send))
          ]),
        )
      ]),
    );
  }
}

// ============== 2. CARTELLA SEGRETA ==============
class VaultPage extends StatefulWidget {
  const VaultPage({super.key});
  @override
  State<VaultPage> createState() => _VaultPageState();
}
class _VaultPageState extends State<VaultPage> {
  List<String> hidden = ["foto_001.jpg", "video_002.mp4", "foto_003.jpg"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black, title: Text("Cartella Segreta 🔒"), actions: [Icon(Icons.visibility_off)]),
      body: Column(children: [
        Container(padding: EdgeInsets.all(16), color: Color(0xFF1A1A1A), child: Row(children: [
          Icon(Icons.shield, color: Colors.greenAccent),
          SizedBox(width: 10),
          Expanded(child: Text("${hidden.length} file nascosti e criptati", style: TextStyle(color: Colors.white70)))
        ])),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: hidden.length + 1,
            itemBuilder: (_, i) {
              if (i == hidden.length) {
                return GestureDetector(
                  onTap: () => setState(() => hidden.add("nuovo_${hidden.length}.jpg")),
                  child: Container(decoration: BoxDecoration(color: Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)), child: Icon(Icons.add, color: Colors.white54, size: 40)),
                );
              }
              return Container(
                decoration: BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(hidden[i].contains("video")? Icons.videocam : Icons.image, color: Colors.white70),
                  SizedBox(height: 6),
                  Text(hidden[i], style: TextStyle(fontSize: 10, color: Colors.white54), overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Icon(Icons.lock, size: 12, color: Colors.greenAccent)
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ============== 3. CAMBIA VOCE ==============
class VoiceChangerPage extends StatefulWidget {
  const VoiceChangerPage({super.key});
  @override
  State<VoiceChangerPage> createState() => _VoiceChangerPageState();
}
class _VoiceChangerPageState extends State<VoiceChangerPage> {
  double pitch = 0;
  bool isRecording = false;
  String selected = "Normale";
  final voices = ["Normale", "Robot", "Scoiattolo", "Gigante", "Alieno", "Bambino"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black, title: Text("Cambia Voce 🎙️")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(children: [
          Wrap(spacing: 8, children: voices.map((v) => ChoiceChip(
            label: Text(v),
            selected: selected == v,
            selectedColor: Colors.white,
            labelStyle: TextStyle(color: selected == v? Colors.black : Colors.white),
            onSelected: (_) => setState(() => selected = v),
          )).toList()),
          SizedBox(height: 30),
          Text("Pitch: ${pitch.toStringAsFixed(1)}", style: TextStyle(color: Colors.white70)),
          Slider(value: pitch, min: -10, max: 10, activeColor: Colors.white, inactiveColor: Colors.white24, onChanged: (val) => setState(() => pitch = val)),
          Spacer(),
          GestureDetector(
            onTapDown: (_) => setState(() => isRecording = true),
            onTapUp: (_) => setState(() => isRecording = false),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: isRecording? 120 : 90,
              height: isRecording? 120 : 90,
              decoration: BoxDecoration(color: isRecording? Colors.red : Colors.white, shape: BoxShape.circle, boxShadow: [if (isRecording) BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 30, spreadRadius: 10)]),
              child: Icon(isRecording? Icons.stop : Icons.mic, size: 40, color: isRecording? Colors.white : Colors.black),
            ),
          ),
          SizedBox(height: 20),
          Text(isRecording? "Registrazione... voce $selected" : "Tieni premuto per parlare", style: TextStyle(color: Colors.white54)),
          Spacer(),
          Container(width: double.infinity, padding: EdgeInsets.all(14), decoration: BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(Icons.info_outline, color: Colors.white38), SizedBox(width: 10), Expanded(child: Text("Effetto attivo: $selected | Pitch $pitch - Verrà applicato ai messaggi vocali in chat", style: TextStyle(color: Colors.white54, fontSize: 12)))]))
        ]),
      ),
    );
  }
}
