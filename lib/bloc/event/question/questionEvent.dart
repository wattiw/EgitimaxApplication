import 'package:egitimaxapplication/model/question/questionPageModel.dart';

abstract class QuestionEvent {}

class InitEvent extends QuestionEvent {
  final QuestionPageModel questionPageModel;

  InitEvent({required this.questionPageModel});
}

class Step1Event extends QuestionEvent {
  final QuestionPageModel questionPageModel;

  Step1Event({required this.questionPageModel});
}

class Step2Event extends QuestionEvent {
  final QuestionPageModel questionPageModel;

  Step2Event({required this.questionPageModel});
}

class Step3Event extends QuestionEvent {
  final QuestionPageModel questionPageModel;

  Step3Event({required this.questionPageModel});
}

class LoadPmEvent extends QuestionEvent {
  final QuestionPageModel questionPageModel;

  LoadPmEvent({required this.questionPageModel});
}

class DeletePmEvent extends QuestionEvent {
  final QuestionPageModel questionPageModel;

  DeletePmEvent({required this.questionPageModel});
}

class RemovePmEvent extends QuestionEvent {
  final QuestionPageModel questionPageModel;

  RemovePmEvent({required this.questionPageModel});
}

class SavePmEvent extends QuestionEvent {
  final QuestionPageModel questionPageModel;

  SavePmEvent({required this.questionPageModel});
}

