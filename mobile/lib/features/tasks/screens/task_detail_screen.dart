import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../providers/task_providers.dart';

/// Lihat, edit, dan hapus satu task. Reaktif via [taskStreamProvider].
class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskStreamProvider(taskId));
    return task.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Detail Tugas')),
        body: ErrorStateView(message: e.toString()),
      ),
      data: (value) {
        if (value == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Tugas')),
            body: const EmptyStateView(
              icon: Icons.check_circle_outline,
              title: 'Tugas ini sudah tidak ada',
              subtitle: 'Mungkin sudah dihapus.',
            ),
          );
        }
        return _TaskEditForm(task: value);
      },
    );
  }
}

class _TaskEditForm extends ConsumerStatefulWidget {
  const _TaskEditForm({required this.task});

  final Task task;

  @override
  ConsumerState<_TaskEditForm> createState() => _TaskEditFormState();
}

class _TaskEditFormState extends ConsumerState<_TaskEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _duration;
  late String _priority;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _title = TextEditingController(text: t.title);
    _description = TextEditingController(text: t.description ?? '');
    _duration = TextEditingController(text: t.estimatedDurationMin?.toString() ?? '');
    _priority = t.priority;
    _deadline = t.deadlineAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(t.deadlineAt!, isUtc: true).toLocal();
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _duration.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final current = _deadline ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null || !mounted) return;
    setState(() {
      _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(taskActionsProvider.notifier).update(
          widget.task.id,
          title: _title.text,
          description: _description.text,
          priority: _priority,
          deadlineAt: _deadline,
          estimatedDurationMin: int.tryParse(_duration.text),
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perubahan tersimpan')),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus tugas ini?'),
        content: const Text('Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            key: const Key('confirm-delete'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(taskActionsProvider.notifier).delete(widget.task.id);
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        actions: [
          IconButton(
            key: const Key('task-delete'),
            tooltip: 'Hapus tugas',
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenH,
          children: [
            TextFormField(
              key: const Key('task-title-field'),
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Judul'),
              validator: (v) {
                final trimmed = v?.trim() ?? '';
                if (trimmed.isEmpty) return 'Judul wajib diisi';
                if (trimmed.length > 100) return 'Maksimal 100 karakter';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.base),
            TextFormField(
              key: const Key('task-desc-field'),
              controller: _description,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
            ),
            const SizedBox(height: AppSpacing.base),
            DropdownButtonFormField<String>(
              key: const Key('task-priority-field'),
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Prioritas'),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Rendah')),
                DropdownMenuItem(value: 'medium', child: Text('Sedang')),
                DropdownMenuItem(value: 'high', child: Text('Tinggi')),
              ],
              onChanged: (v) => setState(() => _priority = v ?? 'medium'),
            ),
            const SizedBox(height: AppSpacing.base),
            TextFormField(
              key: const Key('task-duration-field'),
              controller: _duration,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Estimasi durasi (menit)',
                hintText: 'misal 30',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = int.tryParse(v.trim());
                if (n == null || n < 1 || n > 480) return 'Isi 1–480 menit';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.base),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Deadline'),
              subtitle: Text(
                _deadline == null
                    ? 'Belum diatur'
                    : DateFormat('EEEE, d MMM yyyy • HH:mm').format(_deadline!),
              ),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: _pickDeadline,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              key: const Key('task-save'),
              label: 'Simpan',
              expanded: true,
              onTap: _save,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            Text(
              'Dibuat ${DateFormat('d MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(widget.task.createdAt))}',
              style: text.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
