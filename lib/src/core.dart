library api.types;

import 'dart:async';
import 'dart:isolate';

import 'package:stream_channel/stream_channel.dart';

/// Immutable Repersention of a provisioned service along with any constraints that service
/// may have. Contrainst are captured in the getters.
///
/// ServiceRegistration purpose is to provide context to function that operate
/// on services and or their underlying Isolate.
class ServiceRegistration {
  final DateTime _created = new DateTime.now();
  String _serviceType,
      _serviceEnvironment,
      _serviceVMVersion,
      _serviceSourcePath,
      _serviceStartScript,
      _serviceId,
      _serviceVersion;
  IsolateChannel _channel;
  Capability _pauseCapability, _terminateCapability;
  SendPort _controlPort, _serviceRequest;
  Stream _broadcastedErrors;
  ReceivePort _serviceResponses, _exitAlertPort, _errorMonitorPort;

  /// Creates Service Registration and places it on the registry if it't there.
  ///
  /// This is the dependence on Service Registry.
  ServiceRegistration(Isolate iso, Map credentials, ReceivePort servicePort) {
    _pauseCapability = iso.pauseCapability;
    _terminateCapability = iso.terminateCapability;
    _controlPort = iso.controlPort;
    _serviceResponses = servicePort;
    _serviceType = credentials['ServiceName'];
    _serviceId = credentials['ServiceId'];
    _serviceVersion = credentials['ServiceVersion'];
    _serviceEnvironment = credentials['ServiceEnvironment'];
    _serviceVMVersion = credentials['ServiceVMVersion'];
    _serviceSourcePath = credentials['ServiceSourcePath'];
    _serviceStartScript = credentials['ServiceStartScript'];
    _serviceRequest = credentials['ServiceRequestPort'];
    _exitAlertPort = ServiceRegistry._exitMonitorPort;
    _errorMonitorPort = ServiceRegistry._errorMonitorPort;
    _channel = new IsolateChannel(_serviceResponses, _serviceRequest);
    ServiceRegistry._addService(this);
  }

  /// Returns true if the service can be automanaged by the registry.
  bool get canAutoManage => _exitAlertPort != null &&
      _errorMonitorPort != null &&
      canPause &&
      canTerminate ? true : false;

  /// Returns true if this service accepts messaged.
  bool get canMessage => _serviceRequest != null ? true : false;

  // Returns true if we have the capability to pause the service
  bool get canPause =>
      _pauseCapability != null && _controlPort != null ? true : false;

  /// Returns true if this service provides responses.
  bool get canRespond => _serviceResponses != null ? true : false;

  /// Returns true if we have the capability to terminate this service.
  bool get canTerminate =>
      _terminateCapability != null && _controlPort != null ? true : false;

  /// Returns the Date and Time the Service was created.
  DateTime get createdDateTime => _created;

  /// Returns a description of the environment the service is executing on.
  String get environment => (_serviceEnvironment + '-' + _serviceVMVersion);

  /// Returns an unquie Id for the specific instance of the service.
  ///
  /// ID is based on the hashcode of the services underlying Isolate, it is
  /// used to ensure that the service running on the particular isolate does
  /// no appear in the registery more then once. A second attempt to register
  /// the same service isolate will remove the exiting one an replace it with
  /// the new old, hence allowing it to be refreshed.
  String get id => _serviceId;

  /// Returns the receive side of channel to listen for service respones.
  ///
  /// Listen on this stream for responses from the service.
  Stream get receiveChannel => _channel.stream;

  /// Returns the send side of the channel send request to service.
  ///
  /// Use the add method on the StreamSink to send a message to the service.
  StreamSink get sendChannel => _channel.sink;

  /// Return where the Service is reading it's Source From.
  ///
  /// Used in the event the service needs to be auto restarted.
  String get sourcePath => _serviceSourcePath;

  /// Return the Service Entry Point Script name.
  ///
  /// Used in the event the service needs to be auto restarted.
  String get startupScript => _serviceStartScript;

  /// Returns service type that is provided.
  ///
  /// As defined by the Service Name in the Entry Point.
  String get type => _serviceType;

  /// Returns the version number of this service.
  ///
  /// As defined by the Service Version in the entry point, intended to be a
  /// selection bases for a old and new version runing at the same time.
  String get version => _serviceVersion;

  @override

  /// Returns a details string repersentation of the ServiceRegistration.
  toString() {
    StringBuffer sb = new StringBuffer("* ServiceRegistration Object *\r");
    sb.writeln("$type, version:$version, id:$id, created:$createdDateTime");
    sb.writeln(
        "startupScript: $startupScript, sourcePath: $sourcePath, environment: $environment");
    sb.writeln(
        "canMessage: $canMessage, messageChannel: ($sendChannel.toString)");
    sb.writeln(
        "canReceive: $canRespond, messageChannel: ($receiveChannel.toSting)");
    sb.writeln(
        "canManage: $canMessage, pauseing: $canPause, terminating: $canTerminate");
    return sb.toString();
  }
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

  // Handles the Registration of new services.
  static _addService(ServiceRegistration rego) {
    _currentServices.removeWhere((e) => (e.id == rego.id));
    _currentServices.add(rego);
  }
}
