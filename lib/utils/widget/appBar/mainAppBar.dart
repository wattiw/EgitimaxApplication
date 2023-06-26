import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/config/language/localizationLoader.dart';
import 'package:egitimaxapplication/utils/constant/appConstant/generalAppConstant.dart';
import 'package:egitimaxapplication/utils/widget/drawer/mainDrawer.dart';
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MainAppBarState extends State<MainAppBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double appBarRowHeight = widget.preferredSize.height / 2;

    return AppBar(
      leading: IconButton(
        icon: PopupMenuButton(
          itemBuilder: (BuildContext context) => widget.menuItems,
          offset: const Offset(0, kToolbarHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: (appBarRowHeight * 1),
                width: (appBarRowHeight * 1),
                child: ClipOval(
                  child: Image.asset(
                    GeneralAppConstant.UserProfileImagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        onPressed: () {
          MainDrawer.getDrawer(context);
        },
      ),
      title: Row(
        children: [
          Image.asset(
            GeneralAppConstant.AppLogoPath,
            fit: BoxFit.cover,
            width: 100,
          ),
        ],
      ),
      actions: [
        InkWell(
          onTap:() async {
            await LocalizationLoader.getNextString().then((newLangCode) {
              AppLocalization.changeLocale(Locale(newLangCode));
              setState(() {});
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Row(
              children: [
                Icon(
                  Icons.language_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 5,),
                Text(AppLocalization.instance.translate(AppLocalization.instance.locale.toString().split('/').first.toUpperCase()),style: const TextStyle(fontSize: 10),),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.search,
            color: Colors.grey,
          ),
          onPressed: () {
            // Arama butonuna tıklandığında yapılacak işlemler
          },
        ),
      ],
    );
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
                SizedBox(
                  child: Image.asset(GeneralAppConstant.AppLogoPath,
                      fit: BoxFit.cover),
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: SizedBox(child: Container())),
                ),
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
                          child: Image.asset(
                            GeneralAppConstant.UserProfileImagePath,
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
        ],
      ),
    );
  }
}

class CustomPopupMenu {
  static List<PopupMenuEntry> getMenuItems(
      BuildContext context) {
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
