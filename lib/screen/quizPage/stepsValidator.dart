
import 'package:egitimaxapplication/model/quiz/quizPageModel.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/widget/message/uIMessage.dart';
import 'package:fluttertoast/fluttertoast.dart';


class StepsValidator {
  final QuizPageModel quizModel;

  StepsValidator(this.quizModel);

  bool validateStep1() {
   /* bool isVideoSet = false;
    bool isVideoTitleSet = false;
    bool isVideoDescriptionsSet = true;
    bool isPublicSet = false;
    bool isConditionsAccepted = false;
    bool isExistVideoObjectId = false;

    if (quizModel.videoData != null) {
      isVideoSet = true;
    }

    if (quizModel.videoObjectId != null) {
      isExistVideoObjectId = true;
    }

    if (quizModel.videoTitle != null && quizModel.videoTitle!='') {
      isVideoTitleSet = true;
    }
    if (quizModel.videoDescriptions != null && quizModel.videoDescriptions!='') {
      isVideoDescriptionsSet = true;
    }

    if (quizModel.isPublic != null) {
      isPublicSet = true;
    }
    if (quizModel.isAcceptConditions != null && quizModel.isAcceptConditions==true) {
      isConditionsAccepted = true;
    }


    if (!isVideoSet) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep1', 'videoNotUploaded'), gravity: ToastGravity.CENTER);
      return false;
    }

    if (!isExistVideoObjectId) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep1', 'reUploadVideo'), gravity: ToastGravity.CENTER);
      return false;
    }


    if (!isVideoTitleSet) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep1', 'videoTitleNotSet'), gravity: ToastGravity.CENTER);
      return false;
    }

    if (!isVideoDescriptionsSet) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep1', 'videoDescriptionIsNotSet'), gravity: ToastGravity.CENTER);
      return false;
    }

    if (!isPublicSet) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep1', 'publicOptionIsNotSet'), gravity: ToastGravity.CENTER);
      return false;
    }

    if (!isConditionsAccepted) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep1', 'termsAndConditionsNotAccepted'), gravity: ToastGravity.CENTER);
      return false;
    }

*/
    return true;
  }

  bool validateStep2() {
    // if (quizModel.selectedAcademicYear == null && quizModel.selectedAcademicYear==0) {
    //   UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep2', 'academicYearIsNotSelected'), gravity: ToastGravity.CENTER);
    //   return false;
    // }
    //
    // if (quizModel.selectedGrade == null && quizModel.selectedGrade==0) {
    //   UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep2', 'gradeIsNotSelected'), gravity: ToastGravity.CENTER);
    //   return false;
    // }
    //
    // if (quizModel.selectedBranch == null && quizModel.selectedBranch==0) {
    //   UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep2', 'branchIsNotSelected'), gravity: ToastGravity.CENTER);
    //   return false;
    // }
    //
    // if (quizModel.selectedDomain == null && quizModel.selectedSubDomain==0) {
    //   UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep2', 'domainIsNotSelected'), gravity: ToastGravity.CENTER);
    //   return false;
    // }
    //
    // if (quizModel.selectedSubDomain == null && quizModel.selectedSubDomain==0) {
    //   UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep2', 'subDomainIsNotSelected'), gravity: ToastGravity.CENTER);
    //   return false;
    // }
    //
    // if (quizModel.selectedAchievements.isEmpty || quizModel.achievements .length==0 ||  quizModel.achievements.length < quizModel.selectedAchievements.length) {
    //   UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep2', 'noAchievementsSelected'), gravity: ToastGravity.CENTER);
    //   return false;
    // }

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
