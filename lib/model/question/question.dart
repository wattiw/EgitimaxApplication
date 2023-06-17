class Question
{
  BigInt? id;
  String? question;
  List<Option>? options;
  List<Achievement>? achievement;
}

class Option {
  BigInt? id ;
  BigInt? questId;
  String? mark;
  String? text;
  String? data;
  bool? isCorrect;
  bool? isActive;

  Option({ this.id,this.questId, this.mark,  this.text,  this.data,  this.isCorrect,  this.isActive});
}

class Achievement {
  BigInt? id;
  BigInt? questId;
  int? achvId;
  int? isActive;

  Achievement({ this.id,this.questId, this.achvId,  this.isActive});
}