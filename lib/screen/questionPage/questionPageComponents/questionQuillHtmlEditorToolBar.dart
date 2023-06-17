import 'package:flutter/material.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

class QuestionQuillHtmlEditorToolBarObject extends StatelessWidget {
  final List<ToolBarStyle> customToolBarList;
  final double iconSize;
  final QuillEditorController questionController;

  const QuestionQuillHtmlEditorToolBarObject({
    Key? key,
    required this.customToolBarList,
    required this.iconSize,
    required this.questionController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if(customToolBarList==null || questionController==null )
    {
      return Container();
    }

    return Container(
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
          toolBarConfig: customToolBarList,
          padding: const EdgeInsets.all(5),
          iconSize: iconSize,
          controller: questionController,
          customButtons: const [],
        ),
      ),
    );
  }
}
