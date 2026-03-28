import 'package:flutter/material.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  final ShorebirdUpdater _updater = ShorebirdUpdater();

  bool _isChecking = false;

  Future<void> checkForUpdates(BuildContext context) async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final status = await _updater.checkForUpdate();

      if (status == UpdateStatus.outdated && context.mounted) {
        _showUpdateDialog(context);
      }
    } catch (e) {
      debugPrint('Erro ao verificar atualizações: $e');
    } finally {
      _isChecking = false;
    }
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Atualização disponível!'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Uma nova versão está disponível.'),
            SizedBox(height: 8),
            Text(
              'O app será atualizado automaticamente.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _installUpdate();
            },
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  Future<void> _installUpdate() async {
    try {
      await _updater.update();
    } catch (e) {
      debugPrint('Erro ao instalar atualização: $e');
    }
  }

  Future<int?> getCurrentPatchNumber() async {
    try {
      final patch = await _updater.readCurrentPatch();
      return patch?.number;
    } catch (e) {
      return null;
    }
  }
}
