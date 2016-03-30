import 'dart:isolate';

import 'package:serviceRegistry/serviceRegistry.dart';

@TestOn('vm')
@Timeout(const Duration(seconds: 5))
import 'package:test/test.dart';

main() {
  group("Completing the connection:", () {
    ReceivePort tempProvisionPort = new ReceivePort();
    ReceivePort replyFromServicePort = new ReceivePort();

    Map provisioningPorts = {
      'tempExchangePort': tempProvisionPort.sendPort,
      'serviceReponsePort': replyFromServicePort.sendPort
    };

    List startupArguments = [
      provisioningPorts,
      [
        'serviceArg1Value',
        'serviceArg2Value',
        'serviceArg3Value',
        'serviceArg4Value'
      ]
    ];
    int startupCode = 9999;

    Map serviceDetails = {
      'serviceName': 'EchoService',
      'serviceVersion': '0.0.1',
      'startArgs': startupArguments,
      'startCode': startupCode
    };

    test('Should complete connection returning a Map.', () {
      Map result = completeRemoteConnection(serviceDetails);

      // Requester Listing for return service details.
      tempProvisionPort.listen(expectAsync((Map serviceDetails) {
        expect(serviceDetails.length, equals(9));
        expect(serviceDetails['requesterSendPort'],
            equals(new isInstanceOf<SendPort>()));
        tempProvisionPort.close();
      }, count: 1));

      // Service Provider should receive after the connection is completed.
      expect(result, equals(new isInstanceOf<Map>()));
      expect(result.length, equals(11));
      expect(result['serviceArgs'], equals(startupArguments[1]));
      expect(result['inBoundReceivePort'],
          equals(new isInstanceOf<ReceivePort>()));
      expect(result['outBoundSendPort'], equals(new isInstanceOf<SendPort>()));
    });
  });
}
