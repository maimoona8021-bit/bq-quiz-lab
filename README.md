BQ Quiz Lab

BQ Quiz Lab is a role-based quiz and examination management application developed using **Flutter** and **Firebase**.

The application provides dedicated environments for **Students, Teachers, and Controllers**, allowing quizzes, official examinations, question banks, results, notifications, reports, and student performance to be managed from a single platform.


 📱 About the Project

BQ Quiz Lab is designed to provide a structured digital assessment system for educational environments.

The application separates responsibilities between three user roles:

- **Students** take quizzes and examinations and monitor their academic performance.
- **Teachers** create questions, prepare quizzes, and monitor student attempts.
- **Controllers** supervise official examinations, publish exams, release results, and manage examination activities.



👨‍🎓 Student Features

- Student registration and login
- Student dashboard
- Subject-based quiz selection
- Practice quizzes
- Official examinations
- Timed MCQ assessments
- Exam rules before starting
- Question navigation
- Flag questions for review
- Review answers before submission
- Quiz result display
- Detailed answer review
- Attempt history
- Weak-topic analysis
- Practice leaderboard
- Upcoming exams
- Student notifications
- Profile management

---

 👩‍🏫 Teacher Features

- Teacher registration and login
- Teacher dashboard
- Question bank management
- Add questions
- Edit questions
- Delete questions
- Create quizzes
- Create practice quizzes
- Create official exams
- Configure quiz duration
- Configure number of questions
- Assign quizzes to students/classes
- View student attempts
- Close quizzes
- Manage quiz settings
- Teacher profile management

---

 🛡️ Controller Features

- Controller registration and login
- Controller dashboard
- Official examination management
- Review official exams
- Publish official exams
- Release examination results
- Monitor examination activities
- View reports
- Reopen student attempts
- Record reopen reasons
- Controller notifications
- Profile management

---

## 📝 Quiz Types

### Practice Quiz

Practice quizzes allow students to strengthen their knowledge and monitor their progress.

Students can:

- View scores
- Review answers
- Monitor weak topics
- Maintain a practice streak
- Participate in the practice leaderboard

Official Exam

Official exams follow a more controlled examination workflow.

Teachers prepare the examination while Controllers are responsible for examination administration, publishing, monitoring, and result release.

---

🛠️ Technologies Used

- **Flutter**
- **Dart**
- **Firebase Authentication**
- **Cloud Firestore**
- **Firebase Cloud Functions**
- **Firebase Core**
- **OneSignal / Push Notifications**
- **Material Design**

---

🔥 Firebase Integration

Firebase is used to manage application data and authentication, including:

- User accounts
- Student profiles
- Teacher profiles
- Controller profiles
- Questions
- Quizzes
- Quiz attempts
- Results
- Notifications
- Reports
- Examination status

s

 🏗️ Project Architecture

BQ Quiz Lab follows a feature-based Flutter architecture.

```text
lib/
│
├── core/
│   ├── constants/
│   ├── navigation/
│   ├── routes/
│   ├── theme/
│   └── widgets/
│
├── features/
│   ├── auth/
│   ├── splash/
│   ├── role_selection/
│   ├── student/
│   ├── teacher/
│   └── controller/
│
├── models/
│
├── services/
│
├── firebase_options.dart
│
└── main.dart



