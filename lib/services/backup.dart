import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'database_helper.dart';

// Export / import of the whole SQLite database as a single .db file.
class Backup {
  // Lets the user save a copy of the database. Returns false if they cancelled.
  static Future<bool> export() async {
    final tmp = join((await getTemporaryDirectory()).path, 'export.db');
    await DatabaseHelper().exportTo(tmp);
    try {
      final name = 'sleep_tracker_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.db';
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
    final tmp = join((await getTemporaryDirectory()).path, 'import.db');
    await File(tmp).writeAsBytes(await picked.readAsBytes());
    return tmp;
  }

  // Replaces all data with the backup at [path] (from [pick]) and deletes it.
  static Future<void> restore(String path) async {
    try {
      await DatabaseHelper().importFrom(path);
    } finally {
      await File(path).delete();
    }
  }
}
