import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/speech/speech_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../inbox/providers/inbox_providers.dart';
import '../../tasks/providers/task_providers.dart';

/// S03 & S04: Quick Capture & Voice Capture UI.
/// Memungkinkan input cepat tugas atau ide via teks maupun suara dalam < 5 detik.
class QuickCaptureScreen extends ConsumerStatefulWidget {
  const QuickCaptureScreen({super.key});

  @override
  ConsumerState<QuickCaptureScreen> createState() => _QuickCaptureScreenState();
}

class _QuickCaptureScreenState extends ConsumerState<QuickCaptureScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isRecording = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    final speech = ref.read(speechServiceProvider);

    if (_isRecording) {
      await speech.stopListening();
      if (mounted) {
        setState(() => _isRecording = false);
      }
      return;
    }

    setState(() => _isRecording = true);

    await speech.startListening(
      onResult: (recognizedWords) {
        if (mounted) {
          setState(() {
            _textController.text = recognizedWords;
            _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: _textController.text.length),
            );
          });
        }
      },
      onError: (errorMsg) {
        if (mounted) {
          setState(() => _isRecording = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMsg)));
        }
      },
    );
  }

  Future<void> _saveAsTask() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    // Default deadline: akhir hari ini
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59);

    await ref
        .read(taskActionsProvider.notifier)
        .create(title: text, deadlineAt: endOfDay);

    if (mounted) {
      Navigator.of(context).maybePop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas berhasil disimpan untuk hari ini')),
      );
    }
  }

  Future<void> _saveAsThought() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    await ref.read(inboxActionsProvider.notifier).create(title: text);

    if (mounted) {
      Navigator.of(context).maybePop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ide tersimpan di Thought Inbox')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Capture'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              color: _isRecording ? AppColors.error : AppColors.nearBlack,
            ),
            tooltip: _isRecording ? 'Hentikan rekam' : 'Rekam suara',
            onPressed: _toggleRecording,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenH,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isRecording)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.fiber_manual_record,
                        size: 14,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Mendengarkan suara...',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: TextField(
                  key: const Key('quick-capture-input'),
                  controller: _textController,
                  autofocus: true,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Tulis tugas atau ide kamu di sini...',
                    border: InputBorder.none,
                  ),
                  style: textTheme.bodyLarge,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      key: const Key('save-as-task-btn'),
                      label: 'Jadikan Tugas Hari Ini',
                      icon: Icons.check,
                      variant: AppButtonVariant.primary,
                      onTap: _textController.text.trim().isEmpty
                          ? null
                          : _saveAsTask,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      key: const Key('save-as-inbox-btn'),
                      label: 'Simpan ke Inbox',
                      icon: Icons.inbox,
                      variant: AppButtonVariant.secondary,
                      onTap: _textController.text.trim().isEmpty
                          ? null
                          : _saveAsThought,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
