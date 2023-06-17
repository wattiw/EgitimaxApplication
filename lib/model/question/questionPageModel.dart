import 'package:egitimaxapplication/model/question/question.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

class QuestionPageModel {

  late bool isEditorMode;
  late BigInt userId;
  late BigInt? questionId;

  bool isDelete = false;
  bool isPassive = false;
  bool isActive = true;
  bool isApproved = false;

  String? question;

  List<Option>? options = [];

  List<QuestionOptionsController>? questionOptionsController;

  String? freeTextAnswer;

  int? selectedCountry;
  Map<int, String> countries = {};

  int? selectedGrade;
  Map<int, String> grades = {};

  int? selectedAcademicYear;
  Map<int, String> academicYears = {};

  int? selectedQuestionType;
  Map<int, String> questionTypes = {};

  bool? isPublic=true;
  int? selectedDifficultyLevel;
  Map<int, String> difficultyLevels = {};

  int? selectedBranch;
  Map<int, String> branches = {};

  int? selectedDomain;
  Map<int, String> domains = {};

  int? selectedSubDomain;
  Map<int, String> subDomains = {};

  int? selectedLearn;

  Set<int> selectedAchievements = {};
  Map<int, String> achievements = {};
  Map<String, dynamic> achievementsBulk = {};



  QuestionPageModel({
    required this.isEditorMode,
    required this.userId,
    this.questionId,
  });

  Question? questionObject() {
    var questionObject = Question();
    questionObject.question = question;
    questionObject.options = options;
    return questionObject;
  }
}

class QuestionOptionsController {
  QuillEditorController textController = QuillEditorController();
  bool? isToolbarOpened = false;
  String? data;
  String? mark;
  bool isCorrect = false;
  bool isToolBarVisible=false;
}
