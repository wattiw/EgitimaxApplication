import 'dart:math';

import 'package:egitimaxapplication/model/common/dataTableData.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:flutter/material.dart';

class CommonDataTable extends StatefulWidget {
  List<ColumnDataType>? columnDataTypes;
  List<Widget>? toolBarButtons;
  List<String>? dataTableColumnAlias;
  List<String>? dataTableColumnNames;
  String? dataTableKeyColumnName;
  List<String>? dataTableDisableColumnFilter;
  List<String>? dataTableHideColumn;
  List<Map<Map<String, String>, Widget>>? dataTableRows;
  bool? showCheckboxColumn;
  bool? singleSelection;
  bool? showDataTableMenu;
  bool? filterSelectionMenuIsActive;
  bool? columnSelectionMenuIsActive;
  bool? exportButtonIsActive;
  bool? createDataTableColumnAlias;
  Map<String, Map<Map<String, String>, Widget>>? innerDataTableRows;
  Map<String, TextEditingController>? filterControllers;
  List<DataRow>? filteredRowData = List.empty(growable: true);
  List<dynamic>? dataTableSelectedKeys;
  Map<String, bool> selectedRowKeys = {};
  Function(List<String>? dataTableDisableColumnFilter)?
      onChangedDisabledFilters;
  List<DataRow>? onSelectedDataTableRows = List.empty(growable: true);
  Function(List<Map<String, dynamic>>? rows, List<dynamic>? rowKeys)?
      onSelectedRowsChanged;
  DataRow? filters;
  Function(
      String? filterValue,
      int index,
      Map<String, TextEditingController>? filterControllers,
      List<DataRow>? filteredRows)? onFilterValueChanged;

  CommonDataTable(
      {this.dataTableKeyColumnName,
      this.dataTableSelectedKeys,
      this.toolBarButtons,
      required this.dataTableColumnAlias,
      this.onFilterValueChanged,
      this.dataTableColumnNames,
      this.dataTableRows,
      this.showCheckboxColumn,
      this.showDataTableMenu,
        this.singleSelection,
        this.filterSelectionMenuIsActive,
        this.columnSelectionMenuIsActive,
        this.exportButtonIsActive,
      this.createDataTableColumnAlias,
      this.onSelectedRowsChanged,
      this.dataTableDisableColumnFilter,
      this.onChangedDisabledFilters,
      this.dataTableHideColumn,
      this.columnDataTypes});

  @override
  _CommonDataTableState createState() => _CommonDataTableState();
}

class _CommonDataTableState extends State<CommonDataTable> {
  bool sortAscending = false;
  int sortColumnIndex = 0;

  String generateUniqueId() {
    Random random = Random();
    int randomNumber = random.nextInt(999999);
    DateTime now = DateTime.now();
    int timestamp = now.millisecondsSinceEpoch;
    return '$timestamp$randomNumber';
  }

  void catchSelectedRows() {
    List<String> selectedDynamicKeys = [];
    widget.onSelectedDataTableRows!.clear();
    for (var item in widget.selectedRowKeys.entries) {
      if (item.key != null && item.value == true) {
        var uniqueRecordKey = item.key;
        DataRow? selectedItem;
        for (var dr in widget.filteredRowData!) {
          if (dr != null && dr.key != null) {
            var rowKey = (dr.key as ValueKey)?.value;
            if (rowKey == uniqueRecordKey) {
              selectedItem = dr;
              selectedDynamicKeys.add(rowKey);
            }
          }
        }
        if (selectedItem != null) {
          widget.onSelectedDataTableRows!.add(selectedItem!);
        }
      }
    }

    if (selectedDynamicKeys != null && selectedDynamicKeys.isNotEmpty) {
      widget.dataTableSelectedKeys = selectedDynamicKeys;
    } else {
      widget.dataTableSelectedKeys = null;
    }

    bool callType = true;
    widget.onSelectedDataTableRows != null &&
            widget.onSelectedDataTableRows!.isNotEmpty
        ? callType = true
        : callType = false;
    if (callType) {
      var jsonData = createJsonFromDataRow(
          widget.onSelectedDataTableRows!, widget.dataTableColumnNames!);
      widget.onSelectedRowsChanged!(jsonData, widget.dataTableSelectedKeys);
    } else {
      List<Map<String, dynamic>> nullResult = List.empty();
      widget.onSelectedRowsChanged!(nullResult, widget.dataTableSelectedKeys);
    }
  }

  List<Map<String, dynamic>> createJsonFromDataRow(
      List<DataRow> dataRows, List<String?> columnNames) {
    List<Map<String, dynamic>> json = [];
    widget.dataTableSelectedKeys = [];
    for (DataRow dr in dataRows) {
      dr = cellRemover(dr);

      Map<String, dynamic> row = {};
      int indexColumn = 0;
      for (DataCell dc in dr.cells) {
        var cellKey = (dc.child.key as ValueKey)?.value;
        var cellName = columnNames[indexColumn] ??
            'UnknownColumnName_${indexColumn.toString()}';
        row[cellName] = cellKey;
        // Burada key kolon herhanbiri olacağından dışarıya gönderilecek id useren key olarak belirlediği id olur
        if (cellName.toLowerCase() ==
            widget.dataTableKeyColumnName!.toLowerCase()) {
          widget.dataTableSelectedKeys!.add(cellKey.toString());
        }
        indexColumn++;
      }
      json.add(row);
    }

    return json;
  }

  DataRow cellRemover(DataRow dr) {
    var newRow = DataRow(
      cells: List.generate(
        widget.dataTableColumnNames!.length,
        (index) => DataCell(Container()),
      ),
    );

    int currentCellIndex = 0;
    for (var cell in dr.cells) {
      if (cell.child is Container) {
        Container container1 = cell.child as Container;
        if (container1.child is Container) {
          Container container2 = container1.child as Container;
          var columnName = (container2.key as ValueKey).value;
          if (widget.dataTableColumnNames!.contains(columnName)) {
            int indexOfColumn =
                widget.dataTableColumnNames!.indexOf(columnName);
            newRow.cells[indexOfColumn] = cell;
          }
        }
      }
      currentCellIndex++;
    }

    //row uyarlnaıyor
    dr = newRow;
    return dr;
  }

  void addRowsApplyingFilters() {
    fillInnerUniqueIds();
    setState(() {
      List<DataRow> result = List.empty(growable: true);

      for (var itemMapRoot in widget.innerDataTableRows!.entries) {
        var itemMap = itemMapRoot.value;

        bool isVisible = true;
        var cells = <DataCell>[];
        int colIndex = 0;
        for (var cell in itemMap.entries) {
          Map<String, String> keys = cell.key;
          Widget cellWidgetValue = cell.value;
          String? containerKey;
          String? containerdataTableKeyColumnName;
          for (var keysColumnNameAndColumnValue
              in keys.entries) // Her zaman bir adet keys gelir
          {
            containerKey = keysColumnNameAndColumnValue.value.toString() ?? '';
            containerdataTableKeyColumnName = keysColumnNameAndColumnValue.key;
            String filterText = widget
                    .filterControllers?[keysColumnNameAndColumnValue.key]
                    ?.text ??
                '';
            if (filterText != null && filterText != '') {
              isVisible = keysColumnNameAndColumnValue.value
                  .toString()
                  .toLowerCase()
                  .contains(filterText.toLowerCase());
            }
            if (!isVisible) {
              break;
            }
          }

          if (!isVisible) {
            break;
          }

          cells.add(DataCell(Container(
              alignment: Alignment.centerLeft,
              key: Key(containerKey!),
              child: Container(
                  key: Key(cell.key.entries.first.key),
                  child: cellWidgetValue))));
          colIndex++;
        }

        if (!isVisible) {
          continue;
        }

        if (isVisible) {
          result.add(
              DataRow(key: ValueKey<String>(itemMapRoot.key), cells: cells));
        }
      }

      widget.filteredRowData = result.map((DataRow row) {
        int index = result.indexOf(row);
        var uniqueRecordKey = (row.key as ValueKey).value;

        return DataRow(
          key: row.key,
          cells: row.cells,
          selected: widget.selectedRowKeys[uniqueRecordKey] ?? false,
          onSelectChanged: (bool? value) {
            onSelectedRow(value!, uniqueRecordKey);
          },
        );
      }).toList();

      int d = 4;
    });
  }

  void fillInnerUniqueIds() {
    widget.innerDataTableRows = {};
    widget.selectedRowKeys = {};
    for (var row in widget.dataTableRows!) {
      String? keyColNameValue;
      for (var item in row.entries) {
        var keyColName = widget.dataTableKeyColumnName;
        keyColNameValue = item.key[keyColName];
        if (keyColNameValue != null) {
          break;
        }
      }
      String key = keyColNameValue ?? generateUniqueId();

      var isSelected = false;
      if (widget.dataTableSelectedKeys != null &&
          widget.dataTableSelectedKeys!
              .map((key) => key.toString())
              .contains(key)) {
        isSelected = true;
      }

      widget.innerDataTableRows![key] = row;
      widget.selectedRowKeys[key] = isSelected;
    }
  }

  DataRow filters(ThemeData theme) {
    var tempColumList = List<String>.empty(growable: true);
    if (widget.dataTableColumnNames != null &&
        widget.dataTableColumnNames!.isNotEmpty) {
      for (String colName in widget.dataTableColumnNames!) {
        if (widget.dataTableHideColumn != null) {
          if (!widget.dataTableHideColumn!.contains(colName)) {
            tempColumList.add(colName);
          }
        } else {
          tempColumList.add(colName);
        }
      }
    }

    double? iconSize = theme.dataTableTheme.dataTextStyle?.fontSize ?? 12;
    iconSize = iconSize * 1.3;

    if (false) {
      var filterRow = DataRow(
          cells: tempColumList!.map((columnName) {
        if (widget.dataTableDisableColumnFilter!.contains(columnName)) {
          return DataCell(
              Container(
                alignment: Alignment.center,
                key: Key(columnName),
                child: Text(
                  '',
                  style: theme.dataTableTheme.dataTextStyle,
                ),
              ),
              placeholder: true);
        } else {
          return DataCell(
              Container(
                alignment: Alignment.center,
                key: Key(columnName),
                child: Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    // veya diğer hizalama değeri
                    child: TextField(
                      controller: widget.filterControllers?[columnName],
                      onChanged: (value) {
                        // Filtreleme mantığını burada gerçekleştirin
                        String filterText = value.trim();
                        int index =
                            widget.dataTableColumnNames!.indexOf(columnName);
                        widget.onFilterValueChanged!(
                          filterText,
                          index,
                          widget.filterControllers,
                          widget.filteredRowData,
                        );
                      },
                      style: theme.dataTableTheme.dataTextStyle,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              widget.filterControllers?[columnName]?.clear();
                            });
                          },
                          icon: Icon(
                            Icons.search,
                            size: iconSize,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 1, horizontal: 1),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              widget.filterControllers?[columnName]?.clear();
                            });
                          },
                          icon: widget.filterControllers?[columnName]?.value
                                          .text !=
                                      null &&
                                  widget.filterControllers?[columnName]?.value
                                          .text !=
                                      ''
                              ? Icon(
                                  Icons.clear,
                                  size: iconSize,
                                )
                              : const SizedBox(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              placeholder: true);
        }
      }).toList());
    }
    var filterRow = DataRow(
        cells: tempColumList!.map((columnName) {
      if (widget.dataTableDisableColumnFilter!.contains(columnName)) {
        return DataCell(
            Container(
              alignment: Alignment.center,
              key: Key(columnName),
              child: Text(
                '',
                style: theme.dataTableTheme.dataTextStyle,
              ),
            ),
            placeholder: true);
      } else {
        return DataCell(
            Container(
              alignment: Alignment.center,
              key: Key(columnName),
              child: TextField(
                controller: widget.filterControllers?[columnName],
                onChanged: (value) {
                  // Filtreleme mantığını burada gerçekleştirin
                  String filterText = value.trim();
                  int index = widget.dataTableColumnNames!.indexOf(columnName);
                  widget.onFilterValueChanged!(
                    filterText,
                    index,
                    widget.filterControllers,
                    widget.filteredRowData,
                  );
                },
                style: theme.dataTableTheme.dataTextStyle,
                decoration: InputDecoration(
                  hintText: AppLocalization.instance.translate(
                      'lib.screen.common.commonDataTable', 'filters', 'search'),
                  prefixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        widget.filterControllers?[columnName]?.clear();
                      });
                    },
                    icon: Icon(
                      Icons.search,
                      size: iconSize,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        widget.filterControllers?[columnName]?.clear();
                      });
                    },
                    icon: widget.filterControllers?[columnName]?.value.text !=
                                null &&
                            widget.filterControllers?[columnName]?.value.text !=
                                ''
                        ? Icon(
                            Icons.clear,
                            size: iconSize,
                          )
                        : const SizedBox(),
                  ),
                ),
              ),
            ),
            placeholder: true);
      }
    }).toList());

    return filterRow;
  }

  void filterController() {
    widget.filterControllers ??= {};
    for (var column in widget.dataTableColumnNames!) {
      widget.filterControllers?[column] = TextEditingController();
      widget.filterControllers?[column]?.addListener(addRowsApplyingFilters);
    }
  }

  void sortDataOld(String columnName, int columnIndex, bool sortAscending) {
    int tempColIndex = columnIndex;
    int newIndexAsPerColName = widget.dataTableColumnNames!.indexOf(columnName);

    setState(() {
      if (sortColumnIndex == columnIndex) {
        sortAscending = !sortAscending;
      } else {
        sortColumnIndex = columnIndex;
        sortAscending = !sortAscending;
        sortAscending = false;
      }

      widget.filteredRowData!.sort((a, b) {
        var foundedColumnName =
            ((a.cells[newIndexAsPerColName].child as Container).child!.key
                as ValueKey);

        var foundedColumnNameAsString = foundedColumnName.value.toString();

        if (foundedColumnNameAsString != columnName) {
          int newFoundIndex = 0;
          for (var cell in a.cells) {
            var fcn = ((cell.child as Container).child!.key as ValueKey);

            var fcnAsString = fcn.value.toString();

            if (fcnAsString == columnName) {
              newIndexAsPerColName = newFoundIndex;
              break;
            }
            newFoundIndex++;
          }
        }

        var x1 = a.cells[newIndexAsPerColName];
        var x2 = b.cells[newIndexAsPerColName];

        final aValue = (a.cells[newIndexAsPerColName].child.key as ValueKey)
            .value
            .toString();
        final bValue = (b.cells[newIndexAsPerColName].child.key as ValueKey)
            .value
            .toString();
        return sortAscending
            ? aValue.compareTo(bValue!)
            : bValue!.compareTo(aValue!);
      });
    });
  }

  void sortData(String columnName, int columnIndex, bool sortAscending) {
    int tempColIndex = columnIndex;
    int newIndexAsPerColName = widget.dataTableColumnNames!.indexOf(columnName);

    setState(() {
      if (sortColumnIndex == columnIndex) {
        sortAscending = !sortAscending;
      } else {
        sortColumnIndex = columnIndex;
        sortAscending = !sortAscending;
        sortAscending = false;
      }

      widget.filteredRowData!.sort((a, b) {
        var foundedColumnName =
            ((a.cells[newIndexAsPerColName].child as Container).child!.key
                as ValueKey);
        var foundedColumnNameAsString = foundedColumnName.value.toString();

        if (foundedColumnNameAsString != columnName) {
          int newFoundIndex = 0;
          for (var cell in a.cells) {
            var fcn = ((cell.child as Container).child!.key as ValueKey);
            var fcnAsString = fcn.value.toString();

            if (fcnAsString == columnName) {
              newIndexAsPerColName = newFoundIndex;
              break;
            }
            newFoundIndex++;
          }
        }

        var aValue = '';
        var bValue = '';

        if (a.cells[newIndexAsPerColName].child.key is ValueKey) {
          aValue = (a.cells[newIndexAsPerColName].child.key as ValueKey)
              .value
              .toString();
        } else if (a.cells[newIndexAsPerColName].child is Container) {
          aValue =
              (a.cells[newIndexAsPerColName].child as Container).key.toString();
        }

        if (b.cells[newIndexAsPerColName].child.key is ValueKey) {
          bValue = (b.cells[newIndexAsPerColName].child.key as ValueKey)
              .value
              .toString();
        } else if (b.cells[newIndexAsPerColName].child is Container) {
          bValue =
              (b.cells[newIndexAsPerColName].child as Container).key.toString();
        }

        try {
          dynamic parsedAValue;
          dynamic parsedBValue;

          // Değerleri int veya BigInt olarak dönüştürme
          if (aValue.isNotEmpty && int.tryParse(aValue) != null) {
            parsedAValue = int.parse(aValue);
          } else if (aValue.isNotEmpty && BigInt.tryParse(aValue) != null) {
            parsedAValue = BigInt.parse(aValue);
          }

          if (bValue.isNotEmpty && int.tryParse(bValue) != null) {
            parsedBValue = int.parse(bValue);
          } else if (bValue.isNotEmpty && BigInt.tryParse(bValue) != null) {
            parsedBValue = BigInt.parse(bValue);
          }

          // Sıralama işlemini gerçekleştirme
          if (sortAscending) {
            if (parsedAValue != null && parsedBValue != null) {
              return parsedAValue.compareTo(parsedBValue);
            } else {
              return aValue.compareTo(bValue);
            }
          } else {
            if (parsedAValue != null && parsedBValue != null) {
              return parsedBValue.compareTo(parsedAValue);
            } else {
              return bValue.compareTo(aValue);
            }
          }
        } catch (e) {
          return sortAscending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        }
      });
    });
  }

  void onSelectedRow(bool value, String? index) {
    if (index != null) {

      if(widget.singleSelection==true)
        {
          widget.selectedRowKeys.forEach((key, value) {
            if(key!=index)
              {
                widget.selectedRowKeys[key] = false;
              }
          });
        }

      widget.selectedRowKeys[index] = value;

      catchSelectedRows();
      setState(() {});
    }
  }

  void onSelectAll(bool isChecked) {
    isChecked != isChecked;
    setState(() {
      Map<String, bool> selectedRows = {};
      for (var item in widget.selectedRowKeys.entries) {
        selectedRows[item.key] = isChecked;
      }
      widget.selectedRowKeys = selectedRows;
    });
  }

  String addPadding(String str, double paddingCount) {
    int count = paddingCount.round();
    String paddedStr = ' ' * count + str + ' ' * count;
    return paddedStr;
  }

  List<DataColumn> buildDataTableColumnNames(ThemeData theme) {
    List<int> nonDisplayColumnIndexes = [];

    if (widget.dataTableHideColumn != null &&
        widget.dataTableHideColumn!.isNotEmpty) {
      for (var nonDisplayColumnName in widget.dataTableHideColumn!) {
        int index = widget.dataTableColumnNames!.indexOf(nonDisplayColumnName);
        nonDisplayColumnIndexes.add(index);
      }
    }

    int maxLength = 0;

    for (String str in widget.dataTableColumnAlias!) {
      if (str.length > maxLength) {
        maxLength = str.length;
      }
    }

    List<DataColumn> colList = List.empty(growable: true);

    for (var colNameAsDisplay in widget.dataTableColumnAlias!) {
      int index = widget.dataTableColumnAlias!.indexOf(colNameAsDisplay);
      if (!nonDisplayColumnIndexes.contains(index)) {
        String colName = widget.dataTableColumnNames!
            .elementAt(widget.dataTableColumnAlias!.indexOf(colNameAsDisplay));
        var dc = DataColumn(
          tooltip: colNameAsDisplay,
          label: Container(
            alignment: Alignment.centerLeft,
            key: Key(colName),
            child: Text(
              colNameAsDisplay,
              textAlign: TextAlign.center,
              style: theme.dataTableTheme.headingTextStyle,
            ),
          ),
          onSort: (columnIndex, ascending) {
            ascending = sortAscending = !sortAscending;
            sortData(colName, columnIndex, ascending);
          },
        );

        colList.add(dc);
      }
    }

    //Add column chooser
    bool addTableMenu = true;
    for (DataColumn dc in colList) {
      if (dc.tooltip == 'Table Menu') {
        addTableMenu = false;
      }
    }


    List<DataColumn> columnChooserAddedColList = addDataTableMenuToDataTableColumns(colList);
    return columnChooserAddedColList;

  }

  List<DataColumn> addDataTableMenuToDataTableColumns(
      List<DataColumn> colList) {
    if (widget.showDataTableMenu == false) {
      return colList;
    }
    //Başlangıçta görünen colonları seçmek içindir
    List<String> selectedColumnItems = [];
    for (var item in widget.dataTableColumnNames!) {
      if (widget.dataTableHideColumn != null &&
          widget.dataTableHideColumn!.isNotEmpty) {
        if (!widget.dataTableHideColumn!.contains(item)) {
          selectedColumnItems.add(item);
        }
      } else {
        selectedColumnItems.add(item);
      }
    }

    //Başlangıçta görünen colonları seçmek içindir
    List<String> selectedNonFilterColumnItems = [];
    for (var item in widget.dataTableColumnNames!) {
      if (widget.dataTableDisableColumnFilter != null &&
          widget.dataTableDisableColumnFilter!.isNotEmpty) {
        if (!widget.dataTableDisableColumnFilter!.contains(item)) {
          selectedNonFilterColumnItems.add(item);
        }
      } else {
        selectedNonFilterColumnItems.add(item);
      }
    }

    CommonDataTableMenu cDTM = CommonDataTableMenu(
      widgetList: [
        if(!(widget.columnSelectionMenuIsActive==false))
        ColumnChooserButton(
            selectedItems: selectedColumnItems,
            columnData: mergeLists(
                widget.dataTableColumnAlias!
                    .where((item) => item != 'Table Menu')
                    .toList(),
                widget.dataTableColumnNames!
                    .where((item) => item != 'TableMenu')
                    .toList()),
            onSelectionChanged: (selectedColumns) {
              widget.dataTableHideColumn = List.empty(growable: true);

              for (var columnName in widget.dataTableColumnNames!) {
                if (!selectedColumns.contains(columnName)) {
                  widget.dataTableHideColumn?.add(columnName);
                }
              }

              if (widget.dataTableHideColumn!.length ==
                  widget.dataTableColumnNames!.length) {
                if (widget.dataTableKeyColumnName != null &&
                    widget.dataTableKeyColumnName != '') {
                  widget.dataTableHideColumn!
                      .remove(widget.dataTableKeyColumnName);
                } else {
                  widget.dataTableHideColumn!.removeLast();
                }
              }

              setState(() {});
            }),
        if(!(widget.filterSelectionMenuIsActive==false))
        ColumnFilterChooserButton(
            selectedItems: selectedNonFilterColumnItems,
            columnData: mergeLists(
                widget.dataTableColumnAlias!
                    .where((item) => item != 'Table Menu')
                    .toList(),
                widget.dataTableColumnNames!
                    .where((item) => item != 'TableMenu')
                    .toList()),
            onSelectionChanged: (selectedColumns) {
              widget.dataTableDisableColumnFilter = List.empty(growable: true);

              for (var columnName in widget.dataTableColumnNames!) {
                if (!selectedColumns.contains(columnName)) {
                  widget.dataTableDisableColumnFilter?.add(columnName);
                } else {}
              }
              if (widget.onChangedDisabledFilters != null) {
                widget.onChangedDisabledFilters!(
                    widget.dataTableDisableColumnFilter);
              }

              setState(() {});
            }),
        if(!(widget.exportButtonIsActive==false))
        ExportButton(
          onPressed: () {},
        ),
      ],
    );
    List<DataColumn> columnChooserAddedColList = List.empty(growable: true);
    var dataTableMenuColumn = DataColumn(
        tooltip: "Menu",
        label: Container(
          alignment: Alignment.center,
          key: const Key('DataTableMenu'),
          child: cDTM,
        ),
        onSort: (columnIndex, ascending) => {});

    int lastColumnIndex = colList.length;
    int currentColumnIndex = 1;
    for (var dc in colList) {
      if (dc.tooltip == "Table Menu") {
        columnChooserAddedColList.add(dataTableMenuColumn);
      } else {
        columnChooserAddedColList.add(dc);
      }

      currentColumnIndex++;
    }

    return columnChooserAddedColList;
  }

  List<DataCell> nonDisplayColumnNameHideColumns(DataRow row) {
    row = cellRemover(row);

    //Hiding nodDisplayColumns
    List<int> nonDisplayColumnIndexes = [];
    if (widget.dataTableHideColumn != null) {
      for (var nonDisplayColumnName in widget.dataTableHideColumn!) {
        int index = widget.dataTableColumnNames!.indexOf(nonDisplayColumnName);
        nonDisplayColumnIndexes.add(index);
      }
    }

    int currentIndex = 0;
    List<DataCell> rowCells = [];
    for (var dc in row.cells) {
      if (nonDisplayColumnIndexes.isNotEmpty &&
          nonDisplayColumnIndexes.contains(currentIndex)) {
      } else {
        rowCells.add(dc);
      }
      currentIndex++;
    }

    return rowCells;
  }

  Map<String, String> mergeLists(List<String> keys, List<String> values) {
    final mergedMap = <String, String>{};

    if (keys.length != values.length) {
      throw ArgumentError('Key and value lists must have the same length.');
    }

    for (int i = 0; i < keys.length; i++) {
      final key = keys[i];
      final value = values[i];
      mergedMap[key] = value;
    }

    return mergedMap;
  }

  @override
  void initState() {
    if (widget.createDataTableColumnAlias == true ||
        widget.dataTableColumnAlias == null ||
        widget.dataTableColumnAlias!.isEmpty ||
        widget.dataTableColumnAlias!.length !=
            widget.dataTableColumnNames!.length) {
      var newColumnsAlias =
          convertToDisplayColumnNames(widget.dataTableColumnNames!);
      widget.dataTableColumnAlias = newColumnsAlias;
    }

    //add dataTableMenuColumAndrowCell
    addDataTableMenuColumnNameAndRowCell();

    // Bu ilk olarak hazırlanacak dikkat et.
    fillInnerUniqueIds();

    filterController();

    addRowsApplyingFilters();

    super.initState();
  }

  void addDataTableMenuColumnNameAndRowCell() {
    if (widget.showDataTableMenu != false) {
      List<Map<Map<String, String>, Widget>>? newdataTableRows =
          List.empty(growable: true);
      if (widget.dataTableDisableColumnFilter == null ||
          widget.dataTableDisableColumnFilter!.isEmpty) {
        widget.dataTableDisableColumnFilter = List.empty(growable: true);
      } else {
        widget.dataTableDisableColumnFilter =
            List.from(widget.dataTableDisableColumnFilter!, growable: true);
      }

      widget.dataTableDisableColumnFilter!.add('TableMenu');

      widget.dataTableColumnAlias =
          ['Table Menu'] + widget.dataTableColumnAlias!;
      widget.dataTableColumnNames =
          ['TableMenu'] + widget.dataTableColumnNames!;
      for (var row in widget.dataTableRows!) {
        Map<Map<String, String>, Widget> cells = {};
        Map<String, String> key = {};
        key['TableMenu'] = 'TableMenu';
        cells[key] = const Text(
          '',
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 1),
        );
        cells.addAll(row);
        newdataTableRows.add(cells);
      }

      widget.dataTableRows = newdataTableRows;
    }
  }

  List<String> convertToDisplayColumnNames(List<String> columnNames) {
    return columnNames;
    List<String> displayColumnNames = [];

    for (String columnName in columnNames) {
      String displayColumnName = '';

      for (int i = 0; i < columnName.length; i++) {
        String char = columnName[i];

        if (char == '_') {
          if (i + 1 < columnName.length && columnName[i + 1] != '_') {
            displayColumnName += ' ';
          }
        } else if (char.toUpperCase() == char) {
          displayColumnName += ' ';
        }

        displayColumnName += char;
      }

      displayColumnName = displayColumnName.trim().replaceAllMapped(
          RegExp(r'(?<=\b\w)\w'), (match) => match.group(0)!.toUpperCase());
      displayColumnNames.add(displayColumnName);
    }

    return displayColumnNames;
  }

  @override
  void dispose() {
    for (var column in widget.dataTableColumnNames!) {
      widget.filterControllers?[column]?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.dataTableColumnNames!.contains('TableMenu')) {
      addDataTableMenuColumnNameAndRowCell();
    }

    if (widget.dataTableColumnNames == null ||
        widget.dataTableColumnAlias == null ||
        widget.dataTableColumnNames!.length !=
            widget.dataTableColumnAlias!.length ||
        widget.dataTableRows == null ||
        widget.dataTableRows!.isEmpty) {
      return Container();
    }

    final theme = Theme.of(context);

    if (widget.filteredRowData != null && widget.filteredRowData!.isEmpty) {
      addRowsApplyingFilters();
    }

    widget.filters = filters(theme);
    var rows = widget.filteredRowData!.map((DataRow row) {
      //Hiding nodDisplayColumns
      List<DataCell> rowCells = nonDisplayColumnNameHideColumns(row);

      if (row.key != null && (row.key as ValueKey).value != null) {
        var uniqueRecordKey = (row.key as ValueKey).value;
        DataRow newRow = DataRow(
            cells: rowCells,
            selected: widget.selectedRowKeys[uniqueRecordKey] ?? false,
            onSelectChanged: (bool? value) {
              onSelectedRow(value!, uniqueRecordKey);
            });

        return newRow;
      } else {
        DataRow newRow = DataRow(
          cells: rowCells,
          // selected: false,
          // onSelectChanged: (bool? value) {
          //   onSelectedRow(value!, 'FilterRow');
          //}
        );
        return newRow;
      }
    }).toList();

    List<DataColumn> temColumns = buildDataTableColumnNames(theme);
    List<DataRow> tempRows = List.empty(growable: true);
    tempRows.add(widget.filters!);
    tempRows.addAll(rows);

    var datatable = DataTable(
      decoration: theme.dataTableTheme.decoration,
      dataRowColor: theme.dataTableTheme.dataRowColor,
      dataTextStyle: theme.dataTableTheme.dataTextStyle,
      checkboxHorizontalMargin: theme.dataTableTheme.checkboxHorizontalMargin,
      clipBehavior: Clip.none,
      showCheckboxColumn: widget.singleSelection==true ? false :( widget.showCheckboxColumn ?? false),
      headingRowHeight: theme.dataTableTheme.headingRowHeight,
      horizontalMargin: theme.dataTableTheme.horizontalMargin,
      dataRowMaxHeight: theme.dataTableTheme.dataRowMaxHeight,
      dataRowMinHeight: theme.dataTableTheme.dataRowMinHeight,
      columnSpacing: theme.dataTableTheme.columnSpacing,
      dividerThickness: theme.dataTableTheme.dividerThickness,
      sortAscending: sortAscending,
      sortColumnIndex: sortColumnIndex,
      headingTextStyle: theme.dataTableTheme.headingTextStyle,
      headingRowColor: theme.dataTableTheme.headingRowColor,
      columns: temColumns,
      rows: tempRows,
    );


    return Container(
      alignment: Alignment.topLeft,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (widget.toolBarButtons != null && widget.toolBarButtons!.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: widget.toolBarButtons ?? [],
            ),
          if (widget.toolBarButtons != null && widget.toolBarButtons!.isNotEmpty)
            const SizedBox(
              height: 5,
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              child: false ? Container() : datatable,
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}

class CommonDataTableMenu extends StatefulWidget {
  final List<Widget> widgetList;

  const CommonDataTableMenu({
    required this.widgetList,
    Key? key,
  }) : super(key: key);

  @override
  _CommonDataTableMenuState createState() => _CommonDataTableMenuState();
}

class _CommonDataTableMenuState extends State<CommonDataTableMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Widget>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) {
        return widget.widgetList.map((Widget widget) {
          return PopupMenuItem<Widget>(
            value: widget,
            child: widget,
          );
        }).toList();
      },
      onSelected: (Widget selectedWidget) {
        // Seçilen widget'in eventini burada işleyebilirsiniz.
      },
      offset: const Offset(0, 0),
      // Menüyü icon'un hemen altında göstermek için offset ayarı
      elevation: 1,
      // Gölge ayarı
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      // Köşe yuvarlama ayarı
      padding: EdgeInsets.zero, // Padding ayarı
    );
  }
}

class CommonButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const CommonButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
    );
  }
}

class ColumnChooserButton extends StatefulWidget {
  final Map<String, String> columnData;
  final List<String> selectedItems;
  final void Function(List<String>) onSelectionChanged;

  const ColumnChooserButton({
    required this.columnData,
    required this.selectedItems,
    required this.onSelectionChanged,
    Key? key,
  }) : super(key: key);

  @override
  _ColumnChooserButtonState createState() => _ColumnChooserButtonState();
}

class _ColumnChooserButtonState extends State<ColumnChooserButton> {
  late List<String> _selectedColumns;

  @override
  void initState() {
    super.initState();
    _selectedColumns = List<String>.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = MaterialStateColor.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) {
        return Theme.of(context).disabledColor;
      }
      return Theme.of(context).colorScheme.primary;
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: PopupMenuButton<String>(
                tooltip: AppLocalization.instance.translate(
                    'lib.screen.common.commonDataTable',
                    'columnChooserButton',
                    'choseColumn'),
                icon: Row(
                  children: [
                    Icon(
                      Icons.view_column_outlined,
                      color: textColor.resolve({}),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      AppLocalization.instance.translate(
                          'lib.screen.common.commonDataTable',
                          'columnChooserButton',
                          'choseColumn'),
                      style: TextStyle(
                        color: textColor.resolve({}),
                      ),
                    ),
                  ],
                ),
                itemBuilder: (BuildContext context) {
                  return widget.columnData.keys.map((String column) {
                    final String columnKey = widget.columnData[column]!;
                    bool isSelected = _selectedColumns.contains(columnKey);

                    return PopupMenuItem<String>(
                      value: columnKey,
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: textColor.resolve({}),
                          ),
                          SizedBox(width: 5),
                          Text(
                            column,
                            style: TextStyle(
                              color: textColor.resolve({}),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedColumns.remove(columnKey);
                          } else {
                            _selectedColumns.add(columnKey);
                          }
                        });
                        widget.onSelectionChanged(_selectedColumns);
                      },
                    );
                  }).toList();
                },
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
      ],
    );
  }
}

class ColumnFilterChooserButton extends StatefulWidget {
  final Map<String, String> columnData;
  final List<String> selectedItems;
  final void Function(List<String>) onSelectionChanged;

  const ColumnFilterChooserButton({
    required this.columnData,
    required this.selectedItems,
    required this.onSelectionChanged,
    Key? key,
  }) : super(key: key);

  @override
  _ColumnFilterChooserButton createState() => _ColumnFilterChooserButton();
}

class _ColumnFilterChooserButton extends State<ColumnFilterChooserButton> {
  late List<String> _selectedColumns;

  @override
  void initState() {
    super.initState();
    _selectedColumns = List<String>.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = MaterialStateColor.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) {
        return Theme.of(context).disabledColor;
      }
      return Theme.of(context).colorScheme.primary;
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: PopupMenuButton<String>(
                tooltip: AppLocalization.instance.translate(
                    'lib.screen.common.commonDataTable',
                    'columnFilterChooserButton',
                    'choseFilterColumn'),
                icon: Row(
                  children: [
                    Icon(
                      Icons.view_column_outlined,
                      color: textColor.resolve({}),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      AppLocalization.instance.translate(
                          'lib.screen.common.commonDataTable',
                          'columnFilterChooserButton',
                          'choseFilterColumn'),
                      style: TextStyle(
                        color: textColor.resolve({}),
                      ),
                    ),
                  ],
                ),
                itemBuilder: (BuildContext context) {
                  return widget.columnData.keys.map((String column) {
                    final String columnKey = widget.columnData[column]!;
                    bool isSelected = _selectedColumns.contains(columnKey);

                    return PopupMenuItem<String>(
                      value: columnKey,
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: textColor.resolve({}),
                          ),
                          SizedBox(width: 5),
                          Text(
                            column,
                            style: TextStyle(
                              color: textColor.resolve({}),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedColumns.remove(columnKey);
                          } else {
                            _selectedColumns.add(columnKey);
                          }
                        });
                        widget.onSelectionChanged(_selectedColumns);
                      },
                    );
                  }).toList();
                },
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
      ],
    );
  }
}

class EditButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EditButton({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonButton(
      icon: Icons.edit,
      text: AppLocalization.instance
          .translate('lib.screen.common.commonDataTable', 'editButton', 'edit'),
      onPressed: onPressed,
    );
  }
}

class DeleteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DeleteButton({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonButton(
      icon: Icons.delete,
      text: AppLocalization.instance.translate(
          'lib.screen.common.commonDataTable', 'deleteButton', 'delete'),
      onPressed: onPressed,
    );
  }
}

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SaveButton({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonButton(
      icon: Icons.save,
      text: AppLocalization.instance
          .translate('lib.screen.common.commonDataTable', 'saveButton', 'save'),
      onPressed: onPressed,
    );
  }
}

class ExportButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ExportButton({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonButton(
      icon: Icons.output,
      text: AppLocalization.instance.translate(
          'lib.screen.common.commonDataTable', 'exportButton', 'export'),
      onPressed: onPressed,
    );
  }
}
