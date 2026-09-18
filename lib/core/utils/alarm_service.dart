import 'dart:io';
import 'dart:typed_data';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../domain/entities/medication.dart';

@pragma('vm:entry-point')
Future<void> alarmCallback(int id, Map<String, dynamic> params) async {
  final medicationName = params['medicationName'] as String? ?? 'الدواء';
  final time = params['time'] as String? ?? '';

  final notifications = FlutterLocalNotificationsPlugin();

  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const darwinSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  await notifications.initialize(
    const InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    ),
  );

  await notifications.show(
    id,
    '💊 وقت تناول الدواء',
    'حان وقت تناول $medicationName — $time',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'medication_alarm',
        'منبه الأدوية',
        channelDescription: 'منبه لمواعيد التذكير بتناول الأدوية',
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
        autoCancel: true,
        ongoing: false,
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
  );
}

class AlarmService {
  static Future<void> initialize() async {
    if (Platform.isAndroid) {
      await AndroidAlarmManager.initialize();
    }
  }

  static Future<void> scheduleAlarms({
    required MedicationEntity medication,
  }) async {
    if (!medication.isActive || medication.isDeleted) return;

    final now = DateTime.now();

    // 1. Verify endDate if present
    if (medication.endDate != null && now.isAfter(medication.endDate!)) {
      await cancelAlarms(medication.id);
      return;
    }

    // Cancel previous alarms for this medication first
    await cancelAlarms(medication.id);

    int count = 0;
    for (final schedule in medication.schedules) {
      for (int i = 0; i < schedule.times.length; i++) {
        final timeStr = schedule.times[i];
        final parts = timeStr.split(':');
        if (parts.length < 2) continue;

        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        var targetTime = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );

        // Subtract reminderMinutesBefore offset if specified
        if (schedule.reminderMinutesBefore > 0) {
          targetTime = targetTime.subtract(
            Duration(minutes: schedule.reminderMinutesBefore),
          );
        }

        // If target time already passed today, advance to next day
        if (targetTime.isBefore(now)) {
          targetTime = targetTime.add(const Duration(days: 1));
        }

        // Validate daysOfWeek filter if specified
        if (schedule.daysOfWeek.isNotEmpty &&
            !schedule.daysOfWeek.contains(targetTime.weekday)) {
          // Find next matching weekday
          int daysAdded = 0;
          while (!schedule.daysOfWeek.contains(targetTime.weekday) &&
              daysAdded < 7) {
            targetTime = targetTime.add(const Duration(days: 1));
            daysAdded++;
          }
        }

        final alarmId = '${medication.id}_$count'.hashCode.abs() % 2147483647;

        if (Platform.isAndroid) {
          await AndroidAlarmManager.periodic(
            const Duration(days: 1),
            alarmId,
            alarmCallback,
            startAt: targetTime,
            exact: true,
            wakeup: true,
            rescheduleOnReboot: true,
            params: {
              'medicationName': medication.name,
              'medicationId': medication.id,
              'time': timeStr,
            },
          );
        }

        count++;
      }
    }
  }

  static Future<void> cancelAlarms(String medicationId) async {
    for (int i = 0; i < 50; i++) {
      final id = '${medicationId}_$i'.hashCode.abs() % 2147483647;
      if (Platform.isAndroid) {
        await AndroidAlarmManager.cancel(id);
      }
    }
  }

  static Future<void> cancelAll(List<MedicationEntity> medications) async {
    for (final medication in medications) {
      await cancelAlarms(medication.id);
    }
  }

  static Future<void> scheduleAllMedications(
      List<MedicationEntity> medications) async {
    for (final medication in medications) {
      await scheduleAlarms(medication: medication);
    }
  }
}