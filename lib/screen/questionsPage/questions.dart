import 'package:dropdown_search/dropdown_search.dart';
import 'package:egitimaxapplication/bloc/bloc/questions/questionsBloc.dart';
import 'package:egitimaxapplication/bloc/state/questions/questionsState.dart';
import 'package:egitimaxapplication/model/common/dataTableData.dart';
import 'package:egitimaxapplication/model/questions/questionsPageModel.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/questions/questionsRepository.dart';
import 'package:egitimaxapplication/screen/common/collapsibleItemBuilder.dart';
import 'package:egitimaxapplication/screen/common/commonDataTable.dart';
import 'package:egitimaxapplication/screen/common/commonDropdownButtonFormField.dart';
import 'package:egitimaxapplication/screen/common/commonTextFormField.dart';
import 'package:egitimaxapplication/screen/common/learnLevels.dart';
import 'package:egitimaxapplication/screen/common/questionOverView.dart';
import 'package:egitimaxapplication/screen/common/userInteractiveMessage.dart';
import 'package:egitimaxapplication/screen/questionPage/questionPage.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/constant/router/heroTagConstant.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:egitimaxapplication/utils/helper/getDeviceType.dart';
import 'package:egitimaxapplication/utils/widget/appBar/innerAppBar.dart';
import 'package:egitimaxapplication/utils/widget/layout/mainLayout.dart';
import 'package:egitimaxapplication/utils/widget/message/uIMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../bloc/event/questions/questionsEvent.dart';

class QuestionsPage extends StatefulWidget {
  final BigInt userId;
  TextStyle? componentTextStyle = const TextStyle(fontSize: 10);
  bool isFilterCollapse = false;

  QuestionsPage({
    required this.userId,
    this.componentTextStyle,
  });

  @override
  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  late QuestionsBloc questionsBloc;
  late QuestionsPageModel questionsPageModel;

  AppRepositories appRepositories = AppRepositories();

  String filterPoint = 'My Questions';
  String filterTitle = 'Filters';
  List<String> hiddenColumns = List.empty(growable: true);

  @override
  void initState() {
    questionsPageModel = QuestionsPageModel(userId: widget.userId);
    questionsBloc = QuestionsBloc();
    questionsBloc.add(InitEvent(questionsPageModel: questionsPageModel));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    questionsPageModel.context = context;
    return BlocProvider(
      create: (_) => questionsBloc,
      child: Scaffold(
        appBar: const InnerAppBar(
          title: 'My questions',
          subTitle: 'My questions are listed here',
        ),
        body: BlocBuilder<QuestionsBloc, QuestionsState>(
          builder: (context, state) {
            if (state is InitState) {
              return _buildInit(context, state);
            } else if (state is LoadingState) {
              return _buildLoading(context, state);
            } else if (state is LoadedState) {
              return FutureBuilder<Widget>(
                future: _buildLoaded(context, state),
                builder:
                    (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: snapshot.data ?? Container(),
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                        '${AppLocalization.instance.translate('lib.screen.quizPage.quizPage', 'getStepThreeLayout', 'error')} ${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator(); // or any other loading indicator
                  }
                },
              );
              // return _buildLoaded(context, state);
            } else if (state is ErrorState) {
              return _buildError(context, state);
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Widget _buildInit(BuildContext context, InitState state) {
    return Container();
  }

  Widget _buildLoading(BuildContext context, LoadingState state) {
    return Container();
  }

  Future<Widget> _buildLoaded(BuildContext context, LoadedState state) async {
    final theme = Theme.of(context);
    var deviceType = getDeviceType(context);

    //Prepare visible colums as per mobile or web
    if (deviceType == DeviceType.mobileSmall ||
        deviceType == DeviceType.mobileMedium ||
        deviceType == DeviceType.mobileLarge) {
      hiddenColumns = [
        'id',
        'acad_year',
        //'question_text',
        'dif_level',
        //'branch_name',
        'achievementTree',
        'created_on',
        'favCount',
        'likeCount',
        //'actions'
      ];
    } else if (deviceType != DeviceType.mobileSmall &&
        deviceType != DeviceType.mobileMedium &&
        deviceType != DeviceType.mobileLarge) {
      hiddenColumns = [
        'id',
        'acad_year',
        //'question_text',
        //'dif_level',
        //'branch_name',
        //'achievementTree',
        'created_on',
        'favCount',
        //'likeCount',
        //'actions'
      ];
    } else {
      hiddenColumns = [
        'id',
        'acad_year',
        //'question_text',
        //'dif_level',
        //'branch_name',
        //'achievementTree',
        'created_on',
        'favCount',
        //'likeCount',
        //'actions'
      ];
    }

    if (state.questionsPageModel.loadedInitialData != null &&
        state.questionsPageModel.loadedInitialData == false) {
      await searchButtonOnPressed(
          context, widget.userId ?? BigInt.parse('0'), state, false);
      state.questionsPageModel.loadedInitialData =
          true; // Önemli il açılışta yüklenmesi için
    }

    widget.componentTextStyle ??= const TextStyle(fontSize: 10);

    var collapsibleItemData = CollapsibleItemData(
        isExpanded: widget.isFilterCollapse,
        header: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Text(filterPoint),
            ),
            Flexible(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.manage_search,
                ),
                const SizedBox(width: 5),
                Text(filterTitle),
              ],
            ))
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (deviceType == DeviceType.mobileSmall ||
                          deviceType == DeviceType.mobileMedium ||
                          deviceType == DeviceType.mobileLarge)
                        Column(
                          children: [
                            FutureBuilder<CommonDropdownButtonFormField>(
                              future: filterAcademicYears(state),
                              builder: (BuildContext context,
                                  AsyncSnapshot<CommonDropdownButtonFormField>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!;
                                } else if (snapshot.hasError) {
                                  return Text(
                                      '${AppLocalization.instance.translate('lib.screen.common.questionDataTable', 'build', 'error')}: ${snapshot.error}');
                                } else {
                                  return const CircularProgressIndicator(); // or any other loading indicator
                                }
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            FutureBuilder<CommonDropdownButtonFormField>(
                              future: filterDifficultyLevels(state),
                              builder: (BuildContext context,
                                  AsyncSnapshot<CommonDropdownButtonFormField>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!;
                                } else if (snapshot.hasError) {
                                  return Text(
                                      '${AppLocalization.instance.translate('lib.screen.common.questionDataTable', 'build', 'error')}: ${snapshot.error}');
                                } else {
                                  return const CircularProgressIndicator(); // or any other loading indicator
                                }
                              },
                            ),
                          ],
                        ),
                      if (deviceType != DeviceType.mobileSmall &&
                          deviceType != DeviceType.mobileMedium &&
                          deviceType != DeviceType.mobileLarge)
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child:
                                  FutureBuilder<CommonDropdownButtonFormField>(
                                future: filterAcademicYears(state),
                                builder: (BuildContext context,
                                    AsyncSnapshot<CommonDropdownButtonFormField>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    return snapshot.data!;
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        '${AppLocalization.instance.translate('lib.screen.common.questionDataTable', 'build', 'error')}: ${snapshot.error}');
                                  } else {
                                    return const CircularProgressIndicator(); // or any other loading indicator
                                  }
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child:
                                  FutureBuilder<CommonDropdownButtonFormField>(
                                future: filterDifficultyLevels(state),
                                builder: (BuildContext context,
                                    AsyncSnapshot<CommonDropdownButtonFormField>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    return snapshot.data!;
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        '${AppLocalization.instance.translate('lib.screen.common.questionDataTable', 'build', 'error')}: ${snapshot.error}');
                                  } else {
                                    return const CircularProgressIndicator(); // or any other loading indicator
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (deviceType == DeviceType.mobileSmall ||
                          deviceType == DeviceType.mobileMedium ||
                          deviceType == DeviceType.mobileLarge)
                        Column(
                          children: [
                            FutureBuilder<CommonDropdownButtonFormField>(
                              future: filterGrades(state),
                              builder: (BuildContext context,
                                  AsyncSnapshot<CommonDropdownButtonFormField>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!;
                                } else if (snapshot.hasError) {
                                  return Text(
                                      '${AppLocalization.instance.translate('lib.screen.common.questionDataTable', 'build', 'error')}: ${snapshot.error}');
                                } else {
                                  return const CircularProgressIndicator(); // or any other loading indicator
                                }
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            FutureBuilder<CommonDropdownButtonFormField>(
                              future: filterBranches(state),
                              builder: (BuildContext context,
                                  AsyncSnapshot<CommonDropdownButtonFormField>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!;
                                } else if (snapshot.hasError) {
                                  return Text(
                                      '${AppLocalization.instance.translate('lib.screen.common.questionDataTable', 'build', 'error')}: ${snapshot.error}');
                                } else {
                                  return const CircularProgressIndicator(); // or any other loading indicator
                                }
                              },
                            )
                          ],
                        ),
                      if (deviceType != DeviceType.mobileSmall &&
                          deviceType != DeviceType.mobileMedium &&
                          deviceType != DeviceType.mobileLarge)
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child:
                                  FutureBuilder<CommonDropdownButtonFormField>(
                                future: filterGrades(state),
                                builder: (BuildContext context,
                                    AsyncSnapshot<CommonDropdownButtonFormField>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    return snapshot.data!;
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        '${AppLocalization.instance.translate('lib.screen.common.questionDataTable', 'build', 'error')}: ${snapshot.error}');
                                  } else {
                                    return const CircularProgressIndicator(); // or any other loading indicator
                                  }
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child:
                                  FutureBuilder<CommonDropdownButtonFormField>(
                                future: filterBranches(state),
                                builder: (BuildContext context,
                                    AsyncSnapshot<CommonDropdownButtonFormField>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    return snapshot.data!;
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        '${AppLocalization.instance.translate('lib.screen.common.questionDataTable', 'build', 'error')}: ${snapshot.error}');
                                  } else {
                                    return const CircularProgressIndicator(); // or any other loading indicator
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (state.questionsPageModel.branchId != 0 &&
                          state.questionsPageModel.gradeId != 0 &&
                          state.questionsPageModel.gradeId != null &&
                          state.questionsPageModel.branchId != null)
                        LearnLevels(
                            learnId: state.questionsPageModel.selectedLearn,
                            branchId: state.questionsPageModel.branchId,
                            gradeId: state.questionsPageModel.gradeId,
                            countryId: state.questionsPageModel.countryId,
                            showAchievements: false,
                            onChangedLearnId: (selectedLearnId) {
                              state.questionsPageModel.selectedLearn =
                                  selectedLearnId;
                              setState(() {});
                            },
                            onChangedSelectedAchievements:
                                (selectedAchievements) {},
                            onChangedAchievements: (achievements) {},
                            selectedAchievements: const {},
                            componentTextStyle: widget.componentTextStyle!),
                      const SizedBox(
                        height: 5,
                      ),
                      if (deviceType == DeviceType.mobileSmall ||
                          deviceType == DeviceType.mobileMedium ||
                          deviceType == DeviceType.mobileLarge)
                        Column(
                          children: [
                            filterQuestionText(state),
                          ],
                        ),
                      const SizedBox(
                        height: 5,
                      ),
                      if (deviceType != DeviceType.mobileSmall &&
                          deviceType != DeviceType.mobileMedium &&
                          deviceType != DeviceType.mobileLarge)
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: filterQuestionText(state),
                            ),
                          ],
                        ),
                    ],
                  )),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await clearButtonOnPressed(state);
                    },
                    child: Text(AppLocalization.instance.translate(
                        'lib.screen.common.questionDataTable',
                        'build',
                        'clear')),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await searchButtonOnPressed(context,
                          widget.userId ?? BigInt.parse('0'), state, false);
                    },
                    child: Text(AppLocalization.instance.translate(
                        'lib.screen.common.questionDataTable',
                        'build',
                        'search')),
                  ),
                ],
              ),
            ],
          ),
        ),
        padding: 10,
        onStateChanged: (isFilterCollapseNew) {
          setState(() {
            widget.isFilterCollapse = isFilterCollapseNew;
          });
        });

    var cIB = CollapsibleItemBuilder(
      items: [collapsibleItemData],
      padding: 0,
      onStateChanged: (isFilterCollapseNew) {
        setState(() {
          widget.isFilterCollapse = isFilterCollapseNew;
        });
      },
    );

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            cIB,
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (!(state.questionsPageModel.dataTableDataRoot != null &&
                      state.questionsPageModel.dataTableRows != null &&
                      state.questionsPageModel.dataTableRows!.isNotEmpty))
                    Padding(
                      padding: EdgeInsets.only(
                          right: state.questionsPageModel.selectedKeys != null
                              ? state.questionsPageModel.selectedKeys!
                                      .isNotEmpty
                                  ? 5
                                  : 0
                              : 0),
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MainLayout(
                                    context: context,
                                    loadedStateContainer: QuestionPage(
                                      userId: widget.userId,
                                      isEditorMode: true,
                                      questionId: BigInt.parse('0'),
                                    )),
                                settings: const RouteSettings(
                                    name: HeroTagConstant
                                        .question), // use the route name as the Hero tag
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.add),
                              SizedBox(
                                width: 5,
                              ),
                              Text('Add')
                            ],
                          )),
                    ),
                  if (state.questionsPageModel.selectedKeys != null &&
                      state.questionsPageModel.selectedKeys!.isNotEmpty &&
                      false)
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: ElevatedButton(
                          onPressed: () {
                            if (state.questionsPageModel.selectedKeys != null &&
                                state.questionsPageModel.selectedKeys!
                                    .isNotEmpty &&
                                state.questionsPageModel.selectedKeys!.first !=
                                    null) {
                              String questionIdAsString = state
                                  .questionsPageModel.selectedKeys!.first
                                  .toString();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MainLayout(
                                      context: context,
                                      loadedStateContainer: QuestionPage(
                                        userId: widget.userId,
                                        isEditorMode: true,
                                        questionId:
                                            BigInt.parse(questionIdAsString),
                                      )),
                                  settings: const RouteSettings(
                                      name: HeroTagConstant
                                          .question), // use the route name as the Hero tag
                                ),
                              );
                            }
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.edit),
                              SizedBox(
                                width: 5,
                              ),
                              Text('Edit')
                            ],
                          )),
                    ),
                  if (state.questionsPageModel.selectedKeys != null &&
                      state.questionsPageModel.selectedKeys!.isNotEmpty &&
                      false)
                    Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: ElevatedButton(
                          onPressed: () {
                            UserInteractiveMessage(
                              title: 'Question Delete',
                              message: 'Do you want to delete this question ?',
                              yesButtonText: 'Yes',
                              noButtonText: 'No',
                              onSelection: (bool value) {
                                if (value) {
                                  if (state.questionsPageModel.selectedKeys !=
                                          null &&
                                      state.questionsPageModel.selectedKeys!
                                          .isNotEmpty &&
                                      state.questionsPageModel.selectedKeys!
                                              .first !=
                                          null) {
                                    String questionIdAsString = state
                                        .questionsPageModel.selectedKeys!.first
                                        .toString();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MainLayout(
                                            context: context,
                                            loadedStateContainer: QuestionPage(
                                              userId: widget.userId,
                                              isEditorMode: true,
                                              questionId: BigInt.parse(
                                                  questionIdAsString),
                                            )),
                                        settings: const RouteSettings(
                                            name: HeroTagConstant
                                                .question), // use the route name as the Hero tag
                                      ),
                                    );
                                  }
                                } else {}
                                setState(() {});
                              },
                            ).show(context);
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.delete_forever_outlined),
                              SizedBox(
                                width: 5,
                              ),
                              Text('Delete')
                            ],
                          )),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  height: 400,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: state.questionsPageModel.dataTableDataRoot != null &&
                            state.questionsPageModel.dataTableRows != null &&
                            state.questionsPageModel.dataTableRows!.isNotEmpty
                        ? ListView(
                            shrinkWrap: true,
                            children: [
                              CommonDataTable(
                                filterSelectionMenuIsActive: false,
                                columnSelectionMenuIsActive: false,
                                exportButtonIsActive: false,
                                singleSelection: true,
                                showDataTableMenu: false,
                                columnDataTypes:
                                    state.questionsPageModel.columnDataTypes,
                                toolBarButtons: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: state.questionsPageModel
                                                    .selectedKeys !=
                                                null
                                            ? state.questionsPageModel
                                                    .selectedKeys!.isNotEmpty
                                                ? 5
                                                : 0
                                            : 0),
                                    child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => MainLayout(
                                                  context: context,
                                                  loadedStateContainer:
                                                      QuestionPage(
                                                    userId: widget.userId,
                                                    isEditorMode: true,
                                                    questionId:
                                                        BigInt.parse('0'),
                                                  )),
                                              settings: const RouteSettings(
                                                  name: HeroTagConstant
                                                      .question), // use the route name as the Hero tag
                                            ),
                                          );
                                        },
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.add),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text('Add')
                                          ],
                                        )),
                                  ),
                                ],
                                dataTableKeyColumnName: state
                                    .questionsPageModel.dataTableKeyColumnName,
                                dataTableSelectedKeys:
                                    state.questionsPageModel.selectedKeys,
                                dataTableColumnAlias: state
                                    .questionsPageModel.dataTableColumnAlias,
                                createDataTableColumnAlias: state
                                    .questionsPageModel
                                    .createDataTableColumnAlias,
                                dataTableColumnNames: state
                                    .questionsPageModel.dataTableColumnNames,
                                dataTableDisableColumnFilter: state
                                    .questionsPageModel
                                    .dataTableDisableColumnFilter,
                                onChangedDisabledFilters: (disabledFilters) {
                                  state.questionsPageModel
                                          .dataTableDisableColumnFilter =
                                      disabledFilters;
                                  setState(() {});
                                },
                                dataTableHideColumn: state
                                    .questionsPageModel.dataTableHideColumn,
                                dataTableRows:
                                    state.questionsPageModel.dataTableRows,
                                showCheckboxColumn: true,
                                onFilterValueChanged: (
                                  filterText,
                                  index,
                                  filterControllers,
                                  filteredRows,
                                ) {},
                                onSelectedRowsChanged:
                                    (selectedRows, selectedKeys) async {
                                  state.questionsPageModel.selectedKeys =
                                      await convertToBigIntList(selectedKeys);
                                  setState(() {});
                                },
                              ),
                            ],
                          )
                        : Center(
                            child: Text(AppLocalization.instance.translate(
                                'lib.screen.common.questionDataTable',
                                'build',
                                'noData'))),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, ErrorState state) {
    return Container();
  }

  List<BigInt> convertToBigIntList(List<dynamic>? dataTableSelectedKeys) {
    List<BigInt> convertedKeys = [];

    if (dataTableSelectedKeys != null) {
      for (dynamic item in dataTableSelectedKeys) {
        try {
          BigInt convertedItem = BigInt.parse(item.toString());
          convertedKeys.add(convertedItem);
        } catch (e) {
          // Conversion failed for the item, move to the next item
        }
      }
    }

    return convertedKeys;
  }

  Future<void> searchButtonOnPressed(BuildContext context, BigInt userId,
      LoadedState state, bool isReadyData) async {
    final theme = Theme.of(context);
    if (!isReadyData || state.questionsPageModel.dataSet == null) {
      state.questionsPageModel.dataTableRoot = null;
      state.questionsPageModel.dataTableDataRoot = null;
      state.questionsPageModel.dataTableRows = null;

      var questionsRepository = await appRepositories.questionsRepository();

      state.questionsPageModel
          .dataSet = await questionsRepository.getQuestionDataTableData([
        '*'
      ],
          getNoSqlData: 0,
          user_id_for_isMyFavorite: widget.userId,
          user_id: widget.userId,
          academic_year: state.questionsPageModel.academicYearId == 0
              ? null
              : state.questionsPageModel.academicYearId,
          difficulty_lev: state.questionsPageModel.difficultyId == 0
              ? null
              : state.questionsPageModel.difficultyId,
          grade_id: state.questionsPageModel.gradeId == 0
              ? null
              : state.questionsPageModel.gradeId,
          branch_id: state.questionsPageModel.branchId == 0
              ? null
              : state.questionsPageModel.branchId,
          learn_id: state.questionsPageModel.selectedLearn == 0
              ? null
              : state.questionsPageModel.selectedLearn,
          question_text:
              state.questionsPageModel.filterQuestionTextController.text ==
                          '' ||
                      state.questionsPageModel.filterQuestionTextController.text
                          .isEmpty
                  ? null
                  : state.questionsPageModel.filterQuestionTextController.text);
    }
    var firstId = state.questionsPageModel.dataSet!
            .firstValueWithType<BigInt>('data', 'id') ??
        BigInt.parse('0');

    if (state.questionsPageModel.dataSet != null &&
        state.questionsPageModel.dataSet!.entries.isNotEmpty &&
        firstId > BigInt.parse('0')) {
      var dataTable = state.questionsPageModel.dataSet!.getDataTable();
      if (dataTable != null &&
          dataTable.columns != null &&
          dataTable.columns.isNotEmpty) {
        var dataTableData =
            state.questionsPageModel.dataSet!.getDataTableData();
        // Update QuestionColumn Widget As Text Button Widget
        List<Map<Map<String, String>, Widget>> modifiedRows =
            dataTableData.rowsAsWidget.map((row) {
          Map<Map<String, String>, Widget> modifiedRow = {};

          var idCell;
          BigInt idValue = BigInt.parse('0');

          row.forEach((keyMap, widget) {
            try {
              idCell = row.entries.firstWhere(
                (element) => element.key.entries.first.key == "id",
              );
            } catch (e) {
              debugPrint(e.toString());
              idCell = null;
            }

            if (idCell != null) {
              idValue = BigInt.parse(idCell.key.entries.first.value.toString());
            }

            if (keyMap.entries.first.key == "question_text") {
              modifiedRow[keyMap] = MouseRegion(
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
                          questionId: idValue,
                          userId: userId,
                          onAddedQuestion: (questionId) {
                            if (questionId != null) {}
                          },
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
                    message: keyMap.entries.first.value ?? "",
                    child: Wrap(
                      children: [
                        Text(
                          keyMap.entries.first.value != null &&
                                  keyMap.entries.first.value.length > 20
                              ? "${keyMap.entries.first.value.substring(0, 20)}..."
                              : keyMap.entries.first.value ?? "",
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (keyMap.entries.first.key == "achievementTree") {
              var reversedAchievementTree =
                  keyMap.entries.first.value.split('>>').toList();

              List<String> reversedAchievementTreeNew = [];
              reversedAchievementTree.forEach((achievement) {
                List<String> parts = achievement.split(":");
                if (parts.length > 1) {
                  reversedAchievementTreeNew.add(parts[1]);
                }
              });

              var reversedString =
                  reversedAchievementTreeNew.reversed.toList().join('>>');
              modifiedRow[keyMap] = Text(reversedString);
            } else if (keyMap.entries.first.key == "favCount") {
              String ifNullToZero = keyMap.entries.first.value == 'null' ||
                      keyMap.entries.first.value == null ||
                      keyMap.entries.first.value == ''
                  ? '0'
                  : keyMap.entries.first.value;
              modifiedRow[keyMap] = Text(ifNullToZero);
            } else if (keyMap.entries.first.key == "likeCount") {
              String ifNullToZero = keyMap.entries.first.value == 'null' ||
                      keyMap.entries.first.value == null ||
                      keyMap.entries.first.value == ''
                  ? '0'
                  : keyMap.entries.first.value;
              modifiedRow[keyMap] = Text(ifNullToZero);
            } else {
              modifiedRow[keyMap] = widget;
            }
          });

          Map<String, String> actionsKey = {};
          actionsKey['actions'] = 'actions';
          modifiedRow[actionsKey] = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PopupMenuButton<String>(
                  padding: const EdgeInsets.all(3.0),
                  itemBuilder: (BuildContext context) => [
                        if (false)
                          PopupMenuItem<String>(
                            padding: const EdgeInsets.all(3.0),
                            value: 'add_question',
                            textStyle: const TextStyle(fontSize: 10),
                            child: Row(
                              children: [
                                const Icon(Icons.add, size: 14),
                                const SizedBox(width: 8),
                                Text(
                                    AppLocalization.instance.translate(
                                        'lib.screen.quizPage.quizSectionDataTable',
                                        'build',
                                        'addQuestion'),
                                    style: const TextStyle(fontSize: 10)),
                              ],
                            ),
                          ),
                        PopupMenuItem<String>(
                          padding: const EdgeInsets.all(3.0),
                          value: 'edit',
                          textStyle: const TextStyle(fontSize: 10),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.edit,
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                  AppLocalization.instance.translate(
                                      'lib.screen.quizPage.quizSectionDataTable',
                                      'build',
                                      'edit'),
                                  style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          padding: const EdgeInsets.all(3.0),
                          value: 'delete',
                          textStyle: const TextStyle(fontSize: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.delete, size: 14),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalization.instance.translate(
                                    'lib.screen.quizPage.quizSectionDataTable',
                                    'build',
                                    'delete'),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                  onSelected: (String? value) {
                    if (value == 'edit') {
                      if (idValue != null ||
                          (state.questionsPageModel.selectedKeys != null &&
                              state.questionsPageModel.selectedKeys!
                                  .isNotEmpty &&
                              state.questionsPageModel.selectedKeys!.first !=
                                  null)) {
                        String questionIdAsString =
                            (state.questionsPageModel.selectedKeys != null &&
                                    state.questionsPageModel.selectedKeys!
                                        .isNotEmpty &&
                                    state.questionsPageModel.selectedKeys!
                                            .first !=
                                        null)
                                ? state.questionsPageModel.selectedKeys!.first
                                    .toString()
                                : '0';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MainLayout(
                                context: context,
                                loadedStateContainer: QuestionPage(
                                  userId: widget.userId,
                                  isEditorMode: true,
                                  questionId: idValue ??
                                      BigInt.parse(questionIdAsString),
                                )),
                            settings: const RouteSettings(
                                name: HeroTagConstant
                                    .question), // use the route name as the Hero tag
                          ),
                        );
                      }
                    } else if (value == 'delete') {
                      UserInteractiveMessage(
                        title: 'Question Delete',
                        message: 'Do you want to delete this question ?',
                        yesButtonText: 'Yes',
                        noButtonText: 'No',
                        onSelection: (bool value) {
                          if (value) {
                            if (idValue != null ||
                                (state
                                            .questionsPageModel.selectedKeys !=
                                        null &&
                                    state.questionsPageModel.selectedKeys!
                                        .isNotEmpty &&
                                    state.questionsPageModel.selectedKeys!
                                            .first !=
                                        null)) {
                              String questionIdAsString = state
                                  .questionsPageModel.selectedKeys!.first
                                  .toString();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MainLayout(
                                      context: context,
                                      loadedStateContainer: QuestionPage(
                                        userId: widget.userId,
                                        isEditorMode: true,
                                        questionId: idValue ??
                                            BigInt.parse(questionIdAsString),
                                      )),
                                  settings: const RouteSettings(
                                      name: HeroTagConstant
                                          .question), // use the route name as the Hero tag
                                ),
                              );
                            }
                          } else {}
                          setState(() {});
                        },
                      ).show(context);
                    } else if (value == 'add_question') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MainLayout(
                              context: context,
                              loadedStateContainer: QuestionPage(
                                userId: widget.userId,
                                isEditorMode: true,
                                questionId: BigInt.parse('0'),
                              )),
                          settings: const RouteSettings(
                              name: HeroTagConstant
                                  .question), // use the route name as the Hero tag
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Text(
                        AppLocalization.instance.translate(
                            'lib.screen.quizPage.quizSectionDataTable',
                            'build',
                            'selectAction'),
                        style:
                            const TextStyle(color: Colors.blue, fontSize: 10),
                      ),
                      const SizedBox(width: 5.0),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  )),
            ],
          );

          return modifiedRow;
        }).toList();

        if (dataTableData != null &&
            dataTableData.columns.isNotEmpty &&
            dataTableData.rowsAsWidget != null &&
            dataTableData.rowsAsWidget.isNotEmpty) {}
        state.questionsPageModel.columnDataTypes =
            dataTableData.columnDataTypes;
        state.questionsPageModel.createDataTableColumnAlias = false;
        state.questionsPageModel.dataTableRoot = dataTable;
        state.questionsPageModel.dataTableDataRoot = dataTableData;
        state.questionsPageModel.dataTableColumnAlias = [
          AppLocalization.instance.translate(
              'lib.screen.common.questionDataTable',
              'searchButtonOnPressed',
              'id'),
          AppLocalization.instance.translate(
              'lib.screen.common.questionDataTable',
              'searchButtonOnPressed',
              'academicYear'),
          AppLocalization.instance.translate(
              'lib.screen.common.questionDataTable',
              'searchButtonOnPressed',
              'question'),
          AppLocalization.instance.translate(
              'lib.screen.common.questionDataTable',
              'searchButtonOnPressed',
              'difficultyLevel'),
          AppLocalization.instance.translate(
              'lib.screen.common.questionDataTable',
              'searchButtonOnPressed',
              'branchName'),
          AppLocalization.instance.translate(
              'lib.screen.common.questionDataTable',
              'searchButtonOnPressed',
              'achievementTree'),
          AppLocalization.instance.translate(
              'lib.screen.common.questionDataTable',
              'searchButtonOnPressed',
              'createdOn'),
          AppLocalization.instance.translate(
              'lib.screen.common.questionDataTable',
              'searchButtonOnPressed',
              'favorite'),
          AppLocalization.instance.translate(
              'lib.screen.common.questionDataTable',
              'searchButtonOnPressed',
              'likeCount'),
          'Actions',
        ];
        state.questionsPageModel.dataTableColumnNames = [
          'id',
          'acad_year',
          'question_text',
          'dif_level',
          'branch_name',
          'achievementTree',
          'created_on',
          'favCount',
          'likeCount',
          'actions'
        ];
        state.questionsPageModel.dataTableKeyColumnName = 'id';
        state.questionsPageModel.dataTableDisableColumnFilter = [
          'id',
          'acad_year',
          //'question_text',
          'dif_level',
          'branch_name',
          'achievementTree',
          'created_on',
          'favCount',
          'likeCount',
          'actions'
        ];
        state.questionsPageModel.dataTableHideColumn =hiddenColumns;
        state.questionsPageModel.dataTableRows =
            modifiedRows; //dataTableData.rowsAsWidget; // Map Is List<Map<Map<columnName, columnValueAsString>, Widget(Show Your Widget With Cell Value Bind)>>?
      }
    } else {
      state.questionsPageModel.dataTableRows = null;
      UIMessage.showShort(
          AppLocalization.instance.translate(
              'lib.screen.common.questionDataTable',
              'searchButtonOnPressed',
              'noData'),
          gravity: ToastGravity.CENTER);
    }

    setState(() {
      widget.isFilterCollapse = false;
    });
  }

  Future<void> clearButtonOnPressed(LoadedState state) async {
    setState(() {
      state.questionsPageModel.academicYearId = 0;
      state.questionsPageModel.branchId = 0;
      state.questionsPageModel.gradeId = 0;
      state.questionsPageModel.difficultyId = 0;
      state.questionsPageModel.selectedLearn = null;
      state.questionsPageModel.filterQuestionTextController.text = '';
      widget.isFilterCollapse = true;
    });
  }

  Future<CommonDropdownButtonFormField> filterAcademicYears(
      LoadedState state) async {
    var academicYearsDataSet =
        state.questionsPageModel.academicYearsRootDataSet ??
            await appRepositories.tblUtilAcademicYear(
                'Question/GetObject', ['id', 'acad_year', 'is_default']);
    state.questionsPageModel.academicYearsRootDataSet ??= academicYearsDataSet;

    var academicYears = state.questionsPageModel.academicYearsRoot ??
        academicYearsDataSet.toKeyValuePairsWithTypes<int, String>('data', 'id',
            valueColumn: 'acad_year');
    //Add NotSelectableItem
    academicYears[0] = AppLocalization.instance.translate(
        'lib.screen.common.questionDataTable', 'filterAcademicYears', 'all');

    state.questionsPageModel.academicYearsRoot ??= academicYears;

    var defaultAcademicYear = !widget.isFilterCollapse
        ? null
        : academicYearsDataSet.firstValue('data', 'id',
            filterColumn: 'is_default', filterValue: true, insteadOfNull: 0);
    state.questionsPageModel.academicYearId ??= 0;

    if (state.questionsPageModel.academicYearsRoot == null) {
      //return emptySearchableDropDown();
    }

    return CommonDropdownButtonFormField(
      isExpandedObject: true,
      isSearchEnable: true,
      items: academicYears,
      label: AppLocalization.instance.translate(
          'lib.screen.common.questionDataTable',
          'filterAcademicYears',
          'academicYear'),
      onSelectedItemChanged: (selectedItem) {
        state.questionsPageModel.academicYearId = academicYears.entries
            .map((entry) => entry)
            .toList()
            .firstWhere((item) => selectedItem == item.key)
            .key;
      },
      selectedItem: state.questionsPageModel.academicYearId,
      componentTextStyle: widget.componentTextStyle,
    );
  }

  Future<CommonDropdownButtonFormField> filterGrades(LoadedState state) async {
    var gradesDataSet = state.questionsPageModel.gradesRootDataSet ??
        await appRepositories
            .tblClassGrade('Question/GetObject', ['id', 'grade_name']);
    state.questionsPageModel.gradesRootDataSet ??= gradesDataSet;

    var grades = state.questionsPageModel.gradesRoot ??
        gradesDataSet.toKeyValuePairsWithTypes<int, String>('data', 'id',
            valueColumn: 'grade_name');
    //Add NotSelectableItem
    grades[0] = AppLocalization.instance.translate(
        'lib.screen.common.questionDataTable', 'filterGrades', 'all');

    state.questionsPageModel.gradesRoot ??= grades;

    var userDataSet = state.questionsPageModel.userRootDataSet ??
        await appRepositories.tblUserMain(
            'Question/GetObject', ['id', 'grade_id'],
            id: widget.userId);
    state.questionsPageModel.userRootDataSet ??= userDataSet;

    var defaultGrade = !widget.isFilterCollapse
        ? null
        : state.questionsPageModel.gradeId ??
            userDataSet.firstValue('data', 'grade_id',
                insteadOfNull: grades.entries.first.key);
    state.questionsPageModel.gradeId ??= defaultGrade;

    return CommonDropdownButtonFormField(
        isExpandedObject: true,
        isSearchEnable: true,
        label: AppLocalization.instance.translate(
            'lib.screen.common.questionDataTable', 'filterGrades', 'gradeName'),
        items: grades,
        onSelectedItemChanged: (selectedItem) {
          state.questionsPageModel.gradeId = grades.entries
              .map((entry) => entry)
              .toList()
              .firstWhere((item) => selectedItem == item.key)
              .key;
          state.questionsPageModel.selectedLearn = null;
          state.questionsPageModel.branchId = null;
          setState(() {});
        },
        selectedItem: state.questionsPageModel.gradeId,
        componentTextStyle: widget.componentTextStyle);
  }

  Future<CommonDropdownButtonFormField> filterBranches(
      LoadedState state) async {
    var branchesDataSet = state.questionsPageModel.branchesRootDataSet ??
        await appRepositories
            .tblLearnBranch('Question/GetObject', ['id', 'branch_name']);
    state.questionsPageModel.branchesRootDataSet ??= branchesDataSet;

    var branches = state.questionsPageModel.branchesRoot ??
        branchesDataSet.toKeyValuePairsWithTypes<int, String>('data', 'id',
            valueColumn: 'branch_name');
    //Add NotSelectableItem
    branches[0] = AppLocalization.instance.translate(
        'lib.screen.common.questionDataTable', 'filterBranches', 'all');
    state.questionsPageModel.branchesRoot = branches;

    var branchesMapDataSet = await appRepositories.tblTheaBranMap(
        'Question/GetObject', ['id', 'branch_id', 'user_id'],
        user_id: widget.userId);
    var defaultBranch = !widget.isFilterCollapse
        ? null
        : branchesMapDataSet.firstValue('data', 'branch_id',
            insteadOfNull: branches.entries.first.key);

    state.questionsPageModel.branchId ??= defaultBranch;

    return CommonDropdownButtonFormField(
        isExpandedObject: true,
        isSearchEnable: true,
        items: branches,
        label: AppLocalization.instance.translate(
            'lib.screen.common.questionDataTable',
            'filterBranches',
            'branchName'),
        onSelectedItemChanged: (selectedItem) async {
          state.questionsPageModel.branchId = branches.entries
              .map((entry) => entry)
              .toList()
              .firstWhere((item) => selectedItem == item.key)
              .key;
          if (state.questionsPageModel.countryId == null ||
              state.questionsPageModel.countryId == 0) {
            Locale currentLocale = WidgetsBinding.instance.window.locale;
            String languageCode = currentLocale.languageCode; // 'tr'
            String countryCode = currentLocale.languageCode; // 'TR'

            var tblLocL1Country = await appRepositories.tblLocL1Country(
              'Question/GetObject',
              ['id', 'countrycode'],
            );
            state.questionsPageModel.countryId = tblLocL1Country.firstValue(
                'data', 'id',
                filterColumn: 'countrycode',
                filterValue: countryCode.toUpperCase(),
                insteadOfNull: 0);

            var userDataSet = await appRepositories.tblUserMain(
                'Question/GetObject', ['id', 'country_id'],
                id: widget.userId);
            state.questionsPageModel.countryId = userDataSet.firstValue(
                'data', 'country_id',
                insteadOfNull: state.questionsPageModel.countryId);
          }
          state.questionsPageModel.selectedLearn = null;
          setState(() {});
        },
        selectedItem: state.questionsPageModel.branchId,
        componentTextStyle: widget.componentTextStyle);
  }

  Future<CommonDropdownButtonFormField> filterDifficultyLevels(
      LoadedState state) async {
    var difficultyDataSet = state.questionsPageModel.difficultiesRootDataSet ??
        await appRepositories
            .tblUtilDifficulty('Question/GetObject', ['id', 'dif_level']);

    state.questionsPageModel.difficultiesRootDataSet ??= difficultyDataSet;

    var difficulties = state.questionsPageModel.difficultiesRoot ??
        difficultyDataSet.toKeyValuePairsWithTypes<int, String>('data', 'id',
            valueColumn: 'dif_level');
    //Add NotSelectableItem
    difficulties[0] = AppLocalization.instance.translate(
        'lib.screen.common.questionDataTable', 'filterDifficultyLevels', 'all');

    state.questionsPageModel.difficultiesRoot ??= difficulties;

    var defaultDifficulty = true
        ? 0
        : state.questionsPageModel.difficultyId ??
            difficultyDataSet.firstValue('data', 'id',
                filterColumn: 'dif_level',
                filterValue: 'dif_medium',
                insteadOfNull: difficulties.entries.first.key);
    state.questionsPageModel.difficultyId ??= defaultDifficulty;

    return CommonDropdownButtonFormField(
        isExpandedObject: true,
        isSearchEnable: true,
        items: difficulties,
        label: AppLocalization.instance.translate(
            'lib.screen.common.questionDataTable',
            'filterDifficultyLevels',
            'difficultyLevel'),
        onSelectedItemChanged: (selectedItem) {
          state.questionsPageModel.difficultyId = difficulties.entries
              .map((entry) => entry)
              .toList()
              .firstWhere((item) => selectedItem == item.key)
              .key;
        },
        selectedItem: difficulties.entries
            .map((entry) => entry)
            .toList()
            .firstWhere(
                (item) => state.questionsPageModel.difficultyId == item.key)
            .value,
        componentTextStyle: widget.componentTextStyle);
  }

  StatefulWidget filterQuestionText(LoadedState state) {
    return CommonTextFormField(
        directionText: AppLocalization.instance.translate(
            'lib.screen.common.questionDataTable',
            'filterQuestionText',
            'questionKeyWordsDirectionText'),
        controller: state.questionsPageModel.filterQuestionTextController,
        labelText: AppLocalization.instance.translate(
            'lib.screen.common.questionDataTable',
            'filterQuestionText',
            'questionKeyWords'));
  }
}
