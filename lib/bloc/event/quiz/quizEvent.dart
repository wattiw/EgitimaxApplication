import 'package:egitimaxapplication/model/quiz/quizPageModel.dart';


abstract class QuizEvent {}

class InitEvent extends QuizEvent {
  final QuizPageModel quizPageModel;

  InitEvent({required this.quizPageModel});
}

class Step1Event extends QuizEvent {
  final QuizPageModel quizPageModel;

  Step1Event({required this.quizPageModel});
}

class Step2Event extends QuizEvent {
  final QuizPageModel quizPageModel;

  Step2Event({required this.quizPageModel});
}

class Step3Event extends QuizEvent {
  final QuizPageModel quizPageModel;

  Step3Event({required this.quizPageModel});
}

class LoadPmEvent extends QuizEvent {
  final QuizPageModel quizPageModel;

  LoadPmEvent({required this.quizPageModel});
}

class DeletePmEvent extends QuizEvent {
  final QuizPageModel quizPageModel;

  DeletePmEvent({required this.quizPageModel});
}

class RemovePmEvent extends QuizEvent {
  final QuizPageModel quizPageModel;

  RemovePmEvent({required this.quizPageModel});
}

class SavePmEvent extends QuizEvent {
  final QuizPageModel quizPageModel;

  SavePmEvent({required this.quizPageModel});
}

