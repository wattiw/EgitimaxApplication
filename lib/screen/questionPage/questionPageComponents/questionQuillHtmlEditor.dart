import 'package:egitimaxapplication/model/question/questionPageModel.dart';
import 'package:egitimaxapplication/screen/questionPage/questionPageComponents/questionQuillHtmlEditorToolBar.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

class QuestionQuillHtmlEditorObject extends StatefulWidget {
  final QuestionPageModel? questionPageModel;
  final QuillEditorController? questionController;
  final TextStyle componentTextStyle;
  final double? quillEditorMinHeight;
  final ValueChanged<String>? onTextChanged;
  final Function(bool)? onFocusChanged;
  final Function()? onEditorCreated;
  final Function(double)? onEditorResized;
  final Function(SelectionModel)? onSelectionChanged;
  final bool viewOnly;
  final bool? showTitle;
  final bool? showBoxDecoration;
  final String? viewOnlyHtmlString;
  final Color? editorBackGroundColor;

  const QuestionQuillHtmlEditorObject(
      {Key? key,
      this.questionPageModel,
      this.questionController,
      required this.viewOnly,
      this.viewOnlyHtmlString,
      this.onFocusChanged,
      this.onTextChanged,
      this.onEditorCreated,
      this.onEditorResized,
      this.onSelectionChanged,
      this.quillEditorMinHeight,
        this.showTitle,
        this.showBoxDecoration,
        this.editorBackGroundColor,
      required this.componentTextStyle})
      : super(key: key);

  @override
  _QuestionQuillHtmlEditorObjectState createState() =>
      _QuestionQuillHtmlEditorObjectState();
}

class _QuestionQuillHtmlEditorObjectState
    extends State<QuestionQuillHtmlEditorObject> {
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
  double? iconSize = 12;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.viewOnly) {
      if (widget.questionController == null ||
          widget.questionPageModel == null) {
        return Container();
      }
    }
    return Column(
      children: [
        if (!widget.viewOnly)
          Column(
            children: [
              if (widget.showTitle==true)
              ListTile(
                title: Text(
                  "Question",
                  style: widget.componentTextStyle,
                ),
                subtitle: Text(
                  "Please fill the question correctly !",
                  style: widget.componentTextStyle,
                ),
              ),
              if (widget.showTitle==true)
              const SizedBox(
                height: 8,
              ),
              QuestionQuillHtmlEditorToolBarObject(
                customToolBarList: customToolBarList,
                iconSize: iconSize!,
                questionController: widget.questionController!,
              ),
            ],
          ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: (widget.showBoxDecoration==false ? Colors.transparent :Colors.grey )),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(5),
          child: QuillHtmlEditor(
            backgroundColor: widget.editorBackGroundColor!=null ? widget.editorBackGroundColor! :Colors.white,
            controller: widget.viewOnly
                ? QuillEditorController()
                : widget.questionController!,
            text: widget.viewOnly
                ? widget.viewOnlyHtmlString
                : widget.questionPageModel!.question,
            hintText: AppLocalization.instance.translate('lib.screen.questionPage.questionPageComponents.questionQuillHtmlEditor', 'build', 'typeHere'),
            isEnabled: widget.viewOnly ? false : true,
            minHeight: widget.quillEditorMinHeight ?? 100,
            textStyle: widget.componentTextStyle,
            hintTextStyle: widget.componentTextStyle,
            hintTextAlign: TextAlign.start,
            padding: const EdgeInsets.all(1),
            hintTextPadding: EdgeInsets.zero,
            onFocusChanged: (focus) {
              if(widget.questionPageModel!=null)
                {

                }
              if (widget.onFocusChanged != null) {
                widget.onFocusChanged!(focus);
              }
            },
            onTextChanged: (text) {
              if (widget.onTextChanged != null) {

                widget.onTextChanged!(text);
              }
            },
            onEditorCreated: () {
              if (widget.onEditorCreated != null) {
                widget.onEditorCreated!;
              }
            },
            onEditorResized: (reSized) {
              if (widget.onEditorResized != null) {
                widget.onEditorResized!(reSized);
              }
            },
            onSelectionChanged: (changedSelection) {
              if (widget.onSelectionChanged != null) {
                widget.onSelectionChanged!(changedSelection);
              }
            },
          ),
        ),
      ],
    );
  }
}
