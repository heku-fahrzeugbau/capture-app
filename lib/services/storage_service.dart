import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class StorageService extends ChangeNotifier {
  late Database _db;
  List<Note> _notes = [];
  List<Note> _pendingNotes = [];

  List<Note> get notes => _notes;
  List<Note> get pendingNotes => _pendingNotes;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'capture_app.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE notes(
            id TEXT PRIMARY KEY,
            title TEXT,
            content TEXT,
            timestamp INTEGER,
            syncStatus TEXT,
            googleDriveFileId TEXT,
            retryCount INTEGER
          )
        ''');
      },
    );

    await fetchNotes();
  }

  Future<void> saveNote(Note note) async {
    await _db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await fetchNotes();
    notifyListeners();
  }

  Future<void> fetchNotes() async {
    final maps = await _db.query('notes', orderBy: 'timestamp DESC');
    _notes = maps.map((m) => Note.fromMap(m)).toList();
    _pendingNotes = _notes.where((n) => n.syncStatus == SyncStatus.pending).toList();
    notifyListeners();
  }

  Future<void> updateSyncStatus(String noteId, SyncStatus status) async {
    await _db.update(
      'notes',
      {'syncStatus': status.toString()},
      where: 'id = ?',
      whereArgs: [noteId],
    );
    await fetchNotes();
    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    await _db.delete('notes', where: 'id = ?', whereArgs: [noteId]);
    await fetchNotes();
    notifyListeners();
  }
}
