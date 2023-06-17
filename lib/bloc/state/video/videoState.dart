
import 'package:egitimaxapplication/model/video/videoPageModel.dart';

abstract class VideoState {}

class InitState extends VideoState {}

class LoadingState extends VideoState {}

class LoadedState extends VideoState {
  final VideoPageModel videoPageModel;

  LoadedState({required this.videoPageModel});
}

class ErrorState extends VideoState {
  final String errorMessage;

  ErrorState({required this.errorMessage});
}

class LoadingStep1State extends VideoState {}

class LoadedStep1State extends VideoState {
  final VideoPageModel videoPageModel;

  LoadedStep1State({required this.videoPageModel});
}

class ErrorStep1State extends VideoState {
  final String errorMessage;

  ErrorStep1State({required this.errorMessage});
}

class LoadingStep2State extends VideoState {}

class LoadedStep2State extends VideoState {
  final VideoPageModel videoPageModel;

  LoadedStep2State({required this.videoPageModel});
}

class ErrorStep2State extends VideoState {
  final String errorMessage;

  ErrorStep2State({required this.errorMessage});
}

class LoadingStep3State extends VideoState {}

class LoadedStep3State extends VideoState {
  final VideoPageModel videoPageModel;

  LoadedStep3State({required this.videoPageModel});
}

class ErrorStep3State extends VideoState {
  final String errorMessage;

  ErrorStep3State({required this.errorMessage});
}

class LoadingPmState extends VideoState {}

class LoadedPmState extends VideoState {
  final VideoPageModel videoPageModel;

  LoadedPmState({required this.videoPageModel});
}

class DeletingPmState extends VideoState {}

class DeletedPmState extends VideoState {
  final VideoPageModel videoPageModel;

  DeletedPmState({required this.videoPageModel});
}

class RemovingPmState extends VideoState {}

class RemovedPmState extends VideoState {
  final VideoPageModel videoPageModel;

  RemovedPmState({required this.videoPageModel});
}

class SavingPmState extends VideoState {}

class SavedPmState extends VideoState {
  final VideoPageModel videoPageModel;

  SavedPmState({required this.videoPageModel});
}

class ErrorPmState extends VideoState {
  final String errorMessage;

  ErrorPmState({required this.errorMessage});
}
