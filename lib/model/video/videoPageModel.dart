
import 'dart:typed_data';

import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/screen/common/collapsibleItemBuilder.dart';
import 'package:egitimaxapplication/screen/common/keyValuePairs.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPageModel {

  VideoPageModel({
    required this.isEditorMode,
    required this.userId,
    this.videoId,
  });



  AppRepositories appRepositories = AppRepositories();

  VideoPlayerController? videoPlayerController;
  bool isVideoContainerExpanded = false;
  String videoUploadStatusText='';
  String? videoObjectId;
  String fileNameOfUploaded='';

  late bool isEditorMode;
  late BigInt userId;
  late BigInt? videoId;

  bool isDelete = false;
  bool isPassive = false;
  bool isActive = true;
  bool isApproved = false;

  bool? isPublic;
  bool? isAcceptConditions;

  int videoDuration=0;
  Uint8List? videoData;
  String? videoTitle;
  String? videoDescriptions;

  int? selectedCountry;
  Map<int, String> countries = {};

  int? selectedAcademicYear;
  Map<int, String> academicYears = {};

  int? selectedGrade=1;
  Map<int, String> grades = {};

  int? selectedBranch=1;
  Map<int, String> branches = {};

  int? selectedDomain=1;
  Map<int, String> domains = {};

  int? selectedSubDomain=1;
  Map<int, String> subDomains = {};

  int? selectedLearn;

  Set<int> selectedAchievements = {1,2};
  Map<int, String> achievements = {};
  Map<String, dynamic> achievementsBulk = {};

  Future<CollapsibleItemBuilder> toKeyValuePairs () async {
    final Map<String, String> data = {
      //'Edit Mode': isEditorMode.toString(),
      //'User Id': userId.toString(),
      //'Video Id': videoId?.toString() ?? '',
      //'Is Delete': isDelete.toString(),
      //'Is Passive': isPassive.toString(),
      //'Is Active': isActive.toString(),
      //'Is Approved': isApproved.toString(),
      AppLocalization.instance.translate(
          'lib.model.video.videoPageModel',
          'toKeyValuePairs',
          'isPublic'): isPublic==true ? AppLocalization.instance.translate(
          'lib.model.video.videoPageModel',
          'toKeyValuePairs',
          'isPublicYes'): AppLocalization.instance.translate(
          'lib.model.video.videoPageModel',
          'toKeyValuePairs',
          'isPublicNo'),
      AppLocalization.instance.translate(
          'lib.model.video.videoPageModel',
          'toKeyValuePairs',
          'isAcceptConditions'): isAcceptConditions==true ?  AppLocalization.instance.translate(
          'lib.model.video.videoPageModel',
          'toKeyValuePairs',
          'isAcceptConditionsYes')
      :  AppLocalization.instance.translate(
          'lib.model.video.videoPageModel',
          'toKeyValuePairs',
          'isAcceptConditionsNo'),
      AppLocalization.instance.translate(
          'lib.model.video.videoPageModel',
          'toKeyValuePairs',
          'videoTitle'): videoTitle ?? '',
      AppLocalization.instance.translate(
          'lib.model.video.videoPageModel',
          'toKeyValuePairs',
          'videoDescriptions'): videoDescriptions ?? '',
      AppLocalization.instance.translate(
          'lib.model.video.videoPageModel',
          'toKeyValuePairs',
          'country'): countries[selectedCountry ?? 0] ?? '',
      AppLocalization.instance.translate(
          'lib.model.video.videoPageModel',
          'toKeyValuePairs',
          'academicYear'): academicYears[selectedAcademicYear ?? 0] ?? '',
      AppLocalization.instance.translate(
          'lib.model.video.videoPageModel',
          'toKeyValuePairs',
          'grade'): grades[selectedGrade ?? 0] ?? '',
      AppLocalization.instance.translate(
          'lib.model.video.videoPageModel',
          'toKeyValuePairs',
          'branch'): branches[selectedBranch ?? 0 ] ?? '',
/*      AppLocalization.instance.translate(
          'lib.model.video.videoPageModel',
          'toKeyValuePairs',
          'domain'): domains[selectedDomain ?? 0] ?? '',
      AppLocalization.instance.translate(
          'lib.model.video.videoPageModel',
          'toKeyValuePairs',
          'subDomain'): subDomains[selectedSubDomain ?? 0] ?? '',*/
    };

    var learnMainHierarchiesDataSet =
        await appRepositories.tblLearnMainHierarchies(
      'Video/GetObject',
      selectedLearn ?? 0,
      branch_id: selectedBranch,
      grade_id: selectedGrade,
    );

    var achievementTreeList = learnMainHierarchiesDataSet.selectDataTable('data');

    String? achievementTree = '';
    for (var levelItem in achievementTreeList) {
      var name = levelItem['name'];
      var type = levelItem['type'];

      if (achievementTree!.isEmpty || achievementTree == null) {
        achievementTree += name;
      } else {
        achievementTree += ' >> $name';
      }
    }

    data[AppLocalization.instance.translate(
        'lib.model.video.videoPageModel',
        'toKeyValuePairs',
        'learn')] = achievementTree ?? '';

    for(var achvId in selectedAchievements)
    {
      var tblLearnMainDataSet= await appRepositories.tblLearnMain('Question/GetObject', ['id','item_code','name'],id: achvId);
      var achCode=tblLearnMainDataSet.firstValue('data','item_code',insteadOfNull: '?');
      var achName=tblLearnMainDataSet.firstValue('data','name',insteadOfNull: '?');
      data[achCode] = achName;
    }


    List<Wrap> list = [];
    data.forEach((itemKey, itemValue) {
      list.add(
        Wrap(
          children: [Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  '$itemKey :',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 9,
                child: Text(
                  itemValue,
                  style: const TextStyle(fontWeight: FontWeight.normal),
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),]
        ),
      );

    });

    var result=CollapsibleItemBuilder(items: [
      CollapsibleItemData(
          header: Text(AppLocalization.instance.translate(
              'lib.model.video.videoPageModel',
              'toKeyValuePairs',
              'videoDetails'),style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Wrap(spacing: 5.0, runSpacing: 2.0, children:list),
          padding: 3,
          onStateChanged: (bool ) {  })
    ],
      padding: 3,
      onStateChanged: (bool ) {  },
    );
    return result;
  }


}

