import 'package:egitimaxapplication/bloc/bloc/quiz/quizBloc.dart';
import 'package:egitimaxapplication/bloc/event/quiz/quizEvent.dart';
import 'package:egitimaxapplication/bloc/state/quiz/quizState.dart';
import 'package:egitimaxapplication/model/quiz/quizPageModel.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/quiz/quizRepository.dart';
import 'package:egitimaxapplication/screen/common/commonDropdownButtonFormField.dart';
import 'package:egitimaxapplication/screen/common/commonTextFormField.dart';
import 'package:egitimaxapplication/screen/common/userInteractiveMessage.dart';
import 'package:egitimaxapplication/screen/common/webViewPage.dart';
import 'package:egitimaxapplication/screen/quizPage/quizSectionDataTable.dart';
import 'package:egitimaxapplication/screen/quizPage/stepsValidator.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/constant/language/appLocalizationConstant.dart';
import 'package:egitimaxapplication/utils/widget/appBar/innerAppBar.dart';
import 'package:egitimaxapplication/utils/widget/message/uIMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class QuizPage extends StatefulWidget {
  const QuizPage(
      {super.key,
      required this.userId,
      required this.isEditorMode,
      this.quizId});

  final bool isEditorMode;
  final BigInt userId;
  final BigInt? quizId;

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _activeCurrentStep = 0;
  late QuizBloc quizBloc;
  late QuizPageModel quizPageModel;
  QuizRepository quizRepository = QuizRepository();
  AppRepositories appRepositories = AppRepositories();
  final componentTextStyle = const TextStyle(
      fontSize: 10,
      color: Colors.black,
      locale: AppLocalizationConstant.DefaultLocale);
  double? iconSize = 12;
  bool isHeaderTextCollapsed = true;
  bool isFooterTextCollapsed = true;

  @override
  void initState() {
    super.initState();

    quizPageModel = QuizPageModel(
        userId: widget.userId,
        quizId: widget.quizId,
        isEditorMode: widget.isEditorMode);
    quizBloc = QuizBloc();

    quizBloc.add(InitEvent(quizPageModel: quizPageModel));
  }

  void showAcceptConditionsConfirmationDialog(BuildContext context) {
    UserInteractiveMessage(
      title: AppLocalization.instance.translate(
          'lib.screen.videoPage.videoPage',
          'showVideoUploadAcceptConditionsConfirmationDialog',
          'confirmation'),
      message: AppLocalization.instance.translate(
          'lib.screen.videoPage.videoPage',
          'showVideoUploadAcceptConditionsConfirmationDialog',
          'message'),
      yesButtonText: AppLocalization.instance.translate(
          'lib.screen.videoPage.videoPage',
          'showVideoUploadAcceptConditionsConfirmationDialog',
          'yesButtonText'),
      noButtonText: AppLocalization.instance.translate(
          'lib.screen.videoPage.videoPage',
          'showVideoUploadAcceptConditionsConfirmationDialog',
          'noButtonText'),
      onSelection: (bool value) {
        if (value) {
          quizPageModel.isAcceptConditions = true;
        } else {
          quizPageModel.isAcceptConditions = false;
        }
        setState(() {});
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => quizBloc,
      child: Scaffold(
        appBar: const InnerAppBar(
          title: 'Quiz Operations',
        ),
        body: BlocBuilder<QuizBloc, QuizState>(
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

  List<Step> quizOperationsSteps(BuildContext context, QuizState state) {
    var vSteps = [
      Step(
        state: _activeCurrentStep <= 0 ? StepState.editing : StepState.complete,
        isActive: _activeCurrentStep >= 0,
        title: Text('Quiz Create'),
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
        title: Text('Add Section and Section Question'),
        //subtitle: const Text('Fill in the details'),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: getStepTwoLayout(context),
        ),
      ),
      Step(
        state: _activeCurrentStep <= 2 ? StepState.editing : StepState.complete,
        isActive: _activeCurrentStep >= 2,
        title: Text('Summary And Submit'),
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
    final TextEditingController quizTitleController =
        TextEditingController(text: quizPageModel.quizMain?.title ?? '');
    final TextEditingController quizDescriptionController =
        TextEditingController(text: quizPageModel.quizMain?.description ?? '');
    final TextEditingController quizDurationNumberController =
        TextEditingController(
            text: quizPageModel.quizMain?.duration.toString() ?? '');
    final TextEditingController quizHeaderTextController =
        TextEditingController(text: quizPageModel.quizMain?.headerText ?? '');
    final TextEditingController quizFooterTextController =
        TextEditingController(text: quizPageModel.quizMain?.footerText ?? '');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: WrapAlignment.start,
        runSpacing: 10,
        spacing: 10,
        children: [
          CommonDropdownButtonFormField(
            label: "Academic Year",
            componentTextStyle: componentTextStyle,
            items: quizPageModel.academicYears,
            selectedItem: quizPageModel.quizMain?.academicYear,
            onSelectedItemChanged: (selectedAcademicYear) {
              quizPageModel.quizMain?.academicYear = selectedAcademicYear;
            },
          ),
          CommonDropdownButtonFormField(
            label: "Grade",
            componentTextStyle: componentTextStyle,
            items: quizPageModel.grades,
            selectedItem: quizPageModel.quizMain?.gradeId,
            onSelectedItemChanged: (selectedGrade) {
              quizPageModel.quizMain?.gradeId = selectedGrade;
            },
          ),
          CommonTextFormField(
            controller: quizTitleController,
            labelText: 'Title',
            maxLines: 1,
            minLines: 1,
            onChanged: (text) {
              quizPageModel.quizMain?.title = text;
            },
          ),
          CommonTextFormField(
            controller: quizDescriptionController,
            labelText: 'Descriptions',
            maxLines: 3,
            minLines: 1,
            onChanged: (text) {
              quizPageModel.quizMain?.description = text;
            },
          ),
          CommonTextFormField(
            controller: quizDurationNumberController,
            labelText: 'Duration (Minutes)',
            maxLines: 1,
            minLines: 1,
            onChanged: (text) {
              try {
                final int duration = int.parse(text);
                // Perform necessary checks on duration
                if (duration <= 0) {
                  // Handle invalid duration, show an error message or take appropriate action
                  quizPageModel.quizMain?.duration = 0;
                }

                // Assign the valid duration to quizPageModel.quizMain?.duration
                quizPageModel.quizMain?.duration = duration;
              } catch (e) {
                UIMessage.showError('Please enter a valid number.',
                    gravity: ToastGravity.CENTER);
                quizPageModel.quizMain?.duration = 0;
                setState(() {});
              }
            },
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter a value.';
              }
              if (double.tryParse(value) == null) {
                UIMessage.showError('Please enter a valid number.',
                    gravity: ToastGravity.CENTER);
                quizPageModel.quizMain?.duration = 0;
                return 'Please enter a valid number.';
              }
              return null;
            },
          ),
          TextButton(
            onPressed: () {
              setState(() {
                isHeaderTextCollapsed = !isHeaderTextCollapsed;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Click for Header Information'),
                Icon(!isHeaderTextCollapsed
                    ? Icons.arrow_drop_up_outlined
                    : Icons.arrow_drop_down_outlined),
              ],
            ),
          ),
          if (!isHeaderTextCollapsed)
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: CommonTextFormField(
                controller: quizHeaderTextController,
                labelText: 'Header Information',
                maxLines: null,
                minLines: 1,
                onChanged: (text) {
                  quizPageModel.quizMain?.headerText = text;
                },
              ),
            ),
          TextButton(
            onPressed: () {
              setState(() {
                isFooterTextCollapsed = !isFooterTextCollapsed;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Click for Footer Information'),
                Icon(!isFooterTextCollapsed
                    ? Icons.arrow_drop_up_outlined
                    : Icons.arrow_drop_down_outlined),
              ],
            ),
          ),
          if (!isFooterTextCollapsed)
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: CommonTextFormField(
                controller: quizFooterTextController,
                labelText: 'Footer Information',
                maxLines: null,
                minLines: 1,
                onChanged: (text) {
                  quizPageModel.quizMain?.footerText = text;
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
                      value:
                          quizPageModel.quizMain?.isPublic == 1 ? true : false,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            quizPageModel.quizMain?.isPublic = 1;
                          } else {
                            quizPageModel.quizMain?.isPublic = 0;
                          }
                        });
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (quizPageModel.quizMain?.isPublic == 1) {
                            quizPageModel.quizMain?.isPublic = 0;
                          } else {
                            quizPageModel.quizMain?.isPublic = 1;
                          }
                        });
                      },
                      child: const Text('Can everyone see the exam ?'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Checkbox(
                      value: quizPageModel.isAcceptConditions,
                      onChanged: (value) {
                        setState(() {
                          quizPageModel.isAcceptConditions = value;
                        });
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        showAcceptConditionsConfirmationDialog(context);
                      },
                      child: const Text(
                        'Accept Community Guidelines',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
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
    return Container(
      alignment: Alignment.centerLeft,
      child: QuizSectionDataTable(
        quizPageModel: quizPageModel,
        onChanged: (quizSections) {
          setState(() {});
        },
        componentTextStyle: componentTextStyle,
      ),
    );
  }

  Widget getStepThreeLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      child: FutureBuilder<Widget>(
        future: quizPageModel.generateHtmlDocument(
          quizPageModel.quizMain!,
          context,
        ),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: snapshot.data ?? Container(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator(); // or any other loading indicator
          }
        },
      ),
    );
  }

  void quizBlocAddEvent(int? activeCurrentStep) {
    switch (activeCurrentStep) {
      case 0:
        quizBloc.add(Step1Event(quizPageModel: quizPageModel));
        break;
      case 1:
        quizBloc.add(Step2Event(quizPageModel: quizPageModel));
        break;
      case 2:
        quizBloc.add(Step3Event(quizPageModel: quizPageModel));
        break;
      default:
        break;
    }
  }

  Widget _buildStepper(BuildContext context, QuizState state) {
    var qOStepsCount = quizOperationsSteps(context, state).length;
    return Stepper(
      type: StepperType.vertical,
      currentStep: _activeCurrentStep,
      steps: quizOperationsSteps(context, state),
      onStepContinue: () {
        if (_activeCurrentStep < (qOStepsCount - 1)) {
          setState(() {
            _activeCurrentStep += 1;
            quizBlocAddEvent(_activeCurrentStep);
          });
        } else {
          //Save Pressed
          quizBloc.add(SavePmEvent(quizPageModel: quizPageModel));
        }
      },
      onStepCancel: () {
        if (_activeCurrentStep == 0) {
          return;
        }
        setState(() {
          _activeCurrentStep -= 1;
          quizBlocAddEvent(_activeCurrentStep);
        });
      },
      onStepTapped: (int index) {
        setState(() {
          _activeCurrentStep = index;
          quizBlocAddEvent(_activeCurrentStep);
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
                      child: Text('Next'),
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
                            child: Text('Back'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: controlsDetails.onStepContinue,
                            child: Text('Next'),
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
                            child: Text('Back'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              quizBloc.add(
                                  SavePmEvent(quizPageModel: quizPageModel));
                            },
                            child: Text('Submit'),
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

  Widget _buildInit(BuildContext context, QuizState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(AppLocalization.instance.translate(
              'lib.screen.QuizPage.QuizPage', '_buildInit', 'initializing')),
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
                'lib.screen.QuizPage.QuizPage', '_buildLoading', 'loading'),
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
    quizPageModel = state.quizPageModel;
    quizBlocAddEvent(_activeCurrentStep);
    return Container();
  }

  Widget _buildError(BuildContext context, ErrorState state) {
    String errorMessage;
    if (state is ErrorState) {
      errorMessage = state.errorMessage;
    } else {
      errorMessage = AppLocalization.instance.translate(
          'lib.screen.QuizPage.QuizPage', '_buildError', 'unknownError');
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
            AppLocalization.instance.translate('lib.screen.QuizPage.QuizPage',
                '_buildLoadingStep1', 'firstStepLoading'),
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
          'lib.screen.QuizPage.QuizPage', '_buildErrorStep1', 'unknownError');
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
            AppLocalization.instance.translate('lib.screen.QuizPage.QuizPage',
                '_buildLoadingStep2', 'secondStepLoading'),
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
    if (StepsValidator(quizPageModel).validateStep1()) {
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
          'lib.screen.QuizPage.QuizPage', '_buildErrorStep2', 'unknownError');
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
            AppLocalization.instance.translate('lib.screen.QuizPage.QuizPage',
                '_buildLoadingStep3', 'thirdStepLoading'),
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
    if (StepsValidator(quizPageModel).validateStep1()) {
      if (StepsValidator(quizPageModel).validateStep2()) {
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
          'lib.screen.QuizPage.QuizPage', '_buildErrorStep3', 'unknownError');
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
            AppLocalization.instance.translate('lib.screen.QuizPage.QuizPage',
                '_buildLoadingPm', 'pageModelLoading'),
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
            AppLocalization.instance.translate('lib.screen.QuizPage.QuizPage',
                '_buildDeletingPm', 'pageModelDeleting'),
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
            AppLocalization.instance.translate('lib.screen.QuizPage.QuizPage',
                '_buildRemovingPm', 'pageModelRemoving'),
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
            AppLocalization.instance.translate('lib.screen.QuizPage.QuizPage',
                '_buildSavingPm', 'pageModelSaving'),
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
            'lib.screen.QuizPage.QuizPage', '_buildSavedPm', 'videoSaved'),
        gravity: ToastGravity.CENTER);
    _activeCurrentStep = 2;
    return _buildStepper(context, state);
  }

  Widget _buildErrorPm(BuildContext context, ErrorPmState state) {
    UIMessage.showSuccess(
        AppLocalization.instance.translate(
            'lib.screen.QuizPage.QuizPage', '_buildErrorPm', 'videoNotSaved'),
        gravity: ToastGravity.CENTER);

    _activeCurrentStep = 2;
    return _buildStepper(context, state);
  }
}
