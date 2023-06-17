class SetQuizObjects {
  bool isDelete;
  bool isPassive;
  bool isActive;
  BigInt? quizId= BigInt.parse('0');
  String? quizObjectId;
  BigInt? userId= BigInt.parse('0');
  TblQuizMain? tblQuizMain;

  SetQuizObjects({
    required this.isDelete,
    required this.isPassive,
    required this.isActive,
    required this.quizId,
    required this.quizObjectId,
    required this.userId,
    this.tblQuizMain,
  });

  Map<String, dynamic> toMap() {
    return {
      'IsDelete': isDelete,
      'IsPassive': isPassive,
      'IsActive': isActive,
      'QuizId': quizId,
      'QuizObjectId': quizObjectId,
      'UserId': userId,
      'TblQuizMain': tblQuizMain?.toMap(),
    };
  }

  static SetQuizObjects fromMap(Map<String, dynamic> map) {
    return SetQuizObjects(
      isDelete: map['IsDelete'] ?? false,
      isPassive: map['IsPassive'] ?? false,
      isActive: map['IsActive'] ?? false,
      quizId: map['QuizId'] ?? 0,
      quizObjectId: map['QuizObjectId'],
      userId: map['UserId'] ?? 0,
      tblQuizMain: TblQuizMain.fromMap(map['TblQuizMain']),
    );
  }
}

class TblQuizMain {
  BigInt id= BigInt.parse('0');
  int? country;
  int? academicYear;
  BigInt? userId= BigInt.parse('0');
  int? gradeId;
  String title;
  String description;
  int? duration;
  String headerText;
  String footerText;
  int? isPublic;
  int? isActive;
  double? aggRating;
  BigInt? createdBy= BigInt.parse('0');
  DateTime? createdOn;
  BigInt? updatedBy= BigInt.parse('0');
  DateTime? updatedOn;
  List<TblQuizSection> tblQuizSections;

  TblQuizMain({
    required this.id,
    this.country,
    this.academicYear,
    this.userId,
    this.gradeId,
    required this.title,
    required this.description,
    this.duration,
    required this.headerText,
    required this.footerText,
    this.isPublic,
    this.isActive,
    this.aggRating,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    required this.tblQuizSections,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'country': country,
      'academic_year': academicYear,
      'user_id': userId,
      'grade_id': gradeId,
      'title': title,
      'description': description,
      'duration': duration,
      'header_text': headerText,
      'footer_text': footerText,
      'is_public': isPublic,
      'is_active': isActive,
      'agg_rating': aggRating,
      'created_by': createdBy,
      'created_on': createdOn?.toIso8601String(),
      'updated_by': updatedBy,
      'updated_on': updatedOn?.toIso8601String(),
      'tblQuizSections': tblQuizSections.map((section) => section.toMap()).toList(),
    };
  }

  static TblQuizMain fromMap(Map<String, dynamic> map) {
    return TblQuizMain(
      id: map['id'],
      country: map['country'],
      academicYear: map['academic_year'],
      userId: map['user_id'],
      gradeId: map['grade_id'],
      title: map['title'],
      description: map['description'],
      duration: map['duration'],
      headerText: map['header_text'],
      footerText: map['footer_text'],
      isPublic: map['is_public'],
      isActive: map['is_active'],
      aggRating: map['agg_rating'],
      createdBy: map['created_by'],
      createdOn: DateTime.tryParse(map['created_on']),
      updatedBy: map['updated_by'],
      updatedOn: DateTime.tryParse(map['updated_on']),
      tblQuizSections: (map['tblQuizSections'] as List<dynamic>)
          .map((sectionMap) => TblQuizSection.fromMap(sectionMap))
          .toList(),
    );
  }
}

class TblQuizSection {
  BigInt? id= BigInt.parse('0');
  BigInt? quizId= BigInt.parse('0');
  int? branchId;
  int? orderNo;
  String sectionDesc;
  int? isActive;
  List<TblQuizSectQuestMap> tblQuizSectQuestMaps;

  TblQuizSection({
    required this.id,
    this.quizId,
    this.branchId,
    this.orderNo,
    required this.sectionDesc,
    this.isActive,
    required this.tblQuizSectQuestMaps,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quiz_id': quizId,
      'branch_id': branchId,
      'order_no': orderNo,
      'section_desc': sectionDesc,
      'is_active': isActive,
      'tblQuizSectQuestMaps': tblQuizSectQuestMaps.map((map) => map.toMap()).toList(),
    };
  }

  static TblQuizSection fromMap(Map<String, dynamic> map) {
    return TblQuizSection(
      id: map['id'],
      quizId: map['quiz_id'],
      branchId: map['branch_id'],
      orderNo: map['order_no'],
      sectionDesc: map['section_desc'],
      isActive: map['is_active'],
      tblQuizSectQuestMaps: (map['tblQuizSectQuestMaps'] as List<dynamic>)
          .map((map) => TblQuizSectQuestMap.fromMap(map))
          .toList(),
    );
  }
}

class TblQuizSectQuestMap {
  BigInt? id= BigInt.parse('0');
  BigInt? sectionId= BigInt.parse('0');
  BigInt? questionId= BigInt.parse('0');
  int? orderNo;
  int? isActive;

  TblQuizSectQuestMap({
    required this.id,
    this.sectionId,
    this.questionId,
    this.orderNo,
    this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'section_id': sectionId,
      'question_id': questionId,
      'order_no': orderNo,
      'is_active': isActive,
    };
  }

  static TblQuizSectQuestMap fromMap(Map<String, dynamic> map) {
    return TblQuizSectQuestMap(
      id: map['id'],
      sectionId: map['section_id'],
      questionId: map['question_id'],
      orderNo: map['order_no'],
      isActive: map['is_active'],
    );
  }
}
