import 'package:egitimaxapplication/bloc/bloc/mainLayout/mainLayoutBloc.dart';
import 'package:egitimaxapplication/bloc/event/mainLayout/mainLayoutEvent.dart';
import 'package:egitimaxapplication/bloc/state/mainLayout/mainLayoutState.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/config/language/localizationLoader.dart';
import 'package:egitimaxapplication/utils/widget/appBar/mainAppBar.dart';
import 'package:egitimaxapplication/utils/widget/drawer/mainDrawer.dart';
import 'package:egitimaxapplication/utils/widget/navigation/mainBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({
    required BuildContext context,
    Key? key,
    this.errorStateContainer,
    this.loadedStateContainer,
    this.loadingStateContainer,
    this.initialStateContainer,
  }) : super(key: key);

  final Widget? errorStateContainer;
  final Widget? loadedStateContainer;
  final Widget? loadingStateContainer;
  final Widget? initialStateContainer;

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late MainLayoutBloc _MainLayoutBloc;

  @override
  void initState() {
    super.initState();
    _MainLayoutBloc = MainLayoutBloc();
    _MainLayoutBloc.add(RenderLayoutEvent());
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final String title = AppLocalization.instance
        .translate('lib.utils.widget.layout.mainLayout', 'build', 'title');
    return BlocProvider(
      create: (_) => _MainLayoutBloc,
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: MainAppBar(
          onChangeLanguage: () async {
            await LocalizationLoader.getNextString().then((newLangCode) {
              AppLocalization.changeLocale(Locale(newLangCode));
              setState(() {});
            });
          },
          onAvatarPressed: () {
            // Kullanıcı avatar düğmesine tıkladığında yapılacaklar
          },
          menuItems: CustomPopupMenu.getMenuItems(context),
          onQueryChanged: (String query) {
            // Arama sorgusu değiştiğinde yapılacaklar
          },
          onSearchPressed: () {
            // Mercek düğmesine tıklanınca yapılacaklar
          },
        ),
        body: BlocBuilder<MainLayoutBloc, MainLayoutState>(
          builder: (context, state) {
            if (state is InitialState) {
              return widget.initialStateContainer != null
                  ? Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            alignment: Alignment.center,
                            width: width > 600 ? width * 0.50 : width,
                            child: widget.initialStateContainer!),
                      ],
                    )
                  : Center(
                      child: FutureBuilder<Widget>(
                        future: initialStateContainer(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return snapshot.data!;
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    );
            }
            if (state is LoadingState) {
              return widget.loadingStateContainer != null
                  ? Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Container(
                              alignment: Alignment.center,
                              width: width > 600 ? width * 0.50 : width,
                              child: widget.loadingStateContainer!)
                        ])
                  : Center(
                      child: FutureBuilder<Widget>(
                        future: loadingStateContainer(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return snapshot.data!;
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    );
            }
            if (state is LoadedState) {
              return widget.loadedStateContainer != null
                  ? Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Container(
                              alignment: Alignment.center,
                              width: width > 600 ? width * 0.60 : width,
                              child: widget.loadedStateContainer!)
                        ])
                  : Center(
                      child: FutureBuilder<Widget>(
                        future: loadedStateContainer(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return snapshot.data!;
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    );
            }
            if (state is ErrorState) {
              return widget.errorStateContainer != null
                  ? Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Container(
                              alignment: Alignment.center,
                              width: width > 600 ? width * 0.50 : width,
                              child: widget.errorStateContainer!)
                        ])
                  : Center(
                      child: FutureBuilder<Widget>(
                        future: errorStateContainer(state),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return snapshot.data!;
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    );
            }
            return Container();
          },
        ),
        drawer: MainDrawer.getDrawer(context),
/*        bottomNavigationBar:
        MainBottomNavigationBar(
          tabs: const [
            Icon(Icons.home),
            Icon(Icons.search),
            Icon(Icons.settings),
          ],
        ),*/
      ),
    );
  }

  Future<Widget> initialStateContainer() async {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://wattiw.com.tr/Wattiw/WattiwTextBase.png',
            // replace with your own image URL
            width: 150,
          ), // replace with your own image
          const SizedBox(height: 20),
          Text(
            AppLocalization.instance.translate(
                'lib.utils.widget.layout.mainLayout',
                'build',
                'InitialStateContainer'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<Widget> loadingStateContainer() async {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // replace with your own animation or progress indicator
          const LinearProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            AppLocalization.instance.translate(
                'lib.utils.widget.layout.mainLayout',
                'build',
                'LoadingStateContainer'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<Widget> loadedStateContainer() async {
    return Center(
      child: Text(
        AppLocalization.instance.translate('lib.utils.widget.layout.mainLayout',
            'build', 'LoadedStateContainer'),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<Widget> errorStateContainer(ErrorState state) async {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // replace with your own graphic or message
          Text(
            AppLocalization.instance.translate(
                'lib.utils.widget.layout.mainLayout',
                'build',
                'ErrorStateContainer'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            state.errorMessage,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _MainLayoutBloc.close();
    super.dispose();
  }
}
