import 'package:egitimaxapplication/model/lecture/lecturePageModel.dart';

abstract class LectureEvent {}

class InitEvent extends LectureEvent {
  final LecturePageModel lecturePageModel;

  InitEvent({required this.lecturePageModel});
}

class Step1Event extends LectureEvent {
  final LecturePageModel lecturePageModel;

  Step1Event({required this.lecturePageModel});
}

class Step2Event extends LectureEvent {
  final LecturePageModel lecturePageModel;

  Step2Event({required this.lecturePageModel});
}

class Step3Event extends LectureEvent {
  final LecturePageModel lecturePageModel;

  Step3Event({required this.lecturePageModel});
}

class LoadPmEvent extends LectureEvent {
  final LecturePageModel lecturePageModel;

  LoadPmEvent({required this.lecturePageModel});
}

class DeletePmEvent extends LectureEvent {
  final LecturePageModel lecturePageModel;

  DeletePmEvent({required this.lecturePageModel});
}

class RemovePmEvent extends LectureEvent {
  final LecturePageModel lecturePageModel;

  RemovePmEvent({required this.lecturePageModel});
}

class SavePmEvent extends LectureEvent {
  final LecturePageModel lecturePageModel;

  SavePmEvent({required this.lecturePageModel});
}

