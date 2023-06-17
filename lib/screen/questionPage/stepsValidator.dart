import 'package:egitimaxapplication/model/question/questionPageModel.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/widget/message/uIMessage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:egitimaxapplication/model/question/question.dart';

class StepsValidator {
  final QuestionPageModel questionModel;

  StepsValidator(this.questionModel);

  bool validateStep1() {
    bool isQuestionSet = false;
    bool isOptionExist = false;
    bool isEachOptionContentExist = true;
    bool isCorrectOptionsSet = false;
    bool isResolutionSet = false;

    if (questionModel.question != null && questionModel.question!.isNotEmpty  && questionModel.question != '') {
      isQuestionSet = true;
    }

    if (questionModel.options != null && questionModel.options!.isNotEmpty) {
      isOptionExist = true;
    }

    for (var op in questionModel.options!) {
      if (op.data != null && op.data!.length > 1) {

      } else {
        isEachOptionContentExist=false;
      }
      if (op.isCorrect == true) {
        isCorrectOptionsSet = true;
      }
    }

    if (questionModel.freeTextAnswer != null && questionModel.freeTextAnswer!.isNotEmpty && questionModel.freeTextAnswer!='') {
      isResolutionSet = true;
    }


    if (!isQuestionSet) {
      UIMessage.showError(
        AppLocalization.instance.translate('lib.screen.questionPage.stepsValidator', 'validateStep1', 'isQuestionSetMessage'),
        gravity: ToastGravity.CENTER,
      );
      return false;
    }

    if (!isOptionExist) {
      UIMessage.showError(
        AppLocalization.instance.translate('lib.screen.questionPage.stepsValidator', 'validateStep1', 'isOptionExistMessage'),
        gravity: ToastGravity.CENTER,
      );
      return false;
    }

    if (!isEachOptionContentExist) {
      UIMessage.showError(
        AppLocalization.instance.translate('lib.screen.questionPage.stepsValidator', 'validateStep1', 'isEachOptionContentExistMessage'),
        gravity: ToastGravity.CENTER,
      );
      return false;
    }

    if (!isCorrectOptionsSet) {
      UIMessage.showError(
        AppLocalization.instance.translate('lib.screen.questionPage.stepsValidator', 'validateStep1', 'isCorrectOptionsSetMessage'),
        gravity: ToastGravity.CENTER,
      );
      return false;
    }

    return true;
  }

  bool validateStep2() {

    if (questionModel.selectedAcademicYear == null || questionModel.selectedAcademicYear==0) {
      UIMessage.showError(
        AppLocalization.instance.translate('lib.screen.questionPage.stepsValidator', 'validateStep2', 'selectedAcademicYearMessage'),
        gravity: ToastGravity.CENTER,
      );
      return false;
    }

    if (questionModel.selectedQuestionType == null || questionModel.selectedQuestionType==0) {
      UIMessage.showError(
        AppLocalization.instance.translate('lib.screen.questionPage.stepsValidator', 'validateStep2', 'selectedQuestionTypeMessage'),
        gravity: ToastGravity.CENTER,
      );
      return false;
    }

    if (questionModel.selectedDifficultyLevel == null || questionModel.selectedDifficultyLevel==0) {
      UIMessage.showError(
        AppLocalization.instance.translate('lib.screen.questionPage.stepsValidator', 'validateStep2', 'selectedDifficultyLevelMessage'),
        gravity: ToastGravity.CENTER,
      );
      return false;
    }

    if (questionModel.isPublic == null) {
      UIMessage.showError(
        AppLocalization.instance.translate('lib.screen.questionPage.stepsValidator', 'validateStep2', 'isPublicMessage'),
        gravity: ToastGravity.CENTER,
      );
      return false;
    }

    if (questionModel.selectedGrade == null || questionModel.selectedGrade==0) {
      UIMessage.showError(
        AppLocalization.instance.translate('lib.screen.questionPage.stepsValidator', 'validateStep2', 'selectedGradeMessage'),
        gravity: ToastGravity.CENTER,
      );
      return false;
    }

    if (questionModel.selectedBranch == null || questionModel.selectedBranch==0) {
      UIMessage.showError(
        AppLocalization.instance.translate('lib.screen.questionPage.stepsValidator', 'validateStep2', 'selectedBranchMessage'),
        gravity: ToastGravity.CENTER,
      );
      return false;
    }

    if (true ? false :questionModel.selectedDomain == null || questionModel.selectedDomain==0) {
      UIMessage.showError(
        AppLocalization.instance.translate('lib.screen.questionPage.stepsValidator', 'validateStep2', 'selectedDomainMessage'),
        gravity: ToastGravity.CENTER,
      );
      return false;
    }

    if (true ? false : questionModel.selectedSubDomain == null  || questionModel.selectedSubDomain==0 && false) {
      UIMessage.showError(
        AppLocalization.instance.translate('lib.screen.questionPage.stepsValidator', 'validateStep2', 'selectedSubDomainMessage'),
        gravity: ToastGravity.CENTER,
      );
      return false;
    }

    if (questionModel.selectedLearn == null || questionModel.selectedLearn==0 ) {
      UIMessage.showError(
        AppLocalization.instance.translate('lib.screen.questionPage.stepsValidator', 'validateStep2', 'selectedLearnMessage'),
        gravity: ToastGravity.CENTER,
      );
      return false;
    }

    if (questionModel.selectedAchievements.isEmpty) {
      UIMessage.showError(
        AppLocalization.instance.translate('lib.screen.questionPage.stepsValidator', 'validateStep2', 'selectedAchievementsMessage'),
        gravity: ToastGravity.CENTER,
      );
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
