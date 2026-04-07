import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_project/domain/models/health_record.dart';
import 'package:my_project/domain/models/user_profile.dart';
import 'package:my_project/services/auth_service.dart';
import 'package:my_project/services/connectivity_service.dart';
import 'package:my_project/services/health_record_service.dart';
import 'package:my_project/services/mqtt_service.dart';
import 'package:my_project/theme/app_theme.dart';
import 'package:my_project/widgets/empty_records_state.dart';
import 'package:my_project/widgets/health_record_card.dart';
import 'package:my_project/widgets/health_record_dialog.dart';
import 'package:my_project/widgets/home_app_bar.dart';
import 'package:my_project/widgets/home_iot_metrics_grid.dart';
import 'package:my_project/widgets/mqtt_status_banner.dart';
import 'package:my_project/widgets/section_header.dart';

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
  List<HealthRecord> _records = <HealthRecord>[];
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
    _temperatureSubscription = widget.mqttService.temperatureStream.listen(
      (value) {
        if (!mounted) {
          return;
        }

        setState(() {
          _temperature = value;
        });
      },
    );
    _heartRateSubscription = widget.mqttService.heartRateStream.listen(
      (value) {
        if (!mounted) {
          return;
        }

        setState(() {
          _heartRate = value;
        });
      },
    );
    _mqttConnectionSubscription = widget.mqttService.connectionStream.listen(
      _handleMqttConnectionChange,
    );
    _loadData();
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

  Future<void> _loadData() async {
    final user = await widget.authService.getActiveUser();
    if (user == null && mounted) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final records = await widget.healthRecordService.getRecords();
    if (!mounted) {
      return;
    }

    setState(() {
      _user = user;
      _records = records;
      _isLoading = false;
    });

    await _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    final isOnline = await widget.connectivityService.hasInternetConnection();
    if (!mounted) {
      return;
    }

    setState(() {
      _isOnline = isOnline;
      if (!isOnline) {
        _isMqttConnected = false;
        _heartRate = '--';
        _temperature = '--';
      }
    });

    if (!isOnline) {
      _showStatusMessage(
        'Автовхід доступний, але зараз немає інтернету. MQTT тимчасово '
        'недоступний.',
      );
      _connectionSubscription ??=
          widget.connectivityService.connectionStream.listen(
        _handleConnectivityChange,
      );
      return;
    }

    await _connectToMqtt(showFailureMessage: true);
    _connectionSubscription ??= widget.connectivityService.connectionStream
        .listen(_handleConnectivityChange);
  }

  Future<void> _handleConnectivityChange(bool isOnline) async {
    if (!mounted || _isOnline == isOnline) {
      return;
    }

    setState(() {
      _isOnline = isOnline;
      if (!isOnline) {
        _isMqttConnected = false;
        _heartRate = '--';
        _temperature = '--';
      }
    });

    if (!isOnline) {
      _mqttReconnectTimer?.cancel();
      widget.mqttService.disconnect();
      _showStatusMessage('Зʼєднання з Інтернетом втрачено.');
      return;
    }

    _showStatusMessage('Інтернет повернувся. Відновлюємо MQTT-зʼєднання.');
    await _connectToMqtt(showFailureMessage: true);
  }

  Future<void> _connectToMqtt({
    required bool showFailureMessage,
  }) async {
    if (_isConnectingToMqtt) {
      return;
    }

    _isConnectingToMqtt = true;
    final didConnect = await widget.mqttService.connect();
    _isConnectingToMqtt = false;
    if (!mounted) {
      return;
    }

    if (!didConnect) {
      setState(() {
        _isMqttConnected = false;
      });
      if (showFailureMessage) {
        _showStatusMessage('Не вдалося підключитися до MQTT брокера.');
      }
      _scheduleReconnect();
      return;
    }

    final isSubscribed = await widget.mqttService.subscribeToSensors();
    if (!mounted) {
      return;
    }

    setState(() {
      _isMqttConnected = isSubscribed;
    });

    if (isSubscribed) {
      _mqttReconnectTimer?.cancel();
    }

    if (!isSubscribed && showFailureMessage) {
      _showStatusMessage(
        'MQTT підключено, але підписатися на топік не вдалося.',
      );
      _scheduleReconnect();
    }
  }

  void _handleMqttConnectionChange(bool isConnected) {
    if (!mounted || _isMqttConnected == isConnected) {
      return;
    }

    setState(() {
      _isMqttConnected = isConnected;
      if (!isConnected) {
        _heartRate = '--';
        _temperature = '--';
      }
    });

    if (!isConnected && _isOnline) {
      _showStatusMessage('MQTT брокер відключився.');
      _scheduleReconnect();
      return;
    }

    if (isConnected) {
      _mqttReconnectTimer?.cancel();
    }
  }

  void _scheduleReconnect() {
    if (!_isOnline || _isMqttConnected) {
      return;
    }

    _mqttReconnectTimer ??= Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        if (!mounted || !_isOnline || _isMqttConnected) {
          _mqttReconnectTimer?.cancel();
          _mqttReconnectTimer = null;
          return;
        }

        await _connectToMqtt(showFailureMessage: false);

        if (_isMqttConnected) {
          _mqttReconnectTimer?.cancel();
          _mqttReconnectTimer = null;
        }
      },
    );
  }

  @override
  void deactivate() {
    _mqttReconnectTimer?.cancel();
    _mqttReconnectTimer = null;
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    if (_isOnline && !_isMqttConnected) {
      _scheduleReconnect();
    }
  }

  void _showStatusMessage(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  Future<void> _showRecordDialog({HealthRecord? record}) async {
    final result = await showHealthRecordDialog(
      context,
      healthRecordService: widget.healthRecordService,
      record: record,
    );

    if (result == null) {
      return;
    }

    final updated = record == null
        ? await widget.healthRecordService.addRecord(
            type: result.type,
            value: result.value,
          )
        : await widget.healthRecordService.updateRecord(
            id: record.id,
            type: result.type,
            value: result.value,
          );

    if (!mounted) return;
    setState(() {
      _records = updated;
    });
  }

  Future<void> _deleteRecord(HealthRecord record) async {
    final updated = await widget.healthRecordService.deleteRecord(record.id);
    if (!mounted) {
      return;
    }

    setState(() {
      _records = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = _user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No active user')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hPad = constraints.maxWidth > 600
                ? constraints.maxWidth * 0.15
                : AppSpacing.lg;
            return CustomScrollView(
              slivers: [
                HomeAppBar(
                  hPad: hPad,
                  fullName: user.fullName,
                  email: user.email,
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: AppSpacing.sm),
                      MqttStatusBanner(
                        isOnline: _isOnline,
                        isMqttConnected: _isMqttConnected,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const SectionHeader(title: 'Dashboard'),
                      const SizedBox(height: AppSpacing.md),
                      HomeIotMetricsGrid(
                        heartRate: _heartRate,
                        isMqttConnected: _isMqttConnected,
                        isOnline: _isOnline,
                        temperature: _temperature,
                        temperatureTopic: widget.mqttService.temperatureTopic,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SectionHeader(
                        title: 'Health Journal',
                        action: 'Log +',
                        onAction: _showRecordDialog,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (_records.isEmpty)
                        const EmptyRecordsState()
                      else
                        ..._records.map(
                          (record) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: HealthRecordCard(
                              record: record,
                              onEdit: () => _showRecordDialog(record: record),
                              onDelete: () => _deleteRecord(record),
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      const SizedBox(height: AppSpacing.xl),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showRecordDialog,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.bg),
      ),
    );
  }
}
