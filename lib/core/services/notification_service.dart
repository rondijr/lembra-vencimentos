import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Notificações não suportadas no Windows/Web
    if (_isNotificationSupported()) {
      tz.initializeTimeZones();

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(android: android, iOS: darwin, macOS: darwin);
      await _plugin.initialize(settings);
    }
  }

  bool _isNotificationSupported() {
    if (kIsWeb) return false;
    if (Platform.isWindows || Platform.isLinux) return false;
    return true; // Android, iOS, macOS
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Ignora em plataformas não suportadas
    if (!_isNotificationSupported()) {
      print('⚠️ Notificações não suportadas nesta plataforma');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'deadline_channel',
      'Prazos',
      channelDescription: 'Notificações de prazos',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF2563EB),
    );

    const darwinDetails = DarwinNotificationDetails();

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(android: androidDetails, iOS: darwinDetails, macOS: darwinDetails),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    } catch (e) {
      print('⚠️ Erro ao agendar notificação: $e');
    }
  }

  Future<void> cancel(int id) async {
    if (!_isNotificationSupported()) return;
    try {
      await _plugin.cancel(id);
    } catch (e) {
      print('⚠️ Erro ao cancelar notificação: $e');
    }
  }
}
