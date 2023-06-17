import 'package:egitimaxapplication/model/video/videoPageModel.dart';

abstract class VideoEvent {}

class InitEvent extends VideoEvent {
  final VideoPageModel videoPageModel;

  InitEvent({required this.videoPageModel});
}

class Step1Event extends VideoEvent {
  final VideoPageModel videoPageModel;

  Step1Event({required this.videoPageModel});
}

class Step2Event extends VideoEvent {
  final VideoPageModel videoPageModel;

  Step2Event({required this.videoPageModel});
}

class Step3Event extends VideoEvent {
  final VideoPageModel videoPageModel;

  Step3Event({required this.videoPageModel});
}

class LoadPmEvent extends VideoEvent {
  final VideoPageModel videoPageModel;

  LoadPmEvent({required this.videoPageModel});
}

class DeletePmEvent extends VideoEvent {
  final VideoPageModel videoPageModel;

  DeletePmEvent({required this.videoPageModel});
}

class RemovePmEvent extends VideoEvent {
  final VideoPageModel videoPageModel;

  RemovePmEvent({required this.videoPageModel});
}

class SavePmEvent extends VideoEvent {
  final VideoPageModel videoPageModel;

  SavePmEvent({required this.videoPageModel});
}

