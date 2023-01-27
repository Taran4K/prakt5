import 'dart:io';

import 'package:apidart/utils/app_response.dart';
import 'package:apidart/utils/app_utils.dart';
import 'package:conduit/conduit.dart';

import '../model/user.dart';

class AppUserController extends ResourceController {
  AppUserController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.get()
  Future<Response> getProfile(@Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      final id =AppUtils.getIdFromToken(header);

      final user=await managedContext.fetchObjectWithID<User>(id);

      user!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);

      return AppResponse.ok(
        message: 'Успешное получение профиля', body: user.backing.contents
      );
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка получения профиля');
    }
  }

  @Operation.post()
  Future<Response> updateProfile
  (@Bind.header(HttpHeaders.authorizationHeader) String header,
  @Bind.body() User user,
  ) async {
    try {
      final id =AppUtils.getIdFromToken(header);

      final fuser=await managedContext.fetchObjectWithID<User>(id);

      final qUpdateUser=Query<User>(managedContext)
      ..where((x) => x.id)
      .equalTo(id)
      ..values.userName=user.userName??fuser!.userName
      ..values.email=user.email??fuser!.email;

      await qUpdateUser.updateOne();

      final findUser=await managedContext.fetchObjectWithID<User>(id);
      findUser!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);

      return AppResponse.ok(
        message: 'Успешное обновление данных', body: findUser.backing.contents
      );
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка обновления данных');
    }
  }

   @Operation.put()
  Future<Response> updatePassword
  (@Bind.header(HttpHeaders.authorizationHeader) String header,
  @Bind.query('newPassword') String newPassword,
  @Bind.query('oldPassword') String oldPassword,
  ) async {
    try {
      final id =AppUtils.getIdFromToken(header);

      final qFindUser=Query<User>(managedContext)
      ..where((x) => x.id)
      .equalTo(id)
      ..returningProperties((x) => [x.salt, x.hashPassword],);

      final fUser=await qFindUser.fetchOne();

      final oldHashPassword=generatePasswordHash(oldPassword, fUser!.salt??"");

      // if (oldHashPassword!=fUser.hashPassword){
      //   return AppResponse.badRequest(
      //     message: 'Неверные старый пароль');
      // }

      final newHashPassword=generatePasswordHash(newPassword, fUser.salt??"");

      final qUpdateUser=Query<User>(managedContext)
      ..where((x) => x.id).equalTo(id)
      ..values.hashPassword=newHashPassword;

      await qUpdateUser.fetchOne();

      return AppResponse.ok(
        message: 'Успешное обновление пароля'
      );
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка обновления пароля');
    }
  }
}