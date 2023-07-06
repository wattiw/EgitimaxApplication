import 'package:egitimaxapplication/model/common/dataTableData.dart';
import 'package:egitimaxapplication/model/question/question.dart';
import 'package:flutter/material.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

class QuestionsPageModel {

  late BigInt userId;

  QuestionsPageModel({required this.userId});

  bool loadedInitialData=false;

  BuildContext? context;

  List<dynamic>? selectedKeys;

  Map<String, dynamic>? userRootDataSet;
  Map<int, String>? userRoot;

  Map<String, dynamic>? academicYearsRootDataSet;
  Map<int, String>? academicYearsRoot;
  int? academicYearId;

  Map<String, dynamic>? gradesRootDataSet;
  Map<int, String>? gradesRoot;
  int? gradeId;

  int? selectedLearn;

  Map<String, dynamic>? branchesRootDataSet;
  Map<int, String>? branchesRoot;
  int? branchId;

  int? countryId;

  Map<String, dynamic>? difficultiesRootDataSet;
  Map<int, String>? difficultiesRoot;
  int? difficultyId;

  TextEditingController filterQuestionTextController = TextEditingController();

  Map<String, dynamic>? dataSet;

  DataTable? dataTableRoot;
  DataTableData? dataTableDataRoot;

  bool? createDataTableColumnAlias;
  List<String> dataTableColumnAlias = List.empty(growable: true);
  List<String> dataTableColumnNames = List.empty(growable: true);
  String? dataTableKeyColumnName;
  List<String>? dataTableDisableColumnFilter = List.empty(growable: true);
  List<String>? dataTableHideColumn = List.empty(growable: true);
  List<Map<Map<String, String>, Widget>>?
  dataTableRows; // Map Is List<Map<Map<columnName, columnValueAsString>, Widget(Show Your Widget With Cell Value Bind)>>?
  List<ColumnDataType> columnDataTypes = List.empty(growable: true);
}