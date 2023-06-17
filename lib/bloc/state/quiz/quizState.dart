
import 'package:egitimaxapplication/model/quiz/quizPageModel.dart';

abstract class QuizState {}

class InitState extends QuizState {}

class LoadingState extends QuizState {}

class LoadedState extends QuizState {
  final QuizPageModel quizPageModel;

  LoadedState({required this.quizPageModel});
}

class ErrorState extends QuizState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
}

class LoadingStep1State extends QuizState {}

class LoadedStep1State extends QuizState {
  final QuizPageModel quizPageModel;

  LoadedStep1State({required this.quizPageModel});
}

class ErrorStep1State extends QuizState {
  final String errorMessage;

  ErrorStep1State({required this.errorMessage});
}

class LoadingStep2State extends QuizState {}

class LoadedStep2State extends QuizState {
  final QuizPageModel quizPageModel;

  LoadedStep2State({required this.quizPageModel});
}

class ErrorStep2State extends QuizState {
  final String errorMessage;

  ErrorStep2State({required this.errorMessage});
}

class LoadingStep3State extends QuizState {}

class LoadedStep3State extends QuizState {
  final QuizPageModel quizPageModel;

  LoadedStep3State({required this.quizPageModel});
}

class ErrorStep3State extends QuizState {
  final String errorMessage;

  ErrorStep3State({required this.errorMessage});
}

class LoadingPmState extends QuizState {}

class LoadedPmState extends QuizState {
  final QuizPageModel quizPageModel;

  LoadedPmState({required this.quizPageModel});
}

class DeletingPmState extends QuizState {}

class DeletedPmState extends QuizState {
  final QuizPageModel quizPageModel;

  DeletedPmState({required this.quizPageModel});
}

class RemovingPmState extends QuizState {}

class RemovedPmState extends QuizState {
  final QuizPageModel quizPageModel;

  RemovedPmState({required this.quizPageModel});
}

class SavingPmState extends QuizState {}

class SavedPmState extends QuizState {
  final QuizPageModel quizPageModel;

  SavedPmState({required this.quizPageModel});
}

class ErrorPmState extends QuizState {
  final String errorMessage;

  ErrorPmState({required this.errorMessage});
}
