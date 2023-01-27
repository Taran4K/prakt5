import 'dart:io';

import 'package:apidart/model/History.dart';
import 'package:apidart/utils/app_response.dart';
import 'package:apidart/utils/app_utils.dart';
import 'package:conduit/conduit.dart';
import '../model/Finances.dart';

class AppFinancesController extends ResourceController {
  AppFinancesController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.get('idfinances')
  Future<Response> getFinances(@Bind.path('idfinances') int id,
  ) async {
    try {
      final finance=await managedContext.fetchObjectWithID<Finances>(id);
      if (finance?.isdeleted==false)
      {
        finance!.backing.removeProperty("isdeleted");
      return AppResponse.ok(
        message: 'Успешное получение профиля', body: finance.backing.contents
      );
      }
      else
        return Response.serverError(body: "Ошибка получения данных");
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка получения данных');
    }
  }

  @Operation.put('idfinances')
  Future<Response> UpdateFinance
  (@Bind.path('idfinances') int id,
  @Bind.body() Finances finance,
  ) async {
    try {

      final ofinance=await managedContext.fetchObjectWithID<Finances>(id);

      final qUpdateFinance=Query<Finances>(managedContext)
      ..where((x) => x.isdeleted)
      .equalTo(false)
      ..where((x) => x.id)
      .equalTo(id as int)
      ..values.number=finance.number??ofinance!.number
      ..values.nameOperation=finance.nameOperation??ofinance!.nameOperation
      ..values.description=finance.description??ofinance!.description
      ..values.kategory=finance.kategory??ofinance!.kategory
      ..values.dateOperation=finance.dateOperation??ofinance!.dateOperation
      ..values.summ=finance.summ??ofinance!.summ;

      await qUpdateFinance.updateOne();

      final findFinance=await managedContext.fetchObjectWithID<Finances>(id);
      findFinance!.backing.removeProperty("isdeleted");

      await managedContext.transaction((transaction) async {
        final qCreateHistory = Query<History>(transaction)
          ..values.dateOperation = DateTime.now().toString()
          ..values.description = "Обновлена строка с номером операции ${findFinance.number} и названием ${findFinance.nameOperation}"
          ..values.numid=id;

        await qCreateHistory.insert();});
      return AppResponse.ok(
        message: 'Успешное обновление данных', body: findFinance!.backing.contents
      );
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка обновления данных');
    }
  }

   @Operation.post()
  Future<Response> CreateFinance
  (@Bind.body() Finances finance,
  ) async {
    try {
      late final int id;
      await managedContext.transaction((transaction) async {
        final qCreateFinance = Query<Finances>(transaction)
          ..values.number = finance.number
          ..values.nameOperation = finance.nameOperation
          ..values.description=finance.description
          ..values.kategory=finance.kategory
          ..values.dateOperation=finance.dateOperation
          ..values.summ=finance.summ;

        final createdFinance = await qCreateFinance.insert();
        id = createdFinance.id!;
    });
        await managedContext.transaction((transaction) async {
        final qCreateHistory = Query<History>(transaction)
          ..values.dateOperation = DateTime.now().toString()
          ..values.description = "Добавлена строка с номером операции ${finance.number} и названием ${finance.nameOperation}"
          ..values.numid=id;
        await qCreateHistory.insert();
      });

      final financeData = await managedContext.fetchObjectWithID<Finances>(id);
      financeData!.backing.removeProperty("isdeleted");
      return AppResponse.ok(
         message: 'Успешное добавление данных', body: financeData!.backing.contents
      );
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка добавления данных');
    }
  }


  @Operation.delete('idfinances')
  Future<Response> deleteFinances(
    @Bind.path('idfinances') int id,
  ) async {
    late final deletedFinance;
    try {
      await managedContext.transaction((transaction) async {
        final qDeleteFinance = Query<Finances>(transaction)
          ..where((x) => x.id)
          .equalTo(id);
          deletedFinance = await transaction.fetchObjectWithID<Finances>(id);
          await qDeleteFinance.delete();
          deletedFinance!.backing.removeProperty("isdeleted");
      });
        

      await managedContext.transaction((transaction) async {
        final qCreateHistory = Query<History>(transaction)
          ..values.dateOperation = DateTime.now().toString()
          ..values.description = "Удалена строка с номером операции ${deletedFinance.number} и названием ${deletedFinance.nameOperation}"
          ..values.numid=id;
        await qCreateHistory.insert();});
      return AppResponse.ok(
        message: 'Успешное удаление данных', body: deletedFinance.backing.contents
      );
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка получения данных');
    }
  }

   @Operation.get()
  Future<Response> SearchFinances(
    @Bind.query('Search') String search,
  ) async {
    try{
    late final Finance;
      final qFinancesSearch = Query<Finances>(managedContext)
          ..where((x) => x.isdeleted)
          .equalTo(false)
          ..where((x) => x.number)
          .contains(search);

      final finances=await qFinancesSearch.fetch();
      for (int i=0;i<finances.length;i++)
      {
        finances[i].backing.removeProperty("isdeleted");
      }
      return Response.ok(finances);
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка получения данных');
    }
  }

  @Operation.put()
  Future<Response> Paggination(
    @Bind.query('Page') int numpage,
  ) async {
    try{
      int itemsperpage=10;
      Map<int, List<Finances>> pages=new Map<int, List<Finances>>();
      final qFinancesSearch = Query<Finances>(managedContext)
      ..where((x) => x.isdeleted)
      .equalTo(false)
      ..pageBy((x) => x.id, 
      QuerySortOrder.ascending)
      ..fetchLimit=itemsperpage;

      final finances=await qFinancesSearch.fetch();
      var oldestFinances=finances.last.id;
      
      for (int i=0;i<finances.length/itemsperpage;i++)
      {
        late var qFinances=null;
        if (i!=0) {
          oldestFinances=qFinances.last.id;
        }
        else
        {
          for (int i=0;i<finances.length;i++)
          {
            finances[i].backing.removeProperty("isdeleted");
          }
          final entry=<int, List<Finances>>{0: finances};
          pages.addEntries(entry.entries);
        }

        qFinances = Query<Finances>(managedContext)
            ..where((x) => x.isdeleted)
            .equalTo(false)
            ..pageBy((x) => x.id, 
            QuerySortOrder.ascending, boundingValue: oldestFinances)
            ..fetchLimit=10;
        final qfinances=await qFinances.fetch();
        final entry=<int, List<Finances>>{i+1: qfinances};
        pages.addEntries(entry.entries);
    }
      final result=pages[numpage-1];
      return Response.ok(result);
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка получения данных');
    }
  }
}