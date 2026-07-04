import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

enum SyncStatus { pending, syncing, synced, failed }

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final SyncStatus syncStatus;
  final String? googleDriveFileId;
  final int retryCount;

  Note({
    String? id,
    required this.title,
    required this.content,
    DateTime? timestamp,
    this.syncStatus = SyncStatus.pending,
    this.googleDriveFileId,
    this.retryCount = 0,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  String get filename {
    final formatter = DateFormat('yyyyMMdd_HHmmss');
    final timeString = formatter.format(timestamp);
    return 'notiz_$timeString.md';
  }

  String get markdownContent {
    final formatter = DateFormat('dd.MM.yyyy, HH:mm');
    final timeString = formatter.format(timestamp);

    return '''# $title

**Zeitstempel:** $timeString Uhr

$content

---
*Erstellt mit Quick Notes App*
''';
  }

  static String extractTitle(String content) {
    final lines = content.split('\n');
    final firstLine = lines.first.trim();

    if (firstLine.isEmpty) {
      return 'Notiz';
    }

    if (firstLine.length > 50) {
      return '${firstLine.substring(0, 47)}...';
    }

    return firstLine;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'syncStatus': syncStatus.toString(),
      'googleDriveFileId': googleDriveFileId,
      'retryCount': retryCount,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.toString() == map['syncStatus'],
        orElse: () => SyncStatus.pending,
      ),
      googleDriveFileId: map['googleDriveFileId'],
      retryCount: map['retryCount'] ?? 0,
    );
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? timestamp,
    SyncStatus? syncStatus,
    String? googleDriveFileId,
    int? retryCount,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      syncStatus: syncStatus ?? this.syncStatus,
      googleDriveFileId: googleDriveFileId ?? this.googleDriveFileId,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}
