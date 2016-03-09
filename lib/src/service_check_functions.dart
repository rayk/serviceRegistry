library serviceCheck;

import 'dart:async';
import 'package:string_scanner/string_scanner.dart';
import 'package:source_span/source_span.dart';
import 'package:resource/resource.dart' as resPkg;

/// Inpsects the code ensure there is a variable decalared for the service name.
checkServiceName(String serviceEntrySource) {
  RegExp serviceTarget = new RegExp(r"\serviceName)");
  SourceFile serviceSource = new SourceFile(serviceEntrySource);
  SpanScanner scanner = new SpanScanner(serviceSource.getText(0));
  bool result = scanner.scan(serviceTarget);
  print(result);
}

/// Pre-check the entry point code to ensure min requirements are met.
/// Will look for service entry point under the src directory in library
/// follow any appended paths.
Future<bool> isServiceEntryCertified(String pathToEntry) async {
  bool checksPassed = false;
  final RegExp mainStatement = new RegExp("main()");

  aquireResource(pathToEntry).then((String serviceSource) {
    var scanner = new StringScanner(serviceSource);
    print(scanner.scan(mainStatement));
    return checksPassed = true;
  });
}

/// Handles the retrival of the entry point source file.
Future<String> aquireResource(String pathFromScrouce) async {
  String packagePath = "package:serviceRegistry/src/";
  var entryPointResource = new resPkg.Resource(packagePath + pathFromScrouce);
  try {
    String entryPointSource = await entryPointResource.readAsString();
    if (entryPointSource.length == 0) {
      throw new FormatException(
          "Service Entry point file appears to be entry!");
    }
    return entryPointSource;
  } catch (e) {}
}
