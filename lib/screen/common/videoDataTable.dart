/*
import 'package:dropdown_search/dropdown_search.dart';
import 'package:egitimaxapplication/model/common/dataTableData.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/video/videoRepository.dart';
import 'package:egitimaxapplication/screen/common/collapsibleItemBuilder.dart';
import 'package:egitimaxapplication/screen/common/commonDataTable.dart';
import 'package:egitimaxapplication/screen/common/commonDropdownButtonFormField.dart';
import 'package:egitimaxapplication/screen/common/commonTextFormField.dart';
import 'package:egitimaxapplication/screen/common/learnLevels.dart';
import 'package:egitimaxapplication/screen/common/videoOverView.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:egitimaxapplication/utils/helper/getDeviceType.dart';
import 'package:egitimaxapplication/utils/widget/appBar/innerAppBar.dart';
import 'package:egitimaxapplication/utils/widget/message/uIMessage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../utils/config/language/appLocalizations.dart';

class VideoDataTable extends StatefulWidget {
  BigInt userId;
  List<BigInt>? selectedVideoIds;
  List<Map<String, dynamic>>? selectedRows = List.empty(growable: true);
  List<BigInt>? selectedRowsKeys = List.empty(growable: true);
  Function(List<Map<String, dynamic>>? rows, List<BigInt>? rowKeys)?
      onSelectedRowsChanged;
  final TextStyle componentTextStyle;
  Function(List<BigInt>? selectedVideoIds)? onSelectedVideoIdsChanged;

  VideoDataTable(
      {required this.userId,
      this.selectedVideoIds,
      required this.componentTextStyle,
      required this.onSelectedVideoIdsChanged,
      this.onSelectedRowsChanged});

  @override
  _VideoDataTableState createState() => _VideoDataTableState();
}

class _VideoDataTableState extends State<VideoDataTable> {
  AppRepositories appRepositories = AppRepositories();

  BigInt? userId;
  bool isFilterActive = false;

  Map<String, String> videoSourceList = {
    'myVideos': AppLocalization.instance.translate(
        'lib.screen.common.videoDataTable',
        '_VideoDataTableState',
        'myVideo'),
    'myFavoriteVideos': AppLocalization.instance.translate(
        'lib.screen.common.videoDataTable',
        '_VideoDataTableState',
        'myFavoriteVideo'),
    'egitimaxPublicVideos': AppLocalization.instance.translate(
        'lib.screen.common.videoDataTable',
        '_VideoDataTableState',
        'searchInEgitimax')
  };
  Map<int, String> videoSourceListAsKey = {
    0: AppLocalization.instance.translate('lib.screen.common.videoDataTable',
        '_VideoDataTableState', 'myVideo'),
    1: AppLocalization.instance.translate('lib.screen.common.videoDataTable',
        '_VideoDataTableState', 'myFavoriteVideo'),
    2: AppLocalization.instance.translate('lib.screen.common.videoDataTable',
        '_VideoDataTableState', 'searchInEgitimax')
  };
  Map<int, String> videoSourceListAsKeyValues = {
    0: 'myVideos',
    1: 'myFavoriteVideos',
    2: 'egitimaxPublicVideos'
  };

  bool isFavoriteGroupVisible = false;
  int? countryId;

  int? selectedLearn;

  String? videoSourceName;
  int? videoSourceId;

  Map<String, dynamic>? userRootDataSet;
  Map<int, String>? userRoot;

  Map<String, dynamic>? favoriteGroupsRootDataSet;
  Map<int, String>? favoriteGroupsRoot;
  int? favoriteGroupId;

  Map<String, dynamic>? academicYearsRootDataSet;
  Map<int, String>? academicYearsRoot;
  int? academicYearId;

  Map<String, dynamic>? branchesRootDataSet;
  Map<int, String>? branchesRoot;
  int? branchId;

  Map<String, dynamic>? domainsRootDataSet;
  Map<int, String>? domainsRoot;
  int? domainId;

  Map<String, dynamic>? subDomainsRootDataSet;
  Map<int, String>? subDomainsRoot;
  int? subDomainId;

  Map<String, dynamic>? gradesRootDataSet;
  Map<int, String>? gradesRoot;
  int? gradeId;

  Map<String, dynamic>? difficultiesRootDataSet;
  Map<int, String>? difficultiesRoot;
  int? difficultyId;

  String? filterTitle; // Başlangıç başlık değeri

  TextEditingController filterVideoTextController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  bool isFilterExpanded = false;

  DataTable? dataTableRoot;
  DataTableData? dataTableDataRoot;

  bool? createDataTableColumnAlias;
  List<String> dataTableColumnAlias = List.empty(growable: true);
  List<String> dataTableColumnNames = List.empty(growable: true);
  String? dataTableKeyColumnName;
  List<String>? dataTableDisableColumnFilter = List.empty(growable: true);
  List<String>? dataTableHideColumn = List.empty(growable: true);
  List<Map<Map<String, String>, Widget>>?
      dataTableRows; // Map Is List<Map<Map<columnName, columnValueAsString>, Widget(Show Your Widget With Cell Value Bind)>>?
  List<ColumnDataType> columnDataTypes = List.empty(growable: true);

  @override
  void initState() {
    widget.selectedRowsKeys ??= [];
    widget.selectedRows ??= [];
    widget.selectedVideoIds ??= [];

    super.initState();
  }

  @override
  void dispose() {
    filterVideoTextController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    userId = widget.userId;
    final theme = Theme.of(context);
    var deviceType = getDeviceType(context);

    var collapsibleItemData = CollapsibleItemData(
        isExpanded: isFilterExpanded,
        header: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Text(
                '${filterTitle == null || filterTitle == '' ? '${AppLocalization.instance.translate('lib.screen.common.videoDataTable', 'build', 'filters')} :' : ''}${filterTitle ?? AppLocalization.instance.translate('lib.screen.common.videoDataTable', 'build', 'pleaseSelectVideoSource')}',
                style: widget.componentTextStyle,
              ),
            ),
            Flexible(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.manage_search,
                ),
                SizedBox(width: 5),
                Text(AppLocalization.instance.translate(
                    'lib.screen.common.videoDataTable', 'build', 'filters')),
              ],
            ))
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (deviceType == DeviceType.mobileSmall ||
                          deviceType == DeviceType.mobileMedium ||
                          deviceType == DeviceType.mobileLarge)
                        Column(
                          children: [
                            FutureBuilder<CommonDropdownButtonFormField>(
                              future: filterAcademicYears(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<CommonDropdownButtonFormField>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!;
                                } else if (snapshot.hasError) {
                                  return Text(
                                      '${AppLocalization.instance.translate('lib.screen.common.VideoDataTable', 'build', 'error')}: ${snapshot.error}');
                                } else {
                                  return const CircularProgressIndicator(); // or any other loading indicator
                                }
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            FutureBuilder<CommonDropdownButtonFormField>(
                              future: filterDifficultyLevels(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<CommonDropdownButtonFormField>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!;
                                } else if (snapshot.hasError) {
                                  return Text(
                                      '${AppLocalization.instance.translate('lib.screen.common.videoDataTable', 'build', 'error')}: ${snapshot.error}');
                                } else {
                                  return const CircularProgressIndicator(); // or any other loading indicator
                                }
                              },
                            ),
                          ],
                        ),
                      if (deviceType != DeviceType.mobileSmall &&
                          deviceType != DeviceType.mobileMedium &&
                          deviceType != DeviceType.mobileLarge)
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child:
                                  FutureBuilder<CommonDropdownButtonFormField>(
                                future: filterAcademicYears(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<CommonDropdownButtonFormField>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    return snapshot.data!;
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        '${AppLocalization.instance.translate('lib.screen.common.VideoDataTable', 'build', 'error')}: ${snapshot.error}');
                                  } else {
                                    return const CircularProgressIndicator(); // or any other loading indicator
                                  }
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child:
                                  FutureBuilder<CommonDropdownButtonFormField>(
                                future: filterDifficultyLevels(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<CommonDropdownButtonFormField>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    return snapshot.data!;
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        '${AppLocalization.instance.translate('lib.screen.common.videoDataTable', 'build', 'error')}: ${snapshot.error}');
                                  } else {
                                    return const CircularProgressIndicator(); // or any other loading indicator
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (deviceType == DeviceType.mobileSmall ||
                          deviceType == DeviceType.mobileMedium ||
                          deviceType == DeviceType.mobileLarge)
                        Column(
                          children: [
                            FutureBuilder<CommonDropdownButtonFormField>(
                              future: filterGrades(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<CommonDropdownButtonFormField>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!;
                                } else if (snapshot.hasError) {
                                  return Text(
                                      '${AppLocalization.instance.translate('lib.screen.common.videoDataTable', 'build', 'error')}: ${snapshot.error}');
                                } else {
                                  return const CircularProgressIndicator(); // or any other loading indicator
                                }
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            FutureBuilder<CommonDropdownButtonFormField>(
                              future: filterBranches(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<CommonDropdownButtonFormField>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!;
                                } else if (snapshot.hasError) {
                                  return Text(
                                      '${AppLocalization.instance.translate('lib.screen.common.videoDataTable', 'build', 'error')}: ${snapshot.error}');
                                } else {
                                  return const CircularProgressIndicator(); // or any other loading indicator
                                }
                              },
                            )
                          ],
                        ),
                      if (deviceType != DeviceType.mobileSmall &&
                          deviceType != DeviceType.mobileMedium &&
                          deviceType != DeviceType.mobileLarge)
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child:
                                  FutureBuilder<CommonDropdownButtonFormField>(
                                future: filterGrades(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<CommonDropdownButtonFormField>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    return snapshot.data!;
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        '${AppLocalization.instance.translate('lib.screen.common.VideoDataTable', 'build', 'error')}: ${snapshot.error}');
                                  } else {
                                    return const CircularProgressIndicator(); // or any other loading indicator
                                  }
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child:
                                  FutureBuilder<CommonDropdownButtonFormField>(
                                future: filterBranches(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<CommonDropdownButtonFormField>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    return snapshot.data!;
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        '${AppLocalization.instance.translate('lib.screen.common.videoDataTable', 'build', 'error')}: ${snapshot.error}');
                                  } else {
                                    return const CircularProgressIndicator(); // or any other loading indicator
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (branchId != 0 &&
                          gradeId != 0 &&
                          gradeId != null &&
                          branchId != null)
                        LearnLevels(
                            learnId: selectedLearn,
                            branchId: branchId,
                            gradeId: gradeId,
                            countryId: countryId,
                            showAchievements: false,
                            onChangedLearnId: (selectedLearnId) {
                              selectedLearn = selectedLearnId;
                              subDomainId = selectedLearnId;
                              setState(() {});
                            },
                            onChangedSelectedAchievements:
                                (selectedAchievements) {},
                            onChangedAchievements: (achievements) {},
                            selectedAchievements: const {},
                            componentTextStyle: widget.componentTextStyle),
                      const SizedBox(
                        height: 5,
                      ),
                      if (deviceType == DeviceType.mobileSmall ||
                          deviceType == DeviceType.mobileMedium ||
                          deviceType == DeviceType.mobileLarge)
                        Column(
                          children: [
                            filterVideoText(),
                          ],
                        ),
                      const SizedBox(
                        height: 5,
                      ),
                      if (deviceType != DeviceType.mobileSmall &&
                          deviceType != DeviceType.mobileMedium &&
                          deviceType != DeviceType.mobileLarge)
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: filterVideoText(),
                            ),
                          ],
                        ),
                    ],
                  )),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await clearButtonOnPressed();
                    },
                    child: Text(AppLocalization.instance.translate(
                        'lib.screen.common.videoDataTable',
                        'build',
                        'clear')),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await searchButtonOnPressed(userId ?? BigInt.parse('0'));
                    },
                    child: Text(AppLocalization.instance.translate(
                        'lib.screen.common.videoDataTable',
                        'build',
                        'search')),
                  ),
                ],
              ),
            ],
          ),
        ),
        padding: 10,
        onStateChanged: (isFilterExpandedNew) {
          setState(() {
            isFilterExpanded = isFilterExpandedNew;
          });
        });

    var cIB = CollapsibleItemBuilder(
      items: [collapsibleItemData],
      padding: 0,
      onStateChanged: (isFilterExpandedNew) {
        setState(() {
          isFilterExpanded = isFilterExpandedNew;
        });
      },
    );

    return Scaffold(
      appBar: InnerAppBar(
        title: AppLocalization.instance.translate(
            'lib.screen.common.videoDataTable', 'build', 'videoSelector'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (deviceType == DeviceType.mobileSmall ||
                    deviceType == DeviceType.mobileMedium ||
                    deviceType == DeviceType.mobileLarge)
                  Wrap(
                    alignment: WrapAlignment.start,
                    runSpacing: 10,
                    spacing: 10,
                    children: [
                      videoSources(),
                      if (isFavoriteGroupVisible)
                        FutureBuilder<CommonDropdownButtonFormField>(
                          future: videoFavoriteGroups(),
                          builder: (BuildContext context,
                              AsyncSnapshot<CommonDropdownButtonFormField>
                                  snapshot) {
                            if (snapshot.hasData) {
                              return snapshot.data!;
                            } else if (snapshot.hasError) {
                              return Text(
                                  '${AppLocalization.instance.translate('lib.screen.common.videoDataTable', 'build', 'error')}: ${snapshot.error}');
                            } else {
                              return const CircularProgressIndicator(); // or any other loading indicator
                            }
                          },
                        ),
                      if (!isFilterExpanded)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () async {
                              await searchButtonOnPressed(
                                  userId ?? BigInt.parse('0'));
                            },
                            child: Text(AppLocalization.instance.translate(
                                'lib.screen.common.videoDataTable',
                                'build',
                                'search')),
                          ),
                        ),
                    ],
                  ),
                if (deviceType != DeviceType.mobileSmall &&
                    deviceType != DeviceType.mobileMedium &&
                    deviceType != DeviceType.mobileLarge)
                  Row(
                    children: [
                      Expanded(child: videoSources()),
                      const SizedBox(width: 3.0),
                      if (isFavoriteGroupVisible)
                        Expanded(
                          child: FutureBuilder<CommonDropdownButtonFormField>(
                            future: videoFavoriteGroups(),
                            builder: (BuildContext context,
                                AsyncSnapshot<CommonDropdownButtonFormField>
                                    snapshot) {
                              if (snapshot.hasData) {
                                return snapshot.data!;
                              } else if (snapshot.hasError) {
                                return Text(
                                    '${AppLocalization.instance.translate('lib.screen.common.videoDataTable', 'build', 'error')}: ${snapshot.error}');
                              } else {
                                return const CircularProgressIndicator(); // or any other loading indicator
                              }
                            },
                          ),
                        ),
                      if (!isFilterExpanded) const SizedBox(width: 10.0),
                      if (!isFilterExpanded)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () async {
                              await searchButtonOnPressed(
                                  userId ?? BigInt.parse('0'));
                            },
                            child: Text(AppLocalization.instance.translate(
                                'lib.screen.common.videoDataTable',
                                'build',
                                'search')),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(
                  height: 10,
                ),
                if (isFilterActive) cIB,
                Wrap(
                  children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: dataTableDataRoot != null &&
                                dataTableRows != null &&
                                dataTableRows!.isNotEmpty
                            ? CommonDataTable(
                                columnDataTypes: columnDataTypes,
                                toolBarButtons: null,
                                dataTableKeyColumnName: dataTableKeyColumnName,
                                dataTableSelectedKeys:
                                    widget.selectedVideoIds,
                                dataTableColumnAlias: dataTableColumnAlias,
                                createDataTableColumnAlias:
                                    createDataTableColumnAlias,
                                dataTableColumnNames: dataTableColumnNames,
                                dataTableDisableColumnFilter:
                                    dataTableDisableColumnFilter,
                                onChangedDisabledFilters: (disabledFilters) {
                                  dataTableDisableColumnFilter =
                                      disabledFilters;
                                  setState(() {});
                                },
                                dataTableHideColumn: dataTableHideColumn,
                                dataTableRows: dataTableRows,
                                showCheckboxColumn: true,
                                onFilterValueChanged: (
                                  filterText,
                                  index,
                                  filterControllers,
                                  filteredRows,
                                ) {},
                                onSelectedRowsChanged:
                                    (selectedRows, selectedKeys) async {
                                  widget.selectedVideoIds =
                                      await convertToBigIntList(selectedKeys);

                                  widget.selectedRows = selectedRows;
                                  widget.selectedRowsKeys =
                                      widget.selectedVideoIds;
                                  if (widget.onSelectedRowsChanged != null) {
                                    widget.onSelectedRowsChanged!(selectedRows,
                                        widget.selectedVideoIds);
                                  }
                                  if (widget.onSelectedVideoIdsChanged !=
                                      null) {
                                    widget.onSelectedVideoIdsChanged!(
                                        widget.selectedVideoIds);
                                  }
                                },
                              )
                            : Center(
                                child: Text(AppLocalization.instance.translate(
                                    'lib.screen.common.videoDataTable',
                                    'build',
                                    'noData'))))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // İptal butonuna basıldığında yapılacak işlemler
                        Navigator.pop(context);
                      },
                      child: Text(AppLocalization.instance.translate(
                          'lib.screen.common.videoDataTable',
                          'build',
                          'cancel')),
                    ),
                    if (dataTableRows != null && dataTableRows!.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          if (widget.onSelectedRowsChanged != null) {
                            widget.onSelectedRowsChanged!(
                                widget.selectedRows, widget.selectedRowsKeys);
                          }

                          if (widget.onSelectedVideoIdsChanged != null) {
                            widget.onSelectedVideoIdsChanged!(
                                widget.selectedVideoIds);
                          }

                          Navigator.pop(context);
                        },
                        child: Text(AppLocalization.instance.translate(
                            'lib.screen.common.videoDataTable',
                            'build',
                            'save')),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<BigInt> convertToBigIntList(List<dynamic>? dataTableSelectedKeys) {
    List<BigInt> convertedKeys = [];

    if (dataTableSelectedKeys != null) {
      for (dynamic item in dataTableSelectedKeys) {
        try {
          BigInt convertedItem = BigInt.parse(item.toString());
          convertedKeys.add(convertedItem);
        } catch (e) {
          // Conversion failed for the item, move to the next item
        }
      }
    }

    return convertedKeys;
  }

  Future<void> searchButtonOnPressed(BigInt userId) async {
    dataTableRoot = null;
    dataTableDataRoot = null;
    dataTableRows = null;
    final theme = Theme.of(context);
    if (videoSourceName != null) {
      var VideoRepository = await appRepositories.videoRepository();

      var dataSet = await videoRepository.getVideoDataTableData(['*'],
          getNoSqlData: 0,
          user_id_for_isMyFavorite: widget.userId,
          user_id: videoSourceName != 'egitimaxPublicVideos'
              ? widget.userId
              : null,
          isMyFavorite: videoSourceName == 'myFavoriteVideos' ? 1 : null,
          favGroupId: videoSourceName == 'myFavoriteVideos'
              ? favoriteGroupId == 0
                  ? null
                  : favoriteGroupId
              : null,
          academic_year: academicYearId == 0 ? null : academicYearId,
          difficulty_lev: difficultyId == 0 ? null : difficultyId,
          grade_id: gradeId == 0 ? null : gradeId,
          branch_id: branchId == 0 ? null : branchId,
          learn_id: selectedLearn == 0 ? null : selectedLearn,
          video_text: filterVideoTextController.text == '' ||
                  filterVideoTextController.text.isEmpty
              ? null
              : filterVideoTextController.text);
      if (dataSet != null && dataSet.entries.isNotEmpty) {
        var dataTable = dataSet.getDataTable();
        if (dataTable != null &&
            dataTable.columns != null &&
            dataTable.columns.isNotEmpty) {
          var dataTableData = dataSet.getDataTableData();
          // Update VideoColumn Widget As Text Button Widget
          List<Map<Map<String, String>, Widget>> modifiedRows =
              dataTableData.rowsAsWidget.map((row) {
            Map<Map<String, String>, Widget> modifiedRow = {};

            row.forEach((keyMap, widget) {
              BigInt idValue = BigInt.parse('0');
              var idCell;
              try {
                idCell = row.entries.firstWhere(
                  (element) => element.key.entries.first.key == "id",
                );
              } catch (e) {
                debugPrint(e.toString());
                idCell = null;
              }

              if (idCell != null) {
                idValue =
                    BigInt.parse(idCell.key.entries.first.value.toString());
              }

              if (keyMap.entries.first.key == "video_text") {
                modifiedRow[keyMap] = MouseRegion(
                  onHover: (event) {
                    // Handle hover event
                    // Set a flag or update state to show the widget element
                  },
                  onExit: (event) {
                    // Handle exit event
                    // Reset the flag or update state to hide the widget element
                  },
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Container() ;// VideoOverView( videoId: idValue, userId: userId, );
                        },
                      );
                    },
                    style: ButtonStyle(
                      textStyle: MaterialStateProperty.all<TextStyle>(
                        TextStyle(
                            fontSize:
                                theme.dataTableTheme.dataTextStyle?.fontSize),
                      ),
                    ),
                    child: Tooltip(
                      message: keyMap.entries.first.value ?? "",
                      child: Wrap(
                        children: [
                          Text(
                            keyMap.entries.first.value != null &&
                                    keyMap.entries.first.value.length > 20
                                ? "${keyMap.entries.first.value.substring(0, 20)}..."
                                : keyMap.entries.first.value ?? "",
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (keyMap.entries.first.key == "achievementTree") {
                var reversedAchievementTree =
                    keyMap.entries.first.value.split('>>').toList();
                var reversedString =
                    reversedAchievementTree.reversed.toList().join('>>');
                modifiedRow[keyMap] = Text(reversedString);
              } else {
                modifiedRow[keyMap] = widget;
              }
            });

            return modifiedRow;
          }).toList();

          if (dataTableData != null &&
              dataTableData.columns.isNotEmpty &&
              dataTableData.rowsAsWidget != null &&
              dataTableData.rowsAsWidget.isNotEmpty) {}
          columnDataTypes = dataTableData.columnDataTypes;
          createDataTableColumnAlias = false;
          dataTableRoot = dataTable;
          dataTableDataRoot = dataTableData;
          dataTableColumnAlias = [
            AppLocalization.instance.translate(
                'lib.screen.common.videoDataTable',
                'searchButtonOnPressed',
                'id'),
            AppLocalization.instance.translate(
                'lib.screen.common.videoDataTable',
                'searchButtonOnPressed',
                'academicYear'),
            AppLocalization.instance.translate(
                'lib.screen.common.videoDataTable',
                'searchButtonOnPressed',
                'Video'),
            AppLocalization.instance.translate(
                'lib.screen.common.videoDataTable',
                'searchButtonOnPressed',
                'difficultyLevel'),
            AppLocalization.instance.translate(
                'lib.screen.common.videoDataTable',
                'searchButtonOnPressed',
                'branchName'),
            AppLocalization.instance.translate(
                'lib.screen.common.videoDataTable',
                'searchButtonOnPressed',
                'achievementTree'),
            AppLocalization.instance.translate(
                'lib.screen.common.videoDataTable',
                'searchButtonOnPressed',
                'createdOn'),
            AppLocalization.instance.translate(
                'lib.screen.common.videoDataTable',
                'searchButtonOnPressed',
                'favorite'),
          ];
          dataTableColumnNames = [
            'id',
            'acad_year',
            'video_text',
            'dif_level',
            'branch_name',
            'achievementTree',
            'created_on',
            'favCount'
          ];
          dataTableKeyColumnName = 'id';
          dataTableDisableColumnFilter = ['id'];
          dataTableHideColumn = [
            'dif_level',
            'branch_name',
            'learn_data',
            'created_on'
          ];
          dataTableRows =
              modifiedRows; //dataTableData.rowsAsWidget; // Map Is List<Map<Map<columnName, columnValueAsString>, Widget(Show Your Widget With Cell Value Bind)>>?
        }
      }
      setState(() {});
    } else {
      UIMessage.showError(
          AppLocalization.instance.translate(
              'lib.screen.common.VideoDataTable',
              'searchButtonOnPressed',
              'pleaseSelectSourceType'),
          gravity: ToastGravity.CENTER);
    }
  }

  Future<void> clearButtonOnPressed() async {
    setState(() {
      academicYearId = 0;
      branchId = 0;
      gradeId = 0;
      difficultyId = 0;
      domainId = 0;
      domainsRoot = null;
      subDomainId = 0;
      subDomainsRoot = null;
      selectedLearn = null;
      filterVideoTextController.text = '';
      isFilterActive = false;
      isFilterExpanded = false;
    });
  }

  Future<CommonDropdownButtonFormField> filterAcademicYears() async {
    var academicYearsDataSet = academicYearsRootDataSet ??
        await appRepositories.tblUtilAcademicYear(
            'Video/GetObject', ['id', 'acad_year', 'is_default']);
    academicYearsRootDataSet ??= academicYearsDataSet;

    var academicYears = academicYearsRoot ??
        academicYearsDataSet.toKeyValuePairsWithTypes<int, String>('data', 'id',
            valueColumn: 'acad_year');
    //Add NotSelectableItem
    academicYears[0] = AppLocalization.instance.translate(
        'lib.screen.common.videoDataTable', 'filterAcademicYears', 'all');

    academicYearsRoot ??= academicYears;

    var defaultAcademicYear = !isFilterExpanded
        ? null
        : academicYearsDataSet.firstValue('data', 'id',
            filterColumn: 'is_default', filterValue: true, insteadOfNull: 0);
    academicYearId ??= defaultAcademicYear;

    if (academicYearsRoot == null) {
      //return emptySearchableDropDown();
    }

    return CommonDropdownButtonFormField(
      isExpandedObject: true,
      isSearchEnable: true,
      items: academicYears,
      label: AppLocalization.instance.translate(
          'lib.screen.common.videoDataTable',
          'filterAcademicYears',
          'academicYear'),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: AppLocalization.instance.translate(
              'lib.screen.common.videoDataTable',
              'filterAcademicYears',
              'academicYear'),
          hintText: AppLocalization.instance.translate(
              'lib.screen.common.videoDataTable',
              'filterAcademicYears',
              'pleaseSelectAcademicYear'),
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
        baseStyle: widget.componentTextStyle ?? const TextStyle(fontSize: 10),
      ),
      onSelectedItemChanged: (selectedItem) {
        academicYearId = academicYears.entries
            .map((entry) => entry)
            .toList()
            .firstWhere((item) => selectedItem == item.key)
            .key;
      },
      selectedItem: academicYearId,
      componentTextStyle: widget.componentTextStyle,
    );
  }

  Future<CommonDropdownButtonFormField> filterGrades() async {
    var gradesDataSet = gradesRootDataSet ??
        await appRepositories
            .tblClassGrade('Video/GetObject', ['id', 'grade_name']);
    gradesRootDataSet ??= gradesDataSet;

    var grades = gradesRoot ??
        gradesDataSet.toKeyValuePairsWithTypes<int, String>('data', 'id',
            valueColumn: 'grade_name');
    //Add NotSelectableItem
    grades[0] = AppLocalization.instance.translate(
        'lib.screen.common.videoDataTable', 'filterGrades', 'all');

    gradesRoot ??= grades;

    var userDataSet = userRootDataSet ??
        await appRepositories.tblUserMain(
            'Video/GetObject', ['id', 'grade_id'],
            id: widget.userId);
    userRootDataSet ??= userDataSet;

    var defaultGrade = !isFilterExpanded
        ? null
        : gradeId ??
            userDataSet.firstValue('data', 'grade_id',
                insteadOfNull: grades.entries.first.key);
    gradeId ??= defaultGrade;

    return CommonDropdownButtonFormField(
      isExpandedObject: true,
      isSearchEnable: true,
      label: AppLocalization.instance.translate(
          'lib.screen.common.videoDataTable', 'filterGrades', 'gradeName'),
      items: grades,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: AppLocalization.instance.translate(
              'lib.screen.common.videoDataTable',
              'filterGrades',
              'gradeName'),
          hintText: AppLocalization.instance.translate(
              'lib.screen.common.videoDataTable',
              'filterGrades',
              'pleaseSelectGradeName'),
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
        baseStyle: widget.componentTextStyle ?? const TextStyle(fontSize: 10),
      ),
      onSelectedItemChanged: (selectedItem) {
        gradeId = grades.entries
            .map((entry) => entry)
            .toList()
            .firstWhere((item) => selectedItem == item.key)
            .key;
        selectedLearn = null;
        branchId = null;
        setState(() {});
      },
      selectedItem: gradeId,
      componentTextStyle: widget.componentTextStyle,
    );
  }

  Future<CommonDropdownButtonFormField> filterBranches() async {
    var branchesDataSet = branchesRootDataSet ??
        await appRepositories
            .tblLearnBranch('Video/GetObject', ['id', 'branch_name']);
    branchesRootDataSet ??= branchesDataSet;

    var branches = branchesRoot ??
        branchesDataSet.toKeyValuePairsWithTypes<int, String>('data', 'id',
            valueColumn: 'branch_name');
    //Add NotSelectableItem
    branches[0] = AppLocalization.instance.translate(
        'lib.screen.common.videoDataTable', 'filterBranches', 'all');
    branchesRoot = branches;

    var branchesMapDataSet = await appRepositories.tblTheaBranMap(
        'Video/GetObject', ['id', 'branch_id', 'user_id'],
        user_id: widget.userId);
    var defaultBranch = !isFilterExpanded
        ? null
        : branchesMapDataSet.firstValue('data', 'branch_id',
            insteadOfNull: branches.entries.first.key);

    branchId ??= defaultBranch;

    return CommonDropdownButtonFormField(
      isExpandedObject: true,
      isSearchEnable: true,
      items: branches,
      label: AppLocalization.instance.translate(
          'lib.screen.common.videoDataTable',
          'filterBranches',
          'branchName'),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: AppLocalization.instance.translate(
              'lib.screen.common.videoDataTable',
              'filterBranches',
              'branchName'),
          hintText: AppLocalization.instance.translate(
              'lib.screen.common.videoDataTable',
              'filterBranches',
              'pleaseSelectBranchName'),
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
        baseStyle: widget.componentTextStyle ?? const TextStyle(fontSize: 10),
      ),
      onSelectedItemChanged: (selectedItem) async {
        branchId = branches.entries
            .map((entry) => entry)
            .toList()
            .firstWhere((item) => selectedItem == item.key)
            .key;
        if (countryId == null || countryId == 0) {
          Locale currentLocale = WidgetsBinding.instance.window.locale;
          String languageCode = currentLocale.languageCode; // 'tr'
          String countryCode = currentLocale.languageCode; // 'TR'

          var tblLocL1Country = await appRepositories.tblLocL1Country(
            'Video/GetObject',
            ['id', 'countrycode'],
          );
          countryId = tblLocL1Country.firstValue('data', 'id',
              filterColumn: 'countrycode',
              filterValue: countryCode.toUpperCase(),
              insteadOfNull: 0);

          var userDataSet = await appRepositories.tblUserMain(
              'Video/GetObject', ['id', 'country_id'],
              id: widget.userId);
          countryId = userDataSet.firstValue('data', 'country_id',
              insteadOfNull: countryId);
        }
        selectedLearn = null;
        setState(() {});
      },
      selectedItem: branchId,
      componentTextStyle: widget.componentTextStyle,
    );
  }

  Future<CommonDropdownButtonFormField> filterDifficultyLevels() async {
    var difficultyDataSet = difficultiesRootDataSet ??
        await appRepositories
            .tblUtilDifficulty('Video/GetObject', ['id', 'dif_level']);

    difficultiesRootDataSet ??= difficultyDataSet;

    var difficulties = difficultiesRoot ??
        difficultyDataSet.toKeyValuePairsWithTypes<int, String>('data', 'id',
            valueColumn: 'dif_level');
    //Add NotSelectableItem
    difficulties[0] = AppLocalization.instance.translate(
        'lib.screen.common.videoDataTable', 'filterDifficultyLevels', 'all');

    difficultiesRoot ??= difficulties;

    var defaultDifficulty = true
        ? 0
        : difficultyId ??
            difficultyDataSet.firstValue('data', 'id',
                filterColumn: 'dif_level',
                filterValue: 'dif_medium',
                insteadOfNull: difficulties.entries.first.key);
    difficultyId ??= defaultDifficulty;

    return CommonDropdownButtonFormField(
      isExpandedObject: true,
      isSearchEnable: true,
      items: difficulties,
      label: AppLocalization.instance.translate(
          'lib.screen.common.videoDataTable',
          'filterDifficultyLevels',
          'difficultyLevel'),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: AppLocalization.instance.translate(
              'lib.screen.common.videoDataTable',
              'filterDifficultyLevels',
              'difficultyLevel'),
          hintText: AppLocalization.instance.translate(
              'lib.screen.common.videoDataTable',
              'filterDifficultyLevels',
              'pleaseSelectDifficultyLevel'),
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
        baseStyle: widget.componentTextStyle ?? const TextStyle(fontSize: 10),
      ),
      onSelectedItemChanged: (selectedItem) {
        difficultyId = difficulties.entries
            .map((entry) => entry)
            .toList()
            .firstWhere((item) => selectedItem == item.key)
            .key;
      },
      selectedItem: difficulties.entries
          .map((entry) => entry)
          .toList()
          .firstWhere((item) => difficultyId == item.key)
          .value,
      componentTextStyle: widget.componentTextStyle,
    );
  }

  DropdownSearch<dynamic> emptySearchableDropDown() {
    return DropdownSearch<dynamic>(
      enabled: false,
      popupProps: const PopupProps.menu(
        showSearchBox: true,
        // showSelectedItems: true, // Commented out this line
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
        baseStyle: widget.componentTextStyle ?? const TextStyle(fontSize: 10),
      ),
    );
  }

  StatefulWidget filterVideoText() {
    return CommonTextFormField(
        controller: filterVideoTextController,
        labelText: AppLocalization.instance.translate(
            'lib.screen.common.videoDataTable',
            'filterVideoText',
            'videoKeyWords'));
  }

  Future<CommonDropdownButtonFormField> videoFavoriteGroups() async {
    var userFavoriteGroupsDataSet = favoriteGroupsRootDataSet ??
        await appRepositories.tblFavGroupQuest(
            'Video/GetObject', ['id', 'group_name', 'user_id'],
            user_id: widget.userId);
    favoriteGroupsRootDataSet ??= userFavoriteGroupsDataSet;

    var favoriteGroups = favoriteGroupsRoot ??
        userFavoriteGroupsDataSet.toKeyValuePairsWithTypes<int, String>(
            'data', 'id',
            valueColumn: 'group_name');
    favoriteGroups[0] = AppLocalization.instance.translate(
        'lib.screen.common.videoDataTable', 'videoFavoriteGroups', 'all');

    favoriteGroupsRoot ??= favoriteGroups;

    favoriteGroupId ??= 0;

    return CommonDropdownButtonFormField(
      isExpandedObject: true,
      isSearchEnable: true,
      label: AppLocalization.instance.translate(
          'lib.screen.common.videoDataTable',
          'videoFavoriteGroups',
          'favGroup'),
      selectedItem: favoriteGroupId,
      items: favoriteGroups,
      onSelectedItemChanged: (value) {
        favoriteGroupId = value;
      },
      componentTextStyle: widget.componentTextStyle,
    );
  }

  CommonDropdownButtonFormField videoSources() {
    return CommonDropdownButtonFormField(
      isExpandedObject: true,
      label: AppLocalization.instance.translate(
          'lib.screen.common.videoDataTable',
          'videoSources',
          'videoResource'),
      isSearchEnable: true,
      selectedItem: videoSourceId,
      items: videoSourceListAsKey,
      onSelectedItemChanged: (videoSourceId) {
        var value = videoSourceListAsKeyValues[videoSourceId];
        videoSourceName = value;

        setState(() {
          filterTitle = videoSourceList[value];
          videoSourceName = value;
          if (value != null) {
            isFilterActive = true;
          } else {
            isFilterActive = false;
          }

          if (filterTitle.toString().toLowerCase().contains('favorite')) {
            isFavoriteGroupVisible = true;
          } else {
            isFavoriteGroupVisible = false;
          }

          if (value == 'egitimaxPublicVideos') {
            isFilterExpanded = true;
          } else {
            isFilterExpanded = false;
          }
        });
      },
      componentTextStyle: widget.componentTextStyle,
    );
  }
}
*/