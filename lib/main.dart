import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const SecureCryptApp());

class SecureCryptApp extends StatelessWidget {
  const SecureCryptApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Color(0xFF0F0F0F)),
      home: const LockScreen(),
    );
  }
}

// ===== BLOCCO ACCESSO APP =====
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});
  @override
  State<LockScreen> createState() => _LockScreenState();
}
class _LockScreenState extends State<LockScreen> {
  String pin = "";
  final String correctPin = "1234"; // CODICE ACCESSO APP - cambialo qui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.lock, size: 70, color: Colors.white),
        SizedBox(height: 20),
        Text("SecureCrypt", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text("Inserisci codice accesso", style: TextStyle(color: Colors.white54)),
        SizedBox(height: 20),
        Text(pin.replaceAll(RegExp(r"."), "●"), style: TextStyle(fontSize: 30, letterSpacing: 10)),
        SizedBox(height: 20),
        Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: List.generate(10, (i) {
          String n = i==9? "0" : "${i+1}";
          if(i==9) n="0";
          if(i==10) return SizedBox();
          return GestureDetector(
            onTap: () {
              setState(() => pin+=n);
              if(pin.length==4){
                if(pin==correctPin){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainShell()));
                } else {
                  setState(() => pin="");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Codice errato! Prova 1234")));
                }
              }
            },
            child: Container(width: 70, height: 70, decoration: BoxDecoration(color: Color(0xFF1E1E1E), shape: BoxShape.circle), child: Center(child: Text(n, style: TextStyle(fontSize: 24)))),
          );
        })),
        TextButton(onPressed: () => setState(()=> pin=""), child: Text("Cancella", style: TextStyle(color: Colors.white54)))
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
  int _index = 0;
  final String myId = "${Random().nextInt(9000)+1000}-${Random().nextInt(9000)+1000}";
  @override
  Widget build(BuildContext context) {
    final pages = [ChatWithIdPage(myId: myId), VaultPage(), VoiceChangerPage()];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        currentIndex: _index,
        onTap: (i) => setState(()=> _index=i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat ID"),
          BottomNavigationBarItem(icon: Icon(Icons.folder_special), label: "Segreta"),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: "Voce"),
        ],
      ),
    );
  }
}

// ===== 1. CHAT CON CHIAMATA + MASCHERAMENTO =====
class ChatWithIdPage extends StatefulWidget {
  final String myId;
  const ChatWithIdPage({super.key, required this.myId});
  @override
  State<ChatWithIdPage> createState() => _ChatWithIdPageState();
}
class _ChatWithIdPageState extends State<ChatWithIdPage> {
  List<Map<String,String>> contacts = [];
  List<Map<String,dynamic>> messages = [];
  String? activeId;
  final idCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final msgCtrl = TextEditingController();
  bool hideMessages = true; // mascheramento automatico

  void _addContact(){
    if(idCtrl.text.isEmpty||nameCtrl.text.isEmpty) return;
    setState((){
      contacts.add({"id": idCtrl.text.trim(), "name": nameCtrl.text.trim()});
      activeId=idCtrl.text.trim();
      messages=[{"text": "Chat criptata avviata con ${nameCtrl.text}", "me": false, "hidden": false}];
    });
    idCtrl.clear(); nameCtrl.clear();
  }
  void _send(){
    if(msgCtrl.text.isEmpty||activeId==null) return;
    setState(()=> messages.add({"text": msgCtrl.text.trim(), "me": true, "hidden": false}));
    msgCtrl.clear();
    Future.delayed(Duration(milliseconds: 800), ()=> setState(()=> messages.add({"text": "Messaggio ricevuto - decrittato", "me": false, "hidden": true})));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Chat Segreta", style: TextStyle(fontSize: 16)),
          Text("ID: ${widget.myId} • ${activeId??'nessun contatto'}", style: TextStyle(fontSize: 10, color: Colors.greenAccent)),
        ]),
        actions: [
          IconButton(icon: Icon(Icons.visibility), onPressed: ()=> setState(()=> hideMessages=!hideMessages)),
          IconButton(icon: Icon(Icons.call, color: Colors.greenAccent), onPressed: activeId==null? null : (){
            Navigator.push(context, MaterialPageRoute(builder: (_) => CallPage(contactName: contacts.firstWhere((c)=>c["id"]==activeId)["name"]!)));
          }),
        ],
      ),
      body: Column(children: [
        Container(color: Color(0xFF1A1A1A), padding: EdgeInsets.all(8), child: Row(children: [
          Expanded(child: TextField(controller: nameCtrl, style: TextStyle(fontSize: 12), decoration: InputDecoration(hintText: "Nome", isDense:true, filled:true, fillColor: Color(0xFF2A2A2A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)))),
          SizedBox(width:5),
          Expanded(child: TextField(controller: idCtrl, style: TextStyle(fontSize: 12), decoration: InputDecoration(hintText: "Codice ID", isDense:true, filled:true, fillColor: Color(0xFF2A2A2A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)))),
          IconButton(onPressed: _addContact, icon: Icon(Icons.add))
        ])),
        Expanded(child: activeId==null? Center(child: Text("Aggiungi utente con Nome + Codice ID", style: TextStyle(color: Colors.white54))) :
          ListView.builder(padding: EdgeInsets.all(12), itemCount: messages.length, itemBuilder: (_,i){
            final m=messages[i];
            bool isMe=m["me"]==true;
            bool isHidden =!isMe && hideMessages && (m["hidden"]==true);
            return Align(alignment: isMe? Alignment.centerRight: Alignment.centerLeft, child: GestureDetector(
              onTap: (){ if(isHidden) setState(()=> messages[i]["hidden"]=false); },
              child: Container(margin: EdgeInsets.symmetric(vertical:4), padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: isMe? Colors.white: Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(16)),
                child: Text(isHidden? "•••••••• 🔒 Tocca per mostrare" : m["text"], style: TextStyle(color: isMe? Colors.black: Colors.white, fontStyle: isHidden? FontStyle.italic: FontStyle.normal)),
              ),
            ));
          })
        ),
        Container(padding: EdgeInsets.all(8), color: Colors.black, child: Row(children: [
          Expanded(child: TextField(controller: msgCtrl, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Messaggio criptato...", filled:true, fillColor: Color(0xFF1E1E1E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none)))),
          SizedBox(width:8),
          CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: Icon(Icons.send, color: Colors.black), onPressed: _send))
        ]))
      ]),
    );
  }
}

class CallPage extends StatefulWidget {
  final String contactName;
  const CallPage({super.key, required this.contactName});
  @override
  State<CallPage> createState() => _CallPageState();
}
class _CallPageState extends State<CallPage> {
  String voice = "Robot";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircleAvatar(radius: 50, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 50)),
        SizedBox(height: 16),
        Text(widget.contactName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text("Chiamata criptata • Voce: $voice", style: TextStyle(color: Colors.greenAccent)),
        SizedBox(height: 40),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircleAvatar(backgroundColor: Colors.white24, radius: 30, child: IconButton(icon: Icon(Icons.mic_off), onPressed: (){})),
          SizedBox(width: 20),
          CircleAvatar(backgroundColor: Colors.red, radius: 35, child: IconButton(icon: Icon(Icons.call_end, color: Colors.white), onPressed: ()=> Navigator.pop(context))),
          SizedBox(width: 20),
          CircleAvatar(backgroundColor: Colors.white24, radius: 30, child: IconButton(icon: Icon(Icons.record_voice_over), onPressed: (){
            showModalBottomSheet(context: context, builder: (_) => Container(color: Color(0xFF1E1E1E), height: 200, child: ListView(children: ["Normale","Robot","Scoiattolo","Gigante","Alieno"].map((v)=> ListTile(title: Text(v), onTap: (){ setState(()=> voice=v); Navigator.pop(context);})).toList())));
          })),
        ])
      ])),
    );
  }
}

// ===== 2. CARTELLA SEGRETA CON CODICE =====
class VaultPage extends StatefulWidget {
  const VaultPage({super.key});
  @override
  State<VaultPage> createState() => _VaultPageState();
}
class _VaultPageState extends State<VaultPage> {
  bool unlocked = false;
  String pin = "";
  final String vaultPin = "0000"; // CODICE CARTELLA SEGRETA
  List<String> files = ["foto_1.jpg","video_1.mp4","foto_2.jpg"];

  Widget buildLock(){
    return Scaffold(backgroundColor: Colors.black, appBar: AppBar(backgroundColor: Colors.black, title: Text("Cartella Segreta 🔒")),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.folder_special, size: 60),
        SizedBox(height:12),
        Text("Inserisci codice cartella", style: TextStyle(color: Colors.white54)),
        SizedBox(height:12),
        Text(pin.replaceAll(RegExp(r"."), "●"), style: TextStyle(fontSize: 28, letterSpacing: 8)),
        Wrap(spacing:10, runSpacing:10, alignment: WrapAlignment.center, children: List.generate(10, (i){
          String n = i==9? "0" : "${i+1}"; if(i==9) n="0";
          return GestureDetector(onTap: (){
            setState(()=> pin+=n);
            if(pin.length==4){
              if(pin==vaultPin) setState(()=> unlocked=true);
              else { setState(()=> pin=""); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Codice segreto errato! Prova 0000"))); }
            }
          }, child: Container(width:65,height:65,decoration: BoxDecoration(color: Color(0xFF1E1E1E), shape: BoxShape.circle), child: Center(child: Text(n, style: TextStyle(fontSize:22)))));
        })),
      ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(!unlocked) return buildLock();
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black, title: Text("Cartella Segreta"), actions: [IconButton(icon: Icon(Icons.lock), onPressed: ()=> setState(()=> unlocked=false))]),
      body: GridView.builder(padding: EdgeInsets.all(12), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing:8, mainAxisSpacing:8),
        itemCount: files.length+1,
        itemBuilder: (_,i){
          if(i==files.length) return GestureDetector(onTap: ()=> setState(()=> files.add("nuovo_${files.length}.jpg")), child: Container(decoration: BoxDecoration(color: Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.add)));
          return Container(decoration: BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(files[i].contains("video")? Icons.videocam: Icons.image, color: Colors.white70), Text(files[i], style: TextStyle(fontSize:9, color: Colors.white54)), Icon(Icons.lock, size:10, color: Colors.greenAccent)]));
        }),
    );
  }
}

// ===== 3. CAMBIA VOCE =====
class VoiceChangerPage extends StatefulWidget {
  const VoiceChangerPage({super.key});
  @override
  State<VoiceChangerPage> createState() => _VoiceChangerPageState();
}
class _VoiceChangerPageState extends State<VoiceChangerPage> {
  double pitch = 0;
  bool rec = false;
  String sel = "Robot";
  final voices = ["Normale","Robot","Scoiattolo","Gigante","Alieno","Bambino"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black, title: Text("Cambia Voce 🎙️")),
      body: Padding(padding: EdgeInsets.all(20), child: Column(children: [
        Wrap(spacing:8, children: voices.map((v)=> ChoiceChip(label: Text(v), selected: sel==v, selectedColor: Colors.white, labelStyle: TextStyle(color: sel==v? Colors.black: Colors.white), onSelected: (_)=> setState(()=> sel=v))).toList()),
        SizedBox(height:20),
        Text("Pitch ${pitch.toStringAsFixed(1)} - Effetto: $sel", style: TextStyle(color: Colors.white70)),
        Slider(value: pitch, min: -10, max: 10, activeColor: Colors.white, onChanged: (v)=> setState(()=> pitch=v)),
        Spacer(),
        GestureDetector(onTapDown: (_)=> setState(()=> rec=true), onTapUp: (_)=> setState(()=> rec=false), child: AnimatedContainer(duration: Duration(milliseconds:200), width: rec? 130:90, height: rec? 130:90, decoration: BoxDecoration(color: rec? Colors.red: Colors.white, shape: BoxShape.circle), child: Icon(rec? Icons.stop: Icons.mic, size: 40, color: rec? Colors.white: Colors.black))),
        SizedBox(height:12),
        Text(rec? "Registrazione con voce $sel..." : "Tieni premuto - Verrà usato in chiamata", style: TextStyle(color: Colors.white54)),
        Spacer(),
      ])),
    );
  }
}
