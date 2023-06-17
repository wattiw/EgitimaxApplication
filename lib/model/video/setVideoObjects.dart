class SetVideoObjects {
  bool isDelete = false;
  bool isPassive = false;
  bool isActive = false;
  BigInt? videoId = BigInt.parse('0');
  String? videoObjectId = null;
  BigInt? userId = BigInt.parse('0');
  TblVidVideoMain? tblVidVideoMain;
  List<TblVidVideoAchvMap>? tblVidVideoAchvMaps;

  SetVideoObjects({
    this.isDelete = false,
    this.isPassive = false,
    this.isActive = false,
    this.videoId ,
    this.videoObjectId,
    this.userId ,
    this.tblVidVideoMain,
    this.tblVidVideoAchvMaps,
  });

  factory SetVideoObjects.fromMap(Map<String, dynamic> map) {
    return SetVideoObjects(
      isDelete: map['IsDelete'] ?? false,
      isPassive: map['IsPassive'] ?? false,
      isActive: map['IsActive'] ?? false,
      videoId: map['VideoId'] ?? 0,
      videoObjectId: map['VideoObjectId'],
      userId: map['UserId'] ?? 0,
      tblVidVideoMain: map['TblVidVideoMain'] != null
          ? TblVidVideoMain.fromMap(map['TblVidVideoMain'])
          : null,
      tblVidVideoAchvMaps: map['TblVidVideoAchvMaps'] != null
          ? List<TblVidVideoAchvMap>.from(map['TblVidVideoAchvMaps']
              .map((x) => TblVidVideoAchvMap.fromMap(x)))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'IsDelete': isDelete,
      'IsPassive': isPassive,
      'IsActive': isActive,
      'VideoId': videoId,
      'VideoObjectId': videoObjectId,
      'UserId': userId,
      'TblVidVideoMain': tblVidVideoMain?.toMap(),
      'TblVidVideoAchvMaps':
          tblVidVideoAchvMaps?.map((x) => x.toMap()).toList(),
    };
  }
}

class TblVidVideoMain {
  BigInt? id = BigInt.parse('0');
  int? academicYear;
  int? country;
  BigInt? userId;
  int? branchId;
  int? gradeId;
  int? subdomId;
  String title = "";
  String description = "";
  String videoPath = "";
  int? isPublic;
  int? isActive;
  int? isApproved;
  double? aggRating;
  BigInt? createdBy;
  DateTime? createdOn;
  BigInt? updatedBy;
  DateTime? updatedOn;

  TblVidVideoMain({
    this.id ,
    this.academicYear,
    this.country,
    this.userId,
    this.branchId,
    this.gradeId,
    this.subdomId,
    this.title = "",
    this.description = "",
    this.videoPath = "",
    this.isPublic,
    this.isActive,
    this.isApproved,
    this.aggRating,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
  });

  factory TblVidVideoMain.fromMap(Map<String, dynamic> map) {
    return TblVidVideoMain(
      id: map['id'] ?? 0,
      academicYear: map['academic_year'],
      country: map['country'],
      userId: map['user_id'],
      branchId: map['branch_id'],
      gradeId: map['grade_id'],
      subdomId: map['subdom_id'],
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      videoPath: map['video_path'] ?? "",
      isPublic: map['is_public'],
      isActive: map['is_active'],
      isApproved: map['is_approved'],
      aggRating: map['agg_rating'],
      createdBy: map['created_by'],
      createdOn:
          map['created_on'] != null ? DateTime.parse(map['created_on']) : null,
      updatedBy: map['updated_by'],
      updatedOn:
          map['updated_on'] != null ? DateTime.parse(map['updated_on']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'academic_year': academicYear,
      'country': country,
      'user_id': userId,
      'branch_id': branchId,
      'grade_id': gradeId,
      'subdom_id': subdomId,
      'title': title,
      'description': description,
      'video_path': videoPath,
      'is_public': isPublic,
      'is_active': isActive,
      'is_approved': isApproved,
      'agg_rating': aggRating,
      'created_by': createdBy,
      'created_on': createdOn?.toIso8601String(),
      'updated_by': updatedBy,
      'updated_on': updatedOn?.toIso8601String(),
    };
  }
}

class TblVidVideoAchvMap {
  BigInt? id = BigInt.parse('0');
  BigInt? videoId;
  int? achvId;
  int? isActive;

  TblVidVideoAchvMap({
    this.id,
    this.videoId,
    this.achvId,
    this.isActive,
  });

  factory TblVidVideoAchvMap.fromMap(Map<String, dynamic> map) {
    return TblVidVideoAchvMap(
      id: map['id'] ?? 0,
      videoId: map['video_id'],
      achvId: map['achv_id'],
      isActive: map['is_active'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'video_id': videoId,
      'achv_id': achvId,
      'is_active': isActive,
    };
  }
}
