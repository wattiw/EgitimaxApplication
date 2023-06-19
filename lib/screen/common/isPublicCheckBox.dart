import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:flutter/material.dart';
//

class isPublicCheckBox extends StatefulWidget {
  late bool? isPublic;
  final TextStyle componentTextStyle;
  final ValueChanged<bool>? onChanged;

  isPublicCheckBox({
    Key? key,
    this.isPublic,
    required this.componentTextStyle,
    this.onChanged,
  }) : super(key: key);

  @override
  _isPublicCheckBoxState createState() => _isPublicCheckBoxState();
}

class _isPublicCheckBoxState extends State<isPublicCheckBox> {
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _isPublic = widget.isPublic!;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPublic == null) {
      return Container();
    } else {
      widget.isPublic = false;
    }
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Checkbox(
          value: _isPublic,
          onChanged: widget.onChanged != null
              ? (value) {
            setState(() {
              _isPublic = value ?? false;
            });
            widget.onChanged!(_isPublic);
          }
              : null,
        ),
        Text(
          AppLocalization.instance.translate(
              'lib.screen.common.isPublicCheckBox', 'build', 'isPublic'),
          style: widget.componentTextStyle,
        ),
      ],
    );
  }
}
