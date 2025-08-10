import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:talker/talker.dart';

class ConnectivityService {
  static ConnectivityService? _instance;
  final Connectivity _connectivity = Connectivity();
  final Talker _talker;
  
  StreamController<bool>? _connectionStatusController;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = true;
  
  ConnectivityService._({Talker? talker}) 
      : _talker = talker ?? Talker() {
    _connectionStatusController = StreamController<bool>.broadcast();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  factory ConnectivityService({Talker? talker}) {
    _instance ??= ConnectivityService._(talker: talker);
    return _instance!;
  }
  
  Stream<bool> get connectionStatus => _connectionStatusController!.stream;
  bool get isConnected => _isConnected;
  
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _talker.error('Failed to check connectivity', e);
      _isConnected = false;
      _connectionStatusController?.add(false);
    }
  }
  
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final wasConnected = _isConnected;
    _isConnected = !result.contains(ConnectivityResult.none);
    
    _talker.info('Connectivity changed: ${result.map((r) => r.name).join(', ')} - Connected: $_isConnected');
    
    if (wasConnected != _isConnected) {
      _connectionStatusController?.add(_isConnected);
      
      if (_isConnected && !wasConnected) {
        _talker.info('Internet connection restored');
      } else if (!_isConnected && wasConnected) {
        _talker.warning('Internet connection lost');
      }
    }
  }
  
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected = !result.contains(ConnectivityResult.none);
      return _isConnected;
    } catch (e) {
      _talker.error('Error checking connectivity', e);
      return false;
    }
  }
  
  void dispose() {
    _connectivitySubscription.cancel();
    _connectionStatusController?.close();
    _connectionStatusController = null;
    _instance = null;
  }
}