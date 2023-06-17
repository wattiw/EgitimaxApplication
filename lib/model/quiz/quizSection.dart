import 'package:egitimaxapplication/model/quiz/quizSectionQuestionMap.dart';

class QuizSection {
  BigInt? id;
  BigInt? quizId;
  int? branchId;
  int? orderNo;
  String? sectionDesc;
  int? isActive;
  List<QuizSectionQuestionMap>? quizSectionQuestionMaps;
  List<Map<String, dynamic>>? sectionSelectedQuestionsData;

  QuizSection({
    this.id,
    this.quizId,
    this.branchId,
    this.orderNo,
    this.sectionDesc,
    this.isActive,
  });

  factory QuizSection.fromMap(Map<String, dynamic> map) {
    return QuizSection(
      id: map['id'],
      quizId: map['quiz_id'],
      branchId: map['branch_id'],
      orderNo: map['order_no'],
      sectionDesc: map['section_desc'],
      isActive: map['is_active'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quiz_id': quizId,
      'branch_id': branchId,
      'order_no': orderNo,
      'section_desc': sectionDesc,
      'is_active': isActive,
    };
  }

  void updateOrderNo(int? orderNo) {
    this.orderNo = orderNo;
  }

  void updatequizSectionQuestionMaps(List<QuizSectionQuestionMap>? quizSectionQuestionMaps,int sectionOrderNo)
  {
    this.quizSectionQuestionMaps=quizSectionQuestionMaps;
  }
}
