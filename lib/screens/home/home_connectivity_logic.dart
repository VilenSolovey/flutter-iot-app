part of '../home_screen.dart';

extension _HomeConnectivityLogic on _HomeScreenState {
  void _bindMqttStreams() {
    _temperatureSubscription =
        widget.mqttService.temperatureStream.listen(_setTemperature);
    _heartRateSubscription =
        widget.mqttService.heartRateStream.listen(_setHeartRate);
    _mqttConnectionSubscription =
        widget.mqttService.connectionStream.listen(_handleMqttConnectionChange);
  }

  Future<void> _loadPage() async {
    final user = await widget.authService.getActiveUser();
    if (user == null && mounted) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    _update(() {
      _user = user;
      _recordsFuture = widget.healthRecordService.getRecords();
      _isLoading = false;
    });
    await _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    final isOnline = await widget.connectivityService.hasInternetConnection();
    if (!mounted) return;
    _update(() {
      _isOnline = isOnline;
      if (!isOnline) _resetMqttMetrics();
    });
    if (!isOnline) {
      _showStatusMessage('Офлайн режим: показуємо збережені локально дані.');
    } else {
      await _connectToMqtt(showFailureMessage: true);
    }
    _connectionSubscription ??=
        widget.connectivityService.connectionStream.listen(_handleConnection);
  }

  Future<void> _handleConnection(bool isOnline) async {
    if (!mounted || _isOnline == isOnline) return;
    _update(() {
      _isOnline = isOnline;
      if (!isOnline) _resetMqttMetrics();
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

  Future<void> _connectToMqtt({required bool showFailureMessage}) async {
    if (_isConnectingToMqtt) return;
    _isConnectingToMqtt = true;
    final didConnect = await widget.mqttService.connect();
    _isConnectingToMqtt = false;
    if (!mounted) return;
    if (!didConnect) return _handleMqttFailure(showFailureMessage);
    final isSubscribed = await widget.mqttService.subscribeToSensors();
    if (!mounted) return;
    _update(() => _isMqttConnected = isSubscribed);
    if (isSubscribed) {
      _mqttReconnectTimer?.cancel();
    } else {
      _handleSubscriptionFailure(showFailureMessage);
    }
  }

  void _handleMqttConnectionChange(bool isConnected) {
    if (!mounted || _isMqttConnected == isConnected) return;
    _update(() {
      _isMqttConnected = isConnected;
      if (!isConnected) _resetMqttMetrics();
    });
    if (!isConnected && _isOnline) {
      _showStatusMessage('MQTT брокер відключився.');
      _scheduleReconnect();
    }
    if (isConnected) _mqttReconnectTimer?.cancel();
  }

  void _scheduleReconnect() {
    if (!_isOnline || _isMqttConnected) return;
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

  void _handleMqttFailure(bool showFailureMessage) {
    _update(() => _isMqttConnected = false);
    if (showFailureMessage) {
      _showStatusMessage('Не вдалося підключитися до MQTT брокера.');
    }
    _scheduleReconnect();
  }

  void _handleSubscriptionFailure(bool showFailureMessage) {
    if (showFailureMessage) {
      _showStatusMessage(
        'MQTT підключено, але підписка на сенсори не вдалася.',
      );
    }
    _scheduleReconnect();
  }

  void _setHeartRate(String value) {
    if (!mounted) return;
    _update(() => _heartRate = value);
  }

  void _setTemperature(String value) {
    if (!mounted) return;
    _update(() => _temperature = value);
  }

  void _resetMqttMetrics() {
    _isMqttConnected = false;
    _heartRate = '--';
    _temperature = '--';
  }
}
