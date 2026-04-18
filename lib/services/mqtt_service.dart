import 'dart:async';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  MqttService({
    this.brokerHost = '10.0.2.2',
    this.port = 1883,
    this.temperatureTopic = 'sensor/temperature',
    this.heartRateTopic = 'sensor/heart_rate',
  });

  final String brokerHost;
  final int port;
  final String temperatureTopic;
  final String heartRateTopic;

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final StreamController<String> _heartRateController =
      StreamController<String>.broadcast();
  final StreamController<String> _temperatureController =
      StreamController<String>.broadcast();

  MqttServerClient? _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>?
      _updatesSubscription;

  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<String> get heartRateStream => _heartRateController.stream;
  Stream<String> get temperatureStream => _temperatureController.stream;

  bool get isConnected {
    return _client?.connectionStatus?.state == MqttConnectionState.connected;
  }

  Future<bool> connect() async {
    if (isConnected) {
      return true;
    }

    _client?.disconnect();
    _client = null;
    await _updatesSubscription?.cancel();
    _updatesSubscription = null;

    final clientId = 'flutter_${DateTime.now().microsecondsSinceEpoch}';
    final client = MqttServerClient(brokerHost, clientId)
      ..port = port
      ..logging(on: false)
      ..keepAlivePeriod = 20
      ..autoReconnect = false
      ..onConnected = _handleConnected
      ..onDisconnected = _handleDisconnected
      ..connectionMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean()
          .withWillQos(MqttQos.atMostOnce);

    try {
      await client.connect();
    } catch (_) {
      client.disconnect();
      _client = null;
      _emitConnectionState(false);
      return false;
    }

    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      client.disconnect();
      _client = null;
      _emitConnectionState(false);
      return false;
    }

    _client = client;
    return true;
  }

  Future<bool> subscribeToSensors() async {
    final client = _client;
    if (client == null || !isConnected) {
      return false;
    }

    client.subscribe(temperatureTopic, MqttQos.atMostOnce);
    client.subscribe(heartRateTopic, MqttQos.atMostOnce);
    await _updatesSubscription?.cancel();
    _updatesSubscription = client.updates?.listen(_handleMessages);

    final isSubscribed = _updatesSubscription != null;
    _emitConnectionState(isSubscribed);
    return isSubscribed;
  }

  void disconnect() {
    _updatesSubscription?.cancel();
    _updatesSubscription = null;
    _client?.disconnect();
    _client = null;
    _emitConnectionState(false);
  }

  Future<void> dispose() async {
    disconnect();
    await _connectionController.close();
    await _heartRateController.close();
    await _temperatureController.close();
  }

  void _handleConnected() {
    _emitConnectionState(true);
  }

  void _handleDisconnected() {
    _client = null;
    _updatesSubscription?.cancel();
    _updatesSubscription = null;
    _emitConnectionState(false);
  }

  void _emitConnectionState(bool isConnected) {
    if (!_connectionController.isClosed) {
      _connectionController.add(isConnected);
    }
  }

  void _handleMessages(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final message in messages) {
      if (message.topic != temperatureTopic &&
          message.topic != heartRateTopic) {
        continue;
      }

      final publishMessage = message.payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(
        publishMessage.payload.message,
      );

      if (message.topic == temperatureTopic &&
          !_temperatureController.isClosed) {
        _temperatureController.add(payload);
      }

      if (message.topic == heartRateTopic && !_heartRateController.isClosed) {
        _heartRateController.add(payload);
      }
    }
  }
}
