import 'package:bridgelingo/core/components/gradient_button.dart';
import 'package:bridgelingo/features/dashboard/data/course_repository.dart';
import 'package:bridgelingo/features/dashboard/data/user_stats_provider.dart';
import 'package:bridgelingo/features/dashboard/domain/course_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

final challengeProvider = FutureProvider.family<List<Exercise>, int>((ref, level) async {
  final repo = ref.read(courseRepositoryProvider);
  final data = await repo.getChallenges(level);
  if (data.isEmpty) {
    // Return sample challenges if Firestore is empty
    return [
      Exercise(id: '1', type: 'MULTIPLE_CHOICE', question: 'What does "Muraho" mean?',
          options: ['Hello', 'Goodbye', 'Thank you', 'Please'], correctAnswer: 'Hello'),
      Exercise(id: '2', type: 'MULTIPLE_CHOICE', question: 'How do you say "Thank you" in Kinyarwanda?',
          options: ['Murakoze', 'Yego', 'Oya', 'Muraho'], correctAnswer: 'Murakoze'),
      Exercise(id: '3', type: 'MULTIPLE_CHOICE', question: 'What does "Yego" mean?',
          options: ['Yes', 'No', 'Maybe', 'Always'], correctAnswer: 'Yes'),
    ];
  }
  return data.map((e) => Exercise(
    id: e['id']?.toString() ?? '',
    type: e['type']?.toString() ?? 'MULTIPLE_CHOICE',
    question: e['question']?.toString() ?? '',
    options: (e['options'] as List? ?? []).map((o) => o.toString()).toList(),
    correctAnswer: e['correctAnswer']?.toString() ?? '',
  )).toList();
});

class ChallengePlayerScreen extends ConsumerStatefulWidget {
  final int level;
  const ChallengePlayerScreen({super.key, required this.level});

  @override
  ConsumerState<ChallengePlayerScreen> createState() => _ChallengePlayerScreenState();
}

class _ChallengePlayerScreenState extends ConsumerState<ChallengePlayerScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _showSuccess = false;
  bool _showError = false;
  String _feedback = '';
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    final challengeAsync = ref.watch(challengeProvider(widget.level));

    return Scaffold(
      appBar: AppBar(title: Text('Challenge Level ${widget.level}')),
      body: challengeAsync.when(
        data: (exercises) {
          if (_isCompleted) return _buildCompletionSlide(exercises.length);
          if (_currentIndex >= exercises.length) return _buildCompletionSlide(exercises.length);
          final exercise = exercises[_currentIndex];
          final progress = (_currentIndex + 1) / exercises.length;
          return _buildExerciseSlide(exercise, progress, exercises.length);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildExerciseSlide(Exercise exercise, double progress, int total) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: progress, color: Colors.orange),
          const Gap(16),
          Text('Question ${_currentIndex + 1} / $total', style: const TextStyle(color: Colors.grey)),
          const Gap(32),
          Text(exercise.question, style: Theme.of(context).textTheme.headlineSmall),
          const Gap(40),
          ...exercise.options.map((option) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _checkAnswer(option, exercise, total),
                child: Text(option, style: const TextStyle(fontSize: 18)),
              ),
            ),
          )),
          if (_showSuccess)
            Container(
              color: Colors.green.shade100,
              padding: const EdgeInsets.all(16),
              child: const Text('Correct!', style: TextStyle(color: Colors.green)),
            ),
          if (_showError)
            Container(
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(16),
              child: Text(_feedback, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  void _checkAnswer(String answer, Exercise exercise, int total) {
    final correct = answer.toLowerCase().trim() == exercise.correctAnswer.toLowerCase().trim();
    if (correct) {
      _score++;
      setState(() { _showSuccess = true; _showError = false; });
    } else {
      setState(() { _showError = true; _showSuccess = false; _feedback = 'Correct: ${exercise.correctAnswer}'; });
    }
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _showSuccess = false;
          _showError = false;
          if (_currentIndex < total - 1) {
            _currentIndex++;
          } else {
            _isCompleted = true;
          }
        });
      }
    });
  }

  Widget _buildCompletionSlide(int total) {
    final passed = _score >= (total * 0.7).ceil();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            passed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            size: 80,
            color: passed ? Colors.orange : Colors.grey,
          ),
          const Gap(24),
          Text(
            passed ? 'Challenge Completed! 🎉' : 'Challenge Failed',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Gap(16),
          Text('Score: $_score / $total'),
          if (passed)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Next level unlocked!',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          const Gap(32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: GradientButton(
              text: passed ? 'Claim Rewards & Continue' : 'Try Again',
              onTap: () async {
                await ref.read(courseRepositoryProvider)
                    .saveChallengeResult(widget.level, passed);
                // Refresh stats so challenges screen unlocks next level
                ref.invalidate(userStatsProvider);
                if (context.mounted) context.pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
