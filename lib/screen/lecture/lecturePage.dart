import 'package:egitimaxapplication/bloc/bloc/lecture/lectureBloc.dart';
import 'package:egitimaxapplication/bloc/state/lecture/lectureState.dart';
import 'package:egitimaxapplication/model/lecture/lecturePageModel.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/lecture/lectureRepository.dart';
import 'package:egitimaxapplication/screen/common/collapsibleItemBuilder.dart';
import 'package:egitimaxapplication/screen/common/commonDropdownButtonFormField.dart';
import 'package:egitimaxapplication/screen/common/commonTextFormField.dart';
import 'package:egitimaxapplication/screen/common/learnLevels.dart';
import 'package:egitimaxapplication/screen/common/userInteractiveMessage.dart';
import 'package:egitimaxapplication/screen/lecture/stepsValidator.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/constant/language/appLocalizationConstant.dart';
import 'package:egitimaxapplication/utils/widget/appBar/innerAppBar.dart';
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

  List<Step> LectureOperationsSteps(BuildContext context, LectureState state) {
    var vSteps = [
      Step(
        state: _activeCurrentStep <= 0 ? StepState.editing : StepState.complete,
        isActive: _activeCurrentStep >= 0,
        title: Text(AppLocalization.instance.translate(
            'lib.screen.lecturePage.lecturePage',
            'LectureOperationsSteps',
            'lectureCreate')),
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
        state: _activeCurrentStep <= 1 ? StepState.editing : StepState.complete,
        isActive: _activeCurrentStep >= 1,
        title: Text(AppLocalization.instance.translate(
            'lib.screen.lecturePage.lecturePage',
            'LectureOperationsSteps',
            'createFlow')),
        //subtitle: const Text('Fill in the details'),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: getStepTwoLayout(context),
        ),
      ),
      Step(
        state: _activeCurrentStep <= 2 ? StepState.editing : StepState.complete,
        isActive: _activeCurrentStep >= 2,
        title: Text(AppLocalization.instance.translate(
            'lib.screen.lecturePage.lecturePage',
            'LectureOperationsSteps',
            'summaryAndSubmit')),
        //subtitle: const Text('Please check and submit !'),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: getStepThreeLayout(context),
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
                        'clickWelcomeMsg')),
                    content: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: CommonTextFormField(
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
                          setState(() {});
                        },
                      ),
                    ),
                    padding: 0,
                    onStateChanged: (value) {
                      isWelcomeMsgCollapsed = !isWelcomeMsgCollapsed;
                    })
              ],
              padding: 0,
              onStateChanged: (value) {
                isWelcomeMsgCollapsed = !isWelcomeMsgCollapsed;
              }),
          CollapsibleItemBuilder(
              items: [
                CollapsibleItemData(
                    isExpanded: isGoodbyeMsgCollapsed,
                    header: Text(AppLocalization.instance.translate(
                        'lib.screen.lecturePage.lecturePage',
                        'getStepOneLayout',
                        'clickGoodbyeMsg')),
                    content: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: CommonTextFormField(
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
                          setState(() {});
                        },
                      ),
                    ),
                    padding: 0,
                    onStateChanged: (value) {
                      isGoodbyeMsgCollapsed = !isGoodbyeMsgCollapsed;
                    })
              ],
              padding: 0,
              onStateChanged: (value) {
                isGoodbyeMsgCollapsed = !isGoodbyeMsgCollapsed;
              }),

          if (false)
            TextButton(
              onPressed: () {
                setState(() {
                  isWelcomeMsgCollapsed = !isWelcomeMsgCollapsed;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalization.instance.translate(
                      'lib.screen.lecturePage.lecturePage',
                      'getStepOneLayout',
                      'clickWelcomeMsg')),
                  Icon(!isWelcomeMsgCollapsed
                      ? Icons.arrow_drop_up_outlined
                      : Icons.arrow_drop_down_outlined),
                ],
              ),
            ),
          if (!isWelcomeMsgCollapsed && false)
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: CommonTextFormField(
                controller: welcomeMsgTextController,
                labelText: AppLocalization.instance.translate(
                    'lib.screen.lecturePage.lecturePage',
                    'getStepOneLayout',
                    'welcomeMsg'),
                maxLines: null,
                minLines: 1,
                onChanged: (text) {
                  lecturePageModel
                      .setLectureObjects!.tblCrsCourseMain!.welcomeMsg = text;
                },
              ),
            ),
          if (false)
          TextButton(
            onPressed: () {
              setState(() {
                isGoodbyeMsgCollapsed = !isGoodbyeMsgCollapsed;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalization.instance.translate(
                    'lib.screen.lecturePage.lecturePage',
                    'getStepOneLayout',
                    'clickGoodbyeMsg')),
                Icon(!isGoodbyeMsgCollapsed
                    ? Icons.arrow_drop_up_outlined
                    : Icons.arrow_drop_down_outlined),
              ],
            ),
          ),
          if (!isGoodbyeMsgCollapsed && false)
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: CommonTextFormField(
                controller: goodbyeMsgTextController,
                labelText: AppLocalization.instance.translate(
                    'lib.screen.lecturePage.lecturePage',
                    'getStepOneLayout',
                    'goodbyeMsg'),
                maxLines: null,
                minLines: 1,
                onChanged: (text) {
                  lecturePageModel
                      .setLectureObjects!.tblCrsCourseMain!.goodbyeMsg = text;
                },
              ),
            ),
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

  Widget getStepTwoLayout(BuildContext context) {
    return Container();
  }

  Widget getStepThreeLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container();
  }

  void LectureBlocAddEvent(int? activeCurrentStep) {
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
    var qOStepsCount = LectureOperationsSteps(context, state).length;
    return Stepper(
      type: StepperType.vertical,
      currentStep: _activeCurrentStep,
      steps: LectureOperationsSteps(context, state),
      onStepContinue: () {
        if (_activeCurrentStep < (qOStepsCount - 1)) {
          setState(() {
            _activeCurrentStep += 1;
            LectureBlocAddEvent(_activeCurrentStep);
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
          LectureBlocAddEvent(_activeCurrentStep);
        });
      },
      onStepTapped: (int index) {
        setState(() {
          _activeCurrentStep = index;
          LectureBlocAddEvent(_activeCurrentStep);
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
    LectureBlocAddEvent(_activeCurrentStep);
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
