import 'package:egitimaxapplication/model/common/getDataSet.dart';
import 'package:egitimaxapplication/model/question/setQuestionObjects.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:egitimaxapplication/utils/service/webApi/apiBasicAuthorization.dart';
import 'package:egitimaxapplication/utils/service/webApi/apiBearerAuthorization.dart';
import 'package:flutter/material.dart';

class QuestionsRepository {
  ApiBasicAuthorization apiBasic = ApiBasicAuthorization();
  ApiBearerAuthorization apiBearer = ApiBearerAuthorization();

  // private constructor
  QuestionsRepository._privateConstructor();

  // singleton instance
  static final QuestionsRepository _instance =
  QuestionsRepository._privateConstructor();

  // factory constructor to return the singleton instance
  factory QuestionsRepository() {
    return _instance;
  }

  Future<Map<String, dynamic>> getDataSet(
      {required String query,
      List<SqlParameter>? parameters,
      bool? isProcedure,int? getNoSqlData}) async {
    if (query != null) {
      List<String?> addedParams = List.empty(growable: true);
      List<SqlParameter> newaddedParams = List.empty(growable: true);
      String conditionsQuery = "where 1=1 ";
      if (parameters != null && parameters.isNotEmpty) {
        for (SqlParameter parameter in parameters) {
          if (!addedParams.contains(parameter.name)) {
            conditionsQuery +=
                " and r.${parameter.name.replaceAll("@", "")} =${parameter.name}";

            addedParams.add(parameter.name);
            newaddedParams.add(parameter);
          }
        }
      } else {
        parameters = List.empty(growable: true);
      }

      if (isProcedure == true) {
      } else {
        query = "select * from ($query) r $conditionsQuery";
      }

      addedParams = List.empty(growable: true);
      var data = GetDataSet(query, newaddedParams, isProcedure == true ? 4 : 1,getNoSqlData ?? 1)
          .toMap();
      Map<String, dynamic> result =
          await apiBasic.post("Question/GetObject", data);

      var messages = result.selectDataTable('message');

      for (var message in List.from(messages)) {
        try {
          debugPrint(message['message']);
        } catch (e) {
          debugPrint(e.toString());
        }
      }

      return result;
    } else {
      return <String, dynamic>{};
    }
  }

  Future<Map<String, dynamic>> setDataSet(
      {required SetQuestionObjects setObject}) async {
    if (setObject != null) {
      var data = setObject.toMap();
      Map<String, dynamic> result =
          await apiBasic.post("Question/SetObject", data);

      var messages = result.selectDataTable('message');

      for (var message in List.from(messages)) {
        try {
          debugPrint(message['message']);
        } catch (e) {
          debugPrint(e.toString());
        }
      }

      return result;
    } else {
      return <String, dynamic>{};
    }
  }
}

extension QuestionsRepositoryExtension on QuestionsRepository {

}