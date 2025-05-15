const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.notifyOnNewTask = functions.firestore
  .document("tasks/{taskId}")
  .onCreate((snap, context) => {
    const task = snap.data();
    const fcmToken = task.assignedToToken; // Save this in Firestore

    const message = {
      notification: {
        title: "New Task!",
        body: `Task: ${task.title}`,
      },
      token: fcmToken,
    };

    return admin.messaging().send(message);
  });
