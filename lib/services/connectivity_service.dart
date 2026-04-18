import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService({
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Stream<bool> get connectionStream {
    return _connectivity.onConnectivityChanged.asyncMap((results) async {
      if (!_hasNetwork(results)) {
        return false;
      }
      return hasInternetConnection();
    }).distinct();
  }

  Future<bool> hasInternetConnection() async {
    final results = await _connectivity.checkConnectivity();
    if (!_hasNetwork(results)) {
      return false;
    }

    try {
      final lookup = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 3));
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  bool _hasNetwork(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
