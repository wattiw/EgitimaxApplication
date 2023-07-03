
import 'package:egitimaxapplication/model/quiz/quizPageModel.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/widget/message/uIMessage.dart';
import 'package:fluttertoast/fluttertoast.dart';


class StepsValidator {
  final QuizPageModel quizModel;

  StepsValidator(this.quizModel);

  bool validateStep1() {
    bool isAcademicYearSet = false;
    bool isGradeSet = false;
    bool isTitleSet = false;
    bool isDescriptionSet = false;
    bool isDurationSet = true;
    bool isPublicSet = false;
    bool isConditionsAccepted = false;



    if (quizModel.quizMain!.academicYear != null) {
      isAcademicYearSet = true;
    }

    if (quizModel.quizMain!.gradeId != null) {
      isGradeSet = true;
    }

    if (quizModel.quizMain!.title != null && quizModel.quizMain!.title!='') {
      isTitleSet = true;
    }
    if (quizModel.quizMain!.description != null && quizModel.quizMain!.description!='') {
      isDescriptionSet = true;
    }
    if (quizModel.quizMain!.duration != null && quizModel.quizMain!.duration!=0) {
      isDurationSet = true; // duration zorunlu değil
    }

    if (quizModel.quizMain!.isPublic != null) {
      isPublicSet = true;
    }
    if (quizModel.isAcceptConditions != null && quizModel.isAcceptConditions==true) {
      isConditionsAccepted = true;
    }


    if (!isAcademicYearSet) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.quizPage.stepsValidator', 'validateStep1', 'isAcademicYearSet'), gravity: ToastGravity.CENTER);
      return false;
    }
    if (!isGradeSet) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.quizPage.stepsValidator', 'validateStep1', 'isGradeSet'), gravity: ToastGravity.CENTER);
      return false;
    }
    if (!isTitleSet) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.quizPage.stepsValidator', 'validateStep1', 'isTitleSet'), gravity: ToastGravity.CENTER);
      return false;
    }
    if (!isDescriptionSet) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.quizPage.stepsValidator', 'validateStep1', 'isDescriptionSet'), gravity: ToastGravity.CENTER);
      return false;
    }
    if (!isDurationSet) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.quizPage.stepsValidator', 'validateStep1', 'isDurationSet'), gravity: ToastGravity.CENTER);
      return false;
    }

    if (!isPublicSet) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.quizPage.stepsValidator', 'validateStep1', 'isPublicSet'), gravity: ToastGravity.CENTER);
      return false;
    }
    if (!isConditionsAccepted) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.quizPage.stepsValidator', 'validateStep1', 'isConditionsAccepted'), gravity: ToastGravity.CENTER);
      return false;
    }



    return true;
  }

  bool validateStep2() {

    bool isAddedSectionQuestions=true;
    for(var section in quizModel.quizMain!.quizSections!)
      {
        if(section.quizSectionQuestionMaps==null || section.quizSectionQuestionMaps!.isEmpty)
          {
            isAddedSectionQuestions=false;
            break;
          }

      }
    if (!isAddedSectionQuestions) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.quizPage.stepsValidator', 'validateStep2', 'emptySection'), gravity: ToastGravity.CENTER);
       return false;
     }


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
