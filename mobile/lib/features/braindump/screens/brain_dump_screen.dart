import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/ai_api_client.dart';
import '../../../core/speech/speech_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../inbox/providers/inbox_providers.dart';
import 'brain_dump_preview_screen.dart';

/// S05: AI Brain Dump Screen dengan offline fallback resilience.
class BrainDumpScreen extends ConsumerStatefulWidget {
  const BrainDumpScreen({super.key});

  @override
  ConsumerState<BrainDumpScreen> createState() => _BrainDumpScreenState();
}

class _BrainDumpScreenState extends ConsumerState<BrainDumpScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  bool _isListening = false;
  String? _errorMessage;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _toggleVoice() async {
    final speech = ref.read(speechServiceProvider);

    if (_isListening) {
      await speech.stopListening();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    setState(() {
      _isListening = true;
      _errorMessage = null;
    });

    await speech.startListening(
      onResult: (text) {
        if (mounted) {
          setState(() {
            _textController.text = text;
            _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: _textController.text.length),
            );
          });
        }
      },
      onError: (msg) {
        if (mounted) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      },
    );
  }

  Future<void> _extractWithAI() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = ref.read(aiApiClientProvider);
      final tasks = await client.parseBrainDump(text);

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BrainDumpPreviewScreen(initialTasks: tasks),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
        _showOfflineFallbackDialog(text);
      }
    }
  }

  void _showOfflineFallbackDialog(String text) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Koneksi AI Sedang Terkendala'),
          content: Text(
            '$_errorMessage\n\nTenang, kamu bisa simpan seluruh catatan ini langsung sebagai ide ke Thought Inbox agar tidak hilang.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              key: const Key('fallback-save-inbox-btn'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                final shortTitle = text.length > 50
                    ? '${text.substring(0, 47)}...'
                    : text;
                await ref
                    .read(inboxActionsProvider.notifier)
                    .create(title: shortTitle, content: text);
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
                if (mounted) {
                  Navigator.of(context).maybePop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Catatan berhasil disimpan ke Thought Inbox!',
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'Simpan ke Inbox',
                style: TextStyle(color: AppColors.nearBlack),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Brain Dump'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? AppColors.error : AppColors.nearBlack,
            ),
            tooltip: _isListening ? 'Hentikan rekam' : 'Rekam suara',
            onPressed: _isLoading ? null : _toggleVoice,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenH,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Ceritain aja semua yang mau kamu lakuin...',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'AI bakal mengekstraknya jadi beberapa tugas berjadwal. Bisa sebut tanggal/waktu jika ada.',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: TextField(
                  key: const Key('braindump-textarea'),
                  controller: _textController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText:
                        'Misal: Besok jam 10 pagi mau meeting dengan tim, sorenya belanja bulanan dan jemput adik jam 5...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              if (_isLoading) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'AI sedang mengekstrak tugasmu...',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              AppButton(
                key: const Key('extract-ai-btn'),
                label: _isLoading ? 'Memproses...' : 'Ekstrak dengan AI',
                icon: Icons.auto_awesome,
                onTap: _isLoading || _textController.text.trim().isEmpty
                    ? null
                    : _extractWithAI,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
