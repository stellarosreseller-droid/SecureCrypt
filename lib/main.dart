import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const App());

class AppConfig {
  static String voice = "Gigante";
  static String pin = "1234";
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: const PinScreen());
  }
}

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});
  @override State<PinScreen> createState() => _PinScreenState();
}
class _PinScreenState extends State<PinScreen> {
  String p = "";
  @override Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black, body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Icon(Icons.lock, size: 60), const Text("SecureCrypt", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 20),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) => Container(margin: const EdgeInsets.all(6), width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: i < p.length ? Colors.white : Colors.white24)))),
    const SizedBox(height: 20),
    Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: List.generate(10, (i) {
      String t = i == 9 ? "0" : "${i+1}";
      return InkWell(onTap: () { setState(()=>p+=t); if(p.length==4){ if(p==AppConfig.pin) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const Home())); else setState(()=>p=""); } }, child: Container(width: 68, height: 68, decoration: const BoxDecoration(color: Color(0xFF222222), shape: BoxShape.circle), child: Center(child: Text(t, style: const TextStyle(fontSize: 22)))));
    }))
  ])));
}

class Home extends StatefulWidget { const Home({super.key}); @override State<Home> createState()=> _HomeState(); }
class _HomeState extends State<Home>{
 int idx=0;
 @override Widget build(BuildContext context)=>Scaffold(
  body: [const ChatList(), const VoiceChanger(), const PrivateCall()][idx],
  bottomNavigationBar: BottomNavigationBar(currentIndex: idx, onTap: (i)=>setState(()=>idx=i), backgroundColor: Colors.black, selectedItemColor: Colors.white, unselectedItemColor: Colors.white38, type: BottomNavigationBarType.fixed, items: const [
    BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
    BottomNavigationBarItem(icon: Icon(Icons.mic), label: "Voce"),
    BottomNavigationBarItem(icon: Icon(Icons.phone_in_talk), label: "Chiama in Chat"),
  ]),
 );
}

class ChatList extends StatelessWidget{
  const ChatList({super.key});
  @override Widget build(BuildContext context)=>Scaffold(appBar: AppBar(title: const Text("Chat Private"), backgroundColor: Colors.black), body: ListView(children: [
    ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: const Text("Amico 1"), subtitle: Text("Voce: ${AppConfig.voice}"), trailing: IconButton(icon: const Icon(Icons.phone, color: Colors.green), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const PrivateCall())))),
    ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: const Text("Amico 2"), subtitle: Text("Voce: ${AppConfig.voice}"), trailing: IconButton(icon: const Icon(Icons.phone, color: Colors.green), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const PrivateCall())))),
  ]));
}

class VoiceChanger extends StatefulWidget{const VoiceChanger({super.key});@override State<VoiceChanger> createState()=>_VoiceState();}
class _VoiceState extends State<VoiceChanger>{
 final rec=AudioRecorder(); final play=AudioPlayer(); bool isRec=false; String? path;
 double rate(){ switch(AppConfig.voice){ case "Scoiattolo": return 2.2; case "Gigante": return 0.5; case "Alieno": return 0.7; default: return 1.0; } }
 start()async{ await Permission.microphone.request(); final d=await getTemporaryDirectory(); path="${d.path}/v.m4a"; await rec.start(RecordConfig(), path: path!); setState(()=>isRec=true); }
 stop()async{ await rec.stop(); setState(()=>isRec=false); }
 playIt()async{ await play.setPlaybackRate(rate()); await play.play(DeviceFileSource(path!)); }
 @override Widget build(BuildContext context)=>Scaffold(appBar: AppBar(title: const Text("Effetto Voce"), backgroundColor: Colors.black), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
  Wrap(spacing:8, children: ["Robot","Scoiattolo","Gigante","Alieno"].map((e)=>ChoiceChip(label: Text(e), selected: AppConfig.voice==e, onSelected: (_)=>setState(()=>AppConfig.voice=e))).toList()),
  const SizedBox(height:20),
  GestureDetector(onLongPress: start, onLongPressUp: (_)=>stop(), child: Container(width: isRec?120:90, height: isRec?120:90, decoration: BoxDecoration(color: isRec?Colors.red:Colors.white, shape: BoxShape.circle), child: Icon(isRec?Icons.stop:Icons.mic, color: Colors.black, size: 35))),
  Text(isRec?"Parla...":"Tieni premuto"),
  const SizedBox(height:15),
  if(path!=null) ElevatedButton(onPressed: playIt, child: Text("Ascolta ${AppConfig.voice} ${rate()}x"))
 ])));
}

class PrivateCall extends StatefulWidget{const PrivateCall({super.key});@override State<PrivateCall> createState()=>_CallState();}
class _CallState extends State<PrivateCall>{
 bool inCall=false; int sec=0; Timer? t; final rec=AudioRecorder(); final play=AudioPlayer(); String? path; bool listening=false;
 double rate(){ switch(AppConfig.voice){ case "Scoiattolo": return 2.2; case "Gigante": return 0.5; case "Alieno": return 0.7; default: return 1.0; } }
 startCall()async{ await Permission.microphone.request(); setState((){inCall=true; sec=0;}); t=Timer.periodic(const Duration(seconds:1), (_)=>setState(()=>sec++)); final d=await getTemporaryDirectory(); path="${d.path}/call.m4a"; await rec.start(RecordConfig(), path: path!); }
 endCall()async{ t?.cancel(); try{await rec.stop();}catch(_){} await play.stop(); setState(()=>inCall=false); }
 playLive()async{ if(path==null)return; try{await rec.stop();}catch(_){} await play.setPlaybackRate(rate()); await play.play(DeviceFileSource(path!)); final d=await getTemporaryDirectory(); path="${d.path}/call2.m4a"; await rec.start(RecordConfig(), path: path!); }
 String fmt(int s)=>"${(s~/60).toString().padLeft(2,'0')}:${(s%60).toString().padLeft(2,'0')}";
 @override Widget build(BuildContext context){
  if(!inCall) return Scaffold(appBar: AppBar(title: const Text("Chiama in Chat"), backgroundColor: Colors.black), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green)), child: const Row(children: [Icon(Icons.verified_user, color: Colors.green, size:18), SizedBox(width:8), Expanded(child: Text("SOLO CHIAMATA IN CHAT - L'altro utente vedra': VOCE MODIFICATA CON EFFETTO", style: TextStyle(fontSize:11, color: Colors.greenAccent)))])),
    const SizedBox(height:20),
    const Icon(Icons.phone_in_talk, size:80, color: Colors.white24),
    const SizedBox(height:10),
    Text("Effetto attivo: ${AppConfig.voice} ${rate()}x", style: const TextStyle(fontSize:18, fontWeight: FontWeight.bold)),
    const SizedBox(height:20),
    Wrap(spacing:8, children: ["Robot","Scoiattolo","Gigante","Alieno"].map((e)=>ChoiceChip(label: Text(e), selected: AppConfig.voice==e, onSelected: (_)=>setState(()=>AppConfig.voice=e))).toList()),
    const Spacer(),
    SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(18)), onPressed: startCall, icon: const Icon(Icons.call), label: Text("CHIAMA IN CHAT CON VOCE ${AppConfig.voice.toUpperCase()}"))),
  ])));
  return Scaffold(backgroundColor: const Color(0xFF0A0A0A), body: SafeArea(child: Column(children: [
    const SizedBox(height:20),
    Container(padding: const EdgeInsets.symmetric(horizontal:12, vertical:6), decoration: BoxDecoration(color: Colors.green.withOpacity(0.25), borderRadius: BorderRadius.circular(20)), child: Text("🔊 VOCE MODIFICATA: ${AppConfig.voice.toUpperCase()} - L'ALTRO LO SA", style: const TextStyle(color: Colors.greenAccent, fontSize:11, fontWeight: FontWeight.bold))),
    const SizedBox(height:15),
    Text(fmt(sec), style: const TextStyle(fontSize:48, fontWeight: FontWeight.w300)),
    const Text("Chiamata in Chat - Criptata", style: TextStyle(color: Colors.white38, fontSize:12)),
    const Spacer(),
    Container(width:130, height:130, decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle), child: const Icon(Icons.person, size:60)),
    const SizedBox(height:10),
    const Text("Amico in chat", style: TextStyle(fontSize:18)),
    Text("Sta sentendo voce ${AppConfig.voice}", style: const TextStyle(color: Colors.greenAccent, fontSize:12)),
    const Spacer(),
    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      InkWell(onTap: playLive, child: Container(width:68, height:68, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.graphic_eq, color: Colors.black))),
      InkWell(onTap: endCall, child: Container(width:68, height:68, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.call_end, color: Colors.white, size:30))),
    ]),
    const SizedBox(height:10),
    const Text("Tocca EQ per testare la tua voce modificata", style: TextStyle(fontSize:10, color: Colors.white38)),
    const SizedBox(height:25),
  ])));
 }
}
