import 'package:dropdown_search/dropdown_search.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:flutter/material.dart';

class CommonDropdownButtonFormField extends StatefulWidget {
  final Map<int, String>? items;
  late dynamic? selectedItem;
  final Function(int) onSelectedItemChanged;
  TextStyle? componentTextStyle;
  final bool? isSearchEnable;
  final String? label;
  bool? isExpandedObject;
  bool? isActiveSecondSerachableDropDown;
  DropDownDecoratorProps? dropdownDecoratorProps;

  CommonDropdownButtonFormField({
    Key? key,
    required this.items,
    this.selectedItem,
    required this.onSelectedItemChanged,
    required this.componentTextStyle,
    this.isSearchEnable,
    this.label,
    this.dropdownDecoratorProps,
    this.isExpandedObject=false,
    this.isActiveSecondSerachableDropDown=false,
  }) : super(key: key);

  @override
  _CommonDropdownButtonFormFieldState createState() =>
      _CommonDropdownButtonFormFieldState();
}

class _CommonDropdownButtonFormFieldState
    extends State<CommonDropdownButtonFormField> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {

    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    if (widget.componentTextStyle?.color == Colors.grey ||
        widget.componentTextStyle?.color == null ||
        widget.componentTextStyle?.color == Colors.white ||
        widget.componentTextStyle?.color == Colors.transparent) {
      widget.componentTextStyle = widget.componentTextStyle!.copyWith(color: Colors.black, fontSize: 10);
    }



    if (widget.items == null || widget.items?.length == 0) {
      return Container();
    } else {
      if (!widget.items!.containsKey(widget.selectedItem)) {
        int firstKey = widget.items!.keys.reduce((a, b) => a < b ? a : b);
        widget.selectedItem = firstKey;
      }
    }

    int maxLength = widget.items!.entries
        .map((entry) => entry.value.toString().length)
        .toList()
        .reduce((value1, value2) => value1 > value2 ? value1 : value2);
    double width = maxLength <= 10
        ? 10
        : maxLength >= 20
            ? 20
            : double.parse(maxLength.toString());
    double? textSize =widget.componentTextStyle!.fontSize;

    if (textSize == 0 || textSize == null) {
      textSize = 10;
    }

    if(widget.label!=null && double.parse(widget.label!.length.toString())>width)
      {
        width=double.parse(widget.label!.length.toString());
      }

    if (widget.isSearchEnable != false) {

      if(widget.isActiveSecondSerachableDropDown==true)
        {

    /*       return SizedBox(
              width: widget.isExpandedObject==true ? double.infinity:  width * textSize,
              child: DropdownButtonHideUnderline(
            child: DropdownButton2<dynamic>(
              barrierLabel: widget.label,
              isExpanded: true,
              hint: Text(
                'Select ${widget.label}',
                style: widget.componentTextStyle,
              ),
              items: widget.items!.entries.map((entry) =>
                  DropdownMenuItem(
                    value: entry.key,
                    child: Text(
                      entry.value,
                        style: widget.componentTextStyle,
                    ),
                  )
              ).toList(),
              value: widget.selectedItem ,
              onChanged: (value) {
                setState(() {
                  widget.selectedItem = value;

                  widget.onSelectedItemChanged(widget.selectedItem ?? 0);
                });
              },
              buttonStyleData: ButtonStyleData(
                height: 40,
                width: 200,
                padding: const EdgeInsets.only(left: 14, right: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white,
                  ),
                  color: Colors.white,
                ),
                elevation: 2,
              ),
              dropdownStyleData: const DropdownStyleData(
                maxHeight: 200,
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 40,
              ),
              dropdownSearchData: DropdownSearchData(
                searchController: textEditingController,
                searchInnerWidgetHeight: 50,
                searchInnerWidget: Container(
                  height: 50,
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 4,
                    right: 8,
                    left: 8,
                  ),
                  child: TextFormField(
                    expands: true,
                    maxLines: null,
                    controller: textEditingController,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      hintText: 'Search for an ${widget.label} item...',
                      hintStyle: widget.componentTextStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                searchMatchFn: (item, searchValue) {
                  return (item.value.toString().toLowerCase().contains(searchValue.toLowerCase()));
                },
              ),
              //This to clear the search value when you close the menu
              onMenuStateChange: (isOpen) {
                if (!isOpen) {
                  textEditingController.clear();
                }
              },
            ),
          ));
       */  }

      return SizedBox(
        width: widget.isExpandedObject==true ? double.infinity:  width * textSize,
        child: DropdownSearch<dynamic>(
          dropdownButtonProps: const DropdownButtonProps(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),

          ),
          popupProps: PopupProps.menu(
            menuProps: const MenuProps(
              backgroundColor:Colors.white,
              animationDuration: Duration(milliseconds: 200),
            ),
            fit: FlexFit.tight,
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration:InputDecoration(
                labelText: AppLocalization.instance.translate('lib.screen.common.commonDropdownButtonFormField','build', 'search'),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                isDense: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: widget.componentTextStyle , // Yazı fontu boyutu
            ),
          ),
          items: widget.items!.entries.map((entry) => entry.value).toList(),
          dropdownDecoratorProps: widget.dropdownDecoratorProps ??
              DropDownDecoratorProps(
                dropdownSearchDecoration:
                InputDecoration(
                  filled: true,
                  fillColor:Colors.white,
                  labelText: widget.label,
                  hintText: widget.label,
                  contentPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                baseStyle:widget.componentTextStyle ,
              ),
          onChanged: (selectedItem) {
            setState(() {
              widget.selectedItem = widget.items!.entries
                  .map((entry) => entry)
                  .toList()
                  .firstWhere((item) => selectedItem == item.value)
                  .key;

              widget.onSelectedItemChanged(widget.selectedItem ?? 0);
            });
          },
         selectedItem: widget.items!.entries
              .map((entry) => entry)
              .toList()
              .firstWhere((item) => widget.selectedItem == item.key)
              .value,
          filterFn: (item, value) {
            if (value == null || value.isEmpty) {
              return true;
            }
            return item
                    .toString()
                    .toLowerCase()
                    .contains(value.toLowerCase()) ??
                false;
          },
        ),
      );
    } else {
      return SizedBox(
        width:widget.isExpandedObject==true ? double.infinity:   width * textSize,
        child: DropdownButtonFormField<int>(
          decoration:InputDecoration(
            labelText: widget.label,
            hintText: widget.label,
            contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            isDense: false,
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const SizedBox.shrink(),
          value: widget.selectedItem,
          items: widget.items!.entries.map((entry) {
            return DropdownMenuItem<int>(
              value: entry.key,
              child: Text(
                entry.value,
                style:widget.componentTextStyle , // Yazı fontu boyutu
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              widget.onSelectedItemChanged(value ?? 0);
            });
          },
          style: widget.componentTextStyle, // Dropdown metin fontu boyutu
        ),
      );
    }
  }
}

