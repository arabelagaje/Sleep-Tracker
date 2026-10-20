import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import 'database_helper.dart';

// Export / import of the SQLite database file itself.
class Backup {
  // Lets the user save a copy of the database. Returns false if they cancelled.
  static Future<bool> export() async {
    final tmp = '${await DatabaseHelper().filePath()}.export';
    await DatabaseHelper().exportTo(tmp);
    try {
      final name = 'sleep_tracker_${DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now())}.db';
      final saved = await FilePicker.saveFile(
        fileName: name,
        bytes: await File(tmp).readAsBytes(),
      );
      return saved != null;
    } finally {
      await File(tmp).delete();
    }
  }

  // Lets the user pick a backup file and returns a local copy of it, or null
  // if they cancelled.
  static Future<String?> pick() async {
    final picked = await FilePicker.pickFile();
    if (picked == null) return null;
    // Beside the database file, so the import can move it into place.
    final tmp = '${await DatabaseHelper().filePath()}.import';
    await File(tmp).writeAsBytes(await picked.readAsBytes());
    return tmp;
  }

  // Replaces all data with the backup at [path] (from [pick]).
  static Future<void> restore(String path) => DatabaseHelper().importFrom(path);
}
