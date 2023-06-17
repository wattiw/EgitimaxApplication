import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:flutter/material.dart';
//Test
class AchievementsCheckboxListTile extends StatefulWidget {
  AchievementsCheckboxListTile({
    Key? key,
    required this.achievements,
    this.selectedAchievements,
    required this.onSelectedAchievementsChanged,
    required this.componentTextStyle,
  }) : super(key: key);

  final Map<int, String>? achievements;
  late Set<int>? selectedAchievements;
  final Function(Set<int>) onSelectedAchievementsChanged;
  final TextStyle componentTextStyle;
  bool isAllChecked=false;


  @override
  _AchievementsCheckboxListTileState createState() =>
      _AchievementsCheckboxListTileState();
}

class _AchievementsCheckboxListTileState
    extends State<AchievementsCheckboxListTile> {
  void _onChanged(int key, bool? checked) {
    removeNotExistAchievementsInTheList();

    setState(() {
      if (checked == true) {
        widget.selectedAchievements?.add(key);
      } else {
        widget.selectedAchievements?.remove(key);
      }
    });

    widget.onSelectedAchievementsChanged(widget.selectedAchievements ?? {});
  }

  void removeNotExistAchievementsInTheList() {
    Set<int>? newSelectedAchievement = {};
    for (var achvId in widget.selectedAchievements!) {
      if (widget.achievements != null) {
        for (var achvEntry in widget.achievements!.entries) {
          if (achvEntry.key != achvId &&
              widget.selectedAchievements != null &&
              widget.selectedAchievements!.isNotEmpty) {
          } else {
            newSelectedAchievement.add(achvEntry.key);
          }
        }
      } else {}
    }
    widget.selectedAchievements = newSelectedAchievement;
  }

  @override
  Widget build(BuildContext context) {

    if(widget.selectedAchievements!=null && widget.achievements!=null &&  widget.selectedAchievements?.length==widget.achievements?.length)
      { widget.isAllChecked=true;}
    else
      {
        widget.isAllChecked=false;
      }


    if (widget.achievements == null || widget.achievements?.length == 0) {
      return Container();
    } else {
      if (!widget.achievements!.containsKey(widget.selectedAchievements)) {}
    }

    return Wrap(
      alignment: WrapAlignment.start,
      children: [
        const SizedBox(width: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Text(
                AppLocalization.instance.translate(
                    'lib.screen.common.achievementsCheckboxListTile',
                    'build',
                    'achievements'),
                style: widget.componentTextStyle,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Tooltip(
                message: AppLocalization.instance.translate(
                    'lib.screen.common.achievementsCheckboxListTile',
                    'build',
                    'checkUnCheck'),
                child: Checkbox(
                  value:widget.isAllChecked,
                  onChanged: (value) {
                    widget.isAllChecked=value!;


                    if (value!) {

                      widget.selectedAchievements = widget.selectedAchievements
                          ?.union(widget.achievements!.keys.toSet());
                    } else {

                      widget.selectedAchievements?.clear();
                    }

                    removeNotExistAchievementsInTheList();
                    widget.onSelectedAchievementsChanged(
                        widget.selectedAchievements ?? {});

setState(() {

});
                  },
                ),
              ),
            ),
            const SizedBox(
              width: 30,
            )
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 500,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: widget.achievements?.entries
                            .map((entry) => CheckboxListTile(
                                  title: Text(
                                    entry.value,
                                    style: widget.componentTextStyle,
                                  ),
                                  value: widget.selectedAchievements
                                          ?.contains(entry.key) ??
                                      false,
                                  onChanged: (checked) =>
                                      _onChanged(entry.key, checked),
                                ))
                            .toList() ??
                        [],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
