import 'package:path/path.dart' as path;
import 'package:serviceRegistry/serviceRegistry.dart';

/// API Test of get hold of the under registry different conditions.
@TestOn('vm')
import 'package:test/test.dart';

void main() {
  /// Just get a single authoritative registry.
  group('Aquire Service Registry.', () {
    test('Should return a service registry without any entries.', () {
      ServiceRegistry registry = serviceRegister();
      expect(registry, isNotNull);
      expect(registry.availableServices.isEmpty, isTrue);
    });

    test('Should not create a new registry when nothing has changed.', () {
      ServiceRegistry registryA = serviceRegister();
      ServiceRegistry registryB = serviceRegister();
      expect(registryA == registryB, isTrue);
    });
  });

  /// Adding a service and it should appear in the registry.
  group('Register a service with.', () {
    test('Should get updated Registry when I register a service.', () async {
      var context = new path.Context();
      Uri servicePath = new Uri.file(context.join(
          context.current, "test", 'testEchoService', 'echoService.dart'));
      provisionService(servicePath).then((ServiceRegistry svry) {
        expect(svry, isNotNull);
      });
    });

    test('Should error out when handed a broken or non existent URI.', () {});
  });

  /// Lookup a service by providing the enum for the service type.
  group('Query for a service.', () {
    test('Should  .', () {});
  });
}
