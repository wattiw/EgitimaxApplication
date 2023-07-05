
import 'package:egitimaxapplication/model/questions/questionsPageModel.dart';

abstract class QuestionsEvent {}

class InitEvent extends QuestionsEvent {
  final QuestionsPageModel questionsPageModel;

  InitEvent({required this.questionsPageModel});
}

