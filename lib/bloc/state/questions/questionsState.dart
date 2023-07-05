import 'package:egitimaxapplication/model/questions/questionsPageModel.dart';

abstract class QuestionsState {}

class InitState extends QuestionsState {}

class LoadingState extends QuestionsState {}

class LoadedState extends QuestionsState {
  final QuestionsPageModel questionsPageModel;

  LoadedState({required this.questionsPageModel});
}

class ErrorState extends QuestionsState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
}




