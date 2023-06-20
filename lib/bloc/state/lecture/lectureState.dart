import 'package:egitimaxapplication/model/lecture/lecturePageModel.dart';

abstract class LectureState {}

class InitState extends LectureState {}

class LoadingState extends LectureState {}

class LoadedState extends LectureState {
  final LecturePageModel lecturePageModel;

  LoadedState({required this.lecturePageModel});
}

class ErrorState extends LectureState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
}

class LoadingStep1State extends LectureState {}

class LoadedStep1State extends LectureState {
  final LecturePageModel lecturePageModel;

  LoadedStep1State({required this.lecturePageModel});
}

class ErrorStep1State extends LectureState {
  final String errorMessage;

  ErrorStep1State({required this.errorMessage});
}

class LoadingStep2State extends LectureState {}

class LoadedStep2State extends LectureState {
  final LecturePageModel lecturePageModel;

  LoadedStep2State({required this.lecturePageModel});
}

class ErrorStep2State extends LectureState {
  final String errorMessage;

  ErrorStep2State({required this.errorMessage});
}

class LoadingStep3State extends LectureState {}

class LoadedStep3State extends LectureState {
  final LecturePageModel lecturePageModel;

  LoadedStep3State({required this.lecturePageModel});
}

class ErrorStep3State extends LectureState {
  final String errorMessage;

  ErrorStep3State({required this.errorMessage});
}

class LoadingPmState extends LectureState {}

class LoadedPmState extends LectureState {
  final LecturePageModel lecturePageModel;

  LoadedPmState({required this.lecturePageModel});
}

class DeletingPmState extends LectureState {}

class DeletedPmState extends LectureState {
  final LecturePageModel lecturePageModel;

  DeletedPmState({required this.lecturePageModel});
}

class RemovingPmState extends LectureState {}

class RemovedPmState extends LectureState {
  final LecturePageModel lecturePageModel;

  RemovedPmState({required this.lecturePageModel});
}

class SavingPmState extends LectureState {}

class SavedPmState extends LectureState {
  final LecturePageModel lecturePageModel;

  SavedPmState({required this.lecturePageModel});
}

class ErrorPmState extends LectureState {
  final String errorMessage;

  ErrorPmState({required this.errorMessage});
}
