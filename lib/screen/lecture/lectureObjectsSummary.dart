import 'package:egitimaxapplication/model/lecture/setLectureObjects.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/lecture/lectureRepository.dart';
import 'package:egitimaxapplication/screen/common/commonDataTable.dart';
import 'package:egitimaxapplication/screen/common/percentageCircle.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:flutter/material.dart';

class LectureObjectsSummary extends StatelessWidget {
  final SetLectureObjects lectureObjects;
  final CommonDataTable? lectureFlowDataTable;

  LectureObjectsSummary(
      {required this.lectureObjects, required this.lectureFlowDataTable});

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
                    FutureBuilder<Widget>(
                      future: prepareWidget(),
                      builder: (BuildContext context,
                          AsyncSnapshot<Widget> snapshot) {
                        if (snapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: snapshot.data ?? Container(),
                          );
                        } else if (snapshot.hasError) {
                          return const Text('Nasip');
                        } else {
                          return const CircularProgressIndicator(); // or any other loading indicator
                        }
                      },
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
        'Lecture/GetObject', ['id', 'name', 'surname'],
        getNoSqlData: 0, id: lectureObjects.tblCrsCourseMain?.userId);
    var preparedBy = userDataSet.firstValue('data', 'name', insteadOfNull: '') +
        ' ' +
        userDataSet.firstValue('data', 'surname', insteadOfNull: '');

    var descriptions = lectureObjects.tblCrsCourseMain?.description ?? '';

    var gradeDataSet = await appRepositories.tblClassGrade(
        'Lecture/GetObject', ['id', 'grade_name'],
        getNoSqlData: 0, id: lectureObjects.tblCrsCourseMain?.gradeId);
    var gradeName =
        gradeDataSet.firstValue('data', 'grade_name', insteadOfNull: '');

    var branchDataSet = await appRepositories.tblLearnBranch(
        'Lecture/GetObject', ['id', 'branch_name'],
        getNoSqlData: 0, id: lectureObjects.tblCrsCourseMain?.branchId);
    var branchName =
        branchDataSet.firstValue('data', 'branch_name', insteadOfNull: '');

    var getLearnLevelsDataSet = await appRepositories.getLearnInfoById(
        'Lecture/GetObject', ['*'],
        learn_id: lectureObjects.tblCrsCourseMain?.learnId);
    var learnLevels =
        getLearnLevelsDataSet.firstValue('data', 'levels', insteadOfNull: '');
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

    var isPublic =lectureObjects.tblCrsCourseMain?.isPublic == 1 ? 'Yes' : 'No';

    var openingMessage = lectureObjects.tblCrsCourseMain?.welcomeMsg ?? '';
    var closingMessage = lectureObjects.tblCrsCourseMain?.goodbyeMsg ?? '';

    lectureFlowDataTable?.dataTableHideColumn = const [
      'id',
      'course_id',
      //'order_no',
      'flow_id',
      //'flow_item',
      //'flow_type',
      //'flow_achievement_tree',
      //'compatibleLectureAchievement',
      'is_active',
      'actions'
    ];
    lectureFlowDataTable?.toolBarButtons=null;

    var flows = lectureObjects.tblCrsCourseMain?.tblCrsCourseFlows;
    var videoResult = '';
    var questResult = '';
    if (flows != null) {
      for (var flow in flows) {
        var videoId = flow.videoId;
        var questId = flow.questId;

        if (videoId != null && videoId != 0) {
          if (videoResult.isNotEmpty) {
            videoResult += ',';
          }
          videoResult += videoId.toString();
        }

        if (questId != null && questId != 0) {
          if (questResult.isNotEmpty) {
            questResult += ',';
          }
          questResult += questId.toString();
        }
      }
    }
    var achievementMeterDataSet = await appRepositories.procAchievementMeter('Lecture/GetObject', videoResult, questResult, getNoSqlData: 0);

    List<Row> cardOne = List.empty(growable: true);
    cardOne.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text(
          'Lecture Title:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(lectureTitle)
      ],
    ));
    cardOne.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text(
          'Prepared By:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(preparedBy)
      ],
    ));
    cardOne.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text(
          'Descriptions:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(descriptions)
      ],
    ));
    cardOne.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text(
          'Grade:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(gradeName)
      ],
    ));
    cardOne.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text(
          'Branch:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(branchName)
      ],
    ));

    var libType = {
      "ct_dom": AppLocalization.instance
          .translate('lib.screen.common.videoOverView', 'build', 'domain'),
      "ct_subdom": AppLocalization.instance
          .translate('lib.screen.common.videoOverView', 'build', 'subdomain'),
      "ct_achv": AppLocalization.instance
          .translate('lib.screen.common.videoOverView', 'build', 'achievement'),
      "ct_subject": AppLocalization.instance
          .translate('lib.screen.common.videoOverView', 'build', 'subject')
    };
    for (var item in learnLevelsKeyValuePairs.entries.toList().reversed.toList()) {

      if(item.key!='ct_achv')
        {
          var rowX = Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                '${libType[item.key] ?? ''} :',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(item.value)
            ],
          );
          cardOne.add(rowX);
        }
    }
    cardOne.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text(
          'Is Public:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(isPublic)
      ],
    ));
    var c1 = Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: cardOne),
      ),
    );

    List<Row> cardTwo = List.empty(growable: true);
    cardTwo.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text(
          'Opening Message:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(openingMessage)
      ],
    ));
    cardTwo.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text(
          'Closing Message:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(closingMessage)
      ],
    ));
    var c2 = Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: cardTwo),
      ),
    );

    List<Container> cardThree = List.empty(growable: true);

    cardThree.add( Container(
      alignment: Alignment.centerLeft,
      child: lectureFlowDataTable,
    ));

    var c3 = Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: cardThree),
      ),
    );

    List<Card> cardFour = List.empty(growable: true);


    int totolAchievement=0;
    int compatibleAchievement=0;
    for(var achitem in achievementMeterDataSet.selectDataTable('data'))
      {


        var isContain=achitem['is_contain'];
        var code=achitem['item_code'];
        var name=achitem['name'];

        if(code!=null)
          {
            totolAchievement++;
            if(achitem['is_contain']==1)
              {
                compatibleAchievement++;
              }
            var item= Card(
              color: achitem['is_contain']==1 ? Colors.greenAccent.shade700 : Colors.red.shade600,
              child: ListTile(
                title: Text(achitem['item_code'],style: const TextStyle(fontSize: 10),),
                subtitle: Text(achitem['name'],style: const TextStyle(fontSize: 10),),
              ),
            );

            cardFour.add(item);

          }


      }

    double percentageOfAchievement=0.0;
    try{
      percentageOfAchievement=(100*compatibleAchievement)/totolAchievement;

    }catch(e)
    {
      percentageOfAchievement=0;
    }


    cardFour.add(
      Card(
        color: Colors.transparent,
        child: PercentageCircle(
          percentage: percentageOfAchievement != null && !percentageOfAchievement.isNaN ? percentageOfAchievement : 0.0,
        ),
      ),
    );

    cardFour=cardFour.reversed.toList();

    var c4 = percentageOfAchievement!=null ?  Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Card(
          elevation: 4,
          margin: EdgeInsets.all(8),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Achievement Meter'),
              ],
            )
          ),
        ),
        Card(
          elevation: 4,
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children:percentageOfAchievement!=null ? cardFour : [Container()]),
          ),
        ),
      ],
    ) : Container();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [c1,c2,c3, c4],
    );
  }
}
