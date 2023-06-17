import 'package:egitimaxapplication/model/quiz/quizSection.dart';

class QuizMain {
  BigInt? id;
  int? country;
  int? academicYear;
  BigInt? userId;
  int? gradeId;
  String? title;
  String? description;
  int? duration;
  String? headerText;
  String? footerText;
  int? isPublic;
  int? isActive;
  num? aggRating;
  BigInt? createdBy;
  DateTime? createdOn;
  BigInt? updatedBy;
  DateTime? updatedOn;
  List<QuizSection>? quizSections;

  QuizMain({
    this.id,
    this.country,
    this.academicYear,
    this.userId,
    this.gradeId,
    this.title,
    this.description,
    this.duration,
    this.headerText,
    this.footerText,
    this.isPublic,
    this.isActive,
    this.aggRating,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
  });

  factory QuizMain.fromMap(Map<String, dynamic> map) {
    return QuizMain(
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
      createdOn: DateTime.parse(map['created_on']),
      updatedBy: map['updated_by'],
      updatedOn: DateTime.parse(map['updated_on']),
    );
  }

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
    };
  }
}
