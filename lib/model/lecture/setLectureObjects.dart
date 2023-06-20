class SetLectureObjects {
  bool isDelete;
  bool isPassive;
  bool isActive;
  BigInt lectureId;
  String? lectureObjectId;
  BigInt userId;
  TblCrsCourseMain? tblCrsCourseMain;

  SetLectureObjects({
    required this.isDelete,
    required this.isPassive,
    required this.isActive,
    required this.lectureId,
    this.lectureObjectId,
    required this.userId,
    this.tblCrsCourseMain,
  });

  Map<String, dynamic> toMap() {
    return {
      'isDelete': isDelete,
      'isPassive': isPassive,
      'isActive': isActive,
      'lectureId': lectureId,
      'lectureObjectId': lectureObjectId,
      'userId': userId,
      'tblCrsCourseMain': tblCrsCourseMain?.toMap(),
    };
  }

  static SetLectureObjects fromMap(Map<String, dynamic> map) {
    return SetLectureObjects(
      isDelete: map['isDelete'],
      isPassive: map['isPassive'],
      isActive: map['isActive'],
      lectureId: map['lectureId'],
      lectureObjectId: map['lectureObjectId'],
      userId: map['userId'],
      tblCrsCourseMain: TblCrsCourseMain.fromMap(map['tblCrsCourseMain']),
    );
  }
}

class TblCrsCourseMain {
  BigInt id;
  int? country;
  int? academicYear;
  BigInt? userId;
  int? learnId;
  int? gradeId;
  int? branchId;
  String? title;
  String? description;
  String? welcomeMsg;
  String? goodbyeMsg;
  int? isPublic;
  int? isActive;
  int? isApproved;
  double? aggRating;
  BigInt? createdBy;
  DateTime? createdOn;
  BigInt? updatedBy;
  DateTime? updatedOn;
  List<TblCrsCourseFlow>? tblCrsCourseFlows;

  TblCrsCourseMain({
    required this.id,
    this.country,
    this.academicYear,
    this.userId,
    this.learnId,
    this.gradeId,
    this.branchId,
     this.title,
     this.description,
     this.welcomeMsg,
     this.goodbyeMsg,
    this.isPublic,
    this.isActive,
    this.isApproved,
    this.aggRating,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.tblCrsCourseFlows,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'country': country,
      'academic_year': academicYear,
      'user_id': userId,
      'learn_id': learnId,
      'grade_id': gradeId,
      'branch_id': branchId,
      'title': title,
      'description': description,
      'welcome_msg': welcomeMsg,
      'goodbye_msg': goodbyeMsg,
      'is_public': isPublic,
      'is_active': isActive,
      'is_approved': isApproved,
      'agg_rating': aggRating,
      'created_by': createdBy,
      'created_on': createdOn?.toIso8601String(),
      'updated_by': updatedBy,
      'updated_on': updatedOn?.toIso8601String(),
      'tblCrsCourseFlows': tblCrsCourseFlows?.map((flow) => flow.toMap()).toList(),
    };
  }

  static TblCrsCourseMain fromMap(Map<String, dynamic> map) {
    return TblCrsCourseMain(
      id: map['id'],
      country: map['country'],
      academicYear: map['academic_year'],
      userId: map['user_id'],
      learnId: map['learn_id'],
      branchId: map['branch_id'],
      gradeId: map['grade_id'],
      title: map['title'],
      description: map['description'],
      welcomeMsg: map['welcome_msg'],
      goodbyeMsg: map['goodbye_msg'],
      isPublic: map['is_public'],
      isActive: map['is_active'],
      isApproved: map['is_approved'],
      aggRating: map['agg_rating'],
      createdBy: map['created_by'],
      createdOn: map['created_on'] != null ? DateTime.parse(map['created_on']) : null,
      updatedBy: map['updated_by'],
      updatedOn: map['updated_on'] != null ? DateTime.parse(map['updated_on']) : null,
      tblCrsCourseFlows: (map['tblCrsCourseFlows'] as List<dynamic>?)
          ?.map((flow) => TblCrsCourseFlow.fromMap(flow))
          .toList(),
    );
  }
}

class TblCrsCourseFlow {
  BigInt id;
  BigInt? courseId;
  int? orderNo;
  BigInt? videoId;
  BigInt? quizId;
  BigInt? docId;
  BigInt? questId;
  int? isActive;

  TblCrsCourseFlow({
    required this.id,
    this.courseId,
    this.orderNo,
    this.videoId,
    this.quizId,
    this.docId,
    this.questId,
    this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'order_no': orderNo,
      'video_id': videoId,
      'quiz_id': quizId,
      'doc_id': docId,
      'quest_id': questId,
      'is_active': isActive,
    };
  }

  static TblCrsCourseFlow fromMap(Map<String, dynamic> map) {
    return TblCrsCourseFlow(
      id: map['id'],
      courseId: map['course_id'],
      orderNo: map['order_no'],
      videoId: map['video_id'],
      quizId: map['quiz_id'],
      docId: map['doc_id'],
      questId: map['quest_id'],
      isActive: map['is_active'],
    );
  }
}
