import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../domain/entities/medication.dart';

class NotificationScheduler {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload;
        final actionId = response.actionId;

        if (payload != null && actionId != null) {
          await _handleNotificationAction(
            medicationId: payload,
            actionId: actionId,
          );
        }
      },
    );

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        _notifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'medication_reminders',
              'تذكيرات الأدوية',
              channelDescription: 'إشعارات تذكير بمواعيد الأدوية',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
      }
    });
  }

  static Future<void> _handleNotificationAction({
    required String medicationId,
    required String actionId,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final statusStr = actionId == 'taken' ? 'taken' : 'missed';

      // Find today's pending log for this medication or update it
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final logsQuery = await firestore
          .collection('intakeLogs')
          .where('medicationId', isEqualTo: medicationId)
          .where('scheduledTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduledTime',
              isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      if (logsQuery.docs.isNotEmpty) {
        final logDoc = logsQuery.docs.first;
        await logDoc.reference.update({
          'status': statusStr,
          'respondedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      print('Error handling notification action: $e');
    }
  }

  static Future<void> scheduleMedicationReminders({
    required String medicationId,
    required String medicationName,
    required List<ScheduleEntity> schedules,
  }) async {
    await cancelMedicationReminders(medicationId);

    int count = 0;
    for (final schedule in schedules) {
      for (int i = 0; i < schedule.times.length; i++) {
        final time = schedule.times[i];
        final parts = time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final notificationId =
            '${medicationId}_$count'.hashCode.abs() % 2147483647;

        await _scheduleExactDaily(
          id: notificationId,
          title: '💊 وقت تناول الدواء',
          body: 'حان وقت تناول $medicationName ($time)',
          hour: hour,
          minute: minute,
          payload: medicationId,
        );
        count++;
      }
    }
  }

  static Future<void> _scheduleExactDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_alarm',
            'تنبيهات الأدوية',
            channelDescription: 'تنبيهات صوتية لمواعيد الأدوية',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            vibrationPattern:
                Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
            visibility: NotificationVisibility.public,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            ongoing: false,
            autoCancel: true,
            actions: [
              const AndroidNotificationAction(
                'taken',
                '✓ تم التناول',
                showsUserInterface: true,
                cancelNotification: true,
              ),
              const AndroidNotificationAction(
                'skip',
                '✗ تخطي',
                showsUserInterface: false,
                cancelNotification: true,
              ),
            ],
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e) {
      print('❌ Notification schedule error: $e');
    }
  }

  static Future<void> showTestNotification({
    required String medicationName,
    required String time,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 2147483647,
      '💊 وقت تناول الدواء',
      'حان وقت تناول $medicationName — $time',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminders',
          'تذكيرات الأدوية',
          channelDescription: 'إشعارات تذكير بمواعيد الأدوية',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  static Future<void> cancelMedicationReminders(String medicationId) async {
    for (int i = 0; i < 50; i++) {
      final id = '${medicationId}_$i'.hashCode.abs() % 2147483647;
      await _notifications.cancel(id);
    }
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  static Future<void> scheduleAllMedications(
      List<MedicationEntity> medications) async {
    for (final medication in medications) {
      if (medication.isActive && !medication.isDeleted) {
        await scheduleMedicationReminders(
          medicationId: medication.id,
          medicationName: medication.name,
          schedules: medication.schedules,
        );
      }
    }
  }
}