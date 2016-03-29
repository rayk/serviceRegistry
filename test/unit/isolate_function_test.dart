import 'dart:isolate';

import 'package:serviceRegistry/src/isolate_functions.dart';
import 'package:serviceRegistry/src/path_functions.dart';
@TestOn('vm')
@Timeout(const Duration(seconds: 5))
import 'package:test/test.dart';

void main() {
  group("Spawns Isolate.", () {
    test('Should return a list with Isolates and ports.', () async {
      var entryPath = toUri(['lib', 'src', 'echo_service', 'entry_point.dart']);
      var rootPack = toUri(['lib', 'src', 'echo_service']);
      var isoDetails = await spawnIsolate(entryPath, rootPack);
      expect(isoDetails, equals(new isInstanceOf<List>()));
      expect(isoDetails.length, equals(3));
      expect(isoDetails[0], equals(new isInstanceOf<ReceivePort>()));
      expect(isoDetails[1], equals(new isInstanceOf<ReceivePort>()));
      expect(isoDetails[2], equals(new isInstanceOf<Isolate>()));
    });

    test('Should expection if a non-existent entrypoint is passed in.',
        () async {
      var entryPath =
          toUri(['lib', 'src', 'echo_service', 'does_not_exist.dart']);
      var rootPack = toUri(['lib', 'src', 'echo_service']);
      expect(spawnIsolate(entryPath, rootPack),
          throwsA(new isInstanceOf<IsolateSpawnException>()));
    });
  });

  group("Receive handshake:", () {
    test('Should receive a map with service.', () async {
      var entryPath = toUri(['lib', 'src', 'echo_service', 'entry_point.dart']);
      var rootPack = toUri(['lib', 'src', 'echo_service']);
      spawnIsolate(entryPath, rootPack).then((List isoDetails) async {
        Map svcDetail = await identifyService(isoDetails[0]);
        expect(svcDetail.length, equals(8));
        expect(svcDetail['ServiceName'], isNotEmpty, reason: 'No Service Name');
        expect(svcDetail['ServiceVersion'], isNotEmpty, reason: 'No Version');
        expect(svcDetail['ServiceId'], isNotEmpty, reason: 'No Service ID');
        expect(svcDetail['ServiceId'].length, greaterThanOrEqualTo(6));
        expect(svcDetail['ServiceEnvironment'], isNotEmpty, reason: 'No Envir');
        expect(svcDetail['ServiceVMVersion'], isNotEmpty,
            reason: 'No VM version');
        expect(svcDetail['ServiceSourcePath'], isNotEmpty,
            reason: 'Source Path');
        expect(svcDetail['ServiceStartScript'], isNotNull,
            reason: 'Could be blank because not platform implement this.');
        expect(svcDetail['ServiceRequestPort'],
            equals(new isInstanceOf<SendPort>()));
      });
    });
  });

  group("Isolate Live Check:", () {
    test("Should response to pings when the Isolate is alive", () async {
      var entryPath = toUri(['lib', 'src', 'echo_service', 'entry_point.dart']);
      var rootPack = toUri(['lib', 'src', 'echo_service']);
      var isoDetails = await spawnIsolate(entryPath, rootPack);
      bool reply = await isIsolateAlive(isoDetails[2]);
      expect(reply, isTrue);
    });
  });
}
