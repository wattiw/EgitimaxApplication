import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/question/questionRepository.dart';
import 'package:egitimaxapplication/screen/common/achievementsCheckboxListTile.dart';
import 'package:egitimaxapplication/screen/common/commonDropdownButtonFormField.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:flutter/material.dart';

class LearnLevels extends StatefulWidget {
  final int? learnId;
  final int? branchId;
  final int? gradeId;
  final int? countryId;
  final TextStyle componentTextStyle;
  bool? isAllChecked;
  bool? showAchievements;
  Set<int> selectedAchievements;
  Function(int? learnId) onChangedLearnId;
  Function(Map<int, String>? achievements) onChangedAchievements;
  Function(Set<int>? selectedAchievements) onChangedSelectedAchievements;



  LearnLevels({
    required this.learnId,
    required this.branchId,
    required this.gradeId,
    required this.countryId,
    required this.onChangedLearnId,
    required this.onChangedSelectedAchievements,
    required this.onChangedAchievements,
    required this.selectedAchievements,
    this.isAllChecked,
    this.showAchievements,
    required this.componentTextStyle,
  });

  @override
  _LearnLevelsState createState() => _LearnLevelsState();
}

class _LearnLevelsState extends State<LearnLevels> {
  QuestionRepository questionRepository = QuestionRepository();
  AppRepositories appRepositories = AppRepositories();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getLearnHierarchies(
        widget.learnId,
        widget.branchId,
        widget.gradeId,
        widget.countryId,
      ),
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return FutureBuilder<Wrap>(
            future: createDropDownBoxesOfLearns(snapshot.data!),
            builder: (BuildContext context, AsyncSnapshot<Wrap> innerSnapshot) {
              if (innerSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (innerSnapshot.hasError) {
                return Text('Error: ${innerSnapshot.error}');
              } else if (innerSnapshot.hasData) {
                return innerSnapshot.data!;
              } else {
                return Container();
              }
            },
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> getLearnHierarchies(int? learnId, int? branchId,int? gradeId,int? countryId,) async {
    List<Map<String, dynamic>> data = [];

    if (learnId == 0 || learnId == null) {
      Map<String, dynamic> defaultLevel = {};

      var tblLearnMainDataSet = await appRepositories.tblLearnMain(
        'Question/GetObject',['id','type','name','branch_id','parent_id','grade_id','country_id'],
        parent_id_null_is_active: true,
        parent_id: null,
        branch_id: branchId,
        grade_id: gradeId,
        country_id: countryId,
      );

      var items = tblLearnMainDataSet.toKeyValuePairsWithTypes<int, String>(
        'data',
        'id',
        valueColumn: 'name',
      );

      items[0]=AppLocalization.instance.translate('lib.screen.common.learnLevels','getLearnHierarchies','pleaseSelect');

      if (items.isNotEmpty) {
        var id = tblLearnMainDataSet.firstValue('data', 'id', insteadOfNull: 0);
        var parent_id = tblLearnMainDataSet.firstValue('data', 'parent_id');
        var type = tblLearnMainDataSet.firstValue('data', 'type');
        defaultLevel['selectedId'] = 0;// id can be here dont forget
        defaultLevel['parentId'] = parent_id;
        defaultLevel['type'] = type;
        defaultLevel['items'] = items;
        data.add(defaultLevel);
      }

      return data;
    } else {
      List<Map<String, dynamic>> levels =
      await getLearnLevels(learnId, branchId, gradeId);
      int lastItemIndex = levels.length;
      int currentIndex = 1;
      if (levels.isNotEmpty) {
        for (var levelItem in levels) {
          Map<String, dynamic> level = {};

          var id = levelItem['id'];
          var parent_id = levelItem['parent_id'];
          var type = levelItem['type'];

          var tblLearnMainDataSet = await appRepositories.tblLearnMain(
            'Question/GetObject',['id','type','name','branch_id','parent_id','grade_id','country_id'],
            parent_id_null_is_active: parent_id == null ? true : false,
            parent_id: parent_id,
            grade_id: gradeId,
            branch_id: branchId,
            country_id: countryId,
          );
          Map<int, String> items = {};
          items = tblLearnMainDataSet.toKeyValuePairsWithTypes<int, String>(
            'data',
            'id',
            valueColumn: 'name',
          );

          level['selectedId'] = id;
          level['parentId'] = parent_id;
          level['type'] = type;
          level['items'] = items;
          data.add(level);

          if (currentIndex == lastItemIndex) {
            Map<String, dynamic> levelLast = {};
            var parent_id = id;
            var tblLearnMainLastDataSet = await appRepositories.tblLearnMain(
              'Question/GetObject',['id','type','name','branch_id','parent_id','grade_id','country_id'],
              parent_id_null_is_active: parent_id == null ? true : false,
              parent_id: parent_id,
              grade_id: gradeId,
              branch_id: branchId,
            );
            Map<int, String> lastItems = {};
            lastItems =
                tblLearnMainLastDataSet.toKeyValuePairsWithTypes<int, String>(
                  'data',
                  'id',
                  valueColumn: tblLearnMainLastDataSet.firstValue('data', 'type') ==
                      'ct_achv'
                      ? 'namewithitemcode'
                      : 'name',
                );
            var typeLast = tblLearnMainLastDataSet.firstValue('data', 'type');

            if (lastItems.isNotEmpty) {
              lastItems[0]=AppLocalization.instance.translate('lib.screen.common.learnLevels','getLearnHierarchies','pleaseSelect');

              levelLast['selectedId'] = 0;//lastItems.entries.first.key;
              levelLast['parentId'] = parent_id;
              levelLast['type'] = typeLast;
              levelLast['items'] = lastItems;
              data.add(levelLast);
            }
          }
          currentIndex++;
        }
      }

      return data;
    }
  }

  Future<List<Map<String, dynamic>>> getLearnLevels( int? learnId, int? branchId, int? gradeId) async {
    var learnMainHierarchiesDataSet =
    await appRepositories.tblLearnMainHierarchies(
      'Question/GetObject',
      learnId ?? 0,
      branch_id: branchId,
      grade_id: gradeId,
    );

    var levels = learnMainHierarchiesDataSet.selectDataTable('data');
    return levels;
  }

  Future<Wrap> createDropDownBoxesOfLearns(List<Map<String, dynamic>> snapshotData) async {
    List<Widget> drops = [];
    for (var item in snapshotData) {
      if (item['type'] == 'ct_achv') {
        widget.onChangedAchievements(item['items']);
        var cbl = AchievementsCheckboxListTile(
          achievements: item['items'],
          selectedAchievements: widget.selectedAchievements,
          onSelectedAchievementsChanged: (selectedAchievements) {

            widget.selectedAchievements= {};
            widget.onChangedSelectedAchievements(selectedAchievements);

          },
          componentTextStyle: widget.componentTextStyle,
        );

        if(widget.showAchievements==false) {

        }
        else
          {
            drops.add(cbl);
          }

      } else {
        var ddb = CommonDropdownButtonFormField(
          isExpandedObject: true,
          componentTextStyle: widget.componentTextStyle,
          items: item['items'],
          selectedItem: item['selectedId'],
          onSelectedItemChanged: (value) {
            widget.onChangedLearnId(value);
            debugPrint( "****************SELECTED VALUE : $value ********************");
            setState(() {

            });
          },
          label:AppLocalization.instance.translate('lib.screen.common.learnLevels','createDropDownBoxesOfLearns',item['type']) ,
          isSearchEnable: true,
        );
        drops.add(ddb);
      }
    }

    return Wrap(
      alignment: WrapAlignment.start,
      runSpacing: 10,
      spacing: 10,
      children: drops.isNotEmpty ? drops : [Container()],
    );
  }

}
