import 'package:bridgelingo/features/dashboard/data/user_stats_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Challenge Path')),
      body: statsAsync.when(
        data: (stats) => GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 32,
            crossAxisSpacing: 32,
            childAspectRatio: 0.8,
          ),
          itemCount: 20,
          itemBuilder: (context, index) {
            final level = index + 1;
            final isLocked = level > stats.challengeLevel;
            final isCurrent = level == stats.challengeLevel;

            return InkWell(
              onTap: isLocked ? null : () => context.push('/challenge/play/$level'),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.grey.shade300
                      : (isCurrent ? Colors.orange.shade100 : Colors.green.shade100),
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
                      'Level $level',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Colors.grey.shade600 : Colors.black87,
                      ),
                    ),
                    if (isCurrent)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Current', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Could not load challenges')),
      ),
    );
  }
}
