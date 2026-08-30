import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../firebase_options.dart';

const String medicationReminderTask = 'medicationReminderTask';

// ده بيشتغل في الـ background حتى لو التطبيق مقفول
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (task == medicationReminderTask) {
        await _checkAndSendReminders();
      }

      return Future.value(true);
    } catch (e) {
      print('Background task error: $e');
      return Future.value(false);
    }
  });
}

Future<void> _checkAndSendReminders() async {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  final user = auth.currentUser;
  if (user == null) return;

  final now = DateTime.now();
  final currentHour = now.hour;
  final currentMinute = now.minute;

  // جلب الأدوية الفعّالة للمستخدم الحالي
  final medicationsSnapshot = await firestore
      .collection('medications')
      .where('patientId', isEqualTo: user.uid)
      .where('isActive', isEqualTo: true)
      .where('isDeleted', isEqualTo: false)
      .get();

  final notifications = FlutterLocalNotificationsPlugin();

  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  await notifications.initialize(
    const InitializationSettings(android: androidSettings),
  );

  for (final medicationDoc in medicationsSnapshot.docs) {
    final medication = medicationDoc.data();

    // جلب الـ schedules
    final schedulesSnapshot = await firestore
        .collection('medications')
        .doc(medicationDoc.id)
        .collection('schedules')
        .get();

    for (final scheduleDoc in schedulesSnapshot.docs) {
      final times = List<String>.from(
          scheduleDoc.data()['times'] ?? []);

      for (final time in times) {
        final parts = time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        // تحقق لو الوقت حالياً (فرق أقل من 15 دقيقة)
        final scheduledMinutes = hour * 60 + minute;
        final currentMinutes = currentHour * 60 + currentMinute;
        final diff = (scheduledMinutes - currentMinutes).abs();

        if (diff <= 15) {
          // تحقق إن مفيش log موجود
          final startOfDay = DateTime(
              now.year, now.month, now.day);
          final endOfDay = startOfDay.add(const Duration(days: 1));

          final existingLogs = await firestore
              .collection('intakeLogs')
              .where('medicationId', isEqualTo: medicationDoc.id)
              .where('patientId', isEqualTo: user.uid)
              .where('scheduledTime',
                  isGreaterThanOrEqualTo:
                      Timestamp.fromDate(startOfDay))
              .where('scheduledTime',
                  isLessThan: Timestamp.fromDate(endOfDay))
              .get();

          final alreadyLogged = existingLogs.docs.any((doc) {
            final scheduledTime =
                (doc.data()['scheduledTime'] as Timestamp).toDate();
            return scheduledTime.hour == hour &&
                scheduledTime.minute == minute;
          });

          if (!alreadyLogged) {
            // إنشاء IntakeLog
            final scheduledTime = DateTime(
                now.year, now.month, now.day, hour, minute);

            await firestore.collection('intakeLogs').add({
              'medicationId': medicationDoc.id,
              'medicationName': medication['name'],
              'patientId': user.uid,
              'scheduledTime': Timestamp.fromDate(scheduledTime),
              'status': 'pending',
              'snoozeCount': 0,
              'source': 'background',
              'respondedAt': null,
              'note': null,
            });

            // إرسال الإشعار
            await notifications.show(
              medicationDoc.id.hashCode % 100000,
              '💊 وقت الدواء',
              'حان وقت تناول ${medication['name']} — $time',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'medication_reminders',
                  'تذكيرات الأدوية',
                  channelDescription:
                      'إشعارات تذكير بمواعيد الأدوية',
                  importance: Importance.high,
                  priority: Priority.high,
                  icon: '@mipmap/ic_launcher',
                ),
              ),
            );
          }
        }
      }
    }
  }
}