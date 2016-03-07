library api;

import 'dart:async';
import 'dart:isolate';

import 'package:serviceRegistry/src/core.dart';
import 'package:serviceRegistry/src/serviceRegistration.dart';

export 'package:serviceRegistry/src/core.dart';

/// Returns an Immutable ServiceRegistry containing all the current
/// available services.
ServiceRegistry serviceRegister() => new ServiceRegistry();

/// Returns a ServiceRegistry containing the newly provisioned service.
///
/// Requires the File URI to the Main Entry Point of the Service. Will
/// Error out if the service can not be established.
Future<ServiceRegistry> provisionService(Uri pathToServiceEntryPoint) async {
  try {
    List startArg = [];
    int startCode = 0000;
    await Isolate
        .spawnUri(pathToServiceEntryPoint, startArg, startCode)
        .then((Isolate iso) {
      assert(iso != null);
    });
  } catch (e) {}

  // Attempt to provision
  // Update Registry
  return serviceRegister();
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
