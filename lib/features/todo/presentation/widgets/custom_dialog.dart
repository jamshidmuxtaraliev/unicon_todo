import 'package:flutter/material.dart';

/// Qaysi amal uchun dialog ochilishini bildiradi
enum TaskActionMode { done, delete }

/// Qayta ishlatiladigan dialog
class TaskActionDialog extends StatelessWidget {
  final TaskActionMode mode;

  /// Dialog mazmuni
  final String title; // masalan: “Vazifa bajarilsinmi?” yoki “O‘chirilsinmi?”
  final String? message; // ixtiyoriy tushuntirish
  final String? confirmText; // masalan: “Bajarildi”, “O‘chirish”
  final String? cancelText; // masalan: “Bekor qilish”

  /// Onay bosilganda ishlaydigan callback.
  /// Agar null bo‘lsa, faqat `true` qaytarib Navigator.pop qiladi.
  final Future<void> Function()? onConfirm;

  /// Bekor bosilganda callback (odatda kerak emas)
  final VoidCallback? onCancel;

  /// barrierDismissible — dialogni tashqarisini bosganda yopish
  final bool barrierDismissible;

  /// Qo‘shimcha widgetlar (masalan, checkbox) uchun pastki custom zona
  final Widget? footer;

  /// Kichik UI sozlamalar
  final IconData? customIcon;

  const TaskActionDialog({
    super.key,
    required this.mode,
    required this.title,
    this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.barrierDismissible = true,
    this.footer,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDelete = mode == TaskActionMode.delete;
    final Color accent = isDelete ? (theme.colorScheme.error) : (theme.colorScheme.primary);

    final Color accentContainer = isDelete ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer;

    final Color onAccentContainer = isDelete ? theme.colorScheme.onErrorContainer : theme.colorScheme.onPrimaryContainer;

    final IconData icon = customIcon ?? (isDelete ? Icons.delete_forever_rounded : Icons.check_circle_rounded);

    final String okText = confirmText ?? (isDelete ? 'O‘chirish' : 'Bajarildi');
    final String cancel = cancelText ?? 'Bekor qilish';

    return PopScope(
      canPop: barrierDismissible,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 320),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header icon (accented)
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(color: accentContainer, shape: BoxShape.circle),
                  child: Icon(icon, size: 34, color: onAccentContainer),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),

                if (message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],

                if (footer != null) ...[const SizedBox(height: 12), footer!],

                const SizedBox(height: 18),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          onCancel?.call();
                          Navigator.of(context).pop(false);
                        },
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text(cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          if (onConfirm != null) {
                            await onConfirm!.call();
                          }
                          if (context.mounted) {
                            Navigator.of(context).pop(true);
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(okText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Qulay helper: `await showTaskActionDialog(...)`
/// true -> tasdiqlandi, false/null -> bekor.
Future<bool?> showTaskActionDialog(
  BuildContext context, {
  required TaskActionMode mode,
  required String title,
  String? message,
  String? confirmText,
  String? cancelText,
  Future<void> Function()? onConfirm,
  VoidCallback? onCancel,
  bool barrierDismissible = true,
  Widget? footer,
  IconData? icon,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder:
        (_) => TaskActionDialog(
          mode: mode,
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          onConfirm: onConfirm,
          onCancel: onCancel,
          barrierDismissible: barrierDismissible,
          footer: footer,
          customIcon: icon,
        ),
  );
}
