import 'dart:io';

import 'package:apidart/controllers/app_auth_controllers.dart';
import 'package:apidart/controllers/app_finances2_controller.dart';
import 'package:apidart/controllers/app_finances_controller.dart';
import 'package:apidart/controllers/app_token_controller.dart';
import 'package:apidart/controllers/app_user_controller.dart';
import 'package:conduit/conduit.dart';
import 'package:apidart/model/user.dart';
import 'package:apidart/model/Finances.dart';
import 'package:apidart/model/History.dart';

class AppService extends ApplicationChannel{
  late final ManagedContext managedContext;

  @override
  Future prepare(){
    final persistentStore=_initDatabase();

    managedContext=ManagedContext(
      ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);
      return super.prepare();
  }

  @override
  Controller get entryPoint=>Router()
  ..route('token/[:refresh]').link(() => 
  AppAuthController(managedContext))
  
  ..route('user')
  .link(AppTokenController.new)!
  .link(() => AppUserController(managedContext))

  ..route('finances/[:idfinances]')
  .link(() => AppFinancesController(managedContext))

  ..route('finances/options/[:deleteid]')
  .link(() => AppFinances2Controller(managedContext));

  PersistentStore _initDatabase(){
    final username=Platform.environment['DB_USERNAME'] ?? 'postgres';
    final password=Platform.environment['DB_PASSWORD'] ?? '123';
    final host=Platform.environment['DB_HOST'] ?? 'localhost';
    final port=int.parse(Platform.environment['DB_PORT'] ?? '5432');
    final databaseName=Platform.environment['DB_NAME'] ?? 'postgres';
    return PostgreSQLPersistentStore(username, password, host, port, databaseName);
  }

}