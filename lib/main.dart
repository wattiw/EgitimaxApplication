import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/config/router/appRouter.dart';
import 'package:egitimaxapplication/utils/constant/appConstant/generalAppConstant.dart';
import 'package:egitimaxapplication/utils/constant/language/appLocalizationConstant.dart';
import 'package:egitimaxapplication/utils/constant/router/appRouterConstant.dart';
import 'package:egitimaxapplication/utils/log/navigatorObserver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';


GetIt getIt = GetIt.instance;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      key: Key(GeneralAppConstant.ApplicationKey),
      navigatorKey: GlobalKey<NavigatorState>(),
      onGenerateTitle: (context) => GeneralAppConstant.OnGenerateTitle,
      // color: Colors.black,
      theme: ThemeData(
        dataTableTheme: DataTableThemeData(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1.0),
          ),
          dataRowColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.blue.withOpacity(0.5);
            }
            return null; // Default color
          }),
          dataRowMinHeight: 30.0,
          dataRowMaxHeight: 30.0,
          dataTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 10.0,
            fontWeight: FontWeight.normal,
          ),
          headingRowColor: MaterialStateProperty.all(Colors.blue),
          headingRowHeight: 30.0,
          headingTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
              decoration:TextDecoration.none,
            letterSpacing: 0.5,
            decorationStyle: TextDecorationStyle.double,
          ),
          horizontalMargin: 1.0,
          columnSpacing: 2,
          dividerThickness:0.1,
          checkboxHorizontalMargin: 10.0,
          headingCellCursor: MaterialStateProperty.all(MouseCursor.defer),
          dataRowCursor: MaterialStateProperty.all(MouseCursor.uncontrolled),
        ),
        useMaterial3: true,
        //colorSchemeSeed: Colors.red,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade50),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.light(
        useMaterial3: true,
      ),
      highContrastTheme: ThemeData.light(
        useMaterial3: true,
      ),
      highContrastDarkTheme: ThemeData.light(
        useMaterial3: true,
      ),
      locale: AppLocalizationConstant.DefaultLocale, //Locale('en', 'US'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalization.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('tr', 'TR'),
      ],
      showSemanticsDebugger: false,
      debugShowMaterialGrid: false,
      showPerformanceOverlay: false,
      checkerboardRasterCacheImages: false,
      checkerboardOffscreenLayers: false,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (child == null) {
          return Text( AppLocalization.instance.translate('lib.main', 'build', 'builder')); // Veya null değerle ilgili bir hata bildirimi gösterilebilir
        }
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // add your custom widget here
                Expanded(child: child),
              ],
            ),
          ),
        );
      },
      onGenerateRoute: (settings) => AppRouter.generateRoute(context,settings),
      onUnknownRoute: (settings) => AppRouter.unknownRoute(context,settings),
      navigatorObservers: [CustomNavigatorObserver()],
      initialRoute: AppRouterConstant.home,
      title: AppLocalization.instance.translate('lib.main', 'build', 'egitimaxApplicationTitle'),
    );
  }
}
