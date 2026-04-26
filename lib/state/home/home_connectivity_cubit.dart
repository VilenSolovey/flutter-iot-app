part of 'home_cubit.dart';

mixin HomeConnectivityCubit on Cubit<HomeState> {
  ConnectivityService get connectivityService;

  MqttService get mqttService;

  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<bool>? _mqttConnectionSubscription;
  StreamSubscription<String>? _heartRateSubscription;
  StreamSubscription<String>? _temperatureSubscription;
  Timer? _mqttReconnectTimer;

  void _bindMqttStreams() {
    _temperatureSubscription ??= mqttService.temperatureStream.listen(
      (value) {
        if (!isClosed) emit(state.copyWith(temperature: value));
      },
    );
    _heartRateSubscription ??= mqttService.heartRateStream.listen(
      (value) {
        if (!isClosed) emit(state.copyWith(heartRate: value));
      },
    );
    _mqttConnectionSubscription ??=
        mqttService.connectionStream.listen(_handleMqttConnectionChange);
  }

  Future<void> _initializeConnectivity() async {
    final isOnline = await connectivityService.hasInternetConnection();
    if (isClosed) return;
    emit(
      _offlineAwareState(isOnline).copyWith(
        message: isOnline
            ? null
            : 'Офлайн режим: показуємо збережені локально дані.',
      ),
    );
    if (isOnline) await _connectToMqtt(showFailureMessage: true);
    _connectionSubscription ??=
        connectivityService.connectionStream.listen(_handleConnection);
  }

  Future<void> _handleConnection(bool isOnline) async {
    if (isClosed || state.isOnline == isOnline) return;
    emit(
      _offlineAwareState(isOnline).copyWith(
        message: isOnline
            ? 'Інтернет повернувся. Відновлюємо MQTT-зʼєднання.'
            : 'Зʼєднання з Інтернетом втрачено.',
      ),
    );
    if (!isOnline) {
      _mqttReconnectTimer?.cancel();
      mqttService.disconnect();
      return;
    }
    await _connectToMqtt(showFailureMessage: true);
  }

  HomeState _offlineAwareState(bool isOnline) {
    return state.copyWith(
      isOnline: isOnline,
      isMqttConnected: isOnline && state.isMqttConnected,
      heartRate: isOnline ? state.heartRate : '--',
      temperature: isOnline ? state.temperature : '--',
    );
  }

  Future<void> _connectToMqtt({required bool showFailureMessage}) async {
    if (state.isConnectingToMqtt) return;
    emit(state.copyWith(isConnectingToMqtt: true));
    final didConnect = await mqttService.connect();
    if (isClosed) return;
    emit(state.copyWith(isConnectingToMqtt: false));
    if (!didConnect) return _handleMqttFailure(showFailureMessage);
    final isSubscribed = await mqttService.subscribeToSensors();
    if (isClosed) return;
    emit(state.copyWith(isMqttConnected: isSubscribed));
    if (isSubscribed) {
      _mqttReconnectTimer?.cancel();
    } else {
      _handleSubscriptionFailure(showFailureMessage);
    }
  }

  void _handleMqttConnectionChange(bool isConnected) {
    if (isClosed || state.isMqttConnected == isConnected) return;
    emit(
      state.copyWith(
        isMqttConnected: isConnected,
        heartRate: isConnected ? state.heartRate : '--',
        temperature: isConnected ? state.temperature : '--',
        message:
            !isConnected && state.isOnline ? 'MQTT брокер відключився.' : null,
      ),
    );
    if (!isConnected && state.isOnline) _scheduleReconnect();
    if (isConnected) _mqttReconnectTimer?.cancel();
  }

  void _handleMqttFailure(bool showFailureMessage) {
    emit(
      state.copyWith(
        isMqttConnected: false,
        message: showFailureMessage
            ? 'Не вдалося підключитися до MQTT брокера.'
            : null,
      ),
    );
    _scheduleReconnect();
  }

  void _handleSubscriptionFailure(bool showFailureMessage) {
    emit(
      state.copyWith(
        message: showFailureMessage
            ? 'MQTT підключено, але підписка на сенсори не вдалася.'
            : null,
      ),
    );
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!state.isOnline || state.isMqttConnected) return;
    _mqttReconnectTimer ??= Timer.periodic(
      const Duration(seconds: 5),
      (_) async => _connectToMqtt(showFailureMessage: false),
    );
  }

  @override
  Future<void> close() async {
    await _connectionSubscription?.cancel();
    await _mqttConnectionSubscription?.cancel();
    await _heartRateSubscription?.cancel();
    await _temperatureSubscription?.cancel();
    _mqttReconnectTimer?.cancel();
    mqttService.disconnect();
    return super.close();
  }
}
