import 'package:flutter/material.dart';

class DataTableData {
  List<String> columns;
  List<List<String>> rowsAsString;
  List<List<dynamic>> rowsAsIsType;
  List<Map<Map<String, String>, Widget>> rowsAsWidget;
  List<ColumnDataType> columnDataTypes;
  DataTableData(this.columns, this.rowsAsString,this.rowsAsIsType,this.rowsAsWidget,this.columnDataTypes);
}

class ColumnDataType {
  String columnName;
  Type dataType;

  ColumnDataType(this.columnName, this.dataType);
}