import 'package:egitimaxapplication/model/question/questionPageModel.dart';
import 'package:egitimaxapplication/screen/questionPage/questionOptionsPage.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/constant/language/appLocalizationConstant.dart';
import 'package:egitimaxapplication/utils/widget/layout/mainLayout.dart';
import 'package:flutter/material.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

class OptionsAndFreeTextAnswerButtonsObjects extends StatefulWidget {
  final List<QuestionOptionsController> questionOptionsController;
  final Function(List<QuestionOptionsController>) setQuestionOptions;
  final Function(String?) setQuestionFreeTextAnswer;
  final QuestionPageModel questionPageModel;
  final double? quillEditorMinHeight;
  final Function(int?)? setActiveCurrentStep;

  late QuillEditorController questionFreeTextAnswerController =
      QuillEditorController();
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
    //ToolBarStyle.directionLtr,
    //ToolBarStyle.headerOne,
    //ToolBarStyle.headerTwo,
    ToolBarStyle.color,
    ToolBarStyle.background,
    //ToolBarStyle.align,
    ToolBarStyle.listOrdered,
    ToolBarStyle.listBullet,
    //ToolBarStyle.size,
    ToolBarStyle.link,
    ToolBarStyle.image,
    ToolBarStyle.video,
    //ToolBarStyle.clean,
    //ToolBarStyle.undo,
    //ToolBarStyle.redo,
    //ToolBarStyle.clearHistory,
  ];
  final componentTextStyle = const TextStyle(
      fontSize: 12,
      color: Colors.black,
      locale: AppLocalizationConstant.DefaultLocale);
  double? iconSize = 12;

  OptionsAndFreeTextAnswerButtonsObjects({
    required this.questionOptionsController,
    required this.setQuestionOptions,
    required this.setQuestionFreeTextAnswer,
    required this.questionPageModel,
    this.quillEditorMinHeight,
    this.setActiveCurrentStep,
  });

  @override
  _OptionsAndFreeTextAnswerButtonsObjectsState createState() =>
      _OptionsAndFreeTextAnswerButtonsObjectsState();
}

class _OptionsAndFreeTextAnswerButtonsObjectsState
    extends State<OptionsAndFreeTextAnswerButtonsObjects> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.questionOptionsController == null ||
        widget.questionPageModel == null) {
      return Container();
    }
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Tooltip(
              message: AppLocalization.instance.translate(
                  'lib.screen.questionPage.questionPageComponents.optionsAndFreeTextAnswerButtons',
                  'build',
                  'options'), // Tooltip metni
              child: ElevatedButton(
                //style: ElevatedButton.styleFrom(minimumSize: const Size(8, 8),),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainLayout(
                        loadedStateContainer: QuestionOptions(
                          questionPageModel: widget.questionPageModel,
                          setActiveCurrentStep: widget.setActiveCurrentStep,
                        ),
                        context: context,
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.account_tree_outlined),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: AppLocalization.instance.translate(
                  'lib.screen.questionPage.questionPageComponents.optionsAndFreeTextAnswerButtons',
                  'build',
                  'freeTextAnswer'), // Tooltip metni
              child: ElevatedButton(
                //style: ElevatedButton.styleFrom(minimumSize: const Size(8, 8),),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                child: const Icon(Icons.note_alt_outlined),
              ),
            ),
          ],
        ),
        if (_expanded)
          Column(
            children: [
              ListTile(
                title: Text(
                  AppLocalization.instance.translate(
                      'lib.screen.questionPage.questionPageComponents.optionsAndFreeTextAnswerButtons',
                      'build',
                      'freeTextAnswer'),
                  style: widget.componentTextStyle,
                ),
                subtitle: Text(
                  AppLocalization.instance.translate(
                      'lib.screen.questionPage.questionPageComponents.optionsAndFreeTextAnswerButtons',
                      'build',
                      'pleaseFillTheAnswerCorrectly'),
                  style: widget.componentTextStyle,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(5),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: ToolBar(
                    direction: Axis.horizontal,
                    toolBarConfig: widget.customToolBarList,
                    padding: const EdgeInsets.all(5),
                    iconSize: widget.iconSize,
                    controller: widget.questionFreeTextAnswerController,
                    customButtons: const [],
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(5),
                child: QuillHtmlEditor(
                  controller: widget.questionFreeTextAnswerController,
                  text: widget.questionPageModel.freeTextAnswer,
                  hintText: AppLocalization.instance.translate(
                      'lib.screen.questionPage.questionPageComponents.optionsAndFreeTextAnswerButtons',
                      'build',
                      'typeHere'),
                  isEnabled: true,
                  minHeight: widget.quillEditorMinHeight ?? 100,
                  textStyle: widget.componentTextStyle,
                  hintTextStyle: widget.componentTextStyle,
                  hintTextAlign: TextAlign.start,
                  padding: const EdgeInsets.only(left: 5, top: 5),
                  hintTextPadding: EdgeInsets.zero,
                  onTextChanged: (text) {
                    questionFreeTextAnswer(text);
                  },
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(
                    width: 8,
                  ),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.setActiveCurrentStep!(1);
                      },
                      child: Text(
                        AppLocalization.instance.translate(
                            'lib.screen.questionPage.questionPageComponents.optionsAndFreeTextAnswerButtons',
                            'build',
                            'next'),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                ],
              )
            ],
          )
      ],
    );
  }

  Future<void> questionFreeTextAnswer(String? focus) async {
    String? htmlText = await widget.questionFreeTextAnswerController!.getText();
    widget.setQuestionFreeTextAnswer(htmlText);
    widget.questionPageModel.freeTextAnswer = htmlText;
  }
}
