const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// بتشتغل كل 30 دقيقة
exports.sendMedicationReminders = functions.pubsub
    .schedule("every 30 minutes")
    .onRun(async (context) => {
      console.log("Running medication reminders...");

      try {
        const now = new Date();
        const currentHour = now.getHours();
        const currentMinute = now.getMinutes();

        // جلب كل الأدوية الفعّالة
        const medicationsSnapshot = await db
            .collection("medications")
            .where("isActive", "==", true)
            .where("isDeleted", "==", false)
            .get();

        const promises = [];

        for (const medicationDoc of medicationsSnapshot.docs) {
          const medication = medicationDoc.data();
          const patientId = medication.patientId;

          // جلب الـ schedules
          const schedulesSnapshot = await db
              .collection("medications")
              .doc(medicationDoc.id)
              .collection("schedules")
              .get();

          for (const scheduleDoc of schedulesSnapshot.docs) {
            const schedule = scheduleDoc.data();
            const times = schedule.times || [];

            for (const time of times) {
              const parts = time.split(":");
              const scheduleHour = parseInt(parts[0]);
              const scheduleMinute = parseInt(parts[1]);

              // تحقق لو الوقت قريب (في خلال 30 دقيقة)
              const scheduledTime = scheduleHour * 60 + scheduleMinute;
              const currentTime = currentHour * 60 + currentMinute;
              const diff = Math.abs(scheduledTime - currentTime);

              if (diff <= 2) {
                // جلب الـ FCM Token للمريض
                const userDoc = await db
                    .collection("users")
                    .doc(patientId)
                    .get();

                if (!userDoc.exists) continue;

                const fcmToken = userDoc.data().fcmToken;
                if (!fcmToken) continue;

                // إنشاء IntakeLog
                const logRef = db.collection("intakeLogs").doc();
                const scheduledDateTime = new Date();
                scheduledDateTime.setHours(scheduleHour, scheduleMinute, 0);

                await logRef.set({
                  medicationId: medicationDoc.id,
                  medicationName: medication.name,
                  patientId: patientId,
                  scheduledTime: admin.firestore.Timestamp.fromDate(
                      scheduledDateTime),
                  status: "pending",
                  snoozeCount: 0,
                  source: "auto",
                  respondedAt: null,
                  note: null,
                });

                // إرسال FCM Notification
                const message = {
                  token: fcmToken,
                  notification: {
                    title: "💊 وقت الدواء",
                    body: `حان وقت تناول ${medication.name} - ${time}`,
                  },
                  data: {
                    logId: logRef.id,
                    medicationId: medicationDoc.id,
                    medicationName: medication.name,
                    type: "medication_reminder",
                  },
                  android: {
                    priority: "high",
                    notification: {
                      channelId: "medication_reminders",
                      priority: "high",
                      defaultSound: true,
                      defaultVibrateTimings: true,
                    },
                  },
                };

                promises.push(
                    messaging.send(message).catch((err) => {
                      console.error(`FCM error for ${patientId}:`, err);
                    }),
                );

                console.log(
                    `Sent reminder for ${medication.name} to ${patientId}`,
                );
              }
            }
          }
        }

        await Promise.all(promises);
        console.log("Done sending reminders");
        return null;
      } catch (error) {
        console.error("Error:", error);
        return null;
      }
    });

// بتشتغل كل ساعة — تحديد الجرعات الفائتة
exports.markMissedDoses = functions.pubsub
    .schedule("every 60 minutes")
    .onRun(async (context) => {
      console.log("Marking missed doses...");

      try {
        const oneHourAgo = new Date();
        oneHourAgo.setHours(oneHourAgo.getHours() - 1);

        const logsSnapshot = await db
            .collection("intakeLogs")
            .where("status", "==", "pending")
            .where(
                "scheduledTime",
                "<=",
                admin.firestore.Timestamp.fromDate(oneHourAgo),
            )
            .get();

        const batch = db.batch();

        for (const logDoc of logsSnapshot.docs) {
          batch.update(logDoc.ref, {
            status: "missed",
            respondedAt: admin.firestore.Timestamp.now(),
          });

          // إشعار لمقدم الرعاية
          const log = logDoc.data();
          const patientId = log.patientId;

          // جلب الـ pairs
          const pairsSnapshot = await db
              .collection("pairs")
              .where("patientId", "==", patientId)
              .where("status", "==", "active")
              .get();

          for (const pairDoc of pairsSnapshot.docs) {
            const caregiverId = pairDoc.data().caregiverId;
            const caregiverDoc = await db
                .collection("users")
                .doc(caregiverId)
                .get();

            if (!caregiverDoc.exists) continue;

            const fcmToken = caregiverDoc.data().fcmToken;
            if (!fcmToken) continue;

            const patientDoc = await db
                .collection("users")
                .doc(patientId)
                .get();
            const patientName = patientDoc.exists ?
              patientDoc.data().displayName : "المريض";

            const message = {
              token: fcmToken,
              notification: {
                title: "⚠️ جرعة فائتة",
                body: `${patientName} لم يتناول ${log.medicationName}`,
              },
              data: {
                type: "missed_dose",
                patientId: patientId,
                logId: logDoc.id,
              },
              android: {
                priority: "high",
              },
            };

            await messaging.send(message).catch((err) => {
              console.error("FCM caregiver error:", err);
            });
          }
        }

        await batch.commit();
        console.log(`Marked ${logsSnapshot.size} doses as missed`);
        return null;
      } catch (error) {
        console.error("Error:", error);
        return null;
      }
      
    });
    
