import 'package:egitimaxapplication/bloc/bloc/lecture/lectureBloc.dart';
import 'package:egitimaxapplication/bloc/state/lecture/lectureState.dart';
import 'package:egitimaxapplication/model/common/dataTableData.dart';
import 'package:egitimaxapplication/model/lecture/lecturePageModel.dart';
import 'package:egitimaxapplication/model/lecture/setLectureObjects.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/lecture/lectureRepository.dart';
import 'package:egitimaxapplication/screen/common/collapsibleItemBuilder.dart';
import 'package:egitimaxapplication/screen/common/commonDataTable.dart';
import 'package:egitimaxapplication/screen/common/commonDropdownButtonFormField.dart';
import 'package:egitimaxapplication/screen/common/commonTextFormField.dart';
import 'package:egitimaxapplication/screen/common/learnLevels.dart';
import 'package:egitimaxapplication/screen/common/questionDataTable.dart';
import 'package:egitimaxapplication/screen/common/questionOverView.dart';
import 'package:egitimaxapplication/screen/common/userInteractiveMessage.dart';
import 'package:egitimaxapplication/screen/common/videoDataTable.dart';
import 'package:egitimaxapplication/screen/common/videoOverView.dart';
import 'package:egitimaxapplication/screen/lecture/lectureObjectsSummary.dart';
import 'package:egitimaxapplication/screen/lecture/stepsValidator.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/constant/appConstant/generalAppConstant.dart';
import 'package:egitimaxapplication/utils/constant/language/appLocalizationConstant.dart';
import 'package:egitimaxapplication/utils/constant/router/heroTagConstant.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:egitimaxapplication/utils/widget/appBar/innerAppBar.dart';
import 'package:egitimaxapplication/utils/widget/layout/mainLayout.dart';
import 'package:egitimaxapplication/utils/widget/message/uIMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../bloc/event/lecture/lectureEvent.dart';

class LecturePage extends StatefulWidget {
  const LecturePage(
      {super.key,
      required this.userId,
      required this.isEditorMode,
      this.lectureId});

  final bool isEditorMode;
  final BigInt userId;
  final BigInt? lectureId;

  @override
  _LecturePageState createState() => _LecturePageState();
}

class _LecturePageState extends State<LecturePage> {
  int _activeCurrentStep = 0;
  late LectureBloc lectureBloc;
  late LecturePageModel lecturePageModel;
  LectureRepository lectureRepository = LectureRepository();
  AppRepositories appRepositories = AppRepositories();
  final componentTextStyle = const TextStyle(
      fontSize: 10,
      color: Colors.black,
      locale: AppLocalizationConstant.DefaultLocale);
  double? iconSize = 12;

  bool isWelcomeMsgCollapsed = false;
  bool isGoodbyeMsgCollapsed = false;

  List<Map<String, dynamic>>? selectedQuestionRows = List.empty(growable: true);
  List<Map<String, dynamic>>? selectedVideoRows = List.empty(growable: true);
  CommonDataTable? lectureFlowDataTable;

  @override
  void initState() {
    super.initState();

    lecturePageModel = LecturePageModel(
        userId: widget.userId,
        lectureId: widget.lectureId,
        isEditorMode: widget.isEditorMode);
    lectureBloc = LectureBloc();

    lectureBloc.add(InitEvent(lecturePageModel: lecturePageModel));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => lectureBloc,
      child: Scaffold(
        appBar: InnerAppBar(
          title: AppLocalization.instance.translate(
              'lib.screen.lecturePage.lecturePage', 'build', 'title'),
        ),
        body: BlocBuilder<LectureBloc, LectureState>(
          builder: (context, state) {
            if (state is InitState) {
              return _buildInit(context, state);
            } else if (state is LoadingState) {
              return _buildLoading(context, state);
            } else if (state is LoadedState) {
              return _buildLoaded(context, state);
            } else if (state is ErrorState) {
              return _buildError(context, state);
            } else if (state is LoadingStep1State) {
              return _buildLoadingStep1(context, state);
            } else if (state is LoadedStep1State) {
              return _buildLoadedStep1(context, state);
            } else if (state is ErrorStep1State) {
              return _buildErrorStep1(context, state);
            } else if (state is LoadingStep2State) {
              return _buildLoadingStep2(context, state);
            } else if (state is LoadedStep2State) {
              return _buildLoadedStep2(context, state);
            } else if (state is ErrorStep2State) {
              return _buildErrorStep2(context, state);
            } else if (state is LoadingStep3State) {
              return _buildLoadingStep3(context, state);
            } else if (state is LoadedStep3State) {
              return _buildLoadedStep3(context, state);
            } else if (state is ErrorStep3State) {
              return _buildErrorStep3(context, state);
            } else if (state is LoadingPmState) {
              return _buildLoadingPm(context, state);
            } else if (state is LoadedPmState) {
              return _buildLoadedPm(context, state);
            } else if (state is DeletingPmState) {
              return _buildDeletingPm(context, state);
            } else if (state is DeletedPmState) {
              return _buildDeletedPm(context, state);
            } else if (state is RemovingPmState) {
              return _buildRemovingPm(context, state);
            } else if (state is RemovedPmState) {
              return _buildRemovedPm(context, state);
            } else if (state is SavingPmState) {
              return _buildSavingPm(context, state);
            } else if (state is SavedPmState) {
              return _buildSavedPm(context, state);
            } else if (state is ErrorPmState) {
              return _buildErrorPm(context, state);
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  List<Step> lectureOperationsSteps(BuildContext context, LectureState state) {
    var vSteps = [
      Step(
        state: _activeCurrentStep <= 0 ? StepState.editing : StepState.indexed,
        isActive: _activeCurrentStep >= 0,
        title: Text(AppLocalization.instance.translate(
            'lib.screen.lecturePage.lecturePage',
            'lectureOperationsSteps',
            'lectureCreate')),
        subtitle: Text(AppLocalization.instance.translate(
            'lib.screen.lecturePage.lecturePage',
            'lectureOperationsSteps',
            'lectureCreateDetails')),
        //subtitle: const Text('Fill in the details'),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return getStepOneLayout(context);
              },
            ),
          ),
        ),
      ),
      Step(
        state: _activeCurrentStep <= 1 ? StepState.editing : StepState.indexed,
        isActive: _activeCurrentStep >= 1,
        title: Text(AppLocalization.instance.translate(
            'lib.screen.lecturePage.lecturePage',
            'lectureOperationsSteps',
            'createFlow')),
        subtitle: Text(AppLocalization.instance.translate(
            'lib.screen.lecturePage.lecturePage',
            'lectureOperationsSteps',
            'createFlowDetails')),
        //subtitle: const Text('Fill in the details'),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: FutureBuilder<Widget>(
            future: getStepTwoLayout(context),
            builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: snapshot.data ?? Container(),
                );
              } else if (snapshot.hasError) {
                return Text(
                    '${AppLocalization.instance.translate('lib.screen.lecturePage.lecturePage', 'lectureOperationsSteps', 'error')} ${snapshot.error}');
              } else {
                return const CircularProgressIndicator(); // or any other loading indicator
              }
            },
          ),
        ),
      ),
      Step(
        state: _activeCurrentStep <= 2 ? StepState.editing : StepState.indexed,
        isActive: _activeCurrentStep >= 2,
        title: Text(AppLocalization.instance.translate(
            'lib.screen.lecturePage.lecturePage',
            'lectureOperationsSteps',
            'summaryAndSubmit')),
        subtitle: Text(AppLocalization.instance.translate(
            'lib.screen.lecturePage.lecturePage',
            'lectureOperationsSteps',
            'summaryAndSubmitDetails')),
        //subtitle: const Text('Please check and submit !'),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: FutureBuilder<Widget>(
            future: getStepThreeLayout(context),
            builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: snapshot.data ?? Container(),
                );
              } else if (snapshot.hasError) {
                return Text(
                    '${AppLocalization.instance.translate('lib.screen.lecturePage.lecturePage', 'lectureOperationsSteps', 'error')} ${snapshot.error}');
              } else {
                return const CircularProgressIndicator(); // or any other loading indicator
              }
            },
          ),
        ),
      ),
    ];
    return vSteps;
  }

  Widget getStepOneLayout(BuildContext context) {
    final TextEditingController lectureTitleController = TextEditingController(
        text:
            lecturePageModel.setLectureObjects!.tblCrsCourseMain!.title ?? '');
    final TextEditingController lectureDescriptionController =
        TextEditingController(
            text: lecturePageModel
                    .setLectureObjects!.tblCrsCourseMain!.description ??
                '');

    final TextEditingController welcomeMsgTextController =
        TextEditingController(
            text: lecturePageModel
                    .setLectureObjects!.tblCrsCourseMain!.welcomeMsg ??
                '');
    final TextEditingController goodbyeMsgTextController =
        TextEditingController(
            text: lecturePageModel
                    .setLectureObjects!.tblCrsCourseMain!.goodbyeMsg ??
                '');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: WrapAlignment.start,
        runSpacing: 10,
        spacing: 10,
        children: [
          CommonDropdownButtonFormField(
            label: AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                'getStepOneLayout',
                'academicYear'),
            componentTextStyle: componentTextStyle,
            items: lecturePageModel.academicYears,
            selectedItem: lecturePageModel
                .setLectureObjects!.tblCrsCourseMain!.academicYear,
            onSelectedItemChanged: (selectedAcademicYear) {
              lecturePageModel.setLectureObjects!.tblCrsCourseMain!
                  .academicYear = selectedAcademicYear;
            },
          ),
          CommonTextFormField(
            directionText: AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                'getStepOneLayout',
                'titleDirectionText'),
            controller: lectureTitleController,
            labelText: AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                'getStepOneLayout',
                'title'),
            maxLines: 1,
            minLines: 1,
            onChanged: (text) {
              lecturePageModel.setLectureObjects!.tblCrsCourseMain!.title =
                  text;
            },
          ),
          CommonTextFormField(
            directionText: AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                'getStepOneLayout',
                'descriptionsDirectionText'),
            controller: lectureDescriptionController,
            labelText: AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                'getStepOneLayout',
                'descriptions'),
            maxLines: 3,
            minLines: 1,
            onChanged: (text) {
              lecturePageModel
                  .setLectureObjects!.tblCrsCourseMain!.description = text;
            },
          ),
          CommonDropdownButtonFormField(
            label: AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                'getStepOneLayout',
                'branch'),
            componentTextStyle: componentTextStyle,
            items: lecturePageModel.branches,
            selectedItem:
                lecturePageModel.setLectureObjects!.tblCrsCourseMain!.branchId,
            onSelectedItemChanged: (selectedGrade) {
              setState(() {
                lecturePageModel.setLectureObjects!.tblCrsCourseMain!.branchId =
                    selectedGrade;
                lecturePageModel.setLectureObjects!.tblCrsCourseMain!.learnId =
                    null;
              });
            },
          ),
          CommonDropdownButtonFormField(
            label: AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                'getStepOneLayout',
                'grade'),
            componentTextStyle: componentTextStyle,
            items: lecturePageModel.grades,
            selectedItem:
                lecturePageModel.setLectureObjects!.tblCrsCourseMain!.gradeId,
            onSelectedItemChanged: (selectedGrade) {
              setState(() {
                lecturePageModel.setLectureObjects!.tblCrsCourseMain!.gradeId =
                    selectedGrade;
                lecturePageModel.setLectureObjects!.tblCrsCourseMain!.learnId =
                    null;
              });
            },
          ),
          if (lecturePageModel.setLectureObjects!.tblCrsCourseMain!.branchId !=
                  0 &&
              lecturePageModel.setLectureObjects!.tblCrsCourseMain!.gradeId !=
                  0 &&
              lecturePageModel.setLectureObjects!.tblCrsCourseMain!.gradeId !=
                  null &&
              lecturePageModel.setLectureObjects!.tblCrsCourseMain!.branchId !=
                  null)
            LearnLevels(
                learnId: lecturePageModel
                    .setLectureObjects!.tblCrsCourseMain!.learnId,
                branchId: lecturePageModel
                    .setLectureObjects!.tblCrsCourseMain!.branchId,
                gradeId: lecturePageModel
                    .setLectureObjects!.tblCrsCourseMain!.gradeId,
                countryId: lecturePageModel
                    .setLectureObjects!.tblCrsCourseMain!.country,
                showAchievements: false,
                onChangedLearnId: (selectedLearnId) {
                  lecturePageModel.setLectureObjects!.tblCrsCourseMain!
                      .learnId = selectedLearnId;
                  setState(() {});
                },
                onChangedSelectedAchievements: (selectedAchievements) {},
                onChangedAchievements: (achievements) {},
                selectedAchievements: const {},
                componentTextStyle: componentTextStyle),
          CollapsibleItemBuilder(
              items: [
                CollapsibleItemData(
                    isExpanded: isWelcomeMsgCollapsed,
                    header: Text(AppLocalization.instance.translate(
                        'lib.screen.lecturePage.lecturePage',
                        'getStepOneLayout',
                        'clickWelcomeAndGoodByMsg')),
                    content: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          CommonTextFormField(
                            directionText: AppLocalization.instance.translate(
                                'lib.screen.lecturePage.lecturePage',
                                'getStepOneLayout',
                                'welcomeMsgDirectionText'),
                            controller: welcomeMsgTextController,
                            labelText: AppLocalization.instance.translate(
                                'lib.screen.lecturePage.lecturePage',
                                'getStepOneLayout',
                                'welcomeMsg'),
                            maxLines: null,
                            minLines: 1,
                            onChanged: (text) {
                              lecturePageModel.setLectureObjects!.tblCrsCourseMain!
                                  .welcomeMsg = text;
                            },
                          ),
                          const SizedBox(height: 10,),
                          CommonTextFormField(
                            directionText: AppLocalization.instance.translate(
                                'lib.screen.lecturePage.lecturePage',
                                'getStepOneLayout',
                                'goodbyeMsgDirectionText'),
                            controller: goodbyeMsgTextController,
                            labelText: AppLocalization.instance.translate(
                                'lib.screen.lecturePage.lecturePage',
                                'getStepOneLayout',
                                'goodbyeMsg'),
                            maxLines: null,
                            minLines: 1,
                            onChanged: (text) {
                              lecturePageModel.setLectureObjects!.tblCrsCourseMain!
                                  .goodbyeMsg = text;

                            },
                          ),

                        ],
                      ),
                    ),
                    padding: 0,
                    onStateChanged: (value) {
                      isWelcomeMsgCollapsed = !isWelcomeMsgCollapsed;
                    }),
              ],
              padding: 0,
              onStateChanged: (value) {
                isWelcomeMsgCollapsed = !isWelcomeMsgCollapsed;
              }),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Checkbox(
                      value: lecturePageModel.setLectureObjects!
                                  .tblCrsCourseMain!.isPublic ==
                              1
                          ? true
                          : false,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            lecturePageModel.setLectureObjects!
                                .tblCrsCourseMain!.isPublic = 1;
                          } else {
                            lecturePageModel.setLectureObjects!
                                .tblCrsCourseMain!.isPublic = 0;
                          }
                        });
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (lecturePageModel.setLectureObjects!
                                  .tblCrsCourseMain!.isPublic ==
                              1) {
                            lecturePageModel.setLectureObjects!
                                .tblCrsCourseMain!.isPublic = 0;
                          } else {
                            lecturePageModel.setLectureObjects!
                                .tblCrsCourseMain!.isPublic = 1;
                          }
                        });
                      },
                      child: Text(AppLocalization.instance.translate(
                          'lib.screen.lecturePage.lecturePage',
                          'getStepOneLayout',
                          'canEveryoneSeeTheLecture')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Widget> getStepTwoLayout(BuildContext context) async {
    final theme = Theme.of(context);

    var flows =
        lecturePageModel.setLectureObjects?.tblCrsCourseMain!.tblCrsCourseFlows;

    if (flows!.length > 1) {
      flows = flows.where((element) => element.orderNo != 0).toList();
    }

    flows.sort((a, b) => a.orderNo!.compareTo(b.orderNo!));

    List<Map<Map<String, String>, Widget>>? dataTableRows =
        List.empty(growable: true);
    if (flows != null && flows.isNotEmpty) {
      for (var flow in flows) {
        if (flow.orderNo != 0 ||
            (flow.orderNo == 0 &&
                flows.length == 1)) // Default Kayıt Filtrelendi
        {
          Map<Map<String, String>, Widget> cells = {};

          Map<String, String> key0 = {};
          key0['id'] = flow.id.toString();
          cells[key0] = Text(flow.id.toString());

          Map<String, String> key1 = {};
          key1['course_id'] = flow.courseId.toString();
          cells[key1] = Text(flow.courseId.toString());

          Map<String, String> key2 = {};
          key2['order_no'] = flow.orderNo.toString();
          cells[key2] = Text(flow.orderNo.toString());

          if (flow.videoId != null && flow.videoId != BigInt.parse('0')) {
            Map<String, String> key3 = {};
            key3['flow_id'] = flow.videoId.toString();
            cells[key3] = Text(flow.videoId.toString());

            var tblVidVideoMainDataSet = await appRepositories.tblVidVideoMain(
                'Lecture/GetObject', ['id', 'title', 'description'],
                id: flow.videoId, getNoSqlData: 0);
            var videoTitle = tblVidVideoMainDataSet.firstValue('data', 'title',
                insteadOfNull: '');
            Map<String, String> key3_1 = {};
            key3_1['flow_item'] = videoTitle;
            cells[key3_1] = TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return VideoOverView(
                      videoId: flow.videoId ?? BigInt.parse('0'),
                      userId: widget.userId,
                    );
                  },
                );
              },
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(
                      fontSize: theme.dataTableTheme.dataTextStyle?.fontSize),
                ),
              ),
              child: Tooltip(
                message: videoTitle ?? "",
                child: Wrap(
                  children: [
                    Text(
                      videoTitle != null && videoTitle.length > 20
                          ? "${videoTitle.substring(0, 20)}..."
                          : videoTitle ?? "",
                    ),
                  ],
                ),
              ),
            );

            Map<String, String> key3_2 = {};
            key3_2['flow_type'] = 'Video';
            cells[key3_2] = Text(AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                'getStepTwoLayout',
                'flowItemTypeVideo'));

            var achievementTree = '';
            for (var item in selectedVideoRows!.toList()) {
              if (item['id'] == flow.videoId.toString()) {
                achievementTree = item['achievementTree'];

                var reversedAchievementTree =
                    achievementTree.split('>>').toList();

                List<String> reversedAchievementTreeNew = [];
                reversedAchievementTree.forEach((achievement) {
                  List<String> parts = achievement.split(":");
                  if (parts.length > 1) {
                    reversedAchievementTreeNew.add(parts[1]);
                  }
                });

                var reversedString =
                    reversedAchievementTreeNew.reversed.toList().join('>>');
                achievementTree = reversedString;
              }
            }

            if(achievementTree=='' || achievementTree==null)
              {

                List<String> achievementTreeList=List.empty(growable: true);

                var learnIdDataSet=await appRepositories.tblVidVideoMain('Lecture/GetObject', ['id','subdom_id'],id:flow.videoId ,getNoSqlData: 0);


                var libType = {
                  "ct_dom": AppLocalization.instance
                      .translate('lib.screen.lecture.lectureObjectsSummary', 'prepareWidget', 'domain'),
                  "ct_subdom": AppLocalization.instance
                      .translate('lib.screen.lecture.lectureObjectsSummary', 'prepareWidget', 'subdomain'),
                  "ct_achv": AppLocalization.instance
                      .translate('lib.screen.lecture.lectureObjectsSummary', 'prepareWidget', 'achievement'),
                  "ct_subject": AppLocalization.instance
                      .translate('lib.screen.lecture.lectureObjectsSummary', 'prepareWidget', 'subject')
                };

                var getLearnLevelsDataSet = await appRepositories.getLearnInfoById(
                    'Lecture/GetObject', ['*'],
                    learn_id: learnIdDataSet.firstValue('data', 'subdom_id',insteadOfNull: 0));
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

                for (var item in learnLevelsKeyValuePairs.entries.toList().reversed.toList()) {

                  if(item.key!='ct_achv')
                  {
                    achievementTreeList.add(item.value);
                  }
                }

                achievementTree=achievementTreeList.join('>>');
              }

            Map<String, String> key3_3 = {};
            key3_3['flow_achievement_tree'] = achievementTree;
            cells[key3_3] = Text(achievementTree);



            var videoAchvIdDataSet = await appRepositories.tblVidVideoAchvMap(
                'Lecture/GetObject', ['id', 'video_id', 'achv_id'],
                video_id: flow.videoId);
            var videoAchvId = videoAchvIdDataSet.firstValue('data', 'achv_id');

            var getAchievementsDataSet = await appRepositories.getLearnInfoById(
                'Lecture/GetObject', ['levels'],
                learn_id: videoAchvId, getNoSqlData: 0);
            String? getAchievements =
                getAchievementsDataSet.firstValue('data', 'levels',insteadOfNull: '');

            getAchievements??='';
            getAchievements=getAchievements?.split('|').first ?? '';
            var lectureLearnIdAsString = lecturePageModel.setLectureObjects?.tblCrsCourseMain?.learnId.toString();
            lectureLearnIdAsString??='???';
            bool isCompatibleLectureLearnId=false;
            if (getAchievements.contains(lectureLearnIdAsString)) {
              isCompatibleLectureLearnId=true;

            }

            Map<String, String> key3_4 = {};
            key3_4['compatibleLectureAchievement'] = isCompatibleLectureLearnId ? 'Yes' :'No';
            cells[key3_4] = Text(isCompatibleLectureLearnId ? AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage', 'getStepTwoLayout', 'yes') :AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage', 'getStepTwoLayout', 'no'),style: TextStyle(color:  isCompatibleLectureLearnId ? Colors.green: Colors.red));

          } else if (flow.quizId != null && flow.quizId != BigInt.parse('0')) {
            Map<String, String> key4 = {};
            key4['flow_id'] = flow.quizId.toString();
            cells[key4] = Text(flow.quizId.toString());

            var tblQuizMainDataSet = await appRepositories.tblQuizMain(
                'Lecture/GetObject', ['id', 'title', 'description'],
                id: flow.quizId, getNoSqlData: 0);
            var quizTitle = tblQuizMainDataSet.firstValue('data', 'title',
                insteadOfNull: '');
            Map<String, String> key4_1 = {};
            key4_1['flow_item'] = quizTitle;
            cells[key4_1] = Text(quizTitle);

            Map<String, String> key4_2 = {};
            key4_2['flow_type'] = 'Quiz';
            cells[key4_2] = Text(AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                'getStepTwoLayout',
                'flowItemTypeQuiz'));

            var achievementTree = '';
            Map<String, String> key4_3 = {};
            key4_3['flow_achievement_tree'] = achievementTree;
            cells[key4_3] = Text(achievementTree);

            Map<String, String> key4_4 = {};
            key4_4['compatibleLectureAchievement'] ='No';
            cells[key4_4] = Text(AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage', 'getStepTwoLayout', 'no'),style: TextStyle(color: Colors.red));

          } else if (flow.docId != null && flow.docId != BigInt.parse('0')) {
            Map<String, String> key5 = {};
            key5['flow_id'] = flow.docId.toString();
            cells[key5] = Text(flow.docId.toString());

            var tblCrsCourseDocDataSet = await appRepositories.tblCrsCourseDoc(
                'Lecture/GetObject', ['id', 'description'],
                id: flow.docId, getNoSqlData: 0);
            var docTitle = tblCrsCourseDocDataSet
                .firstValue('data', 'description', insteadOfNull: '');
            Map<String, String> key5_1 = {};
            key5_1['flow_item'] = docTitle;
            cells[key5_1] = Text(docTitle);

            Map<String, String> key5_2 = {};
            key5_2['flow_type'] = 'Document';
            cells[key5_2] = Text(AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                'getStepTwoLayout',
                'flowItemTypeDocument'));

            var achievementTree = '';
            Map<String, String> key5_3 = {};
            key5_3['flow_achievement_tree'] = achievementTree;
            cells[key5_3] = Text(achievementTree);

            Map<String, String> key5_4 = {};
            key5_4['compatibleLectureAchievement'] ='No';
            cells[key5_4] = Text(AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage', 'getStepTwoLayout', 'no'),style: TextStyle(color: Colors.red),);

          } else if (flow.questId != null &&
              flow.questId != BigInt.parse('0')) {
            Map<String, String> key6 = {};
            key6['flow_id'] = flow.questId.toString();
            cells[key6] = Text(flow.questId.toString());

            var tblQueQuestionMainDataSet =
                await appRepositories.tblQueQuestionMain(
                    'Lecture/GetObject', ['id', 'question_text'],
                    id: flow.questId, getNoSqlData: 0);
            var questionTitle = tblQueQuestionMainDataSet
                .firstValue('data', 'question_text', insteadOfNull: '');
            Map<String, String> key6_1 = {};
            key6_1['flow_item'] = questionTitle;
            cells[key6_1] = TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return QuestionOverView(
                      questionId: flow.questId ?? BigInt.parse('0'),
                      userId: widget.userId,
                    );
                  },
                );
              },
              style: ButtonStyle(
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(
                      fontSize: theme.dataTableTheme.dataTextStyle?.fontSize),
                ),
              ),
              child: Tooltip(
                message: questionTitle ?? "",
                child: Wrap(
                  children: [
                    Text(
                      questionTitle != null && questionTitle.length > 20
                          ? "${questionTitle.substring(0, 20)}..."
                          : questionTitle ?? "",
                    ),
                  ],
                ),
              ),
            );

            Map<String, String> key6_2 = {};
            key6_2['flow_type'] = 'Question';
            cells[key6_2] = Text(AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                'getStepTwoLayout',
                'flowItemTypeQuestion'));

            var achievementTree = '';
            for (var item in selectedQuestionRows!.toList()) {
              if (item['id'] == flow.questId.toString()) {
                achievementTree = item['achievementTree'];

                var reversedAchievementTree =
                    achievementTree.split('>>').toList();

                List<String> reversedAchievementTreeNew = [];
                reversedAchievementTree.forEach((achievement) {
                  List<String> parts = achievement.split(":");
                  if (parts.length > 1) {
                    reversedAchievementTreeNew.add(parts[1]);
                  }
                });

                var reversedString =
                    reversedAchievementTreeNew.reversed.toList().join('>>');
                achievementTree = reversedString;
              }
            }

            if(achievementTree=='' || achievementTree==null)
            {

              List<String> achievementTreeList=List.empty(growable: true);

              var learnIdDataSet=await appRepositories.tblQueQuestionMain('Lecture/GetObject', ['id','subdom_id'],id:flow.questId ,getNoSqlData: 0);


              var libType = {
                "ct_dom": AppLocalization.instance
                    .translate('lib.screen.lecture.lectureObjectsSummary', 'prepareWidget', 'domain'),
                "ct_subdom": AppLocalization.instance
                    .translate('lib.screen.lecture.lectureObjectsSummary', 'prepareWidget', 'subdomain'),
                "ct_achv": AppLocalization.instance
                    .translate('lib.screen.lecture.lectureObjectsSummary', 'prepareWidget', 'achievement'),
                "ct_subject": AppLocalization.instance
                    .translate('lib.screen.lecture.lectureObjectsSummary', 'prepareWidget', 'subject')
              };

              var getLearnLevelsDataSet = await appRepositories.getLearnInfoById(
                  'Lecture/GetObject', ['*'],
                  learn_id: learnIdDataSet.firstValue('data', 'subdom_id',insteadOfNull: 0));
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

              for (var item in learnLevelsKeyValuePairs.entries.toList().reversed.toList()) {

                if(item.key!='ct_achv')
                {
                  achievementTreeList.add(item.value);
                }
              }

              achievementTree=achievementTreeList.join('>>');
            }

            Map<String, String> key6_3 = {};
            key6_3['flow_achievement_tree'] = achievementTree;
            cells[key6_3] = Text(achievementTree);

            var questionAchvIdDataSet = await appRepositories.tblQueQuestAchvMap(
                'Lecture/GetObject', ['id', 'quest_id', 'achv_id'],
                quest_id: flow.questId);
            var questionAchvId = questionAchvIdDataSet.firstValue('data', 'achv_id');

            var getAchievementsDataSet = await appRepositories.getLearnInfoById(
                'Lecture/GetObject', ['levels'],
                learn_id: questionAchvId, getNoSqlData: 0);
            String? getAchievements =
            getAchievementsDataSet.firstValue('data', 'levels',insteadOfNull: '');

            getAchievements??='';
            getAchievements=getAchievements?.split('|').first ?? '';
            var lectureLearnIdAsString = lecturePageModel.setLectureObjects?.tblCrsCourseMain?.learnId.toString();
            lectureLearnIdAsString??='???';
            bool isCompatibleLectureLearnId=false;
            if (getAchievements.contains(lectureLearnIdAsString)) {
              isCompatibleLectureLearnId=true;

            }

            Map<String, String> key6_4 = {};
            key6_4['compatibleLectureAchievement'] = isCompatibleLectureLearnId ? 'Yes' :'No';
            cells[key6_4] = Text(isCompatibleLectureLearnId ? AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage', 'getStepTwoLayout', 'yes') :AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage', 'getStepTwoLayout', 'no'),style: TextStyle(color:  isCompatibleLectureLearnId ? Colors.green: Colors.red));
          } else {
            Map<String, String> key7 = {};
            key7['flow_id'] = '0';
            cells[key7] = const Text('0');

            Map<String, String> key7_1 = {};
            key7_1['flow_item'] = 'NoItem';
            cells[key7_1] = Text(AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                'getStepTwoLayout',
                'flowItemTypeNoItem'));

            Map<String, String> key7_2 = {};
            key7_2['flow_type'] = 'NoItem';
            cells[key7_2] = Text(AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                'getStepTwoLayout',
                'flowItemTypeNoItem'));

            var achievementTree = '';
            Map<String, String> key7_3 = {};
            key7_3['flow_achievement_tree'] = achievementTree;
            cells[key7_3] = Text(achievementTree);

            Map<String, String> key7_4 = {};
            key7_4['compatibleLectureAchievement'] ='No';
            cells[key7_4] = Text(AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage', 'getStepTwoLayout', 'no'),style: TextStyle(color: Colors.red));
          }

          Map<String, String> key8 = {};
          key8['is_active'] = flow.isActive.toString();
          cells[key8] = Text(flow.isActive.toString());

          Map<String, String> key9 = {};
          key9['actions'] = 'actions';
          cells[key9] = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PopupMenuButton<String>(
                  padding: const EdgeInsets.all(3.0),
                  itemBuilder: (BuildContext context) => [
                        if (flow.orderNo != 1 && flow.orderNo != 0)
                          PopupMenuItem<String>(
                            padding: const EdgeInsets.all(3.0),
                            value: 'move_up',
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_upward, size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  AppLocalization.instance.translate(
                                      'lib.screen.lecturePage.lecturePage',
                                      'getStepTwoLayout',
                                      'moveUp'),
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        if (flows!
                                    .where((element) => element.orderNo != 0)
                                    .length !=
                                flow.orderNo &&
                            flow.orderNo != 0)
                          PopupMenuItem<String>(
                            padding: const EdgeInsets.all(3.0),
                            value: 'move_down',
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_downward, size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  AppLocalization.instance.translate(
                                      'lib.screen.lecturePage.lecturePage',
                                      'getStepTwoLayout',
                                      'moveDown'),
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          if(flow.orderNo!=0)
                          PopupMenuItem<String>(
                            padding: const EdgeInsets.all(3.0),
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  AppLocalization.instance.translate(
                                      'lib.screen.lecturePage.lecturePage',
                                      'getStepTwoLayout',
                                      'delete'),
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                      ],
                  onSelected: (String? value) {
                    if (value == 'move_up') {
                      if (flow.orderNo != 1) {
                        int currentOrder = flow.orderNo ?? 0;

                        var replacedElement = lecturePageModel.setLectureObjects
                            ?.tblCrsCourseMain!.tblCrsCourseFlows!
                            .where((element) =>
                                element.orderNo == (currentOrder - 1))
                            .first;

                        lecturePageModel.setLectureObjects?.tblCrsCourseMain!
                            .tblCrsCourseFlows!
                            .removeWhere((element) =>
                                element.orderNo == (currentOrder - 1));

                        lecturePageModel.setLectureObjects?.tblCrsCourseMain!
                            .tblCrsCourseFlows!
                            .where((element) => element.orderNo == flow.orderNo)
                            .first
                            .updateOrderNo((currentOrder - 1));

                        if (replacedElement != null) {
                          replacedElement?.orderNo = currentOrder;

                          lecturePageModel.setLectureObjects?.tblCrsCourseMain!
                              .tblCrsCourseFlows!
                              .add(replacedElement!);
                        }

                        setState(() {});
                      }
                    } else if (value == 'move_down') {
                      if (flow.orderNo != flows!.length) {
                        int currentOrder = flow.orderNo ?? 0;

                        var replacedElement = lecturePageModel.setLectureObjects
                            ?.tblCrsCourseMain!.tblCrsCourseFlows!
                            .where((element) =>
                                element.orderNo == (currentOrder + 1))
                            .first;

                        lecturePageModel.setLectureObjects?.tblCrsCourseMain!
                            .tblCrsCourseFlows!
                            .removeWhere((element) =>
                                element.orderNo == (currentOrder + 1));

                        lecturePageModel.setLectureObjects?.tblCrsCourseMain!
                            .tblCrsCourseFlows!
                            .where((element) => element.orderNo == flow.orderNo)
                            .first
                            .updateOrderNo((currentOrder + 1));

                        if (replacedElement != null) {
                          replacedElement?.orderNo = currentOrder;

                          lecturePageModel.setLectureObjects?.tblCrsCourseMain!
                              .tblCrsCourseFlows!
                              .add(replacedElement!);
                        }
                        setState(() {});
                      }
                    } else if (value == 'delete') {
                      lecturePageModel.setLectureObjects?.tblCrsCourseMain!
                          .tblCrsCourseFlows!
                          .removeWhere(
                              (element) => element.orderNo == flow.orderNo);

                      lecturePageModel.setLectureObjects?.tblCrsCourseMain!
                          .tblCrsCourseFlows!
                          .where((item) =>
                              item.orderNo != 0) // remove orderno=0 dumy record
                          .toList()
                          .sort((a, b) => a.orderNo!.compareTo(
                              b.orderNo!)); // remove orderno=0 dumy record

                      int newOrder = 1;
                      lecturePageModel.setLectureObjects?.tblCrsCourseMain!
                          .tblCrsCourseFlows!
                          .where((item) =>
                              item.orderNo != 0) // remove orderno=0 dumy record
                          .toList()
                          .forEach((element) {
                        element.orderNo = newOrder;
                        newOrder++;
                      });

                      setState(() {});
                    }
                  },
                  child: Row(
                    children: [
                      Text(
                        flow.orderNo != 0
                            ? AppLocalization.instance.translate(
                                'lib.screen.lecturePage.lecturePage',
                                'getStepTwoLayout',
                                'selectAction')
                            : 'No Available Action',
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 10),
                      ),
                      const SizedBox(width: 5.0),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  )),
            ],
          );

          dataTableRows.add(cells);
        } else {}
      }
    } else {}

    var toolBarButtons = [
      IconButton(
        onPressed: () {
          var totalQuestion = lecturePageModel
                  .setLectureObjects?.tblCrsCourseMain!.tblCrsCourseFlows!
                  .where((element) =>
                      element.questId! > BigInt.parse('0') &&
                      element.questId != null)
                  .length ??
              0;
          if (totalQuestion < 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MainLayout(
                    context: context,
                    loadedStateContainer: QuestionDataTable(
                      branchId: lecturePageModel
                          .setLectureObjects?.tblCrsCourseMain!.branchId,
                      gradeId: lecturePageModel
                          .setLectureObjects?.tblCrsCourseMain!.gradeId,
                      learnId: lecturePageModel
                          .setLectureObjects?.tblCrsCourseMain!.learnId,
                      userId: widget.userId,
                      componentTextStyle: componentTextStyle,
                      selectedQuestionIds: List.empty(growable: true),
                      onSelectedRowsChanged: (selectedRows, selectedKeys) {
                        selectedQuestionRows = selectedRows;
                      },
                      onSelectedQuestionIdsChanged:
                          (List<BigInt>? selectedQuestionIds) {
                        var flows = lecturePageModel.setLectureObjects
                            ?.tblCrsCourseMain!.tblCrsCourseFlows;

                        if (flows == null || flows!.isEmpty) {
                          lecturePageModel.setLectureObjects?.tblCrsCourseMain!
                              .tblCrsCourseFlows = List.empty(growable: true);
                        }

                        if (selectedQuestionIds != null) {
                          //Rule in constant
                          List<BigInt> firstThreeIds = selectedQuestionIds
                                      .length >
                                  (GeneralAppConstant
                                          .LectureMaxQuestionQuantity -
                                      totalQuestion)
                              ? selectedQuestionIds.sublist(
                                  0,
                                  ((((GeneralAppConstant
                                                  .LectureMaxQuestionQuantity ??
                                              1) -
                                          totalQuestion) -
                                      1)))
                              : selectedQuestionIds.toList();

                          selectedQuestionIds = firstThreeIds;

                          for (var question in selectedQuestionIds) {
                            BigInt id = BigInt.parse('0');
                            BigInt? courseId = lecturePageModel
                                        .setLectureObjects?.tblCrsCourseMain !=
                                    null
                                ? lecturePageModel
                                    .setLectureObjects?.tblCrsCourseMain!.id
                                : BigInt.parse('0');
                            int? orderNo = lecturePageModel.setLectureObjects
                                        ?.tblCrsCourseMain!.tblCrsCourseFlows !=
                                    null
                                ? (lecturePageModel
                                            .setLectureObjects
                                            ?.tblCrsCourseMain!
                                            .tblCrsCourseFlows!
                                            .where((element) =>
                                                element.orderNo != 0)
                                            .length ??
                                        0) +
                                    1
                                : 1;
                            BigInt? videoId = BigInt.parse('0');
                            BigInt? quizId = BigInt.parse('0');
                            BigInt? docId = BigInt.parse('0');
                            BigInt? questId = question;
                            int? isActive = 0;

                            bool isExistQuestion = false;

                            if (flows != null) {
                              if (flows!
                                  .where(
                                      (element) => element.questId == questId)
                                  .isNotEmpty) {
                                isExistQuestion = true;
                              }
                            }

                            if (!isExistQuestion) {
                              lecturePageModel.setLectureObjects
                                  ?.tblCrsCourseMain!.tblCrsCourseFlows!
                                  .add(TblCrsCourseFlow(
                                      id: id,
                                      courseId: courseId,
                                      orderNo: orderNo,
                                      videoId: videoId,
                                      quizId: quizId,
                                      docId: docId,
                                      questId: questId,
                                      isActive: isActive));
                            }
                          }
                        }

                        setState(() {});
                      },
                    )),
                settings: const RouteSettings(
                    name: HeroTagConstant
                        .questionSelector), // use the route name as the Hero tag
              ),
            );
          } else {
            UIMessage.showMessage(context,
                '${AppLocalization.instance.translate('lib.screen.lecturePage.lecturePage', 'getStepTwoLayout', 'maximumQuestionAdded')} [${GeneralAppConstant.LectureMaxQuestionQuantity.toString()}]');
          }
        },
        icon: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.add),
            const SizedBox(width: 3),
            // Adjust the spacing between the icon and text
            Text(AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                'getStepTwoLayout',
                'addQuestion')),
          ],
        ),
        tooltip: AppLocalization.instance.translate(
            'lib.screen.lecturePage.lecturePage',
            'getStepTwoLayout',
            'addQuestion'),
      ),
      IconButton(
        onPressed: () {
          var totalVideo = lecturePageModel
                  .setLectureObjects?.tblCrsCourseMain!.tblCrsCourseFlows!
                  .where((element) =>
                      element.videoId! > BigInt.parse('0') &&
                      element.videoId != null)
                  .length ??
              0;
          if (totalVideo < 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MainLayout(
                    context: context,
                    loadedStateContainer: VideoDataTable(
                      branchId: lecturePageModel
                          .setLectureObjects?.tblCrsCourseMain!.branchId,
                      gradeId: lecturePageModel
                          .setLectureObjects?.tblCrsCourseMain!.gradeId,
                      learnId: lecturePageModel
                          .setLectureObjects?.tblCrsCourseMain!.learnId,
                      userId: widget.userId,
                      componentTextStyle: componentTextStyle,
                      selectedVideoIds: List.empty(growable: true),
                      onSelectedRowsChanged: (selectedRows, selectedKeys) {
                        selectedVideoRows = selectedRows;
                      },
                      onSelectedVideoIdsChanged:
                          (List<BigInt>? selectedVideoIds) {
                        var flows = lecturePageModel.setLectureObjects
                            ?.tblCrsCourseMain!.tblCrsCourseFlows;

                        if (flows == null || flows!.isEmpty) {
                          lecturePageModel.setLectureObjects?.tblCrsCourseMain!
                              .tblCrsCourseFlows = List.empty(growable: true);
                        }

                        if (selectedVideoIds != null) {
                          //Rule in constant
                          List<BigInt> firstThreeIds = selectedVideoIds.length >
                                  (GeneralAppConstant.LectureMaxVideoQuantity -
                                      totalVideo)
                              ? selectedVideoIds.sublist(
                                  0,
                                  ((((GeneralAppConstant
                                                  .LectureMaxVideoQuantity ??
                                              1) -
                                          totalVideo) -
                                      1)))
                              : selectedVideoIds.toList();

                          selectedVideoIds = firstThreeIds;

                          for (var idVideo in selectedVideoIds) {
                            BigInt id = BigInt.parse('0');
                            BigInt? courseId = lecturePageModel
                                        .setLectureObjects?.tblCrsCourseMain !=
                                    null
                                ? lecturePageModel
                                    .setLectureObjects?.tblCrsCourseMain!.id
                                : BigInt.parse('0');
                            int? orderNo = lecturePageModel.setLectureObjects
                                        ?.tblCrsCourseMain!.tblCrsCourseFlows !=
                                    null
                                ? (lecturePageModel
                                            .setLectureObjects
                                            ?.tblCrsCourseMain!
                                            .tblCrsCourseFlows!
                                            .where((element) =>
                                                element.orderNo != 0)
                                            .length ??
                                        0) +
                                    1
                                : 1;
                            BigInt? videoId = idVideo;
                            BigInt? quizId = BigInt.parse('0');
                            BigInt? docId = BigInt.parse('0');
                            BigInt? questId = BigInt.parse('0');
                            int? isActive = 0;

                            bool isExistQuestion = false;

                            if (flows != null) {
                              if (flows!
                                  .where(
                                      (element) => element.videoId == idVideo)
                                  .isNotEmpty) {
                                isExistQuestion = true;
                              }
                            }

                            if (!isExistQuestion) {
                              lecturePageModel.setLectureObjects
                                  ?.tblCrsCourseMain!.tblCrsCourseFlows!
                                  .add(TblCrsCourseFlow(
                                      id: id,
                                      courseId: courseId,
                                      orderNo: orderNo,
                                      videoId: videoId,
                                      quizId: quizId,
                                      docId: docId,
                                      questId: questId,
                                      isActive: isActive));
                            }
                          }
                        }

                        setState(() {});
                      },
                    )),
                settings: const RouteSettings(
                    name: HeroTagConstant
                        .videoSelector), // use the route name as the Hero tag
              ),
            );
          } else {
            UIMessage.showMessage(context,
                '${AppLocalization.instance.translate('lib.screen.lecturePage.lecturePage', 'getStepTwoLayout', 'maximumVideoAdded')} [${GeneralAppConstant.LectureMaxVideoQuantity.toString()}]');
          }
        },
        icon: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.add),
            const SizedBox(width: 3),
            // Adjust the spacing between the icon and text
            Text(AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                'getStepTwoLayout',
                'addVideo')),
          ],
        ),
        tooltip: AppLocalization.instance.translate(
            'lib.screen.lecturePage.lecturePage',
            'getStepTwoLayout',
            'addVideo'),
      ),
      IconButton(
        onPressed: () {
          lecturePageModel
              .setLectureObjects?.tblCrsCourseMain!.tblCrsCourseFlows!.removeWhere((element) => element.orderNo!=0);
          setState(() {

          });
        },
        icon: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(Icons.delete_forever_outlined),
            const SizedBox(width: 3),
            // Adjust the spacing between the icon and text
            Text(AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                'getStepTwoLayout',
                'clearAllFlows')),
          ],
        ),
        tooltip: AppLocalization.instance.translate(
            'lib.screen.lecturePage.lecturePage',
            'getStepTwoLayout',
            'clearAllFlows'),
      )
    ];
    var dataTableColumnAlias = [
      AppLocalization.instance.translate(
          'lib.screen.lecturePage.lecturePage', 'getStepTwoLayout', 'id'),
      AppLocalization.instance.translate(
          'lib.screen.lecturePage.lecturePage', 'getStepTwoLayout', 'courseId'),
      AppLocalization.instance.translate(
          'lib.screen.lecturePage.lecturePage', 'getStepTwoLayout', 'orderNo'),
      AppLocalization.instance.translate(
          'lib.screen.lecturePage.lecturePage', 'getStepTwoLayout', 'flowId'),
      AppLocalization.instance.translate(
          'lib.screen.lecturePage.lecturePage', 'getStepTwoLayout', 'flowItem'),
      AppLocalization.instance.translate(
          'lib.screen.lecturePage.lecturePage', 'getStepTwoLayout', 'flowType'),
      AppLocalization.instance.translate('lib.screen.lecturePage.lecturePage',
          'getStepTwoLayout', 'flow_achievement_tree'),
      AppLocalization.instance.translate('lib.screen.lecturePage.lecturePage',
          'getStepTwoLayout', 'compatibleLectureAchievement'),
      AppLocalization.instance.translate(
          'lib.screen.lecturePage.lecturePage', 'getStepTwoLayout', 'isActive'),
      AppLocalization.instance.translate(
          'lib.screen.lecturePage.lecturePage', 'getStepTwoLayout', 'actions')
    ];
    var dataTableColumnNames = const [
      'id',
      'course_id',
      'order_no',
      'flow_id',
      'flow_item',
      'flow_type',
      'flow_achievement_tree',
      'compatibleLectureAchievement',
      'is_active',
      'actions'
    ];
    var disabledColumFilters = const [
      'id',
      'course_id',
      'order_no',
      'flow_id',
      'flow_item',
      'flow_type',
      'flow_achievement_tree',
      'compatibleLectureAchievement',
      'is_active',
      'actions'
    ];
    var dataTableHideColumn = const ['id', 'course_id', 'is_active'];
    var columnDataTypes = [
      ColumnDataType('id', BigInt),
      ColumnDataType('course_id', BigInt),
      ColumnDataType('orderNo', int),
      ColumnDataType('flow_id', BigInt),
      ColumnDataType('flow_item', String),
      ColumnDataType('flow_type', String),
      ColumnDataType('flow_achievement_tree', String),
      ColumnDataType('compatibleLectureAchievement', String),
      ColumnDataType('is_active', int),
      ColumnDataType('actions', String),
    ];

    lectureFlowDataTable = CommonDataTable(
      toolBarButtons: toolBarButtons,
      dataTableColumnAlias: dataTableColumnAlias,
      dataTableColumnNames: dataTableColumnNames,
      dataTableDisableColumnFilter: disabledColumFilters,
      dataTableHideColumn: dataTableHideColumn,
      columnDataTypes: columnDataTypes,
      dataTableRows: dataTableRows,
      dataTableKeyColumnName: 'orderNo',
      dataTableSelectedKeys: List.empty(),
      showCheckboxColumn: false,
        onChangedDisabledFilters:(disabledColumns){

        if(disabledColumns!=null) {
          dataTableHideColumn=disabledColumns ;
        }
        }
    );

    return Container(
      alignment: Alignment.centerLeft,
      child: lectureFlowDataTable,
    );
  }

  Future<Widget> getStepThreeLayout(BuildContext context) async {
    final screenWidth = MediaQuery.of(context).size.width;


    return Center(
      child: LectureObjectsSummary(
          lectureObjects: lecturePageModel.setLectureObjects!,
          lectureFlowDataTable: lectureFlowDataTable),
    );
  }

  void lectureBlocAddEvent(int? activeCurrentStep) {
    switch (activeCurrentStep) {
      case 0:
        lectureBloc.add(Step1Event(lecturePageModel: lecturePageModel));
        break;
      case 1:
        lectureBloc.add(Step2Event(lecturePageModel: lecturePageModel));
        break;
      case 2:
        lectureBloc.add(Step3Event(lecturePageModel: lecturePageModel));
        break;
      default:
        break;
    }
  }

  Widget _buildStepper(BuildContext context, LectureState state) {
    var qOStepsCount = lectureOperationsSteps(context, state).length;
    return Stepper(
      type: StepperType.vertical,
      currentStep: _activeCurrentStep,
      steps: lectureOperationsSteps(context, state),
      onStepContinue: () {
        if (_activeCurrentStep < (qOStepsCount - 1)) {
          setState(() {
            _activeCurrentStep += 1;
            lectureBlocAddEvent(_activeCurrentStep);
          });
        } else {
          //Save Pressed
          lectureBloc.add(SavePmEvent(lecturePageModel: lecturePageModel));
        }
      },
      onStepCancel: () {
        if (_activeCurrentStep == 0) {
          return;
        }
        setState(() {
          _activeCurrentStep -= 1;
          lectureBlocAddEvent(_activeCurrentStep);
        });
      },
      onStepTapped: (int index) {
        setState(() {
          _activeCurrentStep = index;
          lectureBlocAddEvent(_activeCurrentStep);
        });
      },
      controlsBuilder: (BuildContext context, ControlsDetails controlsDetails) {
        final isLastStep = _activeCurrentStep == qOStepsCount - 1;
        final isFirstStep = _activeCurrentStep == 0;
        return Padding(
          padding: const EdgeInsets.all(0.0),
          child: Row(
            children: [
              if (isFirstStep)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      //onPressed: controlsDetails.onStepContinue,
                      onPressed: controlsDetails.onStepContinue,
                      child: Text(AppLocalization.instance.translate(
                          'lib.screen.lecturePage.lecturePage',
                          '_buildStepper',
                          'next')),
                    ),
                  ),
                ),
              if (!isFirstStep && !isLastStep)
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: controlsDetails.onStepCancel,
                            child: Text(AppLocalization.instance.translate(
                                'lib.screen.lecturePage.lecturePage',
                                '_buildStepper',
                                'back')),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: controlsDetails.onStepContinue,
                            child: Text(AppLocalization.instance.translate(
                                'lib.screen.lecturePage.lecturePage',
                                '_buildStepper',
                                'next')),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (isLastStep)
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: controlsDetails.onStepCancel,
                            child: Text(AppLocalization.instance.translate(
                                'lib.screen.lecturePage.lecturePage',
                                '_buildStepper',
                                'back')),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              lectureBloc.add(SavePmEvent(
                                  lecturePageModel: lecturePageModel));
                            },
                            child: Text(AppLocalization.instance.translate(
                                'lib.screen.lecturePage.lecturePage',
                                '_buildStepper',
                                'submit')),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInit(BuildContext context, LectureState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(AppLocalization.instance.translate(
              'lib.screen.lecturePage.lecturePage',
              '_buildInit',
              'initializing')),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context, LoadingState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                '_buildLoading',
                'loading'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, LoadedState state) {
    lecturePageModel = state.lecturePageModel;
    lectureBlocAddEvent(_activeCurrentStep);
    return Container();
  }

  Widget _buildError(BuildContext context, ErrorState state) {
    String errorMessage;
    if (state is ErrorState) {
      errorMessage = state.errorMessage;
    } else {
      errorMessage = AppLocalization.instance.translate(
          'lib.screen.lecturePage.lecturePage', '_buildError', 'unknownError');
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.0,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16.0),
          Text(
            errorMessage,
            style: const TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStep1(BuildContext context, LoadingStep1State state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                '_buildLoadingStep1',
                'firstStepLoading'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedStep1(BuildContext context, LoadedStep1State state) {
    _activeCurrentStep = 0;
    return _buildStepper(context, state);
  }

  Widget _buildErrorStep1(BuildContext context, ErrorStep1State state) {
    String errorMessage;
    if (state is ErrorStep1State) {
      errorMessage = state.errorMessage;
    } else {
      errorMessage = AppLocalization.instance.translate(
          'lib.screen.lecturePage.lecturePage',
          '_buildErrorStep1',
          'unknownError');
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.0,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16.0),
          Text(
            errorMessage,
            style: const TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStep2(BuildContext context, LoadingStep2State state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                '_buildLoadingStep2',
                'secondStepLoading'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedStep2(BuildContext context, LoadedStep2State state) {
    if (StepsValidator(lecturePageModel).validateStep1()) {
      _activeCurrentStep = 1;
    } else {
      _activeCurrentStep = 0;
    }
    return _buildStepper(context, state);
  }

  Widget _buildErrorStep2(BuildContext context, ErrorStep2State state) {
    String errorMessage;
    if (state is ErrorStep2State) {
      errorMessage = state.errorMessage;
    } else {
      errorMessage = AppLocalization.instance.translate(
          'lib.screen.lecturePage.lecturePage',
          '_buildErrorStep2',
          'unknownError');
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.0,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16.0),
          Text(
            errorMessage,
            style: const TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStep3(BuildContext context, LoadingStep3State state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                '_buildLoadingStep3',
                'thirdStepLoading'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedStep3(BuildContext context, LoadedStep3State state) {
    if (StepsValidator(lecturePageModel).validateStep1()) {
      if (StepsValidator(lecturePageModel).validateStep2()) {
        _activeCurrentStep = 2;
      } else {
        _activeCurrentStep = 1;
      }
    } else {
      _activeCurrentStep = 0;
    }
    return _buildStepper(context, state);
  }

  Widget _buildErrorStep3(BuildContext context, ErrorStep3State state) {
    String errorMessage;
    if (state is ErrorStep3State) {
      errorMessage = state.errorMessage;
    } else {
      errorMessage = AppLocalization.instance.translate(
          'lib.screen.lecturePage.lecturePage',
          '_buildErrorStep3',
          'unknownError');
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.0,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16.0),
          Text(
            errorMessage,
            style: const TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPm(BuildContext context, LoadingPmState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                '_buildLoadingPm',
                'pageModelLoading'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedPm(BuildContext context, LoadedPmState state) {
    // TODO: Implement this widget
    return Container();
  }

  Widget _buildDeletingPm(BuildContext context, DeletingPmState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                '_buildDeletingPm',
                'pageModelDeleting'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeletedPm(BuildContext context, DeletedPmState state) {
    // TODO: Implement this widget
    return Container();
  }

  Widget _buildRemovingPm(BuildContext context, RemovingPmState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                '_buildRemovingPm',
                'pageModelRemoving'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemovedPm(BuildContext context, RemovedPmState state) {
    // TODO: Implement this widget
    return Container();
  }

  Widget _buildSavingPm(BuildContext context, SavingPmState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            AppLocalization.instance.translate(
                'lib.screen.lecturePage.lecturePage',
                '_buildSavingPm',
                'pageModelSaving'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPm(BuildContext context, SavedPmState state) {
    UIMessage.showSuccess(
        AppLocalization.instance.translate('lib.screen.lecturePage.lecturePage',
            '_buildSavedPm', 'pageModelSaved'),
        gravity: ToastGravity.CENTER);
    _activeCurrentStep = 2;
    return _buildStepper(context, state);
  }

  Widget _buildErrorPm(BuildContext context, ErrorPmState state) {
    UIMessage.showSuccess(
        AppLocalization.instance.translate('lib.screen.lecturePage.lecturePage',
            '_buildErrorPm', 'pageModelNotSaved'),
        gravity: ToastGravity.CENTER);

    _activeCurrentStep = 2;
    return _buildStepper(context, state);
  }
}
