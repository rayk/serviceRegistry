library api.types;

import 'dart:async';
import 'dart:isolate';
import 'dart:developer';
import 'dart:collection';

import 'package:stream_channel/stream_channel.dart';

/// Represents a running service and is used to access that service.
class ServiceRegistration {
  final DateTime _created = new DateTime.now();
  String _serviceType,
      _serviceEnvironment,
      _serviceVMVersion,
      _serviceSourcePath,
      _serviceStartScript,
      _serviceId,
      _serviceVersion,
      _serviceExitSignature;
  IsolateChannel _channel;
  Capability _pauseCapability, _terminateCapability;
  SendPort _controlPort, _serviceRequest;
  ReceivePort _serviceResponses, _exitAlertPort, _errorMonitorPort;
  Isolate _underlyingIsolate;

  ServiceRegistration(Map isolateDetails, Map connectionDetails) {
    _channel = new IsolateChannel(_serviceResponses, _serviceRequest);
    _controlPort = _underlyingIsolate.controlPort;
    _errorMonitorPort = isolateDetails['onError'];
    _exitAlertPort = isolateDetails['onExitPort'];
    _pauseCapability = _underlyingIsolate.pauseCapability;
    _serviceEnvironment = connectionDetails['environment'];
    _serviceExitSignature = isolateDetails['onExitSignature'];
    _serviceId = connectionDetails['Id'];
    _serviceRequest = connectionDetails['requesterSendPort'];
    _serviceResponses = isolateDetails['serviceResponsOnPort'];
    _serviceSourcePath = connectionDetails['sourcePath'];
    _serviceStartScript = connectionDetails['startPath'];
    _serviceType = connectionDetails['name'];
    _serviceVersion = connectionDetails['version'];
    _serviceVMVersion = connectionDetails['vmVersion'];
    _terminateCapability = _underlyingIsolate.terminateCapability;
    _underlyingIsolate = isolateDetails['isolate'];
  }

  /// Creates Service Registration and places it on the registry if it't there.
  ///
  /// This is the dependence on Service Registry.
  ServiceRegistration.old(
      Isolate iso, Map serviceDetails, ReceivePort servicePort) {
    _underlyingIsolate = iso;
    _pauseCapability = iso.pauseCapability;
    _terminateCapability = iso.terminateCapability;
    _controlPort = iso.controlPort;
    _serviceResponses = servicePort;
    _serviceType = serviceDetails['name'];
    _serviceId = serviceDetails['Id'];
    _serviceVersion = serviceDetails['version'];
    _serviceEnvironment = serviceDetails['environment'];
    _serviceVMVersion = serviceDetails['vmVersion'];
    _serviceSourcePath = serviceDetails['sourcePath'];
    _serviceStartScript = serviceDetails['startPath'];
    _serviceRequest = serviceDetails['requestSendPort'];
    _channel = new IsolateChannel(_serviceResponses, _serviceRequest);
    ServiceRegistry._addService(this);
  }

  /// Returns true if the service can be auto managed by the registry.
  bool get canAutoManage => _exitAlertPort != null &&
      _errorMonitorPort != null &&
      canPause &&
      canTerminate ? true : false;

  /// Returns true if this service accepts messaged.
  bool get canMessage => _serviceRequest != null ? true : false;

  /// Returns true if we have the capability to pause the service
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

  /// Returns an unique Id for the specific instance of the service.
  ///
  /// ID is based on the hashcode of the services underlying Isolate, it is
  /// used to ensure that the service running on the particular isolate does
  /// no appear in the registry more then once. A second attempt to register
  /// the same service isolate will remove the exiting one an replace it with
  /// the new old, hence allowing it to be refreshed.
  String get id => _serviceId;

  /// Returns the receive side of channel to listen for service responds.
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
  /// selection bases for a old and new version running at the same time.
  String get version => _serviceVersion;

  /// This is the signature send on the exit port as the last action of the
  /// Isolate/Service before it terminates.
  String get existSignature => _serviceExitSignature;

  /// Shuts down the service and frees all the associated resources.
  void shutdown() {
    _underlyingIsolate.kill();
    _serviceResponses.close();
    _channel.sink.close();
    ServiceRegistry._removeService(this);
  }

  @override

  /// Returns a details string representation of the ServiceRegistration.
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

  /// Returns the current instance of the ServiceRegistry with the latest
  /// currently available services.
  factory ServiceRegistry() => _instance;

  ServiceRegistry._internal();

  /// Returns a immutable list of all currently available services.
  UnmodifiableListView<ServiceRegistration> get services {
    return new UnmodifiableListView(_currentServices);
  }

  /// Add a service to the registry and starts monitoring it.
  static _addService(ServiceRegistration service) {
    _currentServices.removeWhere((e) => (e.id == service.id));
    _currentServices.add(service);
  }

  // Handles the removal of a new service Registration.
  //
  // The service is removed from the registry before it is
  // actual killed, to reduce the window as to being able to
  // service schedule for termination.
  static _removeService(ServiceRegistration service) {
    _currentServices.removeWhere((e) => (e.id == service.id));
  }
}
