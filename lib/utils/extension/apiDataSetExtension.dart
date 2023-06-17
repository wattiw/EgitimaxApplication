import 'dart:convert';

import 'package:egitimaxapplication/model/common/dataTableData.dart';
import 'package:flutter/material.dart';

extension NewApiDataSetExtension on Map<String, dynamic> {

  DataTable? getDataTable() {
    var data = selectDataTable('data');

    if(selectDataTable('data').isEmpty)
    {
      data=[this];
    }

    if(data==null || data.isEmpty)
      {
        return null;
      }
    List<DataColumn> columns = [];
    List<DataRow> rows = [];

    try {
      if (data.isNotEmpty) {
        var firstRow = data.first;
        for (var entry in firstRow.entries) {
          columns.add(DataColumn(label: Text(entry.key)));
        }
      }

      for (var row in data) {
        List<DataCell> cells = [];
        for (var entry in row.entries) {
          cells.add(DataCell(Text(entry.value.toString())));
        }
        rows.add(DataRow(cells: cells));
      }

      return DataTable(columns: columns, rows: rows);
    } catch (e) {
      // Handle any errors that occurred during data processing
      debugPrint('Error: $e');
      return DataTable(columns: columns, rows: rows);
    }
  }

  DataTableData getDataTableData() {
    var data = selectDataTable('data');

    if(selectDataTable('data').isEmpty)
      {
       data=[this];
      }
    List<String> columns = [];
    List<List<String>> rowsAsString = [];
    List<List<dynamic>> rowsAsIsType = [];
    List<Map<Map<String, String>, Widget>>? rowsAsWidget=[];
    List<ColumnDataType> columnDataTypes=List.empty(growable: true);

    try {
      if (data.isNotEmpty) {
        var firstRow = data.first;
        for (var entry in firstRow.entries) {
          columns.add(entry.key);
        }
      }

      for (var row in data) {
        List<String> cellsAsString = [];
        List<dynamic> cellsAsIsType = [];
        Map<Map<String, String>, Widget> cells = {};

        for (var entry in row.entries) {
          var valueAsString = entry.value.toString();
          var valueAsIs = entry.value;
          cellsAsString.add(valueAsString);
          cellsAsIsType.add(valueAsIs);

          Map<String, String> key={};
          key[entry.key]=valueAsString;

          cells[key]=Text(valueAsString);

        }
        rowsAsWidget.add(cells);
        rowsAsString.add(cellsAsString);
        rowsAsIsType.add(cellsAsIsType);
      }

      int indexOfColName=0;
      for(var cell in rowsAsIsType.first)
        {
          ColumnDataType cdt=ColumnDataType(columns[indexOfColName], cell.runtimeType);
          columnDataTypes.add(cdt);
          indexOfColName++;
        }

      return DataTableData(columns, rowsAsString, rowsAsIsType,rowsAsWidget,columnDataTypes);
    } catch (e) {
      // Handle any errors that occurred during data processing
      debugPrint('Error: $e');

      return DataTableData(columns, rowsAsString, rowsAsIsType,rowsAsWidget,columnDataTypes);
    }
  }


  List<Map<String, dynamic>> selectDataTable(String tableName,
      {List<String>? selectColumns,
      bool distinct = false,
      String? filterColumn,
      dynamic filterValue}) {
    if (!this.containsKey(tableName)) {
      return [];
    }

    List<dynamic> dataTable = this[tableName];

    if (dataTable == null || dataTable is! List<dynamic>) {
      return [];
    }

    if (filterColumn != null && filterValue != null) {
      dataTable = dataTable.where((row) {
        dynamic columnValue = row[filterColumn];
        if (columnValue is num && filterValue is num) {
          return columnValue == filterValue;
        } else {
          return columnValue.toString() == filterValue.toString();
        }
      }).toList();
    }

    if (selectColumns != null && selectColumns.isNotEmpty) {
      dataTable = dataTable.map((row) {
        Map<String, dynamic> filteredRow = {};
        for (String column in selectColumns) {
          if (row.containsKey(column)) {
            filteredRow[column] = row[column];
          }
        }
        return filteredRow;
      }).toList();
    }

    if (distinct) {
      dataTable = distinctList(dataTable);
    }

    return List<Map<String, dynamic>>.from(dataTable);
  }

  dynamic toKeyValuePairs(String tableName, String keyColumn,
      {String? valueColumn, String? filterColumn, dynamic filterValue}) {
    List<Map<String, dynamic>> dataTable = this.selectDataTable(tableName,
        distinct: true, filterColumn: filterColumn, filterValue: filterValue);

    if (dataTable.isEmpty || !dataTable.first.containsKey(keyColumn)) {
      return {};
    }

    Map<dynamic, dynamic> keyValuePairs = {};

    for (Map<String, dynamic> row in dataTable) {
      dynamic key = row[keyColumn];
      dynamic value = valueColumn == null ? row : row[valueColumn];
      keyValuePairs[key] = value;
    }

    return keyValuePairs;
  }

  Map<T, V> toKeyValuePairsWithTypes<T, V>(String tableName, String keyColumn,
      {String? valueColumn, String? filterColumn, dynamic filterValue}) {
    List<Map<String, dynamic>> dataTable = this.selectDataTable(tableName,
        distinct: true, filterColumn: filterColumn, filterValue: filterValue);

    if (dataTable.isEmpty || !dataTable.first.containsKey(keyColumn)) {
      return {};
    }

    Map<T, V> keyValuePairs = {};

    for (Map<String, dynamic> row in dataTable) {
      T key = row[keyColumn];
      V value = valueColumn == null ? row : row[valueColumn];
      keyValuePairs[key] = value;
    }

    return keyValuePairs;
  }

  Map<String, dynamic>? first(String tableName,
      {List<String>? selectColumns,
      bool distinct = false,
      String? filterColumn,
      dynamic filterValue}) {
    List<Map<String, dynamic>> result = selectDataTable(tableName,
        selectColumns: selectColumns,
        distinct: distinct,
        filterColumn: filterColumn,
        filterValue: filterValue);
    return result.isNotEmpty ? result.first : null;
  }

  Map<String, dynamic>? last(String tableName,
      {List<String>? selectColumns,
      bool distinct = false,
      String? filterColumn,
      dynamic filterValue}) {
    List<Map<String, dynamic>> result = selectDataTable(tableName,
        selectColumns: selectColumns,
        distinct: distinct,
        filterColumn: filterColumn,
        filterValue: filterValue);
    return result.isNotEmpty ? result.last : null;
  }

  dynamic firstValue(String tableName, String valueColumn,
      {String? filterColumn, dynamic filterValue, dynamic insteadOfNull}) {
    Map<String, dynamic>? row = first(tableName,
        selectColumns: [valueColumn],
        filterColumn: filterColumn,
        filterValue: filterValue);
    return row != null ? (row[valueColumn] ?? insteadOfNull) : insteadOfNull;
  }

  dynamic lastValue(String tableName, String valueColumn,
      {String? filterColumn, dynamic filterValue, dynamic insteadOfNull}) {
    Map<String, dynamic>? row = last(tableName,
        selectColumns: [valueColumn],
        filterColumn: filterColumn,
        filterValue: filterValue);
    return row != null ? (row[valueColumn] ?? insteadOfNull) : insteadOfNull;
  }

  T? firstValueWithType<T>(String tableName, String valueColumn,{String? filterColumn, dynamic filterValue, dynamic insteadOfNull})
  {
    Map<String, dynamic>? row = first(tableName,
        selectColumns: [valueColumn],
        filterColumn: filterColumn,
        filterValue: filterValue);
    dynamic result = row != null ? (row[valueColumn] ?? insteadOfNull) : insteadOfNull;
    return result != null ? result is T ? result : _convertValueToType<T>(result) : null;
  }

  T? lastValueWithType<T>(String tableName, String valueColumn,{String? filterColumn, dynamic filterValue, dynamic insteadOfNull})
  {
    Map<String, dynamic>? row = last(tableName,
        selectColumns: [valueColumn],
        filterColumn: filterColumn,
        filterValue: filterValue);
    dynamic result = row != null ? (row[valueColumn] ?? insteadOfNull) : insteadOfNull;
    return result != null ? result is T ? result : _convertValueToType<T>(result) : null;
  }

  T _convertValueToType<T>(dynamic value) {
    if (T == String) {
      return value.toString() as T;
    } else if (T == int) {
      return int.parse(value.toString()) as T;
    } else if (T == double) {
      return double.parse(value.toString()) as T;
    } else if (T == bool) {
      return value as T;
    } else if (T == DateTime) {
      return DateTime.parse(value.toString()) as T;
    } else if (T == List) {
      if (value is List) {
        return value as T;
      } else {
        throw ArgumentError('Value is not a List.');
      }
    } else if (T == Map) {
      if (value is Map) {
        return value as T;
      } else {
        throw ArgumentError('Value is not a Map.');
      }
    } else if (T == BigInt) {
      return BigInt.parse(value.toString()) as T;
    } else {
      throw ArgumentError('Type conversion not supported.');
    }
  }


  Map<String, dynamic> distinctMap(Map<String, dynamic> map) {
    final Set<int> uniqueHashCodes = Set<int>();
    final Map<String, dynamic> distinctMap = <String, dynamic>{};

    // Her bir anahtar-değer çiftini tek tek işle
    map.forEach((key, value) {
      // Nesneye özel bir hashCode oluştur
      final int objectHashCode = Object.hashAll([key, value]);

      // Bu hashCode daha önce eklenmemişse, nesneyi yeni bir Map'e ekle
      if (!uniqueHashCodes.contains(objectHashCode)) {
        uniqueHashCodes.add(objectHashCode);
        distinctMap[key] = value;
      }
    });

    return distinctMap;
  }

  List<dynamic> distinctList(List<dynamic> inputList) {
    // Map to keep track of distinct objects
    Map<String, dynamic> distinctObjects = {};

    // Loop through each object in the input list
    for (var object in inputList) {
      // Convert the object to a JSON string
      String jsonString = json.encode(object);

      // Check if the object already exists in the map
      if (!distinctObjects.containsKey(jsonString)) {
        // If not, add it to the map
        distinctObjects[jsonString] = object;
      }
    }

    // Convert the map back to a list and return it
    return distinctObjects.values.toList();
  }
}
