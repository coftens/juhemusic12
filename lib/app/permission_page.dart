import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../api/api_config.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  bool _requesting = false;

  Future<void> _handlePermissions() async {
    if (_requesting) return;
    setState(() => _requesting = true);

    try {
      // Logic: request Storage and Notification
      // On Android 13+ (SDK 33), storage is split into images/audio.
      // permission_handler handles this mapping internally mostly, but let's be explicit.

      // 1. Notifications (Android 13+)
      await Permission.notification.request();

      // 2. Storage
      // For generic storage reading, we usually check storage or photos/audio depending on OS
      if (Platform.isAndroid) {
         // Try to request comprehensive media permissions
         // We don't strictly block the user if they deny, just request best effort.
         await [
           Permission.storage,
           Permission.audio,
           Permission.photos,
         ].request();
      } else {
        // iOS or others
        await Permission.storage.request();
      }

      // 3. Mark as accepted regardless of result (so we don't block the user forever)
      await ApiConfig.instance.setPermissionsAccepted();
    } finally {
      if (mounted) {
        setState(() => _requesting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFBFB4A6), // Muted brown/gray
                  Color(0xFF7F7466),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  const Icon(Icons.music_note_rounded, size: 80, color: Colors.white),
                  const SizedBox(height: 24),
                  Text(
                    '欢迎使用 Music',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '为了正常播放本地音乐并提供完整的后台播放体验，我们需要申请以下权限：\n\n'
                    '• 存储权限：扫描本地音乐文件\n'
                    '• 通知权限：控制后台播放和显示歌词',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _requesting ? null : _handlePermissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: _requesting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('同意并继续', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
