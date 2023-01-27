import 'dart:io';

import 'package:apidart/apidart.dart';
import 'package:conduit/conduit.dart';

void main(List<String> arguments) async{
  final port=int.parse(Platform.environment["PORT"]??'8080');
  final service=Application<AppService>()
  ..options.port=port
  ..options.configurationFilePath='config.yaml';
  await service.start(numberOfInstances: 3, consoleLogging: true);
}
