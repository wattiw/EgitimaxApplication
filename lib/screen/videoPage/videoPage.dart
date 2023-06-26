import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/video/videoRepository.dart';
import 'package:egitimaxapplication/screen/common/commonDropdownButtonFormField.dart';
import 'package:egitimaxapplication/screen/common/commonTextFormField.dart';
import 'package:egitimaxapplication/screen/common/learnLevels.dart';
import 'package:egitimaxapplication/screen/common/userInteractiveMessage.dart';
import 'package:egitimaxapplication/screen/common/videoItems.dart';
import 'package:egitimaxapplication/screen/videoPage/stepsValidator.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/constant/language/appLocalizationConstant.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:egitimaxapplication/utils/helper/filePickerHelper.dart';
import 'package:flutter/services.dart';
import 'package:egitimaxapplication/bloc/bloc/video/videoBloc.dart';
import 'package:egitimaxapplication/bloc/event/video/videoEvent.dart';
import 'package:egitimaxapplication/bloc/state/video/videoState.dart';
import 'package:egitimaxapplication/model/video/videoPageModel.dart';
import 'package:egitimaxapplication/utils/widget/appBar/innerAppBar.dart';
import 'package:egitimaxapplication/utils/widget/message/uIMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VideoPage extends StatefulWidget {
  const VideoPage(
      {super.key,
      required this.userId,
      required this.isEditorMode,
      this.videoId});

  final bool isEditorMode;
  final BigInt userId;
  final BigInt? videoId;

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  int _activeCurrentStep = 0;
  late VideoBloc videoBloc;
  late VideoPageModel videoPageModel;
  String? videoObjectId;
  VideoRepository videoRepository = VideoRepository();
  AppRepositories appRepositories = AppRepositories();
  final componentTextStyle = const TextStyle(
      fontSize: 12,
      color: Colors.black,
      locale: AppLocalizationConstant.DefaultLocale);
  double? iconSize = 12;
  bool? isAllChecked = false;
  bool? isUploadOrDelete;
  bool onlyCallNoAction = true; // Dont change
  bool videoProcessing = false; // Dont change

  void showVideoDeleteConfirmationDialog(BuildContext context) {
    UserInteractiveMessage(
      title: AppLocalization.instance.translate(
          'lib.screen.videoPage.videoPage',
          'showVideoDeleteConfirmationDialog',
          'confirmation'),
      message: AppLocalization.instance.translate(
          'lib.screen.videoPage.videoPage',
          'showVideoDeleteConfirmationDialog',
          'message'),
      yesButtonText: AppLocalization.instance.translate(
          'lib.screen.videoPage.videoPage',
          'showVideoDeleteConfirmationDialog',
          'yesButtonText'),
      noButtonText: AppLocalization.instance.translate(
          'lib.screen.videoPage.videoPage',
          'showVideoDeleteConfirmationDialog',
          'noButtonText'),
      onSelection: (bool value) {
        if (value) {
          videoPageModel.videoPlayerController?.dispose();
          videoPageModel.videoPlayerController = null;
          videoPageModel.videoData = null;
          videoRepository.deleteVideo(videoId: videoPageModel.videoId);
          videoRepository.deleteVideo(videoObjectId: videoObjectId);
          setState(() {});
        } else {}
      },
    ).show(context);
  }

  void showVideoUploadAcceptConditionsConfirmationDialog(BuildContext context) {
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
          videoPageModel.isAcceptConditions = true;
        } else {
          videoPageModel.isAcceptConditions = false;
        }
        setState(() {});
      },
    ).show(context);
  }

  Future<void> uploadVideo(
      bool? isUploadOrDelete, bool onlyCallNoAction) async {
    if (!onlyCallNoAction) {
      if (videoPageModel.videoPlayerController == null) {
        var _videoData = await FilePickerHelper.pickFile();

        bool showDurationAlert = false;

        var duration = await _videoData!.getDuration();

        videoPageModel.videoDuration = duration;

        if (_videoData != null && duration != null) {
          if (duration > 180 || duration < 60) {
            showDurationAlert = true;
          }
        } else {
          if (_videoData != null && duration == null) {
            showDurationAlert = true;
          }
        }

        if (showDurationAlert) {
          UIMessage.showError(
              AppLocalization.instance.translate(
                  'lib.screen.videoPage.videoPage',
                  'uploadVideo',
                  'videoDurationAlertMessage'),
              gravity: ToastGravity.CENTER);
        } else {}

        videoPageModel.videoData = _videoData?.data;
        var videoNoSqlId = await videoRepository.uploadVideo(
            videoPageModel.videoData,
            fileName:
                'UserId_${videoPageModel.userId}_${_videoData!.fileName}');
        videoObjectId = videoNoSqlId;
        videoPageModel.videoObjectId = videoNoSqlId;

        videoPageModel.videoPlayerController = null;
        videoRepository
            .downloadVideo(videoObjectId: videoObjectId)
            .then((newVideoData) {
          videoPageModel.videoData = newVideoData;
          setState(() {});
        });

        var newVideoPlayerController =
            await VideoControllerProvider.createController(
                videoData: videoPageModel.videoData);

        if (newVideoPlayerController != null) {
          videoPageModel.videoPlayerController = newVideoPlayerController;
          _activeCurrentStep = 0;
          videoBlocAddEvent(0);
          if (newVideoPlayerController != null) {
            videoPageModel.isVideoContainerExpanded = true;
            videoPageModel.videoUploadStatusText = AppLocalization.instance
                .translate('lib.screen.videoPage.videoPage', 'uploadVideo',
                    'videoUploaded');
          } else {
            videoPageModel.isVideoContainerExpanded = false;
            videoPageModel.videoUploadStatusText = AppLocalization.instance
                .translate('lib.screen.videoPage.videoPage', 'uploadVideo',
                    'videoNotExist');
          }
        }

        setState(() {
          onlyCallNoAction = true; // Dont remove
          videoProcessing = false;
        });
      } else {
        showVideoDeleteConfirmationDialog(context);
        setState(() {
          onlyCallNoAction = true; // Dont remove
          videoProcessing = false;
        });
      }
    } else {
      setState(() {
        onlyCallNoAction = true; // Dont remove
        videoProcessing = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    videoPageModel = VideoPageModel(
        userId: widget.userId,
        videoId: widget.videoId,
        isEditorMode: widget.isEditorMode);
    videoBloc = VideoBloc();

    videoBloc.add(InitEvent(videoPageModel: videoPageModel));
  }
  @override
  void dispose() {
    if(videoPageModel.videoPlayerController!=null)
      {
        videoPageModel.videoPlayerController!.dispose();
      }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => videoBloc,
      child: Scaffold(
        appBar: InnerAppBar(
          title: AppLocalization.instance.translate(
              'lib.screen.videoPage.videoPage', 'build', 'videoOperations'),
        ),
        body: BlocBuilder<VideoBloc, VideoState>(
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

  List<Step> videoOperationsSteps(BuildContext context, VideoState state) {
    var vSteps = [
      Step(
        state: _activeCurrentStep <= 0 ? StepState.editing : StepState.complete,
        isActive: _activeCurrentStep >= 0,
        title: Text(AppLocalization.instance.translate(
            'lib.screen.videoPage.videoPage',
            'videoOperationsSteps',
            'videoUpload')),
        subtitle: Text(AppLocalization.instance.translate(
            'lib.screen.videoPage.videoPage',
            'videoOperationsSteps',
            'videoUploadDetails')),
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
            'lib.screen.videoPage.videoPage',
            'videoOperationsSteps',
            'videoAchievements')),
        subtitle: Text(AppLocalization.instance.translate(
            'lib.screen.videoPage.videoPage',
            'videoOperationsSteps',
            'videoAchievementsDetails')),
        //subtitle: const Text('Fill in the details'),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: FutureBuilder<Widget>(
            future: getStepTwoLayout(context),
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
      ),
      Step(
        state: _activeCurrentStep <= 2 ? StepState.editing : StepState.complete,
        isActive: _activeCurrentStep >= 2,
        title: Text(AppLocalization.instance.translate(
            'lib.screen.videoPage.videoPage',
            'videoOperationsSteps',
            'summaryAndSubmit')),
        subtitle: Text(AppLocalization.instance.translate(
            'lib.screen.videoPage.videoPage',
            'videoOperationsSteps',
            'summaryAndSubmitDetails')),
        //subtitle: const Text('Please check and submit !'),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: FutureBuilder<Widget>(
            future: getStepThreeLayout(context),
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
      ),
    ];
    return vSteps;
  }

  Widget getStepOneLayout(BuildContext context) {
    final TextEditingController videoTitleController =
        TextEditingController(text: videoPageModel.videoTitle ?? '');
    final TextEditingController videoDescriptionController =
        TextEditingController(text: videoPageModel.videoDescriptions ?? '');

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: WrapAlignment.start,
        runSpacing: 10,
        spacing: 10,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (videoPageModel.videoPlayerController != null)
                  Row(
                    children: [
                      Text(AppLocalization.instance.translate(
                          'lib.screen.videoPage.videoPage',
                          'getStepOneLayout',
                          'videoUploaded')),
                      IconButton(
                          onPressed:
                              videoProcessing ? null : _handleUploadButtonPressed,
                          icon: const Icon(Icons.delete_forever))
                    ],
                  ),
                if (videoPageModel.videoPlayerController == null)
                  ElevatedButton.icon(
                    onPressed: videoProcessing ? null : _handleUploadButtonPressed,
                    icon: videoProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ))
                        : Icon(videoPageModel.videoPlayerController != null
                            ? Icons.delete_forever
                            : Icons.cloud_upload_outlined),
                    label: videoProcessing
                        ? Text(AppLocalization.instance.translate(
                            'lib.screen.videoPage.videoPage',
                            'getStepOneLayout',
                            'videoUploading'))
                        : Text(videoPageModel.videoPlayerController != null
                            ? AppLocalization.instance.translate(
                                'lib.screen.videoPage.videoPage',
                                'getStepOneLayout',
                                'deleteUploadedVideo')
                            : AppLocalization.instance.translate(
                                'lib.screen.videoPage.videoPage',
                                'getStepOneLayout',
                                'videoUpload')),
                  ),
              ],
            ),
          ),

          CommonTextFormField(controller: videoTitleController, labelText: AppLocalization.instance.translate(
              'lib.screen.videoPage.videoPage',
              'getStepOneLayout',
              'videoTitle'),maxLines: null,minLines: 1,onChanged: (text) {
            videoPageModel.videoTitle = text;
          },),

          CommonTextFormField(controller: videoDescriptionController, labelText: AppLocalization.instance.translate(
              'lib.screen.videoPage.videoPage',
              'getStepOneLayout',
              'videoDescription'),maxLines: 3,minLines: 1,onChanged: (text) {
            videoPageModel.videoDescriptions = text;
          },),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Checkbox(
                      value: videoPageModel.isPublic,
                      onChanged: (value) {
                        setState(() {
                          videoPageModel.isPublic = value;
                        });
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          videoPageModel.isPublic = !videoPageModel.isPublic!;
                        });
                      },
                      child: Text(AppLocalization.instance.translate(
                          'lib.screen.videoPage.videoPage',
                          'getStepOneLayout',
                          'anyoneCanSeeThisVideo')),
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
                      value: videoPageModel.isAcceptConditions,
                      onChanged: (value) {
                        setState(() {
                          videoPageModel.isAcceptConditions = value;
                        });
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        showVideoUploadAcceptConditionsConfirmationDialog(
                            context);
                      },
                      child: Text(
                        AppLocalization.instance.translate(
                            'lib.screen.videoPage.videoPage',
                            'getStepOneLayout',
                            'acceptCommunityGuidelines'),
                        style:
                            const TextStyle(decoration: TextDecoration.underline),
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

  void _handleUploadButtonPressed() {
    setState(() {
      videoProcessing = true;
    });

    isUploadOrDelete = true;
    onlyCallNoAction = false;
    uploadVideo(isUploadOrDelete, onlyCallNoAction);
  }

  Future<Widget> getStepTwoLayout(BuildContext context) async {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          alignment: WrapAlignment.start,
          runSpacing: 10,
          spacing: 10,
          children: [
            CommonDropdownButtonFormField(
              label: AppLocalization.instance.translate(
                  'lib.screen.videoPage.videoPage',
                  'getStepTwoLayout',
                  'academicYear'),
              componentTextStyle: componentTextStyle,
              items: videoPageModel.academicYears,
              selectedItem: videoPageModel.selectedAcademicYear,
              onSelectedItemChanged: (selectedAcademicYear) {},
            ),
            CommonDropdownButtonFormField(
              label: AppLocalization.instance.translate(
                  'lib.screen.videoPage.videoPage',
                  'getStepTwoLayout',
                  'grade'),
              componentTextStyle: componentTextStyle,
              items: videoPageModel.grades,
              selectedItem: videoPageModel.selectedGrade,
              onSelectedItemChanged: (selectedGrade) {
                videoPageModel.selectedGrade = selectedGrade;
                videoPageModel.selectedLearn = null;
                videoPageModel.selectedBranch = null;
                setState(() {});
              },
            ),
            CommonDropdownButtonFormField(
                label: AppLocalization.instance.translate(
                    'lib.screen.videoPage.videoPage',
                    'getStepTwoLayout',
                    'branch'),
                componentTextStyle: componentTextStyle,
                items: videoPageModel.branches,
                selectedItem: videoPageModel.selectedBranch,
                onSelectedItemChanged: (selectedBranch) {
                  videoPageModel.selectedBranch = selectedBranch;

                  appRepositories
                      .tblLearnDomain(
                          'Video/GetObject', ['id', 'domain_name', 'branch_id'],
                          branch_id: selectedBranch)
                      .then((newDomainsDataSet) {
                    videoPageModel.domains = newDomainsDataSet
                        .toKeyValuePairsWithTypes<int, String>('data', 'id',
                            valueColumn: 'domain_name');
                    videoPageModel.selectedDomain = null;
                    videoPageModel.subDomains = {};
                    videoPageModel.selectedSubDomain = null;
                    videoPageModel.selectedAchievements = {};
                    videoPageModel.achievements = {};
                    videoPageModel.selectedLearn = null;
                    setState(() {});
                  });
                }),
            LearnLevels(
                learnId: videoPageModel.selectedLearn,
                branchId: videoPageModel.selectedBranch,
                gradeId: videoPageModel.selectedGrade,
                countryId: videoPageModel.selectedCountry,
                onChangedLearnId: (selectedLearnId) {
                  videoPageModel.selectedLearn = selectedLearnId;
                  videoPageModel.selectedSubDomain = selectedLearnId;
                  setState(() {});
                },
                onChangedSelectedAchievements: (selectedAchievements) {
                  videoPageModel.selectedAchievements =
                      selectedAchievements ?? {};
                },
                onChangedAchievements: (achievements) {
                  videoPageModel.achievements = achievements ?? {};
                },
                selectedAchievements: videoPageModel.selectedAchievements,
                componentTextStyle: componentTextStyle),
          ],
        ));
  }

  Future<Widget> getStepThreeLayout(BuildContext context) async {
    final screenWidth = MediaQuery.of(context).size.width;

    var vpO=VideoPlayerObject(
        autoplay: false,
        looping: false,
        videoPlayerController:
        videoPageModel.videoPlayerController,isFullScreen: (isFullScreen){
      if(!isFullScreen)
      {
        setState(() {

        });

      }
    });
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.start,
          direction: Axis.horizontal,
          spacing: 5,
          runSpacing: 5,
          children: [
            if (videoPageModel.videoPlayerController != null)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(0),
                child: SizedBox(
                  width: screenWidth < 600 ? double.infinity : 600,
                  child: vpO,
                ),
              ),
            if (videoPageModel.videoPlayerController == null)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.video_library,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalization.instance.translate(
                          'lib.screen.videoPage.videoPage',
                          'getStepThreeLayout',
                          'noVideoUploaded'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                width: double.infinity,
                child: FutureBuilder<Wrap>(
                  future: videoPageModel.toKeyValuePairs(),
                  builder: (BuildContext context,
                      AsyncSnapshot<Wrap> innerSnapshot) {
                    if (innerSnapshot.connectionState ==
                        ConnectionState.waiting) {
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
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  void videoBlocAddEvent(int? activeCurrentStep) {
    switch (activeCurrentStep) {
      case 0:
        videoBloc.add(Step1Event(videoPageModel: videoPageModel));
        break;
      case 1:
        videoBloc.add(Step2Event(videoPageModel: videoPageModel));
        break;
      case 2:
        videoBloc.add(Step3Event(videoPageModel: videoPageModel));
        break;
      default:
        break;
    }
  }

  Widget _buildStepper(BuildContext context, VideoState state) {
    var qOStepsCount = videoOperationsSteps(context, state).length;
    return Stepper(
      type: StepperType.vertical,
      currentStep: _activeCurrentStep,
      steps: videoOperationsSteps(context, state),
      onStepContinue: () {
        if (_activeCurrentStep < (qOStepsCount - 1)) {
          setState(() {
            _activeCurrentStep += 1;
            videoBlocAddEvent(_activeCurrentStep);
          });
        } else {
          //Save Pressed
          videoBloc.add(SavePmEvent(videoPageModel: videoPageModel));
        }
      },
      onStepCancel: () {
        if (_activeCurrentStep == 0) {
          return;
        }
        setState(() {
          _activeCurrentStep -= 1;
          videoBlocAddEvent(_activeCurrentStep);
        });
      },
      onStepTapped: (int index) {
        setState(() {
          _activeCurrentStep = index;
          videoBlocAddEvent(_activeCurrentStep);
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
                          'lib.screen.videoPage.videoPage',
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
                                'lib.screen.videoPage.videoPage',
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
                                'lib.screen.videoPage.videoPage',
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
                                'lib.screen.videoPage.videoPage',
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
                              if (videoPageModel.videoDuration < 60 ||
                                  videoPageModel.videoDuration > 180) {
                                UIMessage.showError(
                                    AppLocalization.instance.translate(
                                            'lib.screen.videoPage.videoPage',
                                            'uploadVideo',
                                            'videoDurationAlertMessage') +
                                        ' Video Duraion Alert Is Active Only - But Video Will be Saved.',
                                    gravity: ToastGravity.CENTER);
                                videoBloc.add(SavePmEvent(
                                    videoPageModel: videoPageModel));
                              } else {
                                videoBloc.add(SavePmEvent(
                                    videoPageModel: videoPageModel));
                              }
                            },
                            child: Text(AppLocalization.instance.translate(
                                'lib.screen.videoPage.videoPage',
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

  Widget _buildInit(BuildContext context, VideoState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(AppLocalization.instance.translate(
              'lib.screen.videoPage.videoPage', '_buildInit', 'initializing')),
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
                'lib.screen.videoPage.videoPage', '_buildLoading', 'loading'),
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
    videoObjectId = state.videoPageModel.videoObjectId;
    videoPageModel = state.videoPageModel;
    videoBlocAddEvent(_activeCurrentStep);
    return Container();
  }

  Widget _buildError(BuildContext context, ErrorState state) {
    String errorMessage;
    if (state is ErrorState) {
      errorMessage = state.errorMessage;
    } else {
      errorMessage = AppLocalization.instance.translate(
          'lib.screen.videoPage.videoPage', '_buildError', 'unknownError');
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
            AppLocalization.instance.translate('lib.screen.videoPage.videoPage',
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
          'lib.screen.videoPage.videoPage', '_buildErrorStep1', 'unknownError');
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
            AppLocalization.instance.translate('lib.screen.videoPage.videoPage',
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
    if (StepsValidator(videoPageModel).validateStep1()) {
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
          'lib.screen.videoPage.videoPage', '_buildErrorStep2', 'unknownError');
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
            AppLocalization.instance.translate('lib.screen.videoPage.videoPage',
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
    if (StepsValidator(videoPageModel).validateStep1()) {
      if (StepsValidator(videoPageModel).validateStep2()) {
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
          'lib.screen.videoPage.videoPage', '_buildErrorStep3', 'unknownError');
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
            AppLocalization.instance.translate('lib.screen.videoPage.videoPage',
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
            AppLocalization.instance.translate('lib.screen.videoPage.videoPage',
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
            AppLocalization.instance.translate('lib.screen.videoPage.videoPage',
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
            AppLocalization.instance.translate('lib.screen.videoPage.videoPage',
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
    videoObjectId = state.videoPageModel.videoObjectId;
    UIMessage.showSuccess(
        AppLocalization.instance.translate(
            'lib.screen.videoPage.videoPage', '_buildSavedPm', 'videoSaved'),
        gravity: ToastGravity.CENTER);
    _activeCurrentStep = 2;
    return _buildStepper(context, state);
  }

  Widget _buildErrorPm(BuildContext context, ErrorPmState state) {
    UIMessage.showSuccess(
        AppLocalization.instance.translate(
            'lib.screen.videoPage.videoPage', '_buildErrorPm', 'videoNotSaved'),
        gravity: ToastGravity.CENTER);

    _activeCurrentStep = 2;
    return _buildStepper(context, state);
  }
}
