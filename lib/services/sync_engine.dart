import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'auth_service.dart';
import 'storage_service.dart';
import 'google_drive_service.dart';
import '../models/note.dart';
import 'dart:async';

class SyncEngine extends ChangeNotifier {
  final AuthService authService;
  final StorageService storageService;
  final GoogleDriveService driveService = GoogleDriveService();
  
  bool _isSyncing = false;
  DateTime? _lastSyncDate;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncDate => _lastSyncDate;

  SyncEngine({required this.authService, required this.storageService}) {
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.wifi) || 
          results.contains(ConnectivityResult.mobile)) {
        syncPendingNotes();
      }
    });
  }

  Future<void> syncPendingNotes() async {
    if (_isSyncing || !authService.isAuthenticated) return;

    final pending = storageService.pendingNotes;
    if (pending.isEmpty) return;

    _isSyncing = true;
    notifyListeners();

    for (var note in pending) {
      await _syncNote(note, 0);
    }

    _isSyncing = false;
    _lastSyncDate = DateTime.now();
    notifyListeners();
  }

  Future<void> _syncNote(Note note, int retryCount) async {
    try {
      storageService.updateSyncStatus(note.id, SyncStatus.syncing);

      await driveService.uploadNote(
        note,
        authService.accessToken!,
        authService.selectedFolderID!,
      );

      storageService.updateSyncStatus(note.id, SyncStatus.synced);
      print('✅ Synced: ${note.title}');
    } catch (e) {
      final delay = exponentialBackoff(retryCount);

      if (retryCount < 3) {
        await Future.delayed(Duration(seconds: delay));
        await _syncNote(note, retryCount + 1);
      } else {
        storageService.updateSyncStatus(note.id, SyncStatus.failed);
        print('❌ Sync failed: ${note.title}');
      }
    }
  }

  int exponentialBackoff(int retryCount) {
    return 2 * (1 << retryCount);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
