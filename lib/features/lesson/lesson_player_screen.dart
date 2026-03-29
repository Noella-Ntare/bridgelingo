import 'package:bridgelingo/core/components/gradient_button.dart';
import 'package:bridgelingo/features/dashboard/data/course_repository.dart';
import 'package:bridgelingo/features/dashboard/domain/course_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

// Key format: "courseId|lessonId"
final lessonDetailsProvider = FutureProvider.family<Lesson, String>((ref, params) async {
  final parts = params.split('|');
  final courseId = parts[0];
  final lessonId = parts[1];

  final doc = await FirebaseFirestore.instance
      .collection('courses')
      .doc(courseId)
      .collection('lessons')
      .doc(lessonId)
      .get();

  if (!doc.exists) {
    return Lesson(
      id: lessonId,
      title: 'Sample Lesson',
      content:
          '# Muraho\n**Meaning:** Hello\n---\n# Murakoze\n**Meaning:** Thank you\n---\n# Yego\n**Meaning:** Yes',
      orderIndex: 0,
      exercises: [
        Exercise(
          id: 'ex1',
          type: 'MULTIPLE_CHOICE',
          question: 'What does "Muraho" mean?',
          options: ['Hello', 'Goodbye', 'Thank you', 'Please'],
          correctAnswer: 'Hello',
        ),
      ],
    );
  }

  final data = doc.data()!;

  final exercisesSnap = await FirebaseFirestore.instance
      .collection('courses')
      .doc(courseId)
      .collection('lessons')
      .doc(lessonId)
      .collection('exercises')
      .get();

  final exercises = exercisesSnap.docs.map((e) => Exercise(
        id: e.id,
        type: e['type'] ?? 'MULTIPLE_CHOICE',
        question: e['question'] ?? '',
        options:
            (e['options'] as List? ?? []).map((o) => o.toString()).toList(),
        correctAnswer: e['correctAnswer'] ?? '',
      )).toList();

  return Lesson(
    id: doc.id,
    title: data['title'] ?? '',
    content: data['content'] ?? '',
    orderIndex: data['orderIndex'] ?? 0,
    exercises: exercises,
  );
});

class LessonPlayerScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final String courseId;
  final bool isLastLesson;

  const LessonPlayerScreen({
    super.key,
    required this.lessonId,
    required this.courseId,
    required this.isLastLesson,
  });

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  int _currentIndex = 0;
  bool _showSuccess = false;
  bool _showError = false;
  String _feedback = '';
  List<FlashcardContent> _flashcards = [];
  bool _parsed = false;

  @override
  Widget build(BuildContext context) {
    final key = '${widget.courseId}|${widget.lessonId}';
    final lessonAsync = ref.watch(lessonDetailsProvider(key));

    return Scaffold(
      appBar: AppBar(title: const Text('Lesson')),
      body: lessonAsync.when(
        data: (lesson) {
          if (!_parsed) {
            _parseContent(lesson.content);
            _parsed = true;
          }
          final totalItems = _flashcards.length + lesson.exercises.length;
          final progress = (_currentIndex + 1) / (totalItems + 1);

          if (_currentIndex < _flashcards.length) {
            return _buildFlashcardView(_flashcards[_currentIndex], progress);
          } else if (_currentIndex < totalItems) {
            final exerciseIndex = _currentIndex - _flashcards.length;
            return _buildExerciseSlide(
                lesson.exercises[exerciseIndex], progress);
          } else {
            return _buildCompletionSlide(lesson);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _parseContent(String rawContent) {
    _flashcards.clear();
    if (rawContent.contains('---')) {
      final parts = rawContent.split('---');
      for (var part in parts) {
        if (part.trim().isEmpty) continue;
        final lines = part.trim().split('\n');
        String term = 'Term';
        String meaning = 'Meaning';
        for (var line in lines) {
          if (line.startsWith('# ')) term = line.replaceFirst('# ', '').trim();
          if (line.startsWith('**Meaning:**')) {
            meaning = line.replaceFirst('**Meaning:**', '').trim();
          }
        }
        _flashcards.add(FlashcardContent(term: term, definition: meaning));
      }
    } else if (rawContent.contains('- **')) {
      final lines = rawContent.split('\n');
      for (var line in lines) {
        if (line.trim().startsWith('- **')) {
          final wordEnd = line.indexOf('**:');
          if (wordEnd != -1) {
            final word = line.substring(4, wordEnd).trim();
            final def = line.substring(wordEnd + 3).trim();
            _flashcards.add(FlashcardContent(term: word, definition: def));
          }
        }
      }
    }
    if (_flashcards.isEmpty) {
      _flashcards
          .add(FlashcardContent(term: 'Lesson', definition: rawContent));
    }
  }

  Widget _buildFlashcardView(FlashcardContent card, double progress) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          LinearProgressIndicator(
              value: progress, borderRadius: BorderRadius.circular(4)),
          const Gap(32),
          Expanded(
            child: FlashcardWidget(
              front: Center(
                  child: Text(card.term,
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center)),
              back: Center(
                  child: Text(card.definition,
                      style: const TextStyle(fontSize: 24),
                      textAlign: TextAlign.center)),
            ),
          ),
          const Gap(32),
          GradientButton(
              text: 'Next', onTap: () => setState(() => _currentIndex++)),
        ],
      ),
    );
  }

  Widget _buildExerciseSlide(Exercise exercise, double progress) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: progress, color: Colors.orange),
          const Gap(32),
          Text('Quiz Time!', style: Theme.of(context).textTheme.titleLarge),
          const Gap(16),
          Text(exercise.question,
              style: Theme.of(context).textTheme.headlineSmall),
          const Gap(40),
          ...exercise.options.map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _checkAnswer(option, exercise),
                    child: Text(option, style: const TextStyle(fontSize: 18)),
                  ),
                ),
              )),
          if (_showSuccess)
            Container(
              color: Colors.green.shade100,
              padding: const EdgeInsets.all(16),
              child: const Text('Correct!',
                  style: TextStyle(color: Colors.green)),
            ),
          if (_showError)
            Container(
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(16),
              child: Text(_feedback,
                  style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  void _checkAnswer(String answer, Exercise exercise) {
    if (answer.toLowerCase().trim() ==
        exercise.correctAnswer.toLowerCase().trim()) {
      setState(() {
        _showSuccess = true;
        _showError = false;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _currentIndex++;
            _showSuccess = false;
          });
        }
      });
    } else {
      setState(() {
        _showError = true;
        _showSuccess = false;
        _feedback = 'Correct: ${exercise.correctAnswer}';
      });
    }
  }

  Widget _buildCompletionSlide(Lesson lesson) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 80, color: Colors.green),
          const Gap(24),
          const Text('Lesson Complete!',
              style:
                  TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Gap(32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: GradientButton(
              text: 'Finish',
              onTap: () async {
                await ref
                    .read(courseRepositoryProvider)
                    .updateProgress(widget.courseId, 1.0);
                if (widget.isLastLesson) {
                  await ref
                      .read(courseRepositoryProvider)
                      .generateCertificate(widget.courseId, lesson.title);
                }
                if (context.mounted) context.pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FlashcardContent {
  final String term;
  final String definition;
  FlashcardContent({required this.term, required this.definition});
}

class FlashcardWidget extends StatefulWidget {
  final Widget front;
  final Widget back;
  const FlashcardWidget(
      {super.key, required this.front, required this.back});

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool _isBack = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isBack = !_isBack),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _isBack
              ? Colors.blue.shade50
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4))
          ],
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isBack ? widget.back : widget.front,
              const Gap(40),
              Icon(Icons.touch_app, color: Colors.grey.shade400),
              const Text('Tap to flip',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
