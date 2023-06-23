import 'package:egitimaxapplication/model/lecture/setLectureObjects.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/lecture/lectureRepository.dart';
import 'package:egitimaxapplication/screen/common/commonDataTable.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:flutter/material.dart';

class LectureObjectsSummary extends StatelessWidget {
  final SetLectureObjects lectureObjects;
  final CommonDataTable?  lectureFlowDataTable;

  LectureObjectsSummary({required this.lectureObjects, required this.lectureFlowDataTable});

  @override
  Widget build(BuildContext context) {
    var lectureTitle = lectureObjects.tblCrsCourseMain?.title ?? '';


    var preparedBy = lectureObjects.tblCrsCourseMain?.userId ?? '';

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isWideScreen = maxWidth > 600;

        return Column(
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Lecture Title:'),
                        Text(lectureObjects.tblCrsCourseMain?.title ?? '')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Prepared By:'),
                        Text(lectureObjects.tblCrsCourseMain?.title ?? '')
                      ],
                    ),
                  ],
                ),
              ),
            ),

          ],
        );
      },
    );
  }

  Future<Widget> prepareWidget() async {
    LectureRepository lectureRepository = LectureRepository();
    AppRepositories appRepositories = AppRepositories();

    var lectureTitle = lectureObjects.tblCrsCourseMain?.title ?? '';

    var userDataSet = await appRepositories.tblUserMain(
        'Lecture/GetObject', ['id', 'name', 'surname'], getNoSqlData: 0,
        id: lectureObjects.tblCrsCourseMain?.userId);
    var preparedBy = userDataSet.firstValue('data', 'name', insteadOfNull: '') +
        ' ' + userDataSet.firstValue('data', 'surname', insteadOfNull: '');

    var descriptions = lectureObjects.tblCrsCourseMain?.description ?? '';

    var gradeDataSet = await appRepositories.tblClassGrade(
        'Lecture/GetObject', ['id', 'grade_name'], getNoSqlData: 0,
        id: lectureObjects.tblCrsCourseMain?.gradeId);
    var gradeName = gradeDataSet.firstValue(
        'data', 'grade_name', insteadOfNull: '');

    var branchDataSet = await appRepositories.tblLearnBranch(
        'Lecture/GetObject', ['id', 'branch_name'], getNoSqlData: 0,
        id: lectureObjects.tblCrsCourseMain?.branchId);
    var branchName = branchDataSet.firstValue(
        'data', 'branch_name', insteadOfNull: '');

    var getLearnLevelsDataSet = await appRepositories.getLearnInfoById(
        'Lecture/GetObject', ['0']);
    var learnLevels = getLearnLevelsDataSet.firstValue(
        'data', 'levels', insteadOfNull: '');
    String input = learnLevels;
    Map<String, String> learnLevelsKeyValuePairs = {};
    // Splitting the string using '|'
    List<String> parts = input.split('|');
    if (parts.length >= 2) {
      // Getting the second part and splitting it using ';'
      List<String> subParts = parts[1].split(';');

      for (String subPart in subParts) {
        List<String> items = subPart.split(':');
        if (items.length >= 2) {
          String key = items[0].trim();
          String value = items[1].trim();
          learnLevelsKeyValuePairs[key] = value;
        }
      }
    }

    var isPublic = lectureObjects.tblCrsCourseMain?.isPublic == 1
        ? 'Yes'
        : 'No';

    var openingMessage = lectureObjects.tblCrsCourseMain?.welcomeMsg ?? '';
    var closingMessage = lectureObjects.tblCrsCourseMain?.goodbyeMsg ?? '';

    lectureFlowDataTable?.dataTableHideColumn=const [
      'id',
      'course_id',
      //'order_no',
      'flow_id',
      //'flow_item',
      //'flow_type',
      'is_active',
      'actions'
    ];

    return Container();
  }
}
