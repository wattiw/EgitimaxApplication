import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class HtmlEditorObject extends StatefulWidget {
  String? content;
  double? height;
  final ValueChanged<String>? onTextChanged;

  HtmlEditorObject({this.content, this.onTextChanged, this.height});

  @override
  _HtmlEditorObjectState createState() => _HtmlEditorObjectState();
}

class _HtmlEditorObjectState extends State<HtmlEditorObject> {
  HtmlEditorController controller = HtmlEditorController(
    processInputHtml: true,
    processNewLineAsBr: true,
    processOutputHtml: true,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
/*        ToolbarWidget(
          controller: controller,
          htmlToolbarOptions: const HtmlToolbarOptions(
            toolbarType : ToolbarType.nativeGrid,
            toolbarPosition: ToolbarPosition.custom, //required to place toolbar anywhere!
            //other options
          ),
            callbacks:null
        ),*/
        HtmlEditor(
          controller: controller,
          htmlEditorOptions: HtmlEditorOptions(
            autoAdjustHeight:true,
            adjustHeightForKeyboard:true,
            hint: "Type Here...",
            initialText: widget.content ?? '',
            shouldEnsureVisible: true,
          ),
          htmlToolbarOptions:   HtmlToolbarOptions(
            defaultToolbarButtons: [
              StyleButtons(style:true),
              FontSettingButtons(fontSizeUnit: true),
              FontButtons(clearAll: false),
              ColorButtons(),
              ListButtons(listStyles: false),
              ParagraphButtons(
                  textDirection: false,
                  lineHeight: false,
                  caseConverter: false),
              InsertButtons(
                  video: false,
                  audio: false,
                  table: false,
                  hr: false,
                  otherFile: false)
            ],

            toolbarItemHeight:36,
            dropdownElevation :3,
            buttonBorderWidth: 10,
            dropdownIconSize: 14,
            initiallyExpanded: true,
            textStyle: TextStyle(fontSize: 10, color: Colors.black),
            toolbarType: ToolbarType.nativeExpandable,
            toolbarPosition: ToolbarPosition.aboveEditor,
          ),
          otherOptions: OtherOptions(
            height: widget.height ?? 400,
          ),
          callbacks: Callbacks(onChangeContent: (String? changed) {
            if (widget.onTextChanged != null) {
              widget.onTextChanged!(changed ?? '');
            }
          }),
        ),
      ],
    );
  }
}
