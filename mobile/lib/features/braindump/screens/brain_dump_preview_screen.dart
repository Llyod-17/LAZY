import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/ai_api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../inbox/providers/inbox_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../widgets/task_preview_card.dart';

/// Layar konfirmasi hasil ekstraksi AI.
/// Menjamin tidak ada data yang tersimpan ke SQLite sebelum tombol konfirmasi ditekan secara eksplisit.
class BrainDumpPreviewScreen extends ConsumerStatefulWidget {
  const BrainDumpPreviewScreen({
    super.key,
    required this.initialTasks,
  });

  final List<ExtractedTask> initialTasks;

  @override
  ConsumerState<BrainDumpPreviewScreen> createState() =>
      _BrainDumpPreviewScreenState();
}

class _BrainDumpPreviewScreenState
    extends ConsumerState<BrainDumpPreviewScreen> {
  late List<ExtractedTask> _tasks;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(widget.initialTasks);
  }

  Future<void> _confirmAndSave() async {
    if (_tasks.isEmpty) {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() => _isSaving = true);

    try {
      final taskActions = ref.read(taskActionsProvider.notifier);
      final inboxActions = ref.read(inboxActionsProvider.notifier);

      int tasksCreated = 0;
      int thoughtsCreated = 0;

      for (final item in _tasks) {
        final title = item.title.trim();
        if (title.isEmpty) continue;

        // Jika memiliki tanggal yang valid -> simpan sebagai Task
        if (item.suggestedDate != null && item.suggestedDate!.isNotEmpty) {
          DateTime? deadline;
          try {
            final dateParts = item.suggestedDate!.split('-');
            final year = int.parse(dateParts[0]);
            final month = int.parse(dateParts[1]);
            final day = int.parse(dateParts[2]);

            int hour = 23;
            int minute = 59;
            if (item.suggestedTime != null && item.suggestedTime!.isNotEmpty) {
              final timeParts = item.suggestedTime!.split(':');
              hour = int.parse(timeParts[0]);
              minute = int.parse(timeParts[1]);
            }
            deadline = DateTime(year, month, day, hour, minute);
          } catch (_) {
            deadline = null;
          }

          await taskActions.create(
            title: title,
            description: item.reason,
            priority: item.priority ?? 'medium',
            deadlineAt: deadline,
          );
          tasksCreated++;
        } else {
          // Tanpa tanggal -> simpan sebagai ide di Thought Inbox
          await inboxActions.create(
            title: title,
            content: item.reason,
          );
          thoughtsCreated++;
        }
      }

      if (mounted) {
        Navigator.of(context).maybePop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tersimpan: $tasksCreated tugas, $thoughtsCreated ide di inbox.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tinjau Hasil AI'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.screenH,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Periksa kembali tugas hasil rangkuman AI. Kamu bisa mengubah judul atau menghapus yang tidak sesuai.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            Expanded(
              child: _tasks.isEmpty
                  ? Center(
                      child: Text(
                        'Semua tugas telah dihapus.',
                        style: textTheme.bodyLarge,
                      ),
                    )
                  : ListView.builder(
                      padding: AppSpacing.screenH,
                      itemCount: _tasks.length,
                      itemBuilder: (context, i) {
                        return TaskPreviewCard(
                          key: ValueKey('preview-$i'),
                          task: _tasks[i],
                          onChanged: (updated) {
                            setState(() {
                              _tasks[i] = updated;
                            });
                          },
                          onDelete: () {
                            setState(() {
                              _tasks.removeAt(i);
                            });
                          },
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Batal',
                      variant: AppButtonVariant.secondary,
                      onTap: _isSaving ? null : () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      key: const Key('confirm-save-btn'),
                      label: _isSaving ? 'Menyimpan...' : 'Konfirmasi & Simpan',
                      icon: Icons.check,
                      variant: AppButtonVariant.primary,
                      onTap: _isSaving || _tasks.isEmpty ? null : _confirmAndSave,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
