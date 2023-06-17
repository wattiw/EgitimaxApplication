
class SetQuestionObjects {
  bool isDelete = false;
  bool isPassive = false;
  bool isActive = false;
  BigInt? questionId = BigInt.parse('0');
  BigInt? userId = BigInt.parse('0');
  TblQueQuestionMain? tblQueQuestionMain;
  List<TblQueQuestOptions>? tblQueQuestOptions;
  List<TblQueQuestAchvMaps>? tblQueQuestAchvMaps;

  SetQuestionObjects({
    this.isDelete = false,
    this.isPassive = false,
    this.isActive = false,
    this.questionId ,
    this.userId,
    this.tblQueQuestionMain,
    this.tblQueQuestOptions,
    this.tblQueQuestAchvMaps,
  });

  factory SetQuestionObjects.fromMap(Map<String, dynamic> map) {
    return SetQuestionObjects(
      isDelete: map['IsDelete'] ?? false,
      isPassive: map['IsPassive'] ?? false,
      isActive: map['IsActive'] ?? false,
      questionId: map['QuestionId'] ?? 0,
      userId: map['UserId'] ?? 0,
      tblQueQuestionMain: map['TblQueQuestionMain'] != null ? TblQueQuestionMain.fromMap(map['TblQueQuestionMain']) : null,
      tblQueQuestOptions: map['TblQueQuestOptions'] != null ? List<TblQueQuestOptions>.from(map['TblQueQuestOptions'].map((x) => TblQueQuestOptions.fromMap(x))) : null,
      tblQueQuestAchvMaps: map['TblQueQuestAchvMaps'] != null ? List<TblQueQuestAchvMaps>.from(map['TblQueQuestAchvMaps'].map((x) => TblQueQuestAchvMaps.fromMap(x))) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'IsDelete': isDelete,
      'IsPassive': isPassive,
      'IsActive': isActive,
      'QuestionId': questionId,
      'UserId': userId,
      'TblQueQuestionMain': tblQueQuestionMain?.toMap(),
      'TblQueQuestOptions': tblQueQuestOptions?.map((x) => x.toMap()).toList(),
      'TblQueQuestAchvMaps': tblQueQuestAchvMaps?.map((x) => x.toMap()).toList(),
    };
  }
}


class TblQueQuestAchvMaps {
  BigInt id;
  BigInt? questId;
  int? achvId;
  int? isActive;

  TblQueQuestAchvMaps({
    required this.id,
    this.questId,
    this.achvId,
    this.isActive,
  });

  factory TblQueQuestAchvMaps.fromMap(Map<String, dynamic> json) => TblQueQuestAchvMaps(
    id: json['id'],
    questId: json['quest_id'],
    achvId: json['achv_id'],
    isActive: json['is_active'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'quest_id': questId,
    'achv_id': achvId,
    'is_active': isActive,
  };
}
class TblQueQuestionMain {
  BigInt id;
  int? questionType;
  int? academicYear;
  int? difficultyLev;
  int? country;
  BigInt? userId;
  int? gradeId;
  int? subdomId;
  String? questionText;
  String? questionImage;
  String? resolution;
  int? isPublic;
  int? isActive;
  int? isApproved;
  BigInt? createdBy;
  DateTime? createdOn;
  BigInt? updatedBy;
  DateTime? updatedOn;

  TblQueQuestionMain({
    required this.id,
    this.questionType,
    this.academicYear,
    this.difficultyLev,
    this.country,
    this.userId,
    this.gradeId,
    this.subdomId,
    this.questionText,
    this.questionImage,
    this.resolution,
    this.isPublic,
    this.isActive,
    this.isApproved,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
  });

  factory TblQueQuestionMain.fromMap(Map<String, dynamic> json) => TblQueQuestionMain(
    id: json['id'],
    questionType: json['question_type'],
    academicYear: json['academic_year'],
    difficultyLev: json['difficulty_lev'],
    country: json['country'],
    userId: json['user_id'],
    gradeId: json['grade_id'],
    subdomId: json['subdom_id'],
    questionText: json['question_text'],
    questionImage: json['question_image'],
    resolution: json['resolution'],
    isPublic: json['is_public'],
    isActive: json['is_active'],
    isApproved: json['is_approved'],
    createdBy: json['created_by'],
    createdOn: json['created_on'] != null ? DateTime.parse(json['created_on']) : null,
    updatedBy: json['updated_by'],
    updatedOn: json['updated_on'] != null ? DateTime.parse(json['updated_on']) : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'question_type': questionType,
    'academic_year': academicYear,
    'difficulty_lev': difficultyLev,
    'country': country,
    'user_id': userId,
    'grade_id': gradeId,
    'subdom_id': subdomId,
    'question_text': questionText,
    'question_image': questionImage,
    'resolution': resolution,
    'is_public': isPublic,
    'is_active': isActive,
    'is_approved': isApproved,
    'created_by': createdBy,
    'created_on': createdOn?.toIso8601String(),
    'updated_by': updatedBy,
    'updated_on': updatedOn?.toIso8601String(),
  };
}

class TblQueQuestOptions {
  late final BigInt id;
  late final BigInt? questId;
  late final String? optIdentifier;
  late final String? optText;
  late final int? isCorrect;
  late final int? isActive;

  TblQueQuestOptions({
    required this.id,
    this.questId,
    this.optIdentifier,
    this.optText,
    this.isCorrect,
    this.isActive,
  });

  factory TblQueQuestOptions.fromMap(Map<String, dynamic> map) {
    return TblQueQuestOptions(
      id: map['id'],
      questId: map['quest_id'],
      optIdentifier: map['opt_identifier'],
      optText: map['opt_text'],
      isCorrect: map['is_correct'],
      isActive: map['is_active'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quest_id': questId,
      'opt_identifier': optIdentifier,
      'opt_text': optText,
      'is_correct': isCorrect,
      'is_active': isActive,
    };
  }
}