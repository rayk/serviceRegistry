import 'dart:isolate';

import 'package:serviceRegistry/src/core.dart';
@TestOn('vm')
import 'package:test/test.dart';

main() {
  group("Register a created Isolate:", () {
    test('Should create a complete Service Registration .', () {
      ReceivePort mockServicePort = new ReceivePort();
      final Map<String, String> serviceCreds = {
        'ServiceName': "testServiceName",
        'ServiceVersion': '3',
        'ServiceId': '32033859267',
        'ServiceEnvironment': 'MacOSX',
        'ServiceVMVersion': '1.15.0',
        'ServiceSourcePath': '/package',
        'ServiceStartScript': '/script.dart',
        'ServiceRequestPort': mockServicePort.sendPort,
      };
      ReceivePort mockConsumerPort = new ReceivePort();
      Isolate iso = Isolate.current;

      ServiceRegistration testRego =
          new ServiceRegistration(iso, serviceCreds, mockServicePort);

      expect(testRego.type, equals('testServiceName'));
      expect(testRego.id, equals('32033859267'));
      expect(testRego.version, isNotEmpty, reason: 'No Service Version');
      expect(testRego.canPause, isNotNull, reason: 'Pause Cap Null');
      expect(testRego.canTerminate, isNotNull, reason: 'Terminate Cap Null');
      expect(testRego.environment, isNotEmpty, reason: 'Environment Missing');
      expect(testRego.sourcePath, isNotEmpty, reason: 'No Source Path');
      expect(testRego.startupScript, isNotEmpty, reason: 'No Startup Script');
      expect(testRego.canRespond, isTrue, reason: 'No Receive Port');
      expect(testRego.canMessage, isTrue, reason: 'No Send Port');
      expect(testRego.canAutoManage, isTrue, reason: 'No Monitoring');
      expect(testRego.receiveChannel, isNotNull, reason: 'No Receive Channel');
      expect(testRego.sendChannel, isNotNull, reason: 'No Send Channel');

      ServiceRegistry registry = new ServiceRegistry();

      List serviceList = registry.availableServices;

      expect(serviceList.isNotEmpty, isTrue, reason: 'Service Not Listed');

      expect(
          serviceList.first, equals(new isInstanceOf<ServiceRegistration>()));
    });

    test(
        'Should not create second Service Registration for same service instance',
        () {
      ReceivePort mockServicePort = new ReceivePort();
      final Map<String, String> serviceCreds = {
        'ServiceName': "testServiceName",
        'ServiceVersion': '3',
        'ServiceId': '32033859267',
        'ServiceEnvironment': 'MacOSX',
        'ServiceVMVersion': '1.15.0',
        'ServiceSourcePath': '/package',
        'ServiceStartScript': '/script.dart',
        'ServiceRequestPort': mockServicePort.sendPort,
      };
      ReceivePort mockConsumerPort = new ReceivePort();
      Isolate iso = Isolate.current;

      ServiceRegistration testRego =
          new ServiceRegistration(iso, serviceCreds, mockServicePort);

      expect(testRego.type, equals('testServiceName'));
      expect(testRego.id, equals('32033859267'));
      expect(testRego.version, isNotEmpty, reason: 'No Service Version');
      expect(testRego.canPause, isNotNull, reason: 'Pause Cap Null');
      expect(testRego.canTerminate, isNotNull, reason: 'Terminate Cap Null');
      expect(testRego.environment, isNotEmpty, reason: 'Environment Missing');
      expect(testRego.sourcePath, isNotEmpty, reason: 'No Source Path');
      expect(testRego.startupScript, isNotEmpty, reason: 'No Startup Script');
      expect(testRego.canRespond, isTrue, reason: 'No Receive Port');
      expect(testRego.canMessage, isTrue, reason: 'No Send Port');
      expect(testRego.canAutoManage, isTrue, reason: 'No Monitoring');
      expect(testRego.receiveChannel, isNotNull, reason: 'No Receive Channel');
      expect(testRego.sendChannel, isNotNull, reason: 'No Send Channel');

      ServiceRegistry registry = new ServiceRegistry();

      List serviceList = registry.availableServices;

      expect(serviceList.length, equals(1),
          reason: 'Should not add existing service');

      expect(
          serviceList.first, equals(new isInstanceOf<ServiceRegistration>()));
    });

    test('Should another second entry for different service.', () {
      ReceivePort mockServicePort = new ReceivePort();
      final Map<String, String> serviceCreds = {
        'ServiceName': "SecondTestServiceName",
        'ServiceVersion': '2',
        'ServiceId': '23948329578',
        'ServiceEnvironment': 'MacOSX',
        'ServiceVMVersion': '1.15.0',
        'ServiceSourcePath': '/package',
        'ServiceStartScript': '/script2.dart',
        'ServiceRequestPort': mockServicePort.sendPort,
      };
      ReceivePort mockConsumerPort = new ReceivePort();
      Isolate iso = Isolate.current;

      ServiceRegistration testRego =
          new ServiceRegistration(iso, serviceCreds, mockServicePort);

      expect(testRego.type, equals('SecondTestServiceName'));
      expect(testRego.id, equals('23948329578'));
      expect(testRego.version, isNotEmpty, reason: 'No Service Version');
      expect(testRego.canPause, isNotNull, reason: 'Pause Cap Null');
      expect(testRego.canTerminate, isNotNull, reason: 'Terminate Cap Null');
      expect(testRego.environment, isNotEmpty, reason: 'Environment Missing');
      expect(testRego.sourcePath, isNotEmpty, reason: 'No Source Path');
      expect(testRego.startupScript, isNotEmpty, reason: 'No Startup Script');
      expect(testRego.canRespond, isTrue, reason: 'No Receive Port');
      expect(testRego.canMessage, isTrue, reason: 'No Send Port');
      expect(testRego.canAutoManage, isTrue, reason: 'No Monitoring');
      expect(testRego.receiveChannel, isNotNull, reason: 'No Receive Channel');
      expect(testRego.sendChannel, isNotNull, reason: 'No Send Channel');

      ServiceRegistry registry = new ServiceRegistry();

      List serviceList = registry.availableServices;

      expect(serviceList.length, equals(2), reason: 'Second Service Missing!');

      expect(serviceList.last, equals(new isInstanceOf<ServiceRegistration>()));
    });
  });
}
