library api;

import 'dart:async';
import 'dart:isolate';
import 'dart:io';
import 'package:serviceRegistry/src/core.dart';
import 'package:serviceRegistry/src/isolate_functions.dart';
import 'package:serviceRegistry/src/path_functions.dart';

export 'package:serviceRegistry/src/core.dart';

/// Returns an Immutable ServiceRegistry containing all the current
/// available services.
ServiceRegistry serviceRegister() => new ServiceRegistry();

/// Returns a ServiceRegistration for the newly started service.
///
/// The new services needs four parameters.
///
/// - Path for the entry point source code, in the form of a List of String.
/// - Path where the service should look for packages.
/// - Startup Arguments that need to be passed to the service, which is being provisioned.
Future<ServiceRegistration> startService(List<String> entryPointPath,
    {List serviceArguments}) async {
  Uri entryPoint = toUri(entryPointPath);
  List serviceArgs = serviceArguments ?? new List();
  Map spawned = await spawnIsolate(entryPoint, serviceArgs);
  Map connection = await completeRemoteConnection(spawned);
  return new ServiceRegistration(spawned, connection);
}

/// Returns a ServiceRegistry when the requested service has been stopped.
///
/// After the [targetService] completes it's current task, if there is one.
/// The service along with all it's communication channels and any other resources
/// shall be shutdown.
///
/// Failure to terminate will result an exception, which can dealt with by calling
/// terminate again.
ServiceRegistry stopService(ServiceRegistration targetService) {
  targetService.shutdown();
  return serviceRegister();
}

/// Used by the service's remote code to completed it's connection back to the requester.
///
/// This function is used by the remote service to complete the hand shaking required
/// as part of the starting a service. The function is provided to all the remote
/// service code abstracted way from the underlying Isolate and Channel connection.
Map completeRemoteConnection(Map serviceDetails) {
  Map serviceRegistration = new Map();

  final ReceivePort serviceInboundPort = new ReceivePort();
  final SendPort requesterSendPort = serviceInboundPort.sendPort;
  SendPort _tempExchangePort;

  serviceRegistration['name'] = serviceDetails['serviceName'];
  serviceRegistration['version'] = serviceDetails['serviceVersion'];
  serviceRegistration['serviceArgs'] =
      _serviceArgs(serviceDetails['startArgs']);
  serviceRegistration['Id'] = Isolate.current.hashCode.toString();
  serviceRegistration['environment'] = Platform.operatingSystem;
  serviceRegistration['vmVersion'] = Platform.version;
  serviceRegistration['sourcePath'] = Platform.packageRoot ?? 'Not Available';
  serviceRegistration['startPath'] =
      Platform.script.toString() ?? 'Not Available';
  serviceRegistration['requesterSendPort'] = requesterSendPort;
  _tempExchangePort = _temporaryProvisionPort(serviceDetails['startArgs']);

  _tempExchangePort.send(serviceRegistration);

  serviceRegistration['inBoundReceivePort'] = serviceInboundPort;
  serviceRegistration['requesterBackChannel'] =
      _serviceResponsePort(serviceDetails['startArgs']);

  return serviceRegistration;
}

SendPort _temporaryProvisionPort(List args) {
  Map ports = args.firstWhere((e) => e is Map);
  assert(ports.isNotEmpty);
  return ports.containsKey('tempProPort')
      ? ports['tempProPort']
      : throw new ArgumentError('Missing Temp Provisioning Port!');
}

SendPort _serviceResponsePort(List args) {
  Map ports = args.firstWhere((e) => e is Map);
  assert(ports.isNotEmpty);
  return ports.containsKey('tempExchangePort')
      ? ports['tempExchangePort']
      : throw new ArgumentError('Missing Temp Provisioning Port!');
}

List _serviceArgs(List args) {
  return args[1];
}
