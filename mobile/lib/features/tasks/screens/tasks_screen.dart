import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../providers/task_providers.dart';
import '../widgets/task_card.dart';

enum TaskListFilter { semua, tertunda, selesai }

final taskListFilterProvider = StateProvider<TaskListFilter>((_) => TaskListFilter.semua);

/// Layar Tasks: filter Semua/Tertunda/Selesai + daftar TaskCard.
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(taskListFilterProvider);
    final pending = ref.watch(allTasksStreamProvider);
    final completed = ref.watch(completedTasksStreamProvider);

    final Widget body = switch (filter) {
      TaskListFilter.semua => _TaskList(tasks: pending.value ?? const []),
      TaskListFilter.tertunda => _TaskList(
          tasks: (pending.value ?? const []).where((t) => t.status == 'pending').toList(),
        ),
      TaskListFilter.selesai => _TaskList(tasks: completed.value ?? const []),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Column(
        children: [
          Padding(
            padding: AppSpacing.screenH,
            child: SegmentedButton<TaskListFilter>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: TaskListFilter.semua, label: Text('Semua')),
                ButtonSegment(value: TaskListFilter.tertunda, label: Text('Tertunda')),
                ButtonSegment(value: TaskListFilter.selesai, label: Text('Selesai')),
              ],
              selected: {filter},
              onSelectionChanged: (s) =>
                  ref.read(taskListFilterProvider.notifier).state = s.first,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const EmptyStateView(
        icon: Icons.checklist_outlined,
        title: 'Belum ada tugas di sini',
        subtitle: 'Tulis atau rekam tugas pertamamu lewat tombol kuning.',
      );
    }
    return ListView.builder(
      padding: AppSpacing.screenH,
      itemCount: tasks.length,
      itemBuilder: (context, i) => TaskCard(task: tasks[i]),
    );
  }
}
