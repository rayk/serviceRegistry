library api;

import 'dart:async';
import 'dart:isolate';
import 'package:serviceRegistry/src/path_functions.dart';
import 'package:serviceRegistry/src/isolate_functions.dart';

import 'package:serviceRegistry/src/core.dart';
export 'package:serviceRegistry/src/core.dart';

/// Returns an Immutable ServiceRegistry containing all the current
/// available services.
ServiceRegistry serviceRegister() => new ServiceRegistry();

/// Returns a ServiceRegistration for the newly started service.
///
/// Takes a two list of strings one for the entry point and other for
/// package location of the source file. This are convert to Platform specific
/// path names, allowing it to work across environments.
Future<ServiceRegistration> startService(
    List<String> entryPointWithPath, List<String> servicePackageRoot) async {
  Uri entryPoint = toUri(entryPointWithPath);
  Uri packageRoot = toUri(servicePackageRoot);
  bool entryExist = await fileExist(entryPoint);
  bool packageExist = await dirExist(packageRoot);
  if (entryExist && packageExist) {
    spawnIsolate(entryPoint, packageRoot).then((List provisioned) {
      identifyService(provisioned[0]).then((Map serviceDetails) {
        return new ServiceRegistration(
            provisioned[2], serviceDetails, provisioned[1]);
      });
    });
  }
}

/// Returns a ServiceRegistry when the requested service has been terminated.
///
/// After the [targetService] completes it's current task, if there is one.
/// The service along with all it's communication channels and any other resources
/// shall be shutdown.
///
/// Failure to terminate will result an exception, which can dealt with by calling
/// terminate again.
Future<ServiceRegistry> terminateService(
    ServiceRegistration targetService) async {
  return serviceRegister();
}

/// Privately register the service.
Future<ServiceRegistration> _registerIsolate(Uri serviceEntryPoint,
    {bool channelRequired: true}) async {
  ServiceRegistration rego;
  ReceivePort tempProvisionPort = new ReceivePort();
  ReceivePort actualServicePort = new ReceivePort();
  List startArgs = [tempProvisionPort.sendPort, actualServicePort.sendPort];
  int startCode;
  channelRequired ? startCode = 9999 : startCode = 0000;
  Isolate.spawnUri(serviceEntryPoint, startArgs, startCode).then((Isolate iso) {
    _identifyIsolate(tempProvisionPort).then((Map creds) {
      rego = new ServiceRegistration(iso, creds, actualServicePort);
    });
    return rego;
  });
}

/// Listen for the Service Credentials and then close the provisioning port.
Future<Map> _identifyIsolate(ReceivePort provisionPort) async {
  provisionPort.listen((Map credentials) {
    assert(credentials.length == 8);
    provisionPort.close();
    return credentials;
  });
}
