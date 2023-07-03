import 'package:egitimaxapplication/model/common/dataTableData.dart';
import 'package:egitimaxapplication/model/quiz/quizPageModel.dart';
import 'package:egitimaxapplication/model/quiz/quizSection.dart';
import 'package:egitimaxapplication/model/quiz/quizSectionQuestionMap.dart';
import 'package:egitimaxapplication/screen/common/collapsibleItemBuilder.dart';
import 'package:egitimaxapplication/screen/common/commonDataTable.dart';
import 'package:egitimaxapplication/screen/common/commonDropdownButtonFormField.dart';
import 'package:egitimaxapplication/screen/common/commonTextFormField.dart';
import 'package:egitimaxapplication/screen/common/questionDataTable.dart';
import 'package:egitimaxapplication/screen/common/questionOverView.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/constant/router/heroTagConstant.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:egitimaxapplication/utils/helper/getDeviceType.dart';
import 'package:egitimaxapplication/utils/widget/layout/mainLayout.dart';
import 'package:flutter/material.dart';

class QuizSectionDataTable extends StatefulWidget {
  QuizPageModel quizPageModel;
  final TextStyle componentTextStyle;
  Function(List<Map<String, dynamic>>? rows, List<dynamic>? rowKeys)?
      onSelectedRowsChanged;
  final Function(List<QuizSection>? quizSections) onChanged;

  QuizSectionDataTable({
    required this.quizPageModel,
    required this.onChanged,
    required this.componentTextStyle,
  });

  @override
  _QuizSectionDataTableState createState() => _QuizSectionDataTableState();
}

class _QuizSectionDataTableState extends State<QuizSectionDataTable> {
  List<String>? disabledColumFilters = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
  }

  List<QuizSection> updateQuizSectionQuestionMapsByOrderNo(
      List<QuizSection> quizSections,
      int orderNo,
      List<QuizSectionQuestionMap> newQuestionMaps,
      List<Map<String, dynamic>>? sectionSelectedQuestionsData) {
    for (var section in quizSections) {
      if (section.orderNo == orderNo) {
        section.quizSectionQuestionMaps = newQuestionMaps;
        section.sectionSelectedQuestionsData = sectionSelectedQuestionsData;
        break;
      }
    }
    return quizSections;
  }

  List<BigInt> getSectionQuestionIds(QuizSection quizSections) {
    List<BigInt> result = List.empty(growable: true);
    if (quizSections != null &&
        quizSections.quizSectionQuestionMaps != null &&
        quizSections.quizSectionQuestionMaps!.isNotEmpty) {
      for (var map in quizSections.quizSectionQuestionMaps!) {
        if (map.questionId != null && map.questionId! > BigInt.parse('0')) {
          result.add(map.questionId!);
        }
      }
    } else {}

    return result;
  }

  @override
  Widget build(BuildContext context) {
    List<BigInt>? selectedQuestionIdList = List.empty(growable: true);

    final theme = Theme.of(context);
    widget.quizPageModel.quizMain!.quizSections!
        .sort((a, b) => (a.orderNo ?? 0).compareTo(b.orderNo ?? 0));

    double paddingDataTable = 10;
    int dataTableCount = 1;
    List<QuizSection>? result = List.empty(growable: true);
    result = widget.quizPageModel.quizMain!.quizSections!;

    List<Map<Map<String, String>, Widget>>? rowList =
        List.empty(growable: true);
    for (var section in widget.quizPageModel.quizMain!.quizSections!) {
      Map<Map<String, String>, Widget> cells = {};
      Map<String, String> key0 = {};
      key0['id'] = section.id.toString();
      cells[key0] = Text(
        section.id.toString(),
        softWrap: true,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 10),
      );
      Map<String, String> key1 = {};
      key1['orderNo'] = section.orderNo.toString();
      cells[key1] = Text(
        ((section.orderNo.toString() ?? '').length > 15)
            ? '${(section.orderNo.toString() ?? '').substring(0, 15)}...'
            : (section.orderNo.toString() ?? ''),
        softWrap: true,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 10),
      );
      Map<String, String> key2 = {};
      key2['sectionDesc'] = section.sectionDesc.toString();
      cells[key2] = Text(
        ((section.sectionDesc ?? '').length > 15)
            ? '${(section.sectionDesc ?? '').substring(0, 15)}...'
            : (section.sectionDesc ?? ''),
        softWrap: true,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 10),
      );
      Map<String, String> key3 = {};
      key3['branchId'] =
          widget.quizPageModel.branches[section?.branchId].toString();
      cells[key3] = Text(
        ((widget.quizPageModel.branches[section?.branchId].toString() ?? '')
                    .length >
                15)
            ? '${(widget.quizPageModel.branches[section?.branchId].toString() ?? '').substring(0, 15)}...'
            : (widget.quizPageModel.branches[section?.branchId].toString() ??
                ''),
        softWrap: true,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 10),
      );

      Map<String, String> key4 = {};
      key4['qIds'] = section != null && section.quizSectionQuestionMaps != null
          ? section.quizSectionQuestionMaps!.length.toString()
          : '0';
      cells[key4] = Text(
          section != null && section.quizSectionQuestionMaps != null
              ? section.quizSectionQuestionMaps!.length.toString()
              : '0');

      Map<String, String> key5 = {};
      key5['actions'] = 'actions';
      cells[key5] = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PopupMenuButton<String>(
              padding: const EdgeInsets.all(3.0),
              itemBuilder: (BuildContext context) => [
                     PopupMenuItem<String>(
                      padding: EdgeInsets.all(3.0),
                      value: 'add_question',
                      textStyle: TextStyle(fontSize: 10),
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 14),
                          SizedBox(width: 8),
                          Text(AppLocalization.instance.translate(
                              'lib.screen.quizPage.quizSectionDataTable',
                              'build',
                              'addQuestion'), style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                     PopupMenuItem<String>(
                      padding: EdgeInsets.all(3.0),
                      value: 'edit',
                      textStyle: TextStyle(fontSize: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 14,
                          ),
                          SizedBox(width: 8),
                          Text(AppLocalization.instance.translate(
                              'lib.screen.quizPage.quizSectionDataTable',
                              'build',
                              'edit'), style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    if (section.orderNo != 1)
                       PopupMenuItem<String>(
                        padding: EdgeInsets.all(3.0),
                        value: 'move_up',
                        textStyle: TextStyle(fontSize: 10),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_upward, size: 14),
                            SizedBox(width: 8),
                            Text(AppLocalization.instance.translate(
                                'lib.screen.quizPage.quizSectionDataTable',
                                'build',
                                'moveUp'), style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    if (widget.quizPageModel.quizMain!.quizSections?.length !=
                        section.orderNo)
                       PopupMenuItem<String>(
                        padding: EdgeInsets.all(3.0),
                        value: 'move_down',
                        textStyle: TextStyle(fontSize: 10),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_downward, size: 14),
                            SizedBox(width: 8),
                            Text(AppLocalization.instance.translate(
                                'lib.screen.quizPage.quizSectionDataTable',
                                'build',
                                'moveDown'), style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    if (section.orderNo != 1)
                       PopupMenuItem<String>(
                        padding: EdgeInsets.all(3.0),
                        value: 'delete',
                        textStyle: TextStyle(fontSize: 10),
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 14),
                            SizedBox(width: 8),
                            Text(
                              AppLocalization.instance.translate(
                                  'lib.screen.quizPage.quizSectionDataTable',
                                  'build',
                                  'delete'),
                              style: TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                  ],
              onSelected: (String? value) {
                if (value == 'edit') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return QuizSectionDataTableEditPopup(
                        branches: widget.quizPageModel.branches,
                        section: section,
                        componentTextStyle: widget.componentTextStyle,
                        onSavePressed: (newSection) {
                          if (newSection != null) {
                            if (newSection.orderNo != null &&
                                newSection.sectionDesc != null &&
                                newSection.branchId != null) {
                              widget.quizPageModel.quizMain!.quizSections
                                  ?.removeWhere((section) =>
                                      section.orderNo == newSection?.orderNo);
                              widget.quizPageModel.quizMain!.quizSections
                                  ?.add(newSection!);
                              widget.onChanged(
                                  widget.quizPageModel.quizMain!.quizSections);
                            }
                          }
                        },
                      );
                    },
                  );
                } else if (value == 'move_up') {
                  if (section.orderNo != 1) {
                    int currentOrder = section.orderNo ?? 0;

                    var currentSection = section;
                    var replacedSection = widget
                        .quizPageModel.quizMain!.quizSections
                        ?.firstWhere((sec) => sec.orderNo == currentOrder - 1);

                    currentSection.orderNo = (currentOrder - 1)!;
                    replacedSection?.orderNo = currentOrder;

                    widget.quizPageModel.quizMain!.quizSections
                        ?.removeWhere((sec) => sec.orderNo == currentOrder - 1);
                    widget.quizPageModel.quizMain!.quizSections
                        ?.removeWhere((sec) => sec.orderNo == currentOrder);

                    widget.quizPageModel.quizMain!.quizSections
                        ?.add(currentSection);
                    widget.quizPageModel.quizMain!.quizSections
                        ?.add(replacedSection!);

                    widget
                        .onChanged(widget.quizPageModel.quizMain!.quizSections);
                  }
                } else if (value == 'move_down') {
                  if (section.orderNo !=
                      widget.quizPageModel.quizMain!.quizSections?.length) {
                    int currentOrder = section.orderNo ?? 0;

                    var currentSection = section;
                    var replacedSection = widget
                        .quizPageModel.quizMain!.quizSections
                        ?.firstWhere((sec) => sec.orderNo == currentOrder + 1);

                    currentSection.orderNo = (currentOrder + 1)!;
                    replacedSection?.orderNo = currentOrder;

                    widget.quizPageModel.quizMain!.quizSections
                        ?.removeWhere((sec) => sec.orderNo == currentOrder + 1);
                    widget.quizPageModel.quizMain!.quizSections
                        ?.removeWhere((sec) => sec.orderNo == currentOrder);

                    widget.quizPageModel.quizMain!.quizSections
                        ?.add(currentSection);
                    widget.quizPageModel.quizMain!.quizSections
                        ?.add(replacedSection!);

                    widget
                        .onChanged(widget.quizPageModel.quizMain!.quizSections);
                  }
                } else if (value == 'delete') {
                  widget.quizPageModel.quizMain!.quizSections
                      ?.removeWhere((sec) => sec.orderNo == section.orderNo);

                  widget.quizPageModel.quizMain!.quizSections!.sort(
                      (a, b) => (a.orderNo ?? 0).compareTo(b.orderNo ?? 0));
                  int newOrder = 1;
                  for (var section
                      in widget.quizPageModel.quizMain!.quizSections!) {
                    section.orderNo = newOrder;
                    newOrder++;
                  }

                  widget.onChanged(widget.quizPageModel.quizMain!.quizSections);
                } else if (value == 'add_question') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MainLayout(
                          context: context,
                          loadedStateContainer: QuestionDataTable(
                            gradeId: widget.quizPageModel.quizMain!.gradeId,
                            branchId: widget
                                .quizPageModel.quizMain!.quizSections!
                                .firstWhere((element) =>
                            element.orderNo == section.orderNo).branchId,

                        userId: widget.quizPageModel.userId,
                            componentTextStyle: widget.componentTextStyle,
                            selectedQuestionIds: getSectionQuestionIds(widget
                                    .quizPageModel.quizMain!.quizSections!
                                    .firstWhere((element) =>
                                        element.orderNo == section.orderNo)) ??
                                List.empty(growable: true),
                            onSelectedRowsChanged:
                                (selectedRows, selectedKeys) {
                              if (widget.onSelectedRowsChanged != null) {
                                widget.onSelectedRowsChanged!(
                                    selectedRows, selectedKeys);
                              }
                              selectedQuestionIdList = selectedKeys;

                              // Değişiklikleri Anında Yansıt
                              section.quizSectionQuestionMaps =
                                  List.empty(growable: true);

                              if (selectedQuestionIdList != null &&
                                  selectedQuestionIdList!.isNotEmpty) {
                                int questionOrderNo = 1;
                                for (BigInt questionId
                                    in selectedQuestionIdList!) {
                                  var qsqm = QuizSectionQuestionMap();

                                  qsqm.orderNo = questionOrderNo;
                                  qsqm.questionId = questionId;
                                  qsqm.sectionId = section.id;
                                  qsqm.id = BigInt.parse('0');
                                  qsqm.isActive = 0;

                                  section.quizSectionQuestionMaps!.add(qsqm);
                                  questionOrderNo++;
                                }

                                widget.quizPageModel.quizMain!.quizSections =
                                    updateQuizSectionQuestionMapsByOrderNo(
                                        widget.quizPageModel.quizMain!
                                            .quizSections!,
                                        section.orderNo!,
                                        section.quizSectionQuestionMaps!,
                                        selectedRows);
                              } else {
                                widget.quizPageModel.quizMain!.quizSections =
                                    updateQuizSectionQuestionMapsByOrderNo(
                                        widget.quizPageModel.quizMain!
                                            .quizSections!,
                                        section.orderNo!,
                                        section.quizSectionQuestionMaps!,
                                        selectedRows);
                              }

                              setState(() {});
                              widget.onChanged(
                                  widget.quizPageModel.quizMain!.quizSections);
                            },
                            onSelectedQuestionIdsChanged:
                                (List<BigInt>? selectedQuestionIds) {
                              int c00 = 0;
                            },
                          )),
                      settings: const RouteSettings(
                          name: HeroTagConstant
                              .questionSelector), // use the route name as the Hero tag
                    ),
                  );
                }
              },
              child:  Row(
                children: [
                  Text(
                    AppLocalization.instance.translate(
                        'lib.screen.quizPage.quizSectionDataTable',
                        'build',
                        'selectAction'),
                    style: TextStyle(color: Colors.blue, fontSize: 10),
                  ),
                  SizedBox(width: 5.0),
                  Icon(Icons.arrow_drop_down),
                ],
              )),
        ],
      );

      rowList.add(cells);
    }

    disabledColumFilters=const [
      'id',
      'orderNo',
      'sectionDesc',
      'branchId',
      'qIds',
      'actions'
    ];

    List<dynamic>? selectedKeyList = [];

    var collapsibleItems = createSectionQuestionsWidget(theme);

    var collapsibleItemBuilder = CollapsibleItemBuilder(
      items: collapsibleItems,
      onStateChanged: (value) {},
      padding: 0,
    );

    return Wrap(
      alignment: WrapAlignment.start,
      children: [
        CommonDataTable(
          dataTableKeyColumnName: 'orderNo',
          dataTableSelectedKeys: selectedKeyList,
          toolBarButtons: [
            IconButton(
              onPressed: () {
                var existDefaultSection =
                    widget.quizPageModel.quizMain!.quizSections?.first ??
                        QuizSection();

                QuizSection newSection = QuizSection();
                newSection.id = existDefaultSection.id;
                newSection.branchId = existDefaultSection.branchId;
                newSection.quizId = existDefaultSection.quizId;
                newSection.isActive = existDefaultSection.isActive;
                newSection?.orderNo =
                    (widget.quizPageModel.quizMain!.quizSections!.length + 1)!;
                String? secDescription =
                    widget.quizPageModel.branches[newSection?.branchId] ?? '';
                secDescription = '$secDescription ${  AppLocalization.instance.translate(
                    'lib.screen.quizPage.quizSectionDataTable',
                    'build',
                    'questions')}';
                newSection?.sectionDesc = secDescription;

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return QuizSectionDataTableEditPopup(
                      branches: widget.quizPageModel.branches,
                      section: newSection,
                      componentTextStyle: widget.componentTextStyle,
                      onSavePressed: (newSec) {
                        if (newSec != null) {
                          if (newSec.orderNo != null &&
                              newSec.sectionDesc != null &&
                              newSec.branchId != null) {
                            widget.quizPageModel.quizMain!.quizSections
                                ?.add(newSec!);
                            widget.onChanged(
                                widget.quizPageModel.quizMain!.quizSections);
                          }
                        }
                      },
                    );
                  },
                );
              },
              icon:  Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 3),
                  // Adjust the spacing between the icon and text
                  Text(AppLocalization.instance.translate(
                      'lib.screen.quizPage.quizSectionDataTable',
                      'build',
                      'addSection')),
                ],
              ),
              tooltip: AppLocalization.instance.translate(
                  'lib.screen.quizPage.quizSectionDataTable',
                  'build',
                  'addSection'),
            ),
          ],
          dataTableColumnAlias:  [
            AppLocalization.instance.translate('lib.screen.quizPage.quizSectionDataTable','build','id'),
            AppLocalization.instance.translate('lib.screen.quizPage.quizSectionDataTable','build','order'),
            AppLocalization.instance.translate('lib.screen.quizPage.quizSectionDataTable','build','sectionName'),
            AppLocalization.instance.translate('lib.screen.quizPage.quizSectionDataTable','build','branch'),
            AppLocalization.instance.translate('lib.screen.quizPage.quizSectionDataTable','build','questionQuantity'),
            AppLocalization.instance.translate('lib.screen.quizPage.quizSectionDataTable','build','actions'),
          ],
          dataTableColumnNames: const [
            'id',
            'orderNo',
            'sectionDesc',
            'branchId',
            'qIds',
            'actions'
          ],
          dataTableDisableColumnFilter: disabledColumFilters,
          onChangedDisabledFilters: (disabledFilters) {
            disabledColumFilters = disabledFilters;
            setState(() {});
          },
          dataTableHideColumn: const ['id'],
          dataTableRows: rowList,
          columnDataTypes: [
            ColumnDataType('id', int),
            ColumnDataType('orderNo', int),
            ColumnDataType('sectionDesc', String),
            ColumnDataType('branchId', int),
            ColumnDataType('qIds', int),
            ColumnDataType('actions', String),
          ],
          showCheckboxColumn: false,
          onFilterValueChanged:
              (filterText, index, filterControllers, filteredRows) {},
          onSelectedRowsChanged: (selectedRows, selectedKeys) {
            var cc = selectedRows;
            selectedKeyList = selectedKeys;
          },
        ),
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: collapsibleItemBuilder,
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  List<CollapsibleItemData> createSectionQuestionsWidget(ThemeData theme) {
    List<CollapsibleItemData> items = List.empty(growable: true);

    // Daha önce selilen questionların datası tekrar db ye gitmedik
    List<String> columns = [];
    List<List<String>> rowsAsString = [];
    List<List<dynamic>> rowsAsIsType = [];
    List<Map<Map<String, String>, Widget>>? rowsAsWidget = [];
    List<int?> addedSections = List.empty(growable: true);
    for (var section in widget.quizPageModel.quizMain!.quizSections!) {
      List<Map<Map<String, String>, Widget>>? modifiedSectionRows =
          List.empty(growable: true);

      int orderNo = 0;
      String id = '0';
      String acad_year = '';
      String question_text = '';
      String dif_level = '';
      String branch_name = '';
      String achievementTree = '';
      String created_on = '';
      String favCount = '';

      if (section.sectionSelectedQuestionsData != null &&
          section.sectionSelectedQuestionsData!.isNotEmpty) {
        int sectionQuestionOrderNo = 1;
        for (var row in section.sectionSelectedQuestionsData!) {
          var sectionDataTable = row.getDataTableData();
          columns = sectionDataTable.columns; // bu herzaman aynı hepsi için
          rowsAsString.addAll(sectionDataTable.rowsAsString);
          rowsAsIsType.addAll(sectionDataTable.rowsAsIsType);
          rowsAsWidget.addAll(sectionDataTable.rowsAsWidget);

          //Yukarıda her satırı daha önce hazırladığımız yardımcı datatable creatordan faydalandık

          String questionIdAsString = row['id'] ?? '0';
          if (questionIdAsString == '' || questionIdAsString == null) {
            questionIdAsString = '0';
          }

          BigInt questionId = BigInt.parse(questionIdAsString ?? '0');
          int orderNo = 0;
          Map<String, String> keyOrderNo = {};
          Map<Map<String, String>, Widget> cells = {};

          bool addOrderNo = true;
          for (var cell in row.entries) {
            if (cell.key == "TableMenu" || cell.key == "actions") {
            } else {
              if (cell.key == 'id') {
                id = cell.value;
              } else if (cell.key == 'acad_year') {
                acad_year = cell.value;
              } else if (cell.key == 'question_text') {
                question_text = cell.value;
              } else if (cell.key == 'dif_level') {
                dif_level = cell.value;
              } else if (cell.key == 'branch_name') {
                branch_name = cell.value;
              } else if (cell.key == 'achievementTree') {
                achievementTree = cell.value;
              } else if (cell.key == 'created_on') {
                created_on = cell.value;
              } else if (cell.key == 'favCount') {
                favCount = cell.value;
              }

              if (addOrderNo && cell.key == 'id') {
                // question selections lardan section -questiom map içindeki sırasını aldık
                var map = section.quizSectionQuestionMaps!
                    .where((element) =>
                        element.questionId == BigInt.parse(cell.value))
                    .toList();
                if (map.isNotEmpty) {
                  questionId = map.first.questionId ?? BigInt.parse('0');
                  orderNo = map.first.orderNo ?? 0;
                  keyOrderNo['orderNo'] = map.first.orderNo.toString();
                  cells[keyOrderNo] = Text(
                    map.first.orderNo.toString(),
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10),
                  );
                }

                addOrderNo = false;
              }

              try {
                if (cell.key == "question_text") {
                  Map<String, String> key = {};
                  key[cell.key] = cell.value;
                  cells[key] = MouseRegion(
                    onHover: (event) {
                      // Handle hover event
                      // Set a flag or update state to show the widget element
                    },
                    onExit: (event) {
                      // Handle exit event
                      // Reset the flag or update state to hide the widget element
                    },
                    child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return QuestionOverView(
                              questionId: questionId,
                              userId: widget.quizPageModel.userId,
                            );
                          },
                        );
                      },
                      style: ButtonStyle(
                        textStyle: MaterialStateProperty.all<TextStyle>(
                          TextStyle(
                              fontSize:
                                  theme.dataTableTheme.dataTextStyle?.fontSize),
                        ),
                      ),
                      child: Tooltip(
                        message: cell.value ?? "",
                        child: Wrap(
                          children: [
                            Text(
                              cell.value != null && cell.value.length > 20
                                  ? "${cell.value.substring(0, 20)}..."
                                  : cell.value ?? "",
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (cell.key == "achievementTree") {
                  Map<String, String> key = {};

                  var reversedAchievementTree = cell.value.split('>>').toList();
                  var reversedString =
                      reversedAchievementTree.reversed.toList().join('>>');
                  key[cell.key] = reversedString;
                  cells[key] = Text(
                    reversedString,
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10),
                  );
                } else {
                  Map<String, String> key = {};
                  key[cell.key] = cell.value;
                  cells[key] = Text(
                    cell.value,
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10),
                  );
                }
              } catch (e) {
                debugPrint(e.toString());
              }
            }
          }

          // Action hücresinin ismi ve değeris hep actions olmalı  // Önemli
          Map<String, String> actions = {};
          actions['actions'] = 'actions';
          cells[actions] = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PopupMenuButton<String>(
                  padding: const EdgeInsets.all(3.0),
                  itemBuilder: (BuildContext context) => [
                        if (orderNo != 1)
                           PopupMenuItem<String>(
                            padding: EdgeInsets.all(3.0),
                            value: 'move_up',
                            textStyle: TextStyle(fontSize: 10),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_upward, size: 14),
                                SizedBox(width: 8),
                                Text(AppLocalization.instance.translate(
                                    'lib.screen.quizPage.quizSectionDataTable',
                                    'createSectionQuestionsWidget',
                                    'moveUp'), style: TextStyle(fontSize: 10)),
                              ],
                            ),
                          ),
                        if (section.quizSectionQuestionMaps!.length != orderNo)
                           PopupMenuItem<String>(
                            padding: EdgeInsets.all(3.0),
                            value: 'move_down',
                            textStyle: TextStyle(fontSize: 10),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_downward, size: 14),
                                SizedBox(width: 8),
                                Text(AppLocalization.instance.translate(
                                    'lib.screen.quizPage.quizSectionDataTable',
                                    'createSectionQuestionsWidget',
                                    'moveDown'),
                                    style: TextStyle(fontSize: 10)),
                              ],
                            ),
                          ),
                        if (orderNo != 1)
                           PopupMenuItem<String>(
                            padding: EdgeInsets.all(3.0),
                            value: 'delete',
                            textStyle: TextStyle(fontSize: 10),
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 14),
                                SizedBox(width: 8),
                                Text(
                                  AppLocalization.instance.translate(
                                      'lib.screen.quizPage.quizSectionDataTable',
                                      'createSectionQuestionsWidget',
                                      'delete'),
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                      ],
                  onSelected: (String? value) {
                    if (value == 'move_up') {
                      if (orderNo != 1) {
                        int currentOrder = orderNo ?? 0;

                        var currentSectionQuestionMap = section
                            .quizSectionQuestionMaps!
                            .where((element) =>
                                element.orderNo == currentOrder &&
                                element.questionId == questionId)
                            .first
                            .updateOrderNo(currentOrder - 1);
                        var replacedSectionQuestionMap = section
                            .quizSectionQuestionMaps!
                            .where((element) =>
                                element.orderNo == currentOrder - 1 &&
                                element.questionId != questionId)
                            .first
                            .updateOrderNo(currentOrder);

                        widget.quizPageModel.quizMain!.quizSections!
                            .where(
                                (element) => element.orderNo == section.orderNo)
                            .first
                            .updatequizSectionQuestionMaps(
                                section.quizSectionQuestionMaps!,
                                section.orderNo ?? 0);
                        widget.onChanged(
                            widget.quizPageModel.quizMain!.quizSections);
                        setState(() {});
                      }
                    } else if (value == 'move_down') {
                      if (section.quizSectionQuestionMaps!.length != orderNo) {
                        int currentOrder = orderNo ?? 0;
                        var currentSectionQuestionMap = section
                            .quizSectionQuestionMaps!
                            .where((element) =>
                                element.orderNo == currentOrder &&
                                element.questionId == questionId)
                            .first
                            .updateOrderNo(currentOrder + 1);
                        var replacedSectionQuestionMap = section
                            .quizSectionQuestionMaps!
                            .where((element) =>
                                element.orderNo == currentOrder + 1 &&
                                element.questionId != questionId)
                            .first
                            .updateOrderNo(currentOrder);

                        widget.quizPageModel.quizMain!.quizSections!
                            .where(
                                (element) => element.orderNo == section.orderNo)
                            .first
                            .updatequizSectionQuestionMaps(
                                section.quizSectionQuestionMaps!,
                                section.orderNo ?? 0);

                        widget.onChanged(
                            widget.quizPageModel.quizMain!.quizSections);

                        setState(() {});
                      }
                    } else if (value == 'delete') {
                      section.quizSectionQuestionMaps!.removeWhere(
                          (element) => element.questionId == questionId);

                      widget.quizPageModel.quizMain!.quizSections!
                          .where(
                              (element) => element.orderNo == section.orderNo)
                          .first
                          .updatequizSectionQuestionMaps(
                              section.quizSectionQuestionMaps!,
                              section.orderNo ?? 0);

                      widget.onChanged(
                          widget.quizPageModel.quizMain!.quizSections);

                      setState(() {});
                    }
                  },
                  child:  Row(
                    children: [
                      Text(
                        AppLocalization.instance.translate(
                            'lib.screen.quizPage.quizSectionDataTable',
                            'createSectionQuestionsWidget',
                            'actions'),
                        style: TextStyle(color: Colors.blue, fontSize: 10),
                      ),
                      SizedBox(width: 5.0),
                      Icon(Icons.arrow_drop_down),
                    ],
                  )),
            ],
          );

          modifiedSectionRows.add(cells);

          sectionQuestionOrderNo++;
        }

        var sectionHeader = Text('${section.sectionDesc} ${AppLocalization.instance.translate(
            'lib.screen.quizPage.quizSectionDataTable',
            'createSectionQuestionsWidget',
            'section')}');
        var sectionQuestionMapDataTable = CommonDataTable(
          dataTableKeyColumnName: 'id',
          dataTableSelectedKeys: null,
          dataTableColumnAlias:  [
            AppLocalization.instance.translate('lib.screen.quizPage.quizSectionDataTable',  'createSectionQuestionsWidget','id'),
            AppLocalization.instance.translate('lib.screen.quizPage.quizSectionDataTable',  'createSectionQuestionsWidget','order'),
            AppLocalization.instance.translate('lib.screen.quizPage.quizSectionDataTable',  'createSectionQuestionsWidget','academicYear'),
            AppLocalization.instance.translate('lib.screen.quizPage.quizSectionDataTable',  'createSectionQuestionsWidget','question'),
            AppLocalization.instance.translate('lib.screen.quizPage.quizSectionDataTable',  'createSectionQuestionsWidget','difficultyLevel'),
            AppLocalization.instance.translate('lib.screen.quizPage.quizSectionDataTable',  'createSectionQuestionsWidget','branchName'),
            AppLocalization.instance.translate('lib.screen.quizPage.quizSectionDataTable',  'createSectionQuestionsWidget','achievementTree'),
            AppLocalization.instance.translate('lib.screen.quizPage.quizSectionDataTable',  'createSectionQuestionsWidget','createdOn'),
            AppLocalization.instance.translate('lib.screen.quizPage.quizSectionDataTable',  'createSectionQuestionsWidget','favorite'),
            AppLocalization.instance.translate('lib.screen.quizPage.quizSectionDataTable',  'createSectionQuestionsWidget','selectActions'),

          ],
          dataTableColumnNames: const [
            'id',
            'orderNo',
            'acad_year',
            'question_text',
            'dif_level',
            'branch_name',
            'achievementTree',
            'created_on',
            'favCount',
            'actions'
          ],
          columnDataTypes: [
            ColumnDataType('id', BigInt),
            ColumnDataType('orderNo', int),
            ColumnDataType('acad_year', String),
            ColumnDataType('question_text', String),
            ColumnDataType('dif_level', String),
            ColumnDataType('branch_name', String),
            ColumnDataType('achievementTree', String),
            ColumnDataType('created_on', DateTime),
            ColumnDataType('favCount', int),
            ColumnDataType('actions', String),
          ],
          dataTableDisableColumnFilter: const [
            'id',
            'orderNo',
            'acad_year',
            'question_text',
            'dif_level',
            'branch_name',
            'achievementTree',
            'created_on',
            'favCount',
            'actions'
          ],
          onChangedDisabledFilters: (disabledFilters) {},
          dataTableHideColumn: const [
            'dif_level',
            'branch_name',
            'achievementTree',
            'created_on',
            'favCount',
          ],
          dataTableRows: modifiedSectionRows,
          showCheckboxColumn: false,
          onFilterValueChanged:
              (filterText, index, filterControllers, filteredRows) {},
          onSelectedRowsChanged: (selectedRows, selectedKeys) {},
        );

        var cID = CollapsibleItemData(
            padding: 0,
            onStateChanged: (value) {},
            header: sectionHeader,
            content: sectionQuestionMapDataTable);

        items.add(cID);
        addedSections.add(section.orderNo);
      }
    }
    //---------------------------------------------------------------

    //Add section which have not questions
    var notAddedSections = widget.quizPageModel.quizMain!.quizSections!
        .where((element) => !addedSections!.contains(element.orderNo));

    for (var emptySection in notAddedSections) {
      var cID = CollapsibleItemData(
          padding: 0,
          onStateChanged: (value) {},
          header: Text(
            '${emptySection.sectionDesc} ${  AppLocalization.instance.translate('lib.screen.quizPage.quizSectionDataTable',  'createSectionQuestionsWidget','sections')}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          content: Container());

      items.add(cID);
    }

    return items;
  }
}

class QuizSectionDataTableEditPopup extends StatefulWidget {
  Map<int, String> branches;

  QuizSection section;
  final TextStyle componentTextStyle;
  final Function(QuizSection? section) onSavePressed;

  QuizSectionDataTableEditPopup(
      {required this.branches,
      required this.section,
      required this.onSavePressed,
      required this.componentTextStyle});

  @override
  _QuizSectionDataTableEditPopupState createState() =>
      _QuizSectionDataTableEditPopupState();
}

class _QuizSectionDataTableEditPopupState
    extends State<QuizSectionDataTableEditPopup> {
  final TextEditingController _sectionDescController = TextEditingController();

  @override
  void dispose() {
    _sectionDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var deviceType = getDeviceType(context);

    Map<int, String> branches = widget.branches;
    QuizSection section = widget.section;
    if (section != null && section.sectionDesc != null) {
      _sectionDescController.text = section.sectionDesc!;
    }

    return AlertDialog(
      title:  Text(AppLocalization.instance.translate(
          'lib.screen.quizPage.quizSectionDataTableEditPopup',
          'build',
          'sectionOperation')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonDropdownButtonFormField(
            isExpandedObject: true,
            label: AppLocalization.instance.translate(
                'lib.screen.quizPage.quizSectionDataTableEditPopup',
                'build',
                'branchName'),
              componentTextStyle: widget.componentTextStyle,
              items: branches,
              selectedItem: section.branchId,
              onSelectedItemChanged: (selectedBranch) {
                section.branchId = selectedBranch;
                String? secDescription = branches[selectedBranch] ?? '';
                secDescription = '$secDescription ${AppLocalization.instance.translate(
                    'lib.screen.quizPage.quizSectionDataTableEditPopup',
                    'build',
                    'sectionOperation')}';
                _sectionDescController.text = secDescription;
              }),
          const SizedBox(height: 10,),
          CommonTextFormField(
            directionText: AppLocalization.instance.translate(
                'lib.screen.quizPage.quizSectionDataTableEditPopup',
                'build',
                'sectionDescriptionsDirectionText'),
            controller: _sectionDescController,
            labelText: AppLocalization.instance.translate(
          'lib.screen.quizPage.quizSectionDataTableEditPopup',
          'build',
          'sectionDescriptions'),maxLines: 1,),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cancel button action
          },
          child: Text(AppLocalization.instance.translate(
              'lib.screen.quizPage.quizSectionDataTableEditPopup',
              'build',
              'cancel')),
        ),
        ElevatedButton(
          onPressed: () {
            String sectionDesc = _sectionDescController.text;
            int? branchId = section.branchId;
            widget.section.branchId = branchId;
            widget.section.sectionDesc = sectionDesc;
            widget.onSavePressed(widget.section);
            Navigator.of(context).pop();
          },
          child: Text(AppLocalization.instance.translate(
              'lib.screen.quizPage.quizSectionDataTableEditPopup',
              'build',
              'save')),
        ),
      ],
    );
  }
}
