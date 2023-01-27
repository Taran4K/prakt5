import 'dart:io';

import 'package:apidart/utils/app_response.dart';
import 'package:apidart/utils/app_utils.dart';
import 'package:conduit/conduit.dart';
import '../model/Finances.dart';

class AppFinances2Controller extends ResourceController {
  AppFinances2Controller(this.managedContext);

  final ManagedContext managedContext;

  @Operation.get()
    Future<Response> FiltrFinances(
      @Bind.query('Filtr') String filtr,
    ) async {
      try{
      late final Finance;
        final qFinancesSearch = Query<Finances>(managedContext)
            ..where((x) => x.number)
            .equalTo(filtr);

        final finances=await qFinancesSearch.fetch();
        return Response.ok(finances);
      } catch (e) {
        return AppResponse.serverError(e, message: 'Ошибка получения данных');
      }
    }


     @Operation.delete('deleteid')
      Future<Response> LogDeleteFinance
      (@Bind.path('deleteid') int id,
      ) async {
        try {

          final ofinance=await managedContext.fetchObjectWithID<Finances>(id);

          final qUpdateFinance=Query<Finances>(managedContext)
          ..where((x) => x.isdeleted)
          .equalTo(false)
          ..where((x) => x.id)
          .equalTo(id as int)
          ..values.isdeleted=true;

          await qUpdateFinance.updateOne();

          final findFinance=await managedContext.fetchObjectWithID<Finances>(id);
          findFinance!.backing.removeProperty("isdeleted");
          return AppResponse.ok(
            message: 'Успешное логическое удаление данных', body: findFinance!.backing.contents
          );
        } catch (e) {
          return AppResponse.serverError(e, message: 'Ошибка обновления данных');
        }
      }

      @Operation.put('deleteid')
      Future<Response> LogRestorationFinance
      (@Bind.path('deleteid') int id,
      ) async {
        try {

          final ofinance=await managedContext.fetchObjectWithID<Finances>(id);

          final qUpdateFinance=Query<Finances>(managedContext)
          ..where((x) => x.isdeleted)
          .equalTo(true)
          ..where((x) => x.id)
          .equalTo(id as int)
          ..values.isdeleted=false;

          await qUpdateFinance.updateOne();

          final findFinance=await managedContext.fetchObjectWithID<Finances>(id);
          findFinance!.backing.removeProperty("isdeleted");
          return AppResponse.ok(
            message: 'Успешное восстановление данных', body: findFinance!.backing.contents
          );
        } catch (e) {
          return AppResponse.serverError(e, message: 'Ошибка обновления данных');
        }
      }
 
}