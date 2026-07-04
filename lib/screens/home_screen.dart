import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/voice_service.dart';
import 'archive_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _textController = TextEditingController();
  late VoiceService _voiceService;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _voiceService = VoiceService();
    _voiceService.initialize();
  }

  void _saveNote() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final title = Note.extractTitle(text);
    final note = Note(title: title, content: text);

    context.read<StorageService>().saveNote(note);
    _textController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notiz erstellt')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0 ? _buildHome() : const ArchiveScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF000000),
        selectedItemColor: const Color(0xFF007AFF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.archive), label: 'Archive'),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return Column(
      children: [
        AppBar(
          backgroundColor: const Color(0xFF000000),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Consumer<VoiceService>(
              builder: (_, voiceService, __) => Text(
                voiceService.isListening
                    ? '🔴 Aufzeichnung läuft...'
                    : (voiceService.transcript.isNotEmpty
                        ? voiceService.transcript
                        : 'Notiz bereit'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Notiz aufzeichnen...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFF333333)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  prefixIcon: const Icon(Icons.add, color: Colors.grey),
                  suffixIcon: Consumer<VoiceService>(
                    builder: (_, voiceService, __) => IconButton(
                      icon: Icon(
                        voiceService.isListening
                            ? Icons.stop_circle
                            : Icons.mic,
                        color: voiceService.isListening
                            ? Colors.red
                            : Colors.grey,
                      ),
                      onPressed: () async {
                        if (voiceService.isListening) {
                          await voiceService.stopListening();
                          _textController.text = voiceService.transcript;
                        } else {
                          await voiceService.startListening();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                onPressed: _saveNote,
                backgroundColor: const Color(0xFF007AFF),
                child: const Icon(Icons.send),
              ),
              const SizedBox(height: 12),
              const Text(
                'Online • 0 pending',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _voiceService.dispose();
    super.dispose();
  }
}
