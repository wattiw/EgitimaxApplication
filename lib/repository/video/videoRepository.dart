import 'dart:typed_data';
import 'package:egitimaxapplication/model/common/getDataSet.dart';
import 'package:egitimaxapplication/model/video/setVideoObjects.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:egitimaxapplication/utils/service/webApi/apiBasicAuthorization.dart';
import 'package:egitimaxapplication/utils/service/webApi/apiBearerAuthorization.dart';
import 'package:flutter/material.dart';

class VideoRepository {
  ApiBasicAuthorization apiBasic = ApiBasicAuthorization();
  ApiBearerAuthorization apiBearer = ApiBearerAuthorization();

  // private constructor
  VideoRepository._privateConstructor();

  // singleton instance
  static final VideoRepository _instance =
      VideoRepository._privateConstructor();

  // factory constructor to return the singleton instance
  factory VideoRepository() {
    return _instance;
  }

  Future<Map<String, dynamic>> getDataSet(
      {required String query, List<SqlParameter>? parameters,bool? isProcedure,int? getNoSqlData}) async {
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

      if(isProcedure==true)
      {

      }
      else{
        query = "select * from ($query) r $conditionsQuery";
      }


      addedParams = List.empty(growable: true);
      var data = GetDataSet(query, newaddedParams, isProcedure==true ? 4 : 1,getNoSqlData ?? 1).toMap();
      Map<String, dynamic> result =
          await apiBasic.post("Video/GetObject", data);

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
      {required SetVideoObjects setObject}) async {
    if (setObject != null) {
      var data = setObject.toMap();
      Map<String, dynamic> result =
      await apiBasic.post("Video/SetObject", data);

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

extension VideoRepositoryExtension on VideoRepository {

  Future<String?> uploadVideo(Uint8List? fileContent,{String? fileName}) async {
    var result = await apiBasic.uploadVideo(fileContent,fileName:fileName);
    return result;
  }

  Future<Uint8List?> downloadVideo({BigInt? videoId,String? videoObjectId}) async {
    if(videoId!=null)
      {
        return await apiBasic.downloadVideo(videoId.toString());
      }
    else
      {
        return await apiBasic.downloadVideo(videoObjectId ?? '0');
      }
  }

  Future<bool?> deleteVideo({BigInt? videoId,String? videoObjectId}) async {
    if(videoId!=null)
    {
      return await apiBasic.deleteVideo(videoId.toString());
    }
    else
    {
      return await apiBasic.deleteVideo(videoObjectId ?? '0');
    }
  }

  Future<Map<String, dynamic>> getAchievementsFromSubDomainId(List<String> columns,
      {int? subdom_id, int? country_id,int? getNoSqlData }) async {
    var columnJoinedString=columns.toSet().toList().join(',') ?? '*';
    String query = "SELECT $columnJoinedString FROM ( SELECT "
        " tbl_learn_achivement.*,"
        " tbl_learn_subdom_ach_map.subdom_id "
        " FROM tbl_learn_achivement "
        " LEFT JOIN tbl_learn_subdom_ach_map ON tbl_learn_achivement.id=tbl_learn_subdom_ach_map.achv_id  ) RTX";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (subdom_id != null) {
      parameters.add(SqlParameter('@subdom_id', subdom_id));
    }
    if (country_id != null) {
      parameters.add(SqlParameter('@country_id', country_id));
    }
    return getDataSet(query: query, parameters: parameters,getNoSqlData: getNoSqlData);
  }
}
