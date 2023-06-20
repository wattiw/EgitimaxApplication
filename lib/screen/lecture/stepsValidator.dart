



import 'package:egitimaxapplication/model/lecture/lecturePageModel.dart';

class StepsValidator {
  final LecturePageModel lecturePageModel;

  StepsValidator(this.lecturePageModel);

  bool validateStep1() {


    return true;
  }

  bool validateStep2() {



    return true;
  }


  bool validateStep3() {
    if (validateStep1() && validateStep2()) {
      return true;
    } else {
      return false;
    }
  }
}
