import 'package:bridgelingo/features/dashboard/data/course_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  int _currentLevel = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    final userId = await const FlutterSecureStorage().read(key: 'user_id');
    if (userId != null) {
      try {
        final res = await ref.read(courseRepositoryProvider).dio.get('/progress/stats/$userId');
        if (mounted) {
          setState(() {
            _currentLevel = res.data['challengeLevel'] ?? 1;
            _isLoading = false;
          });
        }
      } catch (e) {
        print('Error loading level: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text('Challenge Path')),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 32,
          crossAxisSpacing: 32,
          childAspectRatio: 0.8,
        ),
        itemCount: 20, // 20 Levels for now
        itemBuilder: (context, index) {
          final level = index + 1;
          final isLocked = level > _currentLevel;
          final isCurrent = level == _currentLevel;

          return InkWell(
            onTap: isLocked ? null : () {
               context.push('/challenge/play/$level');
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: isLocked ? Colors.grey.shade300 : (isCurrent ? Colors.orange.shade100 : Colors.green.shade100),
                borderRadius: BorderRadius.circular(20),
                border: isCurrent ? Border.all(color: Colors.orange, width: 3) : null,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(
                     isLocked ? Icons.lock : (isCurrent ? Icons.play_circle_fill : Icons.check_circle),
                     size: 48,
                     color: isLocked ? Colors.grey : (isCurrent ? Colors.orange : Colors.green),
                   ),
                   const Gap(16),
                   Text(
                     "Level $level",
                     style: TextStyle(
                       fontSize: 20, 
                       fontWeight: FontWeight.bold,
                       color: isLocked ? Colors.grey.shade600 : Colors.black87
                     ),
                   ),
                   if (isCurrent)
                     const Padding(
                       padding: EdgeInsets.only(top: 8.0),
                       child: Text("Current", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                     )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
