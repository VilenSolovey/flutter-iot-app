import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/domain/models/health_record.dart';
import 'package:my_project/screens/home/home_screen_content.dart';
import 'package:my_project/state/home/home_cubit.dart';
import 'package:my_project/state/home/home_state.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:my_project/widgets/health_record_dialog.dart';
import 'package:secret_flashlight_plugin/secret_flashlight_plugin.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openRecordDialog(
    BuildContext context, [
    HealthRecord? record,
  ]) async {
    final cubit = context.read<HomeCubit>();
    final result = await showHealthRecordDialog(
      context,
      allowedMetrics: cubit.allowedMetrics,
      validateValue: cubit.validateRecordValue,
      record: record,
    );
    if (result == null || !context.mounted) return;
    await cubit.saveRecord(
      record: record,
      type: result.type,
      value: result.value,
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleSecretFlashlight(BuildContext context) async {
    try {
      final isEnabled = await SecretFlashlightPlugin.onLight();
      if (!context.mounted) return;
      _showMessage(
        context,
        isEnabled ? 'Flashlight enabled' : 'Flashlight disabled',
      );
    } on UnsupportedError catch (error) {
      if (!context.mounted) return;
      await _showFlashlightDialog(
        context,
        (error.message ?? error).toString(),
      );
    } on PlatformException catch (error) {
      if (!context.mounted) return;
      await _showFlashlightDialog(
        context,
        error.message ?? 'Flashlight is not available on this device.',
      );
    }
  }

  Future<void> _showFlashlightDialog(
    BuildContext context,
    String message,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Flashlight unavailable'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state.shouldOpenLogin) {
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }
        if (state.message != null) _showMessage(context, state.message!);
      },
      builder: (context, state) {
        final user = state.user;
        if (state.isLoading || user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          body: SafeArea(
            child: HomeScreenContent(
              user: user,
              records: state.records,
              isOnline: state.isOnline,
              isMqttConnected: state.isMqttConnected,
              heartRate: state.heartRate,
              temperature: state.temperature,
              temperatureTopic: context.read<HomeCubit>().temperatureTopic,
              onAddRecord: () => _openRecordDialog(context),
              onEditRecord: (record) => _openRecordDialog(context, record),
              onDeleteRecord: context.read<HomeCubit>().deleteRecord,
              onSecretAction: () => _toggleSecretFlashlight(context),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openRecordDialog(context),
            backgroundColor: AppColors.accent,
            child: const Icon(Icons.add, color: AppColors.bg),
          ),
        );
      },
    );
  }
}
