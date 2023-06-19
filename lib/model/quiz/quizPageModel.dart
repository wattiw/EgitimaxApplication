import 'package:egitimaxapplication/model/quiz/quizMain.dart';
import 'package:egitimaxapplication/model/quiz/quizSection.dart';
import 'package:egitimaxapplication/model/quiz/quizSectionQuestionMap.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/screen/common/collapsibleItemBuilder.dart';
import 'package:egitimaxapplication/screen/common/keyValuePairs.dart';
import 'package:egitimaxapplication/screen/common/questionOverView.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:flutter/material.dart';

class QuizPageModel {
  QuizPageModel({
    required this.isEditorMode,
    required this.userId,
    required this.quizId,
  });

  late bool isEditorMode;
  late BigInt userId;
  late BigInt? quizId;

  bool isDelete = false;
  bool isPassive = false;
  bool isActive = true;
  bool isApproved = false;
  bool? isAcceptConditions = false;

  QuizMain? quizMain;
  Map<int, String> countries = {};
  Map<int, String> academicYears = {};
  Map<int, String> grades = {};
  Map<int, String> branches = {};

  Future<Widget> generateHtmlDocument(
      QuizMain quizMain, BuildContext context) async {
    final theme = Theme.of(context);
    AppRepositories appRepositories = AppRepositories();

    var branchDataSet = await appRepositories.tblLearnBranch(
        'Question/GetObject', ['branch_name', 'id'],
        getNoSqlData: 0);
    var branches = branchDataSet.toKeyValuePairsWithTypes<int, String>(
        'data', 'id',
        valueColumn: 'branch_name');

    List<KeyValuePairs> keyValuePairsOfQuizMain = List.empty(growable: true);

    if (quizMain.country != 0 && quizMain.country != null) {
      keyValuePairsOfQuizMain.add(KeyValuePairs(
          keyText: 'Country',
          valueText: countries.entries
              .where((o) => o.key == quizMain.country)
              .first
              .value));
    }
    if (quizMain.academicYear != 0 && quizMain.academicYear != null) {
      keyValuePairsOfQuizMain.add(KeyValuePairs(
          keyText: 'Academic Year',
          valueText: academicYears.entries
              .where((o) => o.key == quizMain.academicYear)
              .first
              .value));
    }
    if (quizMain.gradeId != 0 && quizMain.gradeId != null) {
      keyValuePairsOfQuizMain.add(KeyValuePairs(
          keyText: 'Grade',
          valueText: grades.entries
              .where((o) => o.key == quizMain.gradeId)
              .first
              .value));
    }

    keyValuePairsOfQuizMain
        .add(KeyValuePairs(keyText: 'Title', valueText: quizMain.title ?? ''));
    keyValuePairsOfQuizMain.add(KeyValuePairs(
        keyText: 'Description', valueText: quizMain.description ?? ''));
    keyValuePairsOfQuizMain.add(KeyValuePairs(
        keyText: 'Duration', valueText: quizMain.duration.toString() ?? ''));
    keyValuePairsOfQuizMain.add(KeyValuePairs(
        keyText: 'Header Text', valueText: quizMain.headerText ?? ''));
    keyValuePairsOfQuizMain.add(KeyValuePairs(
        keyText: 'Footer Text', valueText: quizMain.footerText ?? ''));
    if (quizMain.isPublic != 0 && quizMain.isPublic != null) {
      keyValuePairsOfQuizMain.add(KeyValuePairs(
          keyText: 'Is Public',
          valueText: quizMain.isPublic == 1 ? 'Yes' : 'No'));
    }
    if (quizMain.aggRating != 0 && quizMain.aggRating != null) {
      keyValuePairsOfQuizMain.add(KeyValuePairs(
          keyText: 'Aggregating Rating',
          valueText: quizMain.aggRating.toString()));
    }

    List<CollapsibleItemData> cIDs = List.empty(growable: true);

    for (QuizSection quizSection in quizMain.quizSections ?? []) {
      List<KeyValuePairs> keyValuePairsOfSectionHeader =
          List.empty(growable: true);

      if (quizSection.quizSectionQuestionMaps != null &&
          quizSection.quizSectionQuestionMaps!.isNotEmpty) {
        keyValuePairsOfSectionHeader.add(KeyValuePairs(
            keyText: 'Question Quantity',
            valueText: quizSection.quizSectionQuestionMaps!.length.toString()));
      } else {
        keyValuePairsOfSectionHeader.add(
            const KeyValuePairs(keyText: 'Question Quantity', valueText: '0'));
      }

      if (quizSection.branchId != 0 && quizSection.branchId != null) {
        keyValuePairsOfSectionHeader.add(KeyValuePairs(
            keyText: 'Branch',
            valueText: branches.entries
                .where((o) => o.key == quizSection.branchId)
                .first
                .value));
      }
      if (quizSection.orderNo != 0 && quizSection.orderNo != null) {
        keyValuePairsOfSectionHeader.add(KeyValuePairs(
            keyText: 'Order No', valueText: quizSection.orderNo.toString()));
      }

      keyValuePairsOfSectionHeader.add(KeyValuePairs(
          keyText: 'Section Description',
          valueText: quizSection.sectionDesc ?? ''));

      List<TextButton> sectionQuestions = List.empty(growable: true);
      for (QuizSectionQuestionMap quizSectionQuestionMap
          in quizSection.quizSectionQuestionMaps ?? []) {
        TextButton questionLink;

        var questionDataSet = await appRepositories.tblQueQuestionMain(
            'Question/GetObject', ['id', 'question_text'],
            id: quizSectionQuestionMap.questionId, getNoSqlData: 0);
        var questions = questionDataSet.toKeyValuePairsWithTypes<int, String>(
            'data', 'id',
            valueColumn: 'question_text');

        questionLink = TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return QuestionOverView(
                  questionId:
                      quizSectionQuestionMap.questionId ?? BigInt.parse('0'),
                  userId: userId,
                );
              },
            );
          },
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(
              TextStyle(fontSize: theme.dataTableTheme.dataTextStyle?.fontSize),
            ),
          ),
          child: Tooltip(
            message: questions.entries.first.value ?? "",
            child: Wrap(
              spacing: 5,
              runSpacing: 5,
              alignment: WrapAlignment.start,
              children: [
                KeyValuePairs(
                  keyText:
                      'Question Order No: ${quizSectionQuestionMap.orderNo.toString()} | Question',
                  valueText: questions.entries.first.value != null &&
                          questions.entries.first.value.length > 20
                      ? "${questions.entries.first.value.substring(0, 20)}..."
                      : questions.entries.first.value ?? "",
                ),
              ],
            ),
          ),
        );
        KeyValuePairs? qON;
        if (quizSectionQuestionMap.orderNo != 0 &&
            quizSectionQuestionMap.orderNo != null) {
          qON = KeyValuePairs(
              keyText: 'Question Order No',
              valueText: quizSectionQuestionMap.orderNo.toString());
        }

        sectionQuestions.add(questionLink);
      }

      var resultHeader = Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: double.infinity,
          child: Wrap(
              spacing: 5,
              runSpacing: 5,
              alignment: WrapAlignment.start,
              children: keyValuePairsOfSectionHeader),
        ),
      );
      var resultContent = Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: double.infinity,
          child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.start,
              children: sectionQuestions),
        ),
      );

      CollapsibleItemData cID = CollapsibleItemData(
          header: resultHeader,
          content: resultContent,
          padding: 10,
          onStateChanged: (value) {});
      cIDs.add(cID);
    }

    var result = Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
                spacing: 5,
                runSpacing: 5,
                alignment: WrapAlignment.start,
                children: keyValuePairsOfQuizMain),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: SizedBox(
              width: double.infinity,
              child: CollapsibleItemBuilder(
                  items: cIDs,
                  padding: 10,
                  onStateChanged: (onStateChanged) {})),
        ),
      ],
    );

    return result;
  }
}
