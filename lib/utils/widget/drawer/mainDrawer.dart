import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:flutter/material.dart';

class MainDrawer {
  static Drawer getDrawer(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
            ),
            child: Text(
              AppLocalization.instance.translate(
                  'lib.utils.widget.drawer.mainDrawer',
                  'getDrawer',
                  'DrawerHeaderText'),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.message, color: theme.colorScheme.primary),
            title: Text(AppLocalization.instance.translate(
                'lib.utils.widget.drawer.mainDrawer',
                'getDrawer',
                'ListTileMessages')),
            onTap: () {},
          ),
          ListTile(
            leading:
            Icon(Icons.account_circle, color: theme.colorScheme.primary),
            title: Text(AppLocalization.instance.translate(
                'lib.utils.widget.drawer.mainDrawer',
                'getDrawer',
                'ListTileProfile')),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings, color: theme.colorScheme.primary),
            title: Text(AppLocalization.instance.translate(
                'lib.utils.widget.drawer.mainDrawer',
                'getDrawer',
                'ListTileSettings')),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
