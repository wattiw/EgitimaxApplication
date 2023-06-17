import 'package:egitimaxapplication/model/question/questionPageModel.dart';

abstract class QuestionState {}

class InitState extends QuestionState {}

class LoadingState extends QuestionState {}

class LoadedState extends QuestionState {
  final QuestionPageModel questionPageModel;

  LoadedState({required this.questionPageModel});
}

class ErrorState extends QuestionState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
}

class LoadingStep1State extends QuestionState {}

class LoadedStep1State extends QuestionState {
  final QuestionPageModel questionPageModel;

  LoadedStep1State({required this.questionPageModel});
}

class ErrorStep1State extends QuestionState {
  final String errorMessage;

  ErrorStep1State({required this.errorMessage});
}

class LoadingStep2State extends QuestionState {}

class LoadedStep2State extends QuestionState {
  final QuestionPageModel questionPageModel;

  LoadedStep2State({required this.questionPageModel});
}

class ErrorStep2State extends QuestionState {
  final String errorMessage;

  ErrorStep2State({required this.errorMessage});
}

class LoadingStep3State extends QuestionState {}

class LoadedStep3State extends QuestionState {
  final QuestionPageModel questionPageModel;

  LoadedStep3State({required this.questionPageModel});
}

class ErrorStep3State extends QuestionState {
  final String errorMessage;

  ErrorStep3State({required this.errorMessage});
}

class LoadingPmState extends QuestionState {}

class LoadedPmState extends QuestionState {
  final QuestionPageModel questionPageModel;

  LoadedPmState({required this.questionPageModel});
}

class DeletingPmState extends QuestionState {}

class DeletedPmState extends QuestionState {
  final QuestionPageModel questionPageModel;

  DeletedPmState({required this.questionPageModel});
}

class RemovingPmState extends QuestionState {}

class RemovedPmState extends QuestionState {
  final QuestionPageModel questionPageModel;

  RemovedPmState({required this.questionPageModel});
}

class SavingPmState extends QuestionState {}

class SavedPmState extends QuestionState {
  final QuestionPageModel questionPageModel;

  SavedPmState({required this.questionPageModel});
}

class ErrorPmState extends QuestionState {
  final String errorMessage;

  ErrorPmState({required this.errorMessage});
}
