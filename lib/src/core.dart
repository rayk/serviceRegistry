library api.types;

import 'dart:async';
import 'dart:isolate';

import 'package:stream_channel/stream_channel.dart';

/// Repersents a currently available service.
class ServiceRegistration {
  String _serviceType,
      _serviceEnvironment,
      _serviceVMVersion,
      _serviceSourcePath,
      _serviceStartScript,
      _serviceId,
      _serviceVersion;
  IsolateChannel _channel;
  Capability _pauseCapability, _terminateCapability;
  SendPort _controlPort, _requestPort;
  Stream _broadcastedErrors;
  ReceivePort _serviceResponses;

  /// Creates and registers a new service.
  ServiceRegistration(
      Isolate iso, ReceivePort tempProvision, ReceivePort actualService) {
    _pauseCapability = iso.pauseCapability;
    _terminateCapability = iso.terminateCapability;
    _controlPort = iso.controlPort;
    _serviceResponses = actualService;
    ReceivePort _exitAlertPort = ServiceRegistry._exitMonitorPort;
    ReceivePort _errorMonitorPort = ServiceRegistry._errorMonitorPort;

    tempProvision.listen((Map serviceCreds) {
      _serviceType = serviceCreds['ServiceName'];
      _serviceVersion = serviceCreds['ServiceVersion'];
      _serviceId = serviceCreds['ServiceId'];
      _requestPort = serviceCreds['ServiceRequestPort'];
      _channel = new IsolateChannel(_serviceResponses, _requestPort);
      ServiceRegistry._addService(this);
      tempProvision.close();
    });
  }

  /// Returns an unquie Id for the specific instance of the service.
  String get id => _serviceId;

  /// Returns service type that is provided.
  String get type => _serviceType;

  /// Returns the version number of this service.
  String get version => _serviceVersion;
}

/// Singleton Service Registry for all current services.
///
/// Contains List of all the currently available services in the form
/// of [ServiceRegistrations].
class ServiceRegistry {
  static final ServiceRegistry _instance = new ServiceRegistry._internal();
  static List<ServiceRegistration> _currentServices = new List();
  static ReceivePort _exitMonitorPort = new ReceivePort();
  static final ReceivePort _errorMonitorPort = new ReceivePort();

  /// Returns the current instance of the ServiceRegistry with the latest
  /// currently available services.
  factory ServiceRegistry() => _instance;

  ServiceRegistry._internal();

  /// Returns a list of al currently available services.
  /// available services.
  List<ServiceRegistration> get availableServices => _currentServices;

  static _addService(ServiceRegistration rego) {
    _currentServices.add(rego);
  }
}
