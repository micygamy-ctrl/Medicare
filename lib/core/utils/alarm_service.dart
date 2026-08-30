import 'dart:typed_data';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../domain/entities/medication.dart';

// ده بيشتغل في الـ background
@pragma('vm:entry-point')
Future<void> alarmCallback(int id, Map<String, dynamic> params) async {
  final medicationName = params['medicationName'] as String? ?? 'الدواء';
  final time = params['time'] as String? ?? '';

  final notifications = FlutterLocalNotificationsPlugin();

  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  await notifications.initialize(
    const InitializationSettings(android: androidSettings),
  );

  await notifications.show(
    id,
    '💊 وقت الدواء',
    'حان وقت تناول $medicationName — $time',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'medication_alarm',
        'منبه الأدوية',
        channelDescription: 'منبه لمواعيد الأدوية',
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
    ),
  );
}

class AlarmService {
  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  // جدولة alarm لدواء معين
  static Future<void> scheduleAlarms({
    required String medicationId,
    required String medicationName,
    required List<ScheduleEntity> schedules,
  }) async {
    // إلغاء الـ alarms القديمة
    await cancelAlarms(medicationId);

    for (final schedule in schedules) {
      for (int i = 0; i < schedule.times.length; i++) {
        final time = schedule.times[i];
        final parts = time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        final alarmId =
            '${medicationId}_$i'.hashCode.abs() % 2147483647;

        final now = DateTime.now();
        var alarmTime = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );

        // لو الوقت فات، جدوله بكره
        if (alarmTime.isBefore(now)) {
          alarmTime = alarmTime.add(const Duration(days: 1));
        }

        await AndroidAlarmManager.periodic(
          const Duration(days: 1),
          alarmId,
          alarmCallback,
          startAt: alarmTime,
          exact: true,
          wakeup: true,
          rescheduleOnReboot: true,
          params: {
            'medicationName': medicationName,
            'medicationId': medicationId,
            'time': time,
          },
        );

        print('✅ Alarm set for $medicationName at $time');
      }
    }
  }

  // إلغاء alarms دواء معين
  static Future<void> cancelAlarms(String medicationId) async {
    for (int i = 0; i < 10; i++) {
      final id = '${medicationId}_$i'.hashCode.abs() % 2147483647;
      await AndroidAlarmManager.cancel(id);
    }
  }

  // إلغاء كل الـ alarms
  static Future<void> cancelAll(List<MedicationEntity> medications) async {
    for (final medication in medications) {
      await cancelAlarms(medication.id);
    }
  }

  // جدولة كل الأدوية
  static Future<void> scheduleAllMedications(
      List<MedicationEntity> medications) async {
    for (final medication in medications) {
      if (medication.isActive && !medication.isDeleted) {
        await scheduleAlarms(
          medicationId: medication.id,
          medicationName: medication.name,
          schedules: medication.schedules,
        );
      }
    }
    print('✅ All alarms scheduled for ${medications.length} medications');
  }
}