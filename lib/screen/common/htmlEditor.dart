import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class HtmlEditorObject extends StatefulWidget {
  final String? content;
  final double? height;
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
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ToolbarWidget(
            controller: controller,
            htmlToolbarOptions: const HtmlToolbarOptions(
              defaultToolbarButtons: [
                StyleButtons(style: true),
                FontSettingButtons(fontSizeUnit: true),
                FontButtons(clearAll: true),
                ColorButtons(),
                ListButtons(listStyles: true),
                ParagraphButtons(
                  textDirection: true,
                  lineHeight: true,
                  caseConverter: true,
                ),
                InsertButtons(
                  video: false,
                  audio: false,
                  table: true,
                  hr: true,
                  otherFile: false,
                ),
              ],
              toolbarItemHeight: 36,
              dropdownElevation: 3,
              buttonBorderWidth: 10,
              dropdownIconSize: 14,
              initiallyExpanded: true,
              toolbarType: ToolbarType.nativeScrollable,
            ),
            callbacks: null,
          ),
          HtmlEditor(
            controller: controller,
            htmlToolbarOptions: const HtmlToolbarOptions(
              toolbarPosition: ToolbarPosition.custom,
            ),
            htmlEditorOptions: HtmlEditorOptions(
              autoAdjustHeight: true,
              adjustHeightForKeyboard: true,
              hint: "Type Here...",
              initialText: widget.content ?? '',
              shouldEnsureVisible: true,
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
      ),
    );
  }
}
