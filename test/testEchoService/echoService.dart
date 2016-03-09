library echoService;

import 'dart:isolate';

/// This service is used as a test service to determine if a new service can be
/// provision.
/// Actually not alot happens here. In Essense it deals with only with low level
/// provisioning messages.

/// Main entry point for a service, Args and startup code is used to establish
/// any required shaking.
main(List args, int startupCode) {
  final String serviceName = "EchoService";
  final int serviceVersion = 1;
  final ReceivePort InBoundMessagePort = new ReceivePort();
  SendPort TempProvisionPort, OutBoundMessagePort;

  isPortExchangeRequested(startupCode)
      ? isPortExchangePossible(args) ? exchangePorts() : sendProvisionFail()
      : setupService();
}

/// Is this service being provision in a manner that this service to reply to
/// the provisioner.
isPortExchangeRequested(int code) {}

// Has the provisioner provided all the required elements to excute a port exchange.
isPortExchangePossible(List args) {}

/// Carries out the port exchange protocol with the provisioner.
exchangePorts() {}

/// Informs the provisioner that a port exchange is not possible.
sendProvisionFail() {}

/// Setups the basic identifiers of this service.
setupService() {}
