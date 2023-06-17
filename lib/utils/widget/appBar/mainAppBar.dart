import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/constant/appConstant/generalAppConstant.dart';
import 'package:flutter/material.dart';

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback onAvatarPressed;
  final List<PopupMenuEntry> menuItems;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onSearchPressed;
  final VoidCallback onChangeLanguage;

  const MainAppBar({
    Key? key,
    required this.onAvatarPressed,
    required this.menuItems,
    required this.onQueryChanged,
    required this.onSearchPressed,
    required this.onChangeLanguage,
  }) : super(key: key);

  @override
  _MainAppBarState createState() => _MainAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);
}


class _MainAppBarState extends State<MainAppBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double appBarRowHeight = widget.preferredSize.height / 2;
    return AppBar(
      titleSpacing: 10.0,
      backgroundColor: theme.colorScheme.background,
      flexibleSpace: Column(
        children: [
          SizedBox(
            height: appBarRowHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(width: 15),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: SizedBox(
                    child: Image.asset(GeneralAppConstant.AppLogoPath,
                        fit: BoxFit.cover),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: SizedBox(
                      child: TextField(
                        onChanged: widget.onQueryChanged,
                        decoration: InputDecoration(
                          hintText: AppLocalization.instance.translate(
                              'lib.utils.widget.appBar.mainAppBar',
                              'build',
                              'searchBarHinttext'),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: IconButton(
                    onPressed: widget.onSearchPressed,
                    icon: Icon(
                      Icons.search,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton(
                  itemBuilder: (BuildContext context) => widget.menuItems,
                  offset: const Offset(0, kToolbarHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: (appBarRowHeight * 0.75),
                        width: (appBarRowHeight * 0.75),
                        child: ClipOval(
                          child: Image.asset(GeneralAppConstant.UserProfileImagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          SizedBox(
            height: appBarRowHeight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.home,
                            color: theme.colorScheme.primary,
                          ),
                          Text(AppLocalization.instance.translate(
                              'lib.utils.widget.appBar.mainAppBar',
                              'build',
                              'appBarHomeButtonText')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people,
                            color: theme.colorScheme.primary,
                          ),
                          Text(AppLocalization.instance.translate(
                              'lib.utils.widget.appBar.mainAppBar',
                              'build',
                              'appBarNetworkButtonText')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.school,
                            color: theme.colorScheme.primary,
                          ),
                          Text(AppLocalization.instance.translate(
                              'lib.utils.widget.appBar.mainAppBar',
                              'build',
                              'appBarLessonsButtonText')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment,
                            color: theme.colorScheme.primary,
                          ),
                          Text(AppLocalization.instance.translate(
                              'lib.utils.widget.appBar.mainAppBar',
                              'build',
                              'appBarTasksButtonText')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.chat,
                            color: theme.colorScheme.primary,
                          ),
                          Text(AppLocalization.instance.translate(
                              'lib.utils.widget.appBar.mainAppBar',
                              'build',
                              'appBarMessagingButtonText')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications,
                            color: theme.colorScheme.primary,
                          ),
                          Text(AppLocalization.instance.translate(
                              'lib.utils.widget.appBar.mainAppBar',
                              'build',
                              'appBarNotificationsButtonText')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap:widget.onChangeLanguage,
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.language_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          Text(AppLocalization.instance.translate(AppLocalization.instance.locale.toString())),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton(
                    itemBuilder: (BuildContext context) => widget.menuItems,
                    offset: const Offset(0, kToolbarHeight),
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.settings,
                            color: theme.colorScheme.primary,
                          ),
                          Text(AppLocalization.instance.translate(
                              'lib.utils.widget.appBar.mainAppBar',
                              'build',
                              'appBarSettingsButtonText')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomPopupMenu {
  static List<PopupMenuEntry> getMenuItems(BuildContext context) {
    final theme = Theme.of(context);
    return <PopupMenuEntry>[
      PopupMenuItem(
        value: 1,
        child: Text(AppLocalization.instance.translate(
            'lib.utils.widget.appBar.mainAppBar',
            'CustomPopupMenu',
            'PopupMenuItemOptionOne')),
      ),
      PopupMenuItem(
        value: 2,
        child: Text(AppLocalization.instance.translate(
            'lib.utils.widget.appBar.mainAppBar',
            'CustomPopupMenu',
            'PopupMenuItemOptionTwo')),
      ),
      const PopupMenuDivider(),
      CheckedPopupMenuItem(
        value: 3,
        checked: true,
        child: Text(AppLocalization.instance.translate(
            'lib.utils.widget.appBar.mainAppBar',
            'CustomPopupMenu',
            'CheckedPopupMenuItemCheckedOption')),
      ),
      PopupMenuItem(
        value: 4,
        child: ListTile(
          leading: Icon(
            Icons.add,
            color: theme.colorScheme.primary,
          ),
          title: Text(AppLocalization.instance.translate(
              'lib.utils.widget.appBar.mainAppBar',
              'CustomPopupMenu',
              'PopupMenuItemListTimeOption')),
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 5,
        child: Row(
          children: [
            Icon(
              Icons.mail,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Text(AppLocalization.instance.translate(
                'lib.utils.widget.appBar.mainAppBar',
                'CustomPopupMenu',
                'PopupMenuItemCustomRowItem')),
          ],
        ),
      ),
      PopupMenuItem(
        value: 6,
        child: Container(
          color: theme.colorScheme.background,
          padding: const EdgeInsets.all(10),
          child: Text(AppLocalization.instance.translate(
              'lib.utils.widget.appBar.mainAppBar',
              'CustomPopupMenu',
              'PopupMenuItemCustomContainerItem')),
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 7,
        child: Column(
          children: [
            Icon(
              Icons.star,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 5),
            Text(AppLocalization.instance.translate(
                'lib.utils.widget.appBar.mainAppBar',
                'CustomPopupMenu',
                'PopupMenuItemCustomColumnItem')),
          ],
        ),
      ),
    ];
  }
}
