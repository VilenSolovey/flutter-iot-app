import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_project/domain/models/health_record.dart';
import 'package:my_project/domain/models/user_profile.dart';
import 'package:my_project/screens/home/home_screen_content.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/connectivity_service.dart';
import 'package:my_project/services/health_record_service.dart';
import 'package:my_project/services/mqtt_service.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:my_project/widgets/health_record_dialog.dart';

part 'home/home_connectivity_logic.dart';
part 'home/home_records_logic.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.authService,
    required this.connectivityService,
    required this.healthRecordService,
    required this.mqttService,
    super.key,
  });

  final AuthService authService;
  final ConnectivityService connectivityService;
  final HealthRecordService healthRecordService;
  final MqttService mqttService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _user;
  Future<List<HealthRecord>>? _recordsFuture;
  bool _isLoading = true;
  bool _isOnline = true;
  bool _isMqttConnected = false;
  bool _isConnectingToMqtt = false;
  String _heartRate = '--';
  String _temperature = '--';
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<bool>? _mqttConnectionSubscription;
  StreamSubscription<String>? _heartRateSubscription;
  StreamSubscription<String>? _temperatureSubscription;
  Timer? _mqttReconnectTimer;

  @override
  void initState() {
    super.initState();
    _bindMqttStreams();
    _loadPage();
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _mqttConnectionSubscription?.cancel();
    _heartRateSubscription?.cancel();
    _temperatureSubscription?.cancel();
    _mqttReconnectTimer?.cancel();
    widget.mqttService.disconnect();
    super.dispose();
  }

  void _showStatusMessage(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    });
  }

  void _update(VoidCallback callback) {
    setState(callback);
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (_isLoading || user == null || _recordsFuture == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: SafeArea(
        child: HomeScreenContent(
          user: user,
          recordsFuture: _recordsFuture!,
          isOnline: _isOnline,
          isMqttConnected: _isMqttConnected,
          heartRate: _heartRate,
          temperature: _temperature,
          mqttService: widget.mqttService,
          onAddRecord: _openRecordDialog,
          onEditRecord: _openRecordDialog,
          onDeleteRecord: _deleteRecord,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openRecordDialog,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.bg),
      ),
    );
  }
}
