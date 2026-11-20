import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class BildirimServisi {
  static final BildirimServisi _instance = BildirimServisi._internal();
  factory BildirimServisi() => _instance;
  BildirimServisi._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _hazir = false;
  bool _izinIstendi = false;

  Future<void> baslat() async {
    if (_hazir) return;

    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    }

    const androidAyarlari =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosAyarlari = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidAyarlari,
        iOS: iosAyarlari,
      ),
    );

    _hazir = true;
  }

  Future<AndroidScheduleMode> _uygunAlarmModunuSec() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (!_izinIstendi) {
      _izinIstendi = true;
      await androidPlugin?.requestNotificationsPermission();
      final tamAlarmIzniVarMi =
          await androidPlugin?.canScheduleExactNotifications() ?? false;
      if (!tamAlarmIzniVarMi) {
        await androidPlugin?.requestExactAlarmsPermission();
      }
    }

    final tamAlarmAktif =
        await androidPlugin?.canScheduleExactNotifications() ?? false;
    return tamAlarmAktif
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  int _bildirimIdUret(String gorevId) => gorevId.hashCode & 0x7fffffff;

  NotificationDetails _bildirimDetaylari() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'gorev_hatirlaticilari',
        'Görev Hatırlatıcıları',
        channelDescription: 'Görev son tarihleri ve hatırlatmaları',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> gorevHatirlaticisiZamanla({
    required String gorevId,
    required String baslik,
    required DateTime bildirimZamani,
  }) async {
    await baslat();
    await iptalEt(gorevId);

    if (bildirimZamani.isBefore(DateTime.now())) return;

    final alarmModu = await _uygunAlarmModunuSec();
    final tzZamani = tz.TZDateTime.from(bildirimZamani, tz.local);

    try {
      await _plugin.zonedSchedule(
        _bildirimIdUret(gorevId),
        'Görev Hatırlatıcı',
        baslik,
        tzZamani,
        _bildirimDetaylari(),
        androidScheduleMode: alarmModu,
      );
      debugPrint(
        'Bildirim zamanlandı: $tzZamani (id: ${_bildirimIdUret(gorevId)}, mod: $alarmModu)',
      );
    } catch (e) {
      debugPrint('Bildirim zamanlama hatası: $e');
    }
  }

  Future<void> iptalEt(String gorevId) async {
    await _plugin.cancel(_bildirimIdUret(gorevId));
  }
}