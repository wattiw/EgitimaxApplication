import 'package:egitimaxapplication/model/question/question.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/question/questionRepository.dart';
import 'package:egitimaxapplication/screen/common/collapsibleItemBuilder.dart';
import 'package:egitimaxapplication/screen/common/webViewPage.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/constant/appConstant/generalAppConstant.dart';
import 'package:egitimaxapplication/utils/constant/language/appLocalizationConstant.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:egitimaxapplication/utils/helper/getDeviceType.dart';
import 'package:flutter/material.dart';

class QuestionOverView extends StatefulWidget {
  final BigInt questionId;
  final BigInt userId;
  bool isFavorite = false;
  bool isLiked = false;
  bool isDisLiked = false;
  int likeCount = 0;
  AppRepositories appRepositories = AppRepositories();
  QuestionRepository questionRepository = QuestionRepository();
  Map<String, dynamic>? qovDataSet;
  bool hideText = false;

  QuestionOverView({
    required this.questionId,
    required this.userId,
  });

  @override
  _QuestionOverViewState createState() => _QuestionOverViewState();
}

class _QuestionOverViewState extends State<QuestionOverView> {
  bool isFilterExpandedForResolution = false;
  bool isFilterActiveForResolution = false;
  bool isFilterExpandedForDetails = false;
  bool isFilterActiveForDetails = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var deviceType = getDeviceType(context);

    if (deviceType == DeviceType.mobileSmall ||
        deviceType == DeviceType.mobileLarge ||
        deviceType == DeviceType.mobileMedium) {
      widget.hideText = true;
    }

    return AlertDialog(
      title: SizedBox(
        height: 40, // Başlık bölümünün yüksekliğini artırın
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
             Expanded(
              child: Text(
                AppLocalization.instance.translate('lib.screen.common.questionOverView','build', 'viewQuestion'),
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close),
            ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.all(5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      content: Container(
        width: double.infinity,
        height: 600,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                LikeCountWidget(
                  questionId: widget.questionId,
                ),
                const SizedBox(height: 16),
                FutureBuilder<Widget>(
                  future: getQuestionOverView(widget.questionId),
                  builder: (BuildContext context,
                      AsyncSnapshot<Widget> innerSnapshot) {
                    if (innerSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (innerSnapshot.hasError) {
                      return Text('${AppLocalization.instance.translate('lib.screen.common.questionOverView','build', 'error')}: ${innerSnapshot.error}');
                    } else if (innerSnapshot.hasData) {
                      return innerSnapshot.data!;
                    } else {
                      return Container();
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (false)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.close),
                            SizedBox(width: 8),
                            // Adding some spacing between the icon and text
                            Text('Close'),
                          ],
                        ),
                      ),
                    const SizedBox(
                      height: 15,
                    )
                  ],
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String generateHTMLCode(List<String> list) {
    String htmlCode = '';
    for (var item in list) {
      htmlCode += '<div>$item</div>';
    }
    return htmlCode;
  }

  Future<Widget> getQuestionOverView(BigInt questionId) async {
    var qovDataSet = widget.qovDataSet ??
        await widget.appRepositories.questionOverView(
            'Question/GetObject', ['*'], widget.questionId,
            getNoSqlData: 1);
    widget.qovDataSet ??= qovDataSet;

    var questionHtmlString = qovDataSet.firstValue(
        'collectiondata_question', 'QuestionDocument',
        insteadOfNull: GeneralAppConstant.Slogan);
    var questionFreeTextAnswerHtmlString = qovDataSet.firstValue(
        'collectiondata_question', 'QuestionAnswerDocument',
        insteadOfNull: GeneralAppConstant.Slogan);

    var tblQueQuestOptionDataSet =
        await widget.appRepositories.tblQueQuestOption(
            'Question/GetObject',
            [
              'id',
              'quest_id',
              'is_active',
              'is_correct',
              'opt_identifier',
              'opt_text',
              'opt_text'
            ],
            quest_id: widget.questionId);

    var questionOptionsFromSql = tblQueQuestOptionDataSet.selectDataTable(
        'data',
        filterColumn: 'quest_id',
        filterValue: widget.questionId);

    List<Option>? questionOptions = List.empty(growable: true);

    int i = 0;
    for (var qop in questionOptionsFromSql) {
      try {
        Option option = Option();
        option.id = BigInt.tryParse(qop['id'].toString());
        option.isActive = qop['is_active'] == 1 ? true : false;
        option.isCorrect = qop['is_correct'] == 1 ? true : false;
        option.questId = BigInt.tryParse(qop['quest_id'].toString());
        option.mark = qop['opt_identifier'];
        option.data = qop['opt_text'];
        option.text = qop['opt_text'];

        var qopHtmlString = qovDataSet.firstValue(
            'collectiondata_questionoptions', 'OptionValue',
            filterColumn: 'OptionId',
            filterValue: option.id,
            insteadOfNull: GeneralAppConstant.Slogan);
        option.data = qopHtmlString;
        option.text = qopHtmlString;
        questionOptions.add(option);
      } catch (e) {
        debugPrint(e.toString());
      }
      i++;
    }

    String questionTitle = AppLocalization.instance.translate(
        'lib.screen.questionPage.questionPage',
        'getStepThreeLayout',
        'questionTitle');
    String optionsTitle = '';
    String optionsList = '';

    if (questionOptions != null && questionOptions!.isNotEmpty) {
      String optionsTable =
          '<table style="border-collapse: collapse; text-align: center;">';

      for (var op in questionOptions!) {
        String column1 =
            '<td style="border: none; white-space: nowrap; text-align: left; min-width: 5ch; padding: 5px;"><strong>${op.mark.toString()}</strong></td>';
        String column2 =
            '<td style="border: none; word-wrap: break-word; text-align: left; padding: 0px;">${op.data.toString()}</td>';
        String column3 =
            '<td style="border: none; word-wrap: break-word; text-align: left; padding: 0px;">${(op.isCorrect == true ? '&#10004;' : '')}</td>';

        String row = '<tr>$column3$column1$column2</tr>';

        optionsTable += row;
      }

      optionsTable += '</table>';

      optionsList = optionsTable;
    }

    String resolutionTitle = AppLocalization.instance.translate(
        'lib.screen.common.questionOverView',
        'build',
        'resolutionTitle');

    String fullHtmlStringQQOAS = '''<p>
                        <strong style="color: rgb(0, 0, 0);">
                          <u>${true ? '' : questionTitle}</u>
                        </strong>
                      </p>
                      <p>
                        <span style="color: rgb(0, 0, 0);">${questionHtmlString}</span>
                      </p>
                      <p>
                        <strong style="color: rgb(0, 0, 0);">
                          <u>${true ? '' : optionsTitle}</u>
                        </strong>
                      </p>
                       $optionsList     
                      <p>
                        <br>
                      </p>
                      ''';
    String existSolutionText = '''
                      <p>
                        <strong style="color: rgb(0, 0, 0);"><u>${true ? '' : resolutionTitle}</u></strong>
                      </p>
                      <p>
                        <span style="color: rgb(0, 0, 0);">${questionFreeTextAnswerHtmlString}</span>
                      </p>
                      ''';

    if (false &&
        questionFreeTextAnswerHtmlString != null &&
        questionFreeTextAnswerHtmlString != '') {
      fullHtmlStringQQOAS = fullHtmlStringQQOAS + existSolutionText;
    }

    // Key-value çiftlerini HTML nesnesine dönüştürme
    String keyValuePairs = '';
    List<String> keyValuePairListOne = List.empty(growable: true);
    List<String> keyValuePairListOneColumnNames = ['branch_name', 'learn_data'];

    List<String> keyValuePairListTwo = List.empty(growable: true);
    List<String> keyValuePairListTwoColumnNames = [
      'grade_name',
      'dif_level',
      'acad_year'
    ];

    List<String> keyValuePairListThree = List.empty(growable: true);
    List<String> keyValuePairListThreeColumnNames = ['learn_data'];

    List<String> keyValuePairListFour = List.empty(growable: true);
    List<String> keyValuePairListFourColumnNames = ['achievements'];

    var rows = qovDataSet.selectDataTable('data');

    Map<String, String> columnDisplayNames = {
      'branch_name': AppLocalization.instance.translate(
          'lib.screen.common.questionOverView',
          'build',
          'branchName'),
      'acad_year': AppLocalization.instance.translate(
          'lib.screen.common.questionOverView',
          'build',
          'academicYear'),
      'grade_name': AppLocalization.instance.translate(
          'lib.screen.common.questionOverView',
          'build',
          'gradeName'),
      'dif_level': AppLocalization.instance.translate(
          'lib.screen.common.questionOverView',
          'build',
          'difficultyLevel'),
      'learn_data': AppLocalization.instance.translate(
          'lib.screen.common.questionOverView',
          'build',
          'achievementTree'),
      'achievements':  AppLocalization.instance.translate(
          'lib.screen.common.questionOverView',
          'build',
          'achievements')
    };

    for (var row in rows) {
      for (var cell in row.entries) {
        String columnName = cell.key;
        String? displayName = columnDisplayNames.containsKey(columnName)
            ? columnDisplayNames[columnName]
            : columnName;

        keyValuePairs =
            '''<div><strong>$displayName:</strong> ${cell.value}</div>''';

        if (keyValuePairListOneColumnNames.contains(cell.key)) {
          if (keyValuePairListThreeColumnNames.contains(cell.key)) {
            List<String> achievementTress = cell.value.split("|");
            String secondPart = achievementTress[1] ?? '';

            String formattedSecondPart = '';
            List<String> titles = [AppLocalization.instance.translate(
                'lib.screen.common.questionOverView',
                'build',
                'domain'), AppLocalization.instance.translate(
                'lib.screen.common.questionOverView',
                'build',
                'subdomain'), AppLocalization.instance.translate(
                'lib.screen.common.questionOverView',
                'build',
                'subject')];

            if (secondPart.isNotEmpty) {
              List<String> outerParts = secondPart.split(';').reversed.toList();
              formattedSecondPart += '';
              for (int i = 0; i < outerParts.length; i++) {
                List<String> innerParts = outerParts[i].split(',');
                String title = titles[i]; // Başlık
                if (achievementTress.length >= 3 &&
                    i < achievementTress[2].length) {
                  title = AppLocalization.instance.translate(
                      'lib.screen.common.questionOverView',
                      'build',
                      'subTopic'); // achievementTress[2][i];
                }
                formattedSecondPart +=
                    '<div><strong>$title:</strong>${outerParts[i]}</div>';
              }
              formattedSecondPart += '';
            }

            keyValuePairs = formattedSecondPart;
          }

          keyValuePairListOne.add(keyValuePairs);
          keyValuePairListOne = keyValuePairListOne.reversed.toList();
        } else if (keyValuePairListTwoColumnNames.contains(cell.key)) {
          keyValuePairListTwo.add(keyValuePairs);
        } else if (keyValuePairListThreeColumnNames.contains(cell.key)) {
        } else if (keyValuePairListFourColumnNames.contains(cell.key)) {
          List<String> achievements = cell.value.split("|");

          String listItemElements =
              achievements.map((item) => '<li>$item</li>').join('');

          keyValuePairs =
              '''<div><strong>$displayName:</strong> <ul>$listItemElements</ul></div>''';

          keyValuePairListFour.add(keyValuePairs);
        }
      }
    }

    String htmlCodeSubPart = '''
<table>
  <tr>
    <td style="width: 50%;">${generateHTMLCode(keyValuePairListOne)}</td>
    <td style="width: 50%;">${generateHTMLCode(keyValuePairListTwo)}</td>
  </tr>
  <br>
  <tr>
    <td colspan="2" style="width: 100%;">${generateHTMLCode(keyValuePairListFour)}</td>
  </tr>
</table>
''';

    String questionAndOptions = '''
<!DOCTYPE html>
<html>
<head>
<style>
  body {
    background-color: white;
    width: 300px;
    height: 500px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
</style>
</head>
<body>
<div>${fullHtmlStringQQOAS.replaceAll('<br>', '')}</div>
<hr>
</body>
</html>
''';

    String questionResolutions = '''
<!DOCTYPE html>
<html>
<head>
<style>
  body {
    background-color: white;
    width: 300px;
    height: 500px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
</style>
</head>
<body>
<div>${existSolutionText.replaceAll('<br>', '')}</div>
</body>
</html>
''';

    String questionDetails = '''
<!DOCTYPE html>
<html>
<head>
<style>
  body {
    background-color: white;
    width: 300px;
    height: 500px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
</style>
</head>
<body>
    <div class="container">
         $htmlCodeSubPart
        </div>
</body>
</html>
''';

    const componentTextStyle = TextStyle(
        fontSize: 10,
        backgroundColor: Colors.white,
        color: Colors.black,
        locale: AppLocalizationConstant.DefaultLocale);


    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        WebViewPage(
          htmlContent: questionAndOptions,
          textStyle: componentTextStyle,
        ),
        const SizedBox(
          height: 3,
        ),
        LikeDislikeFavShareButtons(
          questionId: widget.questionId,
          userId: widget.userId,
        ),
        FutureBuilder<Container>(
          future:getCollapsibleQuestionResolutionAndDetails(questionResolutions, componentTextStyle, questionDetails) ,
          builder: (BuildContext context, AsyncSnapshot<Container> snapshot) {
            if (snapshot.hasData) {
              return snapshot.data ?? Container();
            } else if (snapshot.hasError) {
              return Text('${AppLocalization.instance.translate(
                  'lib.screen.common.questionOverView',
                  'build',
                  'error')}: ${snapshot.error}');
            } else {
              return const CircularProgressIndicator(); // or any other loading indicator
            }
          },
        ),
        const SizedBox(
          height: 5,
        ),
      ],
    );
  }

  Future<Container> getCollapsibleQuestionResolutionAndDetails(String questionResolutions, TextStyle componentTextStyle, String questionDetails) async {

    CollapsibleItemData itemData1 = CollapsibleItemData(
      isExpanded: false,
        header: Text(AppLocalization.instance.translate(
            'lib.screen.common.questionOverView',
            'build',
            'showQuestionResolutions')),
        content: WebViewPage(
          htmlContent: questionResolutions,
          textStyle: componentTextStyle,
        ),
        padding: 10,
        onStateChanged: (isFilterExpandedNew) {});

    CollapsibleItemData itemData2 = CollapsibleItemData(
        isExpanded: false,
        header:  Text(AppLocalization.instance.translate(
            'lib.screen.common.questionOverView',
            'build',
            'showQuestionDetails')),
        content: WebViewPage(
          htmlContent: questionDetails,
          textStyle: componentTextStyle,
        ),
        padding: 10,
        onStateChanged: (isFilterExpandedNew) {});

    var collapsableItems = CollapsibleItemBuilder(
      items: [itemData1, itemData2],
      padding: 10,
      onStateChanged: (bool) {},
    );
    return Container(child: collapsableItems);
  }
}

class LikeDislikeFavShareButtons extends StatefulWidget {
  AppRepositories appRepositories = AppRepositories();
  QuestionRepository questionRepository = QuestionRepository();
  final BigInt questionId;
  final BigInt userId;

  LikeDislikeFavShareButtons({required this.userId, required this.questionId});

  @override
  _LikeDislikeFavShareButtonsState createState() =>
      _LikeDislikeFavShareButtonsState();
}

class _LikeDislikeFavShareButtonsState
    extends State<LikeDislikeFavShareButtons> {
  bool isLiked = false;
  bool isDisLiked = false;
  bool isFavorite = false;
  bool hideText = false;

  Future<void> setIsLikedByMe() async {
    var nullVoid = await widget.questionRepository.questionSetIsLikeOrNot(
        ['*'], widget.questionId, isLiked ? 1 : 0, widget.userId,
        getNoSqlData: 0);
  }

  Future<void> setIsDisLikedByMe() async {
    var nullVoid = await widget.questionRepository.questionSetIsLikeOrNot(
        ['*'], widget.questionId, isDisLiked ? 2 : 0, widget.userId,
        getNoSqlData: 0);
  }

  Future<void> setIsMyFavorite() async {
    var nullVoid = await widget.questionRepository.questionSetMyFavorite(
        ['*'], widget.questionId, isFavorite ? 1 : 0, widget.userId,
        getNoSqlData: 0);
  }

  void shareQuestion() {}

  Future<bool> updateButtonStatus() async {
    var questionLikeDataSet = await widget.appRepositories.tblQueQuestionLike(
        'Question/GetObject', ['id', 'quest_id', 'user_id', 'like_type'],
        quest_id: widget.questionId, user_id: widget.userId);
    var qL =
        questionLikeDataSet.firstValue('data', 'like_type', insteadOfNull: 2);

    if (qL == 1) {
      isLiked = true;
      isDisLiked = false;
    } else if (qL == 2) {
      isLiked = false;
      isDisLiked = true;
    } else {
      isLiked = false;
      isDisLiked = false;
    }

    var tblFavQuestionDataSet = await widget.appRepositories.tblFavQuestion(
        'Question/GetObject', ['id', 'question_id', 'user_id'],
        question_id: widget.questionId, user_id: widget.userId);

    var qF = tblFavQuestionDataSet.firstValue('data', 'question_id',
        insteadOfNull: 0);

    if (qF > 0) {
      isFavorite = true;
    } else {
      isFavorite = false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var deviceType = getDeviceType(context);

    if (deviceType == DeviceType.mobileSmall ||
        deviceType == DeviceType.mobileLarge ||
        deviceType == DeviceType.mobileMedium) {
      hideText = true;
    }
    return FutureBuilder<bool>(
      future: updateButtonStatus(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isLiked = !isLiked;
                        if (isLiked) {
                          isDisLiked = false;
                        }
                        setIsLikedByMe();
                      });
                    },
                    icon: Icon(
                      isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                    ),
                    tooltip: isLiked ? AppLocalization.instance.translate(
                        'lib.screen.common.questionOverView',
                        'build',
                        'unlike') : AppLocalization.instance.translate(
                        'lib.screen.common.questionOverView',
                        'build',
                        'like') ,
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isDisLiked = !isDisLiked;
                        if (isDisLiked) {
                          isLiked = false;
                        }
                        setIsDisLikedByMe();
                      });
                    },
                    icon: Icon(
                      isDisLiked
                          ? Icons.thumb_down
                          : Icons.thumb_down_alt_outlined,
                    ),
                    tooltip: isDisLiked ?  AppLocalization.instance.translate(
                        'lib.screen.common.questionOverView',
                        'build',
                        'removeDisLike')  :  AppLocalization.instance.translate(
                        'lib.screen.common.questionOverView',
                        'build',
                        'disLike'),
                  ),
                  if (hideText)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                          setIsMyFavorite();
                        });
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                      ),
                      tooltip: isFavorite
                          ? AppLocalization.instance.translate(
                          'lib.screen.common.questionOverView',
                          'build',
                          'removeFav')
                          : AppLocalization.instance.translate(
                          'lib.screen.common.questionOverView',
                          'build',
                          'addFav'),
                    ),
                  if (hideText)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          shareQuestion();
                        });
                      },
                      icon: const Icon(Icons.ios_share),
                      tooltip: AppLocalization.instance.translate(
                          'lib.screen.common.questionOverView',
                          'build',
                          'shareQuestion'),
                    ),
                  if (!hideText)
                    Tooltip(
                      message: isFavorite
                          ? AppLocalization.instance.translate(
                          'lib.screen.common.questionOverView',
                          'build',
                          'removeFav')
                          : AppLocalization.instance.translate(
                          'lib.screen.common.questionOverView',
                          'build',
                          'addFav'),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            isFavorite = !isFavorite;
                            setIsMyFavorite();
                          });
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                        label: Text(
                          isFavorite
                              ? AppLocalization.instance.translate(
                              'lib.screen.common.questionOverView',
                              'build',
                              'removeFav')
                              : AppLocalization.instance.translate(
                              'lib.screen.common.questionOverView',
                              'build',
                              'addFav'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  if (!hideText)
                    Tooltip(
                      message: AppLocalization.instance.translate(
                          'lib.screen.common.questionOverView',
                          'build',
                          'shareQuestion'),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            shareQuestion();
                          });
                        },
                        icon: const Icon(Icons.ios_share),
                        label: Text(
                          AppLocalization.instance.translate(
                              'lib.screen.common.questionOverView',
                              'build',
                              'share'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('${AppLocalization.instance.translate(
              'lib.screen.common.questionOverView',
              'build',
              'error')}: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator(); // or any other loading indicator
        }
      },
    );
  }
}

class LikeCountWidget extends StatefulWidget {
  int likeCount = 0;
  AppRepositories appRepositories = AppRepositories();
  QuestionRepository questionRepository = QuestionRepository();
  final BigInt questionId;

  LikeCountWidget({Key? key, required this.questionId}) : super(key: key);

  @override
  _LikeCountWidgetState createState() => _LikeCountWidgetState();
}

class _LikeCountWidgetState extends State<LikeCountWidget> {
  Future<int> getTotalLikes() async {
    var getTotalLikesDataSet = await widget.questionRepository
        .getTotalLikes(['*'], widget.questionId, getNoSqlData: 0);

    widget.likeCount =
        getTotalLikesDataSet.firstValue('data', 'like_count', insteadOfNull: 0);

    return widget.likeCount;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: getTotalLikes(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.thumb_up,
                        color: Colors.yellow,
                      ),
                      Text('(${widget.likeCount} ${AppLocalization.instance.translate(
                          'lib.screen.common.questionOverView',
                          'build',
                          'likes')})'),
                    ],
                  ),
                ],
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('${AppLocalization.instance.translate(
              'lib.screen.common.questionOverView',
              'build',
              'error')}: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator(); // or any other loading indicator
        }
      },
    );
  }
}
