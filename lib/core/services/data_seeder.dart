import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataSeeder {
  static final _db = FirebaseFirestore.instance;

  static Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final seeded = prefs.getBool('data_seeded') ?? false;
    if (seeded) return;

    await _seedCourses();
    await _seedChallenges();

    await prefs.setBool('data_seeded', true);
  }

  // ── COURSES ──────────────────────────────────────────────────────────────

  static Future<void> _seedCourses() async {
    final courses = [
      {
        'id': 'kinyarwanda_essentials',
        'title': 'Kinyarwanda Essentials',
        'description': 'Master the basics of Kinyarwanda',
        'level': 'BEGINNER',
        'imageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'lessons': [
          {
            'id': 'greetings',
            'title': 'Greetings',
            'orderIndex': 1,
            'content':
                '# Muraho\n**Meaning:** Hello\n---\n# Bite?\n**Meaning:** How are you?\n---\n# Ni meza\n**Meaning:** I am fine\n---\n# Mwaramutse\n**Meaning:** Good morning\n---\n# Mwiriwe\n**Meaning:** Good afternoon',
            'exercises': [
              {
                'type': 'MULTIPLE_CHOICE',
                'question': 'What does "Muraho" mean?',
                'options': ['Hello', 'Goodbye', 'Thank you', 'Please'],
                'correctAnswer': 'Hello',
              },
              {
                'type': 'MULTIPLE_CHOICE',
                'question': 'How do you say "Good morning"?',
                'options': ['Mwiriwe', 'Mwaramutse', 'Muraho', 'Bite?'],
                'correctAnswer': 'Mwaramutse',
              },
            ],
          },
          {
            'id': 'numbers',
            'title': 'Numbers',
            'orderIndex': 2,
            'content':
                '# Rimwe\n**Meaning:** One (1)\n---\n# Kabiri\n**Meaning:** Two (2)\n---\n# Gatatu\n**Meaning:** Three (3)\n---\n# Kane\n**Meaning:** Four (4)\n---\n# Gatanu\n**Meaning:** Five (5)',
            'exercises': [
              {
                'type': 'MULTIPLE_CHOICE',
                'question': 'What does "Kabiri" mean?',
                'options': ['One', 'Two', 'Three', 'Four'],
                'correctAnswer': 'Two',
              },
              {
                'type': 'MULTIPLE_CHOICE',
                'question': 'How do you say "Five" in Kinyarwanda?',
                'options': ['Kane', 'Gatatu', 'Gatanu', 'Rimwe'],
                'correctAnswer': 'Gatanu',
              },
            ],
          },
          {
            'id': 'family',
            'title': 'Family',
            'orderIndex': 3,
            'content':
                '# Umuryango\n**Meaning:** Family\n---\n# Mama\n**Meaning:** Mother\n---\n# Data\n**Meaning:** Father\n---\n# Mukuru\n**Meaning:** Elder sibling\n---\n# Murumuna\n**Meaning:** Younger sibling',
            'exercises': [
              {
                'type': 'MULTIPLE_CHOICE',
                'question': 'What does "Mama" mean?',
                'options': ['Father', 'Mother', 'Sister', 'Brother'],
                'correctAnswer': 'Mother',
              },
            ],
          },
          {
            'id': 'common_phrases',
            'title': 'Common Phrases',
            'orderIndex': 4,
            'content':
                '# Murakoze\n**Meaning:** Thank you\n---\n# Murakoze cyane\n**Meaning:** Thank you very much\n---\n# Yego\n**Meaning:** Yes\n---\n# Oya\n**Meaning:** No\n---\n# Mwiriwe\n**Meaning:** Good evening',
            'exercises': [
              {
                'type': 'MULTIPLE_CHOICE',
                'question': 'How do you say "Thank you very much"?',
                'options': ['Murakoze', 'Murakoze cyane', 'Yego', 'Oya'],
                'correctAnswer': 'Murakoze cyane',
              },
            ],
          },
          {
            'id': 'time',
            'title': 'Time',
            'orderIndex': 5,
            'content':
                '# Isaha\n**Meaning:** Hour / Time\n---\n# Uyu munsi\n**Meaning:** Today\n---\n# Ejo\n**Meaning:** Yesterday / Tomorrow\n---\n# Icyumweru\n**Meaning:** Week\n---\n# Ukwezi\n**Meaning:** Month',
            'exercises': [
              {
                'type': 'MULTIPLE_CHOICE',
                'question': 'What does "Uyu munsi" mean?',
                'options': ['Yesterday', 'Tomorrow', 'Today', 'Week'],
                'correctAnswer': 'Today',
              },
            ],
          },
        ],
      },
      {
        'id': 'vocabulary_builder',
        'title': 'Vocabulary Builder',
        'description': 'Expand your Kinyarwanda vocabulary',
        'level': 'INTERMEDIATE',
        'imageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'lessons': [
          {
            'id': 'food',
            'title': 'Food',
            'orderIndex': 1,
            'content':
                '# Ibiryo\n**Meaning:** Food\n---\n# Amazi\n**Meaning:** Water\n---\n# Inzoga\n**Meaning:** Drink\n---\n# Umuceri\n**Meaning:** Rice\n---\n# Ibirayi\n**Meaning:** Potatoes',
            'exercises': [
              {
                'type': 'MULTIPLE_CHOICE',
                'question': 'What does "Amazi" mean?',
                'options': ['Food', 'Water', 'Rice', 'Drink'],
                'correctAnswer': 'Water',
              },
            ],
          },
          {
            'id': 'colors',
            'title': 'Colors',
            'orderIndex': 2,
            'content':
                '# Umutuku\n**Meaning:** Red\n---\n# Ubururu\n**Meaning:** Blue\n---\n# Icyatsi\n**Meaning:** Green\n---\n# Umweru\n**Meaning:** White\n---\n# Umukara\n**Meaning:** Black',
            'exercises': [
              {
                'type': 'MULTIPLE_CHOICE',
                'question': 'What does "Ubururu" mean?',
                'options': ['Red', 'Blue', 'Green', 'White'],
                'correctAnswer': 'Blue',
              },
            ],
          },
          {
            'id': 'animals',
            'title': 'Animals',
            'orderIndex': 3,
            'content':
                '# Inyamaswa\n**Meaning:** Animal\n---\n# Inka\n**Meaning:** Cow\n---\n# Imbwa\n**Meaning:** Dog\n---\n# Injangwe\n**Meaning:** Cat\n---\n# Inkoko\n**Meaning:** Chicken',
            'exercises': [
              {
                'type': 'MULTIPLE_CHOICE',
                'question': 'What does "Inka" mean?',
                'options': ['Dog', 'Cat', 'Cow', 'Chicken'],
                'correctAnswer': 'Cow',
              },
            ],
          },
          {
            'id': 'weather',
            'title': 'Weather',
            'orderIndex': 4,
            'content':
                '# Ikirere\n**Meaning:** Weather / Sky\n---\n# Imvura\n**Meaning:** Rain\n---\n# Izuba\n**Meaning:** Sun\n---\n# Umuyaga\n**Meaning:** Wind\n---\n# Urubura\n**Meaning:** Snow / Hail',
            'exercises': [
              {
                'type': 'MULTIPLE_CHOICE',
                'question': 'What does "Imvura" mean?',
                'options': ['Sun', 'Wind', 'Rain', 'Snow'],
                'correctAnswer': 'Rain',
              },
            ],
          },
        ],
      },
    ];

    for (final course in courses) {
      final lessons = course['lessons'] as List;
      final courseData = Map<String, dynamic>.from(course)..remove('lessons');

      final courseRef = _db.collection('courses').doc(course['id'] as String);
      await courseRef.set(courseData);

      for (final lesson in lessons) {
        final exercises = (lesson as Map)['exercises'] as List? ?? [];
        final lessonData = Map<String, dynamic>.from(lesson)..remove('exercises');

        final lessonRef = courseRef.collection('lessons').doc(lesson['id'] as String);
        await lessonRef.set(lessonData);

        for (int i = 0; i < exercises.length; i++) {
          await lessonRef
              .collection('exercises')
              .doc('ex_$i')
              .set(exercises[i] as Map<String, dynamic>);
        }
      }
    }
  }

  // ── CHALLENGES ───────────────────────────────────────────────────────────

  static Future<void> _seedChallenges() async {
    final challengesByLevel = {
      1: [
        {'question': 'What does "Muraho" mean?', 'options': ['Hello', 'Goodbye', 'Thank you', 'Please'], 'correctAnswer': 'Hello'},
        {'question': 'What does "Murakoze" mean?', 'options': ['Yes', 'No', 'Thank you', 'Sorry'], 'correctAnswer': 'Thank you'},
        {'question': 'What does "Yego" mean?', 'options': ['Yes', 'No', 'Maybe', 'Always'], 'correctAnswer': 'Yes'},
      ],
      2: [
        {'question': 'How do you say "Good morning"?', 'options': ['Mwiriwe', 'Mwaramutse', 'Muraho', 'Bite?'], 'correctAnswer': 'Mwaramutse'},
        {'question': 'What does "Oya" mean?', 'options': ['Yes', 'No', 'Hello', 'Please'], 'correctAnswer': 'No'},
        {'question': 'What does "Kabiri" mean?', 'options': ['One', 'Two', 'Three', 'Four'], 'correctAnswer': 'Two'},
      ],
      3: [
        {'question': 'What does "Amazi" mean?', 'options': ['Food', 'Water', 'Fire', 'Earth'], 'correctAnswer': 'Water'},
        {'question': 'What does "Umuryango" mean?', 'options': ['House', 'School', 'Family', 'Friend'], 'correctAnswer': 'Family'},
        {'question': 'What does "Gatanu" mean?', 'options': ['Three', 'Four', 'Five', 'Six'], 'correctAnswer': 'Five'},
      ],
      4: [
        {'question': 'What does "Ubururu" mean?', 'options': ['Red', 'Blue', 'Green', 'Yellow'], 'correctAnswer': 'Blue'},
        {'question': 'What does "Inka" mean?', 'options': ['Dog', 'Cat', 'Cow', 'Bird'], 'correctAnswer': 'Cow'},
        {'question': 'What does "Imvura" mean?', 'options': ['Sun', 'Rain', 'Wind', 'Cloud'], 'correctAnswer': 'Rain'},
      ],
      5: [
        {'question': 'What does "Uyu munsi" mean?', 'options': ['Yesterday', 'Today', 'Tomorrow', 'Week'], 'correctAnswer': 'Today'},
        {'question': 'What does "Icyumweru" mean?', 'options': ['Day', 'Week', 'Month', 'Year'], 'correctAnswer': 'Week'},
        {'question': 'What does "Umutuku" mean?', 'options': ['Blue', 'Green', 'Red', 'White'], 'correctAnswer': 'Red'},
      ],
    };

    final batch = _db.batch();
    challengesByLevel.forEach((level, questions) {
      for (int i = 0; i < questions.length; i++) {
        final ref = _db.collection('challenges').doc('level${level}_q$i');
        batch.set(ref, {
          ...questions[i],
          'level': level,
          'type': 'MULTIPLE_CHOICE',
          'id': 'level${level}_q$i',
        });
      }
    });
    await batch.commit();
  }
}
