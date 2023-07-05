import 'package:egitimaxapplication/bloc/bloc/question/questionBloc.dart';
import 'package:egitimaxapplication/bloc/event/question/questionEvent.dart';
import 'package:egitimaxapplication/bloc/state/question/questionState.dart';
import 'package:egitimaxapplication/model/question/questionPageModel.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/question/questionRepository.dart';
import 'package:egitimaxapplication/screen/common/collapsibleItemBuilder.dart';
import 'package:egitimaxapplication/screen/common/commonDropdownButtonFormField.dart';
import 'package:egitimaxapplication/screen/common/isPublicCheckBox.dart';
import 'package:egitimaxapplication/screen/common/keyValuePairs.dart';
import 'package:egitimaxapplication/screen/common/learnLevels.dart';
import 'package:egitimaxapplication/screen/common/webViewPage.dart';
import 'package:egitimaxapplication/screen/questionPage/questionOptionsPage.dart';
import 'package:egitimaxapplication/screen/questionPage/questionPageComponents/questionQuillHtmlEditor.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/constant/language/appLocalizationConstant.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:egitimaxapplication/utils/helper/getDeviceType.dart';
import 'package:egitimaxapplication/utils/widget/appBar/innerAppBar.dart';
import 'package:egitimaxapplication/utils/widget/layout/mainLayout.dart';
import 'package:egitimaxapplication/utils/widget/message/uIMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:quill_html_editor/quill_html_editor.dart';



import 'stepsValidator.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key,
    required this.userId,
    required this.isEditorMode,
    this.questionId});

  final bool isEditorMode;
  final BigInt userId;
  final BigInt? questionId;

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  GetIt getIt = GetIt.instance;
  late QuestionBloc questionBloc;
  int _activeCurrentStep = 0;
  late QuestionPageModel questionPageModel;
  QuestionRepository questionRepository = QuestionRepository();
  AppRepositories appRepositories = AppRepositories();

  final componentTextStyle = const TextStyle(
      fontSize: 12,
      color: Colors.black,
      locale: AppLocalizationConstant.DefaultLocale);
  double? iconSize = 12;
  bool? isAllChecked = false;

  final customToolBarList = [
    ToolBarStyle.bold,
    ToolBarStyle.italic,
    ToolBarStyle.underline,
    //ToolBarStyle.strike,
    //ToolBarStyle.blockQuote,
    //ToolBarStyle.codeBlock,
    //ToolBarStyle.indentMinus,
    //ToolBarStyle.indentAdd,
    //ToolBarStyle.directionRtl,
    ToolBarStyle.subscript,
    ToolBarStyle.superscript,
    //ToolBarStyle.directionLtr,
    //ToolBarStyle.headerOne,
    //ToolBarStyle.headerTwo,
    ToolBarStyle.color,
    //ToolBarStyle.background,
    //ToolBarStyle.align,
    ToolBarStyle.listOrdered,
    ToolBarStyle.listBullet,
    ToolBarStyle.size,
    //ToolBarStyle.link,
    ToolBarStyle.image,
    //ToolBarStyle.video,
    //ToolBarStyle.clean,
    ToolBarStyle.undo,
    ToolBarStyle.redo,
    //ToolBarStyle.clearHistory,
  ];
  late QuillEditorController questionController = QuillEditorController();

  Widget getStepOneLayout(BuildContext context) {
    var deviceType = getDeviceType(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(),
        const SizedBox(height: 8),
        questionQuillHtmlEditorObject(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget getStepTwoLayout(BuildContext context) {
    var deviceType = getDeviceType(context);

    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          alignment: WrapAlignment.start,
          runSpacing: 10,
          spacing: 10,
          children: [
            publicCheckBox(),
            academicYearDropdownButtonFormField(),
            difficultyLevelDropdownButtonFormField(),
            gradeDropdownButtonFormField(),
            branchDropdownButtonFormField(),
            SizedBox(
              width: double.infinity,
              child: LearnLevels(
                  learnId: questionPageModel.selectedLearn,
                  branchId: questionPageModel.selectedBranch,
                  gradeId: questionPageModel.selectedGrade,
                  countryId:questionPageModel.selectedCountry,
                  onChangedLearnId:(selectedLearnId){
                    questionPageModel.selectedLearn=selectedLearnId;
                    questionPageModel.selectedSubDomain=selectedLearnId;
                    setState(() {});
                  },
                  onChangedSelectedAchievements: (selectedAchievements){
                    questionPageModel.selectedAchievements=selectedAchievements ?? {};
                  },
                  onChangedAchievements:(achievements){
                    questionPageModel.achievements=achievements ?? {};
                  },
                  selectedAchievements:questionPageModel.selectedAchievements,
                  componentTextStyle: componentTextStyle),
            ),
          ],
        ),
      ),
    );
    return Container();
  }

  Widget getStepThreeLayout(BuildContext context) {
    String fullHtmlStringQQOAS = questionOverViewHtmlStringCreator();

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(5),
            child: WebViewPage(
              htmlContent: fullHtmlStringQQOAS, textStyle: componentTextStyle,),
          ),
          if (false)
            QuestionQuillHtmlEditorObject(
                editorBackGroundColor: Colors.transparent,
                showBoxDecoration: true,
                viewOnly: true,
                viewOnlyHtmlString: fullHtmlStringQQOAS,
                componentTextStyle: componentTextStyle),
          const SizedBox(
            height: 8,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: FutureBuilder<Widget>(
              future: getSelectedOptionsTable(),
              builder:
                  (BuildContext context, AsyncSnapshot<Widget> innerSnapshot) {
                if (innerSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (innerSnapshot.hasError) {
                  return Text('Error: ${innerSnapshot.error}');
                } else if (innerSnapshot.hasData) {
                  return innerSnapshot.data!;
                } else {
                  return Container();
                }
              },
            ),
          ),
          const SizedBox(
            height: 8,
          ),
/*          const SizedBox(height: 8,),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(5),
            child: getSelectedAchievementsTable(),
          ),*/
        ],
      ),
    );
  }

  String questionOverViewHtmlStringCreator() {
     String questionTitle = AppLocalization.instance.translate(
        'lib.screen.questionPage.questionPage',
        'getStepThreeLayout',
        'questionTitle');
    String optionsTitle = '';
    String optionsList = '';
     if (questionPageModel != null && questionPageModel.options!.isNotEmpty) {
       String optionsTable = '<table style="border-collapse: separate; border-spacing: 1px; text-align: center;">';

       for (var op in questionPageModel.options!) {
         String column1 = '<td style="border: none; white-space: nowrap; text-align: left; min-width: 5ch; padding: 5px;"><strong>${op.mark.toString()}</strong></td>';
         String column2 = '<td style="border: none; word-wrap: break-word; text-align: left; padding: 0px;">${op.data.toString()}</td>';
         String column3 = '<td style="border: none; word-wrap: break-word; text-align: left; padding: 0px;">${(op.isCorrect == true ? '&#10004;' : '')}</td>';

         String row = '<tr>$column3$column1$column2</tr>';

         optionsTable += row;
       }

       optionsTable += '</table>';

       optionsList = optionsTable;
     }


     String resolutionTitle = AppLocalization.instance.translate(
        'lib.screen.questionPage.questionPage',
        'getStepThreeLayout',
        'resolutionTitle');

    String fullHtmlStringQQOAS = '''<p>
                        <strong style="color: rgb(0, 0, 0);">
                          <u>$questionTitle</u>
                        </strong>
                      </p>
                      <p>
                        <span style="color: rgb(0, 0, 0);">${questionPageModel
        .question}</span>
                      </p>
                      <p>
                        <strong style="color: rgb(0, 0, 0);">
                          <u>$optionsTitle</u>
                        </strong>
                      </p>
                       $optionsList     
                      <p>
                        <br>
                      </p>
                      ''';
    String existSolutionText = '''
                      <p>
                        <strong style="color: rgb(0, 0, 0);"><u>$resolutionTitle</u></strong>
                      </p>
                      <p>
                        <span style="color: rgb(0, 0, 0);">${questionPageModel
        .freeTextAnswer}</span>
                      </p>
                      ''';

    if (questionPageModel.freeTextAnswer != null &&
        questionPageModel.freeTextAnswer != '') {
      fullHtmlStringQQOAS = fullHtmlStringQQOAS + existSolutionText;
    }
    return fullHtmlStringQQOAS;
  }

  QuestionQuillHtmlEditorObject questionQuillHtmlEditorObject() {
    return QuestionQuillHtmlEditorObject(
        viewOnly: false,
        questionPageModel: questionPageModel,
        questionController: questionController,
        componentTextStyle: componentTextStyle,
        onFocusChanged: (hasFocus) {
          if (!hasFocus) {}
        },
        onTextChanged: (text) {
          setQuestion(text);
        });
  }

  CommonDropdownButtonFormField gradeDropdownButtonFormField() {
    return CommonDropdownButtonFormField(
       isSearchEnable: true,
        label: AppLocalization.instance.translate(
            'lib.screen.questionPage.questionPage',
            'gradeDropdownButtonFormField',
            'grade'),
        items: questionPageModel.grades,
        selectedItem: questionPageModel.selectedGrade,
        onSelectedItemChanged: (value) {
          questionPageModel.selectedGrade = value;
          questionPageModel.selectedBranch = null;
          questionPageModel.selectedLearn = null;
          setState(() {

          });
        },
        componentTextStyle: componentTextStyle);
  }

  CommonDropdownButtonFormField branchDropdownButtonFormField() {
    return CommonDropdownButtonFormField(
      label: AppLocalization.instance.translate(
          'lib.screen.questionPage.questionPage',
          'branchDropdownButtonFormField',
          'branch'),
        isSearchEnable: true,
        items: questionPageModel.branches,
        selectedItem: questionPageModel.selectedBranch,
        onSelectedItemChanged: (selectedBranch) {

          questionPageModel.selectedBranch = selectedBranch;
          questionPageModel.selectedLearn = null;

          setState(() {});
        },
        componentTextStyle: componentTextStyle);
  }

  CommonDropdownButtonFormField difficultyLevelDropdownButtonFormField() {
    return CommonDropdownButtonFormField(
      label:  AppLocalization.instance.translate(
          'lib.screen.questionPage.questionPage',
          'difficultyLevelDropdownButtonFormField',
          'difficultyLevel'),
        isSearchEnable: true,
        items: questionPageModel.difficultyLevels,
        selectedItem: questionPageModel.selectedDifficultyLevel,
        onSelectedItemChanged: (value) {
          questionPageModel.selectedDifficultyLevel = value;
        },
        componentTextStyle: componentTextStyle);
  }

  isPublicCheckBox publicCheckBox() {
    return isPublicCheckBox(
        componentTextStyle: componentTextStyle,
        isPublic: questionPageModel.isPublic,
        onChanged: (value) {
          questionPageModel.isPublic = value;
        });
  }

  CommonDropdownButtonFormField academicYearDropdownButtonFormField() {
    return CommonDropdownButtonFormField(
      label: AppLocalization.instance.translate(
          'lib.screen.questionPage.questionPage',
          'academicYearDropdownButtonFormField',
          'academicYear'),
        isSearchEnable: true,
        items: questionPageModel.academicYears,
        selectedItem: questionPageModel.selectedAcademicYear,
        onSelectedItemChanged: (value) {
          questionPageModel.selectedAcademicYear = value;
        },
        componentTextStyle: componentTextStyle);
  }

  Future<Widget> getSelectedOptionsTable() async {
    Map<String, String> data = {
      AppLocalization.instance.translate('lib.screen.questionPage.questionPage',
          'getSelectedOptionsTable', 'country'):
      questionPageModel.countries[questionPageModel.selectedCountry ?? 0] ??
          '',
      AppLocalization.instance.translate('lib.screen.questionPage.questionPage',
          'getSelectedOptionsTable', 'grade'):
      questionPageModel.grades[questionPageModel.selectedGrade ?? 0] ?? '',
      AppLocalization.instance.translate('lib.screen.questionPage.questionPage',
          'getSelectedOptionsTable', 'academicYear'): questionPageModel
          .academicYears[questionPageModel.selectedAcademicYear ?? 0] ??
          '',
      AppLocalization.instance.translate('lib.screen.questionPage.questionPage',
          'getSelectedOptionsTable', 'questionType'): questionPageModel
          .questionTypes[questionPageModel.selectedQuestionType ?? 0] ??
          '',
      AppLocalization.instance.translate('lib.screen.questionPage.questionPage',
          'getSelectedOptionsTable', 'isPublic'):
      questionPageModel.isPublic == true
          ? AppLocalization.instance.translate(
          'lib.screen.questionPage.questionPage',
          'getSelectedOptionsTable',
          'isPublicYes')
          : AppLocalization.instance.translate(
          'lib.screen.questionPage.questionPage',
          'getSelectedOptionsTable',
          'isPublicNo'),
      AppLocalization.instance.translate(
          'lib.screen.questionPage.questionPage',
          'getSelectedOptionsTable',
          'difficultyLevel'): questionPageModel.difficultyLevels[
      questionPageModel.selectedDifficultyLevel ?? 0] ??
          '',
      AppLocalization.instance.translate('lib.screen.questionPage.questionPage',
          'getSelectedOptionsTable', 'branch'):
      questionPageModel.branches[questionPageModel.selectedBranch ?? 0] ??
          '',
      // AppLocalization.instance.translate('lib.screen.questionPage.questionPage',
      //         'getSelectedOptionsTable', 'domain'):
      //     questionPageModel.domains[questionPageModel.selectedDomain ?? 0] ??
      //         '',
      // AppLocalization.instance.translate('lib.screen.questionPage.questionPage',
      //     'getSelectedOptionsTable', 'subDomain'): questionPageModel
      //         .subDomains[questionPageModel.selectedSubDomain ?? 0] ??
      //     ''
    };


    var learnMainHierarchiesDataSet =
    await appRepositories.tblLearnMainHierarchies(
      'Question/GetObject',
      questionPageModel.selectedLearn ?? 0,
      branch_id: questionPageModel.selectedBranch,
      grade_id: questionPageModel.selectedGrade,
    );

    var achievementTreeList = learnMainHierarchiesDataSet.selectDataTable('data');

    String? achievementTree = '';
    for (var levelItem in achievementTreeList) {
      var name = levelItem['name'];
      var type = levelItem['type'];

      if (achievementTree!.isEmpty || achievementTree == null) {
        achievementTree += name;
      } else {
        achievementTree += ' >> $name';
      }
    }

    data[AppLocalization.instance.translate(
        'lib.screen.questionPage.questionPage',
        'getSelectedOptionsTable',
        'learn')] = achievementTree ?? '';


    for(var achvId in questionPageModel.selectedAchievements)
      {
        var tblLearnMainDataSet= await appRepositories.tblLearnMain('Question/GetObject', ['id','item_code','name'],id: achvId);
        var achCode=tblLearnMainDataSet.firstValue('data','item_code',insteadOfNull: '?');
        var achName=tblLearnMainDataSet.firstValue('data','name',insteadOfNull: '?');
        data[achCode] = achName;
      }

    List<Wrap> list = [];
    data.forEach((itemKey, itemValue) {
      list.add(
        Wrap(
            children: [Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    '$itemKey :',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Text(
                    itemValue,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),]
        ),
      );

    });

    var result=CollapsibleItemBuilder(items: [
      CollapsibleItemData(
          header: Text(AppLocalization.instance.translate(
              'lib.screen.questionPage.questionPage',
              'getSelectedOptionsTable',
              'questionDetails'),style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Wrap(spacing: 5.0, runSpacing: 2.0, children:list),
          padding: 3,
          onStateChanged: (bool ) {  })
    ],
      padding: 3,
      onStateChanged: (bool ) {  },
    );
    return result;
  }

  @override
  void initState() {
    super.initState();

    // Create a new instance of QuestionPageModel based on the widget parameters
    questionPageModel = QuestionPageModel(
        userId: widget.userId,
        questionId: widget.questionId,
        isEditorMode: widget.isEditorMode);

    // Determine the active step based on the widget parameters
    if (widget.isEditorMode == true &&
        (widget.questionId == null || widget.questionId == BigInt.zero)) {
      _activeCurrentStep = 0; // Step 1
    } else if (widget.isEditorMode == true &&
        widget.questionId != null &&
        widget.questionId! > BigInt.zero) {
      _activeCurrentStep = 2; // Step 3
    } else {
      _activeCurrentStep = 2; // Step 3
    }

    // Create a new instance of QuestionBloc
    questionBloc = QuestionBloc();

    // Send an InitEvent to the questionBloc with the questionPageModel parameter
    questionBloc.add(InitEvent(questionPageModel: questionPageModel));

    // Initialize the controllers used in this widget
    setQuestionAndOptionsControllers();
  }

  @override
  Widget build(BuildContext context) {
    _activeCurrentStep = 0;
    return BlocProvider(
      create: (_) => questionBloc,
      child: Scaffold(
        appBar: InnerAppBar(
          title: AppLocalization.instance.translate(
              'lib.screen.questionPage.questionPage',
              'build',
              'questionOperations'),
        ),
        body: BlocBuilder<QuestionBloc, QuestionState>(
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

  Future<void> setQuestion(String? htmlString) async {
    questionPageModel.question = htmlString;
  }

  Future<void> setQuestionFreeTextAnswer(String? freeTextAnswer) async {
    questionPageModel.freeTextAnswer = freeTextAnswer;
  }

  void setQuestionAndOptionsControllers() {
    if (questionPageModel.question != null &&
        questionPageModel.question!.isNotEmpty) {
      questionController.setText(questionPageModel.question!);
    }
  }

  List<Step> questionOperationsSteps(BuildContext context,QuestionState state) {
    var qOSteps = [
      Step(
        state: _activeCurrentStep <= 0 ? StepState.editing : StepState.indexed,
        isActive: _activeCurrentStep >= 0,
        title: Text(AppLocalization.instance.translate(
            'lib.screen.questionPage.questionPage',
            'questionOperationsSteps',
            'questionText')),
        subtitle: Text(AppLocalization.instance.translate(
            'lib.screen.questionPage.questionPage',
            'questionOperationsSteps',
            'questionTextDetails')),
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
            'lib.screen.questionPage.questionPage',
            'questionOperationsSteps',
            'subjectAndAchievements')),
        subtitle: Text(AppLocalization.instance.translate(
            'lib.screen.questionPage.questionPage',
            'questionOperationsSteps',
            'subjectAndAchievementsDetails')),
        //subtitle: const Text('Fill in the details'),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: getStepTwoLayout(context),
        ),
      ),
      Step(
        state: _activeCurrentStep <= 2 ? StepState.editing : StepState.indexed,
        isActive: _activeCurrentStep >= 2,
        title: Text(AppLocalization.instance.translate(
            'lib.screen.questionPage.questionPage',
            'questionOperationsSteps',
            'summaryAndSubmit')),
        subtitle: Text(AppLocalization.instance.translate(
            'lib.screen.questionPage.questionPage',
            'questionOperationsSteps',
            'summaryAndSubmitDetails')),
        //subtitle: const Text('Please check and submit !'),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: getStepThreeLayout(context),
        ),
      ),
    ];
    return qOSteps;
  }

  void questionBlocAddEvent(int? activeCurrentStep) {
    switch (activeCurrentStep) {
      case 0:
        questionBloc.add(Step1Event(questionPageModel: questionPageModel));
        break;
      case 1:
        questionBloc.add(Step2Event(questionPageModel: questionPageModel));
        break;
      case 2:
        questionBloc.add(Step3Event(questionPageModel: questionPageModel));
        break;
      default:
        break;
    }
  }

  Widget _buildStepper(BuildContext context, QuestionState state) {
    var qOStepsCount = questionOperationsSteps(context, state).length;
    return Stepper(
      type: StepperType.vertical,
      currentStep: _activeCurrentStep,
      steps: questionOperationsSteps(context, state),
      onStepContinue: () {
        if (_activeCurrentStep < (qOStepsCount - 1)) {
          setState(() {
            _activeCurrentStep += 1;
            questionBlocAddEvent(_activeCurrentStep);
          });
        } else {
          //Save Pressed
          questionBloc.add(SavePmEvent(questionPageModel: questionPageModel));
        }
      },
      onStepCancel: () {
        if (_activeCurrentStep == 0) {
          return;
        }
        setState(() {
          _activeCurrentStep -= 1;
          questionBlocAddEvent(_activeCurrentStep);
        });
      },
      onStepTapped: (int index) {
        setState(() {
          _activeCurrentStep = index;
          questionBlocAddEvent(_activeCurrentStep);
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MainLayout(
                                  loadedStateContainer: QuestionOptions(
                                    questionPageModel: questionPageModel,
                                    setQuestionPageModel: (
                                        newQuestionPageModel) {
                                      if (newQuestionPageModel != null) {
                                        questionPageModel.options =
                                            newQuestionPageModel.options;
                                        questionPageModel.freeTextAnswer =
                                            newQuestionPageModel.freeTextAnswer;
                                      }
                                    },
                                    setActiveCurrentStep: (nextStepId) {
                                      if (nextStepId != null) {
                                        setState(() {
                                          questionBlocAddEvent(nextStepId);
                                          _activeCurrentStep = nextStepId;
                                        });
                                      }
                                    },
                                  ),
                                  context: context,
                                ),
                          ),
                        );
                      },
                      child: Text(AppLocalization.instance.translate(
                          'lib.screen.questionPage.questionPage',
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
                                'lib.screen.questionPage.questionPage',
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
                                'lib.screen.questionPage.questionPage',
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
                                'lib.screen.questionPage.questionPage',
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
                              questionBloc.add(SavePmEvent(
                                  questionPageModel: questionPageModel));
                            },
                            child: Text(AppLocalization.instance.translate(
                                'lib.screen.questionPage.questionPage',
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

  Widget _buildInit(BuildContext context, QuestionState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(AppLocalization.instance.translate(
              'lib.screen.questionPage.questionPage',
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
                'lib.screen.questionPage.questionPage',
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
    questionPageModel = state.questionPageModel;
    setQuestionAndOptionsControllers();
    questionBlocAddEvent(_activeCurrentStep);
    return Container();
  }

  Widget _buildError(BuildContext context, ErrorState state) {
    String errorMessage;
    if (state is ErrorState) {
      errorMessage = state.errorMessage;
    } else {
      errorMessage = AppLocalization.instance.translate(
          'lib.screen.questionPage.questionPage',
          '_buildError',
          'unknownError');
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.0,
            color: Theme
                .of(context)
                .colorScheme
                .error,
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
                'lib.screen.questionPage.questionPage',
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
          'lib.screen.questionPage.questionPage',
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
            color: Theme
                .of(context)
                .colorScheme
                .error,
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
                'lib.screen.questionPage.questionPage',
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
    if (StepsValidator(questionPageModel).validateStep1()) {
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
          'lib.screen.questionPage.questionPage',
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
            color: Theme
                .of(context)
                .colorScheme
                .error,
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
                'lib.screen.questionPage.questionPage',
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
    if (StepsValidator(questionPageModel).validateStep1()) {
      if (StepsValidator(questionPageModel).validateStep2()) {
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
          'lib.screen.questionPage.questionPage',
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
            color: Theme
                .of(context)
                .colorScheme
                .error,
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
                'lib.screen.questionPage.questionPage',
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
                'lib.screen.questionPage.questionPage',
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
                'lib.screen.questionPage.questionPage',
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
                'lib.screen.questionPage.questionPage',
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
        AppLocalization.instance.translate(
            'lib.screen.questionPage.questionPage',
            '_buildSavedPm',
            'questionSaved'),
        gravity: ToastGravity.CENTER);
    _activeCurrentStep = 2;
    return _buildStepper(context, state);
  }

  Widget _buildErrorPm(BuildContext context, ErrorPmState state) {
    UIMessage.showSuccess(
        AppLocalization.instance.translate(
            'lib.screen.questionPage.questionPage',
            '_buildSavedPm',
            'questionNotSaved'),
        gravity: ToastGravity.CENTER);

    _activeCurrentStep = 2;
    return _buildStepper(context, state);
  }
}
