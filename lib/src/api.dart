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
    List<String> entryPointWithPath, List<String> servicePackageRoot) {
  Uri entryPoint = toUri(entryPointWithPath);
  Uri packageRoot = toUri(servicePackageRoot);
  try {
    return spawnIsolate(entryPoint, packageRoot).then((List iso) {
      assert(iso[0] is ReceivePort);
      return identifyService(iso[0]).then((Map svcDetails) {
        assert(svcDetails['ServiceRequestPort'] is SendPort);
        assert(iso[1] is ReceivePort);
        assert(iso[2] is Isolate);
        return new ServiceRegistration(iso[2], svcDetails, iso[1]);
      });
    });
  } on IsolateSpawnException {
    // Throw on problem the entry point was wrong.
  } on RemoteError {
    // Throw on problem with service communication.
  }
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
