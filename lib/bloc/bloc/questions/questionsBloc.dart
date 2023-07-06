import 'package:egitimaxapplication/bloc/event/questions/questionsEvent.dart';
import 'package:egitimaxapplication/bloc/state/questions/questionsState.dart';
import 'package:egitimaxapplication/repository/appRepositories.dart';
import 'package:egitimaxapplication/repository/questions/questionsRepository.dart';
import 'package:egitimaxapplication/screen/common/questionOverView.dart';
import 'package:egitimaxapplication/screen/common/userInteractiveMessage.dart';
import 'package:egitimaxapplication/screen/questionPage/questionPage.dart';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/constant/router/heroTagConstant.dart';
import 'package:egitimaxapplication/utils/extension/apiDataSetExtension.dart';
import 'package:egitimaxapplication/utils/widget/layout/mainLayout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class QuestionsBloc extends Bloc<QuestionsEvent, QuestionsState> {
  QuestionsBloc() : super(InitState()) {
    AppRepositories appRepositories = AppRepositories();
    QuestionsRepository questionsRepository;

    on<InitEvent>((event, emit) async {
      questionsRepository = await appRepositories.questionsRepository();
      emit(LoadingState());
      await Future.delayed(const Duration(seconds: 1));
      try {

        event.questionsPageModel.dataTableRoot = null;
        event.questionsPageModel.dataTableDataRoot = null;
        event.questionsPageModel.dataTableRows = null;

        var questionsRepository = await appRepositories.questionsRepository();

        var dataSet = await questionsRepository.getQuestionDataTableData(['*'],
            getNoSqlData: 0,
            user_id_for_isMyFavorite: event.questionsPageModel.userId,
            user_id: event.questionsPageModel.userId,
            academic_year: event.questionsPageModel.academicYearId == 0 ? null : event.questionsPageModel.academicYearId,
            difficulty_lev: event.questionsPageModel.difficultyId == 0 ? null : event.questionsPageModel.difficultyId,
            grade_id: event.questionsPageModel.gradeId == 0 ? null : event.questionsPageModel.gradeId,
            branch_id: event.questionsPageModel.branchId == 0 ? null : event.questionsPageModel.branchId,
            learn_id: event.questionsPageModel.selectedLearn == 0 ? null : event.questionsPageModel.selectedLearn,
            question_text: event.questionsPageModel.filterQuestionTextController.text == '' ||
                event.questionsPageModel.filterQuestionTextController.text.isEmpty
                ? null
                : event.questionsPageModel.filterQuestionTextController.text);

        emit(LoadedState(questionsPageModel: event.questionsPageModel));
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        emit(ErrorState(errorMessage: e.toString()));
      }
    });
  }
}
