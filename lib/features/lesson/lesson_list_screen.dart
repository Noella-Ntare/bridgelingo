import 'package:bridgelingo/features/dashboard/data/course_repository.dart';
import 'package:bridgelingo/features/dashboard/domain/course_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

final courseLessonsProvider = FutureProvider.family<List<Lesson>, String>((ref, courseId) async {
  final snap = await FirebaseFirestore.instance
      .collection('courses')
      .doc(courseId)
      .collection('lessons')
      .orderBy('orderIndex')
      .get();

  return snap.docs.map((doc) => Lesson(
    id: doc.id,
    title: doc['title'] ?? '',
    content: doc['content'] ?? '',
    orderIndex: doc['orderIndex'] ?? 0,
  )).toList();
});

class LessonListScreen extends ConsumerWidget {
  final String courseId;
  final String courseTitle;

  const LessonListScreen({super.key, required this.courseId, required this.courseTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(courseLessonsProvider(courseId));

    return Scaffold(
      body: lessonsAsync.when(
        data: (lessons) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(courseTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.tertiary,
                      ],
                    ),
                  ),
                  child: const Center(child: Icon(Icons.school, size: 80, color: Colors.white24)),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: lessons.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text('No lessons yet. Check back soon!'),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final lesson = lessons[index];
                          return _LessonCard(
                            lesson: lesson,
                            index: index,
                            isLocked: false,
                            onTap: () => context.push('/lesson/${lesson.id}', extra: {
                              'courseId': courseId,
                              'isLastLesson': index == lessons.length - 1,
                            }),
                          );
                        },
                        childCount: lessons.length,
                      ),
                    ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final bool isLocked;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.index,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isLocked
                      ? Colors.grey.shade300
                      : Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: isLocked ? Colors.grey : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isLocked ? Colors.grey : null,
                      ),
                    ),
                    const Gap(4),
                    Text('Tap to start', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              Icon(
                isLocked ? Icons.lock : Icons.play_arrow_rounded,
                color: isLocked ? Colors.grey : Theme.of(context).colorScheme.primary,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
