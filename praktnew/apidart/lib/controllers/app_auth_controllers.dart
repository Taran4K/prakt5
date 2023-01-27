import 'dart:io';

import 'package:apidart/model/user.dart';
import 'package:apidart/model/model_response.dart';
import 'package:apidart/utils/app_utils.dart';
import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class AppAuthController extends ResourceController {
  AppAuthController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {
    if (user.password == null || user.userName == null) {
      return Response.badRequest(
          body: ModelResponse(message: 'Поля password username обязательны'));
    }
    try {
      final qFindUser = Query<User>(managedContext)
        ..where((element) => element.userName).equalTo(user.userName)
        ..returningProperties(
          (element) => [
            element.id,
            element.salt,
            element.hashPassword,
          ],
        );
      final findUser = await qFindUser.fetchOne();
      if (findUser == null) {
        throw QueryException.input('Пользователь не найден', []);
      }

      final requestHAshPassword =
          generatePasswordHash(user.password ?? '', findUser.salt ?? '');

      if (requestHAshPassword == findUser.hashPassword) {
        _updateTokens(findUser.id ?? -1, managedContext);

        final newUser =
            await managedContext.fetchObjectWithID<User>(findUser.id);

        return Response.ok(ModelResponse(
          data: newUser!.backing.contents,
          message: 'Успешная авторизация',
        ));
      } else {
        throw QueryException.input('Не верный пароль', []);
      }
    } on QueryException catch (e) {
      return Response.serverError(body: ModelResponse(message: e.message));
    }
  }

  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.password == null || user.userName == null || user.email == null) {
      return Response.badRequest(
          body: ModelResponse(
              message: 'Поля password username email обязательны'));
    }

    final salt = generateRandomSalt();
    final hashPassword = generatePasswordHash(user.password!, salt);

    try {
      late final int id;
      await managedContext.transaction((transaction) async {
        final qCreateUser = Query<User>(transaction)
          ..values.userName = user.userName
          ..values.email = user.email
          ..values.salt = salt
          ..values.hashPassword = hashPassword;

        final createdUser = await qCreateUser.insert();
        
        id = createdUser.id!;

        _updateTokens(id, transaction);
      });

      final userData = await managedContext.fetchObjectWithID<User>(id);

      return Response.ok(
        ModelResponse(
          data: userData!.backing.contents,
          message: 'Пользователь успешно зарегистрировался',
        ),
      );
    } on QueryException catch (e) {
      return Response.serverError(body: ModelResponse(message: e.message));
    }
  }

  @Operation.post('refresh')
  Future<Response> refreshToken(@Bind.path('refresh') 
  String refreshToken) async {
    try {
      final id =AppUtils.getIdFromToken(refreshToken);

      final user=await managedContext.fetchObjectWithID<User>(id);

      if (user!.refreshToken!=refreshToken) {
        return Response.unauthorized(body: 'Token не валидный');
      }

      _updateTokens(id, managedContext);

      return Response.ok(
        ModelResponse(data: user.backing.contents,
        message: 'Токен успешно обновлен',
        ),
      );
    } on QueryException catch (e){
      return Response.serverError(body: ModelResponse(message: e.message));
    }
  }

  void _updateTokens(int id, ManagedContext transaction) async {
    final Map<String, String> tokens=_getTokens(id);

    final qUpdateTokens=Query<User>(transaction)
    ..where((x) => x.id).equalTo(id)
    ..values.accessToken=tokens['access']
    ..values.refreshToken=tokens['refresh'];

    await qUpdateTokens.updateOne();
  }

  Map<String, String> _getTokens(int id) {
    final key=Platform.environment['SECRET_KEY']??'SECRET_KEY';
    final accessClaimSet=JwtClaim(
      maxAge: const Duration(hours: 1),
      otherClaims: {'id':id},
    );
    final refreshClaimSet=JwtClaim(
      otherClaims: {'id': id},
    );
    final tokens=<String, String>{};
    tokens['access']=issueJwtHS256(accessClaimSet, key);
    tokens['refresh']=issueJwtHS256(refreshClaimSet, key);

    return tokens;
  }
}

