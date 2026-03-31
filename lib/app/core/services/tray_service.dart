import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class TrayService with TrayListener, WindowListener {
  static final TrayService _instance = TrayService._internal();
  factory TrayService() => _instance;
  TrayService._internal();

  VoidCallback? onShowApp;
  VoidCallback? onQuitApp;
  bool _isQuitting = false;

  Future<void> init() async {
    await windowManager.ensureInitialized();
    windowManager.addListener(this);

    const windowOptions = WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Equily',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    trayManager.addListener(this);

    try {
      if (Platform.isWindows) {
        await trayManager.setIcon('assets/icons/tray_icon.ico');
      } else {
        await trayManager.setIcon('assets/icons/tray_icon.png');
      }
    } catch (e) {
      debugPrint('Tray icon not found, using default');
    }

    final menu = Menu(
      items: [
        MenuItem(key: 'show', label: 'Abrir Equily'),
        MenuItem.separator(),
        MenuItem(key: 'quit', label: 'Sair'),
      ],
    );

    await trayManager.setContextMenu(menu);
    await trayManager.setToolTip('Equily - Seu assistente financeiro');
  }

  Future<void> minimizeToTray() async {
    await windowManager.hide();
  }

  Future<void> showFromTray() async {
    await windowManager.show();
    await windowManager.focus();
  }

  void setQuitting(bool value) {
    _isQuitting = value;
  }

  bool get isQuitting => _isQuitting;

  @override
  void onWindowClose() async {
    if (!_isQuitting) {
      await minimizeToTray();
    }
  }

  @override
  void onTrayIconMouseDown() {
    showFromTray();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        showFromTray();
        break;
      case 'quit':
        _isQuitting = true;
        onQuitApp?.call();
        break;
    }
  }

  Future<void> dispose() async {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    await trayManager.destroy();
  }
}
