const {
  onDocumentCreated,
} = require("firebase-functions/v2/firestore");

const {
  initializeApp,
} = require("firebase-admin/app");

const {
  getFirestore,
  FieldValue,
} = require("firebase-admin/firestore");

const {
  getMessaging,
} = require("firebase-admin/messaging");

initializeApp();

exports.notifyControllerForOfficialQuiz =
  onDocumentCreated(
      "quizzes/{quizId}",
      async (event) => {
        const snapshot = event.data;

        if (!snapshot) {
          console.log("No quiz snapshot found.");
          return;
        }

        const quiz = snapshot.data();

        const quizId =
        event.params.quizId;

        // ===================================================
        // ONLY OFFICIAL QUIZZES WAITING FOR APPROVAL
        // ===================================================

        if (
          quiz.quizType !== "official" ||
        quiz.status !== "pending_approval"
        ) {
          console.log(
              "Quiz does not require Controller notification.",
          );

          return;
        }

        const db =
        getFirestore();

        const quizTitle =
        quiz.title || "Official Quiz";

        // ===================================================
        // CREATE IN-APP NOTIFICATION
        // ===================================================

        const notificationRef =
        db.collection("notifications").doc();

        await notificationRef.set({
          id: notificationRef.id,

          type:
          "official_quiz_pending",

          audienceRole:
          "controller",

          quizId:
          quizId,

          teacherId:
          quiz.teacherId || null,

          title:
          "Official Quiz Pending",

          message:
          `${quizTitle} is waiting for approval.`,

          isRead:
          false,

          createdAt:
          FieldValue.serverTimestamp(),
        });

        // ===================================================
        // GET CONTROLLER DEVICE TOKENS
        // ===================================================

        const controllersSnapshot =
        await db
            .collection("controller")
            .get();

        const tokens = [];

        controllersSnapshot.forEach(
            (controllerDoc) => {
              const controller =
            controllerDoc.data();

              const controllerTokens =
            controller.fcmTokens;

              if (
                Array.isArray(controllerTokens)
              ) {
                controllerTokens.forEach(
                    (token) => {
                      if (
                        typeof token === "string" &&
                  token.trim().length > 0
                      ) {
                        tokens.push(
                            token.trim(),
                        );
                      }
                    },
                );
              }
            },
        );

        // Remove duplicate tokens.
        const uniqueTokens =
        [...new Set(tokens)];

        if (
          uniqueTokens.length === 0
        ) {
          console.log(
              "No Controller FCM tokens found.",
          );

          return;
        }

        // ===================================================
        // FCM ALLOWS UP TO 500 TARGETS PER MULTICAST REQUEST
        // ===================================================

        for (
          let i = 0;
          i < uniqueTokens.length;
          i += 500
        ) {
          const tokenBatch =
          uniqueTokens.slice(
              i,
              i + 500,
          );

          const response =
          await getMessaging()
              .sendEachForMulticast({
                tokens:
                tokenBatch,

                notification: {
                  title:
                  "Official Quiz Pending",

                  body:
                  `${quizTitle} is waiting for your approval.`,
                },

                data: {
                  type:
                  "official_quiz_pending",

                  quizId:
                  quizId,
                },

                android: {
                  priority:
                  "high",

                  notification: {
                    channelId:
                    "quiz_approvals",
                  },
                },
              });

          console.log(
              `Successful notifications: ${response.successCount}`,
          );

          console.log(
              `Failed notifications: ${response.failureCount}`,
          );

          response.responses.forEach(
              (result, index) => {
                if (!result.success) {
                  console.error(
                      "FCM failure:",
                      tokenBatch[index],
                      result.error,
                  );
                }
              },
          );
        }
      },
  );
