part of '../profile_screen.dart';

extension _ProfileActions on _ProfileScreenState {
  Future<void> _logout() async {
    final shouldLogout = await _confirm(
      title: 'Logout',
      content: 'Вийти з акаунта? Активну сесію буде завершено.',
      action: 'Logout',
    );
    if (shouldLogout != true) return;
    await widget.authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  Future<void> _deleteAccount() async {
    final shouldDelete = await _confirm(
      title: 'Delete account',
      content: 'Видалити користувача і всі локальні записи?',
      action: 'Delete',
    );
    if (shouldDelete != true) return;
    await widget.authService.deleteUser();
    await widget.healthRecordService.clearAllRecords();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  Future<bool?> _confirm({
    required String title,
    required String content,
    required String action,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: AppText.h2),
        content: Text(content, style: AppText.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
  }
}
