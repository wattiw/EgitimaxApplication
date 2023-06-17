class QuizSectionQuestionMap {
  BigInt? id;
  BigInt? sectionId;
  BigInt? questionId;
  int? orderNo;
  int? isActive;

  QuizSectionQuestionMap({
    this.id,
    this.sectionId,
    this.questionId,
    this.orderNo,
    this.isActive,
  });

  factory QuizSectionQuestionMap.fromMap(Map<String, dynamic> map) {
    return QuizSectionQuestionMap(
      id: map['id'],
      sectionId: map['section_id'],
      questionId: map['question_id'],
      orderNo: map['order_no'],
      isActive: map['is_active'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'section_id': sectionId,
      'question_id': questionId,
      'order_no': orderNo,
      'is_active': isActive,
    };
  }

  void updateOrderNo(int? orderNo) {
    this.orderNo = orderNo;
  }
}
