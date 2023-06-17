
import 'package:egitimaxapplication/model/video/videoPageModel.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/widget/message/uIMessage.dart';
import 'package:fluttertoast/fluttertoast.dart';


class StepsValidator {
  final VideoPageModel videoModel;

  StepsValidator(this.videoModel);

  bool validateStep1() {
    bool isVideoSet = false;
    bool isVideoTitleSet = false;
    bool isVideoDescriptionsSet = true;
    bool isPublicSet = false;
    bool isConditionsAccepted = false;
    bool isExistVideoObjectId = false;

    if (videoModel.videoData != null) {
      isVideoSet = true;
    }

    if (videoModel.videoObjectId != null) {
      isExistVideoObjectId = true;
    }

    if (videoModel.videoTitle != null && videoModel.videoTitle!='') {
      isVideoTitleSet = true;
    }
    if (videoModel.videoDescriptions != null && videoModel.videoDescriptions!='') {
      isVideoDescriptionsSet = true;
    }

    if (videoModel.isPublic != null) {
      isPublicSet = true;
    }
    if (videoModel.isAcceptConditions != null && videoModel.isAcceptConditions==true) {
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


    return true;
  }

  bool validateStep2() {
    if (videoModel.selectedAcademicYear == null || videoModel.selectedAcademicYear==0) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep2', 'academicYearIsNotSelected'), gravity: ToastGravity.CENTER);
      return false;
    }

    if (videoModel.selectedGrade == null || videoModel.selectedGrade==0) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep2', 'gradeIsNotSelected'), gravity: ToastGravity.CENTER);
      return false;
    }

    if (videoModel.selectedBranch == null || videoModel.selectedBranch==0) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep2', 'branchIsNotSelected'), gravity: ToastGravity.CENTER);
      return false;
    }

    if (true ? false :videoModel.selectedDomain == null || videoModel.selectedDomain==0 && false) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep2', 'domainIsNotSelected'), gravity: ToastGravity.CENTER);
      return false;
    }

    if (true ? false :videoModel.selectedSubDomain == null || videoModel.selectedSubDomain==0 && false) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep2', 'subDomainIsNotSelected'), gravity: ToastGravity.CENTER);
      return false;
    }

    if (videoModel.selectedLearn == null || videoModel.selectedLearn==0) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep2', 'learnIsNotSelected'), gravity: ToastGravity.CENTER);
      return false;
    }

    if (videoModel.selectedAchievements.isEmpty || videoModel.achievements .length==0 ||  videoModel.achievements.length < videoModel.selectedAchievements.length) {
      UIMessage.showError(AppLocalization.instance.translate('lib.screen.videoPage.stepsValidator', 'validateStep2', 'noAchievementsSelected'), gravity: ToastGravity.CENTER);
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
