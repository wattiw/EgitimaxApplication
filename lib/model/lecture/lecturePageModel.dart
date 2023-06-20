import 'package:egitimaxapplication/model/lecture/setLectureObjects.dart';

class LecturePageModel {
  LecturePageModel({
    required this.isEditorMode,
    required this.userId,
    required this.lectureId,
  });

  late bool isEditorMode;
  late BigInt userId;
  late BigInt? lectureId;

  bool isDelete = false;
  bool isPassive = false;
  bool isActive = true;
  bool isApproved = false;
  bool? isAcceptConditions = false;

  Map<int, String> countries = {};
  Map<int, String> academicYears = {};
  Map<int, String> grades = {};
  Map<int, String> branches = {};


  SetLectureObjects? setLectureObjects;
}
