const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const auth = admin.auth();
const Timestamp = admin.firestore.Timestamp;

const PASSWORD = 'admin123';
const CLASS_BATCH = 'Batch 14';
const CAMPUS = 'Bano Qabil';
const SUBJECTS = ['Flutter', 'Web Dev', 'Cybersecurity', 'English', 'Islamiat'];

const QUESTION_BANKS = {
  "Flutter": [
    [
      "Which language is primarily used with Flutter?",
      "Dart",
      "Java",
      "Python",
      "PHP",
      "Flutter apps are primarily written in Dart."
    ],
    [
      "Which function attaches the root widget to the Flutter view?",
      "runApp()",
      "startApp()",
      "buildApp()",
      "mainWidget()",
      "runApp() attaches the root widget to the Flutter view."
    ],
    [
      "Which widget is used when UI does not need mutable state?",
      "StatelessWidget",
      "StatefulWidget",
      "StreamBuilder",
      "FutureBuilder",
      "StatelessWidget is used when mutable state is not required."
    ],
    [
      "Which method schedules a rebuild after State changes?",
      "setState()",
      "refresh()",
      "reload()",
      "updateUI()",
      "setState() tells Flutter that state changed and the widget should rebuild."
    ],
    [
      "Which file declares Flutter dependencies?",
      "pubspec.yaml",
      "main.dart",
      "firebase.json",
      "settings.gradle",
      "Flutter dependencies are declared in pubspec.yaml."
    ],
    [
      "Which widget configures a Material app?",
      "MaterialApp",
      "Container",
      "Column",
      "Padding",
      "MaterialApp provides app-level Material configuration."
    ],
    [
      "Which widget provides a page structure with AppBar and body?",
      "Scaffold",
      "Expanded",
      "Text",
      "Center",
      "Scaffold provides the common Material page structure."
    ],
    [
      "Which Dart type represents one asynchronous result?",
      "Future",
      "String",
      "Map",
      "Set",
      "Future represents a value that may complete later."
    ],
    [
      "Which widget displays a scrollable list?",
      "ListView",
      "Row",
      "Stack",
      "SizedBox",
      "ListView is designed for scrollable lists."
    ],
    [
      "What does hot reload mainly help with?",
      "Applying many code changes quickly while preserving app state",
      "Publishing to Play Store",
      "Creating Firestore rules",
      "Converting Dart to Java",
      "Hot reload speeds development by updating a running app."
    ],
    [
      "Which widget is used when UI depends on mutable state?",
      "StatefulWidget",
      "StatelessWidget",
      "Icon",
      "Divider",
      "StatefulWidget is used when UI can change over time."
    ],
    [
      "Which widget arranges children horizontally?",
      "Row",
      "Column",
      "Stack",
      "Wrap",
      "Row lays out children horizontally."
    ],
    [
      "Which widget arranges children vertically?",
      "Column",
      "Row",
      "Align",
      "Stack",
      "Column lays out children vertically."
    ],
    [
      "Which widget is commonly used to add fixed spacing?",
      "SizedBox",
      "Scaffold",
      "Navigator",
      "Theme",
      "SizedBox can provide fixed width or height spacing."
    ],
    [
      "Which keyword waits for a Future in an async function?",
      "await",
      "yield",
      "final",
      "sync",
      "await waits for a Future to complete."
    ],
    [
      "Which class manages the Flutter route stack?",
      "Navigator",
      "MediaQuery",
      "ThemeData",
      "BuildContext",
      "Navigator manages routes."
    ],
    [
      "Which widget rebuilds from a Stream?",
      "StreamBuilder",
      "TextField",
      "Card",
      "Spacer",
      "StreamBuilder reacts to Stream snapshots."
    ],
    [
      "Which widget rebuilds when a Future completes?",
      "FutureBuilder",
      "InkWell",
      "Padding",
      "SafeArea",
      "FutureBuilder reacts to a Future's state and result."
    ],
    [
      "What does Expanded do in a Row or Column?",
      "Uses remaining available space",
      "Creates a new route",
      "Starts animation",
      "Listens to Firestore",
      "Expanded fills available space on the main axis."
    ],
    [
      "Which widget helps avoid system notches and status bars?",
      "SafeArea",
      "Opacity",
      "Hero",
      "Center",
      "SafeArea adds padding around system intrusions."
    ]
  ],
  "Web Dev": [
    [
      "Which language defines web page structure?",
      "HTML",
      "CSS",
      "SQL",
      "Dart",
      "HTML defines web page structure."
    ],
    [
      "Which technology is mainly used for styling web pages?",
      "CSS",
      "HTML",
      "SQL",
      "HTTP",
      "CSS controls presentation and layout."
    ],
    [
      "Which language commonly adds browser interactivity?",
      "JavaScript",
      "CSS",
      "HTML",
      "Markdown",
      "JavaScript commonly provides client-side interactivity."
    ],
    [
      "What does HTTP primarily define?",
      "Communication between web clients and servers",
      "Database schemas",
      "Image compression",
      "OS permissions",
      "HTTP defines request-response communication on the web."
    ],
    [
      "Which HTTP method normally retrieves data?",
      "GET",
      "DELETE",
      "PATCH",
      "POST",
      "GET is normally used to retrieve a resource."
    ],
    [
      "What does HTTP 404 mean?",
      "Resource not found",
      "Success",
      "Unauthorized",
      "Permanent redirect",
      "404 means the requested resource was not found."
    ],
    [
      "Which HTML element represents navigation?",
      "<nav>",
      "<img>",
      "<table>",
      "<strong>",
      "The nav element represents navigation content."
    ],
    [
      "Which CSS feature supports responsive styles by screen size?",
      "Media queries",
      "Cookies",
      "SQL joins",
      "HTTP headers",
      "Media queries apply CSS based on device or viewport conditions."
    ],
    [
      "Which browser feature stores persistent key-value data?",
      "localStorage",
      "DNS",
      "DOCTYPE",
      "HTTP 404",
      "localStorage stores persistent key-value data in the browser."
    ],
    [
      "Which term describes a resource-oriented HTTP API style?",
      "REST",
      "CSS",
      "SMTP",
      "FTP",
      "REST is a common resource-oriented API style."
    ],
    [
      "Which HTML tag creates a hyperlink?",
      "<a>",
      "<p>",
      "<div>",
      "<span>",
      "The anchor element creates hyperlinks."
    ],
    [
      "Which CSS property changes text color?",
      "color",
      "font-size",
      "display",
      "margin",
      "The color property changes text color."
    ],
    [
      "Which CSS property controls space inside a border?",
      "padding",
      "margin",
      "position",
      "opacity",
      "Padding is inside the border."
    ],
    [
      "Which CSS property controls space outside a border?",
      "margin",
      "padding",
      "height",
      "overflow",
      "Margin is outside the border."
    ],
    [
      "What does DOM stand for?",
      "Document Object Model",
      "Data Object Method",
      "Display Order Map",
      "Document Output Mode",
      "DOM means Document Object Model."
    ],
    [
      "Which JavaScript keyword declares a block-scoped reassignable variable?",
      "let",
      "const",
      "class",
      "import",
      "let declares a block-scoped variable that may be reassigned."
    ],
    [
      "Which method parses JSON text into a JavaScript value?",
      "JSON.parse()",
      "JSON.stringify()",
      "JSON.read()",
      "JSON.open()",
      "JSON.parse() parses JSON text."
    ],
    [
      "Which HTTP code usually means success?",
      "200",
      "404",
      "500",
      "401",
      "200 OK indicates success."
    ],
    [
      "Which HTTP code usually means internal server error?",
      "500",
      "201",
      "301",
      "204",
      "500 indicates an internal server error."
    ],
    [
      "Which element is normally the highest-level heading?",
      "<h1>",
      "<p>",
      "<li>",
      "<em>",
      "h1 is the highest-level HTML heading."
    ]
  ],
  "Cybersecurity": [
    [
      "What is phishing?",
      "A fraudulent attempt to trick users into revealing sensitive information",
      "File compression",
      "Database backup",
      "Software update",
      "Phishing uses deception to steal information or access."
    ],
    [
      "What does MFA improve?",
      "Account security by requiring multiple factors",
      "Screen resolution",
      "Internet speed",
      "File compression",
      "MFA requires more than one authentication factor."
    ],
    [
      "Which process is commonly used for one-way password representation?",
      "Hashing",
      "Printing",
      "Sorting",
      "Rendering",
      "Hashing creates a one-way digest."
    ],
    [
      "HTTPS normally uses which protocol for protection?",
      "TLS",
      "CSS",
      "HTML",
      "SQL",
      "HTTPS uses TLS."
    ],
    [
      "Which password practice is strongest?",
      "Use a long unique password for each account",
      "Reuse one short password",
      "Share passwords",
      "Post passwords publicly",
      "Long unique passwords reduce reuse and guessing risk."
    ],
    [
      "What is ransomware?",
      "Malware that blocks or encrypts data and demands payment",
      "Web framework",
      "Browser theme",
      "Query language",
      "Ransomware restricts access and demands payment."
    ],
    [
      "What does least privilege mean?",
      "Give only permissions needed for a task",
      "Give everyone admin access",
      "Make every file public",
      "Disable passwords",
      "Least privilege limits access to necessary permissions."
    ],
    [
      "What is a firewall mainly used for?",
      "Controlling network traffic by rules",
      "Editing photos",
      "Compiling Flutter",
      "Creating spreadsheets",
      "Firewalls allow or block network traffic."
    ],
    [
      "SQL injection exploits what?",
      "Unsafe handling of input in database queries",
      "Low brightness",
      "Slow bandwidth",
      "Image size",
      "SQL injection targets unsafe query construction."
    ],
    [
      "Why are security patches important?",
      "They fix known vulnerabilities and bugs",
      "They provide unlimited storage",
      "They remove passwords",
      "They replace every firewall",
      "Patches often fix vulnerabilities."
    ],
    [
      "What is social engineering?",
      "Manipulating people into unsafe actions or disclosure",
      "Compressing files",
      "Routing packets",
      "Indexing databases",
      "Social engineering targets human behavior."
    ],
    [
      "What is malware?",
      "Software designed to harm or gain unauthorized access",
      "Secure password manager",
      "Cable standard",
      "Spreadsheet formula",
      "Malware is malicious software."
    ],
    [
      "What is a brute-force attack?",
      "Trying many credentials until one works",
      "Backing up files",
      "Encrypting data for safety",
      "Updating rules",
      "Brute force tries many possible credentials."
    ],
    [
      "What best protects against hardware data loss?",
      "Tested backups",
      "Short passwords",
      "Disabled updates",
      "Shared admin account",
      "Backups provide recoverable copies."
    ],
    [
      "What does encryption do?",
      "Transforms readable data into protected ciphertext",
      "Deletes metadata",
      "Compresses every file",
      "Removes authentication",
      "Encryption protects confidentiality."
    ],
    [
      "What is access control for?",
      "Restricting resources to authorized users or processes",
      "Increasing brightness",
      "Loading images faster",
      "Replacing updates",
      "Access control determines who may access resources."
    ],
    [
      "Which attack overwhelms a service with traffic?",
      "Denial-of-service",
      "Schema migration",
      "Code formatting",
      "Version control",
      "DoS attacks attempt to make a service unavailable."
    ],
    [
      "What is two-factor authentication?",
      "Using two different authentication factor categories",
      "Using one password twice",
      "Using two browsers",
      "Changing username twice",
      "2FA uses two different factor categories."
    ],
    [
      "Why keep software updated?",
      "Updates may fix vulnerabilities and bugs",
      "Updates eliminate passwords",
      "Updates stop all phishing",
      "Updates replace backups",
      "Updates frequently include security fixes."
    ],
    [
      "What is a vulnerability?",
      "A weakness that may be exploited",
      "A secure configuration",
      "A backup copy",
      "A network cable",
      "A vulnerability is an exploitable weakness."
    ]
  ],
  "English": [
    [
      "Which word is a noun in 'The teacher explained the lesson clearly'?",
      "teacher",
      "explained",
      "clearly",
      "the",
      "Teacher names a person and is a noun."
    ],
    [
      "Which word is a verb in 'Students complete assignments daily'?",
      "complete",
      "Students",
      "assignments",
      "daily",
      "Complete expresses the action."
    ],
    [
      "Which word is an adjective in 'She bought a beautiful notebook'?",
      "beautiful",
      "bought",
      "notebook",
      "she",
      "Beautiful describes notebook."
    ],
    [
      "Which word is an adverb in 'He answered quickly'?",
      "quickly",
      "answered",
      "He",
      "answer",
      "Quickly modifies answered."
    ],
    [
      "Which sentence uses the correct plural?",
      "The children are playing.",
      "The childs are playing.",
      "The childrens are playing.",
      "The childes are playing.",
      "Children is the correct irregular plural of child."
    ],
    [
      "Which sentence is simple past?",
      "She visited the library yesterday.",
      "She visits the library every day.",
      "She will visit tomorrow.",
      "She is visiting now.",
      "Visited is simple past."
    ],
    [
      "Which sentence is simple future?",
      "They will start tomorrow.",
      "They start daily.",
      "They started yesterday.",
      "They are starting now.",
      "Will start expresses future time."
    ],
    [
      "Which sentence has correct subject-verb agreement?",
      "He studies every evening.",
      "He study every evening.",
      "He studying every evening.",
      "He are studying every evening.",
      "He takes studies in the simple present."
    ],
    [
      "Choose the correct article: 'She bought ___ umbrella.'",
      "an",
      "a",
      "the only",
      "no article",
      "Umbrella begins with a vowel sound, so an is appropriate."
    ],
    [
      "Which word is a synonym of 'rapid'?",
      "fast",
      "slow",
      "weak",
      "quiet",
      "Fast is a synonym of rapid."
    ],
    [
      "Which word is an antonym of 'ancient'?",
      "modern",
      "old",
      "historic",
      "traditional",
      "Modern contrasts with ancient."
    ],
    [
      "Which sentence is punctuated correctly?",
      "Where are you going?",
      "Where are you going.",
      "Where are you going!",
      "Where are you going,",
      "A direct question ends with a question mark."
    ],
    [
      "Which sentence uses 'their' correctly?",
      "The students submitted their projects.",
      "The students submitted there projects.",
      "The students submitted they're projects.",
      "The students submitted them projects.",
      "Their is the possessive determiner."
    ],
    [
      "Complete: 'I have ___ my homework.'",
      "finished",
      "finish",
      "finishing",
      "finishes",
      "Have is followed by the past participle finished."
    ],
    [
      "Which sentence is passive voice?",
      "The report was written by Sara.",
      "Sara wrote the report.",
      "Sara is writing the report.",
      "Sara writes reports.",
      "Was written is passive voice."
    ],
    [
      "Complete: 'I studied hard, ___ I passed the test.'",
      "so",
      "but",
      "or",
      "although",
      "So expresses the result."
    ],
    [
      "Which sentence contains a preposition?",
      "The book is on the table.",
      "The book reads well.",
      "Books are useful.",
      "Read the book.",
      "On is a preposition."
    ],
    [
      "Which word is a pronoun?",
      "they",
      "teacher",
      "quickly",
      "blue",
      "They is a pronoun."
    ],
    [
      "Which sentence is grammatically correct?",
      "She does not like coffee.",
      "She do not like coffee.",
      "She does not likes coffee.",
      "She not likes coffee.",
      "Does not is followed by the base form like."
    ],
    [
      "Complete: 'If it rains, we ___ stay inside.'",
      "will",
      "would have",
      "had",
      "were",
      "A first conditional commonly uses will in the main clause."
    ]
  ],
  "Islamiat": [
    [
      "How many pillars of Islam are commonly recognized?",
      "Five",
      "Three",
      "Six",
      "Seven",
      "There are five pillars of Islam."
    ],
    [
      "Which pillar is the declaration of faith?",
      "Shahadah",
      "Zakah",
      "Sawm",
      "Hajj",
      "Shahadah is the declaration of faith."
    ],
    [
      "How many obligatory daily prayers are there?",
      "Five",
      "Three",
      "Four",
      "Seven",
      "There are five obligatory daily prayers."
    ],
    [
      "Which month is associated with obligatory fasting?",
      "Ramadan",
      "Muharram",
      "Safar",
      "Rajab",
      "Fasting in Ramadan is one of the five pillars."
    ],
    [
      "What is Zakah?",
      "Obligatory charity on qualifying wealth",
      "A daily prayer",
      "A pilgrimage site",
      "A calendar month",
      "Zakah is obligatory charity on qualifying wealth."
    ],
    [
      "What is Hajj?",
      "Pilgrimage to Makkah",
      "Daily prayer",
      "Voluntary fasting only",
      "A type of charity",
      "Hajj is the pilgrimage to Makkah."
    ],
    [
      "Which direction do Muslims face during Salah?",
      "Toward the Ka'bah in Makkah",
      "Toward Madinah",
      "Toward Cairo",
      "Any random direction",
      "The qiblah is toward the Ka'bah in Makkah."
    ],
    [
      "What is the Qur'an?",
      "The central revealed scripture of Islam",
      "A geography book",
      "Only a calendar",
      "A modern law book",
      "The Qur'an is Islam's central revealed scripture."
    ],
    [
      "Which angel is associated with bringing revelation to Prophet Muhammad ﷺ?",
      "Jibril",
      "Mikail",
      "Israfil",
      "Malik",
      "Jibril is associated with conveying revelation."
    ],
    [
      "Which prayer is performed just after sunset?",
      "Maghrib",
      "Fajr",
      "Dhuhr",
      "Asr",
      "Maghrib begins after sunset."
    ],
    [
      "Which prayer is performed before sunrise?",
      "Fajr",
      "Maghrib",
      "Isha",
      "Asr",
      "Fajr is the dawn prayer."
    ],
    [
      "What does Sawm refer to?",
      "Fasting",
      "Pilgrimage",
      "Charity",
      "Declaration of faith",
      "Sawm means fasting."
    ],
    [
      "Which city contains the Ka'bah?",
      "Makkah",
      "Madinah",
      "Cairo",
      "Damascus",
      "The Ka'bah is in Makkah."
    ],
    [
      "What is Wudu?",
      "Ritual ablution before prayer",
      "Pilgrimage",
      "Charity",
      "A month of fasting",
      "Wudu is ritual purification."
    ],
    [
      "Which day has the special congregational Jumu'ah prayer?",
      "Friday",
      "Monday",
      "Tuesday",
      "Thursday",
      "Jumu'ah is held on Friday."
    ],
    [
      "What is the first month of the Islamic calendar?",
      "Muharram",
      "Ramadan",
      "Shawwal",
      "Rajab",
      "Muharram is the first Hijri month."
    ],
    [
      "What does Masjid mean?",
      "Mosque or place of prostration",
      "Market",
      "School only",
      "House",
      "Masjid refers to a mosque or place of prostration."
    ],
    [
      "What does Eid al-Fitr mark?",
      "The end of Ramadan",
      "The beginning of Hajj",
      "The start of Muharram",
      "The start of the daily fast",
      "Eid al-Fitr marks the end of Ramadan."
    ],
    [
      "Eid al-Adha occurs during which Islamic month?",
      "Dhul-Hijjah",
      "Ramadan",
      "Safar",
      "Rabi al-Awwal",
      "Eid al-Adha occurs in Dhul-Hijjah during the Hajj season."
    ],
    [
      "Which source, with the Qur'an, is foundational for understanding the Prophet's teachings and practice?",
      "Sunnah",
      "Geography",
      "Poetry only",
      "Astronomy",
      "The Sunnah records the Prophet's teachings, actions, and approvals."
    ]
  ]
};

async function createOrUpdateAuthUser(email, displayName) {
  try {
    const user = await auth.getUserByEmail(email);
    return await auth.updateUser(user.uid, {
      password: PASSWORD,
      displayName,
      emailVerified: true,
      disabled: false,
    });
  } catch (e) {
    if (e.code !== 'auth/user-not-found') throw e;

    return await auth.createUser({
      email,
      password: PASSWORD,
      displayName,
      emailVerified: true,
      disabled: false,
    });
  }
}

function slug(text) {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');
}

function dateOffset(days, hour = 10) {
  const d = new Date();
  d.setDate(d.getDate() + days);
  d.setHours(hour, 0, 0, 0);
  return d;
}

async function seed() {
  console.log('Starting BQ Quiz Lab seed...');

  const studentUser = await createOrUpdateAuthUser(
    'student@banoqabil.org',
    'Demo Student'
  );

  const teacherUser = await createOrUpdateAuthUser(
    'teacher@banoqabil.org',
    'Demo Teacher'
  );

  const controllerUser = await createOrUpdateAuthUser(
    'exam@banoqabil.org',
    'Exam Controller'
  );

  await db.collection('student').doc(studentUser.uid).set({
    uid: studentUser.uid,
    name: 'Demo Student',
    email: 'student@banoqabil.org',
    role: 'student',
    classBatch: CLASS_BATCH,
    campus: CAMPUS,
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  }, {merge: true});

  await db.collection('teacher').doc(teacherUser.uid).set({
    uid: teacherUser.uid,
    name: 'Demo Teacher',
    email: 'teacher@banoqabil.org',
    role: 'teacher',
    departmentCourse: 'Flutter Development',
    campus: CAMPUS,
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  }, {merge: true});

  await db.collection('controller').doc(controllerUser.uid).set({
    uid: controllerUser.uid,
    name: 'Exam Controller',
    email: 'exam@banoqabil.org',
    role: 'controller',
    designation: 'Examination Controller',
    campus: CAMPUS,
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  }, {merge: true});

  const students = [
    {id: studentUser.uid, name: 'Demo Student', email: 'student@banoqabil.org'},
    {id: 'seed_student_02', name: 'Ali Khan', email: 'ali.seed@banoqabil.org'},
    {id: 'seed_student_03', name: 'Ayesha Ahmed', email: 'ayesha.seed@banoqabil.org'},
    {id: 'seed_student_04', name: 'Hamza Malik', email: 'hamza.seed@banoqabil.org'},
    {id: 'seed_student_05', name: 'Fatima Noor', email: 'fatima.seed@banoqabil.org'},
    {id: 'seed_student_06', name: 'Usman Tariq', email: 'usman.seed@banoqabil.org'},
    {id: 'seed_student_07', name: 'Zainab Ali', email: 'zainab.seed@banoqabil.org'},
    {id: 'seed_student_08', name: 'Bilal Ahmed', email: 'bilal.seed@banoqabil.org'},
  ];

  for (const s of students) {
    await db.collection('student').doc(s.id).set({
      uid: s.id,
      name: s.name,
      email: s.email,
      role: 'student',
      classBatch: CLASS_BATCH,
      campus: CAMPUS,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    }, {merge: true});
  }

  for (const subject of SUBJECTS) {
    const id = slug(subject);
    await db.collection('subjects').doc(id).set({
      id,
      name: subject,
      active: true,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    }, {merge: true});
  }

  const ids = {};
  const correctMap = {};

  for (const subject of SUBJECTS) {
    const questions = QUESTION_BANKS[subject];

    if (!questions || questions.length !== 20) {
      throw new Error(`${subject} must contain exactly 20 questions`);
    }

    ids[subject] = [];

    for (let i = 0; i < questions.length; i++) {
      const [questionText, correct, wrong1, wrong2, wrong3, explanation] =
        questions[i];

      const qid = `${slug(subject)}_q_${String(i + 1).padStart(2, '0')}`;

      // Rotate the correct answer position so every answer is not option 0.
      const correctIndex = i % 4;
      const options = [wrong1, wrong2, wrong3];
      options.splice(correctIndex, 0, correct);

      ids[subject].push(qid);
      correctMap[qid] = correctIndex;

      await db.collection('questions').doc(qid).set({
        id: qid,
        teacherId: teacherUser.uid,
        subject,
        difficulty: i < 7 ? 'easy' : i < 14 ? 'medium' : 'hard',
        questionText,
        options,
        correctIndex,
        explanation,
        imageUrl: null,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      }, {merge: true});
    }
  }

  const practice1Id = 'seed_practice_flutter_01';
  const practice2Id = 'seed_practice_web_01';
  const officialId = 'seed_official_flutter_01';

  const twoDaysAgo = dateOffset(-2, 9);
  const yesterday = dateOffset(-1, 11);
  const tomorrow = dateOffset(1, 10);

  const flutterIds = ids['Flutter'];
  const webIds = ids['Web Dev'];

  await db.collection('quizzes').doc(practice1Id).set({
    id: practice1Id,
    teacherId: teacherUser.uid,
    title: 'Flutter Basics Practice',
    description: 'Past practice quiz covering Flutter fundamentals.',
    subject: 'Flutter',
    quizType: 'practice',
    durationMinutes: 10,
    passingPercentage: 60,
    classBatch: CLASS_BATCH,
    questionIds: flutterIds.slice(0, 10),
    status: 'closed',
    leaderboardVisible: true,
    publishedAt: Timestamp.fromDate(twoDaysAgo),
    closedAt: Timestamp.fromDate(yesterday),
    createdAt: Timestamp.fromDate(twoDaysAgo),
    updatedAt: Timestamp.now(),
  }, {merge: true});

  await db.collection('quizzes').doc(practice2Id).set({
    id: practice2Id,
    teacherId: teacherUser.uid,
    title: 'Web Development Practice',
    description: 'Past practice quiz covering web development.',
    subject: 'Web Dev',
    quizType: 'practice',
    durationMinutes: 12,
    passingPercentage: 60,
    classBatch: CLASS_BATCH,
    questionIds: webIds.slice(0, 10),
    status: 'closed',
    leaderboardVisible: true,
    publishedAt: Timestamp.fromDate(twoDaysAgo),
    closedAt: Timestamp.fromDate(yesterday),
    createdAt: Timestamp.fromDate(twoDaysAgo),
    updatedAt: Timestamp.now(),
  }, {merge: true});

  await db.collection('quizzes').doc(officialId).set({
    id: officialId,
    teacherId: teacherUser.uid,
    title: 'Flutter Official Exam',
    description: 'Official Flutter exam scheduled for tomorrow.',
    subject: 'Flutter',
    quizType: 'official',
    durationMinutes: 20,
    passingPercentage: 60,
    classBatch: CLASS_BATCH,
    questionIds: flutterIds.slice(10, 20),
    status: 'published',
    leaderboardVisible: false,
    approvedBy: controllerUser.uid,
    approvedAt: Timestamp.now(),
    publishedAt: Timestamp.now(),
    scheduledAt: Timestamp.fromDate(tomorrow),
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  }, {merge: true});

  function makeAnswers(questionIds, correctCount) {
    const answers = {};

    questionIds.forEach((qid, index) => {
      const correct = correctMap[qid];
      answers[qid] = index < correctCount ? correct : (correct + 1) % 4;
    });

    return answers;
  }

  const p1Ids = flutterIds.slice(0, 10);
  const p2Ids = webIds.slice(0, 10);
  const scores1 = [9, 8, 7, 10, 6, 9, 8, 7];
  const scores2 = [8, 7, 9, 8, 10, 6, 7, 9];

  for (let i = 0; i < students.length; i++) {
    const s = students[i];

    const a1 = `seed_p1_attempt_${String(i + 1).padStart(2, '0')}`;
    await db.collection('attempts').doc(a1).set({
      id: a1,
      quizId: practice1Id,
      quizTitle: 'Flutter Basics Practice',
      quizType: 'practice',
      teacherId: teacherUser.uid,
      studentId: s.id,
      studentName: s.name,
      classBatch: CLASS_BATCH,
      status: 'submitted',
      answers: makeAnswers(p1Ids, scores1[i]),
      flaggedQuestionIds: [],
      score: scores1[i],
      percentage: scores1[i] * 10,
      timeTakenSeconds: 420 + i * 15,
      resultReleased: true,
      startedAt: Timestamp.fromDate(twoDaysAgo),
      submittedAt: Timestamp.fromDate(twoDaysAgo),
      updatedAt: Timestamp.now(),
    }, {merge: true});

    const a2 = `seed_p2_attempt_${String(i + 1).padStart(2, '0')}`;
    await db.collection('attempts').doc(a2).set({
      id: a2,
      quizId: practice2Id,
      quizTitle: 'Web Development Practice',
      quizType: 'practice',
      teacherId: teacherUser.uid,
      studentId: s.id,
      studentName: s.name,
      classBatch: CLASS_BATCH,
      status: 'submitted',
      answers: makeAnswers(p2Ids, scores2[i]),
      flaggedQuestionIds: [],
      score: scores2[i],
      percentage: scores2[i] * 10,
      timeTakenSeconds: 480 + i * 15,
      resultReleased: true,
      startedAt: Timestamp.fromDate(yesterday),
      submittedAt: Timestamp.fromDate(yesterday),
      updatedAt: Timestamp.now(),
    }, {merge: true});
  }

  // Hidden official result belongs to another student, so the demo Student
  // still has the official exam available "tomorrow".
  const hiddenStudent = students[1];
  const officialQids = flutterIds.slice(10, 20);

  await db.collection('attempts').doc('seed_official_hidden_attempt_01').set({
    id: 'seed_official_hidden_attempt_01',
    quizId: officialId,
    quizTitle: 'Flutter Official Exam',
    quizType: 'official',
    teacherId: teacherUser.uid,
    studentId: hiddenStudent.id,
    studentName: hiddenStudent.name,
    classBatch: CLASS_BATCH,
    status: 'submitted',
    answers: makeAnswers(officialQids, 8),
    flaggedQuestionIds: [],
    score: 8,
    percentage: 80,
    timeTakenSeconds: 900,
    resultReleased: false,
    startedAt: Timestamp.now(),
    submittedAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  }, {merge: true});

  console.log('\nSEED COMPLETE');
  console.log('student@banoqabil.org / admin123');
  console.log('teacher@banoqabil.org / admin123');
  console.log('exam@banoqabil.org / admin123');
  console.log('5 subjects, 100 questions, 2 practice quizzes, 1 official exam');
  console.log('8 students in attempts/leaderboard');
  console.log('1 hidden official result');
}

seed()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error('SEED FAILED:', error);
    process.exit(1);
  });
