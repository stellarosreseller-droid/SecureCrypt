import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const SecureCryptApp());

class AppConfig {
  static String username = "Utente_Segreto";
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
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Color(0xFF0F0F0F)), home: const LockScreen());
  }
}

class LockScreen extends StatefulWidget { const LockScreen({super.key}); @override State<LockScreen> createState() => _LockScreenState(); }
class _LockScreenState extends State<LockScreen> {
  String pin = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black, body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.lock, size: 70), SizedBox(height: 12),
      Text("SecureCrypt", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      Text("${AppConfig.username} | Key: ${AppConfig.encryptionKey}", style: TextStyle(fontSize: 11, color: Colors.greenAccent)),
      SizedBox(height: 12), Text(pin.replaceAll(RegExp(r"."), "●"), style: TextStyle(fontSize: 32, letterSpacing: 12)), SizedBox(height: 20),
      Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: List.generate(10, (i){
        String n = i==9?"0":"${i+1}"; if(i==9) n="0";
        return GestureDetector(onTap: (){ setState(()=> pin+=n); if(pin.length==4){ if(pin==AppConfig.appPin) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> MainShell())); else { setState(()=> pin=""); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Codice errato, è ${AppConfig.appPin}"))); } } }, child: Container(width: 70, height: 70, decoration: BoxDecoration(color: Color(0xFF1E1E1E), shape: BoxShape.circle), child: Center(child: Text(n, style: TextStyle(fontSize: 24)))));
      })), TextButton(onPressed: ()=> setState(()=> pin=""), child: Text("Cancella"))
    ])));
  }
}

class MainShell extends StatefulWidget { const MainShell({super.key}); @override State<MainShell> createState() => _MainShellState(); }
class _MainShellState extends State<MainShell> {
  int _index = 0;
  final String myId = "${Random().nextInt(9000)+1000}-${Random().nextInt(9000)+1000}";
  @override
  Widget build(BuildContext context) {
    final pages = [ChatWithIdPage(myId: myId), VaultPage(), VoiceChangerPage(), SettingsPage()];
    return Scaffold(body: pages[_index], bottomNavigationBar: BottomNavigationBar(backgroundColor: Colors.black, selectedItemColor: Colors.white, unselectedItemColor: Colors.white38, currentIndex: _index, onTap: (i)=> setState(()=> _index=i), type: BottomNavigationBarType.fixed, items: const [BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"), BottomNavigationBarItem(icon: Icon(Icons.folder_special), label: "Segreta"), BottomNavigationBarItem(icon: Icon(Icons.mic), label: "Voce"), BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Impostazioni")]));
  }
}

class ChatWithIdPage extends StatefulWidget { final String myId; const ChatWithIdPage({super.key, required this.myId}); @override State<ChatWithIdPage> createState() => _ChatWithIdPageState(); }
class _ChatWithIdPageState extends State<ChatWithIdPage> {
  List<Map<String,String>> contacts = []; List<Map<String,dynamic>> messages = []; String? activeId;
  final idCtrl = TextEditingController(); final nameCtrl = TextEditingController(); final msgCtrl = TextEditingController(); bool hideMessages = true;
  void _addContact(){ if(idCtrl.text.isEmpty||nameCtrl.text.isEmpty) return; setState((){ contacts.add({"id": idCtrl.text.trim(), "name": nameCtrl.text.trim()}); activeId=idCtrl.text.trim(); messages=[{"text": "Chat con ${nameCtrl.text} | Key: ${AppConfig.encryptionKey}", "me": false, "hidden": false}]; }); idCtrl.clear(); nameCtrl.clear(); }
  void _send(){ if(msgCtrl.text.isEmpty||activeId==null) return; setState(()=> messages.add({"text": "[${AppConfig.encryptionKey}] ${msgCtrl.text.trim()}", "me": true, "hidden": false})); msgCtrl.clear(); Future.delayed(Duration(milliseconds: 700), ()=> setState(()=> messages.add({"text": "Messaggio decrittato con ${AppConfig.encryptionKey}", "me": false, "hidden": true}))); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(backgroundColor: Colors.black, title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${AppConfig.username} - Chat", style: TextStyle(fontSize: 15)), Text("ID: ${widget.myId} • Key: ${AppConfig.encryptionKey}", style: TextStyle(fontSize: 9, color: Colors.greenAccent))]), actions: [IconButton(icon: Icon(Icons.visibility), onPressed: ()=> setState(()=> hideMessages=!hideMessages)), IconButton(icon: Icon(Icons.call, color: Colors.greenAccent), onPressed: activeId==null? null : ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> CallPage(contactName: contacts.firstWhere((c)=>c["id"]==activeId)["name"]!))))]),
      body: Column(children: [Container(color: Color(0xFF1A1A1A), padding: EdgeInsets.all(8), child: Row(children: [Expanded(child: TextField(controller: nameCtrl, style: TextStyle(fontSize: 12), decoration: InputDecoration(hintText: "Nome", isDense:true, filled:true, fillColor: Color(0xFF2A2A2A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)))), SizedBox(width:5), Expanded(child: TextField(controller: idCtrl, style: TextStyle(fontSize: 12), decoration: InputDecoration(hintText: "Codice ID", isDense:true, filled:true, fillColor: Color(0xFF2A2A2A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)))), IconButton(onPressed: _addContact, icon: Icon(Icons.add)) ])), Expanded(child: activeId==null? Center(child: Text("Aggiungi utente", style: TextStyle(color: Colors.white54))) : ListView.builder(padding: EdgeInsets.all(12), itemCount: messages.length, itemBuilder: (_,i){ final m=messages[i]; bool isMe=m["me"]==true; bool isHidden=!isMe && hideMessages && (m["hidden"]==true); return Align(alignment: isMe? Alignment.centerRight: Alignment.centerLeft, child: GestureDetector(onTap: (){ if(isHidden) setState(()=> messages[i]["hidden"]=false); }, child: Container(margin: EdgeInsets.symmetric(vertical:4), padding: EdgeInsets.all(12), decoration: BoxDecoration(color: isMe? Colors.white: Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(16)), child: Text(isHidden? "•••••••• 🔒 Tocca" : m["text"], style: TextStyle(color: isMe? Colors.black: Colors.white)))) ;})), Container(padding: EdgeInsets.all(8), color: Colors.black, child: Row(children: [Expanded(child: TextField(controller: msgCtrl, decoration: InputDecoration(hintText: "Messaggio...", filled:true, fillColor: Color(0xFF1E1E1E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none)))), SizedBox(width:8), CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: Icon(Icons.send, color: Colors.black), onPressed: _send))]))]));
  }
}

class CallPage extends StatelessWidget { final String contactName; const CallPage({super.key, required this.contactName}); @override Widget build(BuildContext context){ return Scaffold(backgroundColor: Colors.black, body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(radius: 50, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 50)), SizedBox(height: 16), Text(contactName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), Text("Voce: ${AppConfig.voiceEffect} • Pitch ${AppConfig.pitch}", style: TextStyle(color: Colors.greenAccent, fontSize: 12)), SizedBox(height: 40), CircleAvatar(backgroundColor: Colors.red, radius: 35, child: IconButton(icon: Icon(Icons.call_end, color: Colors.white), onPressed: ()=> Navigator.pop(context)))]))); } }

class VaultPage extends StatefulWidget { const VaultPage({super.key}); @override State<VaultPage> createState() => _VaultPageState(); }
class _VaultPageState extends State<VaultPage> {
  bool unlocked = false; String pin = ""; List<String> files = ["foto_1.jpg","video_1.mp4"];
  Widget buildLock(){ return Scaffold(backgroundColor: Colors.black, appBar: AppBar(backgroundColor: Colors.black, title: Text("Cartella Segreta 🔒")), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.folder_special, size: 60), SizedBox(height:12), Text("Codice: ${AppConfig.vaultPin}", style: TextStyle(color: Colors.white30, fontSize: 11)), SizedBox(height:12), Text(pin.replaceAll(RegExp(r"."), "●"), style: TextStyle(fontSize: 28, letterSpacing: 8)), Wrap(spacing:10, runSpacing:10, alignment: WrapAlignment.center, children: List.generate(10, (i){ String n = i==9?"0":"${i+1}"; if(i==9) n="0"; return GestureDetector(onTap: (){ setState(()=> pin+=n); if(pin.length==4){ if(pin==AppConfig.vaultPin) setState(()=> unlocked=true); else { setState(()=> pin=""); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errato! Cod: ${AppConfig.vaultPin}"))); } } }, child: Container(width:65,height:65,decoration: BoxDecoration(color: Color(0xFF1E1E1E), shape: BoxShape.circle), child: Center(child: Text(n, style: TextStyle(fontSize:22))))); })),]))); }
  @override Widget build(BuildContext context){ if(!unlocked) return buildLock(); return Scaffold(appBar: AppBar(backgroundColor: Colors.black, title: Text("Cartella Segreta"), actions: [IconButton(icon: Icon(Icons.lock), onPressed: ()=> setState(()=> unlocked=false))]), body: GridView.builder(padding: EdgeInsets.all(12), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing:8, mainAxisSpacing:8), itemCount: files.length+1, itemBuilder: (_,i){ if(i==files.length) return GestureDetector(onTap: ()=> setState(()=> files.add("nuovo_${files.length}.jpg")), child: Container(decoration: BoxDecoration(color: Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.add))); return Container(decoration: BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(files[i].contains("video")? Icons.videocam: Icons.image, color: Colors.white70), Text(files[i], style: TextStyle(fontSize:9)), Icon(Icons.lock, size:10, color: Colors.greenAccent)])); })); }
}

class VoiceChangerPage extends StatefulWidget { const VoiceChangerPage({super.key}); @override State<VoiceChangerPage> createState() => _VoiceChangerPageState(); }
class _VoiceChangerPageState extends State<VoiceChangerPage> {
  bool rec = false; bool hasPermission = false; final voices = ["Normale","Robot","Scoiattolo","Gigante","Alieno","Bambino"];
  Future<void> checkPermission() async { var status = await Permission.microphone.status; if(!status.isGranted){ status = await Permission.microphone.request(); } setState(()=> hasPermission = status.isGranted); if(!status.isGranted){ if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Permesso negato! Vai in Impostazioni telefono > App > SecureCrypt > Autorizza microfono"))); } }
  @override void initState(){ super.initState(); checkPermission(); }
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(backgroundColor: Colors.black, title: Text("Cambia Voce 🎙️"), actions: [IconButton(icon: Icon(Icons.mic), onPressed: checkPermission)]),
      body: Padding(padding: EdgeInsets.all(20), child: Column(children: [
        if(!hasPermission) Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red)), child: Row(children: [Icon(Icons.warning, color: Colors.red), SizedBox(width:8), Expanded(child: Text("Microfono NON autorizzato", style: TextStyle(color: Colors.white))), TextButton(onPressed: checkPermission, child: Text("AUTORIZZA"))])),
        SizedBox(height:10), Wrap(spacing:8, children: voices.map((v)=> ChoiceChip(label: Text(v), selected: AppConfig.voiceEffect==v, selectedColor: Colors.white, labelStyle: TextStyle(color: AppConfig.voiceEffect==v? Colors.black: Colors.white), onSelected: (_)=> setState(()=> AppConfig.voiceEffect=v))).toList()),
        SizedBox(height:20), Text("Pitch ${AppConfig.pitch.toStringAsFixed(1)} - Effetto: ${AppConfig.voiceEffect}", style: TextStyle(color: Colors.white70)), Slider(value: AppConfig.pitch, min: -10, max: 10, activeColor: Colors.white, onChanged: (v)=> setState(()=> AppConfig.pitch=v)),
        Spacer(),
        GestureDetector(onTapDown: (_) async { await checkPermission(); if(hasPermission) setState(()=> rec=true); }, onTapUp: (_)=> setState(()=> rec=false), child: AnimatedContainer(duration: Duration(milliseconds:200), width: rec? 130:90, height: rec? 130:90, decoration: BoxDecoration(color: rec? Colors.red: (hasPermission? Colors.white: Colors.grey), shape: BoxShape.circle), child: Icon(rec? Icons.stop: Icons.mic, size: 40, color: rec? Colors.white: Colors.black))),
        SizedBox(height:12), Text(!hasPermission? "Premi AUTORIZZA" : rec? "Registrazione con ${AppConfig.voiceEffect}..." : "Tieni premuto - Usato in chiamata", style: TextStyle(color: Colors.white54)), Spacer(),
      ])));
  }
}

class SettingsPage extends StatefulWidget { const SettingsPage({super.key}); @override State<SettingsPage> createState() => _SettingsPageState(); }
class _SettingsPageState extends State<SettingsPage> {
  final userCtrl = TextEditingController(text: AppConfig.username); final keyCtrl = TextEditingController(text: AppConfig.encryptionKey); final appPinCtrl = TextEditingController(text: AppConfig.appPin); final vaultPinCtrl = TextEditingController(text: AppConfig.vaultPin);
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(backgroundColor: Colors.black, title: Text("Impostazioni ⚙️")), body: ListView(padding: EdgeInsets.all(16), children: [
      Text("PROFILO", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)), SizedBox(height:8),
      TextField(controller: userCtrl, decoration: InputDecoration(labelText: "Nome Utente", filled:true, fillColor: Color(0xFF1E1E1E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: Icon(Icons.person))),
      SizedBox(height:12),
      TextField(controller: keyCtrl, decoration: InputDecoration(labelText: "Chiave di Crittografia", filled:true, fillColor: Color(0xFF1E1E1E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: Icon(Icons.vpn_key), suffixIcon: Icon(Icons.lock, color: Colors.greenAccent))),
      SizedBox(height:20), Text("SICUREZZA", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)), SizedBox(height:8),
      TextField(controller: appPinCtrl, maxLength: 4, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Codice Accesso App (4 cifre)", filled:true, fillColor: Color(0xFF1E1E1E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: Icon(Icons.lock_outline), counterText: "")),
      SizedBox(height:12),
      TextField(controller: vaultPinCtrl, maxLength: 4, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Codice Cartella Segreta (4 cifre)", filled:true, fillColor: Color(0xFF1E1E1E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: Icon(Icons.folder_special))),
      SizedBox(height:24),
      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: (){ setState((){ AppConfig.username = userCtrl.text.trim().isEmpty? AppConfig.username : userCtrl.text.trim(); AppConfig.encryptionKey = keyCtrl.text.trim().isEmpty? AppConfig.encryptionKey : keyCtrl.text.trim(); AppConfig.appPin = appPinCtrl.text.trim().length==4? appPinCtrl.text.trim() : AppConfig.appPin; AppConfig.vaultPin = vaultPinCtrl.text.trim().length==4? vaultPinCtrl.text.trim() : AppConfig.vaultPin; }); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Salvato! Utente: ${AppConfig.username} | Key: ${AppConfig.encryptionKey} | AppPin: ${AppConfig.appPin} | VaultPin: ${AppConfig.vaultPin}"))); }, child: Text("SALVA TUTTO", style: TextStyle(fontWeight: FontWeight.bold))),
    ]));
  }
}
