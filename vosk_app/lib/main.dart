import 'package:flutter/material.dart';
import 'package:vosk_flutter_2/vosk_flutter_2.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vosk Speech Recognition',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SpeechRecognitionScreen(),
    );
  }
}

class SpeechRecognitionScreen extends StatefulWidget {
  const SpeechRecognitionScreen({super.key});

  @override
  State<SpeechRecognitionScreen> createState() =>
      _SpeechRecognitionScreenState();
}

class _SpeechRecognitionScreenState extends State<SpeechRecognitionScreen> {
  final VoskFlutterPlugin vosk = VoskFlutterPlugin.instance();
  Recognizer? recognizer;
  SpeechService? speechService;

  bool isInitialized = false;
  bool isListening = false;
  String recognizedText = '';
  String partialText = '';
  String statusMessage = 'Inizializzazione...';

  @override
  void initState() {
    super.initState();
    initializeVosk();
  }

  Future<void> initializeVosk() async {
    try {
      setState(() {
        statusMessage = 'Caricamento modello...';
      });

      // Carica il modello da assets
      final modelPath = await ModelLoader().loadFromAssets(
        'assets/models/vosk-model-small-it-0.22.zip',
      );

      final model = await vosk.createModel(modelPath);

      // Crea il recognizer
      recognizer = await vosk.createRecognizer(model: model, sampleRate: 16000);

      // Inizializza il servizio di riconoscimento vocale
      speechService = await vosk.initSpeechService(recognizer!);

      // Configura i callback
      speechService!.onPartial().forEach((partial) {
        setState(() {
          partialText = partial;
        });
      });

      speechService!.onResult().forEach((result) {
        setState(() {
          recognizedText += result + '\n';
          partialText = '';
        });
      });

      setState(() {
        isInitialized = true;
        statusMessage = 'Pronto per il riconoscimento vocale';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Errore inizializzazione: $e';
      });
    }
  }

  Future<void> startListening() async {
    if (!isInitialized || speechService == null) return;

    try {
      await speechService!.start();
      setState(() {
        isListening = true;
        statusMessage = 'In ascolto...';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Errore avvio: $e';
      });
    }
  }

  Future<void> stopListening() async {
    if (speechService == null) return;

    try {
      await speechService!.stop();
      setState(() {
        isListening = false;
        statusMessage = 'Riconoscimento interrotto';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Errore stop: $e';
      });
    }
  }

  void clearText() {
    setState(() {
      recognizedText = '';
      partialText = '';
    });
  }

  @override
  void dispose() {
    speechService?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vosk Speech Recognition'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  statusMessage,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Controlli
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: isInitialized && !isListening
                      ? startListening
                      : null,
                  icon: Icon(Icons.mic),
                  label: Text('Avvia'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isListening ? stopListening : null,
                  icon: Icon(Icons.stop),
                  label: Text('Stop'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                ElevatedButton.icon(
                  onPressed: clearText,
                  icon: Icon(Icons.clear),
                  label: Text('Pulisci'),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Testo parziale
            if (partialText.isNotEmpty)
              Card(
                color: Colors.yellow[100],
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Testo parziale:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(partialText),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 10),

            // Testo riconosciuto
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Testo riconosciuto:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            recognizedText.isEmpty
                                ? 'Nessun testo riconosciuto ancora...'
                                : recognizedText,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
