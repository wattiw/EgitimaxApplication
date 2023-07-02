import 'package:egitimaxapplication/model/common/getDataSet.dart';
import 'package:egitimaxapplication/model/question/setQuestionObjects.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:egitimaxapplication/utils/service/webApi/apiBasicAuthorization.dart';
import 'package:egitimaxapplication/utils/service/webApi/apiBearerAuthorization.dart';
import 'package:flutter/material.dart';

class QuestionRepository {
  ApiBasicAuthorization apiBasic = ApiBasicAuthorization();
  ApiBearerAuthorization apiBearer = ApiBearerAuthorization();

  // private constructor
  QuestionRepository._privateConstructor();

  // singleton instance
  static final QuestionRepository _instance =
      QuestionRepository._privateConstructor();

  // factory constructor to return the singleton instance
  factory QuestionRepository() {
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

extension QuestionRepositoryExtension on QuestionRepository {

  Future<Map<String, dynamic>> lastActionId(
      List<String> columns,BigInt user_id,
      {int? getNoSqlData }) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query = "SELECT $columnJoinedString FROM ( SELECT id,user_id FROM tbl_que_question_main order by updated_on DESC LIMIT 1 ) RTX";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(query: query, parameters: parameters,getNoSqlData: getNoSqlData);
  }


  Future<Map<String, dynamic>> getTotalLikes(
      List<String> columns,BigInt question_id,
      {int? getNoSqlData }) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query = "SELECT $columnJoinedString FROM ( SELECT quest_id,count(quest_id) as like_count FROM tbl_que_question_like root  where like_type=1 group by quest_id ) RTX";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (question_id != null) {
      parameters.add(SqlParameter('@quest_id', question_id));
    }
    return getDataSet(query: query, parameters: parameters,getNoSqlData: getNoSqlData);
  }

  Future<Map<String, dynamic>> questionSetIsLikeOrNot(
      List<String> columns,BigInt question_id,int like_type,BigInt user_id,
      {int? getNoSqlData }) async {
    String queryPart = 'proc_que_question_like';

    List<String> queryParts = queryPart.split('\n');
    String joinedQuery = queryParts.join(' ');

    List<SqlParameter> parameters = List.empty(growable: true);

    parameters.add(SqlParameter('@p_user_id', user_id));
    parameters.add(SqlParameter('@p_quest_id', question_id));
    parameters.add(SqlParameter('@p_like_type', like_type));

    return getDataSet(query: joinedQuery, parameters: parameters, isProcedure: true);
  }

  Future<Map<String, dynamic>> questionSetMyFavorite(
      List<String> columns,BigInt question_id,int isMyFavorite,BigInt user_id,
      {int? getNoSqlData }) async {
    String queryPart = 'proc_fav_question';

    List<String> queryParts = queryPart.split('\n');
    String joinedQuery = queryParts.join(' ');

    List<SqlParameter> parameters = List.empty(growable: true);

    parameters.add(SqlParameter('@p_user_id', user_id));
    parameters.add(SqlParameter('@p_question_id', question_id));
    parameters.add(SqlParameter('@p_isMyFavorite', isMyFavorite));

    return getDataSet(query: joinedQuery, parameters: parameters, isProcedure: true);
  }

  Future<Map<String, dynamic>> getAchievementsFromSubDomainId(
      List<String> columns,
      {int? subdom_id,
      int? country_id,int? getNoSqlData }) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
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

  Future<Map<String, dynamic>> getQuestionDataTableData(
    List<String> columns, {
    BigInt? id,
    String? question_text,
    int? academic_year,
    String? acad_year,
    int? difficulty_lev,
    String? dif_level,
    int? subdom_id,
    String? subdom_name,
    int? grade_id,
    String? grade_name,
    int? learn_id,
    String? learn_name,
    int? domain_id,
    String? domain_name,
    int? branch_id,
    String? branch_name,
    DateTime? created_on,
    int? favCount,
        int? favGroupId,
    int? is_public,
    BigInt? user_id,
        BigInt? user_id_for_isMyFavorite,
    int? isMyFavorite
    ,int? getNoSqlData
  }) async {
    bool addLearnIdFilter = learn_id != null;
    bool addLearnNameFilter = learn_name != null;
    bool addQuestionTextFilter = question_text != null;
    bool addMyFavoriteGroupFilter = favGroupId != null;

    String myFavoriteGroupCondition =
    addMyFavoriteGroupFilter ? " AND fav_group_ids like '%$favGroupId%'" : "";

    String learnIdCondition =
        addLearnIdFilter ? " AND learn_data like '%$learn_id%'" : "";
    String learnNameCondition =
        addLearnNameFilter ? " AND learn_data like '%$learn_name%'" : "";

    String learn_data = "where 1=1 $myFavoriteGroupCondition  $learnIdCondition $learnNameCondition ${addQuestionTextFilter ? " AND question_text like '%$question_text%'" : ""}";

    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query = '''
                  SELECT $columnJoinedString FROM (
                           SELECT 
                  id,
                  academic_year, 
                  acad_year,  
                  difficulty_lev, 
                  dif_level, 
                  learn_id, 
                  learn_name, 
                  question_text,
                  branch_id,
                  branch_name,
                  created_on,
                  favCount,
                    likeCount,
                  is_public,
                  user_id,
                  isMyFavorite,
                  fav_group_ids,
                  grade_id,
                  grade_name,
                   REPLACE(SUBSTRING_INDEX(learn_data, '|', -1), ';', '>>')  as achievementTree,
                  learn_data
                  FROM
                  (
                  SELECT
                  l2.*,
                  branch.branch_name
                  FROM
                  (
                  SELECT
                  l1.*
                  FROM
                  (SELECT 
                  root.academic_year,
                  acye.acad_year,
                  root.id,
                  root.difficulty_lev,
                  dile.dif_level,
                  root.grade_id,
                  grade.grade_name,
                  root.question_text,
                  root.subdom_id,
                  sudo.name as learn_name,
                  sudo.id as learn_id,
				          sudo.branch_id,
                  root.created_on,
                  qufa.favCount,
                       quli.likeCount,
                  root.is_public,
                  root.user_id,
                  isqufa.isMyFavorite,
                   concatenated_group_ids.fav_group_ids,
                   `egitimax`.`getLearnInfoById`(subdom_id) AS learn_data
                  FROM tbl_que_question_main root 
                  left join tbl_util_academic_year acye on root.academic_year=acye.id 
                  left join tbl_util_difficulty dile on root.difficulty_lev=dile.id 
                  left join tbl_learn_main sudo on root.subdom_id=sudo.id 
                  left join (SELECT question_id, IFNULL(COUNT(question_id),0) AS favCount FROM tbl_fav_question GROUP BY question_id) qufa on root.id=qufa.question_id 
                  left join (SELECT quest_id, IFNULL(COUNT(quest_id),0) AS likeCount FROM tbl_que_question_like GROUP BY quest_id) quli on root.id=quli.quest_id 
                  left join (SELECT question_id, IFNULL(COUNT(question_id),0) AS isMyFavorite FROM tbl_fav_question  WHERE user_id = ${user_id_for_isMyFavorite ?? '0'} GROUP BY question_id) isqufa on root.id=isqufa.question_id                   
                  left join tbl_class_grade  grade on root.grade_id=grade.id
                  left join (SELECT  tbl_fav_group_quest_map.fav_quest_id, GROUP_CONCAT(tbl_fav_group_quest_map.group_id) AS fav_group_ids  FROM tbl_fav_group_quest_map GROUP BY tbl_fav_group_quest_map.fav_quest_id) concatenated_group_ids  on concatenated_group_ids.fav_quest_id=root.id
                  ) l1
                  ) l2
                  left join tbl_learn_branch branch on l2.branch_id=branch.id
                  ) l3  ) RTX  ${learn_data}  
                  ''';

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (acad_year != null) {
      parameters.add(SqlParameter('@acad_year', acad_year));
    }
    if (difficulty_lev != null) {
      parameters.add(SqlParameter('@difficulty_lev', difficulty_lev));
    }
    if (dif_level != null) {
      parameters.add(SqlParameter('@dif_level', dif_level));
    }
    if (subdom_id != null) {
      parameters.add(SqlParameter('@subdom_id', subdom_id));
    }
    if (subdom_name != null) {
      parameters.add(SqlParameter('@subdom_name', subdom_name));
    }
    if (domain_id != null) {
      parameters.add(SqlParameter('@domain_id', domain_id));
    }
    if (domain_name != null) {
      parameters.add(SqlParameter('@domain_name', domain_name));
    }
    if (grade_id != null) {
      parameters.add(SqlParameter('@grade_id', grade_id));
    }
    if (grade_name != null) {
      parameters.add(SqlParameter('@grade_name', grade_name));
    }
    if (branch_id != null) {
      parameters.add(SqlParameter('@branch_id', branch_id));
    }
    if (branch_name != null) {
      parameters.add(SqlParameter('@branch_name', branch_name));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (favCount != null) {
      parameters.add(SqlParameter('@favCount', favCount));
    }

    if (is_public != null) {
      parameters.add(SqlParameter('@is_public', is_public));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (isMyFavorite != null) {
      parameters.add(SqlParameter('@isMyFavorite', isMyFavorite));
    }
    return getDataSet(query: query, parameters: parameters,getNoSqlData: getNoSqlData);
  }
}
