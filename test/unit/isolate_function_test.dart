import 'dart:isolate';

import 'package:serviceRegistry/src/isolate_functions.dart';
import 'package:serviceRegistry/src/path_functions.dart';
@TestOn('vm')
@Timeout(const Duration(seconds: 5))
import 'package:test/test.dart';

void main() {
  group("Spawns Isolates:", () {

    test('Should actually create an Running Isolate.',() async{
      var entryPath =
      toUri(['example', 'echoServiceExample', 'entry_point.dart']);
      List serviceArgs = ['a', 'b', 'c', 'd'];
      Map isoDetails = await spawnIsolate(entryPath, serviceArgs);
      ReceivePort testPingResponsePort = new ReceivePort();
      Isolate iso = isoDetails['isolate'];
      iso.ping(testPingResponsePort.sendPort, response: "pingTest");

      testPingResponsePort.listen(expectAsync((String msg){
        expect(msg, equals('pingTest'));
        iso.kill();
        testPingResponsePort.close();
        isoDetails.forEach((K,V) {
          if( V is ReceivePort){
            V.close();
          }
        });
      }, count:1));
    });

    test('Should return a Map with Isolates and ports.', () async {
      var entryPath =
      toUri(['example', 'echoServiceExample', 'entry_point.dart']);
      List serviceArgs = [];
      Map isoDetails = await spawnIsolate(entryPath, serviceArgs);
      expect(isoDetails, isMap);
      expect(isoDetails['isolate'], equals(new isInstanceOf<Isolate>()));
      expect(
          isoDetails['onErrorPort'], equals(new isInstanceOf<ReceivePort>()));
      expect(isoDetails['onExitPort'], equals(new isInstanceOf<ReceivePort>()));
      expect(isoDetails['onExitSignature'], contains("EXIT"));
      expect(isoDetails['serviceResponseOnPort'],
          equals(new isInstanceOf<ReceivePort>()));
      expect(isoDetails['tempExchangePort'],
          equals(new isInstanceOf<ReceivePort>()));

      isoDetails.forEach((K,V) {
        if( V is ReceivePort){
          V.close();}
      });

      isoDetails['isolate'].kill();

    });


    test('Should Exception with a non-existent entrypoint.', () async {
      var entryPath = toUri(['echo_service', 'does_not_exist.dart']);
      List serviceArgs = ['a', 'b', 'c', 'd'];
      expect(spawnIsolate(entryPath, serviceArgs),
          throwsA(new isInstanceOf<IsolateSpawnException>()));
    });


  });
}



