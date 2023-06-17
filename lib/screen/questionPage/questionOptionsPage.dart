import 'package:egitimaxapplication/bloc/bloc/question/questionOptionsBloc.dart';
import 'package:egitimaxapplication/bloc/event/question/questionOptionsEvent.dart';
import 'package:egitimaxapplication/bloc/state/question/questionOptionsState.dart';
import 'package:egitimaxapplication/model/question/question.dart';
import 'package:egitimaxapplication/model/question/questionPageModel.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/constant/language/appLocalizationConstant.dart';
import 'package:egitimaxapplication/utils/widget/appBar/innerAppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quill_html_editor/quill_html_editor.dart';



class QuestionOptions extends StatefulWidget {
  QuestionOptions({
    super.key,
    this.setActiveCurrentStep,
    this.questionPageModel,
    this.setQuestionPageModel,

  });

  QuestionPageModel? questionPageModel;
  final Function(int?)? setActiveCurrentStep;
  final Function(QuestionPageModel?)? setQuestionPageModel;
  bool expandedResolution = false;
  bool? isHiddenAddOptionButton = true;

  late List<QuestionOptionsController> questionOptionsController = [
    QuestionOptionsController()
  ];
  late QuillEditorController questionResolutionsController =
      QuillEditorController();

  @override
  State<QuestionOptions> createState() => _QuestionOptionsState();
}

class _QuestionOptionsState extends State<QuestionOptions> {
  late QuestionOptionsBloc questionOptionsBloc;
  final componentTextStyle = const TextStyle(
      fontSize: 12,
      color: Colors.black,
      locale: AppLocalizationConstant.DefaultLocale);
  double? iconSize = 14;

  final customToolBarList = [
    ToolBarStyle.bold,
    ToolBarStyle.italic,
    ToolBarStyle.underline,
    ToolBarStyle.strike,
    ToolBarStyle.blockQuote,
    ToolBarStyle.codeBlock,
    ToolBarStyle.indentMinus,
    ToolBarStyle.indentAdd,
    ToolBarStyle.directionRtl,
    ToolBarStyle.directionLtr,
    ToolBarStyle.headerOne,
    ToolBarStyle.headerTwo,
    ToolBarStyle.color,
    ToolBarStyle.background,
    ToolBarStyle.align,
    ToolBarStyle.listOrdered,
    ToolBarStyle.listBullet,
    ToolBarStyle.size,
    ToolBarStyle.link,
    ToolBarStyle.image,
    ToolBarStyle.video,
    ToolBarStyle.clean,
    ToolBarStyle.undo,
    ToolBarStyle.redo,
    ToolBarStyle.clearHistory,
  ];

  @override
  void initState() {

    super.initState();
    questionOptionsBloc = QuestionOptionsBloc();
    questionOptionsBloc.add(QuestionOptionsInitEvent());
    setOptionsAndAnswerControllers();
  }

  void setOptionsToModel()
  {
    if (widget.questionOptionsController!=null && widget.questionOptionsController!.isNotEmpty)
    {
      widget.questionPageModel?.options?.clear();
      List<Option> newOptions=List.empty(growable: true);
      for (int i = 0; i < widget.questionOptionsController!.length; i++) {
        var currentOption = widget.questionOptionsController![i];
        Option newOp=Option();
        newOp.text=currentOption.data;
        newOp.data=currentOption.data;
        newOp.isCorrect=currentOption.isCorrect;
        newOp.mark=currentOption.mark;
        newOp.questId=widget.questionPageModel?.questionId;
        newOptions.add(newOp);
      }
      widget.questionPageModel?.options=newOptions;
      widget.setQuestionPageModel!(widget.questionPageModel);
    }
  }
  void setOptionsAndAnswerControllers() {

    if (widget.questionPageModel!=null && widget.questionPageModel?.options != null && widget.questionPageModel!.options!.isNotEmpty)
    {
      widget.questionOptionsController.clear();

      for (int i = 0; i < widget.questionPageModel!.options!.length; i++) {
        var currentValue = widget.questionPageModel!.options![i];
        QuestionOptionsController defaultOption = QuestionOptionsController();

        defaultOption.mark = currentValue.mark;
        defaultOption.data = currentValue.data;
        defaultOption.textController.setText(currentValue.data ?? '');
        defaultOption.isCorrect = currentValue.isCorrect!;
        widget.questionOptionsController.add(defaultOption);
      }
    } else {
      widget.questionOptionsController.clear();

      for (int i = 0; i < 4; i++) {
        QuestionOptionsController defaultOption = QuestionOptionsController();
        defaultOption.textController.setText(AppLocalization.instance.translate(
            'lib.screen.questionPage.questionPage',
            'setQuestionAndOptionsControllers',
            'defaultOptionText'));
        widget.questionOptionsController.add(defaultOption);
      }
    }

    widget.questionResolutionsController.setText(widget.questionPageModel!=null ? (widget.questionPageModel!.freeTextAnswer ?? '') :'');
  }

  @override
  void dispose() {
    for (int i = 0; i < widget.questionOptionsController.length; i++) {
      widget.questionOptionsController[i].textController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: BlocProvider(
        create: (_) => questionOptionsBloc,
        child: Scaffold(
          appBar: InnerAppBar(
              title: AppLocalization.instance.translate(
                  'lib.screen.questionPage.questionOptionsPage',
                  'build',
                  'questionOptions')),
          body: BlocBuilder<QuestionOptionsBloc, QuestionOptionsState>(
            builder: (context, state) {
              if (state is InitialInitState) {
                return Center(
                  child: FutureBuilder<Widget>(
                    future: initialOptionsStateContainer(state),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return snapshot.data!;
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                );
              }
              if (state is LoadingInitState) {
                return Center(
                  child: FutureBuilder<Widget>(
                    future: loadingOptionsStateContainer(state),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return snapshot.data!;
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                );
              }
              if (state is LoadedInitState) {
                return Center(
                  child: FutureBuilder<Widget>(
                    future: loadedOptionsStateContainer(state),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return snapshot.data!;
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                );
              }
              if (state is ErrorInitState) {
                return Center(
                  child: FutureBuilder<Widget>(
                    future: errorOptionsStateContainer(state),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return snapshot.data!;
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                );
              }

              return Container();
            },
          ),
        ),
      ),
    );
  }


  Future<Widget> initialOptionsStateContainer(InitialInitState state) async {
    return Text(AppLocalization.instance.translate(
        'lib.screen.questionPage.questionOptionsPage',
        'initialOptionsStateContainer',
        'qPOpsPagePreparingToLoad'));
  }

  Future<Widget> loadingOptionsStateContainer(LoadingInitState state) async {
    return Text(AppLocalization.instance.translate(
        'lib.screen.questionPage.questionOptionsPage',
        'loadingOptionsStateContainer',
        'qPOpsPageComponentsLoading'));
  }

  Future<Widget> loadedOptionsStateContainer(LoadedInitState state) async {
    return Column(
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.expandedResolution)
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.questionOptionsController.length,
                      itemBuilder: (context, index) {
                        String optionMaker =
                            '${String.fromCharCode(index + 65)})' ??
                                AppLocalization.instance.translate(
                                    'lib.screen.questionPage.questionOptionsPage',
                                    'loadedOptionsStateContainer',
                                    'errorMarked');

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        '$optionMaker.',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Tooltip(
                                            message: AppLocalization.instance
                                                .translate(
                                                    'lib.screen.questionPage.questionOptionsPage',
                                                    'loadedOptionsStateContainer',
                                                    'isCorrect'),
                                            child: Checkbox(
                                              value: widget
                                                  .questionOptionsController[
                                                      index]
                                                  .isCorrect,
                                              onChanged: (value) {
                                                setState(() {
                                                  if (value == true) {
                                                    for (int i = 0;
                                                        i <
                                                            widget
                                                                .questionOptionsController
                                                                .length;
                                                        i++) {
                                                      if (i != index) {
                                                        widget
                                                            .questionOptionsController[
                                                                i]
                                                            .isCorrect = false;
                                                      }
                                                    }
                                                  }
                                                  widget
                                                      .questionOptionsController[
                                                          index]
                                                      .isCorrect = value ?? false;
                                                });
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: AppLocalization.instance
                                                .translate(
                                                    'lib.screen.questionPage.questionOptionsPage',
                                                    'loadedOptionsStateContainer',
                                                    'deleteOption'),
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              setState(() {
                                                widget.questionOptionsController
                                                    .removeAt(index);
                                                for (int i = 0;
                                                    i <
                                                        widget
                                                            .questionOptionsController
                                                            .length;
                                                    i++) {
                                                  String optionMakr =
                                                      '${String.fromCharCode(i + 65)})' ??
                                                          AppLocalization
                                                              .instance
                                                              .translate(
                                                                  'lib.screen.questionPage.questionOptionsPage',
                                                                  'loadedOptionsStateContainer',
                                                                  'errorMarked');
                                                  widget
                                                      .questionOptionsController[
                                                          i]
                                                      .mark = optionMakr;
                                                }
                                              });
                                            },
                                          ),
                                          IconButton(
                                            tooltip: AppLocalization.instance
                                                .translate(
                                                    'lib.screen.questionPage.questionOptionsPage',
                                                    'loadedOptionsStateContainer',
                                                    'toolbar'),
                                            icon: Icon(widget
                                                    .questionOptionsController[
                                                        index]
                                                    .isToolBarVisible
                                                ? Icons.arrow_drop_up_outlined
                                                : Icons
                                                    .arrow_drop_down_outlined),
                                            onPressed: () {
                                              setState(() {
                                                widget
                                                        .questionOptionsController[
                                                            index]
                                                        .isToolBarVisible =
                                                    !widget
                                                        .questionOptionsController[
                                                            index]
                                                        .isToolBarVisible;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            if (widget.questionOptionsController[index]
                                .isToolBarVisible)
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                margin: const EdgeInsets.fromLTRB(2, 1, 2, 1),
                                padding: const EdgeInsets.all(2),
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: ToolBar(
                                    direction: Axis.horizontal,
                                    toolBarConfig: customToolBarList,
                                    padding: const EdgeInsets.all(2),
                                    iconSize: iconSize,
                                    controller: widget
                                        .questionOptionsController[index]
                                        .textController,
                                    customButtons: [
                                      InkWell(
                                        onTap: () {
                                          setOptionsToModel();
                                        },
                                        child: Icon(
                                          Icons.save,
                                          size: iconSize,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Container(
                                //padding: const EdgeInsets.all(2.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                padding: const EdgeInsets.all(2),
                                margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      verticalDirection: VerticalDirection.up,
                                      children: [
                                        Expanded(
                                          child: QuillHtmlEditor(
                                            text: widget
                                                .questionOptionsController[
                                                    index]
                                                .data,
                                            hintText: AppLocalization.instance
                                                .translate(
                                                    'lib.screen.questionPage.questionOptionsPage',
                                                    'loadedOptionsStateContainer',
                                                    'typeHere'),
                                            isEnabled: true,
                                            minHeight: 10,
                                            controller: widget
                                                .questionOptionsController[
                                                    index]
                                                .textController,
                                            textStyle: TextStyle(
                                              fontSize:
                                                  componentTextStyle.fontSize,
                                              locale: AppLocalizationConstant
                                                  .DefaultLocale,
                                            ),
                                            hintTextStyle: TextStyle(
                                              fontSize:
                                                  componentTextStyle.fontSize,
                                              locale: AppLocalizationConstant
                                                  .DefaultLocale,
                                            ),
                                            hintTextAlign: TextAlign.start,
                                            padding: const EdgeInsets.all(2),
                                            hintTextPadding: EdgeInsets.zero,
                                            //backgroundColor: _backgroundColor,
                                            onTextChanged: (text) {
                                               widget.questionOptionsController[index].data = text;
                                               widget.questionOptionsController[index].mark = optionMaker;
                                               setOptionsToModel();

                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //const Divider(color: Colors.grey),
                          ],
                        );
                      },
                    ),
                  ),
                if (widget.expandedResolution)
                  Column(
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          AppLocalization.instance.translate(
                              'lib.screen.questionPage.questionOptionsPage',
                              'loadedOptionsStateContainer',
                              'resolutionText'),
                          style: TextStyle(
                              fontSize: componentTextStyle.fontSize,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        padding: const EdgeInsets.all(2),
                        margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          child: ToolBar(
                            direction: Axis.horizontal,
                            toolBarConfig: customToolBarList,
                            padding: const EdgeInsets.all(2),
                            iconSize: iconSize,
                            controller: widget.questionResolutionsController ??
                                QuillEditorController(),
                            customButtons: const [],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          padding: const EdgeInsets.all(2),
                          margin: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                          child: SizedBox(
                            width: double.infinity,
                            child: QuillHtmlEditor(
                              controller:
                                  widget.questionResolutionsController ??
                                      QuillEditorController(),
                              text: widget.questionPageModel?.freeTextAnswer ??
                                  '',
                              hintText: AppLocalization.instance.translate(
                                  'lib.screen.questionPage.questionOptionsPage',
                                  'loadedOptionsStateContainer',
                                  'typeHere'),
                              isEnabled: true,
                              minHeight: 300,
                              textStyle: componentTextStyle,
                              hintTextStyle: componentTextStyle,
                              hintTextAlign: TextAlign.start,
                              padding: const EdgeInsets.only(left: 2, top: 2),
                              hintTextPadding: EdgeInsets.zero,
                              onFocusChanged: (focus) {},
                              onTextChanged: (text) {
                                widget.questionPageModel?.freeTextAnswer=text;
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(width: 8),
                  if (widget.isHiddenAddOptionButton != false)
                    Tooltip(
                      message: AppLocalization.instance.translate(
                          'lib.screen.questionPage.questionOptionsPage',
                          'loadedOptionsStateContainer',
                          'addOption'),
                      // Tooltip metni
                      child: ElevatedButton(
                        //style: ElevatedButton.styleFrom(minimumSize: const Size(8, 8),),
                        onPressed: () {
                          setState(() {
                            String optionMakr =
                                '${String.fromCharCode(widget.questionOptionsController.length + 65)})' ??
                                    AppLocalization.instance.translate(
                                        'lib.screen.questionPage.questionOptionsPage',
                                        'loadedOptionsStateContainer',
                                        'errorMarked');
                            QuestionOptionsController newOption =
                                QuestionOptionsController();
                            newOption.mark = optionMakr;
                            newOption.data = '';
                            widget.questionOptionsController.add(newOption);
                          });
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: AppLocalization.instance.translate(
                        'lib.screen.questionPage.questionOptionsPage',
                        'loadedOptionsStateContainer',
                        'addResolutionText'),
                    // Tooltip metni
                    child: ElevatedButton(
                      //style: ElevatedButton.styleFrom(minimumSize: const Size(8, 8),),
                      onPressed: () {
                        setState(() {
                          widget.expandedResolution =
                              !widget.expandedResolution;
                          widget.isHiddenAddOptionButton =
                              !widget.isHiddenAddOptionButton!;
                        });
                      },
                      child: Icon(widget.expandedResolution
                          ? Icons.note_alt_outlined
                          : Icons.notes),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.setQuestionPageModel!(widget.questionPageModel);
                          widget.setActiveCurrentStep!(1);
                          Navigator.pop(context);
                        },
                        child: Text(AppLocalization.instance.translate(
                            'lib.screen.questionPage.questionOptionsPage',
                            'loadedOptionsStateContainer',
                            'next')),
                      ),
                    ),
                  ]),
            ),
            const SizedBox(
              width: 15,
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        )
      ],
    );
    return Text(AppLocalization.instance.translate(
        'lib.screen.questionPage.questionOptionsPage',
        'loadedOptionsStateContainer',
        'qPOpsPageLoaded'));
  }

  Future<Widget> errorOptionsStateContainer(ErrorInitState state) async {
    return Text(
        '${AppLocalization.instance.translate('lib.screen.questionPage.questionOptionsPage', 'errorOptionsStateContainer', 'qPOpsAnErrorOccurredWhileLoadingThePageError:')}${state.errorMessage}');
  }
}
