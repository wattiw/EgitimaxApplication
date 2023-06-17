import 'package:egitimaxapplication/model/question/questionPageModel.dart';

abstract class QuestionOptionsState {}

class InitialInitState extends QuestionOptionsState {}

class LoadingInitState extends QuestionOptionsState {}

class LoadedInitState extends QuestionOptionsState {

  LoadedInitState();
}

class ErrorInitState extends QuestionOptionsState {
  final String errorMessage;

  ErrorInitState({required this.errorMessage});
}
