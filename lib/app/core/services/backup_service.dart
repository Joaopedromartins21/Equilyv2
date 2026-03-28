import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'database_service.dart';

class BackupService {
  static Future<String> createBackup() async {
    final jsonData = await DatabaseService.exportAllData();
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/equily_backup_$timestamp.json');
    await file.writeAsString(jsonData);
    return file.path;
  }

  static Future<bool> restoreBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return false;
      final jsonData = await file.readAsString();
      await DatabaseService.importAllData(jsonData);
      return true;
    } catch (e) {
      return false;
    }
  }
}
