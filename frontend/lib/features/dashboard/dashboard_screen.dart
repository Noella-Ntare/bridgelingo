import 'package:bridgelingo/features/dashboard/data/course_repository.dart';
import 'package:bridgelingo/features/dashboard/data/user_stats_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BridgeLingo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
               context.push('/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Daily Goal Header
            Consumer(
              builder: (context, ref, child) {
                final userStatsAsync = ref.watch(userStatsProvider);
                
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: userStatsAsync.when(
                    data: (stats) {
                      final progress = (stats.totalXp % 1000) / 1000.0;
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Level ${stats.challengeLevel}', style: Theme.of(context).textTheme.titleLarge),
                                const Gap(4),
                                Row(
                                  children: [
                                    const Icon(Icons.flash_on, color: Colors.orange, size: 20),
                                    Text('${stats.streakDays} Day Streak', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const Gap(4),
                                Text('Total XP: ${stats.totalXp}'),
                              ],
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(
                                  value: progress, 
                                  strokeWidth: 6,
                                  backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.2),
                                ),
                              ),
                              Text('${(progress * 100).toInt()}%', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, s) => Center(
                      child: Text('Error loading stats', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
                  ),
                );
              },
            ),
            const Gap(24),
            
            // Continue Learning / Courses
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft, 
                child: Text('My Courses', style: Theme.of(context).textTheme.headlineSmall)
              ),
            ),
            const Gap(16),
            
            coursesAsync.when(
              data: (courses) => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: InkWell(
                      onTap: () {
                         context.go('/dashboard/course/${course.id}', extra: course.title);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.school, size: 40),
                            ),
                            const Gap(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  const Gap(4),
                                  Text(course.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  Text(course.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const Gap(8),
                                  LinearProgressIndicator(
                                    value: course.progress, 
                                    borderRadius: BorderRadius.circular(4),
                                    backgroundColor: Colors.grey.shade300,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.play_circle_fill, size: 40, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),

    );
  }
}

extension on Object {
  get targetLanguage => null;
}
