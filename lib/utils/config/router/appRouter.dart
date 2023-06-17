import 'package:egitimaxapplication/screen/MyHomePage/MyHomePage.dart';
import 'package:egitimaxapplication/screen/common/questionDataTable.dart';
import 'package:egitimaxapplication/screen/questionPage/questionPage.dart';
import 'package:egitimaxapplication/screen/quizPage/quizPage.dart';
import 'package:egitimaxapplication/screen/videoPage/videoPage.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/constant/appConstant/generalAppConstant.dart';
import 'package:egitimaxapplication/utils/constant/router/appRouterConstant.dart';
import 'package:egitimaxapplication/utils/constant/router/heroTagConstant.dart';
import 'package:egitimaxapplication/utils/widget/layout/mainLayout.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> generateRoute(BuildContext context, RouteSettings settings) {
    switch (settings.name) {
      case AppRouterConstant.home:
        return MaterialPageRoute(
          builder: (_) =>  const MyHomePage(title: 'Egitimax',),
          settings: const RouteSettings(
              name: HeroTagConstant.home), // use the route name as the Hero tag
        );
      case AppRouterConstant.question:
        return MaterialPageRoute(
          builder: (_) => MainLayout(context: context, loadedStateContainer: QuestionPage(userId: BigInt.parse('2'),isEditorMode: true,questionId:  BigInt.parse(GeneralAppConstant.TempIdSilSonra ?? '0'),)),
          settings: const RouteSettings(
              name: HeroTagConstant.question), // use the route name as the Hero tag
        );
      case AppRouterConstant.video:
        return MaterialPageRoute(
          builder: (_) => MainLayout(context: context, loadedStateContainer: VideoPage(userId: BigInt.parse('2'),isEditorMode: true,videoId:  BigInt.parse(GeneralAppConstant.TempIdSilSonra ?? '0'),)),
          settings: const RouteSettings(
              name: HeroTagConstant.video), // use the route name as the Hero tag
        );
      case AppRouterConstant.quiz:
        return MaterialPageRoute(
          builder: (_) => MainLayout(context: context, loadedStateContainer: QuizPage(userId: BigInt.parse('2'),isEditorMode: true,quizId:  BigInt.parse(GeneralAppConstant.TempIdSilSonra ?? '0'),)),
          settings: const RouteSettings(
              name: HeroTagConstant.quiz), // use the route name as the Hero tag
        );
      case AppRouterConstant.questionSelector:
        return MaterialPageRoute(
          builder: (_) => MainLayout(context: context, loadedStateContainer: QuestionDataTable(userId: BigInt.parse('2'),componentTextStyle: const TextStyle(), onSelectedQuestionIdsChanged: (List<BigInt>? selectedQuestionIds) {  },)),
          settings: const RouteSettings(
              name: HeroTagConstant.questionSelector), // use the route name as the Hero tag
        );



      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                child: Text('${AppLocalization.instance.translate(
                    'lib.utils.configs.web.appRouter',
                    'generateRoute',
                    'defaultNoRoute')} ${settings.name}'),
              ),
            ));
    }
  }

  static Route<dynamic> unknownRoute(BuildContext context, RouteSettings settings) {
    // Eğer belirtilen isimde bir route yoksa, buraya düşecek.
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          body: Center(
            child: Text('${AppLocalization.instance.translate(
                'lib.utils.configs.web.appRouter',
                'unknownRoute',
                'noRouteMessage')} ${settings.name}'),
          ),
        );
      },
    );
  }
}
