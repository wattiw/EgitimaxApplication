import 'dart:typed_data';

import 'package:egitimaxapplication/model/common/getDataSet.dart';
import 'package:egitimaxapplication/repository/lecture/lectureRepository.dart';
import 'package:egitimaxapplication/repository/mainLayout/mainLayoutRepository.dart';
import 'package:egitimaxapplication/repository/myHomePage/myHomePageRepository.dart';
import 'package:egitimaxapplication/repository/question/questionRepository.dart';
import 'package:egitimaxapplication/repository/quiz/quizRepository.dart';
import 'package:egitimaxapplication/repository/video/videoRepository.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:egitimaxapplication/utils/service/webApi/apiBasicAuthorization.dart';
import 'package:egitimaxapplication/utils/service/webApi/apiBearerAuthorization.dart';
import 'package:flutter/material.dart';

abstract class AppRepositoriesBase {
  Future<MainLayoutRepository> mainLayoutRepository();

  Future<MyHomePageRepository> myHomePageRepository();

  Future<QuestionRepository> questionRepository();

  Future<VideoRepository> videoRepository();

  Future<QuizRepository> quizRepository();

  Future<LectureRepository> lectureRepository();
}

class AppRepositories implements AppRepositoriesBase {
  ApiBasicAuthorization apiBasic = ApiBasicAuthorization();
  ApiBearerAuthorization apiBearer = ApiBearerAuthorization();

  @override
  Future<MainLayoutRepository> mainLayoutRepository() async {
    return MainLayoutRepository();
  }

  @override
  Future<MyHomePageRepository> myHomePageRepository() async {
    return MyHomePageRepository();
  }

  @override
  Future<QuestionRepository> questionRepository() async {
    return QuestionRepository();
  }

  @override
  Future<VideoRepository> videoRepository() async {
    return VideoRepository();
  }

  @override
  Future<QuizRepository> quizRepository() async {
    return QuizRepository();
  }

  @override
  Future<LectureRepository> lectureRepository() async {
    return LectureRepository();
  }

  Future<Map<String, dynamic>> getDataSet(String controllerAndAction,
      {required String query,
      List<SqlParameter>? parameters,
      bool? isProcedure,
      int? getNoSqlData}) async {
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
      var data = GetDataSet(query, newaddedParams, isProcedure == true ? 4 : 1,
              getNoSqlData ?? 1)
          .toMap();
      Map<String, dynamic> result =
          await apiBasic.post(controllerAndAction, data);

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

extension AppRepositoriesExtension on AppRepositories {
  Future<Map<String, dynamic>> questionOverView(
      String controllerAndAction, List<String> columns, BigInt question_id,
      {BigInt? user_id, int? getNoSqlData}) async {
    String query = '''
                SELECT
                L1.*,
                branch.branch_name
                FROM(
                SELECT 
                root.*,
                learn.branch_id,
                grade.grade_name,
                ay.acad_year,
                dl.dif_level,
                getLearnInfoById(subdom_id) as learn_data,
                achievements.achievements
                FROM egitimax.tbl_que_question_main root
                left join tbl_learn_main learn on learn.id=root.subdom_id
                left join tbl_class_grade grade on grade.id=root.grade_id
                left join tbl_util_academic_year ay on ay.id=root.academic_year
                left join tbl_util_difficulty dl on dl.id=root.difficulty_lev
                left join (SELECT quest_id,GROUP_CONCAT( concat(learn.item_code,' ',name) SEPARATOR '|') AS achievements
                FROM tbl_que_quest_achv_map qam
                LEFT JOIN tbl_learn_main learn ON learn.id = qam.achv_id
                GROUP BY qam.quest_id ) achievements on achievements.quest_id=root.id
                ) L1 
                left join tbl_learn_branch branch on branch.id=L1.branch_id''';

    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    query = "select $columnJoinedString from ( $query ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);

    if (question_id != null) {
      parameters.add(SqlParameter('@id', question_id));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }

    return getDataSet(controllerAndAction,
        query: query,
        parameters: parameters,
        isProcedure: false,
        getNoSqlData: getNoSqlData);
  }

  Future<Map<String, dynamic>> tblLearnMainHierarchies(
      String controllerAndAction, int id,
      {int? branch_id, int? grade_id, int? getNoSqlData}) async {
    String queryPart = 'proc_learn_main_hierarchies';

    List<String> queryParts = queryPart.split('\n');
    String joinedQuery = queryParts.join(' ');

    List<SqlParameter> parameters = List.empty(growable: true);

    id ??= 0;
    String? branchIdString = branch_id?.toString();
    String? gradeIdString = grade_id?.toString();
    parameters.add(SqlParameter('@param_id', id));
    parameters.add(SqlParameter('@param_branch_id', branchIdString));
    parameters.add(SqlParameter('@param_grade_id', gradeIdString));

    return getDataSet(controllerAndAction,
        query: joinedQuery, parameters: parameters, isProcedure: true);
  }

  Future<Map<String, dynamic>> tblLearnMain(
      String controllerAndAction, List<String> columns,
      {int? branch_id,
      int? country_id,
      String? description,
      int? grade_id,
      int? id,
      int? is_active,
      String? item_code,
      String? name,
      int? order_no,
      bool? parent_id_null_is_active,
      int? parent_id,
      String? type,
      int? getNoSqlData}) async {
    String? isParentNull =
        parent_id_null_is_active == true ? ' where parent_id is null ' : '';

    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString,CONCAT(item_code, ' ', name) as namewithitemcode from (select * from tbl_learn_main  $isParentNull ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (branch_id != null) {
      parameters.add(SqlParameter('@branch_id', branch_id));
    }
    if (country_id != null) {
      parameters.add(SqlParameter('@country_id', country_id));
    }
    if (description != null) {
      parameters.add(SqlParameter('@description', description));
    }
    if (grade_id != null) {
      parameters.add(SqlParameter('@grade_id', grade_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (item_code != null) {
      parameters.add(SqlParameter('@item_code', item_code));
    }
    if (name != null) {
      parameters.add(SqlParameter('@name', name));
    }
    if (order_no != null) {
      parameters.add(SqlParameter('@order_no', order_no));
    }
    if (parent_id != null) {
      parameters.add(SqlParameter('@parent_id', parent_id));
    }
    if (type != null) {
      parameters.add(SqlParameter('@type', type));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  //Below Generated Codes From Sql
  Future<Map<String, dynamic>> dartMethods(
      String controllerAndAction, List<String> columns,
      {String? code, String? table_name, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from dart_methods ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (code != null) {
      parameters.add(SqlParameter('@code', code));
    }
    if (table_name != null) {
      parameters.add(SqlParameter('@table_name', table_name));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblAnnounceClassMap(
      String controllerAndAction, List<String> columns,
      {BigInt? announce_id,
      BigInt? class_id,
      BigInt? id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_announce_class_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (announce_id != null) {
      parameters.add(SqlParameter('@announce_id', announce_id));
    }
    if (class_id != null) {
      parameters.add(SqlParameter('@class_id', class_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblAnnounceDoc(
      String controllerAndAction, List<String> columns,
      {BigInt? announce_id,
      String? description,
      String? doc_path,
      BigInt? id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_announce_doc ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (announce_id != null) {
      parameters.add(SqlParameter('@announce_id', announce_id));
    }
    if (description != null) {
      parameters.add(SqlParameter('@description', description));
    }
    if (doc_path != null) {
      parameters.add(SqlParameter('@doc_path', doc_path));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblAnnounceMain(
      String controllerAndAction, List<String> columns,
      {BigInt? created_by,
      DateTime? created_on,
      String? description,
      DateTime? end_date,
      BigInt? id,
      String? image_path,
      int? is_active,
      DateTime? start_date,
      String? title,
      BigInt? updated_by,
      DateTime? updated_on,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_announce_main ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (description != null) {
      parameters.add(SqlParameter('@description', description));
    }
    if (end_date != null) {
      parameters.add(SqlParameter('@end_date', end_date));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (image_path != null) {
      parameters.add(SqlParameter('@image_path', image_path));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (start_date != null) {
      parameters.add(SqlParameter('@start_date', start_date));
    }
    if (title != null) {
      parameters.add(SqlParameter('@title', title));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblAssignmentClassMap(
      String controllerAndAction, List<String> columns,
      {BigInt? asgn_id,
      BigInt? class_id,
      BigInt? id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_assignment_class_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (asgn_id != null) {
      parameters.add(SqlParameter('@asgn_id', asgn_id));
    }
    if (class_id != null) {
      parameters.add(SqlParameter('@class_id', class_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblAssignmentCompType(
      String controllerAndAction, List<String> columns,
      {String? comp_type, int? id, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_assignment_comp_type ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (comp_type != null) {
      parameters.add(SqlParameter('@comp_type', comp_type));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblAssignmentComponent(
      String controllerAndAction, List<String> columns,
      {BigInt? asgn_id,
      int? comp_type,
      BigInt? course_id,
      BigInt? curr_id,
      BigInt? homework_id,
      BigInt? id,
      int? order_no,
      BigInt? quiz_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_assignment_component ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (asgn_id != null) {
      parameters.add(SqlParameter('@asgn_id', asgn_id));
    }
    if (comp_type != null) {
      parameters.add(SqlParameter('@comp_type', comp_type));
    }
    if (course_id != null) {
      parameters.add(SqlParameter('@course_id', course_id));
    }
    if (curr_id != null) {
      parameters.add(SqlParameter('@curr_id', curr_id));
    }
    if (homework_id != null) {
      parameters.add(SqlParameter('@homework_id', homework_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (order_no != null) {
      parameters.add(SqlParameter('@order_no', order_no));
    }
    if (quiz_id != null) {
      parameters.add(SqlParameter('@quiz_id', quiz_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblAssignmentHomework(
      String controllerAndAction, List<String> columns,
      {BigInt? asgn_comp_id,
      String? hw_note,
      BigInt? id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_assignment_homework ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (asgn_comp_id != null) {
      parameters.add(SqlParameter('@asgn_comp_id', asgn_comp_id));
    }
    if (hw_note != null) {
      parameters.add(SqlParameter('@hw_note', hw_note));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblAssignmentHomeworkDoc(
      String controllerAndAction, List<String> columns,
      {BigInt? asgn_hw_id,
      String? doc_path,
      BigInt? id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select * from (select * from tbl_assignment_homework_doc ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (asgn_hw_id != null) {
      parameters.add(SqlParameter('@asgn_hw_id', asgn_hw_id));
    }
    if (doc_path != null) {
      parameters.add(SqlParameter('@doc_path', doc_path));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblAssignmentMain(
      String controllerAndAction, List<String> columns,
      {int? academic_year,
      DateTime? created_on,
      String? description,
      BigInt? id,
      int? is_active,
      DateTime? last_resp_date,
      String? title,
      DateTime? updated_on,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_assignment_main ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (description != null) {
      parameters.add(SqlParameter('@description', description));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (last_resp_date != null) {
      parameters.add(SqlParameter('@last_resp_date', last_resp_date));
    }
    if (title != null) {
      parameters.add(SqlParameter('@title', title));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblAssignmentStuMap(
      String controllerAndAction, List<String> columns,
      {BigInt? asgn_id, BigInt? id, BigInt? user_id, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_assignment_stu_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (asgn_id != null) {
      parameters.add(SqlParameter('@asgn_id', asgn_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblClassAdmin(
      String controllerAndAction, List<String> columns,
      {BigInt? class_id,
      BigInt? created_by,
      DateTime? created_on,
      BigInt? id,
      int? is_active,
      BigInt? updated_by,
      DateTime? updated_on,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_class_admin ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (class_id != null) {
      parameters.add(SqlParameter('@class_id', class_id));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblClassGrade(
      String controllerAndAction, List<String> columns,
      {int? country_id,
      String? grade_name,
      int? grade_num,
      int? id,
      int? is_active,
      int? school_type,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_class_grade ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (country_id != null) {
      parameters.add(SqlParameter('@country_id', country_id));
    }
    if (grade_name != null) {
      parameters.add(SqlParameter('@grade_name', grade_name));
    }
    if (grade_num != null) {
      parameters.add(SqlParameter('@grade_num', grade_num));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (school_type != null) {
      parameters.add(SqlParameter('@school_type', school_type));
    }
    if (country_id != null) {
      parameters.add(SqlParameter('@country_id', country_id));
    }
    if (grade_name != null) {
      parameters.add(SqlParameter('@grade_name', grade_name));
    }
    if (grade_num != null) {
      parameters.add(SqlParameter('@grade_num', grade_num));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (school_type != null) {
      parameters.add(SqlParameter('@school_type', school_type));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblClassMain(
      String controllerAndAction, List<String> columns,
      {int? academic_year,
      String? class_name,
      BigInt? created_by,
      DateTime? created_on,
      String? description,
      int? grade_id,
      BigInt? id,
      int? is_active,
      int? is_public,
      BigInt? updated_by,
      DateTime? updated_on,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_class_main ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (class_name != null) {
      parameters.add(SqlParameter('@class_name', class_name));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (description != null) {
      parameters.add(SqlParameter('@description', description));
    }
    if (grade_id != null) {
      parameters.add(SqlParameter('@grade_id', grade_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_public != null) {
      parameters.add(SqlParameter('@is_public', is_public));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (class_name != null) {
      parameters.add(SqlParameter('@class_name', class_name));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (grade_id != null) {
      parameters.add(SqlParameter('@grade_id', grade_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblClassStuMap(
      String controllerAndAction, List<String> columns,
      {int? academic_year,
      BigInt? accepted_by,
      DateTime? accepted_on,
      BigInt? class_id,
      BigInt? id,
      BigInt? invited_by,
      DateTime? invited_on,
      int? is_active,
      int? stu_status,
      BigInt? updated_by,
      DateTime? updated_on,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_class_stu_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (accepted_by != null) {
      parameters.add(SqlParameter('@accepted_by', accepted_by));
    }
    if (accepted_on != null) {
      parameters.add(SqlParameter('@accepted_on', accepted_on));
    }
    if (class_id != null) {
      parameters.add(SqlParameter('@class_id', class_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (invited_by != null) {
      parameters.add(SqlParameter('@invited_by', invited_by));
    }
    if (invited_on != null) {
      parameters.add(SqlParameter('@invited_on', invited_on));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (stu_status != null) {
      parameters.add(SqlParameter('@stu_status', stu_status));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (accepted_by != null) {
      parameters.add(SqlParameter('@accepted_by', accepted_by));
    }
    if (accepted_on != null) {
      parameters.add(SqlParameter('@accepted_on', accepted_on));
    }
    if (class_id != null) {
      parameters.add(SqlParameter('@class_id', class_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (invited_by != null) {
      parameters.add(SqlParameter('@invited_by', invited_by));
    }
    if (invited_on != null) {
      parameters.add(SqlParameter('@invited_on', invited_on));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (stu_status != null) {
      parameters.add(SqlParameter('@stu_status', stu_status));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblClassStuStatus(
      String controllerAndAction, List<String> columns,
      {int? id, int? is_active, String? status, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_class_stu_status ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (status != null) {
      parameters.add(SqlParameter('@status', status));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (status != null) {
      parameters.add(SqlParameter('@status', status));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblClassTeacMap(
      String controllerAndAction, List<String> columns,
      {int? academic_year,
      int? branch_id,
      BigInt? class_id,
      BigInt? created_by,
      DateTime? created_on,
      BigInt? id,
      int? is_active,
      int? stu_status,
      BigInt? updated_by,
      DateTime? updated_on,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_class_teac_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (branch_id != null) {
      parameters.add(SqlParameter('@branch_id', branch_id));
    }
    if (class_id != null) {
      parameters.add(SqlParameter('@class_id', class_id));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (stu_status != null) {
      parameters.add(SqlParameter('@stu_status', stu_status));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (branch_id != null) {
      parameters.add(SqlParameter('@branch_id', branch_id));
    }
    if (class_id != null) {
      parameters.add(SqlParameter('@class_id', class_id));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblCrsCourseDoc(
      String controllerAndAction, List<String> columns,
      {double? agg_rating,
      BigInt? course_id,
      BigInt? created_by,
      DateTime? created_on,
      String? description,
      String? document_path,
      BigInt? id,
      int? is_active,
      int? is_approved,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_crs_course_doc ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (agg_rating != null) {
      parameters.add(SqlParameter('@agg_rating', agg_rating));
    }
    if (course_id != null) {
      parameters.add(SqlParameter('@course_id', course_id));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (description != null) {
      parameters.add(SqlParameter('@description', description));
    }
    if (document_path != null) {
      parameters.add(SqlParameter('@document_path', document_path));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_approved != null) {
      parameters.add(SqlParameter('@is_approved', is_approved));
    }
    if (agg_rating != null) {
      parameters.add(SqlParameter('@agg_rating', agg_rating));
    }
    if (course_id != null) {
      parameters.add(SqlParameter('@course_id', course_id));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (description != null) {
      parameters.add(SqlParameter('@description', description));
    }
    if (document_path != null) {
      parameters.add(SqlParameter('@document_path', document_path));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_approved != null) {
      parameters.add(SqlParameter('@is_approved', is_approved));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblCrsCourseFlow(
      String controllerAndAction, List<String> columns,
      {BigInt? course_id,
      BigInt? doc_id,
      BigInt? id,
      int? is_active,
      int? order_no,
      BigInt? quest_id,
      BigInt? quiz_id,
      BigInt? video_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_crs_course_flow ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (course_id != null) {
      parameters.add(SqlParameter('@course_id', course_id));
    }
    if (doc_id != null) {
      parameters.add(SqlParameter('@doc_id', doc_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (order_no != null) {
      parameters.add(SqlParameter('@order_no', order_no));
    }
    if (quest_id != null) {
      parameters.add(SqlParameter('@quest_id', quest_id));
    }
    if (quiz_id != null) {
      parameters.add(SqlParameter('@quiz_id', quiz_id));
    }
    if (video_id != null) {
      parameters.add(SqlParameter('@video_id', video_id));
    }
    if (course_id != null) {
      parameters.add(SqlParameter('@course_id', course_id));
    }
    if (doc_id != null) {
      parameters.add(SqlParameter('@doc_id', doc_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (order_no != null) {
      parameters.add(SqlParameter('@order_no', order_no));
    }
    if (quiz_id != null) {
      parameters.add(SqlParameter('@quiz_id', quiz_id));
    }
    if (video_id != null) {
      parameters.add(SqlParameter('@video_id', video_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblCrsCourseFlowStu(
      String controllerAndAction, List<String> columns,
      {BigInt? crs_item_id,
      DateTime? finished_on,
      int? flow_status,
      BigInt? id,
      DateTime? started_on,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_crs_course_flow_stu ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (crs_item_id != null) {
      parameters.add(SqlParameter('@crs_item_id', crs_item_id));
    }
    if (finished_on != null) {
      parameters.add(SqlParameter('@finished_on', finished_on));
    }
    if (flow_status != null) {
      parameters.add(SqlParameter('@flow_status', flow_status));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (started_on != null) {
      parameters.add(SqlParameter('@started_on', started_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblCrsCourseMain( String controllerAndAction, List<String> columns,
      {int? academic_year,
      double? agg_rating,
      int? branch_id,
      int? country,
      BigInt? created_by,
      DateTime? created_on,
      String? description,
      String? goodbye_msg,
      int? grade_id,
      BigInt? id,
      int? is_active,
      int? is_approved,
      int? is_public,
      int? learn_id,
      String? title,
      BigInt? updated_by,
      DateTime? updated_on,
      BigInt? user_id,
      String? welcome_msg,int? getNoSqlData}) async {

    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_crs_course_main ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (agg_rating != null) {
      parameters.add(SqlParameter('@agg_rating', agg_rating));
    }
    if (branch_id != null) {
      parameters.add(SqlParameter('@branch_id', branch_id));
    }
    if (country != null) {
      parameters.add(SqlParameter('@country', country));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (description != null) {
      parameters.add(SqlParameter('@description', description));
    }
    if (goodbye_msg != null) {
      parameters.add(SqlParameter('@goodbye_msg', goodbye_msg));
    }
    if (grade_id != null) {
      parameters.add(SqlParameter('@grade_id', grade_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_approved != null) {
      parameters.add(SqlParameter('@is_approved', is_approved));
    }
    if (is_public != null) {
      parameters.add(SqlParameter('@is_public', is_public));
    }
    if (learn_id != null) {
      parameters.add(SqlParameter('@learn_id', learn_id));
    }
    if (title != null) {
      parameters.add(SqlParameter('@title', title));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (welcome_msg != null) {
      parameters.add(SqlParameter('@welcome_msg', welcome_msg));
    }

    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblCrsCourseRate(
      String controllerAndAction, List<String> columns,
      {BigInt? course_id,
      DateTime? created_on,
      BigInt? id,
      int? is_active,
      int? rating,
      String? user_comment,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_crs_course_rate ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (course_id != null) {
      parameters.add(SqlParameter('@course_id', course_id));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (rating != null) {
      parameters.add(SqlParameter('@rating', rating));
    }
    if (user_comment != null) {
      parameters.add(SqlParameter('@user_comment', user_comment));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (course_id != null) {
      parameters.add(SqlParameter('@course_id', course_id));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (rating != null) {
      parameters.add(SqlParameter('@rating', rating));
    }
    if (user_comment != null) {
      parameters.add(SqlParameter('@user_comment', user_comment));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblCrsCourseStudent(
      String controllerAndAction, List<String> columns,
      {BigInt? course_id,
      int? crs_status,
      DateTime? finished_on,
      BigInt? id,
      DateTime? started_on,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_crs_course_student ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (course_id != null) {
      parameters.add(SqlParameter('@course_id', course_id));
    }
    if (crs_status != null) {
      parameters.add(SqlParameter('@crs_status', crs_status));
    }
    if (finished_on != null) {
      parameters.add(SqlParameter('@finished_on', finished_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (started_on != null) {
      parameters.add(SqlParameter('@started_on', started_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblCrsCourseSubdomMap(
      String controllerAndAction, List<String> columns,
      {BigInt? course_id,
      BigInt? id,
      int? is_active,
      int? subdom_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select * from (select * from tbl_crs_course_subdom_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (course_id != null) {
      parameters.add(SqlParameter('@course_id', course_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (subdom_id != null) {
      parameters.add(SqlParameter('@subdom_id', subdom_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblCrsCurrCourseMap(
      String controllerAndAction, List<String> columns,
      {BigInt? course_id,
      BigInt? curr_id,
      BigInt? id,
      int? is_active,
      int? order_no,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_crs_curr_course_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (course_id != null) {
      parameters.add(SqlParameter('@course_id', course_id));
    }
    if (curr_id != null) {
      parameters.add(SqlParameter('@curr_id', curr_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (order_no != null) {
      parameters.add(SqlParameter('@order_no', order_no));
    }
    if (course_id != null) {
      parameters.add(SqlParameter('@course_id', course_id));
    }
    if (curr_id != null) {
      parameters.add(SqlParameter('@curr_id', curr_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (order_no != null) {
      parameters.add(SqlParameter('@order_no', order_no));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblCrsCurriculum(
      String controllerAndAction, List<String> columns,
      {int? academic_year,
      double? agg_rating,
      int? country,
      BigInt? created_by,
      DateTime? created_on,
      String? description,
      int? domain_id,
      String? goodbye_msg,
      int? grade_id,
      BigInt? id,
      int? is_active,
      int? is_public,
      String? title,
      BigInt? updated_by,
      DateTime? updated_on,
      BigInt? user_id,
      String? welcome_msg,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_crs_curriculum ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (agg_rating != null) {
      parameters.add(SqlParameter('@agg_rating', agg_rating));
    }
    if (country != null) {
      parameters.add(SqlParameter('@country', country));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (description != null) {
      parameters.add(SqlParameter('@description', description));
    }
    if (domain_id != null) {
      parameters.add(SqlParameter('@domain_id', domain_id));
    }
    if (goodbye_msg != null) {
      parameters.add(SqlParameter('@goodbye_msg', goodbye_msg));
    }
    if (grade_id != null) {
      parameters.add(SqlParameter('@grade_id', grade_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_public != null) {
      parameters.add(SqlParameter('@is_public', is_public));
    }
    if (title != null) {
      parameters.add(SqlParameter('@title', title));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (welcome_msg != null) {
      parameters.add(SqlParameter('@welcome_msg', welcome_msg));
    }
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (agg_rating != null) {
      parameters.add(SqlParameter('@agg_rating', agg_rating));
    }
    if (country != null) {
      parameters.add(SqlParameter('@country', country));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (description != null) {
      parameters.add(SqlParameter('@description', description));
    }
    if (goodbye_msg != null) {
      parameters.add(SqlParameter('@goodbye_msg', goodbye_msg));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_public != null) {
      parameters.add(SqlParameter('@is_public', is_public));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (welcome_msg != null) {
      parameters.add(SqlParameter('@welcome_msg', welcome_msg));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblCrsCurriculumRate(
      String controllerAndAction, List<String> columns,
      {DateTime? created_on,
      BigInt? curr_id,
      BigInt? id,
      int? is_active,
      int? rating,
      String? user_comment,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_crs_curriculum_rate ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (curr_id != null) {
      parameters.add(SqlParameter('@curr_id', curr_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (rating != null) {
      parameters.add(SqlParameter('@rating', rating));
    }
    if (user_comment != null) {
      parameters.add(SqlParameter('@user_comment', user_comment));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (curr_id != null) {
      parameters.add(SqlParameter('@curr_id', curr_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (rating != null) {
      parameters.add(SqlParameter('@rating', rating));
    }
    if (user_comment != null) {
      parameters.add(SqlParameter('@user_comment', user_comment));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblCrsStuAchGapQuest(
      String controllerAndAction, List<String> columns,
      {BigInt? ach_gap_id,
      DateTime? created_on,
      BigInt? id,
      BigInt? stu_quest_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select * from (select * from tbl_crs_stu_ach_gap_quest ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (ach_gap_id != null) {
      parameters.add(SqlParameter('@ach_gap_id', ach_gap_id));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (stu_quest_id != null) {
      parameters.add(SqlParameter('@stu_quest_id', stu_quest_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblCrsStuAchGapVideo(
      String controllerAndAction, List<String> columns,
      {BigInt? ach_gap_id,
      DateTime? created_on,
      BigInt? id,
      BigInt? stu_vid_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select * from (select * from tbl_crs_stu_ach_gap_video ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (ach_gap_id != null) {
      parameters.add(SqlParameter('@ach_gap_id', ach_gap_id));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (stu_vid_id != null) {
      parameters.add(SqlParameter('@stu_vid_id', stu_vid_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblCrsStudentQuest(
      String controllerAndAction, List<String> columns,
      {DateTime? created_on,
      BigInt? crs_quiz_id,
      BigInt? id,
      int? is_correct,
      int? look_again,
      BigInt? quest_id,
      BigInt? selected_opt,
      DateTime? updated_on,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_crs_student_quest ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (crs_quiz_id != null) {
      parameters.add(SqlParameter('@crs_quiz_id', crs_quiz_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_correct != null) {
      parameters.add(SqlParameter('@is_correct', is_correct));
    }
    if (look_again != null) {
      parameters.add(SqlParameter('@look_again', look_again));
    }
    if (quest_id != null) {
      parameters.add(SqlParameter('@quest_id', quest_id));
    }
    if (selected_opt != null) {
      parameters.add(SqlParameter('@selected_opt', selected_opt));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblCrsStudentQuestText(
      String controllerAndAction, List<String> columns,
      {BigInt? id,
      String? resp_text,
      BigInt? stu_quest_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select * from (select * from tbl_crs_student_quest_text ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (resp_text != null) {
      parameters.add(SqlParameter('@resp_text', resp_text));
    }
    if (stu_quest_id != null) {
      parameters.add(SqlParameter('@stu_quest_id', stu_quest_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblCrsStudentQuiz(
      String controllerAndAction, List<String> columns,
      {BigInt? crs_flow_id,
      DateTime? finished_on,
      BigInt? id,
      int? iteration_no,
      BigInt? quiz_id,
      int? quiz_status,
      DateTime? started_on,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_crs_student_quiz ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (crs_flow_id != null) {
      parameters.add(SqlParameter('@crs_flow_id', crs_flow_id));
    }
    if (finished_on != null) {
      parameters.add(SqlParameter('@finished_on', finished_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (iteration_no != null) {
      parameters.add(SqlParameter('@iteration_no', iteration_no));
    }
    if (quiz_id != null) {
      parameters.add(SqlParameter('@quiz_id', quiz_id));
    }
    if (quiz_status != null) {
      parameters.add(SqlParameter('@quiz_status', quiz_status));
    }
    if (started_on != null) {
      parameters.add(SqlParameter('@started_on', started_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblCrsStudentVideo(
      String controllerAndAction, List<String> columns,
      {BigInt? crs_flow_id,
      DateTime? finished_on,
      BigInt? id,
      DateTime? started_on,
      BigInt? user_id,
      BigInt? video_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_crs_student_video ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (crs_flow_id != null) {
      parameters.add(SqlParameter('@crs_flow_id', crs_flow_id));
    }
    if (finished_on != null) {
      parameters.add(SqlParameter('@finished_on', finished_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (started_on != null) {
      parameters.add(SqlParameter('@started_on', started_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (video_id != null) {
      parameters.add(SqlParameter('@video_id', video_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblFavCourse(
      String controllerAndAction, List<String> columns,
      {BigInt? course_id,
      DateTime? created_on,
      int? id,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_fav_course ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (course_id != null) {
      parameters.add(SqlParameter('@course_id', course_id));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblFavGroupCourse(
      String controllerAndAction, List<String> columns,
      {String? group_name, int? id, BigInt? user_id, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_fav_group_course ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (group_name != null) {
      parameters.add(SqlParameter('@group_name', group_name));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblFavGroupCourseMap(
      String controllerAndAction, List<String> columns,
      {int? fav_course_id, int? group_id, int? id, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_fav_group_course_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (fav_course_id != null) {
      parameters.add(SqlParameter('@fav_course_id', fav_course_id));
    }
    if (group_id != null) {
      parameters.add(SqlParameter('@group_id', group_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblFavGroupQuest(
      String controllerAndAction, List<String> columns,
      {String? group_name, int? id, BigInt? user_id, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_fav_group_quest ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (group_name != null) {
      parameters.add(SqlParameter('@group_name', group_name));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblFavGroupQuestMap(
      String controllerAndAction, List<String> columns,
      {int? fav_quest_id, int? group_id, int? id, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_fav_group_quest_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (fav_quest_id != null) {
      parameters.add(SqlParameter('@fav_quest_id', fav_quest_id));
    }
    if (group_id != null) {
      parameters.add(SqlParameter('@group_id', group_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblFavGroupQuiz(
      String controllerAndAction, List<String> columns,
      {String? group_name, int? id, BigInt? user_id, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_fav_group_quiz ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (group_name != null) {
      parameters.add(SqlParameter('@group_name', group_name));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblFavGroupQuizMap(
      String controllerAndAction, List<String> columns,
      {int? fav_quiz_id, int? group_id, int? id, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_fav_group_quiz_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (fav_quiz_id != null) {
      parameters.add(SqlParameter('@fav_quiz_id', fav_quiz_id));
    }
    if (group_id != null) {
      parameters.add(SqlParameter('@group_id', group_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblFavGroupVid(
      String controllerAndAction, List<String> columns,
      {String? group_name, int? id, BigInt? user_id, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_fav_group_vid ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (group_name != null) {
      parameters.add(SqlParameter('@group_name', group_name));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblFavGroupVidMap(
      String controllerAndAction, List<String> columns,
      {int? fav_video_id, int? group_id, int? id, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_fav_group_vid_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (fav_video_id != null) {
      parameters.add(SqlParameter('@fav_video_id', fav_video_id));
    }
    if (group_id != null) {
      parameters.add(SqlParameter('@group_id', group_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblFavQuestion(
      String controllerAndAction, List<String> columns,
      {DateTime? created_on,
      int? id,
      BigInt? question_id,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_fav_question ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (question_id != null) {
      parameters.add(SqlParameter('@question_id', question_id));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblFavQuiz(
      String controllerAndAction, List<String> columns,
      {DateTime? created_on,
      int? id,
      BigInt? quiz_id,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_fav_quiz ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (quiz_id != null) {
      parameters.add(SqlParameter('@quiz_id', quiz_id));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblFavVideo(
      String controllerAndAction, List<String> columns,
      {DateTime? created_on,
      int? id,
      BigInt? user_id,
      BigInt? video_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_fav_video ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (video_id != null) {
      parameters.add(SqlParameter('@video_id', video_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblLearnAchivement(
      String controllerAndAction, List<String> columns,
      {String? ach_code,
      String? achivement_desc,
      String? achivement_text,
      int? country_id,
      int? grade_id,
      int? id,
      int? is_active,
      int? lang_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_learn_achivement ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (ach_code != null) {
      parameters.add(SqlParameter('@ach_code', ach_code));
    }
    if (achivement_desc != null) {
      parameters.add(SqlParameter('@achivement_desc', achivement_desc));
    }
    if (achivement_text != null) {
      parameters.add(SqlParameter('@achivement_text', achivement_text));
    }
    if (country_id != null) {
      parameters.add(SqlParameter('@country_id', country_id));
    }
    if (grade_id != null) {
      parameters.add(SqlParameter('@grade_id', grade_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (ach_code != null) {
      parameters.add(SqlParameter('@ach_code', ach_code));
    }
    if (achivement_desc != null) {
      parameters.add(SqlParameter('@achivement_desc', achivement_desc));
    }
    if (achivement_text != null) {
      parameters.add(SqlParameter('@achivement_text', achivement_text));
    }
    if (country_id != null) {
      parameters.add(SqlParameter('@country_id', country_id));
    }
    if (grade_id != null) {
      parameters.add(SqlParameter('@grade_id', grade_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (lang_id != null) {
      parameters.add(SqlParameter('@lang_id', lang_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblLearnBranch(
      String controllerAndAction, List<String> columns,
      {String? branch_name,
      int? country_id,
      int? id,
      int? is_active,
      String? short_form,
      int? lang_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_learn_branch ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (branch_name != null) {
      parameters.add(SqlParameter('@branch_name', branch_name));
    }
    if (country_id != null) {
      parameters.add(SqlParameter('@country_id', country_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (short_form != null) {
      parameters.add(SqlParameter('@short_form', short_form));
    }
    if (branch_name != null) {
      parameters.add(SqlParameter('@branch_name', branch_name));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (lang_id != null) {
      parameters.add(SqlParameter('@lang_id', lang_id));
    }
    if (short_form != null) {
      parameters.add(SqlParameter('@short_form', short_form));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblLearnDomain(
      String controllerAndAction, List<String> columns,
      {int? branch_id,
      int? country_id,
      String? domain_name,
      int? id,
      int? is_active,
      int? order_no,
      BigInt? updated_by,
      DateTime? updated_on,
      int? country,
      int? lang_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_learn_domain ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (branch_id != null) {
      parameters.add(SqlParameter('@branch_id', branch_id));
    }
    if (country_id != null) {
      parameters.add(SqlParameter('@country_id', country_id));
    }
    if (domain_name != null) {
      parameters.add(SqlParameter('@domain_name', domain_name));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (order_no != null) {
      parameters.add(SqlParameter('@order_no', order_no));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (branch_id != null) {
      parameters.add(SqlParameter('@branch_id', branch_id));
    }
    if (country != null) {
      parameters.add(SqlParameter('@country', country));
    }
    if (domain_name != null) {
      parameters.add(SqlParameter('@domain_name', domain_name));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (lang_id != null) {
      parameters.add(SqlParameter('@lang_id', lang_id));
    }
    if (order_no != null) {
      parameters.add(SqlParameter('@order_no', order_no));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblLearnSubdomAchMap(
      String controllerAndAction, List<String> columns,
      {int? achv_id,
      int? id,
      int? is_active,
      int? subdom_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_learn_subdom_ach_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (achv_id != null) {
      parameters.add(SqlParameter('@achv_id', achv_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (subdom_id != null) {
      parameters.add(SqlParameter('@subdom_id', subdom_id));
    }
    if (achv_id != null) {
      parameters.add(SqlParameter('@achv_id', achv_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (subdom_id != null) {
      parameters.add(SqlParameter('@subdom_id', subdom_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblLearnSubdomGradeMap(
      String controllerAndAction, List<String> columns,
      {int? grade_id,
      int? id,
      int? is_active,
      int? subdom_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select * from (select * from tbl_learn_subdom_grade_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (grade_id != null) {
      parameters.add(SqlParameter('@grade_id', grade_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (subdom_id != null) {
      parameters.add(SqlParameter('@subdom_id', subdom_id));
    }
    if (grade_id != null) {
      parameters.add(SqlParameter('@grade_id', grade_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (subdom_id != null) {
      parameters.add(SqlParameter('@subdom_id', subdom_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblLearnSubdomain(
      String controllerAndAction, List<String> columns,
      {String? description,
      int? domain_id,
      int? id,
      int? is_active,
      int? order_no,
      String? subdom_name,
      int? lang_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_learn_subdomain ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (description != null) {
      parameters.add(SqlParameter('@description', description));
    }
    if (domain_id != null) {
      parameters.add(SqlParameter('@domain_id', domain_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (order_no != null) {
      parameters.add(SqlParameter('@order_no', order_no));
    }
    if (subdom_name != null) {
      parameters.add(SqlParameter('@subdom_name', subdom_name));
    }
    if (domain_id != null) {
      parameters.add(SqlParameter('@domain_id', domain_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (lang_id != null) {
      parameters.add(SqlParameter('@lang_id', lang_id));
    }
    if (order_no != null) {
      parameters.add(SqlParameter('@order_no', order_no));
    }
    if (subdom_name != null) {
      parameters.add(SqlParameter('@subdom_name', subdom_name));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblLocL1Country(
      String controllerAndAction, List<String> columns,
      {String? country_name_tr,
      String? countrycode,
      int? id,
      int? is_active,
      int? lang,
      String? country_name,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_loc_l1_country ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (country_name_tr != null) {
      parameters.add(SqlParameter('@country_name_tr', country_name_tr));
    }
    if (countrycode != null) {
      parameters.add(SqlParameter('@countrycode', countrycode));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (lang != null) {
      parameters.add(SqlParameter('@lang', lang));
    }
    if (country_name != null) {
      parameters.add(SqlParameter('@country_name', country_name));
    }
    if (countrycode != null) {
      parameters.add(SqlParameter('@countrycode', countrycode));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (lang != null) {
      parameters.add(SqlParameter('@lang', lang));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblLocL1CountryTrans(
      String controllerAndAction, List<String> columns,
      {String? country_name,
      int? county_id,
      int? id,
      int? is_active,
      int? is_default,
      int? lang_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_loc_l1_country_trans ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (country_name != null) {
      parameters.add(SqlParameter('@country_name', country_name));
    }
    if (county_id != null) {
      parameters.add(SqlParameter('@county_id', county_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_default != null) {
      parameters.add(SqlParameter('@is_default', is_default));
    }
    if (lang_id != null) {
      parameters.add(SqlParameter('@lang_id', lang_id));
    }
    if (country_name != null) {
      parameters.add(SqlParameter('@country_name', country_name));
    }
    if (county_id != null) {
      parameters.add(SqlParameter('@county_id', county_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_default != null) {
      parameters.add(SqlParameter('@is_default', is_default));
    }
    if (lang_id != null) {
      parameters.add(SqlParameter('@lang_id', lang_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblLocL2State(
      String controllerAndAction, List<String> columns,
      {int? county_id,
      int? id,
      int? is_active,
      String? state_name_tr,
      String? statecode,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_loc_l2_state ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (county_id != null) {
      parameters.add(SqlParameter('@county_id', county_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (state_name_tr != null) {
      parameters.add(SqlParameter('@state_name_tr', state_name_tr));
    }
    if (statecode != null) {
      parameters.add(SqlParameter('@statecode', statecode));
    }
    if (county_id != null) {
      parameters.add(SqlParameter('@county_id', county_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (state_name_tr != null) {
      parameters.add(SqlParameter('@state_name_tr', state_name_tr));
    }
    if (statecode != null) {
      parameters.add(SqlParameter('@statecode', statecode));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblLocL2StateTrans(
      String controllerAndAction, List<String> columns,
      {int? id,
      int? is_active,
      int? is_default,
      int? lang_id,
      int? state_id,
      String? state_name,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_loc_l2_state_trans ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_default != null) {
      parameters.add(SqlParameter('@is_default', is_default));
    }
    if (lang_id != null) {
      parameters.add(SqlParameter('@lang_id', lang_id));
    }
    if (state_id != null) {
      parameters.add(SqlParameter('@state_id', state_id));
    }
    if (state_name != null) {
      parameters.add(SqlParameter('@state_name', state_name));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_default != null) {
      parameters.add(SqlParameter('@is_default', is_default));
    }
    if (lang_id != null) {
      parameters.add(SqlParameter('@lang_id', lang_id));
    }
    if (state_id != null) {
      parameters.add(SqlParameter('@state_id', state_id));
    }
    if (state_name != null) {
      parameters.add(SqlParameter('@state_name', state_name));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblLocL3City(
      String controllerAndAction, List<String> columns,
      {String? city_code,
      String? city_name_tr,
      int? country_id,
      int? id,
      int? is_active,
      int? state_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_loc_l3_city ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (city_code != null) {
      parameters.add(SqlParameter('@city_code', city_code));
    }
    if (city_name_tr != null) {
      parameters.add(SqlParameter('@city_name_tr', city_name_tr));
    }
    if (country_id != null) {
      parameters.add(SqlParameter('@country_id', country_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (state_id != null) {
      parameters.add(SqlParameter('@state_id', state_id));
    }
    if (city_code != null) {
      parameters.add(SqlParameter('@city_code', city_code));
    }
    if (city_name_tr != null) {
      parameters.add(SqlParameter('@city_name_tr', city_name_tr));
    }
    if (country_id != null) {
      parameters.add(SqlParameter('@country_id', country_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (state_id != null) {
      parameters.add(SqlParameter('@state_id', state_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblLocL3CityTrans(
      String controllerAndAction, List<String> columns,
      {int? city_id,
      String? city_name,
      int? id,
      int? is_active,
      int? is_default,
      int? lang_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_loc_l3_city_trans ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (city_id != null) {
      parameters.add(SqlParameter('@city_id', city_id));
    }
    if (city_name != null) {
      parameters.add(SqlParameter('@city_name', city_name));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_default != null) {
      parameters.add(SqlParameter('@is_default', is_default));
    }
    if (lang_id != null) {
      parameters.add(SqlParameter('@lang_id', lang_id));
    }
    if (city_id != null) {
      parameters.add(SqlParameter('@city_id', city_id));
    }
    if (city_name != null) {
      parameters.add(SqlParameter('@city_name', city_name));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_default != null) {
      parameters.add(SqlParameter('@is_default', is_default));
    }
    if (lang_id != null) {
      parameters.add(SqlParameter('@lang_id', lang_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblPermPermissionMain(
      String controllerAndAction, List<String> columns,
      {int? id,
      int? is_active,
      String? perm_desc,
      String? perm_name,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_perm_permission_main ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (perm_desc != null) {
      parameters.add(SqlParameter('@perm_desc', perm_desc));
    }
    if (perm_name != null) {
      parameters.add(SqlParameter('@perm_name', perm_name));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (perm_desc != null) {
      parameters.add(SqlParameter('@perm_desc', perm_desc));
    }
    if (perm_name != null) {
      parameters.add(SqlParameter('@perm_name', perm_name));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblPermRolePermMap(
      String controllerAndAction, List<String> columns,
      {int? id,
      int? is_active,
      int? perm_id,
      int? role_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_perm_role_perm_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (perm_id != null) {
      parameters.add(SqlParameter('@perm_id', perm_id));
    }
    if (role_id != null) {
      parameters.add(SqlParameter('@role_id', role_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (perm_id != null) {
      parameters.add(SqlParameter('@perm_id', perm_id));
    }
    if (role_id != null) {
      parameters.add(SqlParameter('@role_id', role_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblPermUserRole(
      String controllerAndAction, List<String> columns,
      {int? id, int? is_active, String? role_name, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_perm_user_role ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (role_name != null) {
      parameters.add(SqlParameter('@role_name', role_name));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (role_name != null) {
      parameters.add(SqlParameter('@role_name', role_name));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblPermUserRoleMap(
      String controllerAndAction, List<String> columns,
      {int? id,
      int? is_active,
      int? role_id,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_perm_user_role_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (role_id != null) {
      parameters.add(SqlParameter('@role_id', role_id));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (role_id != null) {
      parameters.add(SqlParameter('@role_id', role_id));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblPostComment(
      String controllerAndAction, List<String> columns,
      {String? comment_text,
      DateTime? created_on,
      BigInt? id,
      int? is_active,
      String? media_path,
      BigInt? parent_comment_id,
      BigInt? post_id,
      DateTime? updated_on,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_post_comment ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (comment_text != null) {
      parameters.add(SqlParameter('@comment_text', comment_text));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (media_path != null) {
      parameters.add(SqlParameter('@media_path', media_path));
    }
    if (parent_comment_id != null) {
      parameters.add(SqlParameter('@parent_comment_id', parent_comment_id));
    }
    if (post_id != null) {
      parameters.add(SqlParameter('@post_id', post_id));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblPostLike(
      String controllerAndAction, List<String> columns,
      {DateTime? created_on,
      BigInt? id,
      int? like_type,
      BigInt? post_id,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_post_like ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (like_type != null) {
      parameters.add(SqlParameter('@like_type', like_type));
    }
    if (post_id != null) {
      parameters.add(SqlParameter('@post_id', post_id));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblPostMain(
      String controllerAndAction, List<String> columns,
      {DateTime? created_on,
      BigInt? id,
      String? media_path,
      String? post_content,
      String? post_title,
      DateTime? updated_on,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_post_main ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (media_path != null) {
      parameters.add(SqlParameter('@media_path', media_path));
    }
    if (post_content != null) {
      parameters.add(SqlParameter('@post_content', post_content));
    }
    if (post_title != null) {
      parameters.add(SqlParameter('@post_title', post_title));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblQueQuestAchvMap(
      String controllerAndAction, List<String> columns,
      {int? achv_id,
      BigInt? id,
      int? is_active,
      BigInt? quest_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_que_quest_achv_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (achv_id != null) {
      parameters.add(SqlParameter('@achv_id', achv_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (quest_id != null) {
      parameters.add(SqlParameter('@quest_id', quest_id));
    }
    if (achv_id != null) {
      parameters.add(SqlParameter('@achv_id', achv_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (quest_id != null) {
      parameters.add(SqlParameter('@quest_id', quest_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblQueQuestOption(
      String controllerAndAction, List<String> columns,
      {BigInt? id,
      int? is_active,
      int? is_correct,
      String? opt_identifier,
      String? opt_text,
      BigInt? quest_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_que_quest_option ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_correct != null) {
      parameters.add(SqlParameter('@is_correct', is_correct));
    }
    if (opt_identifier != null) {
      parameters.add(SqlParameter('@opt_identifier', opt_identifier));
    }
    if (opt_text != null) {
      parameters.add(SqlParameter('@opt_text', opt_text));
    }
    if (quest_id != null) {
      parameters.add(SqlParameter('@quest_id', quest_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_correct != null) {
      parameters.add(SqlParameter('@is_correct', is_correct));
    }
    if (opt_identifier != null) {
      parameters.add(SqlParameter('@opt_identifier', opt_identifier));
    }
    if (opt_text != null) {
      parameters.add(SqlParameter('@opt_text', opt_text));
    }
    if (quest_id != null) {
      parameters.add(SqlParameter('@quest_id', quest_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblQueQuestType(
      String controllerAndAction, List<String> columns,
      {int? id, int? is_active, String? quest_type, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_que_quest_type ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (quest_type != null) {
      parameters.add(SqlParameter('@quest_type', quest_type));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (quest_type != null) {
      parameters.add(SqlParameter('@quest_type', quest_type));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblQueQuestionLike(
      String controllerAndAction, List<String> columns,
      {DateTime? created_on,
      BigInt? id,
      int? is_active,
      int? like_type,
      BigInt? quest_id,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_que_question_like ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (like_type != null) {
      parameters.add(SqlParameter('@like_type', like_type));
    }
    if (quest_id != null) {
      parameters.add(SqlParameter('@quest_id', quest_id));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblQueQuestionMain(
      String controllerAndAction, List<String> columns,
      {int? academic_year,
      int? country,
      BigInt? created_by,
      DateTime? created_on,
      int? difficulty_lev,
      int? grade_id,
      BigInt? id,
      int? is_active,
      int? is_approved,
      int? is_public,
      String? question_image,
      String? question_text,
      int? question_type,
      String? resolution,
      int? subdom_id,
      BigInt? updated_by,
      DateTime? updated_on,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_que_question_main ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (country != null) {
      parameters.add(SqlParameter('@country', country));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (difficulty_lev != null) {
      parameters.add(SqlParameter('@difficulty_lev', difficulty_lev));
    }
    if (grade_id != null) {
      parameters.add(SqlParameter('@grade_id', grade_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_approved != null) {
      parameters.add(SqlParameter('@is_approved', is_approved));
    }
    if (is_public != null) {
      parameters.add(SqlParameter('@is_public', is_public));
    }
    if (question_image != null) {
      parameters.add(SqlParameter('@question_image', question_image));
    }
    if (question_text != null) {
      parameters.add(SqlParameter('@question_text', question_text));
    }
    if (question_type != null) {
      parameters.add(SqlParameter('@question_type', question_type));
    }
    if (resolution != null) {
      parameters.add(SqlParameter('@resolution', resolution));
    }
    if (subdom_id != null) {
      parameters.add(SqlParameter('@subdom_id', subdom_id));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (country != null) {
      parameters.add(SqlParameter('@country', country));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (difficulty_lev != null) {
      parameters.add(SqlParameter('@difficulty_lev', difficulty_lev));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_approved != null) {
      parameters.add(SqlParameter('@is_approved', is_approved));
    }
    if (is_public != null) {
      parameters.add(SqlParameter('@is_public', is_public));
    }
    if (question_image != null) {
      parameters.add(SqlParameter('@question_image', question_image));
    }
    if (question_text != null) {
      parameters.add(SqlParameter('@question_text', question_text));
    }
    if (question_type != null) {
      parameters.add(SqlParameter('@question_type', question_type));
    }
    if (resolution != null) {
      parameters.add(SqlParameter('@resolution', resolution));
    }
    if (subdom_id != null) {
      parameters.add(SqlParameter('@subdom_id', subdom_id));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblQuizMain(
      String controllerAndAction, List<String> columns,
      {int? academic_year,
      double? agg_rating,
      int? country,
      BigInt? created_by,
      DateTime? created_on,
      int? duration,
      String? footer_text,
      int? grade_id,
      String? header_text,
      BigInt? id,
      int? is_active,
      int? is_public,
      String? title,
      BigInt? updated_by,
      DateTime? updated_on,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_quiz_main ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (agg_rating != null) {
      parameters.add(SqlParameter('@agg_rating', agg_rating));
    }
    if (country != null) {
      parameters.add(SqlParameter('@country', country));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (duration != null) {
      parameters.add(SqlParameter('@duration', duration));
    }
    if (footer_text != null) {
      parameters.add(SqlParameter('@footer_text', footer_text));
    }
    if (grade_id != null) {
      parameters.add(SqlParameter('@grade_id', grade_id));
    }
    if (header_text != null) {
      parameters.add(SqlParameter('@header_text', header_text));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_public != null) {
      parameters.add(SqlParameter('@is_public', is_public));
    }
    if (title != null) {
      parameters.add(SqlParameter('@title', title));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (agg_rating != null) {
      parameters.add(SqlParameter('@agg_rating', agg_rating));
    }
    if (country != null) {
      parameters.add(SqlParameter('@country', country));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (footer_text != null) {
      parameters.add(SqlParameter('@footer_text', footer_text));
    }
    if (header_text != null) {
      parameters.add(SqlParameter('@header_text', header_text));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_public != null) {
      parameters.add(SqlParameter('@is_public', is_public));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblQuizRate(
      String controllerAndAction, List<String> columns,
      {DateTime? created_on,
      int? id,
      int? is_active,
      BigInt? quiz_id,
      int? rating,
      String? user_comment,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_quiz_rate ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (quiz_id != null) {
      parameters.add(SqlParameter('@quiz_id', quiz_id));
    }
    if (rating != null) {
      parameters.add(SqlParameter('@rating', rating));
    }
    if (user_comment != null) {
      parameters.add(SqlParameter('@user_comment', user_comment));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (quiz_id != null) {
      parameters.add(SqlParameter('@quiz_id', quiz_id));
    }
    if (rating != null) {
      parameters.add(SqlParameter('@rating', rating));
    }
    if (user_comment != null) {
      parameters.add(SqlParameter('@user_comment', user_comment));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblQuizSectQuestMap(
      String controllerAndAction, List<String> columns,
      {BigInt? id,
      int? is_active,
      int? order_no,
      BigInt? question_id,
      BigInt? section_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_quiz_sect_quest_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (order_no != null) {
      parameters.add(SqlParameter('@order_no', order_no));
    }
    if (question_id != null) {
      parameters.add(SqlParameter('@question_id', question_id));
    }
    if (section_id != null) {
      parameters.add(SqlParameter('@section_id', section_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (order_no != null) {
      parameters.add(SqlParameter('@order_no', order_no));
    }
    if (question_id != null) {
      parameters.add(SqlParameter('@question_id', question_id));
    }
    if (section_id != null) {
      parameters.add(SqlParameter('@section_id', section_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblQuizSection(
      String controllerAndAction, List<String> columns,
      {int? branch_id,
      BigInt? id,
      int? is_active,
      int? order_no,
      BigInt? quiz_id,
      String? section_desc,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_quiz_section ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (branch_id != null) {
      parameters.add(SqlParameter('@branch_id', branch_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (order_no != null) {
      parameters.add(SqlParameter('@order_no', order_no));
    }
    if (quiz_id != null) {
      parameters.add(SqlParameter('@quiz_id', quiz_id));
    }
    if (section_desc != null) {
      parameters.add(SqlParameter('@section_desc', section_desc));
    }
    if (branch_id != null) {
      parameters.add(SqlParameter('@branch_id', branch_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (order_no != null) {
      parameters.add(SqlParameter('@order_no', order_no));
    }
    if (quiz_id != null) {
      parameters.add(SqlParameter('@quiz_id', quiz_id));
    }
    if (section_desc != null) {
      parameters.add(SqlParameter('@section_desc', section_desc));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblSchAdmin(
      String controllerAndAction, List<String> columns,
      {BigInt? created_by,
      DateTime? created_on,
      BigInt? id,
      int? is_active,
      BigInt? school_id,
      BigInt? updated_by,
      DateTime? updated_on,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_sch_admin ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (school_id != null) {
      parameters.add(SqlParameter('@school_id', school_id));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblSchClassMap(
      String controllerAndAction, List<String> columns,
      {BigInt? class_id,
      BigInt? created_by,
      DateTime? created_on,
      int? id,
      int? is_active,
      BigInt? school_id,
      BigInt? updated_by,
      DateTime? updated_on,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_sch_class_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (class_id != null) {
      parameters.add(SqlParameter('@class_id', class_id));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (school_id != null) {
      parameters.add(SqlParameter('@school_id', school_id));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (class_id != null) {
      parameters.add(SqlParameter('@class_id', class_id));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (school_id != null) {
      parameters.add(SqlParameter('@school_id', school_id));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblSchSchoolMain(
      String controllerAndAction, List<String> columns,
      {String? address,
      int? city,
      int? country,
      BigInt? created_by,
      DateTime? created_on,
      String? email,
      String? fax,
      int? id,
      int? is_active,
      String? name,
      int? school_type,
      int? state,
      String? telephone,
      BigInt? updated_by,
      DateTime? updated_on,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_sch_school_main ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (address != null) {
      parameters.add(SqlParameter('@address', address));
    }
    if (city != null) {
      parameters.add(SqlParameter('@city', city));
    }
    if (country != null) {
      parameters.add(SqlParameter('@country', country));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (email != null) {
      parameters.add(SqlParameter('@email', email));
    }
    if (fax != null) {
      parameters.add(SqlParameter('@fax', fax));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (name != null) {
      parameters.add(SqlParameter('@name', name));
    }
    if (school_type != null) {
      parameters.add(SqlParameter('@school_type', school_type));
    }
    if (state != null) {
      parameters.add(SqlParameter('@state', state));
    }
    if (telephone != null) {
      parameters.add(SqlParameter('@telephone', telephone));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (address != null) {
      parameters.add(SqlParameter('@address', address));
    }
    if (city != null) {
      parameters.add(SqlParameter('@city', city));
    }
    if (country != null) {
      parameters.add(SqlParameter('@country', country));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (email != null) {
      parameters.add(SqlParameter('@email', email));
    }
    if (fax != null) {
      parameters.add(SqlParameter('@fax', fax));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (name != null) {
      parameters.add(SqlParameter('@name', name));
    }
    if (school_type != null) {
      parameters.add(SqlParameter('@school_type', school_type));
    }
    if (state != null) {
      parameters.add(SqlParameter('@state', state));
    }
    if (telephone != null) {
      parameters.add(SqlParameter('@telephone', telephone));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblSchSchoolType(
      String controllerAndAction, List<String> columns,
      {int? country_id,
      int? id,
      int? is_active,
      String? type_name,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_sch_school_type ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (country_id != null) {
      parameters.add(SqlParameter('@country_id', country_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (type_name != null) {
      parameters.add(SqlParameter('@type_name', type_name));
    }
    if (country_id != null) {
      parameters.add(SqlParameter('@country_id', country_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (type_name != null) {
      parameters.add(SqlParameter('@type_name', type_name));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblSchSubschool(
      String controllerAndAction, List<String> columns,
      {BigInt? id,
      int? is_active,
      BigInt? main_id,
      BigInt? sub_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_sch_subschool ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (main_id != null) {
      parameters.add(SqlParameter('@main_id', main_id));
    }
    if (sub_id != null) {
      parameters.add(SqlParameter('@sub_id', sub_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (main_id != null) {
      parameters.add(SqlParameter('@main_id', main_id));
    }
    if (sub_id != null) {
      parameters.add(SqlParameter('@sub_id', sub_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblSchTeacMap(
      String controllerAndAction, List<String> columns,
      {int? academic_year,
      BigInt? created_by,
      DateTime? created_on,
      BigInt? id,
      int? is_active,
      BigInt? school_id,
      BigInt? updated_by,
      DateTime? updated_on,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_sch_teac_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (school_id != null) {
      parameters.add(SqlParameter('@school_id', school_id));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (school_id != null) {
      parameters.add(SqlParameter('@school_id', school_id));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblTheaBranMap(
      String controllerAndAction, List<String> columns,
      {int? branch_id,
      BigInt? created_by,
      DateTime? created_on,
      int? id,
      int? is_active,
      BigInt? updated_by,
      DateTime? updated_on,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_thea_bran_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (branch_id != null) {
      parameters.add(SqlParameter('@branch_id', branch_id));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (branch_id != null) {
      parameters.add(SqlParameter('@branch_id', branch_id));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblUserActivity(
      String controllerAndAction, List<String> columns,
      {DateTime? access_timestamp,
      String? access_url,
      BigInt? id,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_user_activity ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (access_timestamp != null) {
      parameters.add(SqlParameter('@access_timestamp', access_timestamp));
    }
    if (access_url != null) {
      parameters.add(SqlParameter('@access_url', access_url));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (access_timestamp != null) {
      parameters.add(SqlParameter('@access_timestamp', access_timestamp));
    }
    if (access_url != null) {
      parameters.add(SqlParameter('@access_url', access_url));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblUserContractGdpr(
      String controllerAndAction, List<String> columns,
      {DateTime? contract_app_date,
      String? contract_ver,
      DateTime? gdpr_app_date,
      String? gdpr_ver,
      BigInt? id,
      int? is_active,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_user_contract_gdpr ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (contract_app_date != null) {
      parameters.add(SqlParameter('@contract_app_date', contract_app_date));
    }
    if (contract_ver != null) {
      parameters.add(SqlParameter('@contract_ver', contract_ver));
    }
    if (gdpr_app_date != null) {
      parameters.add(SqlParameter('@gdpr_app_date', gdpr_app_date));
    }
    if (gdpr_ver != null) {
      parameters.add(SqlParameter('@gdpr_ver', gdpr_ver));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (contract_app_date != null) {
      parameters.add(SqlParameter('@contract_app_date', contract_app_date));
    }
    if (contract_ver != null) {
      parameters.add(SqlParameter('@contract_ver', contract_ver));
    }
    if (gdpr_app_date != null) {
      parameters.add(SqlParameter('@gdpr_app_date', gdpr_app_date));
    }
    if (gdpr_ver != null) {
      parameters.add(SqlParameter('@gdpr_ver', gdpr_ver));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblUserFollow(
      String controllerAndAction, List<String> columns,
      {DateTime? accepted_on,
      BigInt? follower,
      BigInt? following,
      int? id,
      DateTime? reqested_on,
      int? status,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_user_follow ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (accepted_on != null) {
      parameters.add(SqlParameter('@accepted_on', accepted_on));
    }
    if (follower != null) {
      parameters.add(SqlParameter('@follower', follower));
    }
    if (following != null) {
      parameters.add(SqlParameter('@following', following));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (reqested_on != null) {
      parameters.add(SqlParameter('@reqested_on', reqested_on));
    }
    if (status != null) {
      parameters.add(SqlParameter('@status', status));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblUserFollowStatus(
      String controllerAndAction, List<String> columns,
      {int? id, String? status_name, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_user_follow_status ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (status_name != null) {
      parameters.add(SqlParameter('@status_name', status_name));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblUserMain(
      String controllerAndAction, List<String> columns,
      {BigInt? approved_by,
      DateTime? approved_on,
      int? city_id,
      int? country_id,
      BigInt? created_by,
      DateTime? created_on,
      String? email,
      String? fbuserid,
      int? grade_id,
      BigInt? id,
      int? is_active,
      int? is_approved,
      int? is_public,
      String? mobile,
      String? name,
      String? profile_photo_path,
      int? sch_id,
      String? slogan_text,
      int? state_id,
      String? surname,
      String? tc_id,
      BigInt? updated_by,
      DateTime? updated_on,
      String? user_name,
      String? user_password,
      int? user_type,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_user_main ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (approved_by != null) {
      parameters.add(SqlParameter('@approved_by', approved_by));
    }
    if (approved_on != null) {
      parameters.add(SqlParameter('@approved_on', approved_on));
    }
    if (city_id != null) {
      parameters.add(SqlParameter('@city_id', city_id));
    }
    if (country_id != null) {
      parameters.add(SqlParameter('@country_id', country_id));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (email != null) {
      parameters.add(SqlParameter('@email', email));
    }
    if (fbuserid != null) {
      parameters.add(SqlParameter('@fbuserid', fbuserid));
    }
    if (grade_id != null) {
      parameters.add(SqlParameter('@grade_id', grade_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_approved != null) {
      parameters.add(SqlParameter('@is_approved', is_approved));
    }
    if (is_public != null) {
      parameters.add(SqlParameter('@is_public', is_public));
    }
    if (mobile != null) {
      parameters.add(SqlParameter('@mobile', mobile));
    }
    if (name != null) {
      parameters.add(SqlParameter('@name', name));
    }
    if (profile_photo_path != null) {
      parameters.add(SqlParameter('@profile_photo_path', profile_photo_path));
    }
    if (sch_id != null) {
      parameters.add(SqlParameter('@sch_id', sch_id));
    }
    if (slogan_text != null) {
      parameters.add(SqlParameter('@slogan_text', slogan_text));
    }
    if (state_id != null) {
      parameters.add(SqlParameter('@state_id', state_id));
    }
    if (surname != null) {
      parameters.add(SqlParameter('@surname', surname));
    }
    if (tc_id != null) {
      parameters.add(SqlParameter('@tc_id', tc_id));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_name != null) {
      parameters.add(SqlParameter('@user_name', user_name));
    }
    if (user_password != null) {
      parameters.add(SqlParameter('@user_password', user_password));
    }
    if (user_type != null) {
      parameters.add(SqlParameter('@user_type', user_type));
    }
    if (approved_by != null) {
      parameters.add(SqlParameter('@approved_by', approved_by));
    }
    if (approved_on != null) {
      parameters.add(SqlParameter('@approved_on', approved_on));
    }
    if (city_id != null) {
      parameters.add(SqlParameter('@city_id', city_id));
    }
    if (country_id != null) {
      parameters.add(SqlParameter('@country_id', country_id));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (email != null) {
      parameters.add(SqlParameter('@email', email));
    }
    if (fbuserid != null) {
      parameters.add(SqlParameter('@fbuserid', fbuserid));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_approved != null) {
      parameters.add(SqlParameter('@is_approved', is_approved));
    }
    if (is_public != null) {
      parameters.add(SqlParameter('@is_public', is_public));
    }
    if (mobile != null) {
      parameters.add(SqlParameter('@mobile', mobile));
    }
    if (name != null) {
      parameters.add(SqlParameter('@name', name));
    }
    if (profile_photo_path != null) {
      parameters.add(SqlParameter('@profile_photo_path', profile_photo_path));
    }
    if (sch_id != null) {
      parameters.add(SqlParameter('@sch_id', sch_id));
    }
    if (slogan_text != null) {
      parameters.add(SqlParameter('@slogan_text', slogan_text));
    }
    if (state_id != null) {
      parameters.add(SqlParameter('@state_id', state_id));
    }
    if (surname != null) {
      parameters.add(SqlParameter('@surname', surname));
    }
    if (tc_id != null) {
      parameters.add(SqlParameter('@tc_id', tc_id));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_name != null) {
      parameters.add(SqlParameter('@user_name', user_name));
    }
    if (user_password != null) {
      parameters.add(SqlParameter('@user_password', user_password));
    }
    if (user_type != null) {
      parameters.add(SqlParameter('@user_type', user_type));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblUserSubuser(
      String controllerAndAction, List<String> columns,
      {BigInt? id,
      BigInt? main_user_id,
      BigInt? sub_user_id,
      int? is_active,
      int? is_approved,
      BigInt? created_by,
      DateTime? created_on,
      BigInt? updated_by,
      DateTime? updated_on,
      BigInt? approved_by,
      DateTime? approved_on,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_user_subuser ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (main_user_id != null) {
      parameters.add(SqlParameter('@main_user_id', main_user_id));
    }
    if (sub_user_id != null) {
      parameters.add(SqlParameter('@sub_user_id', sub_user_id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_approved != null) {
      parameters.add(SqlParameter('@is_approved', is_approved));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (approved_by != null) {
      parameters.add(SqlParameter('@approved_by', approved_by));
    }
    if (approved_on != null) {
      parameters.add(SqlParameter('@approved_on', approved_on));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblUserType(
      String controllerAndAction, List<String> columns,
      {int? id, int? is_active, String? type_name, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_user_type ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (type_name != null) {
      parameters.add(SqlParameter('@type_name', type_name));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (type_name != null) {
      parameters.add(SqlParameter('@type_name', type_name));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblUsersLogin(
      String controllerAndAction, List<String> columns,
      {BigInt? id,
      int? is_succesfull,
      DateTime? logindatetime,
      String? loginip,
      String? loginport,
      DateTime? logoffdatetime,
      BigInt? user_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_users_login ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_succesfull != null) {
      parameters.add(SqlParameter('@is_succesfull', is_succesfull));
    }
    if (logindatetime != null) {
      parameters.add(SqlParameter('@logindatetime', logindatetime));
    }
    if (loginip != null) {
      parameters.add(SqlParameter('@loginip', loginip));
    }
    if (loginport != null) {
      parameters.add(SqlParameter('@loginport', loginport));
    }
    if (logoffdatetime != null) {
      parameters.add(SqlParameter('@logoffdatetime', logoffdatetime));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblUtilAcademicYear(
      String controllerAndAction, List<String> columns,
      {String? acad_year,
      int? id,
      int? is_active,
      bool? is_default,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_util_academic_year ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (acad_year != null) {
      parameters.add(SqlParameter('@acad_year', acad_year));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_default != null) {
      parameters.add(SqlParameter('@is_default', is_default));
    }
    if (acad_year != null) {
      parameters.add(SqlParameter('@acad_year', acad_year));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblUtilCurrency(
      String controllerAndAction, List<String> columns,
      {int? id, int? is_active, String? short_form, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_util_currency ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (short_form != null) {
      parameters.add(SqlParameter('@short_form', short_form));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (short_form != null) {
      parameters.add(SqlParameter('@short_form', short_form));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblUtilDifficulty(
      String controllerAndAction, List<String> columns,
      {String? dif_level, int? id, int? is_active, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_util_difficulty ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (dif_level != null) {
      parameters.add(SqlParameter('@dif_level', dif_level));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (dif_level != null) {
      parameters.add(SqlParameter('@dif_level', dif_level));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblUtilLanguage(
      String controllerAndAction, List<String> columns,
      {int? id,
      int? is_active,
      String? language,
      String? short_form,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_util_language ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (language != null) {
      parameters.add(SqlParameter('@language', language));
    }
    if (short_form != null) {
      parameters.add(SqlParameter('@short_form', short_form));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (language != null) {
      parameters.add(SqlParameter('@language', language));
    }
    if (short_form != null) {
      parameters.add(SqlParameter('@short_form', short_form));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblUtilLikeType(
      String controllerAndAction, List<String> columns,
      {int? id, int? is_active, String? like_type, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_util_like_type ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (like_type != null) {
      parameters.add(SqlParameter('@like_type', like_type));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (like_type != null) {
      parameters.add(SqlParameter('@like_type', like_type));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblVidVideoAchvMap(
      String controllerAndAction, List<String> columns,
      {int? achv_id,
      BigInt? id,
      int? is_active,
      BigInt? video_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_vid_video_achv_map ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (achv_id != null) {
      parameters.add(SqlParameter('@achv_id', achv_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (video_id != null) {
      parameters.add(SqlParameter('@video_id', video_id));
    }
    if (achv_id != null) {
      parameters.add(SqlParameter('@achv_id', achv_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (video_id != null) {
      parameters.add(SqlParameter('@video_id', video_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblVidVideoMain(
      String controllerAndAction, List<String> columns,
      {int? academic_year,
      double? agg_rating,
      int? country,
      BigInt? created_by,
      DateTime? created_on,
      String? description,
      int? branch_id,
      int? grade_id,
      BigInt? id,
      int? is_active,
      int? is_approved,
      int? is_public,
      int? subdom_id,
      String? title,
      BigInt? updated_by,
      DateTime? updated_on,
      BigInt? user_id,
      String? video_path,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_vid_video_main ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (agg_rating != null) {
      parameters.add(SqlParameter('@agg_rating', agg_rating));
    }
    if (branch_id != null) {
      parameters.add(SqlParameter('@branch_id', branch_id));
    }
    if (country != null) {
      parameters.add(SqlParameter('@country', country));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (description != null) {
      parameters.add(SqlParameter('@description', description));
    }
    if (grade_id != null) {
      parameters.add(SqlParameter('@grade_id', grade_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_approved != null) {
      parameters.add(SqlParameter('@is_approved', is_approved));
    }
    if (is_public != null) {
      parameters.add(SqlParameter('@is_public', is_public));
    }
    if (subdom_id != null) {
      parameters.add(SqlParameter('@subdom_id', subdom_id));
    }
    if (title != null) {
      parameters.add(SqlParameter('@title', title));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (video_path != null) {
      parameters.add(SqlParameter('@video_path', video_path));
    }
    if (academic_year != null) {
      parameters.add(SqlParameter('@academic_year', academic_year));
    }
    if (agg_rating != null) {
      parameters.add(SqlParameter('@agg_rating', agg_rating));
    }
    if (country != null) {
      parameters.add(SqlParameter('@country', country));
    }
    if (created_by != null) {
      parameters.add(SqlParameter('@created_by', created_by));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (description != null) {
      parameters.add(SqlParameter('@description', description));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (is_approved != null) {
      parameters.add(SqlParameter('@is_approved', is_approved));
    }
    if (is_public != null) {
      parameters.add(SqlParameter('@is_public', is_public));
    }
    if (subdom_id != null) {
      parameters.add(SqlParameter('@subdom_id', subdom_id));
    }
    if (title != null) {
      parameters.add(SqlParameter('@title', title));
    }
    if (updated_by != null) {
      parameters.add(SqlParameter('@updated_by', updated_by));
    }
    if (updated_on != null) {
      parameters.add(SqlParameter('@updated_on', updated_on));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (video_path != null) {
      parameters.add(SqlParameter('@video_path', video_path));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> tblVidVideoRate(
      String controllerAndAction, List<String> columns,
      {DateTime? created_on,
      BigInt? id,
      int? is_active,
      int? rating,
      String? user_comment,
      BigInt? user_id,
      BigInt? video_id,
      int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from tbl_vid_video_rate ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (rating != null) {
      parameters.add(SqlParameter('@rating', rating));
    }
    if (user_comment != null) {
      parameters.add(SqlParameter('@user_comment', user_comment));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (video_id != null) {
      parameters.add(SqlParameter('@video_id', video_id));
    }
    if (created_on != null) {
      parameters.add(SqlParameter('@created_on', created_on));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (is_active != null) {
      parameters.add(SqlParameter('@is_active', is_active));
    }
    if (rating != null) {
      parameters.add(SqlParameter('@rating', rating));
    }
    if (user_comment != null) {
      parameters.add(SqlParameter('@user_comment', user_comment));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    if (video_id != null) {
      parameters.add(SqlParameter('@video_id', video_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }

  Future<Map<String, dynamic>> viewCrsStuAchGap(
      String controllerAndAction, List<String> columns,
      {int? achv_id, int? id, int? user_id, int? getNoSqlData}) async {
    var columnJoinedString = columns.toSet().toList().join(',') ?? '*';
    String query =
        "select $columnJoinedString from (select * from view_crs_stu_ach_gap ) rt";

    List<SqlParameter> parameters = List.empty(growable: true);
    if (achv_id != null) {
      parameters.add(SqlParameter('@achv_id', achv_id));
    }
    if (id != null) {
      parameters.add(SqlParameter('@id', id));
    }
    if (user_id != null) {
      parameters.add(SqlParameter('@user_id', user_id));
    }
    return getDataSet(controllerAndAction,
        query: query, parameters: parameters);
  }
}
