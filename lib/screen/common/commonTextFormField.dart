import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:flutter/material.dart';

class CommonTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? directionText;
  final double contentPaddingVertical;
  final double contentPaddingHorizontal;
  final bool isDense;
  final Color enabledBorderColor;
  final Color focusedBorderColor;
  final double borderRadius;
  final double fontSize;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final Color backgroundColor; // New parameter for background color

  const CommonTextFormField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.directionText,
    this.contentPaddingVertical = 12,
    this.contentPaddingHorizontal = 8,
    this.isDense = true,
    this.enabledBorderColor = Colors.grey,
    this.focusedBorderColor = Colors.blue,
    this.borderRadius = 8,
    this.fontSize = 10,
    this.maxLines = 1,
    this.minLines = 1,
    this.onChanged,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.backgroundColor = Colors.white, // Default value set to white
  }) : super(key: key);

  @override
  _CommonTextFormFieldState createState() => _CommonTextFormFieldState();
}

class _CommonTextFormFieldState extends State<CommonTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(fontSize: widget.fontSize),
      controller: widget.controller,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      onChanged: (value){
        if(widget.onChanged!=null)
          {
            widget.onChanged!(value);
          }
        setState(() {

        });

      },
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: widget.controller.text=='' ? (widget.directionText?? widget.labelText) : widget.labelText,
        //hintText: widget.directionText,
        labelStyle:widget.controller.text=='' ? const TextStyle(fontSize: 12): null,
        hintStyle:const TextStyle(fontSize: 10),
        contentPadding: EdgeInsets.symmetric(
          vertical: widget.contentPaddingVertical,
          horizontal: widget.contentPaddingHorizontal,
        ),
        isDense: widget.isDense,
        filled: true, // Enable filling the background
        fillColor: widget.backgroundColor, // Use the provided background color
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.enabledBorderColor),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.focusedBorderColor),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
