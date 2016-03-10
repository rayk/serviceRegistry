@TestOn('vm')
import 'package:test/test.dart';
import 'dart:io';

import 'package:serviceRegistry/src/path_functions.dart';

main() {
  group("Forming URI:", () {
    test('Should return uri for string list.', () {
      List path = ['lib', 'src', 'echo_service', 'entry_point.dart'];
      Uri testPath = toUri(path);
      expect(testPath, equals(new isInstanceOf<Uri>()));
    });

    test("Should return uri for a package root", () {
      List path = ['packages', 'logging'];
      Uri testPath = toUri(path);
      expect(testPath, equals(new isInstanceOf<Uri>()));
    });

    test("Should return true if file Uri exist.", () async {
      List path = ['lib', 'src', 'echo_service', 'entry_point.dart'];
      Uri testPath = toUri(path);
      expect(await fileExist(testPath), equals(true));
    });

    test("Should return false if the file uri does not exist.", () async {
      List path = ['lib', 'src', 'echo_service', 'entry_dog.dart'];
      Uri testPath = toUri(path);
      expect(await fileExist(testPath), equals(false));
    });

    test("Should return turn if the directory exist", () async {
      List path = ['packages', 'logging'];
      Uri testPath = toUri(path);
      expect(await dirExist(testPath), isTrue);
    });

    test("Should return false if the directory does not exist", () async {
      List path = ['packages', 'doesnotexist'];
      Uri testPath = toUri(path);
      expect(await dirExist(testPath), isFalse);
    });
  });
}
