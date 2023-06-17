import 'package:egitimaxapplication/model/question/questionPageModel.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

class QuestionFreeTextAnswerQuillHtmlEditorObjects extends StatefulWidget {
  final QuestionPageModel questionPageModel;
  final QuillEditorController questionFreeTextAnswerController;
  final TextStyle componentTextStyle;
  final ValueChanged<String>? onTextChanged;
  final  Function(bool)? onFocusChanged;
  final  Function()? onEditorCreated;
  final  Function(double)? onEditorResized;
  final  Function(SelectionModel)? onSelectionChanged;
  final double? quillEditorMinHeight;

  const QuestionFreeTextAnswerQuillHtmlEditorObjects({Key? key,
    required this.questionPageModel,
    required this.questionFreeTextAnswerController,
    this.onFocusChanged,
    this.onTextChanged,
    this.onEditorCreated,
    this.onEditorResized,
    this.onSelectionChanged,
    this.quillEditorMinHeight,
    required this.componentTextStyle})
      : super(key: key);

  @override
  _QuestionFreeTextAnswerQuillHtmlEditorObjectsState createState() => _QuestionFreeTextAnswerQuillHtmlEditorObjectsState();
}

class _QuestionFreeTextAnswerQuillHtmlEditorObjectsState extends State<QuestionFreeTextAnswerQuillHtmlEditorObjects> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.questionFreeTextAnswerController==null || widget.questionPageModel==null )
    {
      return Container();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(5),
      child: QuillHtmlEditor(
        controller: widget.questionFreeTextAnswerController,
        text: widget.questionPageModel.freeTextAnswer,
        hintText: AppLocalization.instance.translate('lib.screen.questionPage.questionPageComponents.questionFreeTextAnswerQuillHtmlEditor', 'build', 'typeHere'),
        isEnabled: true,
        minHeight: widget.quillEditorMinHeight ?? 100,
        textStyle: widget.componentTextStyle,
        hintTextStyle: widget.componentTextStyle,
        hintTextAlign: TextAlign.start,
        padding: const EdgeInsets.only(left: 5, top: 5),
        hintTextPadding: EdgeInsets.zero,
        onFocusChanged: widget.onFocusChanged,
        onTextChanged:widget.onTextChanged,
        onEditorCreated: widget.onEditorCreated,
        onEditorResized: widget.onEditorResized,
        onSelectionChanged:widget.onSelectionChanged,
      ),
    );
  }
}
