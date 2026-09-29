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

  double getRateForEffect() {
    switch(AppConfig.voiceEffect) {
      case "Scoiattolo": return 2.2; // voce super acuta
      case "Gigante": return 0.55; // voce profonda gigante
      case "Alieno": return 0.75; // lenta + strana
      case "Robot": return 1.0; // normale ma con effetto
      default: return AppConfig.pitch;
    }
  }

  Future<void> checkMic() async {
    var s = await Permission.microphone.request();
    setState(() => hasMic = s.isGranted);
  }

  @override
  void initState() { super.initState(); checkMic(); }

  Future<void> startRec() async {
    if (!hasMic) { await checkMic(); if (!hasMic) return; }
    final dir = await getTemporaryDirectory();
    filePath = "${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a";
    await recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100), path: filePath!);
    setState(() => isRec = true);
  }

  Future<void> stopRec() async {
    await recorder.stop();
    setState(() => isRec = false);
  }

  Future<void> playSound() async {
    if (filePath == null) return;
    await player.stop();
    double rate = getRateForEffect();
    // Applica pitch + velocità insieme
    await player.setPlaybackRate(rate);
    await player.play(DeviceFileSource(filePath!));
    
    // Messaggio per far capire
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Effetto ${AppConfig.voiceEffect} applicato: ${rate}x ${rate > 1 ? 'ACUTO' : 'GRAVE'}"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Voce: ${AppConfig.voiceEffect}"), backgroundColor: Colors.black),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (!hasMic) ElevatedButton(onPressed: checkMic, child: const Text("AUTORIZZA MICROFONO")),
          if (hasMic) const Text("✓ Microfono OK - Tieni premuto per registrare", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
          const SizedBox(height: 15),
          const Text("SCEGLI EFFETTO:", style: TextStyle(fontSize: 11, color: Colors.white54)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
            _chip("Robot", Icons.smart_toy, "Voce normale"),
            _chip("Scoiattolo", Icons.pets, "2.2x super acuta"),
            _chip("Gigante", Icons.accessibility, "0.55x super grave"),
            _chip("Alieno", Icons.android, "0.75x aliena"),
          ]),
          const SizedBox(height: 15),
          Text("Regolazione fine: ${AppConfig.pitch.toStringAsFixed(2)}x"),
          Slider(value: AppConfig.pitch, min: 0.5, max: 2.5, divisions: 20, label: "${AppConfig.pitch.toStringAsFixed(2)}x", onChanged: (v) => setState(() => AppConfig.pitch = v)),
          const SizedBox(height: 25),
          GestureDetector(
            onLongPress: startRec,
            onLongPressUp: () { stopRec(); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isRec ? 130 : 95, height: isRec ? 130 : 95,
              decoration: BoxDecoration(color: isRec ? Colors.red : Colors.white, shape: BoxShape.circle, boxShadow: [if(isRec) BoxShadow(color: Colors.red.withOpacity(0.6), blurRadius: 25, spreadRadius: 10)]),
              child: Icon(isRec ? Icons.stop : Icons.mic, color: Colors.black, size: 40),
            ),
          ),
          const SizedBox(height: 10),
          Text(isRec ? "🔴 REGISTRAZIONE..." : "Tieni premuto il bottone", style: TextStyle(color: isRec ? Colors.red : Colors.white70)),
          const SizedBox(height: 25),
          if (filePath != null)
            Column(children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14)),
                onPressed: playSound,
                icon: const Icon(Icons.play_arrow),
                label: Text("ASCOLTA COME ${AppConfig.voiceEffect.toUpperCase()}"),
              ),
              const SizedBox(height: 8),
              Text("File: ${filePath!.split('/').last}", style: const TextStyle(fontSize: 9, color: Colors.white30)),
            ])
        ]),
      ),
    );
  }

  Widget _chip(String name, IconData icon, String desc) {
    bool sel = AppConfig.voiceEffect == name;
    return ChoiceChip(
      avatar: Icon(icon, size: 16, color: sel ? Colors.black : Colors.white),
      label: Column(mainAxisSize: MainAxisSize.min, children: [Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: sel ? Colors.black : Colors.white)), Text(desc, style: TextStyle(fontSize: 8, color: sel ? Colors.black54 : Colors.white38))]),
      selected: sel,
      selectedColor: Colors.white,
      backgroundColor: const Color(0xFF222222),
      onSelected: (_) => setState(() => AppConfig.voiceEffect = name),
    );
  }
}
